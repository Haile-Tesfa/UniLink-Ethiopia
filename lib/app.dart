import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_feed.dart';
import 'screens/marketplace/marketplace_home.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/post/create_post_screen.dart';
import 'screens/events/events_home.dart';
import 'screens/services/services_home.dart';
import 'screens/events/event_details_screen.dart';
import 'screens/events/create_event_screen.dart';

class UniLinkApp extends StatelessWidget {
  const UniLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP: still used only for routes that need it
    const int fakeUserId = 3;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniLink',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),

        '/home': (_) => const HomeFeed(currentUserId: fakeUserId),

        '/profile': (_) => const ProfileScreen(),

        '/marketplace': (_) =>
            const MarketplaceHome(currentUserId: fakeUserId),

        // later if you add a named /chat route, also pass fakeUserId/currentUserId here
        // '/chat': (_) => ChatScreen(currentUserId: fakeUserId),

        '/search': (_) => const SearchScreen(),
        '/create-post': (_) => const CreatePostScreen(),
        '/events': (_) => const EventsHome(),
        // IMPORTANT: removed '/notifications' route
        '/services': (_) => const ServicesHome(),
        '/event-details': (_) => const EventDetailsScreen(event: {}),
        '/create-event': (_) => const CreateEventScreen(),
      },
    );
  }
}
