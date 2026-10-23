import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/storage/app_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/auth/pages/auth_page.dart';
import '../../presentation/buyer/navigation/buyer_navigation_page.dart';
import '../../presentation/seller/dashboard/seller_dashboard_page.dart';

class AppRouter {
  static Future<void> routeUser(BuildContext context) async {
    final auth = Supabase.instance.client.auth;

    if (auth.currentSession == null || auth.currentUser == null) {
      routeToAuth(context);
      return;
    }

    final role = await context.read<AuthRepository>().getUserRole();
    if (!context.mounted) return;

    await AppStorage().saveUserRole(role);
    if (!context.mounted) return;

    final Widget destination = role == 'seller'
        ? const SellerDashboardPage()
        : const BuyerNavigationPage();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  static void routeToAuth(BuildContext context) {
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }
}
