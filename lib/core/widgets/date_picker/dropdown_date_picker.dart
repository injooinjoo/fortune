import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/design_system.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_animations.dart';
import '../../../shared/glassmorphism/glass_container.dart';
import 'date_picker_utils.dart';

/// 📅 드롭다운 방식 날짜 선택기 (한국식)
///
/// **특징**:
/// - 년/월/일 드롭다운
/// - 확장/축소 애니메이션
/// - 나이 자동 계산 옵션
/// - GlassContainer UI
///
/// **사용 예시**:
/// ```dart
/// DropdownDatePicker(
///   selectedDate: _birthDate,
///   onDateChanged: (date) => setState(() => _birthDate = date),
///   label: '생년월일',
///   showAge: true,
/// )
/// ```
class DropdownDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? label;
  final bool showAge;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool initiallyExpanded;

  const DropdownDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
    this.label,
    this.showAge = true,
    this.minDate,
    this.maxDate,
    this.initiallyExpanded = false,
  });

  @override
  State<DropdownDatePicker> createState() => _DropdownDatePickerState();
}

class _DropdownDatePickerState extends State<DropdownDatePicker> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  late bool isExpanded;

  late List<int> years;
  List<int> get months => DatePickerUtils.generateMonths();
  List<int> get days => DatePickerUtils.generateDays(selectedYear, selectedMonth);

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;

    // 년도 범위 설정
    final minYear = widget.minDate?.year ?? (DateTime.now().year - 99);
    final maxYear = widget.maxDate?.year ?? DateTime.now().year;
    years = DatePickerUtils.generateYearRange(
      startYear: minYear,
      endYear: maxYear,
    );

    // 초기 날짜 설정
    final date = widget.selectedDate ?? DateTime.now();
    selectedYear = date.year;
    selectedMonth = date.month;
    selectedDay = date.day;
  }

  @override
  void didUpdateWidget(DropdownDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // selectedDate가 외부에서 변경되면 동기화
    if (widget.selectedDate != null &&
        !DatePickerUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      final date = widget.selectedDate!;
      setState(() {
        selectedYear = date.year;
        selectedMonth = date.month;
        selectedDay = date.day;
      });
    }
  }

  void _updateDate() {
    // 선택된 월의 일수 확인 및 조정
    final newDate = DatePickerUtils.createSafeDate(
      selectedYear,
      selectedMonth,
      selectedDay,
    );

    // 범위 체크
    if (!DatePickerUtils.isInRange(
      newDate,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    )) {
      return;
    }

    // 날짜가 변경되면 콜백 호출
    if (!DatePickerUtils.isSameDay(newDate, widget.selectedDate)) {
      widget.onDateChanged(newDate);
    }
  }

  int? _calculateAge() {
    try {
      final selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
      return DatePickerUtils.calculateAge(selectedDate);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = widget.showAge ? _calculateAge() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Text(
              widget.label!,
              style: context.labelMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),

        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: GlassContainer(
            padding: AppSpacing.paddingAll16,
            borderRadius: AppDimensions.borderRadiusLarge,
            blur: 10,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: context.isDark
                      ? context.colors.textSecondary
                      : context.colors.accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DatePickerUtils.formatKorean(
                          DateTime(selectedYear, selectedMonth, selectedDay),
                        ),
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (age != null && age >= 0)
                        Text(
                          '만 $age세',
                          style: context.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: AppAnimations.durationShort,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedContainer(
          duration: AppAnimations.durationMedium,
          height: isExpanded ? null : 0,
          child: AnimatedOpacity(
            duration: AppAnimations.durationShort,
            opacity: isExpanded ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.small),
              child: GlassContainer(
                padding: AppSpacing.paddingAll16,
                borderRadius: AppDimensions.borderRadiusLarge,
                blur: 10,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: '년',
                            value: selectedYear,
                            items: years,
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value!;
                                _updateDate();
                              });
                            },
                            suffix: '년',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing3),
                        Expanded(
                          child: _buildDropdown(
                            label: '월',
                            value: selectedMonth,
                            items: months,
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value!;
                                _updateDate();
                              });
                            },
                            suffix: '월',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing3),
                        Expanded(
                          child: _buildDropdown(
                            label: '일',
                            value: selectedDay,
                            items: days,
                            onChanged: (value) {
                              setState(() {
                                selectedDay = value!;
                                _updateDate();
                              });
                            },
                            suffix: '일',
                          ),
                        ),
                      ],
                    ),
                    if (age != null && age >= 0) ...[
                      const SizedBox(height: AppSpacing.spacing4),
                      Container(
                        padding: AppSpacing.paddingAll12,
                        decoration: BoxDecoration(
                          color: DSColors.accentDark.withValues(alpha: 0.1),
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cake_rounded,
                              size: AppDimensions.iconSizeSmall,
                              color: DSColors.accentDark,
                            ),
                            const SizedBox(width: AppSpacing.spacing2),
                            Text(
                              '나이: $age세',
                              style: context.bodyMedium.copyWith(
                                color: DSColors.accentDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                          ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<int> items,
    required Function(int?) onChanged,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppDimensions.borderRadiusSmall,
            border: Border.all(
              color: context.colors.border,
            ),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            isDense: true,
            underline: const SizedBox(),
            dropdownColor: context.colors.surface,
            items: items.map((item) {
              return DropdownMenuItem<int>(
                value: item,
                child: Text(
                  '$item$suffix',
                  style: context.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
