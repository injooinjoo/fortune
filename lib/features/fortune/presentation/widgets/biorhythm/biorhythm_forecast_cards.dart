import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../core/theme/font_config.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../pages/biorhythm_result_page.dart';
import 'components/biorhythm_hanji_card.dart';
import 'painters/ink_wave_chart_painter.dart';

/// Weekly forecast header with traditional Korean style
///
/// Design Philosophy:
/// - Calligraphy style title
/// - Date range in traditional format
/// - Hanji scroll card style
class WeeklyForecastHeader extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const WeeklyForecastHeader({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    final startDate = DateTime.now();
    final endDate = startDate.add(const Duration(days: 6));

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.scroll,
      showSealStamp: true,
      sealText: '週',
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '주간 운세 전망',
            style: context.heading3.copyWith(
              fontFamily: FontConfig.primary,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateRange(startDate, endDate),
            style: context.bodySmall.copyWith(
              fontFamily: FontConfig.primary,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          // Legend row
          _buildLegendRow(context, isDark),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.month}월 ${start.day}일 ~ ${end.month}월 ${end.day}일';
  }

  Widget _buildLegendRow(BuildContext context, bool isDark) {
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          '신체(火)',
          DSBiorhythmColors.getPhysical(isDark),
          textColor,
        ),
        const SizedBox(width: 20),
        _buildLegendItem(
          context,
          '감정(木)',
          DSBiorhythmColors.getEmotional(isDark),
          textColor,
        ),
        const SizedBox(width: 20),
        _buildLegendItem(
          context,
          '지적(水)',
          DSBiorhythmColors.getIntellectual(isDark),
          textColor,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.labelMedium.copyWith(
            fontFamily: FontConfig.primary,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Weekly rhythm chart with traditional ink wash style
///
/// Design Philosophy:
/// - CustomPainter-based ink wash wave lines (replaces fl_chart)
/// - Brush stroke effects with thickness variation
/// - Ink bleed at data points (seal stamp style)
/// - Traditional day labels in Korean
class WeeklyRhythmChart extends StatefulWidget {
  final BiorhythmData biorhythmData;

  const WeeklyRhythmChart({
    super.key,
    required this.biorhythmData,
  });

  @override
  State<WeeklyRhythmChart> createState() => _WeeklyRhythmChartState();
}

class _WeeklyRhythmChartState extends State<WeeklyRhythmChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Convert -100~100 to 0~100 for display
    final physicalData = widget.biorhythmData.physicalWeek
        .map((v) => (v + 100) / 2)
        .toList()
        .cast<double>();
    final emotionalData = widget.biorhythmData.emotionalWeek
        .map((v) => (v + 100) / 2)
        .toList()
        .cast<double>();
    final intellectualData = widget.biorhythmData.intellectualWeek
        .map((v) => (v + 100) / 2)
        .toList()
        .cast<double>();

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.standard,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 220,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => CustomPaint(
            size: const Size(double.infinity, 220),
            painter: InkWaveChartPainter(
              physicalData: physicalData,
              emotionalData: emotionalData,
              intellectualData: intellectualData,
              animationProgress: _animation.value,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Important dates card with traditional Korean style
///
/// Design Philosophy:
/// - Hanji card with traditional decorations
/// - Lucky/unlucky day indicators with 吉/凶 symbols
/// - Calligraphy style text
class ImportantDatesCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const ImportantDatesCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    final bestDay = _findBestDay();
    final worstDay = _findWorstDay();

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.standard,
      showCornerDecorations: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: DSBiorhythmColors.goldAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '이번 주 길흉일',
                style: context.bodyMedium.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Best day (길일)
          _buildDateItem(
            context,
            type: DateType.lucky,
            title: '길일 (吉日)',
            date: bestDay['date'] as String,
            description: bestDay['description'] as String,
          ),
          const SizedBox(height: 16),

          // Worst day (주의일)
          _buildDateItem(
            context,
            type: DateType.warning,
            title: '주의일 (凶日)',
            date: worstDay['date'] as String,
            description: worstDay['description'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
    BuildContext context, {
    required DateType type,
    required String title,
    required String date,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    final color = type == DateType.lucky
        ? DSBiorhythmColors.statusExcellent
        : DSBiorhythmColors.statusCritical;

    final hanja = type == DateType.lucky ? '吉' : '凶';

    return Row(
      children: [
        // Seal-style badge with Hanja
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              hanja,
              style: context.heading3.copyWith(
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: context.bodySmall.copyWith(
                      fontFamily: FontConfig.primary,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      date,
                      style: context.labelMedium.copyWith(
                        fontFamily: FontConfig.primary,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.labelMedium.copyWith(
                  fontFamily: FontConfig.primary,
                  color: textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _findBestDay() {
    double bestScore = -101;
    int bestDayIndex = 0;

    for (int i = 0; i < 7; i++) {
      final avgScore = (biorhythmData.physicalWeek[i] +
              biorhythmData.emotionalWeek[i] +
              biorhythmData.intellectualWeek[i]) /
          3;
      if (avgScore > bestScore) {
        bestScore = avgScore;
        bestDayIndex = i;
      }
    }

    final date = DateTime.now().add(Duration(days: bestDayIndex));
    final dayNames = ['오늘', '내일', '모레'];
    final dateStr = bestDayIndex < 3
        ? dayNames[bestDayIndex]
        : '${date.month}월 ${date.day}일';

    return {
      'date': dateStr,
      'description': '삼기(三氣)가 조화로워 만사형통의 날입니다',
    };
  }

  Map<String, String> _findWorstDay() {
    double worstScore = 101;
    int worstDayIndex = 0;

    for (int i = 0; i < 7; i++) {
      final avgScore = (biorhythmData.physicalWeek[i] +
              biorhythmData.emotionalWeek[i] +
              biorhythmData.intellectualWeek[i]) /
          3;
      if (avgScore < worstScore) {
        worstScore = avgScore;
        worstDayIndex = i;
      }
    }

    final date = DateTime.now().add(Duration(days: worstDayIndex));
    final dayNames = ['오늘', '내일', '모레'];
    final dateStr = worstDayIndex < 3
        ? dayNames[worstDayIndex]
        : '${date.month}월 ${date.day}일';

    return {
      'date': dateStr,
      'description': '기운이 낮아 무리하지 않는 것이 좋습니다',
    };
  }
}

/// Date type for styling
enum DateType { lucky, warning }

/// Rhythm cycle info card
class RhythmCycleInfoCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const RhythmCycleInfoCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.minimal,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '바이오리듬 주기',
            style: context.bodyMedium.copyWith(
              fontFamily: FontConfig.primary,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCycleInfo(
                context,
                label: '신체(火)',
                days: 23,
                color: DSBiorhythmColors.getPhysical(isDark),
              ),
              _buildCycleInfo(
                context,
                label: '감정(木)',
                days: 28,
                color: DSBiorhythmColors.getEmotional(isDark),
              ),
              _buildCycleInfo(
                context,
                label: '지적(水)',
                days: 33,
                color: DSBiorhythmColors.getIntellectual(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfo(
    BuildContext context, {
    required String label,
    required int days,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$days',
              style: context.heading4.copyWith(
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.labelMedium.copyWith(
            fontFamily: FontConfig.primary,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        Text(
          '일 주기',
          style: context.labelTiny.copyWith(
            fontFamily: FontConfig.primary,
            color: textColor.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
