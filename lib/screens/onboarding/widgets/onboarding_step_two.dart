import 'package:flutter/material.dart';
import '../../../constants/fortune_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

class OnboardingStepTwo extends StatelessWidget {
  final String? mbti;
  final Function(String?) onMbtiChanged;
  final VoidCallback onNext;

  const OnboardingStepTwo({
    super.key,
    this.mbti,
    required this.onMbtiChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'MBTI 선택 (선택사항)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '더 정확한 성격 분석을 제공해드릴 수 있어요.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.fortuneTheme.subtitleText,
          ),
        ),
        const SizedBox(height: 24),
        
        // MBTI Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: mbtiTypes.length,
          itemBuilder: (context, index) {
            final type = mbtiTypes[index];
            final isSelected = mbti == type;
            
            return InkWell(
              onTap: () => onMbtiChanged(isSelected ? null : type),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : context.fortuneTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : context.fortuneTheme.dividerColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // 다음 버튼
        ElevatedButton(
          onPressed: onNext,
          style: context.fortuneTheme.ctaButtonStyle,
          child: const Text('다음'),
        ),
      ],
    );
  }
}