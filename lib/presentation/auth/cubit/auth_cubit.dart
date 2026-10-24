import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/app_storage.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

/// Coordonne les actions de connexion, inscription et fermeture de session.
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      final response = await signUpUseCase(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      final user = response.user;
      if (user != null) {
        // Sans session immédiate, le compte doit d'abord être confirmé par e-mail.
        if (response.session == null) {
          emit(AuthConfirmationRequired(email: email));
        } else {
          emit(AuthSuccess(user: user));
        }
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
      final user = await signInUseCase(email: email, password: password);

      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(AuthFailure(message: 'Login failed: User record empty'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    // Efface le rôle mis en cache après la fermeture de la session Supabase.
    await AppStorage().clearAuthData();
    emit(AuthInitial());
  }
}
