import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class BottomSheetDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  
  const BottomSheetDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetDatePicker(
        initialDate: initialDate,
        onDateSelected: (date) {
          Navigator.of(context).pop(date);
        },
      ),
    );
  }

  @override
  State<BottomSheetDatePicker> createState() => _BottomSheetDatePickerState();
}

class _BottomSheetDatePickerState extends State<BottomSheetDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Default to 2000-01-01 for birthdate selection
    _selectedDate = widget.initialDate ?? DateTime(2000, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
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
                Column(
                  children: [
                    Text(
                      '생년월일',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy년 M월 d일').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => widget.onDateSelected(_selectedDate),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Date picker with Korean locale
          Expanded(
            child: CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now(),
                minimumDate: DateTime(1900),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}