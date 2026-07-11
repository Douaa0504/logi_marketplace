import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure that widget bindings are initialized before performing async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Load production environment configurations securely
  await dotenv.load(fileName: ".env");

  // Initialize Supabase client using updated dynamic variables and secure publishableKey
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(const LogiMarketplaceApp());
}

class LogiMarketplaceApp extends StatelessWidget {
  const LogiMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogiMarketplace',
      debugShowCheckedModeBanner: false,

      // Initializing default typography and premium system colors
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),

      home: const Scaffold(
        body: Center(
          child: Text(
            'LogiMarketplace: Environment Secured & Ready',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
      ),
    );
  }
}