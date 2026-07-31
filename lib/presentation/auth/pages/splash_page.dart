import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/storage/app_storage.dart';
import 'auth_page.dart';
import '../../buyer/home/buyer_home_page.dart';
import 'add_product_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final role = AppStorage().getUserRole();
        if (!mounted) return;

        if (role == 'seller') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BuyerHomePage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    } catch (_) {
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
