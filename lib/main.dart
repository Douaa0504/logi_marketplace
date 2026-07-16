import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/storage/app_storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/auth/pages/splash_page.dart';

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

  // Initialize Hive Local Storage Service for Offline-First session caching
  await AppStorage().init();

  runApp(const LogiMarketplaceApp());
}

class LogiMarketplaceApp extends StatelessWidget {
  const LogiMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate core architectures for dependency injection (Clean Architecture)
    final supabaseClient = Supabase.instance.client;
    final authDataSource = AuthRemoteDataSource(supabaseClient);
    final authRepository = AuthRepositoryImpl(authDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository),
        ),
      ],
      child: MaterialApp(
        title: 'LogiMarketplace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
        ),
        home: const SplashPage(), // Initial app entry point for session verification
      ),
    );
  }
}