import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class GlassEffects {
  static const double defaultBlur = 10.0;
  static const double heavyBlur = 20.0;
  static const double lightBlur = 5.0;
  static const double ultraBlur = 30.0;

  static LinearGradient lightGradient({double opacity = 0.6}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight),
        colors: [
        AppColors.textPrimaryDark.withValues(alpha: opacity),
        AppColors.textPrimaryDark.withValues(alpha: opacity * 0.5),
      ])
  }

  static LinearGradient darkGradient({double opacity = 0.1}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight),
        colors: [
        AppColors.textPrimaryDark.withValues(alpha: opacity),
        AppColors.textPrimaryDark.withValues(alpha: opacity * 0.5),
      ]
    );
  }

  static LinearGradient coloredGradient(
    {
    required Color color,
    double opacity = 0.3,
  )}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight),
        colors: [
        color.withValues(alpha: opacity),
        color.withValues(alpha: opacity * 0.5),
      ])
  }

  static LinearGradient multiColorGradient(
    {
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  )}) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors),
        stops: stops
    );
  }

  static List<BoxShadow> glassShadow(
    {
    Color? color,
    double elevation = 8,
    double spread = 0,
  )}) {
    return [
      BoxShadow(
        color: (color ?? AppColors.textPrimary).withValues(alph,
      a: 0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
        spreadRadius: spread)
      BoxShadow(
        color: (color ?? AppColors.textPrimary).withValues(alph,
      a: 0.05),
        blurRadius: elevation,
        offset: Offset(0, elevation * 0.5),
        spreadRadius: spread * 0.5)
    ];
  }

  static Border glassBorder(
    {
    Color? color,
    double width = 1.5,
    double opacity = 0.2,
  )}) {
    return Border.all(
      color: (color ?? AppColors.textPrimaryDark).withValues(alph,
      a: opacity),
      width: width
    );
  }

  static ImageFilter glassBlur({double blur = defaultBlur}) {
    return ImageFilter.blur(sigmaX: blur, sigmaY: blur);
  }
}

class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Duration animationDuration;
  final List<Color> liquidColors;

  const LiquidGlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius)
    this.animationDuration = const Duration(seconds: 3),
    this.liquidColors = const [
      Color(0xFF7C3AED),
      AppColors.primary,
      Color(0xFF06B6D4),
    ]
  }) : super(key: key);

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration)
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0)).animate(CurvedAnimation(,
      parent: _controller),
        curve: Curves.easeInOut)
    )
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation),
        builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          child: ClipRRect(,
      borderRadius: widget.borderRadius ?? AppDimensions.radiusXLarge),
        child: BackdropFilter(,
      filter: GlassEffects.glassBlur(bl,
      ur: 15),
              child: Container(,
      decoration: BoxDecoration(,
      gradient: LinearGradient(,
      begin: Alignment(_animation.value - 1, -1),
                    end: Alignment(1 - _animation.value, 1),
                    colors: widget.liquidColors.map((color) => 
                      color.withValues(alpha: 0.1 + (_animation.value * 0.1))
                    ).toList())
                  borderRadius: widget.borderRadius ?? AppDimensions.radiusXLarge,
                  border: GlassEffects.glassBorder(,
      opacity: 0.2 + (_animation.value * 0.1),
      boxShadow: GlassEffects.glassShadow(,
      elevation: 10 + (_animation.value * 5))),
      padding: widget.padding,
                child: widget.child)))))))
      }
    );
  }
}

class ShimmerGlass extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color shimmerColor;

  const ShimmerGlass(
    {
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.shimmerColor = AppColors.textPrimaryDark,
  )}) : super(key: key);

  @override
  State<ShimmerGlass> createState() => _ShimmerGlassState();
}

class _ShimmerGlassState extends State<ShimmerGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this),
        duration: const Duration(second,
      s: 2)))..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0)).animate(CurvedAnimation(,
      parent: _controller),
        curve: Curves.linear)
    )
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation),
        builder: (context, child) {
        return ClipRRect(
          borderRadius: widget.borderRadius ?? AppDimensions.radiusXLarge,
          child: Stack(,
      children: [
              widget.child)
              Positioned.fill(
                child: Container(,
      decoration: BoxDecoration(,
      gradient: LinearGradient(,
      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value, 0),
                      colors: [
                        Colors.transparent,
                        widget.shimmerColor.withValues(alpha: 0.1),
                        widget.shimmerColor.withValues(alpha: 0.2),
                        widget.shimmerColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ]
                      stops: const [0.0, 0.35, 0.5, 0.65, 1.0])))))))
            ])))
      }
    );
  }
}