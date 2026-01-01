import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

/// 즉시 실행 조언 섹션
///
/// API 응답의 recommendations 필드를 표시합니다.
/// 시간순으로 정렬된 실행 가이드를 제공합니다.
class RecommendationsSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const RecommendationsSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final recommendationsRaw = fortuneResult?.data['recommendations'];
    final List<String> recommendations;

    if (recommendationsRaw is List) {
      recommendations = recommendationsRaw
          .map((e) => FortuneTextCleaner.clean(e.toString()))
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      recommendations = [];
    }

    if (recommendations.isEmpty) {
      return Center(
        child: Text(
          '실행 조언 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    // 우선순위에 따른 색상 매핑
    final List<Color> priorityColors = [
      DSColors.error, // 즉시 실행 - 빨간색
      colors.accent, // 1주일 내 - 보라색
      DSColors.warning, // 1개월 - 주황색
      DSColors.success, // 3개월 - 초록색
      Colors.blue, // 1년 - 파란색
      Colors.grey, // 평생 - 회색
    ];

    final List<IconData> priorityIcons = [
      Icons.flash_on, // 즉시 실행
      Icons.calendar_today, // 1주일 내
      Icons.date_range, // 1개월
      Icons.event_note, // 3개월
      Icons.timeline, // 1년
      Icons.all_inclusive, // 평생
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final recommendation = entry.value;
          final color = priorityColors[index % priorityColors.length];
          final icon = priorityIcons[index % priorityIcons.length];

          // "시기: 내용" 형태 파싱
          String timing = '';
          String action = recommendation;

          if (recommendation.contains(':')) {
            final colonIndex = recommendation.indexOf(':');
            timing = recommendation.substring(0, colonIndex).trim();
            action = recommendation.substring(colonIndex + 1).trim();
          }

          return Container(
            margin: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타임라인 인디케이터
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: color,
                      ),
                    ),
                    if (index < recommendations.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: colors.border.withValues(alpha: 0.5),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (timing.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            timing,
                            style: DSTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      Text(
                        action.isNotEmpty ? action : recommendation,
                        style: DSTypography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
