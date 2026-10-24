import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/shop_profile_entity.dart';
import '../../../domain/repositories/profile_repository.dart';

class EditSellerProfilePage extends StatefulWidget {
  final ShopProfileEntity? initialProfile;

  const EditSellerProfilePage({super.key, this.initialProfile});

  @override
  State<EditSellerProfilePage> createState() => _EditSellerProfilePageState();
}

class _EditSellerProfilePageState extends State<EditSellerProfilePage> {
  late final TextEditingController _shopNameController;
  late final TextEditingController _shopDescriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _hasChanges = false;
  File? _selectedLogoFile;
  ShopProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _shopNameController = TextEditingController(
      text: widget.initialProfile?.publicShopName == 'Seller Shop'
          ? ''
          : widget.initialProfile?.publicShopName ?? '',
    );
    _shopDescriptionController = TextEditingController(
      text: widget.initialProfile?.shopDescription ?? '',
    );

    _shopNameController.addListener(() => _onChanged());
    _shopDescriptionController.addListener(() => _onChanged());
  }

  void _onChanged() {
    if (!mounted) return;
    final changed = _shopNameController.text.trim() !=
            (_profile?.shopName ?? '').trim() ||
        _shopDescriptionController.text.trim() !=
            (_profile?.shopDescription ?? '').trim() ||
        _selectedLogoFile != null;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _selectedLogoFile = File(picked.path);
        _hasChanges = true;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select shop logo: $error')),
      );
    }
  }

  Future<void> _saveProfile() async {
    // Le logo est téléversé avant d'enregistrer son URL avec les autres champs.
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<ProfileRepository>();
    setState(() => _isSaving = true);
    try {
      String? logoUrl;
      if (_selectedLogoFile != null) {
        logoUrl = await repo.uploadSellerShopLogo(_selectedLogoFile!);
      }

      final updated = await repo.updateSellerShopProfile(
        shopName: _shopNameController.text,
        shopDescription: _shopDescriptionController.text,
        shopLogoUrl: logoUrl ?? _profile?.shopLogoUrl,
      );

      if (!mounted) return;
      setState(() {
        _profile = updated;
        _selectedLogoFile = null;
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop profile saved successfully.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _confirmExit() async {
    // Évite de perdre les modifications saisies si l'utilisateur ferme l'éditeur.
    if (_isSaving) return false;
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard unsaved changes?'),
        content: const Text('Your current shop profile updates will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final logoUrl = _selectedLogoFile != null
        ? _selectedLogoFile!.path
        : _profile?.publicShopLogoUrl;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit My Shop Profile'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSaving
                ? null
                : () async {
              if (await _confirmExit()) {
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context, false);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _isSaving ? null : _pickLogo,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: colors.primary.withValues(alpha: 0.12),
                      child: _selectedLogoFile != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedLogoFile!,
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                              ),
                            )
                          : logoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                logoUrl,
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.storefront,
                                  size: 42,
                                  color: colors.primary,
                                ),
                              ),
                            )
                          : Icon(Icons.storefront, size: 42, color: colors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: _isSaving ? null : _pickLogo,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Change shop logo'),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: !_isSaving,
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop name',
                    border: OutlineInputBorder(),
                    hintText: 'My store name',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Enter a shop name.';
                    if (text.length > 80) return 'Shop name must be under 80 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_isSaving,
                  controller: _shopDescriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Shop description',
                    hintText: 'Tell buyers what makes your shop special.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isNotEmpty && text.length > 500) {
                      return 'Shop description is too long.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Private account',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser?.email ?? 'Not signed in',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
