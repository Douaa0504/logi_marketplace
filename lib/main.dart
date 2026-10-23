import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Storage
import 'package:logi_marketplace/core/storage/app_storage.dart';
import 'package:logi_marketplace/core/theme/theme_cubit.dart';

// Auth Layer
import 'package:logi_marketplace/data/datasources/auth_remote_datasource.dart';
import 'package:logi_marketplace/data/repositories/auth_repository_impl.dart';
import 'package:logi_marketplace/data/repositories/supabase_favorites_repository.dart';
import 'package:logi_marketplace/domain/repositories/auth_repository.dart';
import 'package:logi_marketplace/domain/repositories/favorites_repository.dart';
import 'package:logi_marketplace/domain/usecases/sign_in_usecase.dart';
import 'package:logi_marketplace/domain/usecases/sign_up_usecase.dart';
import 'package:logi_marketplace/presentation/auth/cubit/auth_cubit.dart';
import 'package:logi_marketplace/presentation/auth/pages/splash_page.dart';

// Product & Buyer/Seller Layers
import 'package:logi_marketplace/data/datasources/product_remote_datasource.dart';
import 'package:logi_marketplace/data/repositories/product_repository_impl.dart';
import 'package:logi_marketplace/domain/repositories/product_repository.dart';
import 'package:logi_marketplace/domain/usecases/add_product_usecase.dart';
import 'package:logi_marketplace/domain/usecases/update_product_usecase.dart';
import 'package:logi_marketplace/presentation/auth/cubit/product_cubit.dart';
import 'package:logi_marketplace/presentation/buyer/home/cubit/buyer_home_cubit.dart';
import 'package:logi_marketplace/presentation/buyer/favorites/favorites_cubit.dart';

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
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      supabaseClient: Supabase.instance.client,
    );

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    final signInUseCase = SignInUseCase(authRepository);
    final signUpUseCase = SignUpUseCase(authRepository);

    // Product Dependencies
    final productDataSource = ProductRemoteDataSourceImpl(
      supabaseClient: supabaseClient,
    );
    final productRepository = ProductRepositoryImpl(
      supabaseClient: supabaseClient,
      remoteDataSource: productDataSource,
    );
    final favoritesRepository = SupabaseFavoritesRepository(supabaseClient);
    final addProductUseCase = AddProductUseCase(productRepository);
    final updateProductUseCase = UpdateProductUseCase(productRepository);
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF2563EB),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A),
      onSurfaceVariant: const Color(0xFF64748B),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProductRepository>.value(value: productRepository),
        RepositoryProvider<FavoritesRepository>.value(
          value: favoritesRepository,
        ),
      ],
      child: MultiBlocProvider(
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
              updateProductUseCase: updateProductUseCase,
              productRepository: productRepository,
            ),
          ),
          BlocProvider<BuyerHomeCubit>(
            create: (context) =>
                BuyerHomeCubit(productRepository)..loadHomeData(),
          ),
          BlocProvider<FavoritesCubit>(
            create: (context) =>
                FavoritesCubit(favoritesRepository, productRepository),
          ),
          BlocProvider<ThemeCubit>(
            create: (_) {
              final appStorage = AppStorage();
              final initialThemeMode = appStorage.getThemeMode() ==
                      ThemeMode.dark.name
                  ? ThemeMode.dark
                  : ThemeMode.light;
              return ThemeCubit(
                initialThemeMode: initialThemeMode,
                saveThemeMode: (themeMode) =>
                    appStorage.saveThemeMode(themeMode.name),
              );
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp(
            title: 'LogiMarketplace',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                brightness: Brightness.dark,
              ),
            ),
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
