import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ServicesHome extends StatelessWidget {
  const ServicesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _ServiceCard(
            icon: Icons.library_books,
            title: 'Study Materials',
            description: 'Notes, past papers, books',
            color: Colors.blue,
            onTap: () {},
          ),
          _ServiceCard(
            icon: Icons.car_repair,
            title: 'Transport',
            description: 'Carpool, taxi services',
            color: Colors.green,
            onTap: () {},
          ),
          _ServiceCard(
            icon: Icons.fastfood,
            title: 'Food Delivery',
            description: 'Campus food services',
            color: Colors.orange,
            onTap: () {},
          ),
          _ServiceCard(
            icon: Icons.cleaning_services,
            title: 'Cleaning',
            description: 'Room cleaning services',
            color: Colors.purple,
            onTap: () {},
          ),
          _ServiceCard(
            icon: Icons.computer,
            title: 'Tech Support',
            description: 'Computer repair & help',
            color: Colors.red,
            onTap: () {},
          ),
          _ServiceCard(
            icon: Icons.work,
            title: 'Part-time Jobs',
            description: 'Campus job opportunities',
            color: Colors.teal,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}