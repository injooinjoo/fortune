import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/widgets/fortune_infographic_widgets.dart';
import '../utils/fortune_swipe_helpers.dart';

/// 📈 5대 영역 레이더 카드 - ChatGPT Pulse 스타일
class RadarCard extends StatelessWidget {
  final Map<String, double> radarData;
  final bool isDark;

  const RadarCard({
    super.key,
    required this.radarData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '5대 영역별 운세',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '오늘의 각 분야별 운세를 한눈에',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // 카드 컨테이너 (Pulse 스타일)
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
              // 레이더 차트
              SizedBox(
                height: 240,
                child: FortuneInfographicWidgets.buildRadarChart(
                  scores: radarData.map((k, v) => MapEntry(k, v.round())),
                  size: 240,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 20),

              // 영역별 점수 리스트 (심플하게)
              ...radarData.entries.map((entry) {
                final areaColor = FortuneSwipeHelpers.getPulseScoreColor(entry.value.round());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // 영역 이름
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TypographyUnified.bodySmall.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // 프로그레스 바
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            // 배경
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            // 진행
                            FractionallySizedBox(
                              widthFactor: entry.value / 100,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: areaColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ).animate()
                                .scaleX(
                                  begin: 0,
                                  duration: 800.ms,
                                  delay: 200.ms,
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment.centerLeft,
                                ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 점수
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${entry.value.round()}',
                          style: TextStyle(
                            color: areaColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }
}
