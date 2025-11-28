import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/typography_unified.dart';
import '../utils/fortune_swipe_helpers.dart';

/// 📊 총운 카드 - ChatGPT Pulse 스타일
class OverallCard extends StatelessWidget {
  final int score;
  final bool isDark;
  final String message;
  final String? subtitle;
  final String fullDescription;

  const OverallCard({
    super.key,
    required this.score,
    required this.isDark,
    required this.message,
    this.subtitle,
    required this.fullDescription,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = FortuneSwipeHelpers.getPulseScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (카드 제목만 표시 - 이름은 상단 헤더에 있음)
        Text(
          '오늘의 총운',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 24),

        // 카드 컨테이너 (Pulse 스타일 - 흰색 배경 + 그림자)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 점수 - 크고 임팩트 있는 숫자
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 96,
                  color: scoreColor,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -4,
                  height: 1.0,
                ),
              ).animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9), duration: 500.ms, curve: Curves.easeOut),

              const SizedBox(height: 8),

              // 서브텍스트
              Text(
                'POINTS',
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ).animate()
                .fadeIn(duration: 500.ms, delay: 150.ms),

              const SizedBox(height: 28),

              // 프로그레스 바 (얇고 심플)
              Stack(
                children: [
                  // 배경 바
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  // 진행 바 (단색)
                  FractionallySizedBox(
                    widthFactor: score / 100,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ).animate()
                      .scaleX(
                        begin: 0,
                        duration: 1000.ms,
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerLeft,
                      ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // 메시지 카드 (사자성어)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 300.ms)
          .slideY(begin: 0.06, duration: 500.ms, delay: 300.ms, curve: Curves.easeOut),

        const SizedBox(height: 12),

        // 300자 상세 설명 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            fullDescription,
            style: TypographyUnified.bodySmall.copyWith(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: -0.2,
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 400.ms)
          .slideY(begin: 0.06, duration: 500.ms, delay: 400.ms, curve: Curves.easeOut),
      ],
    );
  }
}
