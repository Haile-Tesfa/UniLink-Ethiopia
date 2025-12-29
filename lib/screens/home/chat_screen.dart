import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: ListView.separated(
        itemCount: 10,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text("Student Name $i"),
          subtitle: const Text("Is the item still available?"),
          onTap: () {},
        ),
      ),
    );
  }
}