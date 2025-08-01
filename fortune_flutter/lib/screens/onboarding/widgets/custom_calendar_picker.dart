import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class CustomCalendarPicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  
  const CustomCalendarPicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent, // Keep transparent for overlay
      isScrollControlled: true,
      builder: (context) => CustomCalendarPicker(
        initialDate: initialDate,
        onDateSelected: (date) {
          Navigator.of(context).pop(date);
        },
      ),
    );
  }

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  late int _selectedYear;
  late int _selectedMonth;
  
  final List<String> _monthNames = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월'
  ];
  
  final List<String> _weekDays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime(1980, 1, 1);
    _focusedDate = _selectedDate;
    _selectedYear = _selectedDate.year;
    _selectedMonth = _selectedDate.month;
  }

  List<DateTime?> _generateCalendarDays() {
    final firstDay = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Convert to 0-6 (Sun-Sat)
    
    List<DateTime?> days = [];
    
    // Add empty days for alignment
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    
    // Add actual days
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_selectedYear, _selectedMonth, i));
    }
    
    return days;
  }

  void _showYearPicker() async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) => _YearPickerDialog(
        selectedYear: _selectedYear,
        minYear: 1900,
        maxYear: DateTime.now().year,
      ),
    );
    
    if (selectedYear != null) {
      setState(() {
        _selectedYear = selectedYear;
        _updateFocusedDate();
      });
    }
  }

  void _showMonthPicker() async {
    final selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) => _MonthPickerDialog(
        selectedMonth: _selectedMonth,
        monthNames: _monthNames,
      ),
    );
    
    if (selectedMonth != null) {
      setState(() {
        _selectedMonth = selectedMonth;
        _updateFocusedDate();
      });
    }
  }

  void _updateFocusedDate() {
    // Ensure the day is valid for the new month
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final day = _focusedDate.day > lastDayOfMonth ? lastDayOfMonth : _focusedDate.day;
    _focusedDate = DateTime(_selectedYear, _selectedMonth, day);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final days = _generateCalendarDays();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius),
          topRight: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: context.fortuneTheme.bottomSheetStyles.handleWidth,
            height: context.fortuneTheme.bottomSheetStyles.handleHeight,
            decoration: BoxDecoration(
              color: context.fortuneTheme.dividerColor,
              borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.handleHeight / 2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.fortuneTheme.subtitleText
                    ),
                  ),
                ),
                Text(
                  '생년월일',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(width: context.fortuneTheme.formStyles.inputPadding.horizontal * 3.75), // Balance the layout
              ],
            ),
          ),
          
          // Year and Month selectors
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Year selector
                InkWell(
                  onTap: _showYearPicker,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal, vertical: context.fortuneTheme.formStyles.inputPadding.vertical * 0.67),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.fortuneTheme.dividerColor),
                      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$_selectedYear년',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                        Icon(Icons.arrow_drop_down, size: context.fortuneTheme.formStyles.inputHeight * 0.4),
                      ],
                    ),
                  ),
                ),
                
                // Month selector
                InkWell(
                  onTap: _showMonthPicker,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal, vertical: context.fortuneTheme.formStyles.inputPadding.vertical * 0.67),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.fortuneTheme.dividerColor),
                      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _monthNames[_selectedMonth - 1],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                        Icon(Icons.arrow_drop_down, size: context.fortuneTheme.formStyles.inputHeight * 0.4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
          
          // Week days header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekDays.map((day) => Container(
                width: context.fortuneTheme.formStyles.inputHeight * 0.8,
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: day == '일' ? AppColors.error : (day == '토' ? AppColors.primary : null)
                  ),
                ),
              )).toList(),
            ),
          ),
          
          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 0.625),
          
          // Calendar grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  if (date == null) return const SizedBox();
                  
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isSunday = date.weekday == 7;
                  final isSaturday = date.weekday == 6;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                    child: Container(
                      margin: EdgeInsets.all(context.fortuneTheme.formStyles.inputBorderWidth * 2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputHeight * 0.4),
                        border: isToday && !isSelected
                            ? Border.all(color: Theme.of(context).primaryColor, width: context.fortuneTheme.formStyles.focusBorderWidth)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? (context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark)
                              : isSunday 
                                  ? AppColors.error 
                                  : isSaturday 
                                      ? AppColors.primary 
                                      : null
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Selected date display and confirm button
          Container(
            padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
            decoration: BoxDecoration(
              color: context.fortuneTheme.cardBackground,
              border: Border(
                top: BorderSide(color: context.fortuneTheme.dividerColor),
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('yyyy년 M월 d일').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor
                  ),
                ),
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                SizedBox(
                  width: double.infinity,
                  height: context.fortuneTheme.formStyles.inputHeight,
                  child: ElevatedButton(
                    onPressed: () => widget.onDateSelected(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputHeight / 2),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '확인',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Year picker dialog
class _YearPickerDialog extends StatelessWidget {
  final int selectedYear;
  final int minYear;
  final int maxYear;
  
  const _YearPickerDialog({
    required this.selectedYear,
    required this.minYear,
    required this.maxYear,
  });

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      maxYear - minYear + 1, 
      (index) => minYear + index
    );
    
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal),
              child: Text(
                '년도 선택',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == selectedYear;
                  
                  return ListTile(
                    title: Text(
                      '$year년',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : null,
                        color: isSelected ? Theme.of(context).primaryColor : null
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(year),
                    selected: isSelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Month picker dialog
class _MonthPickerDialog extends StatelessWidget {
  final int selectedMonth;
  final List<String> monthNames;
  
  const _MonthPickerDialog({
    required this.selectedMonth,
    required this.monthNames,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal),
              child: Text(
                '월 선택',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: monthNames.length,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selectedMonth;
                  
                  return ListTile(
                    title: Text(
                      monthNames[index],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : null,
                        color: isSelected ? Theme.of(context).primaryColor : null
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(month),
                    selected: isSelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}