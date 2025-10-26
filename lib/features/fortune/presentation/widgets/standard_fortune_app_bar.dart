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
      automaticallyImplyLeading: false, // ✅ 기본 백 버튼 제거
      iconTheme: IconThemeData(
        color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
      ),
      title: Text(
        title,
        style: TossTheme.heading3.copyWith(
          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
        ),
      ),
      centerTitle: centerTitle,
      // ✅ 우측 상단에 엑스 버튼 추가
      actions: actions ?? [
        IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
          ),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
