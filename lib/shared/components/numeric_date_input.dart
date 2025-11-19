import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/theme/typography_unified.dart';

/// 숫자패드로 입력하는 날짜 선택 위젯
/// YYYY-MM-DD 형식으로 입력
class NumericDateInput extends StatefulWidget {
  final DateTime? initialDate;
  final String label;
  final String hint;
  final Function(DateTime?) onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const NumericDateInput({
    super.key,
    this.initialDate,
    required this.label,
    this.hint = 'YYYY-MM-DD',
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<NumericDateInput> createState() => _NumericDateInputState();
}

class _NumericDateInputState extends State<NumericDateInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _controller.text = _formatDate(widget.initialDate!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String text) {
    // YYYY-MM-DD 또는 YYYYMMDD 형식 파싱
    final cleaned = text.replaceAll('-', '');
    if (cleaned.length != 8) return null;

    try {
      final year = int.parse(cleaned.substring(0, 4));
      final month = int.parse(cleaned.substring(4, 6));
      final day = int.parse(cleaned.substring(6, 8));

      final date = DateTime(year, month, day);

      // 유효한 날짜인지 확인
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }

      // 날짜 범위 확인
      if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
        return null;
      }
      if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
        return null;
      }

      return date;
    } catch (e) {
      return null;
    }
  }

  void _validateAndNotify(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = null;
        widget.onDateChanged(null);
        return;
      }

      final date = _parseDate(value);
      if (date == null) {
        _errorText = '올바른 날짜 형식이 아닙니다 (YYYY-MM-DD)';
        widget.onDateChanged(null);
      } else {
        _errorText = null;
        widget.onDateChanged(date);
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
            child: Text(
              widget.label,
              style: TypographyUnified.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.textPrimaryLight,
              ),
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
              LengthLimitingTextInputFormatter(8),
              _DateTextInputFormatter(),
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
                Icons.calendar_today,
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
            '숫자 8자리 입력 (예: 19900101)',
            style: TypographyUnified.labelSmall.copyWith(
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }
}

/// 날짜 입력 포매터: YYYYMMDD → YYYY-MM-DD
class _DateTextInputFormatter extends TextInputFormatter {
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
      if (i == 3 || i == 5) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
