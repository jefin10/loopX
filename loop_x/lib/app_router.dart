import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop_x/components/chats/chat_page.dart';
import 'package:loop_x/pages/profile_guest_page.dart';
import 'package:loop_x/pages/edit_profile.dart';
import 'package:loop_x/pages/anonymous_chat.dart';
import 'package:loop_x/screens/home_screen.dart';
import 'package:loop_x/start/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loop_x/start/login_screen.dart';
import 'package:loop_x/screens/chat_screen.dart';
import 'package:loop_x/screens/add_screen.dart';  
import 'package:loop_x/screens/profile_screen.dart';
import 'package:loop_x/screens/search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:loop_x/widgets/curved_navigation_bar.dart';

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
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatPage(chatId: chatId);
      },
    ),
    
    // Anonymous chat route
    GoRoute(
      path: '/anonymous-chat',
      builder: (context, state) => const AnonymousChat(),
    ),
    
    // Main navigation shell
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          extendBody: true,
          body: child,
          bottomNavigationBar: CurvedNavigationBar(
            currentIndex: _calculateSelectedIndex(state.uri.path),
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
        
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: 'user/:userId',
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