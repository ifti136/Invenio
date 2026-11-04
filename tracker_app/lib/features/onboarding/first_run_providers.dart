import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String firstRunDoneKey = 'first_run_done';

final firstRunDoneProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(firstRunDoneKey) ?? false;
  } catch (_) {
    return true;
  }
});

Future<void> markFirstRunDone() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(firstRunDoneKey, true);
  } catch (_) {}
}
