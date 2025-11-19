import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/theme/typography_unified.dart';

/// 숫자패드로 입력하는 시간 선택 위젯
/// HH:MM 형식으로 입력
class NumericTimeInput extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String label;
  final String hint;
  final Function(String?) onTimeChanged;
  final bool required;

  const NumericTimeInput({
    super.key,
    this.initialTime,
    required this.label,
    this.hint = 'HH:MM',
    required this.onTimeChanged,
    this.required = false,
  });

  @override
  State<NumericTimeInput> createState() => _NumericTimeInputState();
}

class _NumericTimeInputState extends State<NumericTimeInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.initialTime != null) {
      _controller.text = _formatTime(widget.initialTime!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _validateTime(String text) {
    // HH:MM 또는 HHMM 형식 검증
    final cleaned = text.replaceAll(':', '');
    if (cleaned.length != 4) return false;

    try {
      final hour = int.parse(cleaned.substring(0, 2));
      final minute = int.parse(cleaned.substring(2, 4));

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  void _validateAndNotify(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = widget.required ? '시간을 입력해주세요' : null;
        widget.onTimeChanged(null);
        return;
      }

      if (_validateTime(value)) {
        _errorText = null;
        widget.onTimeChanged(value);
      } else {
        _errorText = '올바른 시간 형식이 아닙니다 (HH:MM)';
        widget.onTimeChanged(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: TypographyUnified.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TossDesignSystem.textPrimaryLight,
                  ),
                ),
                if (!widget.required)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '(선택)',
                      style: TypographyUnified.labelSmall.copyWith(
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorText != null
                  ? TossDesignSystem.error
                  : _focusNode.hasFocus
                      ? TossDesignSystem.primaryBlue
                      : const Color(0xFFE5E5E5),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              _TimeTextInputFormatter(),
            ],
            style: TypographyUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TypographyUnified.bodyMedium.copyWith(
                color: const Color(0xFF999999),
              ),
              prefixIcon: Icon(
                Icons.access_time,
                color: _focusNode.hasFocus
                    ? TossDesignSystem.primaryBlue
                    : const Color(0xFF999999),
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Color(0xFF999999),
                        size: 20,
                      ),
                      onPressed: () {
                        _controller.clear();
                        _validateAndNotify('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: _validateAndNotify,
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: TossDesignSystem.error,
                ),
                const SizedBox(width: 4),
                Text(
                  _errorText!,
                  style: TypographyUnified.labelSmall.copyWith(
                    color: TossDesignSystem.error,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 12),
          child: Text(
            '숫자 4자리 입력 (예: 1430 → 14:30)',
            style: TypographyUnified.labelSmall.copyWith(
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }
}

/// 시간 입력 포매터: HHMM → HH:MM
class _TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1) {
        buffer.write(':');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
