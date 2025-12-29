import 'package:flutter/material.dart';

class EventsList extends StatelessWidget {
  const EventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events & Clubs")),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Campus Event ${i+1}", style: const TextStyle(fontSize: 18)),
              const Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }
}