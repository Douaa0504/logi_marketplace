import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

// Loading state for API calls
class AuthLoading extends AuthState {}

class AuthConfirmationRequired extends AuthState {
  final String email;

  AuthConfirmationRequired({required this.email});
}

// Success state returning the authenticated user
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess({required this.user});
}

// Failure state capturing error messages
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}
