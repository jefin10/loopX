import 'package:flutter/material.dart';
import 'package:loop_x/components/chats/chat_page.dart';
import 'package:loop_x/pages/profile_guest_page.dart';
import 'package:loop_x/pages/edit_profile.dart';

import 'package:loop_x/screens/home_screen.dart';
import 'package:loop_x/start/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loop_x/start/login_screen.dart';
import 'package:loop_x/screens/chat_screen.dart';
import 'package:loop_x/screens/add_screen.dart';  
import 'package:loop_x/screens/profile_screen.dart';
import 'package:loop_x/screens/search_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.fullPath == '/login' || state.fullPath == '/register';
    if (session == null && !isLoggingIn) {
      return '/login';
    } else if (session != null && isLoggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Chat detail route - outside main navigation
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatPage(chatId: chatId);
      },
    ),
    
    // Main navigation shell
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(state.uri.path),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label: 'New',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/search');
                  break;
                case 2:
                  context.go('/add');
                  break;
                case 3:
                  context.go('/chat');
                  break;
                case 4:
                  context.go('/profile');
                  break;
              }
            },
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen()
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen() 
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const AddScreen()
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen()
        ),
        
        // Profile routes within shell navigation
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            // Adding a more specific pattern to ensure 'edit' route is matched properly
            GoRoute(
              path: 'edit', // Specific route first
              name: 'edit-profile', // Adding a name helps with route priority
              builder: (context, state) => const EditProfileScreen(),
            ),
            // Adding a more specific pattern for user ID to avoid conflict
            GoRoute(
              path: 'user/:userId', // More specific parameter route pattern
              builder: (context, state) {
                final userId = state.pathParameters['userId']!;
                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == currentUserId) {
                  return const ProfileScreen();
                } else {
                  return ProfileGuestPage(userId: userId);
                }
              },
            ),
          ],
        ),
      ]
    )
  ],
);

int _calculateSelectedIndex(String location) {
  // Make profile tab active when viewing any profile
  if (location.startsWith('/profile')) {
    return 4;
  } else if (location.startsWith('/search')) {
    return 1;
  } else if (location.startsWith('/add')) {
    return 2;
  } else if (location.startsWith('/chat')) {
    return 3;
  } else if (location == '/') {
    return 0;
  }
  return 0;
}