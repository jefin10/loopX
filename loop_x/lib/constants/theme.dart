import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
  fontFamily: 'Urbanist',
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Color(0xFFD100F0)	,
    
    onSurface: Colors.white
    
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Color(0xFFD100F0),
    unselectedItemColor: Colors.white,
  ),
  
);
