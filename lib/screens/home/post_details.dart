import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/colors.dart';

class PostDetails extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const PostDetails({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final postText = "$title: $description";

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: imagePath,
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Posted by Group four",
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 30),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Share.share(postText);
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      "Share Update",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
