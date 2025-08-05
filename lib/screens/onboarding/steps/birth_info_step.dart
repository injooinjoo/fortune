import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../widgets/custom_calendar_picker.dart';
import '../widgets/bottom_sheet_time_picker.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class BirthInfoStep extends StatefulWidget {
  final Function(DateTime, String?) onBirthInfoChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const BirthInfoStep({
    super.key,
    required this.onBirthInfoChanged,
    required this.onNext,
    required this.onBack});

  @override
  State<BirthInfoStep> createState() => _BirthInfoStepState();
}

class _BirthInfoStepState extends State<BirthInfoStep> {
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _hasSelectedDate = false;

  void _selectDate() async {
    final date = await CustomCalendarPicker.show(
      context,
      initialDate: _selectedDate ?? DateTime(1980, 1, 1));
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _hasSelectedDate = true;
      });
      
      // Automatically show time picker after date selection
      await Future.delayed(AppAnimations.durationMedium);
      _selectTime();
    }
  }

  void _selectTime() async {
    final time = await BottomSheetTimePicker.show(
      context,
      initialTime: _selectedTime);
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
      
      // Update parent with both values
      if (_selectedDate != null) {
        widget.onBirthInfoChanged(_selectedDate!, _selectedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back, color: context.fortuneTheme.primaryText),
              padding: EdgeInsets.zero)),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '생일이 언제인가요?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: Theme.of(context).textTheme.headlineLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: context.fortuneTheme.primaryText),
                  textAlign: TextAlign.center).animate().fadeIn(
                  duration: 600.ms).shimmer(
                  duration: 1200.ms,
                  color: AppColors.textPrimaryDark.withValues(alpha: 0.3)),
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                
                Text(
                  '정확한 운세를 위해 필요해요',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.fortuneTheme.subtitleText),
                  textAlign: TextAlign.center).animate(
                  delay: 300.ms).fadeIn(
                  duration: 600.ms),
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
                
                // Date selector
                _buildDateSelector(),
                
                if (_hasSelectedDate) ...[
                  SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2),
                  _buildTimeSelector()],
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 5),
                
                // Next button
                SizedBox(
                  width: double.infinity,
                  height: context.fortuneTheme.formStyles.inputHeight,
                  child: ElevatedButton(
                    onPressed: _selectedDate != null ? widget.onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.fortuneTheme.primaryText,
                      foregroundColor: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius + 4)),
                      elevation: 0),
                    child: Text(
                      '다음',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600)))).animate(
                  delay: 700.ms).fadeIn(
                  duration: 600.ms)]))]));
  }
  
  Widget _buildDateSelector() {
    final dateText = _selectedDate != null
        ? DateFormat('yyyy년 M월 d일').format(_selectedDate!)
        : '날짜 선택';
        
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5,
          vertical: context.fortuneTheme.formStyles.inputPadding.horizontal),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.fortuneTheme.dividerColor,
              width: context.fortuneTheme.formStyles.inputBorderWidth))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _selectedDate != null
                    ? context.fortuneTheme.primaryText
                    : context.fortuneTheme.subtitleText,
                fontWeight: _selectedDate != null ? FontWeight.w500 : FontWeight.normal)),
            Icon(
              Icons.calendar_today,
              color: context.fortuneTheme.subtitleText,
              size: AppDimensions.iconSizeMedium)]))).animate(
      delay: 500.ms).fadeIn(
      duration: 600.ms).slideY(
      begin: 0.1,
      end: 0,
      curve: Curves.easeOutQuart);
  }
  
  Widget _buildTimeSelector() {
    final timeText = _selectedTime ?? '시간 모름';
    
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5,
          vertical: context.fortuneTheme.formStyles.inputPadding.horizontal),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.fortuneTheme.dividerColor,
              width: context.fortuneTheme.formStyles.inputBorderWidth))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _selectedTime != null
                    ? context.fortuneTheme.primaryText
                    : context.fortuneTheme.subtitleText,
                fontWeight: _selectedTime != null ? FontWeight.w500 : FontWeight.normal)),
            Icon(
              Icons.access_time,
              color: context.fortuneTheme.subtitleText,
              size: AppDimensions.iconSizeMedium)]))).animate().fadeIn(
      duration: 600.ms).slideY(
      begin: 0.1,
      end: 0,
      curve: Curves.easeOutQuart);
  }
}