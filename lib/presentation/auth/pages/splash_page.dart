import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../domain/repositories/auth_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      await AppRouter.routeUser(context);
    } catch (error) {
      debugPrint('Unable to resolve the startup route: $error');
      if (!mounted) return;
      setState(() {
        _errorMessage = error is AuthProfileException
            ? error.message
            : 'Unable to verify your account right now. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _errorMessage = null);
                    _init();
                  },
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => AppRouter.routeToAuth(context),
                  child: const Text('Go to sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
