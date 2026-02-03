import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_system/design_system.dart';

/// Main shell widget with 4-tab BottomNavigationBar
/// 4탭 스마트 구조: 홈(Chat Insight) / 운세 / 기록 / 더보기
class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _migrationGuideKey = 'migration_guide_v2_shown';

  @override
  void initState() {
    super.initState();
    _checkMigrationGuide();
  }

  Future<void> _checkMigrationGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_migrationGuideKey) ?? false;
    if (!shown && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showMigrationGuide(prefs);
      }
    }
  }

  void _showMigrationGuide(SharedPreferences prefs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _MigrationGuideSheet(
        onConfirm: () {
          prefs.setBool(_migrationGuideKey, true);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            top: BorderSide(
              color: colors.divider,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: '홈',
                  isSelected: currentIndex == 0,
                  accentColor: colors.accent,
                  inactiveColor: colors.textTertiary,
                  onTap: () => _onItemTapped(0),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: '운세',
                  isSelected: currentIndex == 1,
                  accentColor: colors.accent,
                  inactiveColor: colors.textTertiary,
                  onTap: () => _onItemTapped(1),
                ),
                _NavItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: '기록',
                  isSelected: currentIndex == 2,
                  accentColor: colors.accent,
                  inactiveColor: colors.textTertiary,
                  onTap: () => _onItemTapped(2),
                ),
                _NavItem(
                  icon: Icons.menu_outlined,
                  activeIcon: Icons.menu,
                  label: '더보기',
                  isSelected: currentIndex == 3,
                  accentColor: colors.accent,
                  inactiveColor: colors.textTertiary,
                  onTap: () => _onItemTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Migration guide bottom sheet - shown once after update
class _MigrationGuideSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _MigrationGuideSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.xl),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Accent icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: colors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Title
          Text(
            '새로워진 Fortune!',
            style: typography.headingMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),

          // Description
          Text(
            '카톡 대화 분석으로 더 깊은 인사이트를 경험하세요.\n'
            '기존 운세는 [운세] 탭에서 만나보실 수 있어요.',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.md),

          // Tab guide items
          _TabGuideRow(
            icon: Icons.chat_bubble_outline,
            label: '홈',
            description: '카톡 대화 분석 + 채팅 상담',
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabGuideRow(
            icon: Icons.auto_awesome_outlined,
            label: '운세',
            description: '43+ 운세 카테고리 탐색',
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabGuideRow(
            icon: Icons.calendar_today_outlined,
            label: '기록',
            description: '히스토리 타임라인',
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabGuideRow(
            icon: Icons.menu_outlined,
            label: '더보기',
            description: '프로필 / 설정 / 트렌드 / 건강',
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: DSSpacing.xl),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colors.ctaBackground,
                foregroundColor: colors.ctaForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                '확인',
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.ctaForeground,
                ),
              ),
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _TabGuideRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final DSColorScheme colors;
  final DSTypographyScheme typography;

  const _TabGuideRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.accent),
        const SizedBox(width: DSSpacing.sm),
        Text(
          label,
          style: typography.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Text(
            description,
            style: typography.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? accentColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Neon glow indicator for selected tab
            if (isSelected)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 6),
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
