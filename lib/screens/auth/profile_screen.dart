import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/profile/save1.jpg'),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Group four",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Text("SoftwareEngineering Student | Year 4", style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),
            
            // Functional Buttons related to your app
            _profileOption(Icons.grid_on, "My Posts", () {}),
            _profileOption(Icons.shopping_bag_outlined, "My Listings", () => Navigator.pushNamed(context, '/marketplace')),
            _profileOption(Icons.event_available, "Joined Events", () => Navigator.pushNamed(context, '/events')),
            
            const SizedBox(height: 40),
            
            // Wireframe Edit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Navigate to Edit Profile Logic
                  },
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}