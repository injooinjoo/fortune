import 'package:flutter/material.dart';
import '../../../constants/fortune_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class OnboardingStepThree extends StatelessWidget {
  final Gender? gender;
  final Function(Gender?) onGenderChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const OnboardingStepThree({
    super.key,
    this.gender,
    required this.onGenderChanged,
    required this.onSubmit,
    required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final formStyle = context.fortuneTheme.formStyles;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '성별 선택 (선택사항)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: formStyle.inputPadding.horizontal * 1.25),
        
        // 성별 라디오 버튼
        Column(
          children: Gender.values.map((g) => RadioListTile<Gender>(
            title: Text(g.label),
            value: g,
            groupValue: gender,
            onChanged: onGenderChanged,
            contentPadding: EdgeInsets.zero)).toList()),
        
        SizedBox(height: formStyle.inputPadding.vertical * 0.5),
        Text(
          '성별별 운세 분석에 활용됩니다.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.fortuneTheme.subtitleText)),
        
        const Spacer(),
        
        // 완료 버튼
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: formStyle.inputPadding.horizontal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(formStyle.inputBorderRadius)),
          child: isLoading 
              ? SizedBox(
                  height: formStyle.inputHeight * 0.4,
                  width: formStyle.inputHeight * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: formStyle.inputBorderWidth * 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark)))
              : const Text('완료'))]);
  }
}