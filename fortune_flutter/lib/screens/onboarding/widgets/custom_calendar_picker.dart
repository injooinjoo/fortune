import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: Colors.transparent,
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
    _selectedDate = widget.initialDate ?? DateTime(2000, 1, 1);
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
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Text(
                  '생년월일',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 60), // Balance the layout
              ],
            ),
          ),
          
          // Year and Month selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Year selector
                InkWell(
                  onTap: _showYearPicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$_selectedYear년',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
                
                // Month selector
                InkWell(
                  onTap: _showMonthPicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _monthNames[_selectedMonth - 1],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Week days header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekDays.map((day) => Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: day == '일' ? Colors.red : (day == '토' ? Colors.blue : null),
                  ),
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isToday && !isSelected
                            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? Colors.white 
                              : isSunday 
                                  ? Colors.red 
                                  : isSaturday 
                                      ? Colors.blue 
                                      : null,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('yyyy년 M월 d일').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => widget.onDateSelected(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
      (index) => minYear + index,
    );
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                        color: isSelected ? Theme.of(context).primaryColor : null,
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
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                        color: isSelected ? Theme.of(context).primaryColor : null,
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