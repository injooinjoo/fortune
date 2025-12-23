import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';

class QuestionTypeStep extends StatelessWidget {
  final String? selectedCelebrityName;
  final String connectionType;
  final String questionType;
  final ValueChanged<String> onConnectionTypeChanged;
  final ValueChanged<String> onQuestionTypeChanged;

  const QuestionTypeStep({
    super.key,
    required this.selectedCelebrityName,
    required this.connectionType,
    required this.questionType,
    required this.onConnectionTypeChanged,
    required this.onQuestionTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 것이 궁금하신가요?',
            style: DSTypography.headingLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${selectedCelebrityName ?? '선택한 유명인'}님과의 관계에서\n궁금한 부분을 선택해주세요',
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Connection type
          Text(
            '관계 유형',
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          ConnectionOption(
            value: 'ideal_match',
            title: '이상형 매치',
            description: '나와 잘 맞는 이상형인지 알아보기',
            icon: Icons.favorite,
            isSelected: connectionType == 'ideal_match',
            onTap: () => onConnectionTypeChanged('ideal_match'),
          ),
          const SizedBox(height: 12),
          ConnectionOption(
            value: 'compatibility',
            title: '전체 궁합',
            description: '종합적인 궁합 점수와 분석',
            icon: Icons.people,
            isSelected: connectionType == 'compatibility',
            onTap: () => onConnectionTypeChanged('compatibility'),
          ),
          const SizedBox(height: 12),
          ConnectionOption(
            value: 'career_advice',
            title: '조언 구하기',
            description: '인생과 진로에 대한 조언',
            icon: Icons.lightbulb_outline,
            isSelected: connectionType == 'career_advice',
            onTap: () => onConnectionTypeChanged('career_advice'),
          ),

          const SizedBox(height: 32),

          // Question type
          Text(
            '궁금한 영역',
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          QuestionOption(
            value: 'love',
            title: '연애운',
            description: '사랑과 인간관계에 대해',
            icon: Icons.favorite_border,
            isSelected: questionType == 'love',
            onTap: () => onQuestionTypeChanged('love'),
          ),
          const SizedBox(height: 12),
          QuestionOption(
            value: 'career',
            title: '사업운',
            description: '일과 성공에 대해',
            icon: Icons.work_outline,
            isSelected: questionType == 'career',
            onTap: () => onQuestionTypeChanged('career'),
          ),
          const SizedBox(height: 12),
          QuestionOption(
            value: 'personality',
            title: '성격 분석',
            description: '나의 성격과 특징',
            icon: Icons.psychology,
            isSelected: questionType == 'personality',
            onTap: () => onQuestionTypeChanged('personality'),
          ),
          const SizedBox(height: 12),
          QuestionOption(
            value: 'future',
            title: '미래 전망',
            description: '앞으로의 운세와 기회',
            icon: Icons.trending_up,
            isSelected: questionType == 'future',
            onTap: () => onQuestionTypeChanged('future'),
          ),
          const SizedBox(height: 100), // 버튼 높이만큼 여백
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }
}

class ConnectionOption extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ConnectionOption({
    super.key,
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.05) : colors.surface,
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? colors.accent : colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : colors.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DSTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class QuestionOption extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOption({
    super.key,
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const accentColor = Color(0xFFFF6B6B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.05) : colors.surface,
          border: Border.all(
            color: isSelected ? accentColor : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : colors.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DSTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}
