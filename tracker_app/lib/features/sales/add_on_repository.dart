import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tracker/db/app_database.dart';

part 'add_on_repository.g.dart';

@riverpod
AddOnRepository addOnRepository(Ref ref) {
  return AddOnRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<AddOnType>> addOnTypes(Ref ref) {
  return ref.watch(addOnRepositoryProvider).watchAllTypes();
}

@riverpod
Stream<List<AddOnType>> activeAddOnTypes(Ref ref) {
  return ref.watch(addOnRepositoryProvider).watchActiveTypes();
}

@riverpod
Stream<List<SaleAddOn>> saleAddOns(Ref ref, int saleId) {
  return ref.watch(addOnRepositoryProvider).watchForSale(saleId);
}

@riverpod
Stream<double> addOnTotalCost(Ref ref, int saleId) {
  return ref.watch(addOnRepositoryProvider).watchTotalCostForSale(saleId);
}

class AddOnRepository {
  final AppDatabase _db;

  AddOnRepository(this._db);

  Stream<List<AddOnType>> watchAllTypes() {
    return _db.select(_db.addOnTypes).watch();
  }

  Stream<List<AddOnType>> watchActiveTypes() {
    return (_db.select(_db.addOnTypes)..where((t) => t.isActive.equals(true)))
        .watch();
  }

  Future<List<AddOnType>> getActiveTypes() async {
    return (_db.select(_db.addOnTypes)..where((t) => t.isActive.equals(true)))
        .get();
  }

  Future<int> createType(
      {required String name,
      double defaultAmount = 0,
      bool isActive = true}) async {
    return await _db.into(_db.addOnTypes).insert(
          AddOnTypesCompanion.insert(
            name: name,
            isActive: Value(isActive),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> updateType(
      {required int id,
      required String name,
      double? defaultAmount,
      bool? isActive}) async {
    await (_db.update(_db.addOnTypes)..where((t) => t.id.equals(id))).write(
      AddOnTypesCompanion(
        name: Value(name),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteType(int id) async {
    await (_db.delete(_db.addOnTypes)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<SaleAddOn>> watchForSale(int saleId) {
    return (_db.select(_db.saleAddOns)..where((s) => s.saleId.equals(saleId)))
        .watch();
  }

  Future<List<SaleAddOn>> getForSale(int saleId) async {
    return (_db.select(_db.saleAddOns)..where((s) => s.saleId.equals(saleId)))
        .get();
  }

  Future<void> setForSale(int saleId, List<SaleAddOnsCompanion> addOns) async {
    await _db.transaction(() async {
      await (_db.delete(_db.saleAddOns)..where((s) => s.saleId.equals(saleId)))
          .go();
      for (final companion in addOns) {
        await _db.into(_db.saleAddOns).insert(
              companion.copyWith(saleId: Value(saleId)),
            );
      }
    });
  }

  Stream<double> watchTotalCostForSale(int saleId) {
    final query = _db.select(_db.saleAddOns)
      ..where((s) => s.saleId.equals(saleId));
    return query.watch().map((list) {
      double total = 0.0;
      for (final item in list) {
        total += item.cost * item.quantity;
      }
      return total;
    });
  }

  Future<double> totalCostForSale(int saleId) async {
    final results = await (_db.select(_db.saleAddOns)
          ..where((s) => s.saleId.equals(saleId)))
        .get();
    double total = 0.0;
    for (final item in results) {
      total += item.cost * item.quantity;
    }
    return total;
  }
}
