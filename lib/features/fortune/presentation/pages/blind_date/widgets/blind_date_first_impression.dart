import 'package:flutter/material.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 첫인상 가이드 위젯
class BlindDateFirstImpression extends StatelessWidget {
  const BlindDateFirstImpression({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final impressionTips = [
      {
        'tip': '미소로 인사하기',
        'detail': '밝은 미소는 호감도를 높입니다',
        'icon': Icons.sentiment_satisfied
      },
      {
        'tip': '아이컨택 유지',
        'detail': '적당한 눈맿춤으로 진정성 전달',
        'icon': Icons.remove_red_eye
      },
      {
        'tip': '경청하는 자세',
        'detail': '상대방 이야기에 집중하세요',
        'icon': Icons.hearing
      },
      {
        'tip': '자연스러운 바디랭귀지',
        'detail': '열린 자세로 편안함 표현',
        'icon': Icons.accessibility_new
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '첫인상 가이드',
                    style: theme.textTheme.headlineSmall,
                  )
                ],
              ),
              const SizedBox(height: 16),
              ...impressionTips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            tip['icon'] as IconData,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['tip'] as String,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip['detail'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
