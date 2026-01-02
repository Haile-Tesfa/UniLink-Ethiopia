import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/post_model.dart';
import '../../widgets/post_widget.dart';
import '../../widgets/enhanced_bottom_navbar.dart';
import '../../widgets/custom_floating_action_button.dart';
import '../../widgets/story_circle.dart';
import '../../utils/colors.dart';
import '../chat/chat_screen.dart';

class HomeFeed extends StatefulWidget {
  final int currentUserId;

  const HomeFeed({super.key, required this.currentUserId});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  // IMPORTANT: if you test Flutter web on another device, change this to your PC IP.
  static const String _baseUrl = 'http://127.0.0.1:5000';

  int _currentIndex = 0;
  bool _isLoading = false;
  final List<Post> _posts = [];
  final List<Post> _savedPosts = [];

  final List<Map<String, dynamic>> _baseStories = [
    {
      'id': 'me',
      'name': 'Your Story',
      'image': 'assets/images/profile/prof_1.jpg',
      'isMe': true,
      'hasNew': false,
    },
    {
      'id': '2',
      'name': 'Meklit',
      'image': 'assets/images/profile/prof_1.jpg',
      'isMe': false,
      'hasNew': true,
    },
    {
      'id': '3',
      'name': 'Abebe',
      'image': 'assets/images/profile/prof_2.jpg',
      'isMe': false,
      'hasNew': true,
    },
    {
      'id': '4',
      'name': 'Sara',
      'image': 'assets/images/profile/prof_3.jpg',
      'isMe': false,
      'hasNew': false,
    },
    {
      'id': '5',
      'name': 'John',
      'image': 'assets/images/profile/prof_1.jpg',
      'isMe': false,
      'hasNew': true,
    },
  ];

  List<Map<String, dynamic>> get _stories {
    final List<Map<String, dynamic>> stories =
        _baseStories.map((e) => Map<String, dynamic>.from(e)).toList();

    for (final post in _posts) {
      if (post.imageUrl == null || post.imageUrl!.isEmpty) continue;

      stories.add({
        'id': post.id,
        'name': post.userName,
        'image': post.imageUrl!,
        'isMe': false,
        'hasNew': true,
      });

      if (stories.length >= 20) break;
    }

    return stories;
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/posts');
      debugPrint('GET $uri');
      final response = await http.get(uri);

      debugPrint('Posts status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> list = data['posts'] as List<dynamic>;

        final loadedPosts = list.map((raw) {
          final row = raw as Map<String, dynamic>;

          String? mediaUrl = row['MediaUrl'] as String?;
          if (mediaUrl != null && mediaUrl.isNotEmpty) {
            mediaUrl = '$_baseUrl$mediaUrl';
          }

          return Post(
            id: row['PostId'].toString(),
            userId: row['UserId'].toString(),
            userName: 'User ${row['UserId']}',
            userAvatar: 'assets/images/profile/prof_1.jpg',
            content: (row['Content'] ?? '') as String,
            imageUrl: mediaUrl,
            likeCount: 0,
            commentCount: 0,
            createdAt: DateTime.parse(row['CreatedAt'].toString()),
            isLiked: false,
            isSaved: false,
          );
        }).toList();

        debugPrint('Loaded ${loadedPosts.length} posts');

        setState(() {
          _posts
            ..clear()
            ..addAll(loadedPosts);
        });
      } else {
        debugPrint(
          'Failed to load posts: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  void _toggleLike(String postId) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          content: post.content,
          imageUrl: post.imageUrl,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          isLiked: !post.isLiked,
          isSaved: post.isSaved,
        );
      }
    });
  }

  void _toggleSave(String postId) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final isNowSaved = !post.isSaved;

        _posts[index] = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          content: post.content,
          imageUrl: post.imageUrl,
          likeCount: post.likeCount,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          isLiked: post.isLiked,
          isSaved: isNowSaved,
        );

        if (isNowSaved) {
          _savedPosts.add(_posts[index]);
        } else {
          _savedPosts.removeWhere((p) => p.id == postId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/auth/logo.jpg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UniLink',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Home Feed',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-post').then((value) {
            if (value == true) {
              _refreshPosts();
            }
          });
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildStoriesSection(),
            ),
            _isLoading && _posts.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = _posts[index];
                        return PostWidget(
                          post: post,
                          onLike: () => _toggleLike(post.id),
                          onComment: () => _openComments(post),
                          onSave: () => _toggleSave(post.id),
                          onShare: () => _sharePost(post),
                        );
                      },
                      childCount: _posts.length,
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: EnhancedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/marketplace');
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatScreen(currentUserId: widget.currentUserId),
              ),
            );
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        showFloatingActionButton: true,
        onFloatingActionPressed: () {
          Navigator.pushNamed(context, '/create-post');
        },
      ),
    );
  }

  Widget _buildStoriesSection() {
    final stories = _stories;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final bool isMe = story['isMe'] as bool;

          return StoryCircle(
            name: story['name'] as String,
            imagePath: story['image'] as String,
            isMe: isMe,
            hasNew: story['hasNew'] as bool,
            onTap: () {
              if (isMe) {
                Navigator.pushNamed(context, '/create-post').then((value) {
                  if (value == true) {
                    _refreshPosts();
                  }
                });
              } else {
                // open story viewer later
              }
            },
          );
        },
      ),
    );
  }

  void _openComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final TextEditingController commentCtrl = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comments for ${post.userName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    final text = commentCtrl.text.trim();
                    if (text.isEmpty) return;

                    try {
                      final uri = Uri.parse('$_baseUrl/api/comments');
                      final body = jsonEncode({
                        'postId': int.parse(post.id),
                        'authorId': widget.currentUserId,
                        'postOwnerId': int.parse(post.userId),
                        'commentText': text,
                      });

                      final response = await http.post(
                        uri,
                        headers: {'Content-Type': 'application/json'},
                        body: body,
                      );

                      Navigator.pop(sheetContext);

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment saved.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to save comment: ${response.statusCode}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error sending comment: $e'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareImageUrl(Post post) async {
    final url = post.imageUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image to share')),
      );
      return;
    }

    await Share.share(
      url,
      subject: 'Check this post from UniLink',
    );
  }

  Future<void> _shareTextMessage(Post post) async {
    final url = post.imageUrl ?? '';
    final text = 'Check this post from UniLink\n$url';
    await Share.share(
      text,
      subject: 'UniLink Post',
    );
  }

  Future<void> _copyImageUrl(Post post) async {
    final url = post.imageUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No link to copy')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  Future<void> _saveImageToGallery(Post post) async {
    final url = post.imageUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image to save')),
      );
      return;
    }

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving to gallery is only supported on mobile build'),
        ),
      );
      return;
    }

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }
    }

    // implement real gallery save on mobile if you add a plugin
  }

  void _sharePost(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share to Feed'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareImageUrl(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send in Message'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareTextMessage(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Link'),
                onTap: () async {
                  Navigator.pop(context);
                  await _copyImageUrl(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Save Post'),
                onTap: () async {
                  Navigator.pop(context);
                  _toggleSave(post.id);
                  await _saveImageToGallery(post);
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
