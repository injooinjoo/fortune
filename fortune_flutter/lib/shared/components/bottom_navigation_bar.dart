import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extensions.dart';

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
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      label: '할일',
      route: '/todo',
    ),
    _NavItem(
      icon: Icons.camera_alt_outlined,
      selectedIcon: Icons.camera_alt_rounded,
      label: '관상',
      route: '/physiognomy',
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
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) => _NavItemWidget(
                item: _items[index],
                isSelected: index == activeIndex,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go(_items[index].route);
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
              size: 24,
              color: isSelected 
                ? theme.colorScheme.primary 
                : context.fortuneTheme.subtitleText,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : context.fortuneTheme.subtitleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}