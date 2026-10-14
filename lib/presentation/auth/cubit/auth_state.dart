import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthState {}

// Initial state with the default role selection
class AuthInitial extends AuthState {
  final String selectedRole; // 'buyer' or 'seller'
  AuthInitial({this.selectedRole = 'buyer'});
}

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