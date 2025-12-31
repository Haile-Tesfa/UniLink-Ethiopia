import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  String? _attachedFileName;   // e.g. local_file_example.png
  String? _attachedFileType;   // 'image' or 'video'

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content or attach a file')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: later use real logged-in user id from auth
      const int userId = 3;

      final uri = Uri.parse('http://localhost:5000/api/posts');

      final body = {
        'userId': userId,
        'content': _contentController.text.trim(),
        'mediaUrl': _attachedFileName,   // fake local path for now
        'mediaType': _attachedFileType,  // 'image' or 'video'
        'privacy': _selectedPrivacy,
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create post (${response.statusCode}): ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Single button: later replace with real file picker
  void _onUploadFile() {
    setState(() {
      _attachedFileName = 'local_file_example.png';
      _attachedFileType = 'image'; // or 'video'
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File selected (demo only)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
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
                    backgroundImage:
                        AssetImage('assets/images/profile/prof_1.jpg'),
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
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attachment (optional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _onUploadFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload file'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_attachedFileName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Selected: $_attachedFileName',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
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
