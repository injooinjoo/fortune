import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/ds_fortune_colors.dart';
import '../../tokens/ds_love_colors.dart';
import '../../tokens/ds_luck_colors.dart';
import '../../../theme/font_config.dart';

/// Seal stamp shape styles
enum SealStampShape {
  circle, // 원형 낙관
  square, // 정사각 낙관
  rectangle, // 장방형 낙관
  oval, // 타원형 낙관
  organic, // 불규칙 (손으로 찍은 느낌)
}

/// Seal stamp color schemes
enum SealStampColorScheme {
  vermilion, // 다홍색 (가장 전통적)
  gold, // 금색
  blue, // 청색
  black, // 먹색
  love, // 연지색
  custom, // 커스텀
}

/// Seal stamp size presets
enum SealStampSize {
  small, // 28x28
  medium, // 44x44
  large, // 64x64
  xlarge, // 88x88
}

/// Korean Traditional Seal Stamp (낙관) Widget
///
/// Design Philosophy:
/// - Traditional Korean seal stamp aesthetics
/// - Hand-stamped imperfect edges (organic style)
/// - Support for 1-4 characters (Hanja/Korean)
/// - Multiple color schemes following Obangsaek
///
/// Usage:
/// ```dart
/// SealStampWidget(
///   text: '吉',
///   shape: SealStampShape.circle,
///   colorScheme: SealStampColorScheme.vermilion,
///   size: SealStampSize.medium,
/// )
/// ```
class SealStampWidget extends StatefulWidget {
  final String text;
  final SealStampShape shape;
  final SealStampColorScheme colorScheme;
  final SealStampSize size;
  final Color? customColor;
  final bool animated; // Stamp animation on appear
  final bool showInkBleed; // Ink spreading effect
  final VoidCallback? onTap;
  final double? customSize;
  final double borderWidth;
  final bool filled; // Fill background vs outline only

  const SealStampWidget({
    super.key,
    required this.text,
    this.shape = SealStampShape.circle,
    this.colorScheme = SealStampColorScheme.vermilion,
    this.size = SealStampSize.medium,
    this.customColor,
    this.animated = false,
    this.showInkBleed = false,
    this.onTap,
    this.customSize,
    this.borderWidth = 2,
    this.filled = false,
  });

  @override
  State<SealStampWidget> createState() => _SealStampWidgetState();
}

class _SealStampWidgetState extends State<SealStampWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // TweenSequence는 t가 정확히 0.0~1.0 범위여야 함
    // CurvedAnimation을 제거하고 AnimationController를 직접 사용
    // TweenSequence 자체가 0→1.2→1.0 bounce 효과를 제공함
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 40,
      ),
    ]).animate(_animationController); // CurvedAnimation 제거 - 직접 연결

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.animated) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _animationController.forward();
      });
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stampColor = _getColor(isDark);
    final stampSize = widget.customSize ?? _getSize();

    Widget stamp = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Transform.rotate(
          angle: _rotationAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildStamp(stampColor, stampSize, isDark),
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      stamp = GestureDetector(
        onTap: widget.onTap,
        child: stamp,
      );
    }

    return stamp;
  }

  Widget _buildStamp(Color color, double size, bool isDark) {
    if (widget.shape == SealStampShape.organic) {
      return _buildOrganicStamp(color, size);
    }

    return CustomPaint(
      painter: _SealStampPainter(
        text: widget.text,
        color: color,
        shape: widget.shape,
        borderWidth: widget.borderWidth,
        showInkBleed: widget.showInkBleed,
        filled: widget.filled,
      ),
      size: Size(
        widget.shape == SealStampShape.rectangle ? size * 1.5 : size,
        widget.shape == SealStampShape.oval ? size * 0.7 : size,
      ),
    );
  }

  Widget _buildOrganicStamp(Color color, double size) {
    return CustomPaint(
      painter: _OrganicSealPainter(
        text: widget.text,
        color: color,
        borderWidth: widget.borderWidth,
        showInkBleed: widget.showInkBleed,
        filled: widget.filled,
      ),
      size: Size(size, size),
    );
  }

  Color _getColor(bool isDark) {
    if (widget.customColor != null) return widget.customColor!;

    switch (widget.colorScheme) {
      case SealStampColorScheme.vermilion:
        return DSFortuneColors.sealVermilion;
      case SealStampColorScheme.gold:
        return DSLuckColors.getGold(isDark);
      case SealStampColorScheme.blue:
        return DSFortuneColors.sealBlue;
      case SealStampColorScheme.black:
        return DSFortuneColors.inkBlack;
      case SealStampColorScheme.love:
        return DSLoveColors.rougePink;
      case SealStampColorScheme.custom:
        return widget.customColor ?? DSFortuneColors.sealVermilion;
    }
  }

  double _getSize() {
    switch (widget.size) {
      case SealStampSize.small:
        return 28;
      case SealStampSize.medium:
        return 44;
      case SealStampSize.large:
        return 64;
      case SealStampSize.xlarge:
        return 88;
    }
  }
}

/// Custom painter for regular seal stamps
class _SealStampPainter extends CustomPainter {
  final String text;
  final Color color;
  final SealStampShape shape;
  final double borderWidth;
  final bool showInkBleed;
  final bool filled;

  _SealStampPainter({
    required this.text,
    required this.color,
    required this.shape,
    required this.borderWidth,
    required this.showInkBleed,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw ink bleed effect first (if enabled)
    if (showInkBleed) {
      _drawInkBleed(canvas, size, center);
    }

    // Draw shape background/border
    final shapePaint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    switch (shape) {
      case SealStampShape.circle:
        canvas.drawCircle(
          center,
          (size.width / 2) - borderWidth,
          shapePaint,
        );
        break;
      case SealStampShape.square:
        final rect = Rect.fromCenter(
          center: center,
          width: size.width - borderWidth * 2,
          height: size.height - borderWidth * 2,
        );
        canvas.drawRect(rect, shapePaint);
        break;
      case SealStampShape.rectangle:
        final rect = Rect.fromCenter(
          center: center,
          width: size.width - borderWidth * 2,
          height: size.height - borderWidth * 2,
        );
        canvas.drawRect(rect, shapePaint);
        break;
      case SealStampShape.oval:
        final rect = Rect.fromCenter(
          center: center,
          width: size.width - borderWidth * 2,
          height: size.height - borderWidth * 2,
        );
        canvas.drawOval(rect, shapePaint);
        break;
      case SealStampShape.organic:
        // Handled by _OrganicSealPainter
        break;
    }

    // Draw text
    _drawText(canvas, size, center);
  }

  void _drawInkBleed(Canvas canvas, Size size, Offset center) {
    final random = math.Random(text.hashCode);
    final bleedPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Draw several small bleed spots around the stamp
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + random.nextDouble() * 0.3;
      final distance = (size.width / 2) + random.nextDouble() * 4;
      final spotCenter = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      final spotRadius = 2.0 + random.nextDouble() * 3;
      canvas.drawCircle(spotCenter, spotRadius, bleedPaint);
    }
  }

  void _drawText(Canvas canvas, Size size, Offset center) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: FontConfig.primary,
        fontSize: _calculateFontSize(size),
        fontWeight: FontWeight.w700,
        color: filled ? Colors.white : color,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  double _calculateFontSize(Size size) {
    final baseSize = math.min(size.width, size.height);
    if (text.length == 1) {
      return baseSize * 0.5;
    } else if (text.length == 2) {
      return baseSize * 0.35;
    } else if (text.length <= 4) {
      return baseSize * 0.25;
    }
    return baseSize * 0.2;
  }

  @override
  bool shouldRepaint(covariant _SealStampPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.color != color ||
        oldDelegate.shape != shape ||
        oldDelegate.filled != filled;
  }
}

/// Custom painter for organic (hand-stamped) seal
class _OrganicSealPainter extends CustomPainter {
  final String text;
  final Color color;
  final double borderWidth;
  final bool showInkBleed;
  final bool filled;

  _OrganicSealPainter({
    required this.text,
    required this.color,
    required this.borderWidth,
    required this.showInkBleed,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(text.hashCode);

    // Draw ink bleed
    if (showInkBleed) {
      _drawInkBleed(canvas, size, center, random);
    }

    // Draw organic border
    final path = _createOrganicPath(size, center, random);
    final borderPaint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, borderPaint);

    // Add some "imperfect" ink spots along the border
    _drawImperfections(canvas, path, color, random);

    // Draw text
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: FontConfig.primary,
        fontSize: _calculateFontSize(size),
        fontWeight: FontWeight.w700,
        color: filled ? Colors.white : color,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  Path _createOrganicPath(Size size, Offset center, math.Random random) {
    final path = Path();
    final radius = (size.width / 2) - borderWidth;
    const points = 24;

    for (int i = 0; i < points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final variation = 1 + (random.nextDouble() - 0.5) * 0.15;
      final r = radius * variation;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Use quadratic bezier for smooth curves
        final prevAngle = ((i - 0.5) / points) * 2 * math.pi;
        final controlVariation = 1 + (random.nextDouble() - 0.5) * 0.1;
        final controlR = radius * controlVariation;
        final controlX = center.dx + math.cos(prevAngle) * controlR;
        final controlY = center.dy + math.sin(prevAngle) * controlR;
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    path.close();
    return path;
  }

  void _drawInkBleed(
      Canvas canvas, Size size, Offset center, math.Random random) {
    final bleedPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Random bleed spots
    for (int i = 0; i < 12; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = (size.width / 2) * (0.8 + random.nextDouble() * 0.4);
      final spotCenter = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      final spotRadius = 1.5 + random.nextDouble() * 4;
      canvas.drawCircle(spotCenter, spotRadius, bleedPaint);
    }
  }

  void _drawImperfections(
      Canvas canvas, Path borderPath, Color color, math.Random random) {
    final spotPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Add small ink spots along the path
    final pathMetrics = borderPath.computeMetrics();
    for (final metric in pathMetrics) {
      final length = metric.length;
      for (int i = 0; i < 8; i++) {
        final distance = random.nextDouble() * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final spotSize = 0.5 + random.nextDouble() * 1.5;
          if (random.nextDouble() > 0.5) {
            canvas.drawCircle(tangent.position, spotSize, spotPaint);
          }
        }
      }
    }
  }

  double _calculateFontSize(Size size) {
    final baseSize = math.min(size.width, size.height);
    if (text.length == 1) {
      return baseSize * 0.45;
    } else if (text.length == 2) {
      return baseSize * 0.32;
    } else if (text.length <= 4) {
      return baseSize * 0.22;
    }
    return baseSize * 0.18;
  }

  @override
  bool shouldRepaint(covariant _OrganicSealPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.color != color ||
        oldDelegate.filled != filled;
  }
}

/// Fortune level seal - predefined seals for fortune levels
class FortuneLevelSeal extends StatelessWidget {
  final int score; // 0-100
  final SealStampSize size;
  final bool animated;
  final VoidCallback? onTap;

  const FortuneLevelSeal({
    super.key,
    required this.score,
    this.size = SealStampSize.medium,
    this.animated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hanja = DSLuckColors.getLevelHanja(score);
    final color = DSLuckColors.getLevelColor(score);

    return SealStampWidget(
      text: hanja,
      shape: SealStampShape.circle,
      colorScheme: SealStampColorScheme.custom,
      customColor: color,
      size: size,
      animated: animated,
      showInkBleed: true,
      onTap: onTap,
    );
  }
}

/// Compatibility seal - for love/compatibility results
class CompatibilitySeal extends StatelessWidget {
  final int score; // 0-100
  final SealStampSize size;
  final bool animated;
  final VoidCallback? onTap;

  const CompatibilitySeal({
    super.key,
    required this.score,
    this.size = SealStampSize.medium,
    this.animated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hanja = DSLoveColors.getCompatibilityHanja(score);
    final color = DSLoveColors.getCompatibilityColor(score);

    return SealStampWidget(
      text: hanja,
      shape: SealStampShape.circle,
      colorScheme: SealStampColorScheme.custom,
      customColor: color,
      size: size,
      animated: animated,
      showInkBleed: true,
      onTap: onTap,
    );
  }
}

/// Element seal - for Five Elements (오행)
class ElementSeal extends StatelessWidget {
  final String element; // 화/목/수/금/토 or fire/wood/water/metal/earth
  final SealStampSize size;
  final bool animated;
  final VoidCallback? onTap;

  const ElementSeal({
    super.key,
    required this.element,
    this.size = SealStampSize.medium,
    this.animated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hanja = _getHanja();
    final color = DSFortuneColors.getElementColor(element);

    return SealStampWidget(
      text: hanja,
      shape: SealStampShape.square,
      colorScheme: SealStampColorScheme.custom,
      customColor: color,
      size: size,
      animated: animated,
      showInkBleed: true,
      onTap: onTap,
    );
  }

  String _getHanja() {
    switch (element.toLowerCase()) {
      case '화':
      case 'fire':
        return '火';
      case '목':
      case 'wood':
        return '木';
      case '수':
      case 'water':
        return '水';
      case '금':
      case 'metal':
        return '金';
      case '토':
      case 'earth':
        return '土';
      default:
        return element.substring(0, 1);
    }
  }
}

/// Day seal - for daily fortune indicators
class DaySeal extends StatelessWidget {
  final String dayType; // 길 (lucky) or 흉 (unlucky)
  final SealStampSize size;
  final bool animated;

  const DaySeal({
    super.key,
    required this.dayType,
    this.size = SealStampSize.small,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLucky = dayType == '길' || dayType.toLowerCase() == 'lucky';

    return SealStampWidget(
      text: isLucky ? '吉' : '凶',
      shape: SealStampShape.organic,
      colorScheme: isLucky
          ? SealStampColorScheme.vermilion
          : SealStampColorScheme.black,
      size: size,
      animated: animated,
      showInkBleed: true,
    );
  }
}
