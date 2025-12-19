import 'package:flutter/material.dart';
import '../../../../core/theme/typography_unified.dart';

/// 💫 주간 트렌드 카드
class WeeklyTrendCard extends StatelessWidget {
  final List<int> weeklyScores;
  final bool isDark;

  const WeeklyTrendCard({
    super.key,
    required this.weeklyScores,
    required this.isDark,
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
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '이번 주 당신의 운세 흐름',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // 전통 목(木) 색상 그라데이션 (성장과 상승을 상징)
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF2E8B57) : const Color(0xFF3D9970),
                isDark ? const Color(0xFF1E5F3C) : const Color(0xFF2E8B57),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
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
                  style: context.bodySmall.copyWith(
                    color: Colors.white,
                    height: 1.5,
                    fontSize: 12,
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
                    // 전통 목(木) 색상 (좋은 날 강조)
                    color: score >= 80
                        ? const Color(0xFF2E8B57).withValues(alpha: 0.2)
                        : (isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(6),
                    border: score >= 80
                        ? Border.all(color: const Color(0xFF2E8B57), width: 1)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$score',
                        style: TextStyle(
                          color: score >= 80
                              ? const Color(0xFF2E8B57)
                              : (isDark ? Colors.white60 : Colors.black54),
                          fontSize: 11,
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
