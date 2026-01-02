// lib/screens/notifications/notifications_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/notification_model.dart';
import '../../utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  final int currentUserId;

  const NotificationsScreen({super.key, required this.currentUserId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _baseUrl = 'http://localhost:5000';

  bool _isLoading = false;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        '$_baseUrl/api/notifications?userId=${widget.currentUserId}',
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['notifications'] as List<dynamic>? ?? [];

        setState(() {
          _notifications = list
              .map((e) => NotificationModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
            ..sort(
              (a, b) => b.timestamp.compareTo(a.timestamp),
            );
        });
      } else {
        debugPrint(
          'Failed to load notifications: ${res.statusCode} ${res.body}',
        );
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    // optimistic UI update
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/notifications/mark-all-read');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': widget.currentUserId}),
      );
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _notifications.clear();
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/notifications/clear-all');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': widget.currentUserId}),
      );
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => !n.isRead).length;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No notifications',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey),
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
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$unreadCount Unread',
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
                      child: RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification =
                                _notifications[index];
                            return _NotificationItem(
                              notification: notification,
                              onTap: () {
                                // mark single as read in UI
                                setState(() {
                                  _notifications[index] =
                                      notification.copyWith(
                                          isRead: true);
                                });
                                // TODO: optionally send POST /notifications/mark-read
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        leading: notification.senderImage != null &&
                notification.senderImage!.isNotEmpty
            ? CircleAvatar(
                backgroundImage:
                    NetworkImage(notification.senderImage!),
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
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(notification.timestamp),
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey),
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
        onTap: onTap,
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
