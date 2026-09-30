import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/auth/pages/auth_page.dart';
import '../../presentation/buyer/home/view/buyer_home_page.dart';
import '../../presentation/seller/dashboard/seller_dashboard_page.dart';

class AppRouter {
  static Future<void> routeUser(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (!context.mounted) return;

      if (response == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
              (route) => false,
        );
        return;
      }

      final String role = (response['role'] ?? 'buyer').toString().toLowerCase();

      if (role == 'seller') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboardPage()),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BuyerHomePage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
      );
    }
  }
}