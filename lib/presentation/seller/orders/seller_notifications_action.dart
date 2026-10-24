import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/seller_notification_entity.dart';
import '../../../domain/repositories/notification_repository.dart';

class SellerNotificationsAction extends StatefulWidget {
  const SellerNotificationsAction({super.key});

  @override
  State<SellerNotificationsAction> createState() =>
      _SellerNotificationsActionState();
}

class _SellerNotificationsActionState extends State<SellerNotificationsAction> {
  late Future<int> _unreadCount;

  @override
  void initState() {
    super.initState();
    _unreadCount = context.read<NotificationRepository>().getUnreadCount();
  }

  Future<void> _openNotifications() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SellerNotificationsSheet(),
    );
    if (!mounted) return;
    // Actualise le badge à la fermeture, après les éventuels marquages comme lus.
    setState(() {
      _unreadCount = context.read<NotificationRepository>().getUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<int>(
      future: _unreadCount,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return IconButton(
          tooltip: snapshot.hasError
              ? 'Could not load notification count'
              : 'Notifications',
          onPressed: _openNotifications,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                snapshot.hasError
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_outlined,
                color: snapshot.hasError ? colors.error : null,
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SellerNotificationsSheet extends StatefulWidget {
  const _SellerNotificationsSheet();

  @override
  State<_SellerNotificationsSheet> createState() =>
      _SellerNotificationsSheetState();
}

class _SellerNotificationsSheetState extends State<_SellerNotificationsSheet> {
  List<SellerNotificationEntity> _notifications = const [];
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notifications = await context
          .read<NotificationRepository>()
          .getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
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

  Future<void> _markRead(SellerNotificationEntity notification) async {
    setState(() => _isUpdating = true);
    try {
      await context
          .read<NotificationRepository>()
          .markAsRead(notification.id);
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update notification: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _markAllRead() async {
    setState(() => _isUpdating = true);
    try {
      await context.read<NotificationRepository>().markAllAsRead();
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update notifications: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasUnread = _notifications.any((notification) => !notification.isRead);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isUpdating || !hasUnread ? null : _markAllRead,
                    child: const Text('Mark all read'),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              color: colors.error,
                              size: 38,
                            ),
                            const SizedBox(height: 12),
                            const Text('Notifications could not be loaded.'),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _loadNotifications,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _notifications.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Icon(Icons.notifications_none_outlined, size: 48),
                          SizedBox(height: 12),
                          Center(child: Text('No notifications yet.')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            elevation: 0,
                            color: notification.isRead
                                ? colors.surface
                                : colors.secondaryContainer.withValues(
                                    alpha: 0.45,
                                  ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: colors.outlineVariant),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _notificationIcon(notification.type),
                                color: colors.primary,
                              ),
                              title: Text(
                                _notificationTitle(notification.type),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  notification.message,
                                  if (notification.productTitle != null)
                                    notification.productTitle!,
                                  notification.createdAt
                                      .toLocal()
                                      .toString()
                                      .split('.')
                                      .first,
                                ].join('\n'),
                              ),
                              isThreeLine: true,
                              trailing: Icon(
                                notification.isRead
                                    ? Icons.check_circle_outline
                                    : Icons.circle,
                                color: notification.isRead
                                    ? colors.onSurfaceVariant
                                    : colors.primary,
                                size: notification.isRead ? 20 : 12,
                              ),
                              onTap: notification.isRead || _isUpdating
                                  ? null
                                  : () => _markRead(notification),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            if (_isUpdating) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  IconData _notificationIcon(String type) => switch (type) {
    'favorite' => Icons.favorite_border,
    'review' => Icons.rate_review_outlined,
    'order' => Icons.receipt_long_outlined,
    _ => Icons.notifications_outlined,
  };

  String _notificationTitle(String type) => switch (type) {
    'favorite' => 'New favorite',
    'review' => 'New review',
    'order' => 'New order',
    _ => 'Shop notification',
  };
}
