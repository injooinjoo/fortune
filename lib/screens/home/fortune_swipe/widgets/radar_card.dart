import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../presentation/widgets/fortune_infographic_widgets.dart';
import '../utils/fortune_swipe_helpers.dart';

/// 📈 5대 영역 레이더 카드 - ChatGPT Pulse 스타일
class RadarCard extends StatelessWidget {
  final Map<String, double> radarData;

  const RadarCard({
    super.key,
    required this.radarData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '5대 영역별 운세',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘의 각 분야별 운세를 한눈에',
          style: context.bodySmall.copyWith(
            color: context.colors.textPrimary.withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        // 카드 컨테이너 (Pulse 스타일)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 레이더 차트 - 전통 목(木) 색상 적용
              SizedBox(
                height: 180,
                child: FortuneInfographicWidgets.buildRadarChart(
                  scores: radarData.map((k, v) => MapEntry(k, v.round())),
                  size: 180,
                  primaryColor: const Color(0xFF2E8B57), // 고유 색상 - 木(목) 전통 청록
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 12),

              // 영역별 점수 리스트 (심플하게)
              ...radarData.entries.map((entry) {
                final areaColor = FortuneSwipeHelpers.getPulseScoreColor(entry.value.round());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // 영역 이름
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: context.bodySmall.copyWith(
                            color: context.colors.textPrimary,
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
                              height: 4,
                              decoration: BoxDecoration(
                                color: context.colors.textPrimary.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // 진행
                            FractionallySizedBox(
                              widthFactor: entry.value / 100,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: areaColor,
                                  borderRadius: BorderRadius.circular(2),
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
                          style: context.labelSmall.copyWith(
                            color: areaColor,
                            fontWeight: FontWeight.w700,
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
