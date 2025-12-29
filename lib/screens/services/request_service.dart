import 'package:flutter/material.dart';

class RequestServiceScreen extends StatelessWidget {
  const RequestServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Service'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Request Service Screen',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
