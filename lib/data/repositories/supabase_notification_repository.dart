import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/seller_notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// Lit et met à jour les notifications du vendeur connecté.
class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient supabaseClient;

  SupabaseNotificationRepository(this.supabaseClient);

  @override
  Future<List<SellerNotificationEntity>> getNotifications() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to view notifications.');
    }

    final rows = await supabaseClient
        .from('seller_notifications')
        .select()
        // Ce filtre explicite complète les contrôles d'accès définis par RLS.
        .eq('seller_id', user.id)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map(
          (row) => SellerNotificationEntity.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      return 0;
    }

    final rows = await supabaseClient
        .from('seller_notifications')
        .select('id')
        .eq('seller_id', user.id)
        .eq('is_read', false);

    return (rows as List).length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to update notifications.');
    }

    await supabaseClient
        .from('seller_notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('seller_id', user.id);
  }

  @override
  Future<void> markAllAsRead() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to update notifications.');
    }

    await supabaseClient
        .from('seller_notifications')
        .update({'is_read': true})
        .eq('seller_id', user.id)
        .eq('is_read', false);
  }
}
