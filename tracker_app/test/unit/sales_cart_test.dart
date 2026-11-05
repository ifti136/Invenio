import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/sales/cart_controller.dart';
import 'package:tracker/features/sales/customer_repository.dart';
import 'package:tracker/features/sales/sale_models.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/settings/account_repository.dart';

void main() {
  late AppDatabase db;
  late ProductRepository products;
  late SaleRepository sales;
  late AccountRepository accounts;
  late CustomerRepository customers;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    products = ProductRepository(db);
    sales = SaleRepository(db);
    accounts = AccountRepository(db);
    customers = CustomerRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('cart merges duplicate products and computes live totals and flags', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartProvider.notifier);
    const mouse = Product(
      id: 1,
      name: 'Wired Mouse',
      priceMinor: 1200,
      costMinor: 800,
      stock: 5,
      lowStockAt: 3,
      archived: false,
    );

    cart.addProduct(mouse);
    cart.addProduct(mouse, qty: 2);

    var state = container.read(cartProvider);
    expect(state.lines, hasLength(1));
    expect(state.lines.single.qty, 3);
    expect(state.totalMinor, 3600);
    expect(state.profitMinor, 1200);
    expect(state.hasBelowCost, isFalse);

    cart.setUnitPrice(mouse.id, 1000);
    state = container.read(cartProvider);
    expect(state.lines.single.isDiscount, isTrue);
    expect(state.profitMinor, 600);

    cart.setUnitPrice(mouse.id, 700);
    state = container.read(cartProvider);
    expect(state.lines.single.isBelowCost, isTrue);
    expect(state.profitMinor, -300);

    cart.setQty(mouse.id, 9);
    state = container.read(cartProvider);
    expect(state.lines.single.isAboveStock, isTrue);
    expect(state.hasUnapprovedOverStock, isTrue);

    cart.setAllowAboveStock(mouse.id, true);
    state = container.read(cartProvider);
    expect(state.hasUnapprovedOverStock, isFalse);

    cart.removeProduct(mouse.id);
    expect(container.read(cartProvider).isEmpty, isTrue);
  });

  test('multi-line sale saves atomically and tracks a part payment', () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final customerId = await customers.addCustomer(name: 'Rina');
    final mouseId = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );
    final padId = await products.createProduct(
      name: 'Mouse pad',
      priceMinor: 500,
      costMinor: 300,
      initialStock: 3,
      lowStockAt: 1,
      archived: false,
    );
    final channelId = await _firstChannelId(db);

    final receipt = await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: mouseId,
          qty: 2,
          unitPriceMinor: 1200,
          unitCostMinor: 800,
        ),
        SaleLineInput(
          productId: padId,
          qty: 1,
          unitPriceMinor: 500,
          unitCostMinor: 300,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.partial,
      customerId: customerId,
      paidMinor: 1000,
      accountId: accountId,
    );

    expect(receipt.totalMinor, 2900);
    expect(receipt.paidMinor, 1000);
    expect(receipt.dueMinor, 1900);
    expect(receipt.status, 'partial');

    expect((await products.getProduct(mouseId))!.stock, 3);
    expect((await products.getProduct(padId))!.stock, 2);

    final sale = await db.select(db.sales).getSingle();
    expect(sale.totalMinor, 2900);
    expect(sale.status, 'partial');
    expect(sale.customerId, customerId);
    expect(await db.select(db.saleItems).get(), hasLength(2));
    final payment = await db.select(db.payments).getSingle();
    expect(payment.amountMinor, 1000);
    expect(payment.accountId, accountId);

    final saleMovements = await (db.select(db.stockMovements)
          ..where((movement) => movement.type.equals('sale')))
        .get();
    expect(saleMovements, hasLength(2));
    expect(saleMovements.every((movement) => movement.qty < 0), isTrue);

    var balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 11000);

    final result = await sales.recordPayment(
      saleId: sale.id,
      amountMinor: 1900,
      accountId: accountId,
    );
    expect(result.status, 'paid');
    expect(result.dueMinor, 0);

    balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 12900);
    final updated = await (db.select(db.sales)
          ..where((row) => row.id.equals(sale.id)))
        .getSingle();
    expect(updated.status, 'paid');
  });

  test('a failing cart line saves nothing', () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final goodId = await products.createProduct(
      name: 'Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );
    final emptyId = await products.createProduct(
      name: 'Cable',
      priceMinor: 500,
      costMinor: 300,
      initialStock: 0,
      lowStockAt: 1,
      archived: false,
    );
    final channelId = await _firstChannelId(db);

    await expectLater(
      sales.saveSale(
        lines: [
          SaleLineInput(
            productId: goodId,
            qty: 1,
            unitPriceMinor: 1200,
            unitCostMinor: 800,
          ),
          SaleLineInput(
            productId: emptyId,
            qty: 1,
            unitPriceMinor: 500,
            unitCostMinor: 300,
          ),
        ],
        channelId: channelId,
        payment: PaymentMode.paid,
        accountId: accountId,
      ),
      throwsA(isA<StateError>()),
    );

    expect(await db.select(db.sales).get(), isEmpty);
    expect(await db.select(db.saleItems).get(), isEmpty);
    expect(await db.select(db.payments).get(), isEmpty);
    expect(
      await (db.select(db.stockMovements)
            ..where((movement) => movement.type.equals('sale')))
          .get(),
      isEmpty,
    );
    expect((await products.getProduct(goodId))!.stock, 5);
    expect((await products.getProduct(emptyId))!.stock, 0);
  });

  test('part payment requires a customer', () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 0,
    );
    final productId = await products.createProduct(
      name: 'Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );
    final channelId = await _firstChannelId(db);

    await expectLater(
      sales.saveSale(
        lines: [
          SaleLineInput(
            productId: productId,
            qty: 1,
            unitPriceMinor: 1200,
            unitCostMinor: 800,
          ),
        ],
        channelId: channelId,
        payment: PaymentMode.partial,
        paidMinor: 500,
        accountId: accountId,
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(await db.select(db.sales).get(), isEmpty);
  });

  test('editing a sale restores removed stock and applies qty differences',
      () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final mouseId = await products.createProduct(
      name: 'Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );
    final padId = await products.createProduct(
      name: 'Pad',
      priceMinor: 500,
      costMinor: 300,
      initialStock: 3,
      lowStockAt: 1,
      archived: false,
    );
    final channelId = await _firstChannelId(db);

    final receipt = await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: mouseId,
          qty: 2,
          unitPriceMinor: 1200,
          unitCostMinor: 800,
        ),
        SaleLineInput(
          productId: padId,
          qty: 1,
          unitPriceMinor: 500,
          unitCostMinor: 300,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      accountId: accountId,
    );

    expect((await products.getProduct(mouseId))!.stock, 3);
    expect((await products.getProduct(padId))!.stock, 2);

    await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: mouseId,
          qty: 3,
          unitPriceMinor: 1200,
          unitCostMinor: 800,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      accountId: accountId,
      editingSaleId: receipt.saleId,
    );

    expect((await products.getProduct(mouseId))!.stock, 2);
    expect((await products.getProduct(padId))!.stock, 3);

    final sale = await db.select(db.sales).getSingle();
    expect(sale.totalMinor, 3600);
    final items = await db.select(db.saleItems).get();
    expect(items, hasLength(1));
    expect(items.single.productId, mouseId);
    expect(items.single.qty, 3);

    final payments = await db.select(db.payments).get();
    expect(payments, hasLength(1));
    expect(payments.single.amountMinor, 3600);

    final movements = await (db.select(db.stockMovements)
          ..where((movement) => movement.type.equals('sale')))
        .get();
    expect(movements, hasLength(1));
    expect(movements.single.qty, -3);

    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 13600);
  });

  test('deleting a sale restores stock and undo puts it back', () async {
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
    final channelId = await _firstChannelId(db);

    final receipt = await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: productId,
          qty: 1,
          unitPriceMinor: 2000,
          unitCostMinor: 1200,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      accountId: accountId,
    );

    final deleted = await sales.deleteSale(receipt.saleId);
    expect(deleted, isNotNull);
    expect((await products.getProduct(productId))!.stock, 4);
    expect(await db.select(db.sales).get(), isEmpty);
    expect(await db.select(db.payments).get(), isEmpty);

    await sales.restoreSale(deleted!);
    expect((await products.getProduct(productId))!.stock, 3);
    expect(await db.select(db.sales).get(), hasLength(1));
    expect(await db.select(db.payments).get(), hasLength(1));
    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, 7000);
  });
}

Future<int> _firstChannelId(AppDatabase db) async {
  final channels = await db.select(db.channels).get();
  return channels.first.id;
}
