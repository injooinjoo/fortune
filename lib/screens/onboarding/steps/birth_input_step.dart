import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';

class BirthInputStep extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(DateTime) onBirthDateChanged;
  final Function(TimeOfDay)? onBirthTimeChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool showBackButton;
  final String title;
  final String description;
  final String ctaLabel;
  final bool requireDisplayName;
  final String initialDisplayName;
  final ValueChanged<String>? onDisplayNameChanged;

  const BirthInputStep({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onBirthDateChanged,
    this.onBirthTimeChanged,
    required this.onNext,
    required this.onBack,
    this.showBackButton = true,
    this.title = '언제 태어나셨어요?',
    this.description = '더 정확한 인사이트를 위해 알려주세요',
    this.ctaLabel = '다음',
    this.requireDisplayName = false,
    this.initialDisplayName = '',
    this.onDisplayNameChanged,
  });

  @override
  ConsumerState<BirthInputStep> createState() => _BirthInputStepState();
}

class _BirthInputStepState extends ConsumerState<BirthInputStep> {
  final _displayNameController = TextEditingController();
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _timeController = TextEditingController();
  final _minuteController = TextEditingController();

  final _yearFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _dayFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _minuteFocus = FocusNode();

  // ignore: unused_field
  final String _prevYear = '';
  String _prevMonth = '';
  String _prevDay = '';
  String _prevTime = '';
  String _prevMinute = '';

  bool _showMonth = false;
  bool _showDay = false;
  bool _showTime = false;
  bool _isDateValid = false;
  bool _isTimeValid = false;
  bool _isTimeUnknown = false;

  TextStyle? _inputStyle;
  TextStyle? _hintStyle;
  TextStyle? _labelStyle;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.initialDisplayName;
    _displayNameController.addListener(() {
      widget.onDisplayNameChanged?.call(_displayNameController.text.trim());
      if (widget.requireDisplayName && mounted) {
        setState(() {});
      }
    });

    if (widget.initialDate != null) {
      _yearController.text = widget.initialDate!.year.toString();
      _monthController.text =
          widget.initialDate!.month.toString().padLeft(2, '0');
      _dayController.text = widget.initialDate!.day.toString().padLeft(2, '0');
      _showMonth = true;
      _showDay = true;
      _isDateValid = true;
      _showTime = true;
    }

    if (widget.initialTime != null) {
      _timeController.text = '${widget.initialTime!.hour}';
      _minuteController.text =
          widget.initialTime!.minute.toString().padLeft(2, '0');
      _isTimeValid = true;
    }

    _yearController.addListener(() {
      final text = _yearController.text;
      _validateDate();
      if (text.length == 4 && _yearFocus.hasFocus) {
        if (!_showMonth) setState(() => _showMonth = true);
        Future.microtask(() {
          if (mounted) _monthFocus.requestFocus();
        });
      }
    });

    _monthController.addListener(() {
      final text = _monthController.text;
      if (text.isEmpty && _prevMonth.isNotEmpty && _monthFocus.hasFocus) {
        Future.microtask(() {
          if (!mounted) return;
          if (_yearController.text.isNotEmpty) {
            _yearController.text = _yearController.text
                .substring(0, _yearController.text.length - 1);
          }
          _yearFocus.requestFocus();
        });
      }
      _prevMonth = text;
      _validateDate();
      if (text.length == 2 && _monthFocus.hasFocus) {
        if (!_showDay) setState(() => _showDay = true);
        Future.microtask(() {
          if (mounted) _dayFocus.requestFocus();
        });
      }
    });

    _dayController.addListener(() {
      final text = _dayController.text;
      if (text.isEmpty && _prevDay.isNotEmpty && _dayFocus.hasFocus) {
        Future.microtask(() {
          if (!mounted) return;
          if (_monthController.text.isNotEmpty) {
            _monthController.text = _monthController.text
                .substring(0, _monthController.text.length - 1);
          }
          _monthFocus.requestFocus();
        });
      }
      _prevDay = text;
      _validateDate();
      if (text.length == 2 && _dayFocus.hasFocus && _isDateValid) {
        if (!_showTime) setState(() => _showTime = true);
        Future.microtask(() {
          if (mounted) _timeFocus.requestFocus();
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
      if (text.isEmpty &&
          _prevTime.isNotEmpty &&
          !_isTimeUnknown &&
          _timeFocus.hasFocus) {
        Future.microtask(() {
          if (!mounted) return;
          if (_dayController.text.isNotEmpty) {
            _dayController.text = _dayController.text
                .substring(0, _dayController.text.length - 1);
          }
          _dayFocus.requestFocus();
        });
      }
      _prevTime = text;
      if (text.length == 2 && _timeFocus.hasFocus) {
        final hour = int.tryParse(text) ?? 0;
        if (hour >= 0 && hour <= 23) {
          Future.microtask(() {
            if (mounted) _minuteFocus.requestFocus();
          });
        }
      }
      _onTimeChanged();
    });

    _minuteController.addListener(() {
      final text = _minuteController.text;
      if (text.isEmpty &&
          _prevMinute.isNotEmpty &&
          !_isTimeUnknown &&
          _minuteFocus.hasFocus) {
        Future.microtask(() {
          if (!mounted) return;
          if (_timeController.text.isNotEmpty) {
            _timeController.text = _timeController.text
                .substring(0, _timeController.text.length - 1);
          }
          _timeFocus.requestFocus();
        });
      }
      _prevMinute = text;
      _onTimeChanged();
    });

    _minuteFocus.addListener(() {
      if (!_minuteFocus.hasFocus && _minuteController.text.isNotEmpty) {
        final minute = int.tryParse(_minuteController.text) ?? 0;
        if (minute >= 0 && minute <= 59) {
          _minuteController.text = minute.toString().padLeft(2, '0');
        }
      }
    });

    Future.microtask(() {
      if (mounted) _yearFocus.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStyles();
  }

  void _updateStyles() {
    final typography = context.typography;
    final colors = context.colors;
    _inputStyle = typography.displaySmall.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    _hintStyle = typography.displaySmall.copyWith(
      color: colors.textTertiary,
      fontWeight: FontWeight.w600,
    );
    _labelStyle = typography.displaySmall.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w500,
    );
  }

  void _validateDate() {
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
        if (date.year == year &&
            date.month == month &&
            date.day == day &&
            date.isBefore(DateTime.now())) {
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
      } catch (e) {
        debugPrint('[BirthInput] 날짜 파싱 실패: $e');
      }
    }
    setState(() => _isDateValid = false);
  }

  void _onTimeChanged() {
    final hourText = _timeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final minuteText = _minuteController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (hourText.isNotEmpty) {
      final hour = int.tryParse(hourText) ?? 0;
      final minute =
          minuteText.isNotEmpty ? (int.tryParse(minuteText) ?? 0) : 0;

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
    _displayNameController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _minuteController.dispose();
    _yearFocus.dispose();
    _monthFocus.dispose();
    _dayFocus.dispose();
    _timeFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final inputStyle = _inputStyle ??
        typography.displaySmall.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        );
    final hintStyle = _hintStyle ??
        typography.displaySmall.copyWith(
          color: colors.textTertiary,
          fontWeight: FontWeight.w600,
        );
    final labelStyle = _labelStyle ??
        typography.displaySmall.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w500,
        );

    final hasDisplayName = _displayNameController.text.trim().isNotEmpty ||
        !widget.requireDisplayName;
    final showCTA =
        _isDateValid && (_isTimeValid || _isTimeUnknown) && hasDisplayName;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            if (widget.showBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: widget.showBackButton ? 24 : 48),

                    if (widget.requireDisplayName) ...[
                      Text(
                        '대화에서 불릴 이름',
                        style: typography.labelLarge.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius:
                              BorderRadius.circular(context.radius.xl),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.72),
                          ),
                        ),
                        child: TextField(
                          controller: _displayNameController,
                          textCapitalization: TextCapitalization.words,
                          cursorColor: colors.textPrimary,
                          style: typography.headingSmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: '이름을 입력해주세요',
                            hintStyle: typography.headingSmall.copyWith(
                              color: colors.textTertiary.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Title
                    Text(
                      widget.title,
                      style: typography.headingLarge.copyWith(
                        color: colors.textPrimary,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 12),
                    Text(
                      widget.description,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textTertiary,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: 56),

                    // Date Input - Progressive reveal
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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

                          // Month
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
                            ),
                            Text('월', style: labelStyle),
                          ],

                          // Day
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
                            ),
                            Text('일', style: labelStyle),
                          ],
                        ],
                      ),
                    ),

                    // Time Input
                    if (_showTime) ...[
                      const SizedBox(height: 56),
                      Center(
                        child: Text(
                          '태어난 시간을 알려주세요',
                          style: typography.bodyMedium
                              .copyWith(color: colors.textSecondary),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
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
                                    color: _isTimeUnknown
                                        ? colors.border
                                        : colors.textTertiary,
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
                                    color: _isTimeUnknown
                                        ? colors.border
                                        : colors.textTertiary,
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
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isTimeUnknown = !_isTimeUnknown;
                              if (_isTimeUnknown) {
                                _timeController.clear();
                                _minuteController.clear();
                                _isTimeValid = true;
                                FocusScope.of(context).unfocus();
                                widget.onBirthTimeChanged?.call(
                                    const TimeOfDay(hour: 12, minute: 0));
                              } else {
                                _isTimeValid = false;
                                _timeFocus.requestFocus();
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _isTimeUnknown
                                        ? colors.textPrimary
                                        : colors.border,
                                    width: 1.5,
                                  ),
                                  color: _isTimeUnknown
                                      ? colors.textPrimary
                                      : colors.background,
                                ),
                                child: _isTimeUnknown
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: colors.ctaForeground,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text('모르겠어요',
                                  style: typography.bodyMedium
                                      .copyWith(color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ],

                    const SizedBox(height: 56),

                    // CTA Button
                    if (showCTA)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: DSButton.primary(
                          text: widget.ctaLabel,
                          onPressed: widget.onNext,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
