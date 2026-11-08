import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/sales/sale_models.dart';
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

  test('paid restock above the account balance is rejected unless allowed',
      () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 500,
    );
    final productId = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 0,
      lowStockAt: 3,
      archived: false,
    );

    await expectLater(
      products.restock(
        productId: productId,
        qty: 10,
        unitCostMinor: 100,
        accountId: accountId,
      ),
      throwsA(isA<NegativeBalanceException>()),
    );

    expect((await products.getProduct(productId))!.stock, 0);
    expect(await db.select(db.stockMovements).get(), isEmpty);

    await products.restock(
      productId: productId,
      qty: 10,
      unitCostMinor: 100,
      accountId: accountId,
      allowNegative: true,
    );

    expect((await products.getProduct(productId))!.stock, 10);
    final balances = await accounts.watchBalances().first;
    expect(balances.single.balanceMinor, -500);
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

  test('multi-line sale drops every product stock in one transaction',
      () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 0,
    );
    final firstId = await products.createProduct(
      name: 'Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 2,
      archived: false,
    );
    final secondId = await products.createProduct(
      name: 'Cable',
      priceMinor: 500,
      costMinor: 300,
      initialStock: 4,
      lowStockAt: 2,
      archived: false,
    );
    final thirdId = await products.createProduct(
      name: 'Pad',
      priceMinor: 300,
      costMinor: 100,
      initialStock: 2,
      lowStockAt: 1,
      archived: false,
    );
    final channelId = (await db.select(db.channels).get()).first.id;

    await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: firstId,
          qty: 2,
          unitPriceMinor: 1200,
          unitCostMinor: 800,
        ),
        SaleLineInput(
          productId: secondId,
          qty: 1,
          unitPriceMinor: 500,
          unitCostMinor: 300,
        ),
        SaleLineInput(
          productId: thirdId,
          qty: 2,
          unitPriceMinor: 300,
          unitCostMinor: 100,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      accountId: accountId,
    );

    expect((await products.getProduct(firstId))!.stock, 3);
    expect((await products.getProduct(secondId))!.stock, 3);
    expect((await products.getProduct(thirdId))!.stock, 0);
    expect(await db.select(db.saleItems).get(), hasLength(3));
  });

  test('editing product cost does not change past sale profit', () async {
    final accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 0,
    );
    final productId = await products.createProduct(
      name: 'Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 2,
      archived: false,
    );
    final channelId = (await db.select(db.channels).get()).first.id;

    await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: productId,
          qty: 1,
          unitPriceMinor: 1200,
          unitCostMinor: 800,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      accountId: accountId,
    );

    await products.updateProduct(
      id: productId,
      name: 'Mouse',
      priceMinor: 1200,
      costMinor: 1000,
      stock: 4,
      lowStockAt: 2,
      archived: false,
    );

    final item = await db.select(db.saleItems).getSingle();
    expect(item.unitCostMinor, 800);
    expect((await products.getProduct(productId))!.costMinor, 1000);
    final summaries = await sales.watchSales().first;
    expect(summaries.single.profitMinor, 400);
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

  test('product stream emits stock changes after a sale and after undo',
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

    expect((await products.watchProducts().first).single.stock, 5);

    final afterSale = products
        .watchProducts()
        .firstWhere((list) => list.single.stock == 3)
        .timeout(const Duration(seconds: 2));
    final receipt = await sales.saveQuickSale(
      productId: productId,
      qty: 2,
      unitPriceMinor: 1200,
      accountId: accountId,
    );
    expect((await afterSale).single.stock, 3);

    final afterUndo = products
        .watchProducts()
        .firstWhere((list) => list.single.stock == 5)
        .timeout(const Duration(seconds: 2));
    await sales.undoSale(receipt.saleId);
    expect((await afterUndo).single.stock, 5);
  });
}
