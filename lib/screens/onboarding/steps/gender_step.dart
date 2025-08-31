import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/fortune_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class GenderStep extends StatefulWidget {
  final Function(Gender) onGenderChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const GenderStep({
    super.key,
    required this.onGenderChanged,
    required this.onNext,
    required this.onBack});

  @override
  State<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  Gender? _selectedGender;

  void _selectGender(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderChanged(gender);
    
    // Auto-advance after selection
    Future.delayed(AppAnimations.durationMedium, () {
      widget.onNext();
    });
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
                  '성별을 선택해주세요',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: Theme.of(context).textTheme.headlineLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: context.fortuneTheme.primaryText),
                  textAlign: TextAlign.center).animate().fadeIn(
                  duration: 600.ms).shimmer(
                  duration: 1200.ms,
                  color: TossDesignSystem.grayDark900.withOpacity(0.3)),
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                
                Text(
                  '음양의 조화를 살펴볼게요',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.fortuneTheme.subtitleText),
                  textAlign: TextAlign.center).animate(
                  delay: 300.ms).fadeIn(
                  duration: 600.ms),
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
                
                // Gender buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGenderButton(
                      gender: Gender.female,
                      label: '여자',
                      isSelected: _selectedGender == Gender.female).animate(
                      delay: 500.ms).fadeIn(
                      duration: 600.ms).scale(
                      begin: Offset(0.8, 0.8),
                      end: Offset(1, 1),
                      curve: Curves.easeOutBack),
                    
                    SizedBox(width: context.fortuneTheme.formStyles.inputPadding.horizontal),
                    
                    _buildGenderButton(
                      gender: Gender.male,
                      label: '남자',
                      isSelected: _selectedGender == Gender.male).animate(
                      delay: 600.ms).fadeIn(
                      duration: 600.ms).scale(
                      begin: Offset(0.8, 0.8),
                      end: Offset(1, 1),
                      curve: Curves.easeOutBack)])])]);
  }

  Widget _buildGenderButton({
    required Gender gender,
    required String label,
    required bool isSelected}) {
    return InkWell(
      onTap: () => _selectGender(gender),
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius + 8),
      child: Container(
        width: context.fortuneTheme.socialSharing.shareButtonSize * 2.5,
        height: context.fortuneTheme.socialSharing.shareButtonSize * 2.5,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : context.fortuneTheme.cardBackground,
          borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius + 8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : context.fortuneTheme.dividerColor,
            width: isSelected ? context.fortuneTheme.formStyles.focusBorderWidth : context.fortuneTheme.formStyles.inputBorderWidth)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gender == Gender.female ? Icons.female : Icons.male,
              size: context.fortuneTheme.socialSharing.shareButtonSize - 8,
              color: isSelected ? TossDesignSystem.grayDark900 : context.fortuneTheme.subtitleText),
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? TossDesignSystem.grayDark900 : context.fortuneTheme.secondaryText)]));
  }
}