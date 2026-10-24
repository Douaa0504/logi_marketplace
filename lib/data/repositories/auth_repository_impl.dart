import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Relie les cas d'utilisation d'authentification au datasource Supabase.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> signUp({
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
    return response;
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
  Future<String> getUserRole() async {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) {
      throw const AuthProfileException('No authenticated user is available.');
    }

    final profile = await remoteDataSource.getUserProfile(user.id);
    if (profile == null) {
      throw const AuthProfileException(
        'Your account profile is missing. Contact support to restore access.',
      );
    }

    final role = profile['role']?.toString().trim().toLowerCase();
    // Seuls les rôles utilisés par les parcours de l'application sont acceptés.
    if (role == null || (role != 'buyer' && role != 'seller')) {
      throw const AuthProfileException(
        'Your account profile does not have a valid buyer or seller role.',
      );
    }

    return role;
  }
}
