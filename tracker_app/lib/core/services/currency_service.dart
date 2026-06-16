import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_service.g.dart';

class CurrencyService {
  static const String _symbolKey = 'currency_symbol';
  final SharedPreferences _prefs;

  CurrencyService(this._prefs);

  String get symbol {
    return _prefs.getString(_symbolKey) ?? '৳';
  }

  Future<void> setSymbol(String symbol) async {
    await _prefs.setString(_symbolKey, symbol);
  }

  Future<void> reset() async {
    await _prefs.remove(_symbolKey);
  }
}

@Riverpod(keepAlive: true)
Future<CurrencyService> currencyService(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return CurrencyService(prefs);
}

@riverpod
String currencySymbol(Ref ref) {
  final service = ref.watch(currencyServiceProvider).value;
  return service?.symbol ?? '৳';
}
