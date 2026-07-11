import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  String _currentRole = 'buyer';

  AuthCubit(this._authRepository) : super(AuthInitial());

  // Toggle role dynamically inside the login/register screen without full reload
  void toggleRole(String newRole) {
    _currentRole = newRole;
    emit(AuthInitial(selectedRole: _currentRole));
  }

  // Execute registration logic
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: _currentRole,
      );

      if (user != null) {
        emit(AuthSuccess(user: user, role: _currentRole));
      } else {
        emit(AuthFailure(message: 'Registration failed: Unknown error'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  // Execute login logic and fetch database role
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        final role = await _authRepository.getUserRole(user.id);
        emit(AuthSuccess(user: user, role: role ?? 'buyer'));
      } else {
        emit(AuthFailure(message: 'Login failed: User record empty'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}