import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_animations.dart';

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
    this.maxDate}) : assert(
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
    (index) => DateTime.now().year - 99 + index
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
    final theme = Theme.of(context);
    final age = _calculateAge();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
            child: Text(
              widget.label!,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
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
                  color: theme.colorScheme.primary),
                SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$selectedYear년 $selectedMonth월 $selectedDay일',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.showAge && age >= 0)
                        Text(
                          '만 $age세',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                        SizedBox(width: AppSpacing.spacing3),
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
                        SizedBox(width: AppSpacing.spacing3),
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
                      SizedBox(height: AppSpacing.spacing4),
                      Container(
                        padding: AppSpacing.paddingAll12,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: AppDimensions.borderRadiusMedium),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              size: AppDimensions.iconSizeSmall,
                              color: theme.colorScheme.primary),
                            SizedBox(width: AppSpacing.spacing2),
                            Text(
                              '나이: $age세',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
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
    required String suffix}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: AppSpacing.spacing1),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppDimensions.borderRadiusSmall,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                  style: theme.textTheme.bodyMedium,
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
    this.onTap});

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
    final theme = Theme.of(context);
    final age = _calculateAge();

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: AppSpacing.paddingAll20,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        blur: 15,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05)]),
        child: Column(
          children: [
            Icon(
              Icons.cake_rounded,
              size: 48,
              color: theme.colorScheme.primary),
            SizedBox(height: AppSpacing.spacing4),
            Text(
              '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.spacing2),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
              child: Text(
                '만 $age세',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              SizedBox(height: AppSpacing.spacing3),
              Text(
                '탭하여 변경',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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