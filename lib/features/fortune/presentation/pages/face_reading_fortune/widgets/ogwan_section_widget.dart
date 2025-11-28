import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
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
        'color': TossDesignSystem.purple,
      },
      {
        'key': 'eyebrow',
        'title': '눈썹(眉) - 보수관',
        'subtitle': '형제와 친구',
        'icon': Icons.remove_red_eye_outlined,
        'color': TossDesignSystem.tossBlue,
      },
      {
        'key': 'eye',
        'title': '눈(目) - 감찰관',
        'subtitle': '마음의 창',
        'icon': Icons.remove_red_eye,
        'color': TossDesignSystem.successGreen,
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
              Icon(Icons.face_retouching_natural, color: TossDesignSystem.purple, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오관(五官) 분석',
                    style: TossDesignSystem.heading2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전통 관상학의 핵심 - 얼굴 5대 관문',
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
          final content = ogwan[key]?.toString();

          if (content == null || content.isEmpty) return const SizedBox.shrink();

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
                                style: TossDesignSystem.heading4.copyWith(
                                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: TossDesignSystem.caption.copyWith(
                                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: TossDesignSystem.body1.copyWith(
                        color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: (100 * index).ms),
          );
        }),
      ],
    );
  }
}
