import 'package:flutter/material.dart';
import 'package:unilink_ethiopia/widgets/marketplace_item_card.dart';
import '../../models/post_model.dart';
import '../../widgets/post_widget.dart';
import '../../widgets/enhanced_bottom_navbar.dart';
import '../../widgets/custom_floating_action_button.dart';
import '../../widgets/story_circle.dart';
import '../../widgets/app_logo.dart';
import '../search/search_screen.dart';
import '../post/create_post_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../utils/colors.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int _currentIndex = 0;
  bool _isLoading = false;
  final List<Post> _posts = [];
  final List<Post> _savedPosts = [];
  
  final List<Map<String, dynamic>> _stories = [
    {
      'id': '1',
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

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _posts.clear();
      _posts.addAll([
        Post(
          id: '1',
          userId: '1',
          userName: 'Meklit Desalegn',
          userAvatar: 'assets/images/profile/prof_1.jpg',
          content: 'Just completed my final architecture project! The design focuses on sustainable living spaces for urban areas. So proud of this achievement after months of hard work. 🎓✨',
          imageUrl: 'assets/images/home/post_0.jpg',
          likeCount: 245,
          commentCount: 38,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isLiked: true,
          isSaved: false,
        ),
        Post(
          id: '2',
          userId: '2',
          userName: 'Abebe Kebede',
          userAvatar: 'assets/images/profile/prof_2.jpg',
          content: 'Finally finished my final exams! 🎉 Time to relax and work on personal projects. Looking forward to the break and catching up on some reading.',
          imageUrl: 'assets/images/home/post_1.jpg',
          likeCount: 156,
          commentCount: 42,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isLiked: false,
          isSaved: true,
        ),
        Post(
          id: '3',
          userId: '3',
          userName: 'Sara Tesfaye',
          userAvatar: 'assets/images/profile/prof_3.jpg',
          content: 'Looking for study partners for Data Structures exam next week. If anyone wants to join our study group, DM me! We\'re meeting at the library every evening.',
          imageUrl: null,
          likeCount: 78,
          commentCount: 25,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isLiked: true,
          isSaved: false,
        ),
        Post(
          id: '4',
          userId: '4',
          userName: 'John Doe',
          userAvatar: 'assets/images/profile/prof_1.jpg',
          content: 'University hackathon registration is open! 🚀 Teams of 3-4, prizes up to 50,000 ETB. DM if you\'re looking for team members. #Tech #Innovation',
          imageUrl: null,
          likeCount: 189,
          commentCount: 56,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isLiked: false,
          isSaved: true,
        ),
      ]);
      _isLoading = false;
    });
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

  Future<void> _refreshPosts() async {
    await _loadPosts();
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
            if (value != null) {
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
            // Stories Section
            SliverToBoxAdapter(
              child: _buildStoriesSection(),
            ),
            
            // Posts Section
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
                          onComment: () {
                            // Handle comment
                          },
                          onSave: () => _toggleSave(post.id),
                          onShare: () {
                            _sharePost(post);
                          },
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
            Navigator.pushNamed(context, '/chat');
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
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return StoryCircle(
            name: story['name'],
            imagePath: story['image'],
            isMe: story['isMe'],
            hasNew: story['hasNew'],
            onTap: () {
              // Handle story tap
            },
          );
        },
      ),
    );
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
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send in Message'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Save Post'),
                onTap: () {
                  _toggleSave(post.id);
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