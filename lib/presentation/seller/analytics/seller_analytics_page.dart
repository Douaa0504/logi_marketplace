import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerAnalyticsPage extends StatefulWidget {
  const SellerAnalyticsPage({super.key});

  @override
  State<SellerAnalyticsPage> createState() => _SellerAnalyticsPageState();
}

class _SellerAnalyticsPageState extends State<SellerAnalyticsPage> {
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  int _totalProducts = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final productsResponse = await client
          .from('products')
          .select('id')
          .eq('seller_id', currentUserId);

      final productsCount = (productsResponse as List).length;

      final ordersResponse = await client
          .from('orders')
          .select('total_price, status')
          .eq('seller_id', currentUserId);

      final ordersList = ordersResponse as List<dynamic>;
      final ordersCount = ordersList.length;

      double calculatedRevenue = 0.0;
      for (var order in ordersList) {
        final status = order['status'] as String?;

        if (status == 'completed' || status == 'accepted') {
          calculatedRevenue += (order['total_price'] as num).toDouble();
        }
      }

      setState(() {
        _totalProducts = productsCount;
        _totalOrders = ordersCount;
        _totalRevenue = calculatedRevenue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : RefreshIndicator(
              onRefresh: _fetchAnalyticsData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildMetricCard(
                    title: 'Total Revenue',
                    value: '\$${_totalRevenue.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    title: 'Total Orders',
                    value: '$_totalOrders',
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    title: 'Active Products',
                    value: '$_totalProducts',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
