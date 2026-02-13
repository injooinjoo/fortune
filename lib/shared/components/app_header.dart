import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../glassmorphism/glass_container.dart';
import 'token_balance_widget.dart';

enum FontSize { small, medium, large }

extension FontSizeExtension on FontSize {
  double get value {
    switch (this) {
      case FontSize.small:
        return 14.0;
      case FontSize.medium:
        return 16.0;
      case FontSize.large:
        return 18.0;
    }
  }

  FontSize operator +(int value) {
    if (this == FontSize.small && value > 0) return FontSize.medium;
    if (this == FontSize.medium && value > 0) return FontSize.large;
    if (this == FontSize.large && value < 0) return FontSize.medium;
    if (this == FontSize.medium && value < 0) return FontSize.small;
    return this;
  }

  FontSize operator -(int value) {
    return this + (-value);
  }
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showCloseButton;
  final bool showShareButton;
  final bool showFontSizeSelector;
  final bool showTokenBalance;
  final bool showActions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClosePressed;
  final VoidCallback? onSharePressed;
  final Function(FontSize)? onFontSizeChanged;
  final FontSize currentFontSize;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppHeader(
      {super.key,
      this.title,
      this.showBackButton = true,
      this.showCloseButton = false,
      this.showShareButton = false,
      this.showFontSizeSelector = false,
      this.showTokenBalance = true,
      this.showActions = true,
      this.onBackPressed,
      this.onClosePressed,
      this.onSharePressed,
      this.onFontSizeChanged,
      this.currentFontSize = FontSize.medium,
      this.actions,
      this.centerTitle = false,
      this.elevation = 0,
      this.backgroundColor,
      this.foregroundColor});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleBack(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
    } else if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      GoRouter.of(context).go('/home');
    }
  }

  void _handleShare(BuildContext context) async {
    if (onSharePressed != null) {
      onSharePressed!();
    } else {
      final currentUrl = GoRouterState.of(context).uri.toString();
      try {
        await Share.share('포춘 - 신점 운세 서비스\n$currentUrl',
            subject: '포춘에서 나의 운세를 확인해보세요!');
      } catch (e) {
        await Clipboard.setData(ClipboardData(text: currentUrl));
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('링크가 복사되었습니다')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return PreferredSize(
      preferredSize: preferredSize,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded,
                            color: foregroundColor ?? colors.textPrimary),
                        onPressed: () => _handleBack(context)),
                  if (title != null)
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: DSSpacing.xs),
                            child: Text(title!,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    color:
                                        foregroundColor ?? colors.textPrimary),
                                textAlign: centerTitle
                                    ? TextAlign.center
                                    : TextAlign.left,
                                overflow: TextOverflow.ellipsis)))
                  else
                    const Spacer(),
                  if (showFontSizeSelector) ...[
                    _FontSizeSelector(
                        currentSize: currentFontSize,
                        onSizeChanged: onFontSizeChanged),
                    const SizedBox(width: DSSpacing.xs)
                  ],
                  if (showShareButton)
                    IconButton(
                        icon: Icon(Icons.share_rounded,
                            color: foregroundColor ?? colors.textPrimary),
                        onPressed: () => _handleShare(context)),
                  if (showCloseButton)
                    IconButton(
                        icon: Icon(Icons.close,
                            color: foregroundColor ?? colors.textPrimary),
                        onPressed: () {
                          if (onClosePressed != null) {
                            onClosePressed!();
                          } else {
                            GoRouter.of(context).go('/fortune');
                          }
                        }),
                  if (showTokenBalance) ...[
                    const TokenBalanceWidget(),
                    const SizedBox(width: DSSpacing.xs)
                  ],
                  if (showActions && actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FontSizeSelector extends StatelessWidget {
  final FontSize currentSize;
  final Function(FontSize)? onSizeChanged;

  const _FontSizeSelector({required this.currentSize, this.onSizeChanged});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm, vertical: DSSpacing.xxs),
      borderRadius: BorderRadius.circular(DSRadius.xl),
      blur: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SizeButton(
              label: '가',
              size: FontSize.small,
              isSelected: currentSize == FontSize.small,
              onTap: () => onSizeChanged?.call(FontSize.small)),
          const SizedBox(width: DSSpacing.xs),
          _SizeButton(
              label: '가',
              size: FontSize.medium,
              isSelected: currentSize == FontSize.medium,
              onTap: () => onSizeChanged?.call(FontSize.medium)),
          const SizedBox(width: DSSpacing.xs),
          _SizeButton(
            label: '가',
            size: FontSize.large,
            isSelected: currentSize == FontSize.large,
            onTap: () => onSizeChanged?.call(FontSize.large),
          ),
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final FontSize size;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SizeButton(
      {required this.label,
      required this.size,
      required this.isSelected,
      this.onTap});

  double get fontSize {
    switch (size) {
      case FontSize.small:
        return 12;
      case FontSize.medium:
        return 14;
      case FontSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.xs, vertical: DSSpacing.xxs),
        decoration: BoxDecoration(
            color: isSelected
                ? colors.accent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DSRadius.md)),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colors.accent : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
