import 'package:flutter/material.dart';

class NavBarTheme {
  static const Color backgroundColor = Color(0xFF151515);
  static const Color selectedItemColor = Colors.white;
  static const Color unselectedItemColor = Color(0xFF9E9E9E);
  
  static const List<Color> fabGradientColors = [Color(0xFF9C27B0), Color(0xFF2196F3)];
  
  static const double navBarHeight = 80.0;
  static const double fabSize = 60.0;
  static const double navBarBorderRadius = 25.0;
  
  static const Map<int, List<IconData>> tabIcons = {
    0: [Icons.home_outlined, Icons.home],
    1: [Icons.search_outlined, Icons.search],
    2: [Icons.add_box_outlined, Icons.add_box],
    3: [Icons.chat_bubble_outline_rounded, Icons.chat_bubble],
    4: [Icons.person_outline, Icons.person],
  };
}