import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/fortune_design_system.dart';

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
      duration: TossDesignSystem.durationShort,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TossDesignSystem.body3.copyWith(
              color: hasError 
                  ? TossDesignSystem.errorRed
                  : (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingS),
        ],
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                border: Border.all(
                  color: hasError
                      ? TossDesignSystem.errorRed
                      : _hasFocus
                          ? TossDesignSystem.tossBlue
                          : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
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
                style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.spacingM,
                    vertical: TossDesignSystem.spacingM,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            );
          },
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          SizedBox(height: TossDesignSystem.spacingXS),
          Text(
            widget.errorText ?? widget.helperText ?? '',
            style: TossDesignSystem.caption1.copyWith(
              color: hasError
                  ? TossDesignSystem.errorRed
                  : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
            ),
          ).animate().fadeIn(duration: TossDesignSystem.durationShort),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingS),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: hintText != null
                  ? Text(
                      hintText!,
                      style: TossDesignSystem.body2.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                      ),
                    )
                  : null,
              items: options.map((option) {
                return DropdownMenuItem<T>(
                  value: option.value,
                  child: Text(
                    option.label,
                    style: TossDesignSystem.body2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              padding: EdgeInsets.symmetric(
                horizontal: TossDesignSystem.spacingM,
                vertical: TossDesignSystem.spacingM,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onChanged?.call(!value);
            }
          : null,
      borderRadius: BorderRadius.circular(TossDesignSystem.radiusXS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white),
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusXS),
              border: Border.all(
                color: value
                    ? TossDesignSystem.tossBlue
                    : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
                width: 2,
              ),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: TossDesignSystem.white,
                  ).animate().scale(duration: TossDesignSystem.durationShort)
                : null,
          ),
          if (label != null) ...[
            SizedBox(width: TossDesignSystem.spacingS),
            Text(
              label!,
              style: TossDesignSystem.body2.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}