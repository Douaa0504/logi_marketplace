import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      return await _remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
    } catch (e) {
      // Re-throw or handle custom formatting later
      rethrow;
    }
  }

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getUserRole(String userId) async {
    try {
      return await _remoteDataSource.getUserRole(userId);
    } catch (e) {
      rethrow;
    }
  }
}