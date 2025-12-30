import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/home/home_feed.dart';
import 'screens/home/chat_screen.dart';
import 'screens/marketplace/marketplace_home.dart';
import 'screens/events/events_list.dart';

class UniLinkApp extends StatelessWidget {
  const UniLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/chat': (_) => const ChatScreen(),
        '/marketplace': (_) => const MarketplaceHome(),
        '/events': (_) => const EventsList(),
        
      },
    );
  }
}
