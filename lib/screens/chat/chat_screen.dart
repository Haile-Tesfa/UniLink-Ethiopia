import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../utils/colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _ChatItem(
            name: 'Meklit Desalegn',
            lastMessage: 'Hey, are we meeting today?',
            time: '10:30 AM',
            unreadCount: 2,
            image: 'assets/images/profile/prof_1.jpg',
            onTap: () {
              _openChat(
                context,
                'Meklit Desalegn',
                'assets/images/profile/prof_1.jpg',
              );
            },
          ),
          _ChatItem(
            name: 'Abebe Kebede',
            lastMessage: 'Thanks for the notes!',
            time: 'Yesterday',
            unreadCount: 0,
            image: 'assets/images/profile/prof_2.jpg',
            onTap: () {
              _openChat(
                context,
                'Abebe Kebede',
                'assets/images/profile/prof_2.jpg',
              );
            },
          ),
          _ChatItem(
            name: 'Sara Tesfaye',
            lastMessage: 'See you at the study group',
            time: '2 days ago',
            unreadCount: 1,
            image: 'assets/images/profile/prof_3.jpg',
            onTap: () {
              _openChat(
                context,
                'Sara Tesfaye',
                'assets/images/profile/prof_3.jpg',
              );
            },
          ),
          _ChatItem(
            name: 'Study Group',
            lastMessage: 'John: Meeting moved to 3 PM',
            time: '3 days ago',
            unreadCount: 5,
            image: 'assets/images/profile/prof_1.jpg',
            isGroup: true,
            onTap: () {
              _openChat(
                context,
                'Study Group',
                'assets/images/profile/prof_1.jpg',
                isGroup: true,
              );
            },
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, String userName, String userImage, {bool isGroup = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          userName: userName,
          userImage: userImage,
          isGroup: isGroup,
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String image;
  final bool isGroup;
  final VoidCallback onTap;

  const _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.image,
    this.isGroup = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(image),
            child: isGroup
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : null,
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
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
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

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.userImage,
    this.isGroup = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> get _messages => [
    Message(
      id: '1',
      senderId: '1',
      senderName: 'You',
      content: 'Hey, are we meeting today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: true,
    ),
    Message(
      id: '2',
      senderId: '2',
      senderName: widget.userName,
      content: 'Yes, at 3 PM in the library',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: true,
    ),
    Message(
      id: '3',
      senderId: '1',
      senderName: 'You',
      content: 'Perfect! I\'ll bring the notes',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      isRead: true,
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: '1',
      senderName: 'You',
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.userImage),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName),
                Text(
                  widget.isGroup ? '12 members' : 'Online',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == '1';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                message.senderName,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
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