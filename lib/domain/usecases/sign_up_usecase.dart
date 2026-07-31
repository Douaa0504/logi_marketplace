import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User?> call({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
