import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import 'token_balance_widget.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

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
  final bool showShareButton;
  final bool showFontSizeSelector;
  final bool showTokenBalance;
  final bool showActions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSharePressed;
  final Function(FontSize)? onFontSizeChanged;
  final FontSize currentFontSize;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppHeader(
    {
    Key? key,
    this.title,
    this.showBackButton = true,
    this.showShareButton = false,
    this.showFontSizeSelector = false,
    this.showTokenBalance = true,
    this.showActions = true,
    this.onBackPressed,
    this.onSharePressed,
    this.onFontSizeChanged,
    this.currentFontSize = FontSize.medium,
    this.actions,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
  )}) : super(key: key);

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
          '포춘 - AI 운세 서비스\n$currentUrl'),
        subject: '포춘에서 나의 운세를 확인해보세요!')
      } catch (e) {
        await Clipboard.setData(ClipboardData(text: currentUrl);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('링크가 복사되었습니다')))
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
      child: AnimatedContainer(,
      duration: AppAnimations.durationShort),
        child: ClipRRect(,
      child: BackdropFilter(,
      filter: GlassEffects.glassBlur(blu,
      r: 20),
            child: Container(,
      decoration: BoxDecoration(,
      color: backgroundColor,
                gradient: backgroundColor == null 
                  ? GlassEffects.lightGradient(
                      opacity: isDark ? 0.1 : 0.8))
                  : null,
        ),
        border: Border(,
      bottom: BorderSide(
                    color: isDark
                        ? AppColors.textPrimaryDark.withValues(alpha: 0.1)
                        : AppColors.textPrimary.withValues(alpha: 0.1),
                    width: 0.5)),
      boxShadow: elevation > 0
                    ? GlassEffects.glassShadow(elevation: elevation)
                    : null)
              child: SafeArea(,
      child: Padding(,
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing2),
                  child: Row(,
      children: [
                      if (showBackButton,
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: foregroundColor ?? theme.iconTheme.color),
      onPressed: () => _handleBack(context))
                      if (title != null,
                        Expanded(
                          child: Padding(,
      padding: EdgeInsets.only(rig,
      ht: AppSpacing.xSmall),
                            child: Text(
                              title!),
        style: theme.textTheme.headlineSmall?.copyWith(,
      color: foregroundColor,
                          ))
                              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
      overflow: TextOverflow.ellipsis)),
                      else
                        const Spacer(),
                      if (showFontSizeSelector) ...[
                        _FontSizeSelector(
                          currentSize: currentFontSize,
                          onSizeChanged: onFontSizeChanged)
                        SizedBox(width: AppSpacing.spacing2),
                      ]
                      if (showShareButton,
                        IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            color: foregroundColor ?? theme.iconTheme.color),
      onPressed: () => _handleShare(context))
                      if (showTokenBalance) ...[
                        const TokenBalanceWidget(),
                        SizedBox(width: AppSpacing.spacing2),
                      ]
                      if (showActions && actions != null) ...actions!,
                    ])))))))))))
      )
  }
}

class _FontSizeSelector extends StatelessWidget {
  final FontSize currentSize;
  final Function(FontSize)? onSizeChanged;

  const _FontSizeSelector(
    {
    required this.currentSize,
    this.onSizeChanged,
  )});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      blur: 10,
      child: Row(,
      mainAxisSize: MainAxisSize.min,
        children: [
          _SizeButton(
            label: '가',
            size: FontSize.small,
            isSelected: currentSize == FontSize.small),
        onTap: () => onSizeChanged?.call(FontSize.small))
          SizedBox(width: AppSpacing.spacing2),
          _SizeButton(
            label: '가',
            size: FontSize.medium,
            isSelected: currentSize == FontSize.medium),
        onTap: () => onSizeChanged?.call(FontSize.medium))
          SizedBox(width: AppSpacing.spacing2),
          _SizeButton(
            label: '가',
            size: FontSize.large,
            isSelected: currentSize == FontSize.large),
        onTap: () => onSizeChanged?.call(FontSize.large))
        ]
      )
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final FontSize size;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SizeButton(
    {
    required this.label,
    required this.size,
    required this.isSelected,
    this.onTap,
  )});

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
      borderRadius: AppDimensions.borderRadiusMedium),
        child: Container(,
      padding: EdgeInsets.symmetric(horizont,
      al: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
        decoration: BoxDecoration(,
      color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Text(
          label),
        style: TextStyle(,
      fontSize: fontSize),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color)))
      )
  }
}