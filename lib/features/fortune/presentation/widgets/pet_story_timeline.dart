import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 반려운 스토리 타임라인 위젯
/// 아침 → 점심 → 저녁 흐름으로 하루 이야기를 보여줍니다.
class PetStoryTimeline extends StatelessWidget {
  final String opening;
  final String morningChapter;
  final String afternoonChapter;
  final String eveningChapter;
  final String petEmoji;
  final String petName;

  const PetStoryTimeline({
    super.key,
    required this.opening,
    required this.morningChapter,
    required this.afternoonChapter,
    required this.eveningChapter,
    required this.petEmoji,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.08),
            colors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(petEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$petName의 오늘 하루 이야기',
                      style: context.heading3.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opening,
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 타임라인
          _buildTimelineNode(
            context: context,
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFFF59E0B), // 골드
            time: '아침',
            story: morningChapter,
            isFirst: true,
          ),
          _buildTimelineConnector(context),
          _buildTimelineNode(
            context: context,
            icon: Icons.wb_cloudy_rounded,
            iconColor: colors.accent,
            time: '점심',
            story: afternoonChapter,
            isFirst: false,
          ),
          _buildTimelineConnector(context),
          _buildTimelineNode(
            context: context,
            icon: Icons.nights_stay_rounded,
            iconColor: const Color(0xFF8B5CF6), // 퍼플
            time: '저녁',
            story: eveningChapter,
            isFirst: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String time,
    required String story,
    required bool isFirst,
  }) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        // 콘텐츠
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: context.labelMedium.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                story,
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(left: 19, top: 8, bottom: 8),
      width: 2,
      height: 24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.accent.withValues(alpha: 0.3),
            colors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
