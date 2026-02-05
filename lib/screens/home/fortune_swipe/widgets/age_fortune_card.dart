import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 🎂 나이대별 운세 카드
///
/// API 응답의 age_fortune 필드를 표시합니다.
/// - ageGroup: 나이대 (예: "30대 초반")
/// - title: 제목 (예: "성장의 해")
/// - description: 상세 설명
/// - zodiacAnimal: 띠 (선택)
class AgeFortuneCard extends StatelessWidget {
  final Map<String, dynamic>? ageFortune;

  const AgeFortuneCard({
    super.key,
    required this.ageFortune,
  });

  @override
  Widget build(BuildContext context) {
    // 데이터가 없으면 빈 위젯 반환
    if (ageFortune == null || ageFortune!.isEmpty) {
      return const SizedBox.shrink();
    }

    final ageGroup = ageFortune!['ageGroup']?.toString() ?? '';
    final title = ageFortune!['title']?.toString() ?? '';
    final description = ageFortune!['description']?.toString() ?? '';
    final zodiacAnimal = ageFortune!['zodiacAnimal']?.toString();

    // 필수 데이터가 없으면 빈 위젯 반환
    if (ageGroup.isEmpty && title.isEmpty && description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.15),
                    const Color(0xFFA78BFA).withValues(alpha: 0.1), // 고유 색상: 밝은 보라
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🎂', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나이대별 운세',
                    style: context.heading3.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '같은 연령대의 특별한 메시지',
                    style: context.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 메인 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDark
                ? [const Color(0xFF2D2440), context.colors.surface] // 고유 색상: 다크 보라 그라디언트
                : [const Color(0xFFF5F0FF), const Color(0xFFEDE9FE)], // 고유 색상: 라이트 보라 그라디언트
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: DSFortuneColors.categoryLuckyItems.withValues(alpha: context.isDark ? 0.2 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 나이대 배지 + 띠
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DSFortuneColors.categoryLuckyItems,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ageGroup.isNotEmpty ? ageGroup : '나의 나이대',
                      style: context.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (zodiacAnimal != null && zodiacAnimal.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDAA520).withValues(alpha: 0.2), // 오방색: 토(土)
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFDAA520).withValues(alpha: 0.5), // 오방색: 토(土)
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$zodiacAnimal띠',
                        style: context.labelSmall.copyWith(
                          color: const Color(0xFFDAA520), // 오방색: 토(土)
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 제목
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: context.heading2.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 설명
              if (description.isNotEmpty) ...[
                Text(
                  description,
                  style: context.bodyMedium.copyWith(
                    color: context.colors.textPrimary.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 하단 힌트
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '같은 나이대의 사람들과 비슷한 고민과 기회가 있을 수 있어요',
                  style: context.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
