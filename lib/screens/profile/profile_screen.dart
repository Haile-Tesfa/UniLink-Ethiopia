import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../widgets/post_widget.dart';
import '../../widgets/profile_header.dart';
import '../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Posts', 'Saved', 'About'];

  final Map<String, dynamic> _user = {
    'id': '1',
    'name': 'Meklit Desalegn',
    'email': 'meklit.d@student.edu.et',
    'studentId': 'UGR/1234/14',
    'department': 'Architecture',
    'university': 'Addis Ababa University',
    'profileImage': 'assets/images/profile/prof_1.jpg',
    'coverImage': 'assets/images/home/post_0.jpg',
    'yearOfStudy': 4,
    'bio':
        'Architecture student passionate about sustainable design and urban planning. Love photography and community projects.',
    'phone': '+251 912 345 678',
    'location': 'Addis Ababa, Ethiopia',
    'joinedDate': 'September 2022',
    'friends': 245,
    'posts': 48,
    'followers': 189,
    'following': 156,
  };

  final List<Post> _userPosts = [];
  final List<Post> _savedPosts = [];
  bool _isLoading = false;
  bool _isFollowing = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _userPosts.clear();
      _userPosts.addAll([
        Post(
          id: '1',
          userId: _user['id'],
          userName: _user['name'],
          userAvatar: _user['profileImage'],
          content:
              'Final project submission day! Our sustainable campus design got excellent feedback from the professors.',
          imageUrl: 'assets/images/home/post_0.jpg',
          likeCount: 245,
          commentCount: 38,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isLiked: true,
          isSaved: false,
        ),
        Post(
          id: '2',
          userId: _user['id'],
          userName: _user['name'],
          userAvatar: _user['profileImage'],
          content:
              'Participated in the university architecture exhibition today. Amazing to see so much talent!',
          imageUrl: null,
          likeCount: 123,
          commentCount: 25,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          isLiked: false,
          isSaved: false,
        ),
        Post(
          id: '3',
          userId: _user['id'],
          userName: _user['name'],
          userAvatar: _user['profileImage'],
          content:
              'Working on my thesis: "Sustainable Urban Housing Solutions for Addis Ababa". Any recommendations for resources?',
          imageUrl: null,
          likeCount: 89,
          commentCount: 42,
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          isLiked: true,
          isSaved: false,
        ),
      ]);

      _savedPosts.clear();
      _savedPosts.addAll([
        Post(
          id: '4',
          userId: '2',
          userName: 'Abebe Kebede',
          userAvatar: 'assets/images/profile/prof_2.jpg',
          content:
              'Important study tips for finals season that helped me ace my exams!',
          imageUrl: null,
          likeCount: 289,
          commentCount: 64,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isLiked: true,
          isSaved: true,
        ),
        Post(
          id: '5',
          userId: '3',
          userName: 'Sara Tesfaye',
          userAvatar: 'assets/images/profile/prof_3.jpg',
          content:
              'Free online courses for Computer Science students - curated list',
          imageUrl: null,
          likeCount: 156,
          commentCount: 38,
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
          isLiked: true,
          isSaved: true,
        ),
      ]);

      _isLoading = false;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(String postId) {
    setState(() {
      final index = _userPosts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _userPosts[index];
        _userPosts[index] = Post(
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
      final index = _savedPosts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _savedPosts[index];
        _savedPosts[index] = Post(
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
          isSaved: !post.isSaved,
        );

        if (!_savedPosts[index].isSaved) {
          _savedPosts.removeAt(index);
        }
      }
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _user['followers']++;
      } else {
        _user['followers']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 320,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      _showSettings(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(
                    user: _user,
                    isFollowing: _isFollowing,
                    onFollowToggle: _toggleFollow,
                    onEditProfile: () => _editProfile(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        count: _user['posts'].toString(),
                        label: 'Posts',
                      ),
                      _StatItem(
                        count: _user['followers'].toString(),
                        label: 'Followers',
                      ),
                      _StatItem(
                        count: _user['following'].toString(),
                        label: 'Following',
                      ),
                      _StatItem(
                        count: _user['friends'].toString(),
                        label: 'Friends',
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _userPosts.isEmpty
                      ? const Center(child: Text('No posts yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: _userPosts.length,
                          itemBuilder: (context, index) {
                            final post = _userPosts[index];
                            return PostWidget(
                              post: post,
                              onLike: () => _toggleLike(post.id),
                              onComment: () {},
                              onSave: () {},
                              onShare: () {},
                            );
                          },
                        ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _savedPosts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No saved posts',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: _savedPosts.length,
                          itemBuilder: (context, index) {
                            final post = _savedPosts[index];
                            return PostWidget(
                              post: post,
                              onLike: () {},
                              onComment: () {},
                              onSave: () => _toggleSave(post.id),
                              onShare: () {},
                            );
                          },
                        ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bio',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _user['bio'],
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Education',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _InfoRow(
                              icon: Icons.school,
                              label: 'University',
                              value: _user['university'],
                            ),
                            _InfoRow(
                              icon: Icons.book,
                              label: 'Department',
                              value: _user['department'],
                            ),
                            _InfoRow(
                              icon: Icons.confirmation_number,
                              label: 'Year of Study',
                              value: 'Year ${_user['yearOfStudy']}',
                            ),
                            _InfoRow(
                              icon: Icons.badge,
                              label: 'Student ID',
                              value: _user['studentId'],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: _user['email'],
                            ),
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: _user['phone'],
                            ),
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: _user['location'],
                            ),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Joined UniLink',
                              value: _user['joinedDate'],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Skills & Interests',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const [
                                _ChipItem(label: 'Architecture'),
                                _ChipItem(label: 'Sustainable Design'),
                                _ChipItem(label: 'Urban Planning'),
                                _ChipItem(label: 'Photography'),
                                _ChipItem(label: '3D Modeling'),
                                _ChipItem(label: 'Community Projects'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage:
                                        AssetImage(_user['profileImage']),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              initialValue: _user['name'],
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              initialValue: _user['bio'],
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Bio',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              initialValue: _user['department'],
                              decoration: const InputDecoration(
                                labelText: 'Department',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              initialValue:
                                  _user['yearOfStudy'].toString(),
                              decoration: const InputDecoration(
                                labelText: 'Year of Study',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              initialValue: _user['phone'],
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              initialValue: _user['location'],
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // FIXED BUTTON: constrained width, no infinite constraint
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Profile updated successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize:
                                      const Size.fromHeight(50),
                                ),
                                child: const Text('Save Changes'),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppColors.primary,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy Settings'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About UniLink'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Report a Problem'),
                onTap: () {},
              ),
              const Divider(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  final String label;

  const _ChipItem({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
