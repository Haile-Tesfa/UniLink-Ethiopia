import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ServiceList extends StatelessWidget {
  const ServiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Services")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, i) => ListTile(
          leading: const Icon(Icons.work, color: AppColors.secondary),
          title: Text("Tutoring Service #$i"),
          subtitle: const Text("Provider: Aman K. • 150 ETB/hr"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ),
    );
  }
}