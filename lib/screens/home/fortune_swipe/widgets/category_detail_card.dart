import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/fortune_swipe_helpers.dart';

/// ❤️ 카테고리 상세 카드 (연애/금전/직장/학업/건강)
class CategoryDetailCard extends StatelessWidget {
  final String title;
  final String categoryKey;
  final int score;
  final String advice;
  final bool isDark;

  const CategoryDetailCard({
    super.key,
    required this.title,
    required this.categoryKey,
    required this.score,
    required this.advice,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = FortuneSwipeHelpers.getCategoryEmoji(categoryKey);
    final scoreColor = FortuneSwipeHelpers.getPulseScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 헤더 (가운데 정렬)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 카드 (Pulse 스타일)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 점수 표시 - 크고 임팩트 있게
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 48,
                      color: scoreColor,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '점',
                    style: TextStyle(
                      fontSize: 16,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 프로그레스 바
              Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: score / 100,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate()
                      .scaleX(begin: 0, duration: 800.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 조언 텍스트
              Text(
                advice,
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }
}
