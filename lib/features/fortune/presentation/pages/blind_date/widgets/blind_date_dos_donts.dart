import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// DO's & DON'Ts 위젯
class BlindDateDosDonts extends StatelessWidget {
  const BlindDateDosDonts({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final dos = [
      '시간 약속 지키기 (10분 전 도착)',
      '긍정적인 태도 유지하기',
      '상대방에게 질문하고 관심 보이기',
      '적당한 유머로 분위기 풀기',
      '감사 인사 전하기'
    ];

    final donts = [
      '핸드폰 자주 확인하지 않기',
      '과도한 자기 자랑 피하기',
      '부정적인 이야기 하지 않기',
      '너무 개인적인 질문 피하기',
      '결론 급하게 내리지 않기'
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
                Icons.rule,
                color: colors.accent,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                'DO\'s & DON\'Ts',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // DO's Section
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: DSColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: DSColors.success,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      'DO\'s - 꼭 하세요',
                      style: DSTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DSColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                ...dos.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: DSTypography.bodyMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: DSTypography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          // DON'Ts Section
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: DSColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: DSColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.cancel,
                      size: 20,
                      color: DSColors.error,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      'DON\'Ts - 피하세요',
                      style: DSTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DSColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                ...donts.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: DSTypography.bodyMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: DSTypography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          // Final Message
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DSColors.warning.withValues(alpha: 0.1),
                  DSColors.warning.withValues(alpha: 0.15)
                ],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: DSColors.warning,
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Text(
                    '가장 중요한 것은 진실된 자신의 모습을 보여주는 것입니다. 행운을 빕니다!',
                    style: DSTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
