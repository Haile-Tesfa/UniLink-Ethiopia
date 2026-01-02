
import 'package:flutter/material.dart';
import 'home_feed.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  final String fullName;
  final String email;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return HomeFeed(currentUserId: userId);
  }
}
