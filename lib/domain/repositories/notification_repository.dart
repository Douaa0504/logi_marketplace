import '../entities/seller_notification_entity.dart';

abstract class NotificationRepository {
  Future<List<SellerNotificationEntity>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
