import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import './post_details.dart'; // Ensure this import exists

class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    // Your specific image assets as requested
    final List<String> posts = [
      'assets/images/home/post_0.jpg',
      'assets/images/home/post_1.jpg',
      'assets/images/home/post_2.jpg',
      'assets/images/home/post_3.jpg',
      'assets/images/home/post_4.jpg',
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
      // Sidebar Drawer as per wireframe
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile/prof_1.jpg'),
              ),
              accountName: Text("Meklit Desalegn"),
              accountEmail: Text("meklit.d@aau.edu.et"),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {}, // Handled in Drawer now
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile/prof_1.jpg'),
                ),
                title: Text("Meklit Desalegn", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Just now • Addis Ababa"),
              ),
              
              // THE CLICKABLE IMAGE LOGIC
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetails(imagePath: posts[i]),
                  ),
                ),
                child: Hero(
                  tag: posts[i], // Smooth animation transition
                  child: Image.asset(
                    posts[i],
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
                    const Text(
                      "Campus Networking Event",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Click the image to see more details about this update! #AAU #UniLink",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Market"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}