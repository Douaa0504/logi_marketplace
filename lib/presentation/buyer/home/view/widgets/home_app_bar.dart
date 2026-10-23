import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_marketplace/core/navigation/app_router.dart';
import '../../../../auth/cubit/auth_cubit.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LogiMarket',
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Welcome back, discover products!',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _signOut(context),
          icon: Icon(Icons.logout_rounded, color: colors.onSurface),
          tooltip: 'Sign Out',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
