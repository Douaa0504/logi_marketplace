import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/product_repository.dart';
import '../cubit/buyer_home_cubit.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_selector.dart';
import 'widgets/product_grid_view.dart';

class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BuyerHomeCubit(context.read<ProductRepository>())..loadHomeData(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
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
                        color: Color(0xFF0F172A),
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
                        color: Color(0xFF0F172A),
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
