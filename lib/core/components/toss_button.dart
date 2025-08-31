import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/toss_design_system.dart';

/// TOSS 스타일 버튼 컴포넌트
class TossButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final TossButtonStyle style;
  final TossButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final bool enableHaptic;

  const TossButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = TossButtonStyle.primary,
    this.size = TossButtonSize.large,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.enableHaptic = true,
  });

  @override
  State<TossButton> createState() => _TossButtonState();
}

class _TossButtonState extends State<TossButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: TossDesignSystem.durationMedium,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    
    _animationController.forward();
    
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null || widget.isLoading) return;
    
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: _getHeight(),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context, isDark),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              border: _getBorder(context, isDark),
              boxShadow: _getBoxShadow(isDark),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                splashColor: _getSplashColor(context, isDark),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: _getPadding(),
                  child: Center(
                    child: widget.isLoading
                        ? _buildLoadingIndicator(context, isDark)
                        : _buildContent(context, isDark),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final textWidget = Text(
      widget.text,
      style: _getTextStyle(context, isDark),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (widget.leadingIcon == null && widget.trailingIcon == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          IconTheme(
            data: IconThemeData(
              size: _getIconSize(),
              color: _getTextColor(context, isDark),
            ),
            child: widget.leadingIcon!,
          ),
          SizedBox(width: widget.size == TossButtonSize.small ? 6 : 8),
        ],
        Flexible(child: textWidget),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: widget.size == TossButtonSize.small ? 6 : 8),
          IconTheme(
            data: IconThemeData(
              size: _getIconSize(),
              color: _getTextColor(context, isDark),
            ),
            child: widget.trailingIcon!,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, bool isDark) {
    return SizedBox(
      width: _getIconSize(),
      height: _getIconSize(),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(context, isDark)),
      ),
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case TossButtonSize.small:
        return 40;
      case TossButtonSize.medium:
        return 48;
      case TossButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case TossButtonSize.small:
        return TossDesignSystem.radiusS;
      case TossButtonSize.medium:
        return TossDesignSystem.radiusM;
      case TossButtonSize.large:
        return TossDesignSystem.radiusL;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case TossButtonSize.small:
        return EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM);
      case TossButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM);
      case TossButtonSize.large:
        return EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingL);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case TossButtonSize.small:
        return 16;
      case TossButtonSize.medium:
        return 20;
      case TossButtonSize.large:
        return 24;
    }
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.style) {
      case TossButtonStyle.primary:
        if (isDisabled) return TossDesignSystem.gray200;
        return isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;
            
      case TossButtonStyle.secondary:
        return Colors.transparent;
        
      case TossButtonStyle.tertiary:
        return Colors.transparent;
        
      case TossButtonStyle.danger:
        if (isDisabled) return TossDesignSystem.errorRed.withOpacity(0.3);
        return TossDesignSystem.errorRed;
    }
  }

  Color _getTextColor(BuildContext context, bool isDark) {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.style) {
      case TossButtonStyle.primary:
        if (isDisabled) return TossDesignSystem.gray400;
        return isDark ? TossDesignSystem.gray900 : TossDesignSystem.white;
            
      case TossButtonStyle.secondary:
      case TossButtonStyle.tertiary:
        if (isDisabled) return TossDesignSystem.gray400;
        return isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;
            
      case TossButtonStyle.danger:
        if (isDisabled) return TossDesignSystem.errorRed.withOpacity(0.5);
        return TossDesignSystem.white;
    }
  }

  TextStyle _getTextStyle(BuildContext context, bool isDark) {
    final baseStyle = widget.size == TossButtonSize.small 
        ? TossDesignSystem.body3
        : widget.size == TossButtonSize.medium
            ? TossDesignSystem.body2
            : TossDesignSystem.body1;
    
    return baseStyle.copyWith(
      color: _getTextColor(context, isDark),
      fontWeight: FontWeight.w600,
    );
  }

  Color _getSplashColor(BuildContext context, bool isDark) {
    switch (widget.style) {
      case TossButtonStyle.primary:
        return TossDesignSystem.white.withOpacity(0.1);
      case TossButtonStyle.secondary:
      case TossButtonStyle.tertiary:
        return (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900).withOpacity(0.05);
      case TossButtonStyle.danger:
        return TossDesignSystem.white.withOpacity(0.1);
    }
  }

  BoxBorder? _getBorder(BuildContext context, bool isDark) {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.style) {
      case TossButtonStyle.secondary:
        return Border.all(
          color: isDisabled
              ? TossDesignSystem.gray200
              : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
          width: 1,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isDark) {
    if (widget.style != TossButtonStyle.primary || widget.onPressed == null) {
      return null;
    }
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

enum TossButtonStyle {
  primary,
  secondary,
  tertiary,
  danger,
}

enum TossButtonSize {
  small,
  medium,
  large,
}

/// Floating Action Button TOSS 스타일
class TossFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final bool mini;
  final bool enableHaptic;

  const TossFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.mini = false,
    this.enableHaptic = true,
  });

  @override
  State<TossFloatingActionButton> createState() => _TossFloatingActionButtonState();
}

class _TossFloatingActionButtonState extends State<TossFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: TossDesignSystem.durationMedium,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = widget.mini ? 40.0 : 56.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed == null) return;
        _animationController.forward();
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed == null) return;
        _animationController.reverse();
      },
      onTapCancel: () {
        if (widget.onPressed == null) return;
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: widget.mini ? 20 : 24,
                      color: isDark ? TossDesignSystem.gray900 : TossDesignSystem.white,
                    ),
                    child: widget.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}