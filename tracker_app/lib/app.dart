import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/onboarding/first_run_providers.dart';
import 'features/onboarding/first_run_screen.dart';
import 'router.dart';

class TrackerApp extends ConsumerWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final firstRun = ref.watch(firstRunDoneProvider);

    return firstRun.when(
      loading: () => MaterialApp(
        title: 'Invenio',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => _routerApp(ref, themeMode),
      data: (done) {
        if (done) return _routerApp(ref, themeMode);
        return MaterialApp(
          title: 'Invenio',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: FirstRunScreen(
            onCompleted: () => ref.invalidate(firstRunDoneProvider),
          ),
        );
      },
    );
  }

  Widget _routerApp(WidgetRef ref, ThemeMode themeMode) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Invenio',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
