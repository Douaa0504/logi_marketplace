import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final AuthResponse response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );

    final User? user = response.user;

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

  @override
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

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<String?> getUserRole(String userId) async {
    final data = await _supabaseClient
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

    return data['role'] as String?;
  }
}
