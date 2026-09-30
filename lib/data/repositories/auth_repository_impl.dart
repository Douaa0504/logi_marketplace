import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await remoteDataSource.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
    return response.user;
  }

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.signIn(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<String?> getUserRole() async {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) return null;
    final profile = await remoteDataSource.getUserProfile(user.id);
    return profile?['role'] as String?;
  }
}