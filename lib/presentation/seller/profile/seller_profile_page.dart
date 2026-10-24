import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/app_router.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../domain/entities/shop_profile_entity.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../buyer/product_details/view/product_details_page.dart';
import '../../shared/public_shop_page.dart';
import 'edit_seller_profile_page.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  ShopProfileEntity? _profile;
  File? _selectedLogo;
  bool _isLoading = true;
  bool _isUploadingLogo = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await context
          .read<ProfileRepository>()
          .getCurrentSellerProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _selectedLogo = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedLogo = File(picked.path);
      _isUploadingLogo = true;
    });
    try {
      final repo = context.read<ProfileRepository>();
      final logoUrl = await repo.uploadSellerShopLogo(_selectedLogo!);
      final updated = await repo.updateSellerShopProfile(
        shopName: _profile?.shopName,
        shopDescription: _profile?.shopDescription,
        shopLogoUrl: logoUrl,
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _selectedLogo = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop logo updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _selectedLogo = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update shop logo: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  Future<void> _editProfile() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditSellerProfilePage(initialProfile: _profile),
      ),
    );
    if (saved == true && mounted) await _loadProfile();
  }

  void _previewShop() {
    final sellerId = _profile?.id;
    if (sellerId == null || sellerId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicShopPage(
          sellerId: sellerId,
          onProductTap: (product) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Shop')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store_mall_directory_outlined,
                    size: 44, color: colors.error),
                const SizedBox(height: 12),
                const Text(
                  'Your shop profile could not be loaded.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _profile!;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh shop profile',
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIdentityCard(profile, colors),
                    const SizedBox(height: 16),
                    _buildDescriptionCard(profile, colors),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _editProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit My Shop Profile'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _previewShop,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Preview Public Shop'),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Private account',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: colors.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.lock_outline,
                          color: colors.onSurfaceVariant,
                        ),
                        title: const Text('Account email'),
                        subtitle: Text(user?.email ?? 'Not signed in'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await context.read<AuthCubit>().signOut();
                            if (!context.mounted) return;
                            AppRouter.routeToAuth(context);
                          } catch (error) {
                            debugPrint('Unable to sign out: $error');
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not sign out. Please try again.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Disconnect Store'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: colors.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(
    ShopProfileEntity profile,
    ColorScheme colors,
  ) {
    final logoUrl = profile.publicShopLogoUrl;
    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colors.primaryContainer,
                  child: _selectedLogo != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedLogo!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : logoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            logoUrl,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.storefront_outlined,
                              size: 42,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.storefront_outlined,
                          size: 42,
                          color: colors.onPrimaryContainer,
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: colors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isUploadingLogo ? null : _pickAndUploadLogo,
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: _isUploadingLogo
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: colors.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.publicShopName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Public storefront identity',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _isUploadingLogo ? null : _pickAndUploadLogo,
              icon: const Icon(Icons.photo_camera_back_outlined, size: 18),
              label: Text(logoUrl == null ? 'Add shop logo' : 'Change shop logo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
    ShopProfileEntity profile,
    ColorScheme colors,
  ) {
    final description = (profile.shopDescription ?? '').trim();
    return Card(
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sticky_note_2_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  'About this shop',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description.isEmpty
                  ? 'Add a short introduction to help buyers get to know your shop.'
                  : description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: description.isEmpty
                    ? colors.onSurfaceVariant
                    : colors.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
