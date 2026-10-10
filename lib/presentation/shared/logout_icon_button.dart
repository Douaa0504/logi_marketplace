import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutIconButton extends StatelessWidget {
  const LogoutIconButton({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      // Return to Auth/Login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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