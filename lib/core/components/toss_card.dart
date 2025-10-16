import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/toss_design_system.dart';

/// TOSS 스타일 카드 컴포넌트
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
    this.margin,
    this.onTap,
    this.style = TossCardStyle.elevated,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: _getBorder(isDark),
        boxShadow: _getBoxShadow(isDark),
      ),
      child: Material(
        color: TossDesignSystem.white.withValues(alpha: 0.0),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: InkWell(
          onTap: onTap != null ? () {
            if (enableHaptic) {
              HapticFeedback.lightImpact();
            }
            onTap!();
          } : null,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Padding(
            padding: padding ?? EdgeInsets.all(TossDesignSystem.spacingM),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }

  Color _getBackgroundColor(bool isDark) {
    switch (style) {
      case TossCardStyle.elevated:
      case TossCardStyle.outlined:
      case TossCardStyle.filled:
        return isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white;
      case TossCardStyle.transparent:
        return TossDesignSystem.white.withValues(alpha: 0.0);
      case TossCardStyle.glassmorphism:
        return (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white)
            .withValues(alpha: 0.7);
    }
  }

  double _getBorderRadius() {
    switch (style) {
      case TossCardStyle.glassmorphism:
        return TossDesignSystem.radiusXL;
      default:
        return TossDesignSystem.radiusM;
    }
  }

  BoxBorder? _getBorder(bool isDark) {
    switch (style) {
      case TossCardStyle.outlined:
        return Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
          width: 1,
        );
      case TossCardStyle.glassmorphism:
        return Border.all(
          color: (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray100)
              .withValues(alpha: 0.2),
          width: 1,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isDark) {
    switch (style) {
      case TossCardStyle.elevated:
        return [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case TossCardStyle.glassmorphism:
        return [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ];
      default:
        return null;
    }
  }
}

enum TossCardStyle {
  elevated,
  outlined,
  filled,
  transparent,
  glassmorphism,
}

/// 리스트 아이템용 TOSS 스타일 카드
class TossListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final TossCardStyle style;

  const TossListCard({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.style = TossCardStyle.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossCard(
      style: style,
      padding: padding ?? EdgeInsets.all(TossDesignSystem.spacingM),
      margin: margin,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: TossDesignSystem.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: TossDesignSystem.spacingXS),
                  DefaultTextStyle(
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray400,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: TossDesignSystem.spacingM),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// 섹션 카드 컴포넌트
class TossSectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final TossCardStyle style;

  const TossSectionCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.margin,
    this.style = TossCardStyle.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossCard(
      style: style,
      padding: padding ?? EdgeInsets.all(TossDesignSystem.spacingM),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TossDesignSystem.heading4.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray900,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: TossDesignSystem.spacingXS),
              Text(
                subtitle!,
                style: TossDesignSystem.body3.copyWith(
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray400,
                ),
              ),
            ],
            SizedBox(height: TossDesignSystem.spacingM),
          ],
          child,
        ],
      ),
    );
  }
}