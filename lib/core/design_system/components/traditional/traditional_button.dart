import 'package:flutter/material.dart';
import '../../tokens/ds_fortune_colors.dart';
import '../../tokens/ds_love_colors.dart';
import '../../tokens/ds_luck_colors.dart';

/// Korean Traditional Button Styles
///
/// Design Philosophy:
/// - standard: 한지 배경 + 먹색 테두리
/// - filled: 오방색 배경 + 밝은 텍스트
/// - outlined: 투명 배경 + 컬러 테두리
/// - seal: 낙관 스타일 원형 버튼
/// - ink: 수묵화 스타일 브러시 스트로크
enum TraditionalButtonStyle {
  standard,
  filled,
  outlined,
  seal,
  ink,
}

/// Color scheme for traditional buttons
enum TraditionalButtonColorScheme {
  fortune, // 자주색 (mystical purple)
  gold, // 황금색 (gold)
  vermilion, // 다홍색 (lucky red)
  love, // 연지색 (rouge pink)
  ink, // 먹색 (ink black)
  earth, // 토색 (warm brown)
}

/// Korean Traditional Style Button Component
///
/// Usage:
/// ```dart
/// TraditionalButton(
///   text: '운세 보기',
///   onPressed: () {},
///   style: TraditionalButtonStyle.filled,
///   colorScheme: TraditionalButtonColorScheme.fortune,
/// )
/// ```
class TraditionalButton extends StatefulWidget {
  final String text;
  final String? hanja; // Optional Hanja text (shown smaller)
  final VoidCallback? onPressed;
  final TraditionalButtonStyle style;
  final TraditionalButtonColorScheme colorScheme;
  final bool isLoading;
  final bool isExpanded; // Full width
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final EdgeInsets? padding;

  const TraditionalButton({
    super.key,
    required this.text,
    this.hanja,
    this.onPressed,
    this.style = TraditionalButtonStyle.standard,
    this.colorScheme = TraditionalButtonColorScheme.fortune,
    this.isLoading = false,
    this.isExpanded = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 52,
    this.padding,
  });

  @override
  State<TraditionalButton> createState() => _TraditionalButtonState();
}

class _TraditionalButtonState extends State<TraditionalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: isDisabled ? null : (_) => _onTapDown(),
          onTapUp: isDisabled ? null : (_) => _onTapUp(),
          onTapCancel: isDisabled ? null : _onTapCancel,
          onTap: isDisabled ? null : widget.onPressed,
          child: _buildButton(isDark, colors, isDisabled),
        ),
      ),
    );
  }

  Widget _buildButton(
      bool isDark, _TraditionalButtonColors colors, bool isDisabled) {
    switch (widget.style) {
      case TraditionalButtonStyle.standard:
        return _buildStandardButton(isDark, colors, isDisabled);
      case TraditionalButtonStyle.filled:
        return _buildFilledButton(isDark, colors, isDisabled);
      case TraditionalButtonStyle.outlined:
        return _buildOutlinedButton(isDark, colors, isDisabled);
      case TraditionalButtonStyle.seal:
        return _buildSealButton(isDark, colors, isDisabled);
      case TraditionalButtonStyle.ink:
        return _buildInkButton(isDark, colors, isDisabled);
    }
  }

  /// Standard button - Hanji background with ink border
  Widget _buildStandardButton(
      bool isDark, _TraditionalButtonColors colors, bool isDisabled) {
    final hanjiColor =
        isDark ? DSFortuneColors.hanjiDark : DSFortuneColors.hanjiCream;

    return Container(
      width: widget.isExpanded ? double.infinity : widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDisabled ? hanjiColor.withValues(alpha: 0.5) : hanjiColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDisabled
              ? colors.primary.withValues(alpha: 0.3)
              : colors.primary.withValues(alpha: _isPressed ? 1.0 : 0.6),
          width: _isPressed ? 2 : 1,
        ),
        boxShadow: _isPressed
            ? null
            : [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding:
          widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _buildContent(colors.primary, isDisabled),
    );
  }

  /// Filled button - Colored background
  Widget _buildFilledButton(
      bool isDark, _TraditionalButtonColors colors, bool isDisabled) {
    return Container(
      width: widget.isExpanded ? double.infinity : widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primaryDark,
                ],
              ),
        color: isDisabled ? colors.primary.withValues(alpha: 0.3) : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDisabled || _isPressed
            ? null
            : [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding:
          widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _buildContent(
        isDisabled
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.95),
        isDisabled,
      ),
    );
  }

  /// Outlined button - Transparent with colored border
  Widget _buildOutlinedButton(
      bool isDark, _TraditionalButtonColors colors, bool isDisabled) {
    return Container(
      width: widget.isExpanded ? double.infinity : widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _isPressed
            ? colors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDisabled
              ? colors.primary.withValues(alpha: 0.3)
              : colors.primary,
          width: _isPressed ? 2 : 1.5,
        ),
      ),
      padding:
          widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _buildContent(
        isDisabled ? colors.primary.withValues(alpha: 0.3) : colors.primary,
        isDisabled,
      ),
    );
  }

  /// Seal button - Circular stamp style
  Widget _buildSealButton(
      bool isDark, _TraditionalButtonColors colors, bool isDisabled) {
    final size = widget.height;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDisabled
            ? colors.primary.withValues(alpha: 0.1)
            : colors.primary.withValues(alpha: _isPressed ? 0.2 : 0.1),
        border: Border.all(
          color: isDisabled
              ? colors.primary.withValues(alpha: 0.3)
              : colors.primary,
          width: _isPressed ? 3 : 2,
        ),
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              )
            : Text(
                widget.hanja ?? widget.text.substring(0, 1),
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w700,
                  color: isDisabled
                      ? colors.primary.withValues(alpha: 0.3)
                      : colors.primary,
                ),
              ),
      ),
    );
  }

  /// Ink button - Brush stroke style
  Widget _buildInkButton(
      bool isDark, _TraditionalButtonColors colors, bool isDisabled) {
    return Container(
      width: widget.isExpanded ? double.infinity : widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _InkBrushButtonPainter(
          color: isDisabled
              ? colors.primary.withValues(alpha: 0.3)
              : colors.primary,
          isPressed: _isPressed,
          isDark: isDark,
        ),
        child: Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: _buildContent(
            isDisabled
                ? colors.primary.withValues(alpha: 0.3)
                : colors.primary,
            isDisabled,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor, bool isDisabled) {
    if (widget.isLoading && widget.style != TraditionalButtonStyle.seal) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(textColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'GowunBatang',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            if (widget.hanja != null && widget.style != TraditionalButtonStyle.seal) ...[
              const SizedBox(height: 2),
              Text(
                widget.hanja!,
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, size: 18, color: textColor),
        ],
      ],
    );
  }

  _TraditionalButtonColors _getColors(bool isDark) {
    switch (widget.colorScheme) {
      case TraditionalButtonColorScheme.fortune:
        return _TraditionalButtonColors(
          primary: DSFortuneColors.getPrimary(isDark),
          primaryDark: DSFortuneColors.mysticalPurpleDark,
        );
      case TraditionalButtonColorScheme.gold:
        return _TraditionalButtonColors(
          primary: DSLuckColors.getGold(isDark),
          primaryDark: DSLuckColors.fortuneGoldDark,
        );
      case TraditionalButtonColorScheme.vermilion:
        return _TraditionalButtonColors(
          primary: DSLuckColors.getLucky(isDark),
          primaryDark: DSLuckColors.luckyRedDark,
        );
      case TraditionalButtonColorScheme.love:
        return _TraditionalButtonColors(
          primary: DSLoveColors.getPrimary(isDark),
          primaryDark: DSLoveColors.rougePinkDark,
        );
      case TraditionalButtonColorScheme.ink:
        return _TraditionalButtonColors(
          primary: DSFortuneColors.getInk(isDark),
          primaryDark: DSFortuneColors.inkBlack,
        );
      case TraditionalButtonColorScheme.earth:
        return _TraditionalButtonColors(
          primary: DSLuckColors.wealthLuck,
          primaryDark: const Color(0xFF8B6914),
        );
    }
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }
}

/// Internal color holder
class _TraditionalButtonColors {
  final Color primary;
  final Color primaryDark;

  const _TraditionalButtonColors({
    required this.primary,
    required this.primaryDark,
  });
}

/// Brush stroke painter for ink style button
class _InkBrushButtonPainter extends CustomPainter {
  final Color color;
  final bool isPressed;
  final bool isDark;

  _InkBrushButtonPainter({
    required this.color,
    required this.isPressed,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: isPressed ? 0.8 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPressed ? 3 : 2
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Top stroke - brush-like with thickness variation
    path.moveTo(size.width * 0.05, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.08,
      size.width * 0.5, size.height * 0.12,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.16,
      size.width * 0.95, size.height * 0.1,
    );

    // Bottom stroke
    path.moveTo(size.width * 0.08, size.height * 0.88);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.92,
      size.width * 0.5, size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.78,
      size.width * 0.92, size.height * 0.9,
    );

    // Left stroke
    path.moveTo(size.width * 0.08, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.04, size.height * 0.5,
      size.width * 0.06, size.height * 0.8,
    );

    // Right stroke
    path.moveTo(size.width * 0.92, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.96, size.height * 0.45,
      size.width * 0.94, size.height * 0.85,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InkBrushButtonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isPressed != isPressed;
  }
}

/// Text-only traditional button (minimal style)
class TraditionalTextButton extends StatefulWidget {
  final String text;
  final String? hanja;
  final VoidCallback? onPressed;
  final TraditionalButtonColorScheme colorScheme;

  const TraditionalTextButton({
    super.key,
    required this.text,
    this.hanja,
    this.onPressed,
    this.colorScheme = TraditionalButtonColorScheme.fortune,
  });

  @override
  State<TraditionalTextButton> createState() => _TraditionalTextButtonState();
}

class _TraditionalTextButtonState extends State<TraditionalTextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(isDark);
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.6 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'GowunBatang',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled ? color.withValues(alpha: 0.4) : color,
                decoration: TextDecoration.underline,
                decorationColor: color.withValues(alpha: 0.3),
                decorationStyle: TextDecorationStyle.dashed,
              ),
            ),
            if (widget.hanja != null) ...[
              const SizedBox(width: 4),
              Text(
                '(${widget.hanja})',
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: 12,
                  color: isDisabled
                      ? color.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColor(bool isDark) {
    switch (widget.colorScheme) {
      case TraditionalButtonColorScheme.fortune:
        return DSFortuneColors.getPrimary(isDark);
      case TraditionalButtonColorScheme.gold:
        return DSLuckColors.getGold(isDark);
      case TraditionalButtonColorScheme.vermilion:
        return DSLuckColors.getLucky(isDark);
      case TraditionalButtonColorScheme.love:
        return DSLoveColors.getPrimary(isDark);
      case TraditionalButtonColorScheme.ink:
        return DSFortuneColors.getInk(isDark);
      case TraditionalButtonColorScheme.earth:
        return DSLuckColors.wealthLuck;
    }
  }
}

/// Icon button with seal stamp style
class TraditionalIconButton extends StatefulWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final TraditionalButtonColorScheme colorScheme;
  final double size;
  final bool showBorder;

  const TraditionalIconButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.colorScheme = TraditionalButtonColorScheme.fortune,
    this.size = 44,
    this.showBorder = true,
  });

  @override
  State<TraditionalIconButton> createState() => _TraditionalIconButtonState();
}

class _TraditionalIconButtonState extends State<TraditionalIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(isDark);
    final isDisabled = widget.onPressed == null;

    Widget button = GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.05),
          border: widget.showBorder
              ? Border.all(
                  color: isDisabled
                      ? color.withValues(alpha: 0.2)
                      : color.withValues(alpha: _isPressed ? 0.8 : 0.4),
                  width: _isPressed ? 2 : 1,
                )
              : null,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.size * 0.5,
            color: isDisabled ? color.withValues(alpha: 0.3) : color,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  Color _getColor(bool isDark) {
    switch (widget.colorScheme) {
      case TraditionalButtonColorScheme.fortune:
        return DSFortuneColors.getPrimary(isDark);
      case TraditionalButtonColorScheme.gold:
        return DSLuckColors.getGold(isDark);
      case TraditionalButtonColorScheme.vermilion:
        return DSLuckColors.getLucky(isDark);
      case TraditionalButtonColorScheme.love:
        return DSLoveColors.getPrimary(isDark);
      case TraditionalButtonColorScheme.ink:
        return DSFortuneColors.getInk(isDark);
      case TraditionalButtonColorScheme.earth:
        return DSLuckColors.wealthLuck;
    }
  }
}
