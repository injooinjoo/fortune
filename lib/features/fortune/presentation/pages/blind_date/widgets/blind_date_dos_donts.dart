import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// DO's & DON'Ts 위젯
class BlindDateDosDonts extends StatelessWidget {
  const BlindDateDosDonts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rule,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DO\'s & DON\'Ts',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // DO's Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TossDesignSystem.successGreen.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: TossDesignSystem.successGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DO\'s - 꼭 하세요',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TossDesignSystem.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...dos.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // DON'Ts Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TossDesignSystem.errorRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 20,
                          color: TossDesignSystem.errorRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DON\'Ts - 피하세요',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TossDesignSystem.errorRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...donts.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Final Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.warningYellow.withValues(alpha: 0.1),
                      TossDesignSystem.warningOrange.withValues(alpha: 0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: TossDesignSystem.warningYellow,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '가장 중요한 것은 진실된 자신의 모습을 보여주는 것입니다. 행운을 빕니다!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
