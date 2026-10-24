import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  static const String _shopLogoBucket = 'products';

  final SupabaseClient supabaseClient;

  ProfileRemoteDataSource({required this.supabaseClient});

  Future<Map<String, dynamic>> getCurrentProfile() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to access your shop profile.');
    }

    final profile = await supabaseClient
        .from('profiles')
        .select('id, full_name, role, shop_name, shop_description, shop_logo_url')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw StateError('Your seller profile could not be found.');
    }
    return Map<String, dynamic>.from(profile);
  }

  Future<Map<String, dynamic>> getProfileById(String sellerId) async {
    // La vue publique ne retourne que les champs destinés à la vitrine.
    final profile = await supabaseClient
        .from('public_seller_shops')
        .select('id, shop_name, shop_description, shop_logo_url')
        .eq('id', sellerId)
        .maybeSingle();

    if (profile == null) {
      throw StateError('This public shop could not be found.');
    }

    return Map<String, dynamic>.from(profile);
  }

  Future<Map<String, dynamic>> updateCurrentProfile({
    required String? shopName,
    required String? shopDescription,
    required String? shopLogoUrl,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to save your shop profile.');
    }

    final nextShopName = shopName == null
        ? null
        : shopName.trim().isEmpty
        ? null
        : shopName.trim();

    final nextShopDescription = shopDescription == null
        ? null
        : shopDescription.trim().isEmpty
        ? null
        : shopDescription.trim();

    final payload = <String, dynamic>{
      'shop_name': nextShopName,
      'shop_description': nextShopDescription,
      'shop_logo_url': shopLogoUrl,
    };

    final profile = await supabaseClient
        .from('profiles')
        .update(payload)
        .eq('id', user.id)
        .select('id, full_name, role, shop_name, shop_description, shop_logo_url')
        .single();

    return Map<String, dynamic>.from(profile);
  }

  Future<String> uploadCurrentShopLogo(File imageFile) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to upload your shop logo.');
    }

    final file = imageFile;
    final fileSizeInBytes = await file.length();
    final maxBytes = 2 * 1024 * 1024;
    if (fileSizeInBytes <= 0 || fileSizeInBytes > maxBytes) {
      throw StateError('Shop logo must be under 2 MB.');
    }

    final extension = file.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    // Le chemin inclut l'ID authentifié et un nom unique pour éviter l'écrasement.
    final path =
        'shop-logos/${user.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';
    final uploadBytes = await file.readAsBytes();
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

    await supabaseClient.storage.from(_shopLogoBucket).uploadBinary(
      path,
      uploadBytes,
      fileOptions: FileOptions(
        cacheControl: '3600',
        upsert: false,
        contentType: mimeType,
      ),
    );

    return supabaseClient.storage.from(_shopLogoBucket).getPublicUrl(path);
  }
}
