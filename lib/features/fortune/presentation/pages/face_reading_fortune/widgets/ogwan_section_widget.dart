import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../domain/models/fortune_result.dart';

class OgwanSectionWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final FortuneResult result;
  final bool isDark;

  const OgwanSectionWidget({
    super.key,
    required this.data,
    required this.result,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ogwan = data['ogwan'] as Map<String, dynamic>?;
    if (ogwan == null) return const SizedBox.shrink();

    final ogwanItems = [
      {
        'key': 'ear',
        'title': '귀(耳) - 채청관',
        'subtitle': '복록과 수명',
        'icon': Icons.hearing,
        'color': DSColors.accent,
      },
      {
        'key': 'eyebrow',
        'title': '눈썹(眉) - 보수관',
        'subtitle': '형제와 친구',
        'icon': Icons.remove_red_eye_outlined,
        'color': DSColors.accent,
      },
      {
        'key': 'eye',
        'title': '눈(目) - 감찰관',
        'subtitle': '마음의 창',
        'icon': Icons.remove_red_eye,
        'color': DSColors.success,
      },
      {
        'key': 'nose',
        'title': '코(鼻) - 심변관',
        'subtitle': '재물의 중심',
        'icon': Icons.air,
        'color': Colors.amber,
      },
      {
        'key': 'mouth',
        'title': '입(口) - 출납관',
        'subtitle': '식복과 언변',
        'icon': Icons.sentiment_satisfied,
        'color': Colors.pink,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오관 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.face_retouching_natural, color: DSColors.accent, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오관(五官) 분석',
                    style: DSTypography.headingLarge.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전통 관상학의 핵심 - 얼굴 5대 관문',
                    style: DSTypography.labelSmall.copyWith(
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 오관 카드들
        ...ogwanItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final key = item['key'] as String;

          // Map 객체로 파싱 (JSON 버그 수정)
          final ogwanData = ogwan[key] as Map<String, dynamic>?;
          if (ogwanData == null) return const SizedBox.shrink();

          final observation = ogwanData['observation'] as String? ?? '';
          final interpretation = ogwanData['interpretation'] as String? ?? '';
          final score = (ogwanData['score'] as num?)?.toInt() ?? 0;
          final advice = ogwanData['advice'] as String? ?? '';

          // 모든 필드가 비어있으면 표시하지 않음
          if (observation.isEmpty && interpretation.isEmpty && advice.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UnifiedBlurWrapper(
              isBlurred: result.isBlurred,
              blurredSections: result.blurredSections,
              sectionKey: 'ogwan',
              child: AppCard(
                style: AppCardStyle.filled,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더: 아이콘 + 제목 + 점수
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: DSTypography.headingSmall.copyWith(
                                  color: DSColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: DSTypography.labelSmall.copyWith(
                                  color: DSColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 점수 배지
                        if (score > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$score점',
                              style: DSTypography.labelSmall.copyWith(
                                color: item['color'] as Color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // 점수 게이지 바
                    if (score > 0) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                          minHeight: 6,
                        ),
                      ),
                    ],

                    // 관찰 내용
                    if (observation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        title: '관찰',
                        content: observation,
                        color: item['color'] as Color,
                        isDark: isDark,
                      ),
                    ],

                    // 관상학적 해석
                    if (interpretation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        title: '해석',
                        content: interpretation,
                        color: item['color'] as Color,
                        isDark: isDark,
                      ),
                    ],

                    // 개운 조언
                    if (advice.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (item['color'] as Color).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.tips_and_updates_outlined,
                              color: item['color'] as Color,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                advice,
                                style: DSTypography.bodyMedium.copyWith(
                                  color: DSColors.textPrimary,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: (100 * index).ms),
          );
        }),
      ],
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DSTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: DSTypography.bodyMedium.copyWith(
            color: DSColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
