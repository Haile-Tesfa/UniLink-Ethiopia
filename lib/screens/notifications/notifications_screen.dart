import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      type: 'like',
      title: 'Meklit Desalegn',
      body: 'liked your post',
      senderId: '1',
      senderName: 'Meklit Desalegn',
      senderImage: 'assets/images/profile/prof_1.jpg',
      postId: '1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      type: 'comment',
      title: 'Abebe Kebede',
      body: 'commented on your post: "Great work!"',
      senderId: '2',
      senderName: 'Abebe Kebede',
      senderImage: 'assets/images/profile/prof_2.jpg',
      postId: '1',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      type: 'follow',
      title: 'Sara Tesfaye',
      body: 'started following you',
      senderId: '3',
      senderName: 'Sara Tesfaye',
      senderImage: 'assets/images/profile/prof_3.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      type: 'marketplace',
      title: 'Marketplace',
      body: 'Your item "Textbooks Bundle" has a new offer',
      itemId: '2',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification = NotificationModel(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          senderId: notification.senderId,
          senderName: notification.senderName,
          senderImage: notification.senderImage,
          postId: notification.postId,
          itemId: notification.itemId,
          timestamp: notification.timestamp,
          isRead: true,
        );
      }
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all as read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'When you get notifications, they\'ll appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_notifications.where((n) => !n.isRead).length} Unread',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _NotificationItem(notification: notification);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        leading: notification.senderImage != null
            ? CircleAvatar(
                backgroundImage: AssetImage(notification.senderImage!),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                ),
              ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(notification.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}