import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'user_search_screen.dart'; 
import '../../models/chat_message_model.dart';
// make sure this file exists

class ChatScreen extends StatefulWidget {
  final int currentUserId;

  const ChatScreen({super.key, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// Simple conversation model (one row per chat in the list)
class ChatSummary {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl; // null if no image
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isGroup;

  ChatSummary({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.isGroup = false,
  });

  factory ChatSummary.fromJson(
      Map<String, dynamic> json, int currentUserId) {
    final int user1 = json['user1Id'] as int;
    final int user2 = json['user2Id'] as int;
    final bool iAmUser1 = user1 == currentUserId;

    final int otherId = iAmUser1 ? user2 : user1;

    return ChatSummary(
      otherUserId: otherId,
      otherUserName: json['otherUserName'] as String,
      otherUserAvatarUrl:
          json['otherUserAvatarUrl'] as String?, // can be null
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime:
          DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isGroup: json['isGroup'] as bool? ?? false,
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  // Using centralized API URL from constants
  bool _isLoading = false;
  List<ChatSummary> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
          '${AppConstants.apiBaseUrl}/api/chat/conversations?userId=${widget.currentUserId}');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['conversations'] as List<dynamic>? ?? [];

        setState(() {
          _chats = list
              .map((e) => ChatSummary.fromJson(
                  e as Map<String, dynamic>, widget.currentUserId))
              .toList()
            ..sort(
              (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
            );
        });
      } else {
        debugPrint(
            'Failed to load chats: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Error loading chats: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openChat(ChatSummary chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          currentUserId: widget.currentUserId,
          otherUserId: chat.otherUserId,
          userName: chat.otherUserName,
          userImage: chat.otherUserAvatarUrl ?? '',
          isGroup: chat.isGroup,
        ),
      ),
    ).then((_) {
      _loadChats();
    });
  }

  // >>> ADD THIS: open user search screen
  void _openUserSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UserSearchScreen(currentUserId: widget.currentUserId),
      ),
    ).then((_) => _loadChats());
  }
  // <<<

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openUserSearch, // << use function here
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? const Center(child: Text('No chats yet'))
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    return _ChatItem(
                      name: chat.otherUserName,
                      lastMessage: chat.lastMessage,
                      time: _formatTime(chat.lastMessageTime),
                      unreadCount: chat.unreadCount,
                      imageUrl: chat.otherUserAvatarUrl,
                      isGroup: chat.isGroup,
                      onTap: () => _openChat(chat),
                    );
                  },
                ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}

class _ChatItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? imageUrl; // null = no image
  final bool isGroup;
  final VoidCallback onTap;

  const _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.imageUrl,
    this.isGroup = false,
    required this.onTap,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.isNotEmpty
          ? parts.first[0].toUpperCase()
          : '?';
    }
    return (parts[0].isNotEmpty ? parts[0][0] : '') +
        (parts[1].isNotEmpty ? parts[1][0] : '');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!) as ImageProvider
                : null,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? Text(
                    _initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          if (isGroup)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
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
      title: Text(
        name,
        style: TextStyle(
          fontWeight:
              unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unreadCount > 0 ? AppColors.primary : Colors.grey,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (unreadCount > 0)
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
    );
  }
}
// -------------------- ChatDetailScreen --------------------

class ChatDetailScreen extends StatefulWidget {
  final int currentUserId;
  final int otherUserId;
  final String userName;
  final String userImage;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.userName,
    required this.userImage,
    this.isGroup = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // Using centralized API URL from constants
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}/api/chat/messages'
        '?user1=${widget.currentUserId}&user2=${widget.otherUserId}',
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (data['messages'] as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          _messages
            ..clear()
            ..addAll(list);
        });
      } else {
        debugPrint(
          'Failed to load messages: ${res.statusCode} ${res.body}',
        );
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final temp = ChatMessage(
      messageId: 0,
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(temp);
      _messageController.clear();
    });

    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/chat/messages');
      final body = jsonEncode({
        'senderId': widget.currentUserId,
        'receiverId': widget.otherUserId,
        'content': text,
      });

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await _loadMessages();
      } else {
        debugPrint(
          'Failed to send message: ${res.statusCode} ${res.body}',
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.userImage.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.userImage),
              )
            else
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName),
                Text(
                  widget.isGroup ? 'Group chat' : 'Last seen recently',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.video_call),
          SizedBox(width: 8),
          Icon(Icons.phone),
          SizedBox(width: 8),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe =
                          message.senderId == widget.currentUserId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      widget.userName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.primary
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          const Radius.circular(16),
                                      topRight:
                                          const Radius.circular(16),
                                      bottomLeft: isMe
                                          ? const Radius.circular(16)
                                          : const Radius.circular(4),
                                      bottomRight: isMe
                                          ? const Radius.circular(4)
                                          : const Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${message.timestamp.hour.toString().padLeft(2, '0')}:'
                                    '${message.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.primary),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: AppColors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
