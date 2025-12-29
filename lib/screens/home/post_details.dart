import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class PostDetails extends StatelessWidget {
  final String imagePath;
  const PostDetails({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: imagePath,
              child: Image.asset(imagePath, width: double.infinity, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Architecture Dept. Update",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Posted by Meklit Desalegn",
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 30),
                  const Text(
                    "This is a detailed view of the post. In your app, this is where students can read the full description of campus events, announcements, or networking opportunities.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text("Share Update", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}