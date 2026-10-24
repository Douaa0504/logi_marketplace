import '../entities/seller_notification_entity.dart';

abstract class NotificationRepository {
  /// Charge les notifications accessibles au vendeur authentifié.
  Future<List<SellerNotificationEntity>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
