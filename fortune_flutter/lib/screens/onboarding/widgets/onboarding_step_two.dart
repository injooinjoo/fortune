import 'package:flutter/material.dart';
import '../../../constants/fortune_constants.dart';

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
        const Text(
          'MBTI 선택 (선택사항)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        DropdownButtonFormField<String>(
          value: mbti,
          decoration: InputDecoration(
            labelText: 'MBTI',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: mbtiTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: onMbtiChanged,
          hint: const Text('MBTI 선택'),
        ),
        const SizedBox(height: 8),
        Text(
          '성격 기반 운세 분석에 활용됩니다.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        
        const Spacer(),
        
        // 다음 버튼
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('다음'),
        ),
      ],
    );
  }
}