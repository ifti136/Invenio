import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(appDatabaseProvider));
});

final todayStatsProvider = StreamProvider<TodayStats>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchTodayStats();
});
