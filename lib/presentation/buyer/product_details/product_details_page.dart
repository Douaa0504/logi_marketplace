import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';
import '../../shared/primary_button.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 1;
  final List<Color> _colors = [Colors.black, Colors.indigo, Colors.brown, Colors.grey];
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description ?? 'This premium product is crafted with high-quality materials to ensure durability and style. Perfect for daily use and versatile enough for any occasion.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildVariantSelectors(),
                  const SizedBox(height: 100), // Space for sticky bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${widget.product.id}',
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              image: widget.product.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.product.imageUrl == null
                ? const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 64, color: Color(0xFF64748B)),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                widget.product.category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '4.9 (2.4k Reviews)',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.product.title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'In Stock',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
    );
  }

  Widget _buildVariantSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Available Color'),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    color: _colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColorIndex == index ? const Color(0xFF2563EB) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _selectedColorIndex == index
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Select Size'),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sizes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final isSelected = _selectedSizeIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedSizeIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _sizes[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Price', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: PrimaryButton(
                label: 'Add to Cart',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Product added to cart!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
