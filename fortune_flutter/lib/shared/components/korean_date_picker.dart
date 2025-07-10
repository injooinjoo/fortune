import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/theme/app_theme.dart';

class KoreanDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  final String? label;
  final bool showAge;
  final DateTime? minDate;
  final DateTime? maxDate;

  const KoreanDatePicker({
    Key? key,
    this.initialDate,
    required this.onDateSelected,
    this.label,
    this.showAge = true,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

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
    (index) => DateTime.now().year - index,
  );

  List<int> get months => List.generate(12, (index) => index + 1);

  List<int> get days {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  @override
  void initState() {
    super.initState();
    final date = widget.initialDate ?? DateTime.now();
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
    widget.onDateSelected(newDate);
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
            padding: const EdgeInsets.only(bottom: 8),
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
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            blur: 10,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
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
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? null : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isExpanded ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 12),
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
                        const SizedBox(width: 12),
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '현재 만 나이: $age세',
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
    required String suffix,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
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
    Key? key,
    required this.birthDate,
    this.onTap,
  }) : super(key: key);

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
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        blur: 15,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.cake_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '만 $age세',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Text(
                '탭하여 변경',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
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