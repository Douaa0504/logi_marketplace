import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<User?> signIn({required String email, required String password});

  Future<void> signOut();
  Future<String> getUserRole();
}

class AuthProfileException implements Exception {
  final String message;

  const AuthProfileException(this.message);

  @override
  String toString() => message;
}
