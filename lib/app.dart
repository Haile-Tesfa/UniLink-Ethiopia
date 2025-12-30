import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_feed.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/marketplace/marketplace_home.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/post/create_post_screen.dart';
import 'screens/events/events_home.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/services/services_home.dart';
import 'screens/events/event_details_screen.dart';
import 'screens/events/create_event_screen.dart';

class UniLinkApp extends StatelessWidget {
  const UniLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniLink',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeFeed(),
        '/profile': (_) => const ProfileScreen(),
        '/chat': (_) => const ChatScreen(),
        '/marketplace': (_) => const MarketplaceHome(),
        '/search': (_) => const SearchScreen(),
        '/create-post': (_) => const CreatePostScreen(),
        '/events': (_) => const EventsHome(),
        '/notifications': (_) => const NotificationsScreen(),
        '/services': (_) => const ServicesHome(),
        '/event-details': (_) => const EventDetailsScreen(event: {},),
        '/create-event': (_) => const CreateEventScreen(),
      },
    );
  }
}