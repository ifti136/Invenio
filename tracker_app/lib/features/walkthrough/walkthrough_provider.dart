import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughNotifier extends StateNotifier<WalkthroughState> {
  WalkthroughNotifier() : super(const WalkthroughState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('walkthrough_completed') ?? false;
      final shopName = prefs.getString('shop_name');
      state = state.copyWith(
        completed: completed,
        shopName: shopName,
        initialized: true,
      );
    } catch (_) {
      state = state.copyWith(completed: true, initialized: true);
    }
  }

  Future<void> completeWalkthrough(String shopName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walkthrough_completed', true);
    await prefs.setString('shop_name', shopName);
    state = state.copyWith(
      completed: true,
      shopName: shopName,
      initialized: true,
    );
  }

  Future<void> resetWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('walkthrough_completed');
    await prefs.remove('shop_name');
    state = const WalkthroughState(initialized: true);
  }
}

final walkthroughProvider =
    StateNotifierProvider<WalkthroughNotifier, WalkthroughState>((ref) {
  return WalkthroughNotifier();
});

class WalkthroughState {
  final bool completed;
  final bool initialized;
  final String? shopName;

  const WalkthroughState({
    this.completed = false,
    this.initialized = false,
    this.shopName,
  });

  WalkthroughState copyWith({
    bool? completed,
    bool? initialized,
    String? shopName,
  }) {
    return WalkthroughState(
      completed: completed ?? this.completed,
      initialized: initialized ?? this.initialized,
      shopName: shopName ?? this.shopName,
    );
  }
}

final shopNameProvider = Provider<String?>((ref) {
  return ref.watch(walkthroughProvider).shopName;
});
