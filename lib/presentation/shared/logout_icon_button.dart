import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_marketplace/core/navigation/app_router.dart';
import 'package:logi_marketplace/presentation/auth/cubit/auth_cubit.dart';

class LogoutIconButton extends StatelessWidget {
  const LogoutIconButton({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthCubit>().signOut();
      if (!context.mounted) return;
      AppRouter.routeToAuth(context);
    } catch (error) {
      debugPrint('Unable to sign out: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: Color(0xFF0F172A)),
      onPressed: () => _handleLogout(context),
      tooltip: 'Logout',
    );
  }
}