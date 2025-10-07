import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/toss_theme.dart';

/// 표준 운세 페이지 AppBar
///
/// 모든 운세 페이지에서 일관된 디자인을 제공합니다:
/// - 좌측: 라운드 배경의 뒤로가기 버튼
/// - 중앙: 페이지 제목
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        child: IconButton(
          onPressed: onBackPressed ?? () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? TossDesignSystem.grayDark700
                : TossTheme.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            size: 20,
          ),
        ),
      ),
      title: Text(
        title,
        style: TossTheme.heading3.copyWith(
          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
