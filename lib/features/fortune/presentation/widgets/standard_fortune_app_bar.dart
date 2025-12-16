import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

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
  final bool showBackButton;

  const StandardFortuneAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: colors.textPrimary,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      iconTheme: IconThemeData(
        color: colors.textPrimary,
      ),
      title: Text(
        title,
        style: DSTypography.headingMedium.copyWith(
          color: colors.textPrimary,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
