import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/design_system/design_system.dart';

// ═══════════════════════════════════════════════════════════════════
// Enhanced visual components for fortune body widgets
// Animated, infographic-style, reusable across all fortune types
// ═══════════════════════════════════════════════════════════════════

/// Animated circular score ring with count-up animation
class FortuneAnimatedScoreRing extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final String? label;
  final Color? overrideColor;

  const FortuneAnimatedScoreRing({
    super.key,
    required this.score,
    this.size = 100,
    this.strokeWidth = 8,
    this.label,
    this.overrideColor,
  });

  @override
  State<FortuneAnimatedScoreRing> createState() =>
      _FortuneAnimatedScoreRingState();
}

class _FortuneAnimatedScoreRingState extends State<FortuneAnimatedScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  late Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DSAnimation.resultReveal,
      vsync: this,
    );
    final clamped = widget.score.clamp(0, 100);
    _progressAnim = Tween<double>(begin: 0, end: clamped / 100).animate(
        CurvedAnimation(parent: _controller, curve: DSAnimation.claude));
    _countAnim = IntTween(begin: 0, end: clamped).animate(
        CurvedAnimation(parent: _controller, curve: DSAnimation.claude));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant FortuneAnimatedScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      final clamped = widget.score.clamp(0, 100);
      _progressAnim = Tween<double>(begin: 0, end: clamped / 100).animate(
          CurvedAnimation(parent: _controller, curve: DSAnimation.claude));
      _countAnim = IntTween(begin: 0, end: clamped).animate(
          CurvedAnimation(parent: _controller, curve: DSAnimation.claude));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _scoreColor(BuildContext context, int score) {
    if (widget.overrideColor != null) return widget.overrideColor!;
    final colors = context.colors;
    if (score >= 70) return colors.success;
    if (score >= 40) return colors.warning;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ringColor = _scoreColor(context, widget.score);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ScoreRingPainter(
                  progress: _progressAnim.value,
                  color: ringColor,
                  trackColor: colors.border.withValues(alpha: 0.15),
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_countAnim.value}',
                    style: context.typography.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ringColor,
                      height: 1.1,
                    ),
                  ),
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      trackColor != oldDelegate.trackColor;
}

/// Staggered fade-in + slide-up wrapper for sections
class FortuneStaggeredSection extends StatelessWidget {
  final int index;
  final Widget child;

  const FortuneStaggeredSection({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: DSAnimation.normal,
          curve: DSAnimation.claude,
          delay: Duration(
              milliseconds: index * DSAnimation.contentStagger.inMilliseconds),
        )
        .slideY(
          begin: 0.03,
          end: 0,
          duration: DSAnimation.normal,
          curve: DSAnimation.claude,
          delay: Duration(
              milliseconds: index * DSAnimation.contentStagger.inMilliseconds),
        );
  }
}

/// Animated progress bar with color gradient based on score
class FortuneAnimatedProgressBar extends StatelessWidget {
  final String label;
  final int score;
  final String? emoji;
  final int staggerIndex;
  final Color? overrideColor;
  final bool showPercentage;

  const FortuneAnimatedProgressBar({
    super.key,
    required this.label,
    required this.score,
    this.emoji,
    this.staggerIndex = 0,
    this.overrideColor,
    this.showPercentage = true,
  });

  Color _barColor(BuildContext context) {
    if (overrideColor != null) return overrideColor!;
    final colors = context.colors;
    if (score >= 70) return colors.success;
    if (score >= 40) return colors.warning;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = (score / 100).clamp(0.0, 1.0);
    final barColor = _barColor(context);
    final delay = Duration(
      milliseconds: staggerIndex * DSAnimation.contentStagger.inMilliseconds,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: DSSpacing.xxs),
          ],
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: context.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate().custom(
                          duration: DSAnimation.resultReveal,
                          curve: DSAnimation.claude,
                          delay: delay,
                          builder: (context, value, child) {
                            return SizedBox(
                              width: constraints.maxWidth * fraction * value,
                              child: child,
                            );
                          },
                        ),
                  );
                },
              ),
            ),
          ),
          if (showPercentage) ...[
            const SizedBox(width: DSSpacing.sm),
            SizedBox(
              width: 32,
              child: Text(
                '$score%',
                style: context.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 2-column infographic grid for key-value data
class FortuneInfoGraphGrid extends StatelessWidget {
  final List<FortuneInfoGraphItem> items;

  const FortuneInfoGraphGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final accentColor = item.accentColor ?? colors.accent;

        return FortuneStaggeredSection(
          index: i,
          child: Container(
            width: (MediaQuery.of(context).size.width - 120) / 2,
            padding: const EdgeInsets.all(DSSpacing.sm + 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.iconData != null)
                      Icon(item.iconData, size: 15, color: accentColor)
                    else
                      Text(item.icon ?? '',
                          style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: DSSpacing.xxs),
                    Expanded(
                      child: Text(
                        item.label,
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.xxs + 1),
                Text(
                  item.value,
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class FortuneInfoGraphItem {
  final String? icon;
  final IconData? iconData;
  final String label;
  final String value;
  final Color? accentColor;

  const FortuneInfoGraphItem({
    this.icon,
    this.iconData,
    required this.label,
    required this.value,
    this.accentColor,
  }) : assert(icon != null || iconData != null,
            'Either icon (emoji) or iconData must be provided');
}

/// Vertical timeline strip with colored dots and connector lines
class FortuneTimelineStrip extends StatelessWidget {
  final List<FortuneTimelineEntry> entries;

  const FortuneTimelineStrip({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return Column(
      children: entries.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isLast = i == entries.length - 1;
        final dotColor = _statusColor(context, item.status);

        return FortuneStaggeredSection(
          index: i,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline column: dot + line
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dotColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: colors.border.withValues(alpha: 0.25),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : DSSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.time,
                              style: context.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: dotColor,
                              ),
                            ),
                            const SizedBox(width: DSSpacing.xs),
                            Expanded(
                              child: Text(
                                item.label,
                                style: context.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (item.description != null) ...[
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            item.description!,
                            style: context.bodySmall.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  Color _statusColor(BuildContext context, TimelineStatus status) {
    final colors = context.colors;
    switch (status) {
      case TimelineStatus.good:
        return colors.success;
      case TimelineStatus.caution:
        return colors.warning;
      case TimelineStatus.bad:
        return colors.error;
      case TimelineStatus.neutral:
        return colors.textSecondary;
    }
  }
}

enum TimelineStatus { good, caution, bad, neutral }

class FortuneTimelineEntry {
  final String time;
  final String label;
  final TimelineStatus status;
  final String? description;

  const FortuneTimelineEntry({
    required this.time,
    required this.label,
    this.status = TimelineStatus.neutral,
    this.description,
  });
}

/// Comparison card with left/right split and color tints
class FortuneComparisonCard extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final String leftEmoji;
  final String rightEmoji;
  final List<String> leftItems;
  final List<String> rightItems;
  final Color? leftColor;
  final Color? rightColor;

  const FortuneComparisonCard({
    super.key,
    required this.leftTitle,
    required this.rightTitle,
    this.leftEmoji = '✅',
    this.rightEmoji = '⚠️',
    required this.leftItems,
    required this.rightItems,
    this.leftColor,
    this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final left = leftColor ?? colors.success;
    final right = rightColor ?? colors.warning;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: left.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DSRadius.lg),
                  bottomLeft: Radius.circular(DSRadius.lg),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(leftEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: DSSpacing.xxs),
                      Expanded(
                        child: Text(
                          leftTitle,
                          style: context.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: left,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  ...leftItems.take(3).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
                          child: Text(
                            '• $item',
                            style: context.bodySmall.copyWith(height: 1.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            color: colors.border.withValues(alpha: 0.2),
          ),
          // Right side
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: right.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(DSRadius.lg),
                  bottomRight: Radius.circular(DSRadius.lg),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(rightEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: DSSpacing.xxs),
                      Expanded(
                        child: Text(
                          rightTitle,
                          style: context.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  ...rightItems.take(3).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
                          child: Text(
                            '• $item',
                            style: context.bodySmall.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero gradient background with score ring + summary text
class FortuneHeroGradient extends StatelessWidget {
  final int? score;
  final String? scoreLabel;
  final String summary;
  final String? eyebrow;
  final Widget? trailing;

  const FortuneHeroGradient({
    super.key,
    this.score,
    this.scoreLabel,
    required this.summary,
    this.eyebrow,
    this.trailing,
  });

  Color _moodColor(BuildContext context, int score) {
    final colors = context.colors;
    if (score >= 80) return const Color(0xFFD4A574); // warm gold
    if (score >= 60) return colors.success;
    if (score >= 40) return colors.warning;
    return const Color(0xFF6B8EC4); // calm blue
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final moodColor =
        score != null ? _moodColor(context, score!) : colors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            moodColor.withValues(alpha: context.isDark ? 0.15 : 0.08),
            colors.surface,
          ],
        ),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              style: context.labelSmall.copyWith(
                color: moodColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (score != null) ...[
            FortuneAnimatedScoreRing(
              score: score!,
              size: 90,
              strokeWidth: 7,
              label: scoreLabel,
              overrideColor: moodColor,
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          Text(
            summary,
            textAlign: TextAlign.center,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(height: DSSpacing.sm),
            trailing!,
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: DSAnimation.contentReveal, curve: DSAnimation.claude)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          duration: DSAnimation.contentReveal,
          curve: DSAnimation.claude,
        );
  }
}

/// Mini category score card (for daily fortune categories like love/wealth/health/career)
class FortuneCategoryScoreGrid extends StatelessWidget {
  final List<FortuneCategoryItem> categories;

  const FortuneCategoryScoreGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: categories.asMap().entries.map((entry) {
        final i = entry.key;
        final cat = entry.value;
        final statusColor = _statusToColor(context, cat.status);

        return FortuneStaggeredSection(
          index: i + 2, // offset for hero animation
          child: Container(
            width: (MediaQuery.of(context).size.width - 120) / 2,
            padding: const EdgeInsets.all(DSSpacing.sm + 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.label,
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        cat.value,
                        style: context.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  Color _statusToColor(BuildContext context, CategoryStatus status) {
    final colors = context.colors;
    switch (status) {
      case CategoryStatus.great:
        return colors.success;
      case CategoryStatus.good:
        return const Color(0xFF3B82F6); // blue
      case CategoryStatus.normal:
        return colors.textSecondary;
      case CategoryStatus.caution:
        return colors.warning;
    }
  }
}

enum CategoryStatus { great, good, normal, caution }

class FortuneCategoryItem {
  final String emoji;
  final String label;
  final String value;
  final CategoryStatus status;

  const FortuneCategoryItem({
    required this.emoji,
    required this.label,
    required this.value,
    this.status = CategoryStatus.normal,
  });
}
