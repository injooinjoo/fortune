import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_animation.dart';
import '../utils/ds_haptics.dart';
import '../theme/ds_extensions.dart';

/// iOS-style toggle switch (ChatGPT style)
///
/// Features:
/// - Green active color (#10B981)
/// - Smooth animation
/// - Haptic feedback
/// - iOS-like appearance
///
/// Usage:
/// ```dart
/// DSToggle(
///   value: _isEnabled,
///   onChanged: (value) => setState(() => _isEnabled = value),
/// )
/// ```
class DSToggle extends StatefulWidget {
  /// Current toggle state
  final bool value;

  /// Change callback (null = disabled)
  final ValueChanged<bool>? onChanged;

  /// Enable haptic feedback
  final bool enableHaptic;

  const DSToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.enableHaptic = true,
  });

  @override
  State<DSToggle> createState() => _DSToggleState();
}

class _DSToggleState extends State<DSToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  // iOS toggle dimensions
  static const double _trackWidth = 51.0;
  static const double _trackHeight = 31.0;
  static const double _thumbSize = 27.0;
  static const double _thumbPadding = 2.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DSAnimation.toggleSwitch,
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    _positionAnimation = Tween<double>(
      begin: _thumbPadding,
      end: _trackWidth - _thumbSize - _thumbPadding,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DSAnimation.curveToggle,
    ));
  }

  @override
  void didUpdateWidget(DSToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged == null) return;

    if (widget.enableHaptic) {
      DSHaptics.selection();
    }

    widget.onChanged!(!widget.value);
  }

  bool get _isEnabled => widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    _colorAnimation = ColorTween(
      begin: colors.toggleInactive,
      end: colors.toggleActive,
    ).animate(_animationController);

    return GestureDetector(
      onTap: _handleTap,
      child: Opacity(
        opacity: _isEnabled ? 1.0 : 0.5,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: _trackWidth,
              height: _trackHeight,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(_trackHeight / 2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: _positionAnimation.value,
                    top: _thumbPadding,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: colors.toggleThumb,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: DSColors.textPrimary.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: DSColors.textPrimary.withValues(alpha: 0.06),
                            blurRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Labeled toggle with title and optional subtitle
///
/// Usage:
/// ```dart
/// DSLabeledToggle(
///   title: '다크 모드',
///   subtitle: '어두운 테마 사용',
///   value: _isDark,
///   onChanged: (value) => setState(() => _isDark = value),
/// )
/// ```
class DSLabeledToggle extends StatelessWidget {
  /// Toggle label
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Current value
  final bool value;

  /// Change callback
  final ValueChanged<bool>? onChanged;

  /// Enable haptic
  final bool enableHaptic;

  const DSLabeledToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.typography.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: context.typography.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        DSToggle(
          value: value,
          onChanged: onChanged,
          enableHaptic: enableHaptic,
        ),
      ],
    );
  }
}
