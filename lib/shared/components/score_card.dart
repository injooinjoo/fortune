import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'dart:math' as math;

/// Korean Traditional style score/metric display card
/// Similar to traditional fortune scoring displays
class ScoreCard extends StatelessWidget {
  final String title;
  final String score;
  final String? subtitle;
  final String? description;
  final double? progress; // 0.0 ~ 1.0
  final Color? progressColor;
  final Widget? icon;
  final VoidCallback? onTap;
  final List<Widget>? additionalInfo;

  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    this.subtitle,
    this.description,
    this.progress,
    this.progressColor,
    this.icon,
    this.onTap,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final brightness = Theme.of(context).brightness;

    final Widget content = Container(
      decoration: DSShadows.getInkWashDecoration(
        brightness,
        backgroundColor: colors.surface,
        borderRadius: DSRadius.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title area
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg,
              DSSpacing.lg,
              DSSpacing.lg,
              DSSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (icon != null) icon!,
              ],
            ),
          ),

          // Central score display area
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
            ),
            child: progress != null
                ? _buildProgressScore(context)
                : _buildSimpleScore(context),
          ),

          // Description area
          if (description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.lg,
                DSSpacing.md,
                DSSpacing.lg,
                DSSpacing.lg,
              ),
              child: Text(
                description!,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Additional info area
          if (additionalInfo != null && additionalInfo!.isNotEmpty) ...[
            Divider(
              height: 1,
              color: colors.divider,
            ),
            Padding(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Column(
                children: additionalInfo!,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: InkWell(
          onTap: () {
            DSHaptics.light();
            onTap!();
          },
          borderRadius: BorderRadius.circular(DSRadius.lg),
          splashColor: colors.accentSecondary.withValues(alpha: 0.1),
          highlightColor: colors.accentSecondary.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildSimpleScore(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: [
        Text(
          score,
          style: typography.displayLarge.copyWith(
            color: colors.textPrimary,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: DSSpacing.xs),
            child: Text(
              subtitle!,
              style: typography.bodySmall.copyWith(
                color: progressColor ?? colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressScore(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final color = progressColor ?? colors.accent;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: const Size(200, 200),
            painter: _CircleProgressPainter(
              progress: 1.0,
              color: colors.surfaceSecondary,
              strokeWidth: 12,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: const Size(200, 200),
            painter: _CircleProgressPainter(
              progress: progress!,
              color: color,
              strokeWidth: 12,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score,
                style: typography.displayMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: typography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Small score card (for lists)
class ScoreCardMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final Widget? icon;

  const ScoreCardMini({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: DSSpacing.xs),
              ],
              Text(
                label,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            value,
            style: typography.headingSmall.copyWith(
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
