import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../utils/colors.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const PostWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(post.userAvatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _formatTime(post.createdAt),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.public, size: 12, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showPostOptions(context);
                  },
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  post.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, size: 12, color: Colors.red),
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}'),
                  ],
                ),
                Text('${post.commentCount} comments'),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _PostActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: 'Like',
                    isActive: post.isLiked,
                    onTap: onLike,
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: Icons.comment,
                    label: 'Comment',
                    onTap: onComment,
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: onShare,
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    label: 'Save',
                    isActive: post.isSaved,
                    onTap: onSave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('Save Post'),
                onTap: () {
                  Navigator.pop(context);
                  onSave();
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report Post'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? AppColors.primary : Colors.grey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}