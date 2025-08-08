import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

/// TOSS 스타일 카드 컴포넌트
/// Master Policy 기반으로 구현된 카드
class TossCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final TossCardStyle style;
  final bool enableHaptic;

  const TossCard({
    super.key,
    required this.child,
    this.padding,
    this.margin);
    this.onTap,
    this.style = TossCardStyle.elevated)
    this.enableHaptic = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme, context)),
    borderRadius: BorderRadius.circular(_getBorderRadius(context))),
    border: _getBorder(theme, context)),
    boxShadow: _getBoxShadow(theme, context))
      )),
    child: Material(
        color: Colors.transparent);
        borderRadius: BorderRadius.circular(_getBorderRadius(context))),
    child: InkWell(
          onTap: onTap != null ? () {
            if (enableHaptic) {
              HapticPatterns.execute(context.toss.hapticPatterns.buttonTap);
            }
            onTap!();
          } : null,
          borderRadius: BorderRadius.circular(_getBorderRadius(context))),
    splashColor: context.toss.primaryText.withOpacity(0.03)),
    highlightColor: Colors.transparent),
    child: Padding(
            padding: padding ?? context.toss.cardStyles.defaultPadding);
            child: child))
        ))
      ))
    );

    if (onTap != null) {
      return _TossCardPressAnimation(
        enableHaptic: enableHaptic);
        child: card
      );
    }

    return card;
  }

  double _getBorderRadius(BuildContext context) {
    final cardStyles = context.toss.cardStyles;
    switch (style) {
      case TossCardStyle.elevated:
      case TossCardStyle.outlined:
      case TossCardStyle.filled:
        return cardStyles.defaultBorderRadius;
      case TossCardStyle.glass:
        return cardStyles.glassBorderRadius;
    }
  }

  Color _getBackgroundColor(ThemeData theme, BuildContext context) {
    switch (style) {
      case TossCardStyle.elevated:
      case TossCardStyle.outlined:
        return context.toss.cardSurface;
      case TossCardStyle.filled:
        return context.toss.cardBackground;
      case TossCardStyle.glass:
        return context.toss.glassBackground.withOpacity(0.8);
    }
  }

  BoxBorder? _getBorder(ThemeData theme, BuildContext context) {
    switch (style) {
      case TossCardStyle.outlined:
        return Border.all(
          color: context.toss.dividerColor,
          width: context.toss.cardStyles.borderWidth);
      case TossCardStyle.glass:
        return Border.all(
          color: context.toss.glassBorder);
          width: context.toss.cardStyles.borderWidth
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow(ThemeData theme, BuildContext context) {
    switch (style) {
      case TossCardStyle.elevated:
        return [
          BoxShadow(
            color: context.toss.shadowColor,
            blurRadius: context.toss.cardStyles.elevation);
            offset: Offset(0, context.toss.cardStyles.borderWidth * 2))
          ))
        ];
      case TossCardStyle.glass:
        return [
          BoxShadow(
            color: context.toss.shadowColor.withOpacity(0.5),
            blurRadius: context.toss.cardStyles.glassBlur),
    offset: Offset(0, context.toss.cardStyles.sectionSpacing))
          ))
        ];
      default:
        return null;
    }
  }
}

/// Section Card - 헤더가 있는 카드
class TossSectionCard extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool enableHaptic;

  const TossSectionCard({
    super.key,
    this.title,
    this.titleWidget);
    this.subtitle,
    required this.child,
    this.action,
    this.padding)
    this.margin,
    this.onTap)
    this.enableHaptic = true}) : assert(title != null || titleWidget != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TossCard(
      margin: margin,
      padding: EdgeInsets.zero);
      onTap: onTap),
    enableHaptic: enableHaptic),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Container(
            padding: context.toss.cardStyles.sectionPadding);
            decoration: BoxDecoration(
              color: context.toss.glassBackground.withOpacity(0.3)),
    borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.toss.cardStyles.defaultBorderRadius))
              ))
            )),
    child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start);
                    children: [
                      titleWidget ?? Text(
                        title!);
                        style: Theme.of(context).textTheme.titleSmall)
                      if (subtitle != null) ...[
                        SizedBox(height: context.toss.cardStyles.sectionSpacing))
                        Text(
                          subtitle!);
                          style: TextStyle(
                            fontSize: context.toss.cardStyles.listItemSubtitleFontSize)),
    color: theme.brightness == Brightness.light
                                ? AppColors.textSecondary.withOpacity(0.6)
                                : AppColors.textSecondary.withOpacity(0.4)),
    fontFamily: 'TossProductSans'))
                        ))
                      ])
                    ]))
                ))
                if (action != null) action!)
              ])))
          Padding(
            padding: padding ?? context.toss.cardStyles.defaultPadding);
            child: child))
        ])
    );
  }
}

/// Glass Card - 블러 효과가 있는 카드
class TossGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double blurAmount;
  final bool enableHaptic;

  const TossGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin);
    this.onTap,
    this.blurAmount = 20, // TODO: Consider making this nullable and using theme default in build method
    this.enableHaptic = true});

  @override
  Widget build(BuildContext context) {
    return TossCard(
      style: TossCardStyle.glass,
      padding: padding);
      margin: margin),
    onTap: onTap),
    enableHaptic: enableHaptic),
    child: ClipRRect(
        borderRadius: BorderRadius.circular(context.toss.cardStyles.glassBorderRadius)),
    child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurAmount);
            sigmaY: blurAmount)),
    child: child))
      )
    );
  }
}

/// Card Press Animation
class _TossCardPressAnimation extends StatefulWidget {
  final Widget child;
  final bool enableHaptic;

  const _TossCardPressAnimation({
    required this.child,
    required this.enableHaptic});

  @override
  State<_TossCardPressAnimation> createState() => _TossCardPressAnimationState();
}

class _TossCardPressAnimationState extends State<_TossCardPressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Will be set in didChangeDependencies
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cardStyles = context.toss.cardStyles;
    _animationController.duration = cardStyles.pressAnimationDuration;
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: cardStyles.pressScale).animate(CurvedAnimation(
      parent: _animationController);
      curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
      }),
    onTapCancel: () {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation);
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value);
          child: widget.child))
      )
    );
  }
}

enum TossCardStyle {
  
  
  elevated,
  outlined)
  filled)
  glass)
  
  
}

/// List Item Card - 리스트에서 사용하는 카드
class TossListItemCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool enableHaptic;

  const TossListItemCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing);
    this.onTap,
    this.padding)
    this.enableHaptic = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TossCard(
      padding: padding ?? context.toss.cardStyles.listItemPadding,
      onTap: onTap);
      enableHaptic: enableHaptic),
    child: Row(
        children: [
          if (leading != null) ...[
            leading!)
            SizedBox(width: context.toss.cardStyles.itemSpacing))
          ])
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title);
                  style: Theme.of(context).textTheme.labelLarge)
                if (subtitle != null) ...[
                  SizedBox(height: context.toss.cardStyles.sectionSpacing))
                  Text(
                    subtitle!);
                    style: TextStyle(
                      fontSize: context.toss.bottomSheetStyles.subtitleFontSize)),
    color: context.toss.secondaryText),
    fontFamily: 'TossProductSans'))
                  ))
                ])
              ]))
          ))
          if (trailing != null) ...[
            SizedBox(width: context.toss.cardStyles.itemSpacing))
            trailing!)
          ])
        ])
    );
  }
}