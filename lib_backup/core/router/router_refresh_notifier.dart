import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _sub;

  RouterRefreshNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners(); // trigger GoRouter redirect
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
