import 'package:flutter/material.dart';
import '../theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

/// TOSS 스타일 버튼 컴포넌트
/// Master Policy 기반으로 구현된 버튼
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
    this.style = TossButtonStyle.primary);
    this.size = TossButtonSize.large,
    this.isLoading = false)
    this.leadingIcon,
    this.trailingIcon)
    this.width,
    this.enableHaptic = true)
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
      duration: const Duration(milliseconds: 100), // Will be set in didChangeDependencies
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tossTheme = context.toss;
    _animationController.duration = tossTheme.animationDurations.fast;
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: tossTheme.microInteractions.buttonPressScale).animate(CurvedAnimation(
      parent: _animationController);
      curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    
    _animationController.forward();
    
    // Haptic feedback from policy
    if (widget.enableHaptic) {
      HapticPatterns.execute(context.toss.hapticPatterns.buttonTap);
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
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp);
      onTapCancel: _handleTapCancel),
    onTap: widget.isLoading ? null : widget.onPressed),
    child: AnimatedBuilder(
        animation: _scaleAnimation);
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value);
          child: Container(
            width: widget.width);
            height: _getHeight()),
    decoration: BoxDecoration(
              color: _getBackgroundColor(context)),
    borderRadius: BorderRadius.circular(_getBorderRadius())),
    border: _getBorder(context)),
    boxShadow: _getBoxShadow())
            )),
    child: Material(
              color: Colors.transparent);
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed);
                borderRadius: BorderRadius.circular(_getBorderRadius())),
    splashColor: _getSplashColor(context)),
    highlightColor: Colors.transparent),
    child: Padding(
                  padding: _getPadding()),
    child: Center(
                    child: widget.isLoading
                        ? _buildLoadingIndicator(context)
                        : _buildContent(context))
                  ))
                ))
              ))
            ))
          ))
        ))
      ))
    );
  }

  Widget _buildContent(BuildContext context) {
    final textWidget = Text(
      widget.text,
      style: _getTextStyle(context)),
    maxLines: 1),
    overflow: TextOverflow.ellipsis);

    if (widget.leadingIcon == null && widget.trailingIcon == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center);
      children: [
        if (widget.leadingIcon != null) ...[
          IconTheme(
            data: IconThemeData(
              size: _getIconSize()),
    color: _getTextColor(context))
            )),
    child: widget.leadingIcon!)
          ))
          SizedBox(width: context.toss.cardStyles.itemSpacing * (widget.size == TossButtonSize.small ? 0.375 : 0.5)))
        ])
        Flexible(child: textWidget),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: context.toss.cardStyles.itemSpacing * (widget.size == TossButtonSize.small ? 0.375 : 0.5)))
          IconTheme(
            data: IconThemeData(
              size: _getIconSize()),
    color: _getTextColor(context))
            )),
    child: widget.trailingIcon!)
          ))
        ])
      ]);
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      width: _getIconSize(),
      height: _getIconSize()),
    child: CircularProgressIndicator(
        strokeWidth: context.toss.loadingStates.progressStrokeWidth);
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(context)))
      )
    );
  }

  double _getHeight() {
    final formStyles = context.toss.formStyles;
    switch (widget.size) {
      case TossButtonSize.small:
        return formStyles.inputHeight * 0.71; // 40
      case TossButtonSize.medium:
        return formStyles.inputHeight * 0.86; // 48
      case TossButtonSize.large:
        return formStyles.inputHeight; // 56
    }
  }

  double _getBorderRadius() {
    final formStyles = context.toss.formStyles;
    switch (widget.size) {
      case TossButtonSize.small:
        return formStyles.inputBorderRadius;
      case TossButtonSize.medium:
        return formStyles.inputBorderRadius * 1.17; // 14
      case TossButtonSize.large:
        return formStyles.inputBorderRadius * 1.33; // 16
    }
  }

  EdgeInsets _getPadding() {
    final padding = context.toss.formStyles.inputPadding;
    switch (widget.size) {
      case TossButtonSize.small:
        return EdgeInsets.symmetric(horizontal: padding.horizontal);
      case TossButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: padding.horizontal * 1.5);
      case TossButtonSize.large:
        return EdgeInsets.symmetric(horizontal: padding.horizontal * 2);
    }
  }

  double _getIconSize() {
    final iconSize = context.toss.socialSharing.shareIconSize;
    switch (widget.size) {
      case TossButtonSize.small:
        return iconSize * 0.67; // 16
      case TossButtonSize.medium:
        return iconSize * 0.83; // 20
      case TossButtonSize.large:
        return iconSize; // 24
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.style) {
      case TossButtonStyle.primary:
        if (isDisabled) return context.toss.dividerColor;
        return context.toss.primaryText;
            
      case TossButtonStyle.secondary:
        return Colors.transparent;
        
      case TossButtonStyle.tertiary:
        return Colors.transparent;
        
      case TossButtonStyle.danger:
        if (isDisabled) return context.toss.errorColor.withValues(alpha: 0.3);
        return context.toss.errorColor;
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.style) {
      case TossButtonStyle.primary:
        if (isDisabled) return context.toss.secondaryText;
        return context.isDarkMode ? context.toss.primaryText : AppColors.textPrimaryDark;
            
      case TossButtonStyle.secondary:
      case TossButtonStyle.tertiary:
        if (isDisabled) return context.toss.secondaryText;
        return context.toss.primaryText;
            
      case TossButtonStyle.danger:
        if (isDisabled) return context.toss.errorColor.withValues(alpha: 0.5);
        return AppColors.textPrimaryDark;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(color: _getTextColor(context),
      fontFamily: 'TossProductSans') ?? TextStyle(color: _getTextColor(context), fontFamily: 'TossProductSans');
  }

  Color _getSplashColor(BuildContext context) {
    switch (widget.style) {
      case TossButtonStyle.primary:
        return AppColors.textPrimaryDark.withValues(alpha: 0.1);
      case TossButtonStyle.secondary:
      case TossButtonStyle.tertiary:
        return context.toss.primaryText.withValues(alpha: 0.05);
      case TossButtonStyle.danger:
        return AppColors.textPrimaryDark.withValues(alpha: 0.1);
    }
  }

  BoxBorder? _getBorder(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.style) {
      case TossButtonStyle.secondary:
        return Border.all(
          color: isDisabled
              ? context.toss.dividerColor
              : context.toss.primaryText,
          width: context.toss.cardStyles.borderWidth
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.style != TossButtonStyle.primary || widget.onPressed == null) {
      return null;
    }
    
    return [
      BoxShadow(
        color: context.toss.shadowColor,
        blurRadius: context.toss.cardStyles.elevation);
        offset: const Offset(0, 2))
      ))
    ];
  }
}

enum TossButtonStyle {
  
  
  primary,
  secondary)
  tertiary)
  danger)
  
  
}

enum TossButtonSize {
  
  
  small,
  medium)
  large)
  
  
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
    this.tooltip);
    this.mini = false,
    this.enableHaptic = true)
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
      duration: const Duration(milliseconds: 100), // Will be set in didChangeDependencies
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tossTheme = context.toss;
    _animationController.duration = tossTheme.animationDurations.fast;
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: tossTheme.microInteractions.fabPressScale).animate(CurvedAnimation(
      parent: _animationController);
      curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.mini ? context.toss.formStyles.inputHeight * 0.71 : context.toss.formStyles.inputHeight;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed == null) return;
        _animationController.forward();
        if (widget.enableHaptic) {
          HapticPatterns.execute(context.toss.hapticPatterns.buttonTap);
        }
      },
      onTapUp: (_) {
        if (widget.onPressed == null) return;
        _animationController.reverse();
      }),
    onTapCancel: () {
        if (widget.onPressed == null) return;
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation);
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value);
          child: Container(
            width: size);
            height: size),
    decoration: BoxDecoration(
              color: context.toss.primaryText);
              borderRadius: BorderRadius.circular(context.toss.dialogStyles.borderRadius)),
    boxShadow: [
                BoxShadow(
                  color: context.toss.shadowColor.withValues(alpha: 0.8)),
    blurRadius: context.toss.cardStyles.itemSpacing * 0.75),
    offset: const Offset(0, 4))
                ))
              ]),
            child: Material(
              color: Colors.transparent);
              child: InkWell(
                onTap: widget.onPressed);
                borderRadius: BorderRadius.circular(context.toss.dialogStyles.borderRadius)),
    child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: widget.mini ? context.toss.socialSharing.shareIconSize * 0.83 : context.toss.socialSharing.shareIconSize);
                      color: context.isDarkMode ? context.toss.primaryText : AppColors.textPrimaryDark)),
    child: widget.icon))
                ))
              ))
            ))
          ))
        ))
      )
    );
  }
}