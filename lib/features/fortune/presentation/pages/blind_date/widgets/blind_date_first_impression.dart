import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 첫인상 가이드 위젯
class BlindDateFirstImpression extends StatelessWidget {
  const BlindDateFirstImpression({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: colors.accentTertiary,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '첫인상 가이드',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              )
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 팁 리스트
          ...impressionTips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                      ),
                      child: Icon(
                        tip['icon'] as IconData,
                        size: 20,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.iconTextGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['tip'] as String,
                            style: DSTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            tip['detail'] as String,
                            style: DSTypography.bodyMedium.copyWith(
                              color: colors.textSecondary,
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
    );
  }
}
