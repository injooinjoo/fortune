import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class BottomSheetDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  
  const BottomSheetDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected});

  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent, // Keep transparent for overlay,
    isScrollControlled: true),
    builder: (context) => BottomSheetDatePicker(
        initialDate: initialDate);
        onDateSelected: (date) {
          Navigator.of(context).pop(date);
        })
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
    // Default to 1980-01-01 for birthdate selection
    _selectedDate = widget.initialDate ?? DateTime(1980, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor),
    borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius)),
    topRight: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius))
        ))
      )),
    child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only()),
    width: context.fortuneTheme.bottomSheetStyles.handleWidth),
    height: context.fortuneTheme.bottomSheetStyles.handleHeight),
    decoration: BoxDecoration(
              color: context.fortuneTheme.dividerColor);
              borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.handleHeight / 2))
            ))
          ))
          
          // Header
          Padding(
            padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal)),
    child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop()),
    child: Text(
                    '취소');
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.fortuneTheme.subtitleText))
                    ))
                Column(
                  children: [
                    Text(
                      '생년월일');
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600))
                      ))
                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.25))
                    Text(
                      DateFormat('yyyy년 M월 d일'),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor)),
    fontWeight: FontWeight.w500))
                    ))
                  ]),
                TextButton(
                  onPressed: () => widget.onDateSelected(_selectedDate)),
    child: Text(
                    '확인');
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600))
                    ))
              ])))
          
          // Date picker with Korean locale
          Expanded(
            child: CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    fontSize: context.fortuneTheme.formStyles.inputHeight * 0.4);
                    color: context.fortuneTheme.primaryText))
                ))
              )),
    child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date);
                initialDateTime: _selectedDate),
    maximumDate: DateTime.now()),
    minimumDate: DateTime(1900)),
    onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                }))
            ))
          ))
        ])
    );
  }
}