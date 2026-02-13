import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// TOSS 스타일 텍스트 입력 필드
class TossTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool enableHaptic;

  const TossTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.autofocus = false,
    this.enableHaptic = true,
  });

  @override
  State<TossTextField> createState() => _TossTextFieldState();
}

class _TossTextFieldState extends State<TossTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      vsync: this,
      duration: DSAnimation.fast,
    );
    
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    
    if (_hasFocus) {
      _animationController.forward();
      if (widget.enableHaptic) {
        HapticFeedback.selectionClick();
      }
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: context.bodySmall.copyWith(
              color: hasError
                  ? DSColors.error
                  : context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.smd),
                border: Border.all(
                  color: hasError
                      ? DSColors.error
                      : _hasFocus
                          ? context.colors.accent
                          : context.colors.border,
                  width: _hasFocus ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                onChanged: widget.onChanged,
                onEditingComplete: widget.onEditingComplete,
                onSubmitted: widget.onSubmitted,
                enabled: widget.enabled,
                inputFormatters: widget.inputFormatters,
                autofocus: widget.autofocus,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: context.bodyMedium.copyWith(
                    color: context.colors.textDisabled,
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.md,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            );
          },
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            widget.errorText ?? widget.helperText ?? '',
            style: context.labelMedium.copyWith(
              color: hasError
                  ? DSColors.error
                  : context.colors.textDisabled,
            ),
          ).animate().fadeIn(duration: DSAnimation.fast),
        ],
      ],
    );
  }
}

/// TOSS 스타일 선택 필드
class TossSelectField<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<TossSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const TossSelectField({
    super.key,
    this.labelText,
    this.hintText,
    this.value,
    required this.options,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: context.bodySmall.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.smd),
            border: Border.all(
              color: context.colors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: hintText != null
                  ? Text(
                      hintText!,
                      style: context.bodyMedium.copyWith(
                        color: context.colors.textDisabled,
                      ),
                    )
                  : null,
              items: options.map((option) {
                return DropdownMenuItem<T>(
                  value: option.value,
                  child: Text(
                    option.label,
                    style: context.bodyMedium.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.md,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TossSelectOption<T> {
  final String label;
  final T value;

  const TossSelectOption({
    required this.label,
    required this.value,
  });
}

/// TOSS 스타일 체크박스
class TossCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool enabled;

  const TossCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onChanged?.call(!value);
            }
          : null,
      borderRadius: BorderRadius.circular(DSRadius.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value
                  ? context.colors.accent
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.xs),
              border: Border.all(
                color: value
                    ? context.colors.accent
                    : context.colors.border,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ).animate().scale(duration: DSAnimation.fast)
                : null,
          ),
          if (label != null) ...[
            const SizedBox(width: DSSpacing.sm),
            Text(
              label!,
              style: context.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}