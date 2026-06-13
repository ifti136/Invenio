import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'core/background/aurora_backdrop.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class TrackerApp extends ConsumerWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeAsync = ref.watch(themeProviderProvider);

    return themeAsync.when(
      loading: () => const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (err, stack) =>
          MaterialApp(home: Scaffold(body: Center(child: Text('Error: $err')))),
      data: (themeId) {
        final settings = AppTheme.fromId(themeId);

        return MaterialApp.router(
          title: 'Tracker',
          theme: settings.data,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(
              settings.data.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light.copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: Colors.transparent,
                    )
                  : SystemUiOverlayStyle.dark.copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: Colors.transparent,
                    ),
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: AuroraBackdrop(config: settings.aurora),
                ),
                Positioned.fill(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
        );
      },
    );
  }
}
