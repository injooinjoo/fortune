import 'package:flutter/material.dart';

class CustomCalendarDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateChanged;
  final Function()? onConfirm;

  const CustomCalendarDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.onConfirm,
  });

  @override
  State<CustomCalendarDatePicker> createState() => _CustomCalendarDatePickerState();
}

class _CustomCalendarDatePickerState extends State<CustomCalendarDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    // 임시로 기본 날짜 선택기 사용
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme,
      ),
      child: CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        onDateChanged: (date) {
          setState(() {
            _selectedDate = date;
          });
          widget.onDateChanged(date);
        },
      ),
    );
  }
}