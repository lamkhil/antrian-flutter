import 'package:antrian/data/services/auth/auth_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:antrian/globals/widgets/app_dialog.dart';

part 'login_controller.g.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final String email;
  final String password;
  final bool obscurePass;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.email = "",
    this.password = "",
    this.obscurePass = true,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? obscurePass,
    String? error,
    String? email,
    String? password,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePass: obscurePass ?? this.obscurePass,
    );
  }
}

@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void togglePassword() =>
      state = state.copyWith(obscurePass: !state.obscurePass);

  Future<void> login() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      AppDialog.error(message: "Email dan password wajib diisi");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthServices.login(state.email, state.password);
      if (result.user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      AppDialog.error(message: "Login gagal: ${e.toString()}");
      state = state.copyWith(error: e.toString(), isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: false);
  }
}
