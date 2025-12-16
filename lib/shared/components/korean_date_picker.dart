import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/design_system/design_system.dart';

class KoreanDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? selectedDate; // Alias for initialDate
  final Function(DateTime)? onDateSelected;
  final Function(DateTime)? onDateChanged; // Alias for onDateSelected
  final String? label;
  final bool showAge;
  final DateTime? minDate;
  final DateTime? maxDate;

  const KoreanDatePicker({
    super.key,
    this.initialDate,
    this.selectedDate,
    this.onDateSelected,
    this.onDateChanged,
    this.label,
    this.showAge = true,
    this.minDate,
    this.maxDate,
  }) : assert(
          onDateSelected != null || onDateChanged != null,
          'Either onDateSelected or onDateChanged must be provided');

  @override
  State<KoreanDatePicker> createState() => _KoreanDatePickerState();
}

class _KoreanDatePickerState extends State<KoreanDatePicker> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  bool isExpanded = false;

  final List<int> years = List.generate(
    100,
    (index) => DateTime.now().year - 99 + index,
  );

  List<int> get months => List.generate(12, (index) => index + 1);

  List<int> get days {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  @override
  void initState() {
    super.initState();
    final date = widget.initialDate ?? widget.selectedDate ?? DateTime.now();
    selectedYear = date.year;
    selectedMonth = date.month;
    selectedDay = date.day;
  }

  void _updateDate() {
    // Ensure day is valid for the selected month
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    if (selectedDay > daysInMonth) {
      selectedDay = daysInMonth;
    }

    final newDate = DateTime(selectedYear, selectedMonth, selectedDay);
    // Call whichever callback is provided
    widget.onDateSelected?.call(newDate);
    widget.onDateChanged?.call(newDate);
  }

  int _calculateAge() {
    final now = DateTime.now();
    final selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
    int age = now.year - selectedDate.year;

    if (now.month < selectedDate.month ||
        (now.month == selectedDate.month && now.day < selectedDate.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final age = _calculateAge();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Text(
              widget.label!,
              style: typography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),

        GestureDetector(
          onTap: () {
            DSHaptics.light();
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            blur: 10,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: colors.accent,
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$selectedYear년 $selectedMonth월 $selectedDay일',
                        style: typography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (widget.showAge && age >= 0)
                        Text(
                          '만 $age세',
                          style: typography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: DSAnimation.durationFast,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedContainer(
          duration: DSAnimation.durationMedium,
          height: isExpanded ? null : 0,
          child: AnimatedOpacity(
            duration: DSAnimation.durationFast,
            opacity: isExpanded ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: DSSpacing.sm),
              child: GlassContainer(
                padding: const EdgeInsets.all(DSSpacing.md),
                borderRadius: BorderRadius.circular(DSRadius.lg),
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
                        const SizedBox(width: DSSpacing.md),
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
                        const SizedBox(width: DSSpacing.md),
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
                    if (widget.showAge && age >= 0) ...[
                      const SizedBox(height: DSSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(DSSpacing.sm),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              size: 18,
                              color: colors.accent,
                            ),
                            const SizedBox(width: DSSpacing.sm),
                            Text(
                              '나이: $age세',
                              style: typography.bodyMedium.copyWith(
                                color: colors.accent,
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
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.sm),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            isDense: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem<int>(
                value: item,
                child: Text(
                  '$item$suffix',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
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

class BirthDatePreview extends StatelessWidget {
  final DateTime birthDate;
  final VoidCallback? onTap;

  const BirthDatePreview({
    super.key,
    required this.birthDate,
    this.onTap,
  });

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final age = _calculateAge();

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          DSHaptics.light();
          onTap!();
        }
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(DSSpacing.lg),
        borderRadius: BorderRadius.circular(DSRadius.xl),
        blur: 15,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.1),
            colors.accentSecondary.withValues(alpha: 0.05),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.cake_rounded,
              size: 48,
              color: colors.accent,
            ),
            const SizedBox(height: DSSpacing.lg),
            Text(
              '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일',
              style: typography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.lg,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.xl),
              ),
              child: Text(
                '만 $age세',
                style: typography.bodyLarge.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: DSSpacing.md),
              Text(
                '탭하여 변경',
                style: typography.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
    );
  }
}
