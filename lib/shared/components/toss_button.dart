import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'loading_dots.dart';

/// 토스 스타일 버튼
/// Primary, Secondary, Ghost, Text 스타일 지원
class TossButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TossButtonStyle style;
  final TossButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const TossButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = TossButtonStyle.primary,
    this.size = TossButtonSize.large,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.margin,
  });

  /// Primary 버튼 생성 헬퍼
  factory TossButton.primary({
    required String text,
    VoidCallback? onPressed,
    TossButtonSize size = TossButtonSize.large,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return TossButton(
      text: text,
      onPressed: onPressed,
      style: TossButtonStyle.primary,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      margin: margin,
    );
  }

  /// Secondary 버튼 생성 헬퍼
  factory TossButton.secondary({
    required String text,
    VoidCallback? onPressed,
    TossButtonSize size = TossButtonSize.large,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return TossButton(
      text: text,
      onPressed: onPressed,
      style: TossButtonStyle.secondary,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      margin: margin,
    );
  }

  /// Ghost 버튼 생성 헬퍼
  factory TossButton.ghost({
    required String text,
    VoidCallback? onPressed,
    TossButtonSize size = TossButtonSize.medium,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return TossButton(
      text: text,
      onPressed: onPressed,
      style: TossButtonStyle.ghost,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      margin: margin,
    );
  }

  /// Text 버튼 생성 헬퍼
  factory TossButton.text({
    required String text,
    VoidCallback? onPressed,
    TossButtonSize size = TossButtonSize.small,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    EdgeInsetsGeometry? margin,
  }) {
    return TossButton(
      text: text,
      onPressed: onPressed,
      style: TossButtonStyle.text,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: null,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;
    
    Widget child = isLoading
        ? LoadingDots(
            color: _getTextColor(isDark, effectiveEnabled),
            size: 6,
          )
        : Row(
            mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                if (text.isNotEmpty) const SizedBox(width: TossDesignSystem.spacingXS),
              ],
              if (text.isNotEmpty)
                Text(
                  text,
                  style: _getTextStyle(isDark, effectiveEnabled),
                ),
            ],
          );
    
    Widget button;
    
    switch (style) {
      case TossButtonStyle.primary:
        button = ElevatedButton(
          onPressed: effectiveEnabled ? () {
            TossDesignSystem.hapticLight();
            onPressed!();
          } : null,
          style: _getPrimaryButtonStyle(isDark, effectiveEnabled),
          child: child,
        );
        break;
        
      case TossButtonStyle.secondary:
        button = ElevatedButton(
          onPressed: effectiveEnabled ? () {
            TossDesignSystem.hapticLight();
            onPressed!();
          } : null,
          style: _getSecondaryButtonStyle(isDark, effectiveEnabled),
          child: child,
        );
        break;
        
      case TossButtonStyle.ghost:
        button = OutlinedButton(
          onPressed: effectiveEnabled ? () {
            TossDesignSystem.hapticLight();
            onPressed!();
          } : null,
          style: _getGhostButtonStyle(isDark, effectiveEnabled),
          child: child,
        );
        break;
        
      case TossButtonStyle.text:
        button = TextButton(
          onPressed: effectiveEnabled ? () {
            TossDesignSystem.hapticLight();
            onPressed!();
          } : null,
          style: _getTextButtonStyle(isDark, effectiveEnabled),
          child: child,
        );
        break;
    }
    
    if (width != null) {
      button = SizedBox(
        width: width,
        child: button,
      );
    }
    
    if (margin != null) {
      button = Padding(
        padding: margin!,
        child: button,
      );
    }
    
    return button;
  }
  
  double _getHeight() {
    switch (size) {
      case TossButtonSize.large:
        return TossDesignSystem.buttonHeightLarge;
      case TossButtonSize.medium:
        return TossDesignSystem.buttonHeightMedium;
      case TossButtonSize.small:
        return TossDesignSystem.buttonHeightSmall;
    }
  }
  
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case TossButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingL);
      case TossButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM);
      case TossButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM);
    }
  }
  
  TextStyle _getTextStyle(bool isDark, bool enabled) {
    final baseStyle = size == TossButtonSize.small 
        ? TossDesignSystem.body3 
        : TossDesignSystem.button;
    
    return baseStyle.copyWith(
      color: _getTextColor(isDark, enabled),
    );
  }
  
  Color _getTextColor(bool isDark, bool enabled) {
    if (!enabled) {
      return isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400;
    }

    switch (style) {
      case TossButtonStyle.primary:
        return TossDesignSystem.white;
      case TossButtonStyle.secondary:
        return isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;
      case TossButtonStyle.ghost:
        return isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue;
      case TossButtonStyle.text:
        return isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue;
    }
  }
  
  ButtonStyle _getPrimaryButtonStyle(bool isDark, bool enabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: enabled 
          ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
          : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
      foregroundColor: TossDesignSystem.white,
      disabledBackgroundColor: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
      disabledForegroundColor: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
      elevation: 0,
      shadowColor: TossDesignSystem.white.withValues(alpha: 0.0),
      minimumSize: Size(0, _getHeight()),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
      ),
    );
  }
  
  ButtonStyle _getSecondaryButtonStyle(bool isDark, bool enabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
      foregroundColor: enabled 
          ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
          : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
      disabledBackgroundColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
      disabledForegroundColor: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
      elevation: 0,
      shadowColor: TossDesignSystem.white.withValues(alpha: 0.0),
      minimumSize: Size(0, _getHeight()),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
      ),
    );
  }
  
  ButtonStyle _getGhostButtonStyle(bool isDark, bool enabled) {
    return OutlinedButton.styleFrom(
      foregroundColor: enabled 
          ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
          : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      disabledForegroundColor: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
      minimumSize: Size(0, _getHeight()),
      padding: _getPadding(),
      side: BorderSide(
        color: enabled 
            ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
            : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
      ),
    );
  }
  
  ButtonStyle _getTextButtonStyle(bool isDark, bool enabled) {
    return TextButton.styleFrom(
      foregroundColor: enabled 
          ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
          : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      disabledForegroundColor: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
      padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingXS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
      ),
    );
  }
}

/// 버튼 스타일 종류
enum TossButtonStyle {
  primary,   // 파란색 배경
  secondary, // 회색 배경
  ghost,     // 테두리만
  text,      // 텍스트만
}

/// 버튼 크기
enum TossButtonSize {
  large,  // 56px
  medium, // 48px
  small,  // 40px
}

/// 토스 스타일 아이콘 버튼
class TossIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const TossIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget button = Material(
      color: backgroundColor ?? TossDesignSystem.white.withValues(alpha: 0.0),
      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
      child: InkWell(
        onTap: onPressed != null ? () {
          TossDesignSystem.hapticLight();
          onPressed!();
        } : null,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        child: Container(
          width: size + 16,
          height: size + 16,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size,
            color: color ?? (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
          ),
        ),
      ),
    );
    
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

/// 토스 스타일 플로팅 액션 버튼
class TossFloatingButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double? size;
  final String? heroTag;

  const TossFloatingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.size,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FloatingActionButton(
      onPressed: onPressed != null ? () {
        TossDesignSystem.hapticMedium();
        onPressed!();
      } : null,
      backgroundColor: backgroundColor ?? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue),
      elevation: 4,
      highlightElevation: 8,
      heroTag: heroTag,
      mini: size != null && size! < 50,
      child: child,
    );
  }
}