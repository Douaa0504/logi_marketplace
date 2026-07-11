import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthState {}

// Initial state with the default role selection
class AuthInitial extends AuthState {
  final String selectedRole; // 'buyer' or 'seller'
  AuthInitial({this.selectedRole = 'buyer'});
}

// Loading state for API calls
class AuthLoading extends AuthState {}

// Success state returning the authenticated user and their business role
class AuthSuccess extends AuthState {
  final User user;
  final String role;
  AuthSuccess({required this.user, required this.role});
}

// Failure state capturing error messages
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}