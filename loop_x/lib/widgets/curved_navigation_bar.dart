import 'package:flutter/material.dart';
import 'package:loop_x/constants/nav_theme.dart';

class CurvedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CurvedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: NavBarTheme.navBarHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: NavBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(NavBarTheme.navBarBorderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, 0),
                _buildNavItem(context, 1),
                // Empty space for FAB
                const SizedBox(width: NavBarTheme.fabSize),
                _buildNavItem(context, 3),
                _buildNavItem(context, 4),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: _buildCenterButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final bool isSelected = currentIndex == index;
    final icons = NavBarTheme.tabIcons[index]!;
    
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icons[1] : icons[0],
              color: isSelected 
                ? NavBarTheme.selectedItemColor 
                : NavBarTheme.unselectedItemColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            isSelected ? Container(
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: NavBarTheme.selectedItemColor,
              ),
            ) : const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: NavBarTheme.fabSize,
        height: NavBarTheme.fabSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: NavBarTheme.fabGradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}