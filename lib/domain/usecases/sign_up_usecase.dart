import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthResponse> call({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    // Le rôle est limité aux deux parcours pris en charge par l'application.
    if (role != 'buyer' && role != 'seller') {
      throw ArgumentError.value(role, 'role', 'Role must be buyer or seller.');
    }

    return await repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
