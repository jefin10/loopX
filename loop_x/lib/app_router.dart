import 'package:flutter/material.dart';
import 'package:loop_x/screens/home_screen.dart';
import 'package:loop_x/start/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loop_x/start/login_screen.dart';
import 'package:loop_x/screens/chat_screen.dart';
import 'package:loop_x/screens/add_screen.dart';  
import 'package:loop_x/screens/profile_screen.dart';
import 'package:loop_x/screens/search_screen.dart';
import 'package:go_router/go_router.dart';
final GoRouter appRouter= GoRouter(
  initialLocation: '/home',
  redirect:(context,state){
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn=state.fullPath=='/login' || state.fullPath=='/register';
    if(session==null && !isLoggingIn){
      return '/login';
    }
    else if(session!=null && isLoggingIn){
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder:(context,state) {
        return const LoginScreen();
      }
    ),
    GoRoute(
      path: '/register',
      builder:(context,state) {
        return const RegisterScreen();
      }
    ),
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(state.uri.toString()),
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
            onTap: (index){
              switch(index){
                case 0:
                  context.go('/home');
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
      routes:[
        GoRoute(
          path: '/home',
          builder:(context,state) => const HomeScreen()
        ),
        GoRoute(
          path: '/search',
          builder:(context,state) => const SearchScreen() 
        ),
        GoRoute(
          path: '/add',
          builder:(context,state) => const AddScreen()
        ),
        GoRoute(
          path: '/chat',
          builder:(context,state) => const ChatScreen()
        ),
        GoRoute(
          path: '/profile',
          builder:(context,state) => const ProfileScreen()
        ),

      ]
    )
  ],
  

);
int _calculateSelectedIndex(String location) {
  if(location == '/home') {
    return 0;
  } else if(location == '/search') {
    return 1;
  } else if(location == '/add') {
    return 2;
  } else if(location == '/chat') {
    return 3;
  } else if(location == '/profile') {
    return 4;
  } 
  return 0;
}