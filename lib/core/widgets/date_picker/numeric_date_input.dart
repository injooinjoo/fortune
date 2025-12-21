import 'package:flutter/material.dart';
import '../../theme/fortune_design_system.dart';
import '../../design_system/design_system.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';
import 'date_picker_utils.dart';

/// 📅 숫자 키패드 날짜 입력 (YYYYMMDD 방식)
///
/// **특징**:
/// - 숫자 키패드로 빠른 입력
/// - 자동 포맷팅 (YYYY년 MM월 DD일)
/// - 4자리(년) + 2자리(월) + 2자리(일) 자동 인식
/// - 백스페이스로 역순 삭제 (일 → 월 → 년)
/// - 입력 위치 시각적 표시
///
/// **사용 예시**:
/// ```dart
/// NumericDateInput(
///   selectedDate: _partnerBirthDate,
///   onDateChanged: (date) => setState(() => _partnerBirthDate = date),
///   label: '상대방 생년월일',
/// )
/// ```
class NumericDateInput extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? label;
  final String? hintText;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool showAge;

  const NumericDateInput({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
    this.label,
    this.hintText,
    this.minDate,
    this.maxDate,
    this.showAge = false,
  });

  @override
  State<NumericDateInput> createState() => _NumericDateInputState();
}

class _NumericDateInputState extends State<NumericDateInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _rawInput = ''; // 숫자만 (예: "20001121")
  String _prevDisplayText = ''; // 백스페이스 감지용
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // 초기값 설정
    if (widget.selectedDate != null) {
      final date = widget.selectedDate!;
      _rawInput = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      _controller.text = _formatDisplay(_rawInput);
      _prevDisplayText = _controller.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumericDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDate != null &&
        !DatePickerUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      final date = widget.selectedDate!;
      _rawInput = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      _controller.text = _formatDisplay(_rawInput);
      _prevDisplayText = _controller.text;
    }
  }

  /// 입력된 숫자를 "YYYY년 MM월 DD일" 형식으로 변환
  String _formatDisplay(String input) {
    if (input.isEmpty) return '';

    final buffer = StringBuffer();
    final length = input.length;

    if (length <= 4) {
      // 년도 입력 중 (1~4자리)
      buffer.write(input);
      if (length == 4) buffer.write('년');
    } else if (length <= 6) {
      // 월 입력 중 (5~6자리)
      buffer.write('${input.substring(0, 4)}년 ');
      buffer.write(input.substring(4));
      if (length == 6) buffer.write('월');
    } else if (length <= 8) {
      // 일 입력 중 (7~8자리)
      buffer.write('${input.substring(0, 4)}년 ');
      buffer.write('${input.substring(4, 6)}월 ');
      buffer.write(input.substring(6));
      if (length == 8) buffer.write('일');
    }

    return buffer.toString();
  }

  /// 입력 유효성 검사 및 콜백 호출
  void _validateAndNotify() {
    setState(() {
      _errorMessage = null;
    });

    if (_rawInput.length != 8) {
      return; // 아직 입력 중
    }

    try {
      final year = int.parse(_rawInput.substring(0, 4));
      final month = int.parse(_rawInput.substring(4, 6));
      final day = int.parse(_rawInput.substring(6, 8));

      // 유효한 날짜인지 확인
      if (!DatePickerUtils.isValidDate(year, month, day)) {
        setState(() {
          _errorMessage = '올바른 날짜를 입력해주세요';
        });
        return;
      }

      final date = DateTime(year, month, day);

      // 범위 체크
      if (!DatePickerUtils.isInRange(
        date,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
      )) {
        final minYear = widget.minDate?.year ?? 1900;
        final maxYear = widget.maxDate?.year ?? DateTime.now().year;
        setState(() {
          _errorMessage = '$minYear년 ~ $maxYear년 사이 날짜를 입력해주세요';
        });
        return;
      }

      // 유효한 날짜 → 콜백 호출
      widget.onDateChanged(date);
    } catch (e) {
      setState(() {
        _errorMessage = '올바른 날짜를 입력해주세요';
      });
    }
  }

  /// 숫자 입력 처리
  void _handleInput(String value) {
    // 숫자만 추출
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    // 백스페이스 감지: 이전 텍스트보다 짧아졌고 숫자 개수가 같거나 더 많은 경우
    // (한글 "년/월/일"만 삭제된 경우) → 마지막 숫자 수동 삭제
    if (value.length < _prevDisplayText.length &&
        numbers.length >= _rawInput.length &&
        _rawInput.isNotEmpty) {
      setState(() {
        _rawInput = _rawInput.substring(0, _rawInput.length - 1);
        _controller.text = _formatDisplay(_rawInput);
        _prevDisplayText = _controller.text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _errorMessage = null;
      });
      return;
    }

    if (numbers.length > 8) {
      return; // 최대 8자리 (YYYYMMDD)
    }

    setState(() {
      _rawInput = numbers;
      _controller.text = _formatDisplay(_rawInput);
      _prevDisplayText = _controller.text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });

    _validateAndNotify();
  }

  /// 커서 위치 계산 (입력 위치 표시)
  String _getPlaceholder() {
    final length = _rawInput.length;

    if (length == 0) return 'YYYY년 MM월 DD일';
    if (length < 4) return '${_rawInput}_년 MM월 DD일';
    if (length == 4) return '${_rawInput.substring(0, 4)}년 MM월 DD일';
    if (length < 6) return '${_rawInput.substring(0, 4)}년 ${_rawInput.substring(4)}_월 DD일';
    if (length == 6) return '${_rawInput.substring(0, 4)}년 ${_rawInput.substring(4, 6)}월 DD일';
    if (length < 8) return '${_rawInput.substring(0, 4)}년 ${_rawInput.substring(4, 6)}월 ${_rawInput.substring(6)}_일';

    return _formatDisplay(_rawInput);
  }

  int? _calculateAge() {
    if (!widget.showAge) return null;
    if (_rawInput.length != 8) return null;

    try {
      final year = int.parse(_rawInput.substring(0, 4));
      final month = int.parse(_rawInput.substring(4, 6));
      final day = int.parse(_rawInput.substring(6, 8));
      final date = DateTime(year, month, day);
      return DatePickerUtils.calculateAge(date);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final age = _calculateAge();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Text(
              widget.label!,
              style: DSTypography.labelMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ),

        // 입력 필드
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: isDark
                ? TossDesignSystem.grayDark800
                : TossDesignSystem.gray50,
            borderRadius: AppDimensions.borderRadiusLarge,
            border: Border.all(
              color: _errorMessage != null
                  ? TossDesignSystem.errorRed
                  : (isDark
                      ? TossDesignSystem.borderDark
                      : TossDesignSystem.borderLight),
              width: _errorMessage != null ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_calendar_outlined,
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.tossBlue,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.spacing3),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      // inputFormatters 제거 - _handleInput에서 숫자 필터링 및 길이 제한 처리
                      style: DSTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? 'YYYY년 MM월 DD일',
                        hintStyle: DSTypography.bodyLarge.copyWith(
                          color: isDark
                              ? TossDesignSystem.textSecondaryDark
                              : TossDesignSystem.textSecondaryLight,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _handleInput,
                    ),
                  ),
                  if (_rawInput.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark
                            ? TossDesignSystem.textSecondaryDark
                            : TossDesignSystem.textSecondaryLight,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _rawInput = '';
                          _controller.clear();
                          _errorMessage = null;
                        });
                      },
                    ),
                ],
              ),

              // 입력 가이드 (플레이스홀더)
              if (_rawInput.isNotEmpty && _rawInput.length < 8)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.spacing2),
                  child: Text(
                    _getPlaceholder(),
                    style: DSTypography.bodySmall.copyWith(
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark.withValues(alpha: 0.5)
                          : TossDesignSystem.textSecondaryLight.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

              // 나이 표시
              if (age != null && age >= 0 && _errorMessage == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.spacing2),
                  child: Text(
                    '만 $age세',
                    style: DSTypography.bodyMedium.copyWith(
                      color: TossDesignSystem.tossBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 에러 메시지
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.spacing2),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: TossDesignSystem.errorRed,
                  size: 16,
                ),
                SizedBox(width: AppSpacing.spacing1),
                Text(
                  _errorMessage!,
                  style: DSTypography.bodySmall.copyWith(
                    color: TossDesignSystem.errorRed,
                  ),
                ),
              ],
            ),
          ),

        // 입력 도움말
        if (_errorMessage == null && _rawInput.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.spacing2),
            child: Text(
              '예: 20001121 → 2000년 11월 21일',
              style: DSTypography.bodySmall.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ),
      ],
    );
  }
}
