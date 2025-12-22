import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../../core/theme/font_config.dart';

/// Calligraphy style score badge for biorhythm display
///
/// Design Philosophy:
/// - Traditional Korean calligraphy number style (붓글씨)
/// - Ink wash background with status-based coloring
/// - Compact display suitable for lists and summaries
/// - Optional Hanja status indicator
class BiorhythmScoreBadge extends StatelessWidget {
  final int score;
  final BiorhythmType type;
  final BadgeSize size;
  final bool showLabel;
  final bool showHanja;
  final bool animate;

  const BiorhythmScoreBadge({
    super.key,
    required this.score,
    required this.type,
    this.size = BadgeSize.medium,
    this.showLabel = true,
    this.showHanja = false,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (animate) {
      return _AnimatedScoreBadge(
        score: score,
        type: type,
        size: size,
        showLabel: showLabel,
        showHanja: showHanja,
        isDark: isDark,
      );
    }

    return _buildBadge(isDark);
  }

  Widget _buildBadge(bool isDark) {
    final dimensions = _getDimensions();
    final color = _getTypeColor(isDark);
    final bgColor = _getBackgroundColor(isDark);

    return Container(
      width: dimensions.width,
      height: dimensions.height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label (신체/감정/지적)
          if (showLabel)
            Text(
              _getTypeLabel(),
              style: TextStyle(
                color: color,
                fontSize: dimensions.labelSize,
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w500,
              ),
            ),

          // Score number (calligraphy style)
          Text(
            '$score',
            style: TextStyle(
              color: isDark
                  ? DSBiorhythmColors.hanjiCream
                  : DSBiorhythmColors.inkBleed,
              fontSize: dimensions.scoreSize,
              fontFamily: FontConfig.primary,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),

          // Unit (점)
          Text(
            '점',
            style: TextStyle(
              color: (isDark
                      ? DSBiorhythmColors.hanjiCream
                      : DSBiorhythmColors.inkBleed)
                  .withValues(alpha: 0.6),
              fontSize: dimensions.unitSize,
              fontFamily: FontConfig.primary,
            ),
          ),

          // Hanja status
          if (showHanja) ...[
            const SizedBox(height: 2),
            Text(
              DSBiorhythmColors.getStatusHanja(score),
              style: TextStyle(
                color: DSBiorhythmColors.getStatusColor(score),
                fontSize: dimensions.hanjaSize,
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BadgeDimensions _getDimensions() {
    switch (size) {
      case BadgeSize.small:
        return const _BadgeDimensions(
          width: 50,
          height: 65,
          borderRadius: 8,
          labelSize: 10,
          scoreSize: 20,
          unitSize: 9,
          hanjaSize: 8,
        );
      case BadgeSize.medium:
        return const _BadgeDimensions(
          width: 70,
          height: 90,
          borderRadius: 10,
          labelSize: 12,
          scoreSize: 28,
          unitSize: 11,
          hanjaSize: 10,
        );
      case BadgeSize.large:
        return const _BadgeDimensions(
          width: 90,
          height: 115,
          borderRadius: 12,
          labelSize: 14,
          scoreSize: 36,
          unitSize: 13,
          hanjaSize: 12,
        );
    }
  }

  Color _getTypeColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }

  Color _getBackgroundColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysicalBackground(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotionalBackground(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectualBackground(isDark);
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case BiorhythmType.physical:
        return '신체';
      case BiorhythmType.emotional:
        return '감정';
      case BiorhythmType.intellectual:
        return '지적';
    }
  }
}

/// Badge size variants
enum BadgeSize { small, medium, large }

/// Biorhythm type enumeration
enum BiorhythmType { physical, emotional, intellectual }

/// Badge dimension configuration
class _BadgeDimensions {
  final double width;
  final double height;
  final double borderRadius;
  final double labelSize;
  final double scoreSize;
  final double unitSize;
  final double hanjaSize;

  const _BadgeDimensions({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.labelSize,
    required this.scoreSize,
    required this.unitSize,
    required this.hanjaSize,
  });
}

/// Animated version of score badge
class _AnimatedScoreBadge extends StatefulWidget {
  final int score;
  final BiorhythmType type;
  final BadgeSize size;
  final bool showLabel;
  final bool showHanja;
  final bool isDark;

  const _AnimatedScoreBadge({
    required this.score,
    required this.type,
    required this.size,
    required this.showLabel,
    required this.showHanja,
    required this.isDark,
  });

  @override
  State<_AnimatedScoreBadge> createState() => _AnimatedScoreBadgeState();
}

class _AnimatedScoreBadgeState extends State<_AnimatedScoreBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: BiorhythmScoreBadge(
            score: _scoreAnimation.value,
            type: widget.type,
            size: widget.size,
            showLabel: widget.showLabel,
            showHanja: widget.showHanja,
            animate: false,
          ),
        );
      },
    );
  }
}

/// Horizontal score badge row for displaying all three rhythms
class BiorhythmScoreBadgeRow extends StatelessWidget {
  final int physical;
  final int emotional;
  final int intellectual;
  final BadgeSize size;
  final bool showLabels;
  final bool showHanja;
  final bool animate;
  final MainAxisAlignment alignment;

  const BiorhythmScoreBadgeRow({
    super.key,
    required this.physical,
    required this.emotional,
    required this.intellectual,
    this.size = BadgeSize.medium,
    this.showLabels = true,
    this.showHanja = false,
    this.animate = false,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        BiorhythmScoreBadge(
          score: physical,
          type: BiorhythmType.physical,
          size: size,
          showLabel: showLabels,
          showHanja: showHanja,
          animate: animate,
        ),
        BiorhythmScoreBadge(
          score: emotional,
          type: BiorhythmType.emotional,
          size: size,
          showLabel: showLabels,
          showHanja: showHanja,
          animate: animate,
        ),
        BiorhythmScoreBadge(
          score: intellectual,
          type: BiorhythmType.intellectual,
          size: size,
          showLabel: showLabels,
          showHanja: showHanja,
          animate: animate,
        ),
      ],
    );
  }
}

/// Compact inline score display (horizontal bar style)
class BiorhythmScoreInline extends StatelessWidget {
  final int score;
  final BiorhythmType type;
  final double width;

  const BiorhythmScoreInline({
    super.key,
    required this.score,
    required this.type,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getTypeColor(isDark);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTypeLabel(),
                style: TextStyle(
                  color: color,
                  fontSize: 12, // 예외: 바이오리듬 타입 라벨
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$score점',
                style: TextStyle(
                  color: isDark
                      ? DSBiorhythmColors.hanjiCream
                      : DSBiorhythmColors.inkBleed,
                  fontSize: 12, // 예외: 바이오리듬 점수 표시
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress bar with ink wash style
          CustomPaint(
            size: Size(width, 6),
            painter: _InkProgressBarPainter(
              progress: score / 100,
              color: color,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case BiorhythmType.physical:
        return '신체';
      case BiorhythmType.emotional:
        return '감정';
      case BiorhythmType.intellectual:
        return '지적';
    }
  }
}

/// Ink wash style progress bar painter
class _InkProgressBarPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _InkProgressBarPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = isDark
        ? DSBiorhythmColors.inkWashGuideDark
        : DSBiorhythmColors.inkWashGuide;

    // Background track
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      bgRect,
      Paint()..color = bgColor.withValues(alpha: 0.5),
    );

    // Progress fill with ink bleed effect
    final progressWidth = size.width * progress;
    if (progressWidth > 0) {
      // Blurred edge (ink bleed)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, progressWidth + 2, size.height),
          const Radius.circular(3),
        ),
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Main progress
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, progressWidth, size.height),
          const Radius.circular(3),
        ),
        Paint()..color = color.withValues(alpha: 0.8),
      );

      // Highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 1, progressWidth - 2, size.height / 3),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InkProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
