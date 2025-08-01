import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';

class FortuneBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const FortuneBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: '홈',
      route: '/home',
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      label: '운세',
      route: '/fortune',
    ),
    _NavItem(
      icon: Icons.trending_up,
      selectedIcon: Icons.trending_up,
      label: '트렌드',
      route: '/trend',
    ),
    _NavItem(
      icon: Icons.stars_outlined,
      selectedIcon: Icons.stars_rounded,
      label: '프리미엄',
      route: '/premium',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: '프로필',
      route: '/profile',
    ),
  ];

  int _getIndexFromPath(String path) {
    for (int i = 0; i < _items.length; i++) {
      if (path.startsWith(_items[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPath = GoRouterState.of(context).uri.path;
    final activeIndex = _getIndexFromPath(currentPath);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(
            color: context.fortuneTheme.dividerColor,
            width: AppSpacing.spacing0 * 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.buttonHeightLarge,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) => _NavItemWidget(
                item: _items[index],
                isSelected: index == activeIndex,
                onTap: () {
                  HapticFeedback.lightImpact();
                  // If already on the same route, refresh the page
                  if (currentPath == _items[index].route || currentPath.startsWith(_items[index].route)) {
                    // Special handling for fortune page to refresh and close any open sheets
                    if (_items[index].route == '/fortune') {
                      // Navigate away and back to force refresh
                      context.go('/home');
                      Future.delayed(const Duration(milliseconds: 50), () {
                        context.go('/fortune');
                      });
                    } else {
                      context.go(_items[index].route);
                    }
                  } else {
                    context.go(_items[index].route);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: AppDimensions.iconSizeMedium,
              color: isSelected 
                ? theme.colorScheme.primary 
                : context.fortuneTheme.subtitleText,
            ),
            SizedBox(height: AppSpacing.spacing1),
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isSelected 
                  ? theme.colorScheme.primary 
                  : context.fortuneTheme.subtitleText)),
          ],
        ),
      ),
    );
  }
}