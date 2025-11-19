import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 표준 운세 페이지 AppBar
///
/// 모든 운세 페이지에서 일관된 디자인을 제공합니다:
/// - 좌측: iOS 스타일 백 버튼 (arrow_back_ios)
/// - 중앙: 페이지 제목 (heading3 폰트)
/// - 우측: 옵션(필요 시)
class StandardFortuneAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;

  const StandardFortuneAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      iconTheme: IconThemeData(
        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
      ),
      title: Text(
        title,
        style: TypographyUnified.heading3.copyWith(
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
