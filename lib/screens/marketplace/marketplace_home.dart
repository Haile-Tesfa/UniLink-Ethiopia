import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class MarketplaceHome extends StatelessWidget {
  const MarketplaceHome({super.key});

  @override
  Widget build(BuildContext context) {
    // List of your specific marketplace assets
    final List<String> items = [
      'assets/images/marketplace/item_0.jpg',
      'assets/images/marketplace/item_1.jpg',
      'assets/images/marketplace/item_2.png', // Corrected extension
      'assets/images/marketplace/item_3.jpg',
      'assets/images/marketplace/item_4.jpg',
      'assets/images/marketplace/item_5.jpg',
      'assets/images/marketplace/item_6.jpg',
      'assets/images/marketplace/item_7.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Marketplace"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // Add search logic here
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,       // 2 items per row
          childAspectRatio: 0.75,  // Adjust height/width ratio
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          return Card(
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the specific item image
                Expanded(
                  child: Image.asset(
                    items[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Item ${i + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Price: Negotiable",
                        style: TextStyle(color: AppColors.secondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      
      // FULL FLOATING ACTION BUTTON IMPLEMENTATION
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, '/create_listing'), 
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // Consistent Bottom Navigation across screens
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // Marketplace is index 1
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      onTap: (index) {
        if (index == 0) Navigator.pushReplacementNamed(context, '/home');
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