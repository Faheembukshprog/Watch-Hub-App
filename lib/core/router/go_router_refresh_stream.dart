import 'dart:async';
import 'package:flutter/foundation.dart';

/// Listenable adapter that converts a [Stream] into a [ChangeNotifier]
/// so GoRouter can observe auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
      onError: (Object _, StackTrace _) {},
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
