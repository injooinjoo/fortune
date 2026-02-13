import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/design_system.dart';

/// 년/월/일 분리 입력 위젯 (온보딩과 동일한 UX)
/// - 자동 포커스 이동
/// - 백스페이스 시 이전 필드로 이동 + 마지막 숫자 삭제
/// - 포커스 해제 시 자동 패딩 (예: "5" → "05")
class ProgressiveDateInput extends StatefulWidget {
  final DateTime? initialDate;
  final String? label;
  final Function(DateTime?) onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool compact;

  const ProgressiveDateInput({
    super.key,
    this.initialDate,
    this.label,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
    this.compact = false,
  });

  @override
  State<ProgressiveDateInput> createState() => _ProgressiveDateInputState();
}

class _ProgressiveDateInputState extends State<ProgressiveDateInput> {
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();

  final _yearFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _dayFocus = FocusNode();

  String _prevMonth = '';
  String _prevDay = '';

  bool _showMonth = false;
  bool _showDay = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      _yearController.text = widget.initialDate!.year.toString();
      _monthController.text =
          widget.initialDate!.month.toString().padLeft(2, '0');
      _dayController.text = widget.initialDate!.day.toString().padLeft(2, '0');
      _showMonth = true;
      _showDay = true;
    }

    _yearController.addListener(_onYearChanged);
    _monthController.addListener(_onMonthChanged);
    _dayController.addListener(_onDayChanged);

    _monthFocus.addListener(_onMonthFocusChanged);
    _dayFocus.addListener(_onDayFocusChanged);
  }

  void _onYearChanged() {
    final text = _yearController.text;
    _validateAndNotify();

    if (text.length == 4 && _yearFocus.hasFocus) {
      if (!_showMonth) setState(() => _showMonth = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _monthFocus.requestFocus();
      });
    }
  }

  void _onMonthChanged() {
    final text = _monthController.text;

    // Backspace when empty → go back to year AND delete last digit
    if (text.isEmpty && _prevMonth.isNotEmpty && _monthFocus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_yearController.text.isNotEmpty) {
          _yearController.text = _yearController.text
              .substring(0, _yearController.text.length - 1);
        }
        _yearFocus.requestFocus();
      });
    }

    _prevMonth = text;
    _validateAndNotify();

    if (text.length == 2 && _monthFocus.hasFocus) {
      if (!_showDay) setState(() => _showDay = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dayFocus.requestFocus();
      });
    }
  }

  void _onDayChanged() {
    final text = _dayController.text;

    // Backspace when empty → go back to month AND delete last digit
    if (text.isEmpty && _prevDay.isNotEmpty && _dayFocus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_monthController.text.isNotEmpty) {
          _monthController.text = _monthController.text
              .substring(0, _monthController.text.length - 1);
        }
        _monthFocus.requestFocus();
      });
    }

    _prevDay = text;
    _validateAndNotify();
  }

  void _onMonthFocusChanged() {
    if (!_monthFocus.hasFocus && _monthController.text.isNotEmpty) {
      final month = int.tryParse(_monthController.text) ?? 0;
      if (month > 0 && month <= 12) {
        _monthController.text = month.toString().padLeft(2, '0');
      }
    }
  }

  void _onDayFocusChanged() {
    if (!_dayFocus.hasFocus && _dayController.text.isNotEmpty) {
      final day = int.tryParse(_dayController.text) ?? 0;
      if (day > 0 && day <= 31) {
        _dayController.text = day.toString().padLeft(2, '0');
      }
    }
  }

  void _validateAndNotify() {
    final year = int.tryParse(_yearController.text);
    final month = int.tryParse(_monthController.text);
    final day = int.tryParse(_dayController.text);

    if (year != null &&
        month != null &&
        day != null &&
        year >= 1900 &&
        year <= DateTime.now().year &&
        month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= 31) {
      try {
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day) {
          // Check date range
          if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
            widget.onDateChanged(null);
            return;
          }
          if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
            widget.onDateChanged(null);
            return;
          }
          widget.onDateChanged(date);
          return;
        }
      } catch (_) {}
    }
    widget.onDateChanged(null);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _yearFocus.dispose();
    _monthFocus.dispose();
    _dayFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final inputStyle = widget.compact
        ? typography.bodyLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          )
        : typography.headingSmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          );

    final hintStyle = inputStyle.copyWith(
      color: colors.textTertiary,
    );

    final labelStyle = inputStyle.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: Text(
              widget.label!,
              style: typography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? DSSpacing.md : DSSpacing.lg,
            vertical: widget.compact ? DSSpacing.sm : DSSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Year
              SizedBox(
                width: widget.compact ? 60 : 80,
                child: TextField(
                  controller: _yearController,
                  focusNode: _yearFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputStyle,
                  cursorColor: colors.textSecondary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    hintText: 'YYYY',
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Text('년', style: labelStyle),

              // Month
              if (_showMonth) ...[
                SizedBox(width: widget.compact ? 8 : 12),
                SizedBox(
                  width: widget.compact ? 40 : 50,
                  child: TextField(
                    controller: _monthController,
                    focusNode: _monthFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: inputStyle,
                    cursorColor: colors.textSecondary,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      hintText: 'MM',
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                Text('월', style: labelStyle),
              ],

              // Day
              if (_showDay) ...[
                SizedBox(width: widget.compact ? 8 : 12),
                SizedBox(
                  width: widget.compact ? 40 : 50,
                  child: TextField(
                    controller: _dayController,
                    focusNode: _dayFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: inputStyle,
                    cursorColor: colors.textSecondary,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      hintText: 'DD',
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                Text('일', style: labelStyle),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 시/분 분리 입력 위젯 (온보딩과 동일한 UX)
class ProgressiveTimeInput extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String? label;
  final Function(TimeOfDay?) onTimeChanged;
  final bool showUnknownOption;

  const ProgressiveTimeInput({
    super.key,
    this.initialTime,
    this.label,
    required this.onTimeChanged,
    this.showUnknownOption = false,
  });

  @override
  State<ProgressiveTimeInput> createState() => _ProgressiveTimeInputState();
}

class _ProgressiveTimeInputState extends State<ProgressiveTimeInput> {
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();

  final _hourFocus = FocusNode();
  final _minuteFocus = FocusNode();

  String _prevMinute = '';
  bool _isUnknown = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialTime != null) {
      _hourController.text =
          widget.initialTime!.hour.toString().padLeft(2, '0');
      _minuteController.text =
          widget.initialTime!.minute.toString().padLeft(2, '0');
    }

    _hourController.addListener(_onHourChanged);
    _minuteController.addListener(_onMinuteChanged);
    _minuteFocus.addListener(_onMinuteFocusChanged);
  }

  void _onHourChanged() {
    final text = _hourController.text;

    if (text.length == 2 && _hourFocus.hasFocus) {
      final hour = int.tryParse(text) ?? 0;
      if (hour >= 0 && hour <= 23) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _minuteFocus.requestFocus();
        });
      }
    }

    _validateAndNotify();
  }

  void _onMinuteChanged() {
    final text = _minuteController.text;

    // Backspace when empty → go back to hour AND delete last digit
    if (text.isEmpty && _prevMinute.isNotEmpty && _minuteFocus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hourController.text.isNotEmpty) {
          _hourController.text = _hourController.text
              .substring(0, _hourController.text.length - 1);
        }
        _hourFocus.requestFocus();
      });
    }

    _prevMinute = text;
    _validateAndNotify();
  }

  void _onMinuteFocusChanged() {
    if (!_minuteFocus.hasFocus && _minuteController.text.isNotEmpty) {
      final minute = int.tryParse(_minuteController.text) ?? 0;
      if (minute >= 0 && minute <= 59) {
        _minuteController.text = minute.toString().padLeft(2, '0');
      }
    }
  }

  void _validateAndNotify() {
    if (_isUnknown) {
      widget.onTimeChanged(const TimeOfDay(hour: 12, minute: 0));
      return;
    }

    final hourText = _hourController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final minuteText = _minuteController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (hourText.isNotEmpty) {
      final hour = int.tryParse(hourText) ?? 0;
      final minute =
          minuteText.isNotEmpty ? (int.tryParse(minuteText) ?? 0) : 0;

      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        widget.onTimeChanged(TimeOfDay(hour: hour, minute: minute));
        return;
      }
    }
    widget.onTimeChanged(null);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final inputStyle = typography.bodyLarge.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w600,
    );

    final hintStyle = inputStyle.copyWith(
      color: _isUnknown ? colors.border : colors.textTertiary,
    );

    final labelStyle = inputStyle.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: Text(
              widget.label!,
              style: typography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Hour
              SizedBox(
                width: 40,
                child: TextField(
                  controller: _hourController,
                  focusNode: _hourFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputStyle,
                  cursorColor: colors.textSecondary,
                  enabled: !_isUnknown,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    hintText: '00',
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Text('시', style: labelStyle),

              const SizedBox(width: 12),

              // Minute
              SizedBox(
                width: 40,
                child: TextField(
                  controller: _minuteController,
                  focusNode: _minuteFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputStyle,
                  cursorColor: colors.textSecondary,
                  enabled: !_isUnknown,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    hintText: '00',
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Text('분', style: labelStyle),
            ],
          ),
        ),
        if (widget.showUnknownOption) ...[
          const SizedBox(height: DSSpacing.md),
          GestureDetector(
            onTap: () {
              setState(() {
                _isUnknown = !_isUnknown;
                if (_isUnknown) {
                  _hourController.clear();
                  _minuteController.clear();
                  FocusScope.of(context).unfocus();
                  widget.onTimeChanged(const TimeOfDay(hour: 12, minute: 0));
                } else {
                  _hourFocus.requestFocus();
                  widget.onTimeChanged(null);
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isUnknown ? colors.accent : colors.textSecondary,
                      width: 2,
                    ),
                    color: _isUnknown ? colors.accent : Colors.transparent,
                  ),
                  child: _isUnknown
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '모르겠어요',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
