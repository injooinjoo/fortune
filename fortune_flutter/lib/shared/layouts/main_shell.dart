import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/bottom_navigation_bar.dart';

/// Main shell widget that provides persistent navigation
/// This widget wraps around all main pages and maintains the bottom navigation bar
class MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    Key? key,
    required this.child,
    required this.state,
  }) : super(key: key);

  int _calculateSelectedIndex(String location) {
    // Determine which navigation item should be selected based on the current route
    if (location.startsWith('/home')) {
      return 0;
    } else if (location.startsWith('/fortune')) {
      return 1;
    } else if (location.startsWith('/todo')) {
      return 2;
    } else if (location.startsWith('/physiognomy')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }
    return 0; // Default to home
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(state.uri.path);

    return Scaffold(
      body: child,
      bottomNavigationBar: FortuneBottomNavigationBar(
        currentIndex: selectedIndex,
      ),
    );
  }
}