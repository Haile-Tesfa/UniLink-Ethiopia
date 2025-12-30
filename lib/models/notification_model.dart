import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String type; // 'like', 'comment', 'follow', 'message', 'marketplace'
  final String title;
  final String body;
  final String? senderId;
  final String? senderName;
  final String? senderImage;
  final String? postId;
  final String? itemId;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.postId,
    this.itemId,
    required this.timestamp,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'message':
        return Icons.message;
      case 'marketplace':
        return Icons.shopping_bag;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'message':
        return Colors.purple;
      case 'marketplace':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}