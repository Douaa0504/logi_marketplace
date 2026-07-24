import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logi_marketplace/presentation/auth/cubit/product_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Storage
import 'core/storage/app_storage.dart';

// Auth Layer
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/auth/pages/splash_page.dart';

// Product Layer
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  await AppStorage().init();

  runApp(const LogiMarketplaceApp());
}

class LogiMarketplaceApp extends StatelessWidget {
  const LogiMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    // Dependency Injection
    final authDataSource = AuthRemoteDataSource(supabaseClient);
    final authRepository = AuthRepositoryImpl(authDataSource);

    // Dependency Injection for Products (Supabase)
    final productDataSource = ProductRemoteDataSource(supabaseClient);
    final productRepository = ProductRepositoryImpl(productDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository),
        ),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(productRepository),
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
        home: const SplashPage(),
      ),
    );
  }
}