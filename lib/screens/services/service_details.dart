import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.school, size: 100, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text("Advanced Math Tutoring", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("By Aman K. • 4.9 Star Rating", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text("Service Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("I offer tutoring for Calculus I, II and Linear Algebra. I have 2 years of experience helping students pass their exams."),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                    onPressed: () => Navigator.pushNamed(context, '/chat'),
                    child: const Text("Message Provider"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => Navigator.pushNamed(context, '/request_service'),
                    child: const Text("Request Now", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}