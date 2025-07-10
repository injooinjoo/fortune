import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import 'token_balance_widget.dart';

enum FontSize { small, medium, large }

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showShareButton;
  final bool showFontSizeSelector;
  final bool showTokenBalance;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSharePressed;
  final Function(FontSize)? onFontSizeChanged;
  final FontSize currentFontSize;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppHeader({
    Key? key,
    this.title,
    this.showBackButton = true,
    this.showShareButton = false,
    this.showFontSizeSelector = false,
    this.showTokenBalance = true,
    this.onBackPressed,
    this.onSharePressed,
    this.onFontSizeChanged,
    this.currentFontSize = FontSize.medium,
    this.actions,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

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
        await Share.share(
          '포춘 - AI 운세 서비스\n$currentUrl',
          subject: '포춘에서 나의 운세를 확인해보세요!',
        );
      } catch (e) {
        await Clipboard.setData(ClipboardData(text: currentUrl));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('링크가 복사되었습니다')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: preferredSize,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          child: BackdropFilter(
            filter: GlassEffects.glassBlur(blur: 20),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                gradient: backgroundColor == null 
                  ? GlassEffects.lightGradient(
                      opacity: isDark ? 0.1 : 0.8,
                    )
                  : null,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                boxShadow: elevation > 0
                    ? GlassEffects.glassShadow(elevation: elevation)
                    : null,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      if (showBackButton)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: foregroundColor ?? theme.iconTheme.color,
                          ),
                          onPressed: () => _handleBack(context),
                        ),
                      if (title != null)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: showBackButton ? 0 : 16,
                              right: 8,
                            ),
                            child: Text(
                              title!,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: foregroundColor,
                              ),
                              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (showFontSizeSelector) ...[
                        _FontSizeSelector(
                          currentSize: currentFontSize,
                          onSizeChanged: onFontSizeChanged,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (showShareButton)
                        IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            color: foregroundColor ?? theme.iconTheme.color,
                          ),
                          onPressed: () => _handleShare(context),
                        ),
                      if (showTokenBalance) ...[
                        const TokenBalanceWidget(),
                        const SizedBox(width: 8),
                      ],
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
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

  const _FontSizeSelector({
    required this.currentSize,
    this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: BorderRadius.circular(20),
      blur: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SizeButton(
            label: '가',
            size: FontSize.small,
            isSelected: currentSize == FontSize.small,
            onTap: () => onSizeChanged?.call(FontSize.small),
          ),
          const SizedBox(width: 8),
          _SizeButton(
            label: '가',
            size: FontSize.medium,
            isSelected: currentSize == FontSize.medium,
            onTap: () => onSizeChanged?.call(FontSize.medium),
          ),
          const SizedBox(width: 8),
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

  const _SizeButton({
    required this.label,
    required this.size,
    required this.isSelected,
    this.onTap,
  });

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
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}