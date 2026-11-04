import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'sale_repository.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(ref.watch(appDatabaseProvider));
});
