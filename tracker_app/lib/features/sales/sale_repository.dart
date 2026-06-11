import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';

part 'sale_repository.g.dart';

enum SalePlatform { facebook, offline }

extension SalePlatformX on SalePlatform {
  String get key => name;
  String get label => switch (this) {
        SalePlatform.facebook => 'Facebook',
        SalePlatform.offline => 'Offline',
      };
  static SalePlatform fromKey(String k) =>
      SalePlatform.values.firstWhere((e) => e.key == k, orElse: () => SalePlatform.offline);
}

enum PaymentStatus { paid, due }

extension PaymentStatusX on PaymentStatus {
  String get key => name;
  String get label => switch (this) {
        PaymentStatus.paid => 'Paid',
        PaymentStatus.due => 'Due',
      };
  static PaymentStatus fromKey(String k) =>
      PaymentStatus.values.firstWhere((e) => e.key == k, orElse: () => PaymentStatus.paid);
}

@Riverpod(keepAlive: true)
SaleRepository saleRepository(Ref ref) {
  return SaleRepository(ref.watch(appDatabaseProvider));
}

class AddSaleResult {
  final Sale sale;
  final int newStock;
  const AddSaleResult({required this.sale, required this.newStock});
}

class SaleRepository {
  SaleRepository(this._db);
  final AppDatabase _db;

  Stream<List<Sale>> watchAll() {
    final q = _db.select(_db.sales)
      ..orderBy([(s) => drift.OrderingTerm.desc(s.date)]);
    return q.watch();
  }

  Stream<List<Sale>> watchFiltered(SaleFilter f) {
    final q = _db.select(_db.sales);
    if (f.productId != null) {
      q.where((s) => s.productId.equals(f.productId!));
    }
    if (f.platform != null) {
      q.where((s) => s.platform.equals(f.platform!));
    }
    if (f.paymentStatus != null) {
      q.where((s) => s.paymentStatus.equals(f.paymentStatus!));
    }
    if (f.from != null) {
      q.where((s) =>
          s.date.isBiggerOrEqualValue(f.from!.millisecondsSinceEpoch));
    }
    if (f.to != null) {
      q.where((s) =>
          s.date.isSmallerOrEqualValue(f.to!.millisecondsSinceEpoch));
    }
    q.orderBy([(s) => drift.OrderingTerm.desc(s.date)]);
    return q.watch();
  }

  Future<Sale?> getById(int id) {
    return (_db.select(_db.sales)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Sale?> lastSellingPriceFor(int productId) async {
    final q = _db.select(_db.sales)
      ..where((s) => s.productId.equals(productId))
      ..orderBy([(s) => drift.OrderingTerm.desc(s.date)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    return row;
  }

  Future<AddSaleResult> addSale({
    required int productId,
    required int quantity,
    required double sellingPrice,
    required String platform,
    required String paymentStatus,
    String? customerName,
    DateTime? date,
    int? walletId,
    String? ownership,
    bool isDiscounted = false,
    double? normalPrice,
  }) {
    return _db.transaction(() async {
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingle();
      final newStock = product.stock - quantity;
      if (newStock < 0) {
        throw Exception(
            'Not enough stock — only ${product.stock} available.');
      }
      final effectiveDate = date ?? DateTime.now();
      final total = quantity * sellingPrice;
      final saleId = await _db.into(_db.sales).insert(
            SalesCompanion.insert(
              productId: productId,
              quantity: quantity,
              sellingPrice: sellingPrice,
              total: total,
              platform: platform,
              paymentStatus: paymentStatus,
              customerName: drift.Value(customerName),
              isDiscounted: drift.Value(isDiscounted),
              normalPrice: drift.Value(normalPrice),
              date: effectiveDate.millisecondsSinceEpoch,
              createdAt: DateTime.now().millisecondsSinceEpoch,
               walletId: drift.Value(walletId),
               ownership: drift.Value(ownership ?? 'business'),
             ),

          );
      await (_db.update(_db.products)..where((p) => p.id.equals(productId)))
          .write(ProductsCompanion(stock: drift.Value(newStock)));
      await _db.into(_db.stockMovements).insert(
            StockMovementsCompanion.insert(
              productId: productId,
              quantity: -quantity,
              type: 'sale',
              date: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      final sale = await (_db.select(_db.sales)
            ..where((s) => s.id.equals(saleId)))
          .getSingle();
      return AddSaleResult(sale: sale, newStock: newStock);
    });
  }

  Future<void> updateSale({
    required int id,
    required int productId,
    required int quantity,
    required double sellingPrice,
    required String platform,
    required String paymentStatus,
    String? customerName,
    DateTime? date,
    int? walletId,
    String? ownership,
  }) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.sales)
            ..where((s) => s.id.equals(id)))
          .getSingle();
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingle();
      final qtyDelta = quantity - existing.quantity;
      final newStock = product.stock - qtyDelta;
      if (newStock < 0) {
        throw Exception(
            'Not enough stock — only ${product.stock} available after this change.');
      }
      final effectiveDate = date ?? existing.dateAsDateTime;
      final total = quantity * sellingPrice;
      await (_db.update(_db.sales)..where((s) => s.id.equals(id))).write(
        SalesCompanion(
          productId: drift.Value(productId),
          quantity: drift.Value(quantity),
          sellingPrice: drift.Value(sellingPrice),
          total: drift.Value(total),
          platform: drift.Value(platform),
          paymentStatus: drift.Value(paymentStatus),
          customerName: drift.Value(customerName),
          date: drift.Value(effectiveDate.millisecondsSinceEpoch),
           walletId: drift.Value(walletId),
           ownership: drift.Value(ownership ?? 'business'),
         ),

      );
      if (qtyDelta != 0) {
        await (_db.update(_db.products)..where((p) => p.id.equals(productId)))
            .write(ProductsCompanion(stock: drift.Value(newStock)));
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: productId,
                quantity: -qtyDelta,
                type: 'sale',
                date: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });
  }

  Future<void> markAsPaid(int id) async {
    await (_db.update(_db.sales)..where((s) => s.id.equals(id))).write(
      const SalesCompanion(paymentStatus: drift.Value('paid')),
    );
  }

  Future<void> deleteSale(int id) {
    return _db.transaction(() async {
      final sale = await (_db.select(_db.sales)
            ..where((s) => s.id.equals(id)))
          .getSingle();
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(sale.productId)))
          .getSingle();
      await (_db.delete(_db.sales)..where((s) => s.id.equals(id))).go();
      await (_db.update(_db.products)
            ..where((p) => p.id.equals(sale.productId)))
          .write(ProductsCompanion(
              stock: drift.Value(product.stock + sale.quantity)));
       await _db.into(_db.stockMovements).insert(
             StockMovementsCompanion.insert(
               productId: sale.productId,
               quantity: sale.quantity,
               type: 'adjustment',
               note: const drift.Value('Stock restored — sale deleted'),
               date: DateTime.now().millisecondsSinceEpoch,
             ),
           );
    });
  }
}

extension on Sale {
  DateTime get dateAsDateTime =>
      DateTime.fromMillisecondsSinceEpoch(date);
}

class SaleFilter {
  final int? productId;
  final String? platform;
  final String? paymentStatus;
  final DateTime? from;
  final DateTime? to;

  const SaleFilter({
    this.productId,
    this.platform,
    this.paymentStatus,
    this.from,
    this.to,
  });

  SaleFilter copyWith({
    int? productId,
    Object? platform = _sentinel,
    Object? paymentStatus = _sentinel,
    Object? from = _sentinel,
    Object? to = _sentinel,
  }) {
    return SaleFilter(
      productId: productId ?? this.productId,
      platform:
          platform == _sentinel ? this.platform : platform as String?,
      paymentStatus: paymentStatus == _sentinel
          ? this.paymentStatus
          : paymentStatus as String?,
      from: from == _sentinel ? this.from : from as DateTime?,
      to: to == _sentinel ? this.to : to as DateTime?,
    );
  }

  SaleFilter clear() => const SaleFilter();

  static const _sentinel = Object();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleFilter &&
        other.productId == productId &&
        other.platform == platform &&
        other.paymentStatus == paymentStatus &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(productId, platform, paymentStatus, from, to);
}

class DateRangePreset {
  final String label;
  final DateTime from;
  final DateTime? to;
  const DateRangePreset(this.label, this.from, this.to);
}

List<DateRangePreset> dateRangePresets() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    DateRangePreset('All time', DateTime(2000), null),
    DateRangePreset('Today', today, null),
    DateRangePreset('This week',
        today.subtract(Duration(days: today.weekday - 1)), null),
    DateRangePreset('This month', DateTime(now.year, now.month, 1), null),
    DateRangePreset('Last 30 days', today.subtract(const Duration(days: 30)),
        null),
  ];
}
