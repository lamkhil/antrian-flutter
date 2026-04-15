import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pengaturan_controller.g.dart';

@riverpod
class PengaturanController extends _$PengaturanController {
  @override
  User? build() => FirebaseAuth.instance.currentUser;

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = null;
  }
}
