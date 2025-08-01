import 'package:flutter/material.dart';
import '../../../constants/fortune_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class OnboardingStepTwo extends StatelessWidget {
  final String? mbti;
  final Function(String?) onMbtiChanged;
  final VoidCallback onNext;

  const OnboardingStepTwo(
    {
    super.key,
    this.mbti,
    required this.onMbtiChanged,
    required this.onNext,
  )});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                        Text(
                          'MBTI 선택 (선택사항)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold,
                          ),))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
        
        DropdownButtonFormField<String>(
          value: mbti,
          decoration: InputDecoration(,
      labelText: 'MBTI'),
        border: OutlineInputBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      contentPadding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical)
            ))
          items: mbtiTypes.map((type) => DropdownMenuItem(,
      value: type),
        child: Text(type)))).toList(),
          onChanged: onMbtiChanged,
          hint: Text('MBTI 선택'))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
        Text(
          '성격 기반 운세 분석에 활용됩니다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),))
        
        const Spacer(),
        
        // 다음 버튼
        ElevatedButton(
          onPressed: onNext),
        style: ElevatedButton.styleFrom(,
      padding: EdgeInsets.symmetric(vertic,
      al: context.fortuneTheme.formStyles.inputPadding.horizontal),
            shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius))))
          child: const Text('다음'))
      ]
    );
  }
}