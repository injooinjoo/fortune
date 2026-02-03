import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/widgets/simple_blur_overlay.dart';

/// 얼굴 부위별 상세 분석 카드
/// 오관(五官), 삼정(三停), 십이궁(十二宮) 등의 개별 부위 카드
class FaceZoneDetailCard extends StatelessWidget {
  final String zoneKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? zoneData;
  final bool isBlurred;
  final List<String> blurredSections;
  final String sectionKey;
  final int animationIndex;

  const FaceZoneDetailCard({
    super.key,
    required this.zoneKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.zoneData,
    this.isBlurred = false,
    this.blurredSections = const [],
    this.sectionKey = 'ogwan',
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // zoneData가 Map인 경우 파싱
    final observation = zoneData?['observation'] as String? ?? '';
    final interpretation = zoneData?['interpretation'] as String? ?? '';
    final score = (zoneData?['score'] as num?)?.toInt() ?? 0;
    final advice = zoneData?['advice'] as String? ?? '';

    // 삼정의 경우 다른 필드 구조
    final description = zoneData?['description'] as String? ?? '';
    final period = zoneData?['period'] as String? ?? '';
    final peakAge = zoneData?['peakAge'] as String? ?? '';

    // 모든 필드가 비어있으면 표시하지 않음
    if (observation.isEmpty &&
        interpretation.isEmpty &&
        advice.isEmpty &&
        description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SimpleBlurOverlay(
        isBlurred: isBlurred && blurredSections.contains(sectionKey),
        child: AppCard(
          style: AppCardStyle.filled,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 아이콘 + 제목 + 점수
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.labelLarge.copyWith(
                            color: isDark
                                ? DSColors.textPrimary
                                : DSColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: context.labelSmall.copyWith(
                            color: isDark
                                ? DSColors.textSecondary
                                : DSColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 점수 배지
                  if (score > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$score점',
                        style: context.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              // 점수 게이지 바
              if (score > 0) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],

              // 오관 형식 (observation, interpretation, advice)
              if (observation.isNotEmpty || interpretation.isNotEmpty) ...[
                // 관찰 내용
                if (observation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    context: context,
                    title: '관찰',
                    content: observation,
                    color: color,
                    isDark: isDark,
                  ),
                ],

                // 관상학적 해석
                if (interpretation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailSection(
                    context: context,
                    title: '해석',
                    content: interpretation,
                    color: color,
                    isDark: isDark,
                  ),
                ],
              ]
              // 삼정 형식 (description, period, peakAge)
              else if (description.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (period.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      period,
                      style: context.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  description,
                  style: context.bodyMedium.copyWith(
                    color: isDark
                        ? DSColors.textPrimary
                        : DSColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                if (peakAge.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '전성기: $peakAge',
                        style: context.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              // 개운 조언
              if (advice.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: color,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          advice,
                          style: context.bodyMedium.copyWith(
                            color: isDark
                                ? DSColors.textPrimary
                                : DSColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (100 * animationIndex).ms);
  }

  Widget _buildDetailSection({
    required BuildContext context,
    required String title,
    required String content,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: context.bodyMedium.copyWith(
            color: isDark
                ? DSColors.textPrimary
                : DSColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
