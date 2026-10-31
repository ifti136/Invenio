import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughNotifier extends StateNotifier<WalkthroughState> {
  WalkthroughNotifier() : super(const WalkthroughState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('walkthrough_completed') ?? false;
    final shopName = prefs.getString('shop_name');
    state = state.copyWith(
      completed: completed,
      shopName: shopName,
    );
  }

  Future<void> completeWalkthrough(String shopName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walkthrough_completed', true);
    await prefs.setString('shop_name', shopName);
    state = state.copyWith(completed: true, shopName: shopName);
  }

  Future<void> resetWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('walkthrough_completed');
    await prefs.remove('shop_name');
    state = const WalkthroughState();
  }
}

final walkthroughProvider =
    StateNotifierProvider<WalkthroughNotifier, WalkthroughState>((ref) {
  return WalkthroughNotifier();
});

class WalkthroughState {
  final bool completed;
  final String? shopName;

  const WalkthroughState({this.completed = false, this.shopName});

  WalkthroughState copyWith({bool? completed, String? shopName}) {
    return WalkthroughState(
      completed: completed ?? this.completed,
      shopName: shopName ?? this.shopName,
    );
  }
}

final shopNameProvider = Provider<String?>((ref) {
  return ref.watch(walkthroughProvider).shopName;
});
