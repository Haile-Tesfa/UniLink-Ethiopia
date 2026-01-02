// lib/models/chat_message_model.dart

class ChatMessage {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['MessageId'] as int? ?? json['messageId'] as int,
      senderId: json['SenderId'] as int? ?? json['senderId'] as int,
      receiverId:
          json['ReceiverId'] as int? ?? json['receiverId'] as int,
      content: json['Content'] as String? ?? json['content'] as String,
      timestamp: DateTime.parse(
        (json['Timestamp'] as String? ?? json['timestamp'] as String),
      ),
      isRead: json['IsRead'] as bool? ?? json['isRead'] as bool? ?? false,
    );
  }
}

class UserSearchResult {
  final int userId;
  final String fullName;
  final String email;
  final String? profileImageUrl;

  UserSearchResult({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['UserId'] as int,
      fullName: json['FullName'] as String,
      email: json['UniversityEmail'] as String,
      profileImageUrl: json['ProfileImageUrl'] as String?,
    );
  }
}
