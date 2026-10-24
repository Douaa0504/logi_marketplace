import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/product_repository.dart';
import '../cubit/buyer_home_cubit.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_selector.dart';
import 'widgets/product_grid_view.dart';

/// Assemble les contrôles de recherche, catégories et résultats du catalogue Buyer.
class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  @override
  Widget build(BuildContext context) {
    // Le Cubit est lié à cette page et charge les produits à son ouverture.
    return BlocProvider(
      create: (context) =>
          BuyerHomeCubit(context.read<ProductRepository>())..loadHomeData(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: HomeAppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  SearchFilterBar(
                    onSearchChanged: (query) =>
                        context.read<BuyerHomeCubit>().searchProducts(query),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  CategorySelector(),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Popular Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ProductGridView(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
