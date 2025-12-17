import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/providers/user_settings_provider.dart';

class BirthInputStep extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(DateTime) onBirthDateChanged;
  final Function(TimeOfDay)? onBirthTimeChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BirthInputStep({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onBirthDateChanged,
    this.onBirthTimeChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<BirthInputStep> createState() => _BirthInputStepState();
}

class _BirthInputStepState extends ConsumerState<BirthInputStep> {
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _timeController = TextEditingController();
  final _minuteController = TextEditingController(); // ✅ 분 입력 컨트롤러

  final _yearFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _dayFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _minuteFocus = FocusNode(); // ✅ 분 입력 포커스

  // For backspace detection
  // ignore: unused_field
  String _prevYear = '';
  String _prevMonth = '';
  String _prevDay = '';
  String _prevTime = '';
  String _prevMinute = ''; // ✅ 분 백스페이스 감지용

  bool _showMonth = false;
  bool _showDay = false;
  bool _showTime = false;
  bool _isDateValid = false;
  bool _isTimeValid = false;
  bool _isTimeUnknown = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      _yearController.text = widget.initialDate!.year.toString();
      _monthController.text = widget.initialDate!.month.toString().padLeft(2, '0');
      _dayController.text = widget.initialDate!.day.toString().padLeft(2, '0');
      _showMonth = true;
      _showDay = true;
      _isDateValid = true;
      _showTime = true;
    }

    if (widget.initialTime != null) {
      _timeController.text = '${widget.initialTime!.hour}';
      _minuteController.text = widget.initialTime!.minute.toString().padLeft(2, '0'); // ✅ 분 초기화
      _isTimeValid = true;
    }

    _yearController.addListener(() {
      final text = _yearController.text;
      _validateDate();

      // Auto-advance to month ONLY when exactly 4 digits
      if (text.length == 4 && _yearFocus.hasFocus) {
        if (!_showMonth) setState(() => _showMonth = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _monthFocus.requestFocus();
        });
      }
    });

    _monthController.addListener(() {
      final text = _monthController.text;

      // Backspace when empty → go back to year AND delete last digit
      if (text.isEmpty && _prevMonth.isNotEmpty && _monthFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_yearController.text.isNotEmpty) {
            _yearController.text = _yearController.text.substring(0, _yearController.text.length - 1);
          }
          _yearFocus.requestFocus();
        });
      }

      _prevMonth = text;
      _validateDate();

      // Auto-advance to day ONLY when exactly 2 digits
      if (text.length == 2 && _monthFocus.hasFocus) {
        if (!_showDay) setState(() => _showDay = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dayFocus.requestFocus();
        });
      }
    });

    _dayController.addListener(() {
      final text = _dayController.text;

      // Backspace when empty → go back to month AND delete last digit
      if (text.isEmpty && _prevDay.isNotEmpty && _dayFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_monthController.text.isNotEmpty) {
            _monthController.text = _monthController.text.substring(0, _monthController.text.length - 1);
          }
          _monthFocus.requestFocus();
        });
      }

      _prevDay = text;
      _validateDate();

      // Auto-advance to time ONLY when exactly 2 digits AND date is valid
      if (text.length == 2 && _dayFocus.hasFocus && _isDateValid) {
        if (!_showTime) setState(() => _showTime = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _timeFocus.requestFocus();
        });
      }
    });

    _monthFocus.addListener(() {
      if (!_monthFocus.hasFocus && _monthController.text.isNotEmpty) {
        final month = int.tryParse(_monthController.text) ?? 0;
        if (month > 0 && month <= 12) {
          _monthController.text = month.toString().padLeft(2, '0');
        }
      }
    });

    _dayFocus.addListener(() {
      if (!_dayFocus.hasFocus && _dayController.text.isNotEmpty) {
        final day = int.tryParse(_dayController.text) ?? 0;
        if (day > 0 && day <= 31) {
          _dayController.text = day.toString().padLeft(2, '0');
        }
      }
    });

    _timeController.addListener(() {
      final text = _timeController.text;

      // Backspace when empty → go back to day AND delete last digit
      if (text.isEmpty && _prevTime.isNotEmpty && !_isTimeUnknown && _timeFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_dayController.text.isNotEmpty) {
            _dayController.text = _dayController.text.substring(0, _dayController.text.length - 1);
          }
          _dayFocus.requestFocus();
        });
      }

      _prevTime = text;

      // ✅ 시간 2자리 입력 시 분으로 자동 이동
      if (text.length == 2 && _timeFocus.hasFocus) {
        final hour = int.tryParse(text) ?? 0;
        if (hour >= 0 && hour <= 23) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _minuteFocus.requestFocus();
          });
        }
      }

      _onTimeChanged();
    });

    // ✅ 분 입력 리스너 추가
    _minuteController.addListener(() {
      final text = _minuteController.text;

      // Backspace when empty → go back to hour AND delete last digit
      if (text.isEmpty && _prevMinute.isNotEmpty && !_isTimeUnknown && _minuteFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_timeController.text.isNotEmpty) {
            _timeController.text = _timeController.text.substring(0, _timeController.text.length - 1);
          }
          _timeFocus.requestFocus();
        });
      }

      _prevMinute = text;
      _onTimeChanged();
    });

    // ✅ 분 포커스 해제 시 패딩 추가 (예: "5" → "05")
    _minuteFocus.addListener(() {
      if (!_minuteFocus.hasFocus && _minuteController.text.isNotEmpty) {
        final minute = int.tryParse(_minuteController.text) ?? 0;
        if (minute >= 0 && minute <= 59) {
          _minuteController.text = minute.toString().padLeft(2, '0');
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _yearFocus.requestFocus());
  }

  void _validateDate() {
    final year = int.tryParse(_yearController.text);
    final month = int.tryParse(_monthController.text);
    final day = int.tryParse(_dayController.text);

    if (year != null && month != null && day != null &&
        year >= 1900 && year <= DateTime.now().year &&
        month >= 1 && month <= 12 &&
        day >= 1 && day <= 31) {
      try {
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day && date.isBefore(DateTime.now())) {
          setState(() {
            _isDateValid = true;
            if (!_showTime) {
              _showTime = true;
              Future.delayed(300.ms, () => _timeFocus.requestFocus());
            }
          });
          widget.onBirthDateChanged(date);
          return;
        }
      } catch (_) {}
    }
    setState(() => _isDateValid = false);
  }

  void _onTimeChanged() {
    final hourText = _timeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final minuteText = _minuteController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (hourText.isNotEmpty) {
      final hour = int.tryParse(hourText) ?? 0;
      // ✅ 분은 입력하지 않아도 0으로 처리 (선택적 입력)
      final minute = minuteText.isNotEmpty ? (int.tryParse(minuteText) ?? 0) : 0;

      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        setState(() => _isTimeValid = true);
        widget.onBirthTimeChanged?.call(TimeOfDay(hour: hour, minute: minute));
      } else {
        setState(() => _isTimeValid = false);
      }
    } else {
      setState(() => _isTimeValid = false);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _minuteController.dispose(); // ✅ 분 컨트롤러 정리
    _yearFocus.dispose();
    _monthFocus.dispose();
    _dayFocus.dispose();
    _timeFocus.dispose();
    _minuteFocus.dispose(); // ✅ 분 포커스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = ref.watch(typographyThemeProvider);
    final colors = context.colors;
    final inputStyle = typography.displaySmall.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    final hintStyle = typography.displaySmall.copyWith(
      color: colors.textTertiary,
      fontWeight: FontWeight.w600,
    );
    final labelStyle = typography.displaySmall.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: MediaQuery.of(context).size.height * 0.15,
              bottom: 24,
            ),
            child: Column(
              children: [
                Text(
                  '생년월일을 알려주세요',
                  style: typography.headingSmall.copyWith(color: colors.textSecondary),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 48),

                // Date Input - Progressive reveal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Year
                    SizedBox(
                      width: 90,
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

                    // Month - fade in after year
                    if (_showMonth) ...[
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 50,
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
                      ).animate().fadeIn(duration: 300.ms),
                      Text('월', style: labelStyle).animate().fadeIn(duration: 300.ms),
                    ],

                    // Day - fade in after month
                    if (_showDay) ...[
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 50,
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
                      ).animate().fadeIn(duration: 300.ms),
                      Text('일', style: labelStyle).animate().fadeIn(duration: 300.ms),
                    ],
                  ],
                ),

                // Time Input - fade in after date complete
                if (_showTime) ...[
                  const SizedBox(height: 48),
                  Text(
                    '태어난 시간을 알려주세요',
                    style: typography.headingSmall.copyWith(color: colors.textSecondary),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // 시간 입력
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _timeController,
                          focusNode: _timeFocus,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: inputStyle,
                          cursorColor: colors.textSecondary,
                          enabled: !_isTimeUnknown,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText: '00',
                            hintStyle: hintStyle.copyWith(
                              color: _isTimeUnknown ? colors.border : colors.textTertiary,
                            ),
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

                      // ✅ 분 입력 추가
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _minuteController,
                          focusNode: _minuteFocus,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: inputStyle,
                          cursorColor: colors.textSecondary,
                          enabled: !_isTimeUnknown,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText: '00',
                            hintStyle: hintStyle.copyWith(
                              color: _isTimeUnknown ? colors.border : colors.textTertiary,
                            ),
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
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTimeUnknown = !_isTimeUnknown;
                        if (_isTimeUnknown) {
                          _timeController.clear();
                          _minuteController.clear(); // ✅ 분 컨트롤러도 초기화
                          _isTimeValid = true;
                          FocusScope.of(context).unfocus();
                          widget.onBirthTimeChanged?.call(const TimeOfDay(hour: 12, minute: 0));
                        } else {
                          _isTimeValid = false;
                          _timeFocus.requestFocus();
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isTimeUnknown ? colors.accent : colors.textSecondary,
                              width: 2,
                            ),
                            color: _isTimeUnknown ? colors.accent : Colors.transparent,
                          ),
                          child: _isTimeUnknown
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text('모르겠어요', style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],

                const SizedBox(height: 56),

                // Next Button
                if (_isDateValid && (_isTimeValid || _isTimeUnknown))
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.ctaBackground,
                        foregroundColor: colors.ctaForeground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.md)),
                        elevation: 0,
                      ),
                      child: Text(
                        '다음',
                        style: typography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ctaForeground,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
