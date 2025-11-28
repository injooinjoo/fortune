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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주간 운세 트렌드',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '이번 주 당신의 운세 흐름',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF10B981) : const Color(0xFF34D399),
                isDark ? const Color(0xFF059669) : const Color(0xFF10B981),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Text(
                    '상승세',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '이번 주는 전반적으로 상승세를 타고 있습니다. 특히 수요일부터 금요일까지가 가장 좋은 시기입니다. 새로운 도전이나 중요한 결정을 내리기에 최적의 타이밍입니다.',
                  style: TypographyUnified.bodySmall.copyWith(
                    color: Colors.white,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: score >= 80
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : (isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                    border: score >= 80
                        ? Border.all(color: const Color(0xFF10B981), width: 1.5)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score',
                        style: TextStyle(
                          color: score >= 80
                              ? const Color(0xFF10B981)
                              : (isDark ? Colors.white60 : Colors.black54),
                          fontSize: 12,
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
