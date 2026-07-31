import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Storage
import 'package:logi_marketplace/core/storage/app_storage.dart';

// Auth Layer
import 'package:logi_marketplace/data/datasources/auth_remote_datasource.dart';
import 'package:logi_marketplace/data/repositories/auth_repository_impl.dart';
import 'package:logi_marketplace/domain/usecases/sign_in_usecase.dart';
import 'package:logi_marketplace/domain/usecases/sign_up_usecase.dart';
import 'package:logi_marketplace/presentation/auth/cubit/auth_cubit.dart';
import 'package:logi_marketplace/presentation/auth/pages/splash_page.dart';

// Product Layer
import 'package:logi_marketplace/data/datasources/product_remote_datasource.dart';
import 'package:logi_marketplace/data/repositories/product_repository_impl.dart';
import 'package:logi_marketplace/domain/usecases/add_product_usecase.dart';
import 'package:logi_marketplace/presentation/auth/cubit/product_cubit.dart';

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

    // Auth Dependencies
    final authDataSource = AuthRemoteDataSourceImpl(supabaseClient);
    final authRepository = AuthRepositoryImpl(authDataSource);
    final signInUseCase = SignInUseCase(authRepository);
    final signUpUseCase = SignUpUseCase(authRepository);

    // Product Dependencies
    final productDataSource = ProductRemoteDataSource(supabaseClient);
    final productRepository = ProductRepositoryImpl(productDataSource);
    final addProductUseCase = AddProductUseCase(productRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
            authRepository: authRepository,
          ),
        ),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(
            addProductUseCase: addProductUseCase,
            productRepository: productRepository,
          ),
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
