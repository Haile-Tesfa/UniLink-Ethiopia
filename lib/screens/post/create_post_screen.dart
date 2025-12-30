import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedPrivacy = 'Public';
  final List<String> _privacyOptions = ['Public', 'Friends', 'Only Me'];
  bool _isLoading = false;

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context, {
      'content': _contentController.text,
      'privacy': _selectedPrivacy,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _createPost,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/profile/prof_1.jpg'),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meklit Desalegn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedPrivacy,
                        items: _privacyOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Row(
                              children: [
                                Icon(
                                  option == 'Public' 
                                    ? Icons.public 
                                    : option == 'Friends' 
                                      ? Icons.people 
                                      : Icons.lock,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(option),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPrivacy = value!;
                          });
                        },
                        underline: Container(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Add to your post',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ActionButton(
                            icon: Icons.photo,
                            label: 'Photo',
                            color: Colors.green,
                            onTap: () {},
                          ),
                          _ActionButton(
                            icon: Icons.video_camera_back,
                            label: 'Video',
                            color: Colors.purple,
                            onTap: () {},
                          ),
                          _ActionButton(
                            icon: Icons.location_on,
                            label: 'Location',
                            color: Colors.red,
                            onTap: () {},
                          ),
                          _ActionButton(
                            icon: Icons.tag,
                            label: 'Tag',
                            color: Colors.blue,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}