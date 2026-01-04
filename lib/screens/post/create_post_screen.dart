import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/colors.dart';
import '../../utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  final int? userId;
  
  const CreatePostScreen({super.key, this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedPrivacy = 'Public';
  final List<String> _privacyOptions = ['Public', 'Friends', 'Only Me'];
  bool _isLoading = false;

  String? _attachedFileName;
  String? _attachedFileType; // 'image' or 'video'
  String? _uploadedMediaUrl; // URL from backend

  // Using centralized API URL from constants

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        // on web we need bytes, on desktop path is enough but this is safe
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final ext = file.extension?.toLowerCase();
      final isVideo = ext == 'mp4';

      setState(() {
        _attachedFileName = file.name;
        _attachedFileType = isVideo ? 'video' : 'image';
        _uploadedMediaUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading ${file.name} ...')),
      );

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/uploads/post-media');
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        // WEB: use bytes only, path is always null
        final Uint8List? bytes = file.bytes;
        if (bytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot read file bytes')),
          );
          return;
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'media',
            bytes,
            filename: file.name,
          ),
        );
      } else {
        // DESKTOP / MOBILE: use OS file path
        final path = file.path;
        if (path == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File path is null')),
          );
          return;
        }

        request.files.add(
          await http.MultipartFile.fromPath('media', path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        String? fileUrl = data['fileUrl'] as String?;
        // Ensure full URL if relative path
        if (fileUrl != null && fileUrl.isNotEmpty) {
          if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
            // If it starts with /, prepend base URL, otherwise add / before it
            if (fileUrl.startsWith('/')) {
              fileUrl = '${AppConstants.apiBaseUrl}$fileUrl';
            } else {
              fileUrl = '${AppConstants.apiBaseUrl}/$fileUrl';
            }
          }
        }
        setState(() {
          _uploadedMediaUrl = fileUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload success: ${file.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed (${response.statusCode}): ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty &&
        _uploadedMediaUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or attach a file'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get userId from widget or use a default (you should pass this from context)
      final int userId = widget.userId ?? 1;
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/posts');

      final body = {
        'userId': userId,
        'content': _contentController.text.trim(),
        'mediaUrl': _uploadedMediaUrl,
        'mediaType': _attachedFileType,
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
      if (mounted) _isLoading = false;
      setState(() {});
    }
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attachment (optional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadFile,
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
                        if (_uploadedMediaUrl == null)
                          const Text(
                            'Uploading...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          )
                        else
                          const Text(
                            'Uploaded ✓',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
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
