import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../pages/biorhythm_result_page.dart';
import 'components/biorhythm_hanji_card.dart';
import 'components/biorhythm_score_badge.dart';
import 'components/rhythm_traditional_icon.dart';
import 'painters/ink_score_circle_painter.dart';

/// Today's overall status card with traditional Korean ink wash style
///
/// Design Philosophy:
/// - Calligraphy style score display with Hanja status
/// - Hanji paper card background
/// - Obangsaek (오방색) gradient based on status
class TodayOverallStatusCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const TodayOverallStatusCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.scroll,
      showCornerDecorations: true,
      showSealStamp: true,
      sealText: DSBiorhythmColors.getStatusHanja(biorhythmData.overallScore),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main score with ink wash circle
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: InkScoreCirclePainter(
                score: biorhythmData.overallScore,
                isDark: isDark,
                showHanja: true,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${biorhythmData.overallScore}',
                      style: context.displayMedium.copyWith(
                        fontFamily: 'GowunBatang',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '점',
                      style: context.bodyMedium.copyWith(
                        fontFamily: 'GowunBatang',
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status message in calligraphy style
          Text(
            biorhythmData.statusMessage,
            style: context.heading3.copyWith(
              fontFamily: 'GowunBatang',
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Date with traditional styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: DSBiorhythmColors.getInkWashGuide(isDark).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTraditionalDate(),
              style: context.labelMedium.copyWith(
                fontFamily: 'GowunBatang',
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTraditionalDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일의 기운';
  }
}

/// Three rhythm detail cards with traditional Korean style
///
/// Design Philosophy:
/// - Traditional icon representation (Sun, Lotus, Moon)
/// - Element badge showing 火, 木, 水
/// - Ink wash style score badges
/// - Hanji paper card backgrounds
class RhythmDetailCards extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const RhythmDetailCards({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRhythmCard(
          context,
          type: BiorhythmType.physical,
          title: '신체 리듬',
          subtitle: '활력의 불기운 (火氣)',
          score: biorhythmData.physicalScore,
          status: biorhythmData.physicalStatus,
          cycleDays: 23,
        ),
        const SizedBox(height: 16),
        _buildRhythmCard(
          context,
          type: BiorhythmType.emotional,
          title: '감정 리듬',
          subtitle: '정서의 나무기운 (木氣)',
          score: biorhythmData.emotionalScore,
          status: biorhythmData.emotionalStatus,
          cycleDays: 28,
        ),
        const SizedBox(height: 16),
        _buildRhythmCard(
          context,
          type: BiorhythmType.intellectual,
          title: '지적 리듬',
          subtitle: '지혜의 물기운 (水氣)',
          score: biorhythmData.intellectualScore,
          status: biorhythmData.intellectualStatus,
          cycleDays: 33,
        ),
      ],
    );
  }

  Widget _buildRhythmCard(
    BuildContext context, {
    required BiorhythmType type,
    required String title,
    required String subtitle,
    required int score,
    required String status,
    required int cycleDays,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);
    final color = _getTypeColor(type, isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.standard,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Traditional icon
          RhythmTraditionalIcon(
            type: type,
            size: 56,
            showBackground: true,
            showLabel: false,
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: context.bodyMedium.copyWith(
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElementBadge(
                      type: type,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.labelMedium.copyWith(
                    fontFamily: 'Pretendard',
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                // Status text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: context.labelMedium.copyWith(
                      fontFamily: 'GowunBatang',
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Score badge
          BiorhythmScoreBadge(
            score: score,
            type: type,
            size: BadgeSize.medium,
            showLabel: false,
            showHanja: true,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(BiorhythmType type, bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }
}

/// Score summary row showing all three rhythms
class RhythmScoreSummaryRow extends StatelessWidget {
  final BiorhythmData biorhythmData;
  final bool animate;

  const RhythmScoreSummaryRow({
    super.key,
    required this.biorhythmData,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return BiorhythmHanjiCard(
      style: HanjiCardStyle.minimal,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: BiorhythmScoreBadgeRow(
        physical: biorhythmData.physicalScore,
        emotional: biorhythmData.emotionalScore,
        intellectual: biorhythmData.intellectualScore,
        size: BadgeSize.medium,
        showLabels: true,
        showHanja: true,
        animate: animate,
        alignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }
}

/// Compact inline rhythm scores for use in lists
class CompactRhythmScores extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const CompactRhythmScores({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.minimal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 삼기(三氣)',
            style: context.bodySmall.copyWith(
              fontFamily: 'GowunBatang',
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BiorhythmScoreInline(
                  score: biorhythmData.physicalScore,
                  type: BiorhythmType.physical,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BiorhythmScoreInline(
                  score: biorhythmData.emotionalScore,
                  type: BiorhythmType.emotional,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BiorhythmScoreInline(
                  score: biorhythmData.intellectualScore,
                  type: BiorhythmType.intellectual,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
