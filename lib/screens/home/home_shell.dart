// lib/screens/home/home_shell.dart
import 'package:flutter/material.dart';

import '../home/home_screen.dart';              // your existing main feed
import '../marketplace/marketplace_home.dart';  // if you have it
import '../chat/chat_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/enhanced_bottom_navbar.dart';

class HomeShell extends StatefulWidget {
  final int currentUserId;
  final String fullName;
  final String email;

  const HomeShell({
    super.key,
    required this.currentUserId,
    required this.fullName,
    required this.email,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        userId: widget.currentUserId,
        fullName: widget.fullName,
        email: widget.email,
      ),
      MarketplaceHome(currentUserId: widget.currentUserId),
      ChatScreen(currentUserId: widget.currentUserId),
      NotificationsScreen(currentUserId: widget.currentUserId),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: EnhancedBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
