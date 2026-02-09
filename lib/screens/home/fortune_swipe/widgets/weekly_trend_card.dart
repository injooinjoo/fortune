import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 💫 주간 트렌드 카드
class WeeklyTrendCard extends StatelessWidget {
  final List<int> weeklyScores;

  const WeeklyTrendCard({
    super.key,
    required this.weeklyScores,
  });

  /// 주간 트렌드 레이블 계산 (상승세/평탄/하락세)
  String _getTrendLabel() {
    if (weeklyScores.length < 2) return '평탄';

    final firstHalf = weeklyScores.take(3).fold<int>(0, (a, b) => a + b) / 3;
    final secondHalf = weeklyScores.skip(4).fold<int>(0, (a, b) => a + b) / 3;
    final diff = secondHalf - firstHalf;

    if (diff > 5) return '상승세';
    if (diff < -5) return '하락세';
    return '평탄';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주간 운세 트렌드',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          '이번 주 당신의 운세 흐름',
          style: context.bodySmall.copyWith(
            color: context.colors.textPrimary.withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: DSSpacing.md),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // 고유 색상 - 전통 목(木) 색상 그라데이션 (성장과 상승을 상징)
            gradient: LinearGradient(
              colors: [
                context.isDark ? DSColors.success : const Color(0xFF3D9970), // 고유 색상 - 木 청록
                context.isDark ? const Color(0xFF1E5F3C) : DSColors.success, // 고유 색상 - 木 진한
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📈', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Text(
                    _getTrendLabel(),
                    style: context.heading4.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '이번 주는 전반적으로 상승세를 타고 있습니다. 특히 수요일부터 금요일까지가 가장 좋은 시기입니다. 새로운 도전이나 중요한 결정을 내리기에 최적의 타이밍입니다.',
                  style: context.labelTiny.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 요일별 간단 정보
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 48) / 7; // 48 = spacing * 6
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weeklyScores.asMap().entries.map((entry) {
                final index = entry.key;
                final score = entry.value;
                final day = ['월', '화', '수', '목', '금', '토', '일'][index];
                return Container(
                  width: itemWidth,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    // 고유 색상 - 전통 목(木) 색상 (좋은 날 강조)
                    color: score >= 80
                        ? DSColors.success.withValues(alpha: 0.2) // 좋은 날 강조
                        : context.colors.textPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: score >= 80
                        ? Border.all(color: DSColors.success, width: 1) // 좋은 날 강조
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: context.labelTiny.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        '$score',
                        style: context.labelTiny.copyWith(
                          color: score >= 80
                              ? DSColors.success // 좋은 날 강조
                              : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
