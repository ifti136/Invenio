import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(appDatabaseProvider));
});

final reportProvider =
    StreamProvider.family<ReportData, ReportRange>((ref, range) {
  return ref.watch(reportRepositoryProvider).watchReport(range);
});
