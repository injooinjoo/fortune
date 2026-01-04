import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/fortune_design_system.dart';
import '../../design_system/design_system.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';
import 'date_picker_utils.dart';

/// 📅 휠 방식 날짜 선택기 (iOS 스타일)
///
/// **특징**:
/// - CupertinoDatePicker 기반
/// - 모달 바텀시트
/// - 모바일 친화적
/// - iOS 네이티브 느낌
///
/// **사용 예시**:
/// ```dart
/// WheelDatePicker(
///   selectedDate: _birthDate,
///   onDateChanged: (date) => setState(() => _birthDate = date),
///   label: '생년월일',
/// )
/// ```
class WheelDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? label;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool showAge;

  const WheelDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
    this.label,
    this.minDate,
    this.maxDate,
    this.showAge = false,
  });

  @override
  State<WheelDatePicker> createState() => _WheelDatePickerState();
}

class _WheelDatePickerState extends State<WheelDatePicker> {
  late DateTime _tempDate;

  @override
  void initState() {
    super.initState();
    _tempDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(WheelDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDate != null &&
        !DatePickerUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      setState(() {
        _tempDate = widget.selectedDate!;
      });
    }
  }

  void _showWheelPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      isScrollControlled: true,
      builder: (context) => _buildWheelPickerModal(),
    );
  }

  Widget _buildWheelPickerModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // StatefulBuilder를 사용하여 bottom sheet 내부 상태 관리
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: isDark
                ? TossDesignSystem.grayDark900
                : TossDesignSystem.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXLarge),
            ),
          ),
          child: Column(
            children: [
              // 헤더
              Container(
                padding: AppSpacing.paddingAll16,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? TossDesignSystem.borderDark
                          : TossDesignSystem.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '취소',
                        style: DSTypography.bodyMedium.copyWith(
                          color: isDark
                              ? TossDesignSystem.textSecondaryDark
                              : TossDesignSystem.textSecondaryLight,
                        ),
                      ),
                    ),
                    Text(
                      widget.label ?? '날짜 선택',
                      style: DSTypography.headingSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onDateChanged(_tempDate);
                        Navigator.pop(context);
                      },
                      child: Text(
                        '완료',
                        style: DSTypography.bodyMedium.copyWith(
                          color: TossDesignSystem.tossBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 선택된 날짜 미리보기
              Container(
                padding: AppSpacing.paddingAll16,
                child: Column(
                  children: [
                    Text(
                      DatePickerUtils.formatKorean(_tempDate, showWeekday: true),
                      style: DSTypography.headingSmall,
                    ),
                    if (widget.showAge) ...[
                      const SizedBox(height: AppSpacing.spacing2),
                      Text(
                        '만 ${DatePickerUtils.calculateAge(_tempDate)}세',
                        style: DSTypography.bodyMedium.copyWith(
                          color: TossDesignSystem.tossBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 한국식 날짜 휠 피커 (년 → 월 → 일)
              Expanded(
                child: _buildKoreanDateWheels(isDark, setModalState),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 한국식 날짜 휠 피커 (년 → 월 → 일 순서)
  Widget _buildKoreanDateWheels(bool isDark, StateSetter setModalState) {
    final minYear = widget.minDate?.year ?? 1900;
    final maxYear = widget.maxDate?.year ?? DateTime.now().year;

    final years = List.generate(
      maxYear - minYear + 1,
      (index) => minYear + index,
    );

    final months = List.generate(12, (index) => index + 1);

    final daysInMonth = DatePickerUtils.getDaysInMonth(
      _tempDate.year,
      _tempDate.month,
    );
    final days = List.generate(daysInMonth, (index) => index + 1);

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: TossDesignSystem.tossBlue,
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: DSTypography.bodyLarge.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // 년 (Year)
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: years.indexOf(_tempDate.year),
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setModalState(() {
                  final newYear = years[index];
                  _tempDate = DatePickerUtils.createSafeDate(
                    newYear,
                    _tempDate.month,
                    _tempDate.day,
                  );
                });
              },
              children: years.map((year) {
                return Center(
                  child: Text(
                    '$year년',
                    style: DSTypography.bodyLarge,
                  ),
                );
              }).toList(),
            ),
          ),

          // 월 (Month)
          Expanded(
            flex: 1,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _tempDate.month - 1,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setModalState(() {
                  final newMonth = months[index];
                  _tempDate = DatePickerUtils.createSafeDate(
                    _tempDate.year,
                    newMonth,
                    _tempDate.day,
                  );
                });
              },
              children: months.map((month) {
                return Center(
                  child: Text(
                    '$month월',
                    style: DSTypography.bodyLarge,
                  ),
                );
              }).toList(),
            ),
          ),

          // 일 (Day)
          Expanded(
            flex: 1,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _tempDate.day - 1,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setModalState(() {
                  final newDay = days[index];
                  _tempDate = DateTime(
                    _tempDate.year,
                    _tempDate.month,
                    newDay,
                  );
                });
              },
              children: days.map((day) {
                return Center(
                  child: Text(
                    '$day일',
                    style: DSTypography.bodyLarge,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  int? _calculateAge() {
    if (!widget.showAge) return null;
    if (widget.selectedDate == null) return null;
    return DatePickerUtils.calculateAge(widget.selectedDate!);
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

        InkWell(
          onTap: _showWheelPicker,
          borderRadius: AppDimensions.borderRadiusLarge,
          child: Container(
            padding: AppSpacing.paddingAll16,
            decoration: BoxDecoration(
              color: isDark
                  ? TossDesignSystem.grayDark800
                  : TossDesignSystem.gray50,
              borderRadius: AppDimensions.borderRadiusLarge,
              border: Border.all(
                color: isDark
                    ? TossDesignSystem.borderDark
                    : TossDesignSystem.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.tossBlue,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedDate != null
                            ? DatePickerUtils.formatKorean(
                                widget.selectedDate!,
                              )
                            : '날짜를 선택해주세요',
                        style: DSTypography.bodyLarge.copyWith(
                          color: widget.selectedDate != null
                              ? (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.textPrimaryLight)
                              : (isDark
                                  ? TossDesignSystem.textSecondaryDark
                                  : TossDesignSystem.textSecondaryLight),
                          fontWeight: widget.selectedDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (age != null && age >= 0)
                        Text(
                          '만 $age세',
                          style: DSTypography.bodySmall.copyWith(
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.textSecondaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
