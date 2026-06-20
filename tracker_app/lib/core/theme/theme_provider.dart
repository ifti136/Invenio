import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeProvider extends _$ThemeProvider {
  static const _storageKey = 'selected_theme_id';

  @override
  Future<AppThemeId> build() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString(_storageKey);
    if (idString != null) {
      var id = AppThemeId.values.firstWhere(
        (id) => id.name == idString,
        orElse: () => AppThemeId.darkAurora,
      );

      // Map deprecated IDs to new ones
      if (id == AppThemeId.solidSlate) {
        id = AppThemeId.darkSolid;
      }

      return id;
    }
    return AppThemeId.darkAurora;
  }

  Future<void> setTheme(AppThemeId id) async {
    state = AsyncData(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, id.name);
  }
}
