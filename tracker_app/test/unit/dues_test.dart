import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/money/dues_repository.dart';
import 'package:tracker/features/sales/customer_repository.dart';
import 'package:tracker/features/sales/sale_models.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/settings/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late ProductRepository products;
  late SaleRepository sales;
  late CustomerRepository customers;
  late DuesRepository dues;
  late int channelId;
  late int accountId;
  late int customerId;
  late int productId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accounts = AccountRepository(db);
    products = ProductRepository(db);
    sales = SaleRepository(db);
    customers = CustomerRepository(db);
    dues = DuesRepository(db);
    channelId = (await db.select(db.channels).get()).first.id;
    accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 0,
    );
    customerId = await customers.addCustomer(name: 'Rina', phone: '017xx');
    productId = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1000,
      costMinor: 600,
      initialStock: 20,
      lowStockAt: 3,
      archived: false,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> creditSale({required int qty}) async {
    final receipt = await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: productId,
          qty: qty,
          unitPriceMinor: 1000,
          unitCostMinor: 600,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.due,
      customerId: customerId,
    );
    return receipt.saleId;
  }

  test('dues list groups unpaid sales by customer with the oldest date',
      () async {
    final first = await creditSale(qty: 1);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = await creditSale(qty: 2);

    final list = await dues.watchDues().first;
    expect(list, hasLength(1));
    expect(list.single.customerId, customerId);
    expect(list.single.dueMinor, 3000);
    expect(list.single.saleCount, 2);
    expect(list.single.phone, '017xx');

    final detail = (await dues.getDueDetail(customerId))!;
    expect(detail.sales.map((sale) => sale.id), [first, second]);
    expect(detail.sales.map((sale) => sale.dueMinor), [1000, 2000]);
    expect(detail.dueMinor, 3000);
    expect(detail.oldestCreatedAt, detail.sales.first.createdAt);
  });

  test('recording a payment settles the oldest sale first and updates status',
      () async {
    final first = await creditSale(qty: 1);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = await creditSale(qty: 2);

    final result = await dues.recordCustomerPayment(
      customerId: customerId,
      amountMinor: 1200,
      accountId: accountId,
    );
    expect(result.appliedMinor, 1200);
    expect(result.dueMinor, 1800);

    final payments = await db.select(db.payments).get();
    expect(payments, hasLength(2));
    final bySale = {for (final payment in payments) payment.saleId: payment};
    expect(bySale[first]!.amountMinor, 1000);
    expect(bySale[second]!.amountMinor, 200);

    final saved = await db.select(db.sales).get();
    expect(saved.firstWhere((sale) => sale.id == first).status, 'paid');
    expect(saved.firstWhere((sale) => sale.id == second).status, 'partial');

    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 1200);

    final detail = (await dues.getDueDetail(customerId))!;
    expect(detail.sales, hasLength(1));
    expect(detail.sales.single.id, second);
    expect(detail.dueMinor, 1800);
    expect(detail.payments, hasLength(2));
  });

  test('a payment can target one specific sale', () async {
    final first = await creditSale(qty: 1);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = await creditSale(qty: 1);

    final result = await dues.recordCustomerPayment(
      customerId: customerId,
      amountMinor: 400,
      accountId: accountId,
      saleId: second,
    );
    expect(result.dueMinor, 1600);

    final saved = await db.select(db.sales).get();
    expect(saved.firstWhere((sale) => sale.id == first).status, 'due');
    expect(saved.firstWhere((sale) => sale.id == second).status, 'partial');
    final payment = await db.select(db.payments).getSingle();
    expect(payment.saleId, second);
    expect(payment.amountMinor, 400);
  });

  test('payments cannot exceed the due', () async {
    await creditSale(qty: 1);
    expect(
      () => dues.recordCustomerPayment(
        customerId: customerId,
        amountMinor: 1200,
        accountId: accountId,
      ),
      throwsArgumentError,
    );
  });
}
