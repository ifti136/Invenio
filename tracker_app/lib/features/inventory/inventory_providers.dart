import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';

final lowStockCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.products).watch().map(
        (products) => products
            .where(
              (p) => !p.archived && p.stock > 0 && p.stock <= p.lowStockAt,
            )
            .length,
      );
});
