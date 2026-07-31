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
    return await _remoteDataSource.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<String?> getUserRole(String userId) async {
    return await _remoteDataSource.getUserRole(userId);
  }
}
