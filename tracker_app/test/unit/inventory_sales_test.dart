import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/settings/account_repository.dart';

void main() {
  late AppDatabase db;
  late ProductRepository products;
  late SaleRepository sales;
  late AccountRepository accounts;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    products = ProductRepository(db);
    sales = SaleRepository(db);
    accounts = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('restock updates stock, last cost, and deducts the account balance',
      () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final productId = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );

    await products.restock(
      productId: productId,
      qty: 10,
      unitCostMinor: 900,
      accountId: accountId,
      note: 'Supplier',
    );

    final product = await products.getProduct(productId);
    expect(product!.stock, 15);
    expect(product.costMinor, 900);

    final restock = await (db.select(db.stockMovements)
          ..where((m) => m.type.equals('restock')))
        .getSingle();
    expect(restock.qty, 10);
    expect(restock.unitCostMinor, 900);
    expect(restock.accountId, accountId);

    final expenses = await db.select(db.expenses).get();
    expect(expenses, isEmpty);

    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 10000 - (10 * 900));
  });

  test('quick sell saves sale, item, movement, and payment atomically',
      () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final productId = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );

    final receipt = await sales.saveQuickSale(
      productId: productId,
      qty: 2,
      unitPriceMinor: 1200,
      accountId: accountId,
    );

    expect(receipt.totalMinor, 2400);
    expect(receipt.paidMinor, 2400);
    expect(receipt.dueMinor, 0);

    final product = await products.getProduct(productId);
    expect(product!.stock, 3);

    final sale = await db.select(db.sales).getSingle();
    expect(sale.totalMinor, 2400);
    expect(sale.status, 'paid');

    final item = await db.select(db.saleItems).getSingle();
    expect(item.qty, 2);
    expect(item.unitPriceMinor, 1200);
    expect(item.unitCostMinor, 800);

    final movement = await (db.select(db.stockMovements)
          ..where((m) => m.type.equals('sale')))
        .getSingle();
    expect(movement.qty, -2);

    final payment = await db.select(db.payments).getSingle();
    expect(payment.amountMinor, 2400);
    expect(payment.accountId, accountId);

    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 10000 + 2400);
  });

  test('quick sell allows selling above stock', () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 0,
    );
    final productId = await products.createProduct(
      name: 'Cable',
      priceMinor: 500,
      costMinor: 300,
      initialStock: 1,
      lowStockAt: 1,
      archived: false,
    );

    await sales.saveQuickSale(
      productId: productId,
      qty: 3,
      unitPriceMinor: 500,
      accountId: accountId,
    );

    final product = await products.getProduct(productId);
    expect(product!.stock, -2);
  });

  test('undo restores stock and removes the sale ledger entries', () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 5000,
    );
    final productId = await products.createProduct(
      name: 'Keyboard',
      priceMinor: 2000,
      costMinor: 1200,
      initialStock: 4,
      lowStockAt: 2,
      archived: false,
    );

    final receipt = await sales.saveQuickSale(
      productId: productId,
      qty: 1,
      unitPriceMinor: 2000,
      accountId: accountId,
    );
    await sales.undoSale(receipt.saleId);

    final product = await products.getProduct(productId);
    expect(product!.stock, 4);
    expect(await db.select(db.sales).get(), isEmpty);
    expect(await db.select(db.saleItems).get(), isEmpty);
    expect(await db.select(db.payments).get(), isEmpty);
    expect(
      await (db.select(db.stockMovements)..where((m) => m.type.equals('sale')))
          .get(),
      isEmpty,
    );

    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 5000);
  });
}
