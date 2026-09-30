import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logi_marketplace/presentation/auth/pages/auth_page.dart';
import 'package:logi_marketplace/presentation/buyer/home/view/buyer_home_page.dart';
import 'package:logi_marketplace/presentation/seller/dashboard/seller_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;

      debugPrint("DEBUG_AUTH: Session = ${session != null}, User = ${user?.id}");

      if (session == null || user == null) {
        debugPrint("DEBUG_AUTH: No active user, redirecting to AuthPage");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
        return;
      }

      // Fetch profile role directly from Supabase
      debugPrint("DEBUG_AUTH: Fetching role for user ${user.id}...");
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      debugPrint("DEBUG_AUTH: DB Profile Response = $response");

      final String? role = response?['role']?.toString();
      debugPrint("DEBUG_AUTH: Extracted Role = '$role'");

      if (!mounted) return;

      if (role == 'seller') {
        debugPrint("DEBUG_AUTH: SUCCESS -> NAVIGATING TO SELLER DASHBOARD!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboardPage()),
        );
      } else {
        debugPrint("DEBUG_AUTH: NAVIGATING TO BUYER HOME!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BuyerHomePage()),
        );
      }
    } catch (e, stack) {
      debugPrint("DEBUG_AUTH ERROR: $e");
      debugPrint(stack.toString());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_rounded, size: 80, color: Color(0xFF2563EB)),
            SizedBox(height: 24),
            Text(
              'LogiMarket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
