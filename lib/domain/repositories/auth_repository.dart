import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<User?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<String?> getUserRole(String userId);
}
