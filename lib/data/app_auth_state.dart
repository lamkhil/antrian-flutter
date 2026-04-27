import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';

/// Combines Firebase Auth state with the user's Firestore profile so the
/// router can decide where to send each role. Acts as the GoRouter
/// `refreshListenable` — fires on signin/signout AND on user-doc changes
/// (e.g. counterId set, role flipped, paused toggled).
class AppAuthState extends ChangeNotifier {
  AppUser? _user;
  bool _profileLoading = false;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  AppAuthState() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) _onAuthChanged(current);
  }

  AppUser? get user => _user;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
  bool get isProfileLoading => isLoggedIn && _profileLoading && _user == null;

  void _onAuthChanged(User? authUser) {
    _profileSub?.cancel();
    if (authUser == null) {
      _user = null;
      _profileLoading = false;
      notifyListeners();
      return;
    }
    _profileLoading = true;
    notifyListeners();
    _profileSub = FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .snapshots()
        .listen((doc) {
      _user = doc.exists
          ? AppUser.fromMap({...?doc.data(), 'id': doc.id})
          : null;
      _profileLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}

final appAuthStateProvider = Provider<AppAuthState>((ref) {
  final state = AppAuthState();
  ref.onDispose(state.dispose);
  return state;
});
