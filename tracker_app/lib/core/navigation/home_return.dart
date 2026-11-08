import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeReturnController extends Notifier<bool> {
  @override
  bool build() => false;

  void arm() => state = true;

  void clear() => state = false;
}

final homeReturnProvider =
    NotifierProvider<HomeReturnController, bool>(HomeReturnController.new);

void goFromHome(BuildContext context, WidgetRef ref, String location) {
  ref.read(homeReturnProvider.notifier).arm();
  context.go(location);
}
