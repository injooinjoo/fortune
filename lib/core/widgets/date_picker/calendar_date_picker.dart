import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/fortune_design_system.dart';
import '../../design_system/design_system.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';
import 'date_picker_utils.dart';

/// 📅 캘린더 방식 날짜 선택기
///
/// **특징**:
/// - TableCalendar 기반 월간 캘린더
/// - 운세 정보 표시 옵션 (길흉 점수, 손없는날 등)
/// - 휴일 표시
/// - 시각적 날짜 선택
///
/// **사용 예시**:
/// ```dart
/// CalendarDatePickerWidget(
///   selectedDate: _moveDate,
///   onDateChanged: (date) => setState(() => _moveDate = date),
///   luckyScores: {DateTime(2025, 1, 15): 0.9},
///   auspiciousDays: [DateTime(2025, 1, 20)],
/// )
/// ```
class CalendarDatePickerWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? minDate;
  final DateTime? maxDate;

  // 운세 정보 (선택)
  final Map<DateTime, double>? luckyScores; // 0.0 ~ 1.0
  final List<DateTime>? auspiciousDays; // 손없는날
  final Map<DateTime, String>? holidayMap; // 휴일

  const CalendarDatePickerWidget({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
    this.minDate,
    this.maxDate,
    this.luckyScores,
    this.auspiciousDays,
    this.holidayMap,
  });

  @override
  State<CalendarDatePickerWidget> createState() =>
      _CalendarDatePickerWidgetState();
}

class _CalendarDatePickerWidgetState extends State<CalendarDatePickerWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(CalendarDatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDate != null &&
        !DatePickerUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      setState(() {
        _focusedDay = widget.selectedDate!;
        _selectedDay = widget.selectedDate;
      });
    }
  }

  Color _getDayColor(DateTime day) {
    final normalizedDay = DatePickerUtils.normalizeDate(day);

    // 손없는날 체크
    if (widget.auspiciousDays?.any((d) =>
            DatePickerUtils.isSameDay(d, normalizedDay)) ??
        false) {
      return TossDesignSystem.warningOrange.withValues(alpha: 0.6);
    }

    // 길흉 점수 체크
    final score = widget.luckyScores?[normalizedDay];
    if (score != null) {
      if (score >= 0.8) {
        return TossDesignSystem.successGreen.withValues(alpha: 0.6);
      }
      if (score >= 0.6) {
        return TossDesignSystem.tossBlue.withValues(alpha: 0.6);
      }
      if (score >= 0.4) {
        return TossDesignSystem.warningOrange.withValues(alpha: 0.6);
      }
      return TossDesignSystem.errorRed.withValues(alpha: 0.6);
    }

    return TossDesignSystem.gray500.withValues(alpha: 0.5);
  }

  Widget? _buildLegend() {
    // 운세 정보가 없으면 범례 표시 안함
    if (widget.luckyScores == null && widget.auspiciousDays == null) {
      return null;
    }

    return Container(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '날짜 길흉 안내',
            style: DSTypography.headingSmall,
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (widget.auspiciousDays != null)
                _buildLegendItem(
                  TossDesignSystem.warningOrange.withValues(alpha: 0.6),
                  '손없는날',
                ),
              if (widget.luckyScores != null) ...[
                _buildLegendItem(
                  TossDesignSystem.successGreen.withValues(alpha: 0.6),
                  '매우 길한 날',
                ),
                _buildLegendItem(
                  TossDesignSystem.tossBlue.withValues(alpha: 0.6),
                  '길한 날',
                ),
                _buildLegendItem(
                  TossDesignSystem.warningOrange.withValues(alpha: 0.6),
                  '보통',
                ),
                _buildLegendItem(
                  TossDesignSystem.errorRed.withValues(alpha: 0.6),
                  '피해야 할 날',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: AppSpacing.spacing5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppDimensions.borderRadiusSmall,
            border: Border.all(
              color: TossDesignSystem.gray500.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing1 * 1.5),
        Text(
          label,
          style: DSTypography.bodySmall,
        ),
      ],
    );
  }

  Widget? _buildDayDetails(DateTime day) {
    final normalizedDay = DatePickerUtils.normalizeDate(day);
    final isAuspicious = widget.auspiciousDays?.any((d) =>
            DatePickerUtils.isSameDay(d, normalizedDay)) ??
        false;
    final luckyScore = widget.luckyScores?[normalizedDay];
    final holiday = widget.holidayMap?[normalizedDay];

    if (!isAuspicious && luckyScore == null && holiday == null) {
      return null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.spacing4),
      padding: AppSpacing.paddingAll12,
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.grayDark800
            : TossDesignSystem.gray50,
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(
          color: isDark
              ? TossDesignSystem.borderDark
              : TossDesignSystem.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DatePickerUtils.formatKorean(day, showWeekday: true),
            style: DSTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing2),
          if (isAuspicious) ...[
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: TossDesignSystem.warningOrange.withValues(alpha: 0.8),
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.spacing1),
                Text(
                  '손없는날 - 이사하기 매우 좋은 날',
                  style: DSTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing1),
          ],
          if (luckyScore != null) ...[
            Row(
              children: [
                Icon(
                  luckyScore >= 0.6 ? Icons.thumb_up : Icons.thumb_down,
                  color: _getDayColor(day),
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.spacing1),
                Text(
                  '길흉점수: ${(luckyScore * 100).toInt()}점',
                  style: DSTypography.bodySmall.copyWith(
                    color: _getDayColor(day),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing1),
          ],
          if (holiday != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: TossDesignSystem.errorRed,
                ),
                const SizedBox(width: AppSpacing.spacing1),
                Text(
                  holiday,
                  style: DSTypography.bodySmall.copyWith(
                    color: TossDesignSystem.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: isDark
              ? TossDesignSystem.grayDark900
              : TossDesignSystem.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusLarge,
            side: BorderSide(
              color: isDark
                  ? TossDesignSystem.borderDark
                  : TossDesignSystem.borderLight,
            ),
          ),
          child: Padding(
            padding: AppSpacing.paddingAll16,
            child: TableCalendar(
              firstDay: widget.minDate ?? DateTime(1900),
              lastDay: widget.maxDate ?? DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return DatePickerUtils.isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!DatePickerUtils.isInRange(
                  selectedDay,
                  minDate: widget.minDate,
                  maxDate: widget.maxDate,
                )) {
                  return;
                }

                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateChanged(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(
                  color: TossDesignSystem.errorRed,
                ),
                holidayTextStyle: const TextStyle(
                  color: TossDesignSystem.errorRed,
                ),
                selectedDecoration: const BoxDecoration(
                  color: TossDesignSystem.tossBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final normalizedDay = DatePickerUtils.normalizeDate(day);
                  final isAuspicious = widget.auspiciousDays?.any((d) =>
                          DatePickerUtils.isSameDay(d, normalizedDay)) ??
                      false;

                  if (isAuspicious) {
                    return Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: TossDesignSystem.warningOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                defaultBuilder: (context, day, focusedDay) {
                  if (widget.luckyScores == null) {
                    return null; // 기본 렌더링 사용
                  }

                  final normalizedDay = DatePickerUtils.normalizeDate(day);
                  final color = _getDayColor(normalizedDay);
                  final isWeekend = DatePickerUtils.isWeekend(day);

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: DSTypography.bodyMedium.copyWith(
                          color: isWeekend
                              ? TossDesignSystem.errorRed
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.textPrimaryLight),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusSmall,
                ),
                formatButtonTextStyle: DSTypography.bodySmall.copyWith(
                  color: TossDesignSystem.tossBlue,
                  fontWeight: FontWeight.w500,
                ),
                titleTextStyle: DSTypography.headingSmall,
              ),
            ),
          ),
        ),
        if (_selectedDay != null) _buildDayDetails(_selectedDay!) ?? const SizedBox.shrink(),
        if (_buildLegend() != null) _buildLegend()!,
      ],
    );
  }
}
