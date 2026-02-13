import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';

/// Main shell widget — passthrough wrapper for StatefulNavigationShell
///
/// ChatGPT iOS style: No bottom navigation bar.
/// All navigation is handled programmatically via context.go().
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: navigationShell,
    );
  }
}
