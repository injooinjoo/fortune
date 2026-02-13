import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// @deprecated Use [DSCard] instead for consistent design system usage.
/// ChatGPT 스타일 카드 컴포넌트
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final AppCardStyle style;
  final bool enableHaptic;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.style = AppCardStyle.elevated,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.shadows;

    final Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _getBackgroundColor(colors),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: _getBorder(colors),
        boxShadow: _getBoxShadow(shadows),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: InkWell(
          onTap: onTap != null
              ? () {
                  if (enableHaptic) {
                    DSHaptics.light();
                  }
                  onTap!();
                }
              : null,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(DSSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }

  Color _getBackgroundColor(DSColorScheme colors) {
    switch (style) {
      case AppCardStyle.elevated:
      case AppCardStyle.outlined:
      case AppCardStyle.filled:
        return colors.surface;
      case AppCardStyle.transparent:
        return Colors.transparent;
      case AppCardStyle.glassmorphism:
        return colors.surface.withValues(alpha: 0.7);
    }
  }

  double _getBorderRadius() {
    switch (style) {
      case AppCardStyle.glassmorphism:
        return DSRadius.xl;
      default:
        return DSRadius.md;
    }
  }

  BoxBorder? _getBorder(DSColorScheme colors) {
    switch (style) {
      case AppCardStyle.elevated:
      case AppCardStyle.outlined:
        return Border.all(
          color: colors.border,
          width: 1,
        );
      case AppCardStyle.glassmorphism:
        return Border.all(
          color: colors.border.withValues(alpha: 0.2),
          width: 1,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow(DSShadowScheme shadows) {
    // Flat design - no depth shadows
    return null;
  }
}

enum AppCardStyle {
  elevated,
  outlined,
  filled,
  transparent,
  glassmorphism,
}

/// 리스트 아이템용 카드
class AppListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AppCardStyle style;

  const AppListCard({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.style = AppCardStyle.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return AppCard(
      style: style,
      padding: padding ?? const EdgeInsets.all(DSSpacing.md),
      margin: margin,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: DSSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  DefaultTextStyle(
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DSSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// @deprecated Use [AppListCard] instead
typedef TossListCard = AppListCard;

/// 섹션 카드 컴포넌트
class AppSectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AppCardStyle style;

  const AppSectionCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.margin,
    this.style = AppCardStyle.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return AppCard(
      style: style,
      padding: padding ?? const EdgeInsets.all(DSSpacing.md),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.xs),
              Text(
                subtitle!,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: DSSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

/// @deprecated Use [AppSectionCard] instead
typedef TossSectionCard = AppSectionCard;
