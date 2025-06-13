import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop_x/providers/navigation_provider.dart';

class HideNavBarScrollBehavior extends ScrollBehavior {
  final WidgetRef ref;
  
  HideNavBarScrollBehavior(this.ref);
  
  @override
  Widget buildViewportChrome(
    BuildContext context, Widget child, AxisDirection axisDirection) {
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Only react to actual scroll events, not overscroll or ballistic (fling) events
        if (notification is ScrollUpdateNotification) {
          if (notification.scrollDelta == null) return false;
          
          // Hide the navbar when scrolling down
          if (notification.scrollDelta! > 5) {
            ref.read(navigationProvider.notifier).hideNavBar();
          } 
          // Show the navbar when scrolling up
          else if (notification.scrollDelta! < -5) {
            ref.read(navigationProvider.notifier).showNavBar();
          }
          
          // Also show the navbar when at the top of the page
          if (notification.metrics.pixels <= 0) {
            ref.read(navigationProvider.notifier).showNavBar();
          }
        }
        
        // Return false to allow the notification to continue bubbling up
        return false;
      },
      child: child,
    );
  }
}