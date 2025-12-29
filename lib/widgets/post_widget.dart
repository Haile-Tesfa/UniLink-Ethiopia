import 'package:flutter/material.dart';
import '../utils/colors.dart';

class PostWidget extends StatefulWidget {
  final String user, time, content, postImage, userImage;
  
  const PostWidget({
    super.key, 
    required this.user, 
    required this.time, 
    required this.content, 
    required this.postImage,
    required this.userImage
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  bool isSaved = false;
  int likeCount = 14; // Mock data

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User Info
          ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(widget.userImage)),
            title: Text(widget.user, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.time, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, 
                   color: isSaved ? AppColors.secondary : Colors.grey),
              onPressed: () => setState(() => isSaved = !isSaved),
            ),
          ),

          // Content Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ),

          // Post Image
          ClipRRect(
            child: Image.asset(widget.postImage, fit: BoxFit.cover, width: double.infinity, height: 220),
          ),

          // Interaction Bar: Like, Comment, Share
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, 
                           color: isLiked ? Colors.red : Colors.grey),
                      onPressed: () => setState(() {
                        isLiked = !isLiked;
                        isLiked ? likeCount++ : likeCount--;
                      }),
                    ),
                    Text("$likeCount likes"),
                  ],
                ),
                _iconLabel(Icons.mode_comment_outlined, "Comment"),
                _iconLabel(Icons.share_outlined, "Share"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}