import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../settings_screen.dart';
import './post_details.dart';

class HomeFeed extends StatelessWidget {
  final int userId;
  final String fullName;
  final String email;

  const HomeFeed({
    super.key,
    required this.userId,
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> posts = [
      {
        'image': 'assets/images/home/post_0.jpg',
        'title': 'Architecture Networking Night',
        'description':
            'Meet faculty, alumni, and peers to discuss design careers and internships in the Architecture Department.',
      },
      {
        'image': 'assets/images/home/post_1.jpg',
        'title': 'Final Year Design Review',
        'description': '.',
      },
      {
        'image': 'assets/images/home/post_2.jpg',
        'title': 'Sustainable Design Workshop',
        'description':
            'Hands-on workGraduation exhibition featuring final-year studio projects, juried by invited architects and staffshop on green building materials and climate-responsive design strategies.',
      },
      {
        'image': 'assets/images/home/post_3.jpg',
        'title': 'Guest Lecture: Urban Futures',
        'description':
            'Graduation exhibition featuring final-year studio projects, juried by invited architects and staff.',
      },
      {
        'image': 'assets/images/home/post_4.jpg',
        'title': 'Model Making Lab Tour',
        'description':
            'Guided tour of the architecture model lab and digital fabrication tools for new students.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("UniLink Feed"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              currentAccountPicture: const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/profile/save1.jpg'),
              ),
              accountName: Text(fullName),
              accountEmail: Text(email),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      userId: userId,
                      fullName: fullName,
                      email: email,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, i) {
          final post = posts[i];

          return Card(
            margin: const EdgeInsets.all(12),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/profile/save1.jpg'),
                  ),
                  title: Text(
                    "Group four",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Just now • Bahir Dar"),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetails(
                        imagePath: post['image']!,
                        title: post['title']!,
                        description: post['description']!,
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: post['image']!,
                    child: Image.asset(
                      post['image']!,
                      fit: BoxFit.cover,
                      height: 220,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Click the image to see more details about this update! #BDU #UniLink",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 1) Navigator.pushNamed(context, '/marketplace');
        if (index == 2) Navigator.pushNamed(context, '/chat');
        if (index == 3) Navigator.pushNamed(context, '/events');
        if (index == 4) Navigator.pushNamed(context, '/profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), label: "Market"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
