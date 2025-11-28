import 'package:flutter/material.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class SelectedMbtiInfo extends StatelessWidget {
  final String selectedMbti;
  final List<Color> colors;

  static const Map<String, String> mbtiDescriptions = {
    'INTJ': '전략적 사고를 가진 완벽주의자',
    'INTP': '논리적이고 창의적인 사색가',
    'ENTJ': '대담한 지도자형 인간',
    'ENTP': '영리한 발명가형 인간',
    'INFJ': '선의의 옹호자형 인간',
    'INFP': '열정적인 중재자형 인간',
    'ENFJ': '정의로운 사회운동가',
    'ENFP': '재기발랄한 활동가',
    'ISTJ': '청렴결백한 논리주의자',
    'ISFJ': '용감한 수호자형 인간',
    'ESTJ': '엄격한 관리자형 인간',
    'ESFJ': '사교적인 외교관형 인간',
    'ISTP': '만능 재주꾼형 인간',
    'ISFP': '호기심 많은 예술가',
    'ESTP': '모험을 즐기는 사업가',
    'ESFP': '자유로운 영혼의 연예인',
  };

  const SelectedMbtiInfo({
    super.key,
    required this.selectedMbti,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedMbti,
            style: TypographyUnified.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mbtiDescriptions[selectedMbti] ?? '',
            style: TypographyUnified.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
