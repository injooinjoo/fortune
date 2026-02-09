import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_animation.dart';
import '../theme/ds_extensions.dart';

/// ChatGPT-inspired text field
///
/// Features:
/// - Gray background (no border by default)
/// - Gray focus border (monochrome)
/// - Clean, minimal design
///
/// Usage:
/// ```dart
/// DSTextField(
///   label: '이름',
///   placeholder: '이름을 입력하세요',
///   controller: _controller,
/// )
/// ```
class DSTextField extends StatefulWidget {
  /// Label above the field
  final String? label;

  /// Placeholder text
  final String? placeholder;

  /// Text controller
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// Change callback
  final ValueChanged<String>? onChanged;

  /// Submit callback
  final ValueChanged<String>? onSubmitted;

  /// Error text
  final String? errorText;

  /// Helper text
  final String? helperText;

  /// Is password field
  final bool obscureText;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Max lines
  final int maxLines;

  /// Min lines
  final int? minLines;

  /// Max length
  final int? maxLength;

  /// Is enabled
  final bool enabled;

  /// Is read only
  final bool readOnly;

  /// Leading icon
  final IconData? leadingIcon;

  /// Trailing widget
  final Widget? trailing;

  /// Autofocus
  final bool autofocus;

  /// Auto-correct
  final bool autocorrect;

  const DSTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.leadingIcon,
    this.trailing,
    this.autofocus = false,
    this.autocorrect = false,
  });

  @override
  State<DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<DSTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final hasError = widget.errorText != null;

    // Determine border color
    Color borderColor;
    if (hasError) {
      borderColor = colors.error;
    } else if (_isFocused) {
      borderColor = colors.borderFocus;
    } else {
      borderColor = Colors.transparent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: typography.labelMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],

        // Text field
        AnimatedContainer(
          duration: DSAnimation.durationFast,
          decoration: BoxDecoration(
            color: widget.enabled
                ? colors.backgroundTertiary
                : colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 2 : 0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            autocorrect: widget.autocorrect,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
            cursorColor: colors.textPrimary,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: typography.bodyMedium.copyWith(
                color: colors.textTertiary,
              ),
              prefixIcon: widget.leadingIcon != null
                  ? Icon(
                      widget.leadingIcon,
                      color: _isFocused ? colors.textPrimary : colors.textTertiary,
                      size: 20,
                    )
                  : null,
              suffixIcon: _buildSuffix(colors),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.inputHorizontal,
                vertical: DSSpacing.inputVertical,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),

        // Error or helper text
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            widget.errorText ?? widget.helperText!,
            style: typography.labelSmall.copyWith(
              color: hasError ? colors.error : colors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffix(DSColorScheme colors) {
    if (widget.trailing != null) {
      return widget.trailing;
    }

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: colors.textTertiary,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return null;
  }
}

/// Search text field variant
///
/// Usage:
/// ```dart
/// DSSearchField(
///   placeholder: '검색',
///   onChanged: (value) => print(value),
/// )
/// ```
class DSSearchField extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const DSSearchField({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DSTextField(
      placeholder: placeholder ?? '검색',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      leadingIcon: Icons.search,
      textInputAction: TextInputAction.search,
      autofocus: autofocus,
      trailing: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: colors.textTertiary,
                size: 20,
              ),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
    );
  }
}
