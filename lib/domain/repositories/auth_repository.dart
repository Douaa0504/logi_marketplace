import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  // Sign up a new user with an email, password, full name, and defined role
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  // Sign in an existing user with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  });

  // Fetch the user profile from database to determine their role upon login
  Future<String?> getUserRole(String userId);
}