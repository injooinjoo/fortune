import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class LocationStep extends StatefulWidget {
  final Function(String region) onLocationChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  
  const LocationStep({
    super.key,
    required this.onLocationChanged,
    required this.onComplete,
    required this.onBack});

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  String? _selectedRegion;
  
  final List<String> _regions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도'];
  
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
                // Title with typewriter animation
                Text(
                  '어디에 사시나요?',
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
                
                // Subtitle with delay
                Text(
                  '운세의 정확도를 높이기 위해\n지역 정보가 필요해요',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.fortuneTheme.subtitleText),
                  textAlign: TextAlign.center).animate(
                  delay: 300.ms).fadeIn(
                  duration: 600.ms),
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
                
                // Region dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.fortuneTheme.dividerColor),
                    borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius)),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: InputDecoration(
                      labelText: '지역 선택',
                      border: InputBorder.none,
                      contentPadding: context.fortuneTheme.formStyles.inputPadding),
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                      });
                      if (value != null) {
                        widget.onLocationChanged(value);
                      }
                    })).animate(
                  delay: 500.ms).fadeIn(
                  duration: 600.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  curve: Curves.easeOutQuart),
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 5),
                
                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: context.fortuneTheme.formStyles.inputHeight,
                  child: ElevatedButton(
                    onPressed: _selectedRegion != null
                        ? widget.onComplete 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.fortuneTheme.primaryText,
                      foregroundColor: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius + 4)),
                      elevation: 0),
                    child: Text(
                      '완료',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600)))).animate(
                  delay: 700.ms).fadeIn(
                  duration: 600.ms)]))]));
  }
}