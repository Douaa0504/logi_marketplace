import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/buyer_home_cubit.dart';
import '../../cubit/buyer_home_state.dart';
import '../../../../shared/category_chip.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  final List<String> _categories = const [
    'All',
    'Home',
    'Gaming',
    'Books',
    'Fashion',
    'Electronics'
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerHomeCubit, BuyerHomeState>(
      buildWhen: (previous, current) => current is BuyerHomeLoaded,
      builder: (context, state) {
        String selected = 'All';
        if (state is BuyerHomeLoaded) {
          selected = state.selectedCategory;
        }

        return SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryChip(
                label: category,
                isSelected: selected == category,
                onTap: () => context.read<BuyerHomeCubit>().selectCategory(category),
              );
            },
          ),
        );
      },
    );
  }
}
