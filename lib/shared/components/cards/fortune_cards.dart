import 'package:flutter/material.dart';
import 'package:ondo/core/design_system/design_system.dart';

enum FortuneCardTone {
  neutral,
  accent,
  success,
  warning,
  danger,
  premium,
}

class FortuneCardSurface extends StatelessWidget {
  final Widget child;
  final FortuneCardTone tone;
  final DSCardStyle style;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final bool tinted;
  final bool showBorder;
  final double borderOpacity;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? accentGradient;
  final Color? accentColor;
  final double accentHeight;
  final VoidCallback? onTap;

  const FortuneCardSurface({
    super.key,
    required this.child,
    this.tone = FortuneCardTone.neutral,
    this.style = DSCardStyle.flat,
    this.padding,
    this.margin,
    this.borderRadius,
    this.tinted = false,
    this.showBorder = false,
    this.borderOpacity = 0.12,
    this.backgroundColor,
    this.borderColor,
    this.accentGradient,
    this.accentColor,
    this.accentHeight = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColor = _toneColor(context, tone);
    final resolvedBorderColor = borderColor ?? toneColor;
    final resolvedBackgroundColor = backgroundColor ??
        (tinted
            ? toneColor.withValues(alpha: 0.08)
            : _defaultSurface(colors, style));

    return DSCard(
      style: style,
      margin: margin,
      borderRadius: borderRadius,
      padding: EdgeInsets.zero,
      backgroundColor: resolvedBackgroundColor,
      border: showBorder
          ? Border.all(
              color: resolvedBorderColor.withValues(alpha: borderOpacity),
            )
          : null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (accentGradient != null || accentColor != null)
            Container(
              height: accentHeight,
              decoration: BoxDecoration(
                gradient: accentGradient ??
                    LinearGradient(
                      colors: [
                        accentColor ?? toneColor,
                        accentColor ?? toneColor,
                      ],
                    ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius ?? DSRadius.card),
                  topRight: Radius.circular(borderRadius ?? DSRadius.card),
                ),
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(DSSpacing.cardPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}

class FortuneCardBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final FortuneCardTone tone;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const FortuneCardBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = FortuneCardTone.neutral,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final toneColor = foregroundColor ?? _toneColor(context, tone);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xxs,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? toneColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius ?? DSRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: toneColor,
            ),
            const SizedBox(width: DSSpacing.xxs),
          ],
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: toneColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FortuneMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final FortuneCardTone tone;

  const FortuneMetricPill({
    super.key,
    required this.label,
    required this.value,
    this.tone = FortuneCardTone.accent,
  });

  @override
  Widget build(BuildContext context) {
    return FortuneCardBadge(
      label: '$label $value',
      tone: tone,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: 2,
      ),
      borderRadius: DSRadius.xs,
    );
  }
}

class FortuneFeatureCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final List<String> highlights;
  final FortuneCardTone tone;
  final EdgeInsetsGeometry? margin;

  const FortuneFeatureCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.highlights,
    this.tone = FortuneCardTone.accent,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return FortuneCardSurface(
      tone: tone,
      margin: margin,
      tinted: true,
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: context.labelSmall.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            title,
            style: context.heading4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            description,
            style: context.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: highlights
                  .map(
                    (item) => FortuneCardBadge(
                      label: item,
                      tone: tone,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class FortuneRecordCard extends StatelessWidget {
  final String badgeLabel;
  final IconData? badgeIcon;
  final FortuneCardTone badgeTone;
  final String metaText;
  final String? trailingText;
  final String? summary;
  final List<Widget> footer;
  final Widget? trailingAction;
  final VoidCallback? onTap;

  const FortuneRecordCard({
    super.key,
    required this.badgeLabel,
    this.badgeIcon,
    this.badgeTone = FortuneCardTone.neutral,
    required this.metaText,
    this.trailingText,
    this.summary,
    this.footer = const [],
    this.trailingAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FortuneCardSurface(
      style: DSCardStyle.elevated,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FortuneCardBadge(
                label: badgeLabel,
                icon: badgeIcon,
                tone: badgeTone,
                backgroundColor: context.colors.backgroundTertiary,
                foregroundColor: context.colors.textSecondary,
                borderRadius: DSRadius.sm,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                metaText,
                style: context.bodySmall.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              const Spacer(),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: context.labelSmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              if (trailingAction != null) ...[
                const SizedBox(width: DSSpacing.xs),
                trailingAction!,
              ],
            ],
          ),
          if (summary != null && summary!.trim().isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              summary!,
              style: context.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (footer.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: footer,
            ),
          ],
        ],
      ),
    );
  }
}

class FortuneSectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final FortuneCardTone tone;
  final DSCardStyle style;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const FortuneSectionCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.leading,
    this.trailing,
    this.tone = FortuneCardTone.neutral,
    this.style = DSCardStyle.flat,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return FortuneCardSurface(
      tone: tone,
      style: style,
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null ||
              subtitle != null ||
              leading != null ||
              trailing != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: DSSpacing.xs),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: context.headingSmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: DSSpacing.xxs),
                        Text(
                          subtitle!,
                          style: context.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: DSSpacing.sm),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

class FortuneResultFrame extends StatelessWidget {
  final Widget header;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Gradient? accentGradient;

  const FortuneResultFrame({
    super.key,
    required this.header,
    required this.child,
    this.margin,
    this.accentGradient,
  });

  @override
  Widget build(BuildContext context) {
    return FortuneCardSurface(
      margin: margin,
      padding: EdgeInsets.zero,
      backgroundColor: context.isDark
          ? context.colors.backgroundSecondary
          : context.colors.surface,
      showBorder: true,
      borderColor: context.colors.textPrimary,
      borderOpacity: 0.1,
      accentGradient: accentGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          child,
        ],
      ),
    );
  }
}

Color _defaultSurface(DSColorScheme colors, DSCardStyle style) {
  switch (style) {
    case DSCardStyle.outlined:
      return colors.surface;
    case DSCardStyle.glassmorphism:
      return colors.surface.withValues(alpha: 0.7);
    case DSCardStyle.elevated:
    case DSCardStyle.flat:
    case DSCardStyle.hanji:
    case DSCardStyle.premium:
    case DSCardStyle.gradient:
      return colors.surfaceSecondary;
  }
}

Color _toneColor(BuildContext context, FortuneCardTone tone) {
  final colors = context.colors;
  switch (tone) {
    case FortuneCardTone.neutral:
      return colors.textPrimary;
    case FortuneCardTone.accent:
      return colors.accent;
    case FortuneCardTone.success:
      return colors.success;
    case FortuneCardTone.warning:
      return colors.warning;
    case FortuneCardTone.danger:
      return colors.error;
    case FortuneCardTone.premium:
      return colors.accentSecondary;
  }
}
