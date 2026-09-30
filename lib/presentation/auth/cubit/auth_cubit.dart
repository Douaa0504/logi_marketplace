import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/app_storage.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;
  String _currentRole = 'buyer';

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  void toggleRole(String newRole) {
    _currentRole = newRole;
    emit(AuthInitial(selectedRole: _currentRole));
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (user != null) {
        await AppStorage().saveUserRole(role);
        emit(AuthSuccess(user: user, role: role));
      } else {
        emit(AuthFailure(message: 'Registration failed: Unknown error'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await signInUseCase(
        email: email,
        password: password,
      );

      if (user != null) {
        // تم تصحيح هذا السطر: الاستدعاء بدون وسائط لأنgetUserRole() تعتمد على المستخدم الجاري محلياً
        final role = await authRepository.getUserRole();
        final finalRole = role ?? 'buyer';
        await AppStorage().saveUserRole(finalRole);
        emit(AuthSuccess(user: user, role: finalRole));
      } else {
        emit(AuthFailure(message: 'Login failed: User record empty'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
    } catch (e) {
      // Ignore remote errors to ensure local state is cleared
    } finally {
      await AppStorage().clearAuthData();
      emit(AuthInitial(selectedRole: 'buyer'));
    }
  }
}