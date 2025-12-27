import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/bottom_navigation_bar.dart';
import '../../presentation/providers/navigation_visibility_provider.dart';
import '../../routes/navigation_helper.dart';
import '../../core/design_system/design_system.dart';

/// Main shell widget that provides persistent navigation
/// This widget wraps around all main pages and maintains the bottom navigation bar
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    super.key,
    required this.child,
    required this.state});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _paddingAnimation;
  
  static const double _navBarHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1.0)).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut));
    _paddingAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut));

    // Set initial animation state AND provider state based on current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShow = NavigationHelper.shouldShowNavigationBar(widget.state);
      if (!shouldShow) {
        _animationController.value = 1.0;
      }
      // Sync provider state with initial route visibility
      ref.read(navigationVisibilityProvider.notifier).setVisibility(shouldShow);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(String location) {
    // Determine which navigation item should be selected based on the current route
    // Chat-First 4탭 구조: Home/Chat(0), 인사이트(1), 탐구(2), 트렌드(3)
    // 프로필은 각 페이지 상단 ProfileHeaderIcon → 바텀시트로 접근
    if (location.startsWith('/chat')) {
      return 0;
    } else if (location.startsWith('/home')) {
      return 1;
    } else if (location.startsWith('/fortune')) {
      return 2;
    } else if (location.startsWith('/trend')) {
      return 3;
    }
    return 0; // Default to Chat
  }

  void _updateNavigationVisibility() {
    final shouldShow = NavigationHelper.shouldShowNavigationBar(widget.state);
    final currentVisibility = ref.read(navigationVisibilityProvider).isVisible;
    
    // Only update if visibility actually changed
    if (shouldShow != currentVisibility) {
      if (kDebugMode) {
        debugPrint('route: ${widget.state.uri.path}');
      }
      // Update the navigation visibility state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationVisibilityProvider.notifier).setVisibility(shouldShow);
      });
    }
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.uri.path != widget.state.uri.path) {
      _updateNavigationVisibility();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNavigationVisibility();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(widget.state.uri.path);
    final navigationState = ref.watch(navigationVisibilityProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Control animation based on visibility state with proper timing
    // Ensure animation state matches visibility state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigationState.isVisible && _animationController.value != 0) {
        // Navigation should be visible - slide up animation (reverse to 0)
        _animationController.reverse();
      } else if (!navigationState.isVisible && _animationController.value != 1) {
        // Navigation should be hidden - slide down animation (forward to 1)
        _animationController.forward();
      }
    });

    // Wrap entire shell with HanjiBackground for Korean traditional aesthetic
    return HanjiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false, // Prevent navigation bar from moving with keyboard
        body: Stack(
          children: [
            // Main content with animated padding
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _paddingAnimation,
                builder: (context, child) {
                  final totalNavHeight = _navBarHeight + bottomPadding;
                  // Add bottom padding when navigation bar is visible
                  final bottomPaddingValue = navigationState.isVisible ? totalNavHeight * _paddingAnimation.value : 0.0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottomPaddingValue),
                    child: widget.child);
                },
              ),
            ),
            // Navigation bar with ink-wash shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _navBarHeight + bottomPadding, // Add explicit height
              child: SlideTransition(
                position: _slideAnimation,
                child: FortuneBottomNavigationBar(
                  currentIndex: selectedIndex,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}