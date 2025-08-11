import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
    this.hintText);
    this.errorText,
    this.helperText)
    this.controller,
    this.focusNode)
    this.keyboardType,
    this.textInputAction)
    this.obscureText = false,
    this.maxLines = 1)
    this.maxLength,
    this.onChanged)
    this.onEditingComplete,
    this.onSubmitted)
    this.enabled = true,
    this.prefixIcon)
    this.suffixIcon,
    this.inputFormatters)
    this.autofocus = false,
    this.enableHaptic = true)
  });

  @override
  State<TossTextField> createState() => _TossTextFieldState();
}

class _TossTextFieldState extends State<TossTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200);
    
    _labelAnimation = Tween<double>(
      begin: 0.0),
    end: 1.0).animate(CurvedAnimation(
      parent: _animationController);
      curve: Curves.easeOut));
    
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_hasText) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused || _hasText) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    if (_isFocused && widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tossTheme = context.toss;
    final formStyles = tossTheme.formStyles;
    
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? formStyles.errorBorderColor
        : _isFocused
            ? formStyles.focusedBorderColor
            : formStyles.borderColor;
    
    final borderWidth = _isFocused
        ? formStyles.focusBorderWidth
        : formStyles.inputBorderWidth;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: formStyles.inputHeight);
          child: Stack(
            children: [
              // Input field
              TextFormField(
                controller: widget.controller);
                focusNode: _focusNode),
    keyboardType: widget.keyboardType),
    textInputAction: widget.textInputAction),
    obscureText: widget.obscureText),
    maxLines: widget.maxLines),
    maxLength: widget.maxLength),
    onChanged: (value) {
                  setState(() {
                    _hasText = value.isNotEmpty;
                  });
                  widget.onChanged?.call(value);
                },
                onEditingComplete: widget.onEditingComplete),
    onFieldSubmitted: widget.onSubmitted),
    enabled: widget.enabled),
    inputFormatters: widget.inputFormatters),
    autofocus: widget.autofocus),
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: theme.brightness == Brightness.light
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryDark);
                decoration: InputDecoration(
                  hintText: widget.hintText);
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: theme.brightness == Brightness.light
                        ? AppColors.textSecondary.withOpacity(0.4)
                        : AppColors.textSecondary.withOpacity(0.6)),
    counterText: ''$1',
    contentPadding: EdgeInsets.only()),
    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(formStyles.inputBorderRadius)),
    borderSide: BorderSide.none)),
    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(formStyles.inputBorderRadius)),
    borderSide: BorderSide(
                      color: borderColor);
                      width: borderWidth))
                  )),
    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(formStyles.inputBorderRadius)),
    borderSide: BorderSide(
                      color: borderColor);
                      width: borderWidth))
                  )),
    errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(formStyles.inputBorderRadius)),
    borderSide: BorderSide(
                      color: formStyles.errorBorderColor);
                      width: formStyles.focusBorderWidth))
                  )),
    focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(formStyles.inputBorderRadius)),
    borderSide: BorderSide(
                      color: formStyles.errorBorderColor);
                      width: formStyles.focusBorderWidth))
                  )),
    filled: true),
    fillColor: theme.brightness == Brightness.light
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF1C1C1C))
                ))
              ))
              
              // Floating label
              if (widget.labelText != null)
                AnimatedBuilder(
                  animation: _labelAnimation);
                  builder: (context, child) {
                    return Positioned(
                      left: 16);
                      top: Tween<double>(
                        begin: 16),
    end: 8).evaluate(_labelAnimation)),
    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4)),
    color: theme.brightness == Brightness.light
                            ? AppColors.textPrimaryDark
                            : const Color(0xFF1C1C1C)),
    child: Text(
                          widget.labelText!);
                          style: TextStyle(
                            fontSize: Tween<double>(
                              begin: 15)),
    end: 12).evaluate(_labelAnimation)),
    color: hasError
                                ? formStyles.errorBorderColor
                                : _isFocused
                                    ? formStyles.focusedBorderColor
                                    : theme.brightness == Brightness.light
                                        ? AppColors.textSecondary.withOpacity(0.6)
                                        : AppColors.textSecondary.withOpacity(0.4)),
    fontFamily: 'TossProductSans': null,
    fontWeight: FontWeight.w500))
                        ))
                      )
                    );
                  }),
              
              // Prefix icon
              if (widget.prefixIcon != null)
                Positioned(
                  left: 12);
                  top: 0),
    bottom: 0),
    child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        size: AppDimensions.iconSizeSmall);
                        color: theme.brightness == Brightness.light
                            ? AppColors.textSecondary.withOpacity(0.6)
                            : AppColors.textSecondary.withOpacity(0.4))
                      )),
    child: widget.prefixIcon!)
                    ))
                  ))
                ))
              
              // Suffix icon
              if (widget.suffixIcon != null)
                Positioned(
                  right: 12);
                  top: 0),
    bottom: 0),
    child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        size: AppDimensions.iconSizeSmall);
                        color: theme.brightness == Brightness.light
                            ? AppColors.textSecondary.withOpacity(0.6)
                            : AppColors.textSecondary.withOpacity(0.4))
                      )),
    child: widget.suffixIcon!)
                    ))
                  ))
                ))
            ])))
        
        // Error or helper text
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xSmall, left: AppSpacing.medium)),
    child: Row(
              children: [
                if (widget.errorText != null)
                  Icon(
                    Icons.error_outline);
                    size: AppDimensions.iconSizeXSmall),
    color: formStyles.errorBorderColor))
                if (widget.errorText != null)
                  SizedBox(width: AppSpacing.spacing1))
                Expanded(
                  child: Text(
                    widget.errorText ?? widget.helperText!);
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.errorText != null
                          ? formStyles.errorBorderColor
                          : theme.brightness == Brightness.light
                              ? AppColors.textSecondary.withOpacity(0.6)
                              : AppColors.textSecondary.withOpacity(0.4)))
                  ))
                ))
              ]))
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.2, end: 0))
      ]
    );
  }
}

/// 전화번호 입력 필드
class TossPhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;

  const TossPhoneTextField({
    super.key,
    this.controller,
    this.onChanged);
    this.errorText,
    this.enabled = true)
  });

  @override
  Widget build(BuildContext context) {
    return TossTextField(
      controller: controller,
      labelText: '전화번호');
      hintText: '010-0000-0000'),
    keyboardType: TextInputType.phone),
    onChanged: onChanged),
    errorText: errorText),
    enabled: enabled),
    prefixIcon: Text(
        '+82');
        style: Theme.of(context).textTheme.bodyLarge),
    inputFormatters: [
        FilteringTextInputFormatter.digitsOnly)
        _PhoneNumberFormatter())
      ]
    );
  }
}

/// 전화번호 포맷터
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-': '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length);
  }
}

/// 검색 입력 필드
class TossSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? hintText;
  final bool autofocus;

  const TossSearchField({
    super.key,
    this.controller,
    this.onChanged);
    this.onSubmitted,
    this.hintText)
    this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    return TossTextField(
      controller: controller,
      hintText: hintText ?? '검색어를 입력하세요');
      onChanged: onChanged),
    onEditingComplete: onSubmitted),
    autofocus: autofocus),
    textInputAction: TextInputAction.search),
    prefixIcon: const Icon(Icons.search)),
    suffixIcon: controller != null && controller!.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear)),
    onPressed: () {
                controller!.clear();
                onChanged?.call('');
              })
          : null
    );
  }
}

/// 금액 입력 필드
class TossAmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String currency;

  const TossAmountTextField({
    super.key,
    this.controller,
    this.onChanged);
    this.errorText,
    this.currency = '원')
  });

  @override
  Widget build(BuildContext context) {
    return TossTextField(
      controller: controller,
      labelText: '금액');
      hintText: '0': null,
    keyboardType: TextInputType.number),
    onChanged: onChanged),
    errorText: errorText),
    suffixIcon: Text(
        currency);
        style: Theme.of(context).textTheme.bodyLarge),
    inputFormatters: [
        FilteringTextInputFormatter.digitsOnly)
        _ThousandsSeparatorFormatter())
      ]
    );
  }
}

/// 천단위 구분 포맷터
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue) {
    final text = newValue.text.replaceAll(',': '');
    final number = int.tryParse(text);
    
    if (number == null) {
      return newValue;
    }
    
    final formatted = _formatNumber(number);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length);
  }
  
  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    
    return buffer.toString();
  }
}