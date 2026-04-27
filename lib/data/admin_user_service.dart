import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/app_user.dart';

/// Creates Firebase Auth users from the admin panel without disturbing the
/// signed-in admin's session.
///
/// Why: `FirebaseAuth.createUserWithEmailAndPassword` on the default app
/// instance auto-signs-in the new user, kicking the admin out. We spin up a
/// secondary FirebaseApp just for the create call, then sign that secondary
/// instance out — the default app keeps the admin's session intact.
class AdminUserService {
  static const _secondaryName = 'admin_user_creator';

  final FirebaseFirestore _firestore;
  AdminUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<FirebaseApp> _secondaryApp() async {
    try {
      return Firebase.app(_secondaryName);
    } on FirebaseException {
      return Firebase.initializeApp(
        name: _secondaryName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  Future<AppUser> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? counterId,
  }) async {
    final app = await _secondaryApp();
    final auth = FirebaseAuth.instanceFor(app: app);
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final user = AppUser(
      id: uid,
      email: email.trim(),
      name: name.trim(),
      role: role,
      counterId: counterId,
    );
    await _users.doc(uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await auth.signOut();
    return user;
  }

  Future<AppUser> updateUser(String id, Map<String, dynamic> data) async {
    final clean = Map<String, dynamic>.from(data)
      ..remove('id')
      ..remove('email')
      ..remove('password');
    await _users.doc(id).set(clean, SetOptions(merge: true));
    final snap = await _users.doc(id).get();
    return AppUser.fromMap({...?snap.data(), 'id': snap.id});
  }

  /// Deletes the Firestore profile. Firebase Auth account removal requires
  /// the Admin SDK (server-side) — left as a follow-up.
  Future<void> deleteUserProfile(String id) async {
    await _users.doc(id).delete();
  }
}
