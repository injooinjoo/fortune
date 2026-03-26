import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/paper_runtime_chrome.dart';

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
    this.description =
        '사주와 인사이트 정확도를 높이기 위해 생년월일을 먼저 받아요. 시간을 모르면 낮 12시 기준으로 이어집니다.',
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
    final hasDisplayName = _displayNameController.text.trim().isNotEmpty ||
        !widget.requireDisplayName;
    final showCTA =
        _isDateValid && (_isTimeValid || _isTimeUnknown) && hasDisplayName;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
        child: Column(
          children: [
            if (widget.showBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
              )
            else
              const SizedBox(height: DSSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: DSSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.requireDisplayName) ...[
                      const PaperRuntimePill(
                        label: '대화에서 사용할 이름',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: DSSpacing.md),
                      PaperRuntimePanel(
                        elevated: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.md,
                          vertical: DSSpacing.xs,
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
                              color:
                                  colors.textTertiary.withValues(alpha: 0.72),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xl),
                    ],
                    Text(
                      widget.title,
                      style: typography.headingLarge.copyWith(
                        color: colors.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.6,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: DSSpacing.sm),
                    Text(
                      widget.description,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
                    const SizedBox(height: DSSpacing.xl),
                    const PaperRuntimePill(
                      label: '생년월일',
                      icon: Icons.cake_outlined,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildInputCard(
                            controller: _yearController,
                            focusNode: _yearFocus,
                            hintText: '연도',
                            inputStyle: inputStyle,
                            hintStyle: hintStyle,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        Expanded(
                          child: _buildInputCard(
                            controller: _monthController,
                            focusNode: _monthFocus,
                            hintText: '월',
                            inputStyle: inputStyle,
                            hintStyle: hintStyle,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        Expanded(
                          child: _buildInputCard(
                            controller: _dayController,
                            focusNode: _dayFocus,
                            hintText: '일',
                            inputStyle: inputStyle,
                            hintStyle: hintStyle,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: _showTime ? 1 : 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaperRuntimePill(
                            label: '태어난 시간',
                            icon: Icons.schedule_outlined,
                            emphasize: _isTimeUnknown,
                          ),
                          const SizedBox(height: DSSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputCard(
                                  controller: _timeController,
                                  focusNode: _timeFocus,
                                  hintText: '시',
                                  inputStyle: inputStyle,
                                  hintStyle: hintStyle,
                                  enabled: !_isTimeUnknown,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                ),
                              ),
                              const SizedBox(width: DSSpacing.sm),
                              Expanded(
                                child: _buildInputCard(
                                  controller: _minuteController,
                                  focusNode: _minuteFocus,
                                  hintText: '분',
                                  inputStyle: inputStyle,
                                  hintStyle: hintStyle,
                                  enabled: !_isTimeUnknown,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.md),
                          GestureDetector(
                            onTap: _toggleUnknownTime,
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _isTimeUnknown
                                        ? colors.textPrimary
                                        : colors.surface,
                                    borderRadius:
                                        BorderRadius.circular(DSRadius.smd),
                                    border: Border.all(
                                      color: _isTimeUnknown
                                          ? colors.textPrimary
                                          : colors.border,
                                    ),
                                  ),
                                  child: _isTimeUnknown
                                      ? Icon(
                                          Icons.check,
                                          size: 14,
                                          color: colors.ctaForeground,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: DSSpacing.sm),
                                Text(
                                  '태어난 시간을 모르겠어요',
                                  style: typography.bodyMedium.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.md),
              child: DSButton.primary(
                text: widget.ctaLabel,
                onPressed: showCTA ? widget.onNext : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required TextStyle inputStyle,
    required TextStyle hintStyle,
    required List<TextInputFormatter> inputFormatters,
    bool enabled = true,
  }) {
    final colors = context.colors;

    return PaperRuntimePanel(
      elevated: false,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: inputStyle,
        cursorColor: colors.textPrimary,
        enabled: enabled,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle.copyWith(
            color: enabled
                ? hintStyle.color
                : colors.textTertiary.withValues(alpha: 0.45),
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
    );
  }

  void _toggleUnknownTime() {
    setState(() {
      _isTimeUnknown = !_isTimeUnknown;
      if (_isTimeUnknown) {
        _timeController.clear();
        _minuteController.clear();
        _isTimeValid = true;
        FocusScope.of(context).unfocus();
        widget.onBirthTimeChanged?.call(const TimeOfDay(hour: 12, minute: 0));
      } else {
        _isTimeValid = false;
        _timeFocus.requestFocus();
      }
    });
  }
}
