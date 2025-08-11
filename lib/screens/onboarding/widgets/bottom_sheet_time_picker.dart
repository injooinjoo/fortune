import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class BottomSheetTimePicker extends StatelessWidget {
  final String? selectedTime;
  final Function(String?) onTimeSelected;
  
  const BottomSheetTimePicker({
    super.key,
    this.selectedTime,
    required this.onTimeSelected});

  static final List<Map<String, String>> timeOptions = [
    {'value': '자시', 'time': '23:00 - 01:00'},
    {'value': '축시', 'time': '01:00 - 03:00'},
    {'value': '인시', 'time': '03:00 - 05:00'},
    {'value': '묘시', 'time': '05:00 - 07:00'},
    {'value': '진시', 'time': '07:00 - 09:00'},
    {'value': '사시', 'time': '09:00 - 11:00'},
    {'value': '오시', 'time': '11:00 - 13:00'},
    {'value': '미시', 'time': '13:00 - 15:00'},
    {'value': '신시', 'time': '15:00 - 17:00'},
    {'value': '유시', 'time': '17:00 - 19:00'},
    {'value': '술시', 'time': '19:00 - 21:00'},
    {'value': '해시', 'time': '21:00 - 23:00'},
    {'value': '모름', 'time': '시간을 모르겠어요'}];

  static Future<String?> show(BuildContext context, {String? initialTime}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetTimePicker(
        selectedTime: initialTime,
        onTimeSelected: (time) {
          Navigator.of(context).pop(time);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius),
          topRight: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius)),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: context.fortuneTheme.bottomSheetStyles.handleWidth,
            height: context.fortuneTheme.bottomSheetStyles.handleHeight,
            decoration: BoxDecoration(
              color: context.fortuneTheme.dividerColor,
              borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.handleHeight / 2)),
          
          // Header
          Padding(
            padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal),
            child: Text(
              '태어난 시간',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600)),
          
          // Time options
          Expanded(
            child: ListView.builder(
              itemCount: timeOptions.length,
              itemBuilder: (context, index) {
                final option = timeOptions[index];
                final isSelected = selectedTime == option['value'];
                
                return InkWell(
                  onTap: () => onTimeSelected(option['value']),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5,
                      vertical: context.fortuneTheme.formStyles.inputPadding.horizontal),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.fortuneTheme.dividerColor,
                          width: context.fortuneTheme.formStyles.inputBorderWidth)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['value']!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Theme.of(context).primaryColor : context.fortuneTheme.primaryText)),
                            if (option['value'] != '모름')
                              Text(
                                option['time']!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.fortuneTheme.subtitleText))]),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor)])));
              })]);
  }
}