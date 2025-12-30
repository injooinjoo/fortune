import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';

/// Main shell widget that provides consistent background
/// Chat-First 아키텍처: 네비게이션 바 없이 채팅 중심 UX
class MainShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wrap entire shell with HanjiBackground for Korean traditional aesthetic
    return HanjiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: child,
      ),
    );
  }
}