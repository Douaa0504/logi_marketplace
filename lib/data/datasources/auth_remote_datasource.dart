import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSource(this._supabaseClient);

  // Direct API call to Supabase Auth and subsequent profile creation
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    // 1. Create the user authentication record
    final AuthResponse response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );

    final User? user = response.user;

    // 2. Insert profile metadata into the public profiles table if auth succeeds
    if (user != null) {
      await _supabaseClient.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    return user;
  }

  // Direct API call to authenticate existing users
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  // Retrieve the stored database role for a specific user ID
  Future<String?> getUserRole(String userId) async {
    final data = await _supabaseClient
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

    return data['role'] as String?;
  }
}