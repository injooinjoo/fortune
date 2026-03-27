import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

class PaperRuntimeBackground extends StatelessWidget {
  final Widget child;
  final Alignment ringAlignment;
  final EdgeInsetsGeometry padding;
  final bool applySafeArea;
  final bool showRings;
  final int ringCount;

  const PaperRuntimeBackground({
    super.key,
    required this.child,
    this.ringAlignment = Alignment.topCenter,
    this.padding = EdgeInsets.zero,
    this.applySafeArea = true,
    this.showRings = true,
    this.ringCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseSize =
            math.max(constraints.maxWidth, constraints.maxHeight) * 0.92;
        final content = Padding(
          padding: padding,
          child: child,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background,
                    colors.background,
                    colors.backgroundSecondary.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Align(
              alignment: ringAlignment,
              child: IgnorePointer(
                child: Container(
                  width: baseSize * 0.56,
                  height: baseSize * 0.56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.textPrimary.withValues(alpha: 0.05),
                        colors.textPrimary.withValues(alpha: 0.018),
                        colors.textPrimary.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.46, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            if (showRings)
              for (var index = 0; index < ringCount; index++)
                Align(
                  alignment: ringAlignment,
                  child: IgnorePointer(
                    child: Container(
                      width: baseSize * (0.48 + (index * 0.23)),
                      height: baseSize * (0.48 + (index * 0.23)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.border.withValues(
                            alpha: index == 0 ? 0.30 : 0.18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            if (applySafeArea) SafeArea(child: content) else content,
          ],
        );
      },
    );
  }
}

class PaperRuntimePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final bool elevated;

  const PaperRuntimePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DSSpacing.lg),
    this.width,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(DSRadius.xxl),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.76),
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 32,
                  offset: const Offset(0, 20),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class PaperRuntimeExpandablePanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;

  const PaperRuntimeExpandablePanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PaperRuntimePanel(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.sm,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: DSSpacing.md),
          iconColor: colors.textSecondary,
          collapsedIconColor: colors.textTertiary,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            title,
            style: context.heading4.copyWith(
              color: colors.textPrimary,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: DSSpacing.xs),
                  child: Text(
                    subtitle!,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
          children: [child],
        ),
      ),
    );
  }
}

class PaperRuntimePill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool emphasize;

  const PaperRuntimePill({
    super.key,
    required this.label,
    this.icon,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: emphasize
            ? colors.selectionBackground.withValues(alpha: 0.92)
            : colors.backgroundSecondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: emphasize
              ? colors.selectionBorder.withValues(alpha: 0.9)
              : colors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color:
                  emphasize ? colors.selectionForeground : colors.textSecondary,
            ),
            const SizedBox(width: DSSpacing.xs),
          ],
          Text(
            label,
            style: context.labelMedium.copyWith(
              color:
                  emphasize ? colors.selectionForeground : colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
