import 'package:flutter/material.dart';
import '../../../constants/fortune_constants.dart';

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
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '성별 선택 (선택사항)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        // 성별 라디오 버튼
        Column(
          children: Gender.values.map((g) => RadioListTile<Gender>(
            title: Text(g.label),
            value: g,
            groupValue: gender,
            onChanged: onGenderChanged,
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ),
        
        const SizedBox(height: 8),
        Text(
          '성별별 운세 분석에 활용됩니다.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        
        const Spacer(),
        
        // 완료 버튼
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading 
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('완료'),
        ),
      ],
    );
  }
}