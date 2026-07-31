import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/product_cubit.dart';
import '../../auth/cubit/product_state.dart';
import '../../auth/pages/add_product_page.dart';
import '../../shared/logout_button.dart';
import '../../shared/product_card.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context.read<ProductCubit>().loadProducts(),
          color: const Color(0xFF2563EB),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildAnalyticsGrid(),
              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              _buildQuickActionGrid(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Inventory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Manage All', style: TextStyle(color: Color(0xFF2563EB))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInventoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logi Store',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -1),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Verified Seller',
                style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const LogoutButton(),
      ],
    );
  }

  Widget _buildAnalyticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Revenue', '\$4,250', Icons.account_balance_wallet_rounded, Colors.blue),
        _buildStatCard('Orders', '28', Icons.shopping_cart_checkout_rounded, Colors.orange),
        _buildStatCard('Products', '15', Icons.inventory_2_rounded, Colors.purple),
        _buildStatCard('Sold', '142', Icons.trending_up_rounded, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return Row(
      children: [
        _buildActionItem('Add Product', Icons.add_box_rounded, Colors.indigo, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()))
              .then((v) => context.read<ProductCubit>().loadProducts());
        }),
        const SizedBox(width: 16),
        _buildActionItem('Manage Orders', Icons.assignment_rounded, Colors.teal, () {}),
        const SizedBox(width: 16),
        _buildActionItem('Store Settings', Icons.settings_rounded, Colors.blueGrey, () {}),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return _buildEmptyInventory();
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        image: product.imageUrl != null ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('\$${product.price}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit_note_rounded, color: Colors.blue)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent)),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyInventory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Your inventory is empty', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          const Text('Start adding products to see them here', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }
}
