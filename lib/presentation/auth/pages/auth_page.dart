import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/app_storage.dart';
import '../pages/buyer_home_page.dart';
import '../../seller/dashboard/seller_dashboard_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../shared/custom_text_field.dart';
import '../../shared/primary_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  String _selectedRole = 'buyer';

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color sellerDark = Color(0xFF1E293B);
  static const Color lightBackground = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleAuthSuccess(BuildContext context, AuthSuccess state) async {
    await AppStorage().saveUserRole(state.role);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Welcome back, ${state.user.email}!'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (state.role == 'seller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BuyerHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _selectedRole == 'seller' ? sellerDark : primaryBlue;

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              _handleAuthSuccess(context, state);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthInitial) {
              _selectedRole = state.selectedRole;
            }

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Logo Container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedRole == 'seller' ? Icons.storefront_rounded : Icons.shopping_bag_rounded,
                          size: 42,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignUp
                            ? 'Join LogiMarket and start your journey'
                            : 'Sign in to access your curated marketplace',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Modern Segmented Role Picker
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildRoleTab('Buyer', 'buyer', activeColor),
                            _buildRoleTab('Seller', 'seller', activeColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_isSignUp) ...[
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (val) => val == null || val.length < 6 ? 'Min 6 characters required' : null,
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: _isSignUp ? 'Create Account' : 'Sign In',
                        isLoading: state is AuthLoading,
                        color: activeColor,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_isSignUp) {
                              context.read<AuthCubit>().registerUser(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                fullName: _nameController.text.trim(),
                              );
                            } else {
                              context.read<AuthCubit>().loginUser(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isSignUp = !_isSignUp),
                            child: Text(
                              _isSignUp ? 'Sign In' : 'Sign Up',
                              style: TextStyle(
                                color: activeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleTab(String label, String role, Color activeColor) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRole = role);
          context.read<AuthCubit>().toggleRole(role);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? activeColor : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
