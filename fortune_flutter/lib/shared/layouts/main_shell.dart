import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/bottom_navigation_bar.dart';
import '../../presentation/providers/navigation_visibility_provider.dart';
import '../../routes/navigation_helper.dart';

/// Main shell widget that provides persistent navigation
/// This widget wraps around all main pages and maintains the bottom navigation bar
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    Key? key,
    required this.child,
    required this.state,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _paddingAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(String location) {
    // Determine which navigation item should be selected based on the current route
    if (location.startsWith('/home')) {
      return 0;
    } else if (location.startsWith('/fortune')) {
      return 1;
    } else if (location.startsWith('/trend')) {
      return 2;
    } else if (location.startsWith('/premium')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }
    return 0; // Default to home
  }

  void _updateNavigationVisibility() {
    final shouldShow = NavigationHelper.shouldShowNavigationBar(widget.state);
    
    // Update the navigation visibility state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).setVisibility(shouldShow);
    });
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

    // Control animation based on visibility state
    if (navigationState.isVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content with animated padding
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _paddingAnimation,
              builder: (context, child) {
                final totalNavHeight = _navBarHeight + bottomPadding;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: totalNavHeight * _paddingAnimation.value,
                  ),
                  child: widget.child,
                );
              },
            ),
          ),
          // Navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: FortuneBottomNavigationBar(
                currentIndex: selectedIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}