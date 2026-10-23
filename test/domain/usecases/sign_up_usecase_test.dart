import 'package:flutter_test/flutter_test.dart';
import 'package:logi_marketplace/domain/repositories/auth_repository.dart';
import 'package:logi_marketplace/domain/usecases/sign_up_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SignUpUseCase', () {
    test('allows buyer and seller roles during registration', () async {
      for (final role in ['buyer', 'seller']) {
        final repository = _FakeAuthRepository();
        final useCase = SignUpUseCase(repository);

        await expectLater(
          useCase(
            email: 'person@example.com',
            password: 'password',
            fullName: 'Test Person',
            role: role,
          ),
          throwsA(isA<_RepositoryReached>()),
        );

        expect(repository.requestedRole, role);
      }
    });

    test(
      'rejects unsupported roles before contacting the repository',
      () async {
        final repository = _FakeAuthRepository();
        final useCase = SignUpUseCase(repository);

        await expectLater(
          useCase(
            email: 'person@example.com',
            password: 'password',
            fullName: 'Test Person',
            role: 'admin',
          ),
          throwsArgumentError,
        );
        expect(repository.requestedRole, isNull);
      },
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? requestedRole;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    requestedRole = role;
    throw const _RepositoryReached();
  }

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }

  @override
  Future<String> getUserRole() async {
    throw UnimplementedError();
  }
}

class _RepositoryReached implements Exception {
  const _RepositoryReached();
}
