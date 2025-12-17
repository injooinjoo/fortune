import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/components/app_card.dart';
import '../../../../data/saju_explanations.dart';
import 'saju/saju_concept_card.dart';

/// 오행 균형 차트 위젯
class SajuElementChart extends StatefulWidget {
  final Map<String, dynamic> elementBalance;
  final AnimationController animationController;

  const SajuElementChart({
    super.key,
    required this.elementBalance,
    required this.animationController,
  });

  @override
  State<SajuElementChart> createState() => _SajuElementChartState();
}

class _SajuElementChartState extends State<SajuElementChart> {
  late Animation<double> _chartAnimation;
  late Animation<double> _titleAnimation;
  
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    
    _titleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
    ));
    
    _chartAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.5, 0.8, curve: Curves.elasticOut),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final typography = context.typography;
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return AppCard(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              FadeTransition(
                opacity: _titleAnimation,
                child: Row(
                  children: [
                    Icon(
                      Icons.donut_large_outlined,
                      color: colors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '오행 균형',
                      style: typography.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              FadeTransition(
                opacity: _titleAnimation,
                child: Text(
                  '천간지지의 오행 분포를 확인해보세요',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: DSSpacing.md),

              // 차트와 범례 - 더 컴팩트하게
              Row(
                children: [
                  // 파이 차트
                  Expanded(
                    flex: 3,
                    child: _buildPieChart(context, isDark),
                  ),

                  const SizedBox(width: DSSpacing.md),

                  // 범례
                  Expanded(
                    flex: 2,
                    child: _buildLegend(context, isDark),
                  ),
                ],
              ),

              const SizedBox(height: DSSpacing.md),

              // 오행 해석
              _buildElementInterpretation(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final totalCount = widget.elementBalance.values.fold<double>(0, (sum, count) => sum + (count is num ? count.toDouble() : 0));

    if (totalCount == 0) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            '오행 데이터가 없습니다',
            style: typography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });

              // 탭 시 바텀시트 표시
              if (event is FlTapUpEvent &&
                  pieTouchResponse != null &&
                  pieTouchResponse.touchedSection != null) {
                final elements = ['목', '화', '토', '금', '수'];
                final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                if (touchedIndex >= 0 && touchedIndex < elements.length) {
                  final element = elements[touchedIndex];
                  final data = SajuExplanations.ohangElements[element];
                  if (data != null) {
                    showOhangExplanationSheet(
                      context: context,
                      element: element,
                      hanja: data['hanja'] ?? '',
                      meaning: data['meaning'] ?? '',
                      personality: data['personality'] ?? '',
                      description: data['description'] ?? '',
                      season: data['season'] ?? '',
                      direction: data['direction'] ?? '',
                      organ: data['organ'] ?? '',
                      colorName: data['color'] ?? '',
                      number: data['number'] ?? '',
                    );
                  }
                }
              }
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 3,
          centerSpaceRadius: 35 * _chartAnimation.value,
          sections: _buildPieChartSections(context),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(BuildContext context) {
    final typography = context.typography;
    final elements = ['목', '화', '토', '금', '수'];
    final totalCount = widget.elementBalance.values.fold<double>(0, (sum, count) => sum + (count is num ? count.toDouble() : 0));

    return elements.asMap().entries.map((entry) {
      final index = entry.key;
      final element = entry.value;
      final rawCount = widget.elementBalance[element];
      final count = rawCount is num ? rawCount.toDouble() : 0.0;
      final percentage = totalCount > 0 ? count / totalCount * 100 : 0.0;
      final isTouched = index == _touchedIndex;

      final radius = (isTouched ? 50.0 : 42.0) * _chartAnimation.value;
      final color = _getElementColor(context, element);

      return PieChartSectionData(
        color: color,
        value: count,
        title: count > 0 ? '${percentage.round()}%' : '',
        radius: radius,
        titleStyle: typography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isTouched ? 12 : 10,
        ),
        titlePositionPercentageOffset: 0.55,
        badgeWidget: isTouched ? _buildBadge(context, element, count) : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  Widget _buildBadge(BuildContext context, String element, double count) {
    final typography = context.typography;
    final elementColor = _getElementColor(context, element);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: elementColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: elementColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$element: ${count.toStringAsFixed(1)}',
        style: typography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    return FadeTransition(
      opacity: _chartAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: widget.elementBalance.entries.map((entry) {
          final element = entry.key;
          final rawCount = entry.value;
          final count = rawCount is num ? rawCount.toDouble() : 0.0;
          final color = _getElementColor(context, element);
          final strength = _getElementStrength(count);

          return GestureDetector(
            onTap: () {
              final data = SajuExplanations.ohangElements[element];
              if (data != null) {
                showOhangExplanationSheet(
                  context: context,
                  element: element,
                  hanja: data['hanja'] ?? '',
                  meaning: data['meaning'] ?? '',
                  personality: data['personality'] ?? '',
                  description: data['description'] ?? '',
                  season: data['season'] ?? '',
                  direction: data['direction'] ?? '',
                  organ: data['organ'] ?? '',
                  colorName: data['color'] ?? '',
                  number: data['number'] ?? '',
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    element,
                    style: typography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    strength,
                    style: typography.bodySmall.copyWith(
                      fontSize: 10,
                      color: colors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    count.toStringAsFixed(1),
                    style: typography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildElementInterpretation(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final dominantElement = _getDominantElement();
    final lackingElement = _getLackingElement();

    return FadeTransition(
      opacity: _chartAnimation,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: colors.accent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '오행 분석',
                  style: typography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 강한 오행
            _buildAnalysisItem(
              context,
              '강한 오행',
              dominantElement['element'] ?? '',
              dominantElement['interpretation'] ?? '',
              _getElementColor(context, dominantElement['element'] ?? ''),
              Icons.trending_up,
              isDark,
            ),

            const SizedBox(height: 8),

            // 부족한 오행
            _buildAnalysisItem(
              context,
              '부족한 오행',
              lackingElement['element'] ?? '',
              lackingElement['interpretation'] ?? '',
              _getElementColor(context, lackingElement['element'] ?? ''),
              Icons.trending_down,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(BuildContext context, String title, String element, String interpretation, Color color, IconData icon, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: color,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: typography.bodySmall.copyWith(
                      fontSize: 11,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      element,
                      style: typography.bodySmall.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                interpretation,
                style: typography.bodySmall.copyWith(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _getDominantElement() {
    String maxElement = '목';
    double maxCount = 0;

    widget.elementBalance.forEach((element, rawCount) {
      final count = rawCount is num ? rawCount.toDouble() : 0.0;
      if (count > maxCount) {
        maxCount = count;
        maxElement = element;
      }
    });
    
    final interpretations = {
      '목': '성장과 발전 욕구가 강하고 적극적인 성격입니다',
      '화': '열정적이고 활동적이며 리더십이 뛰어납니다',
      '토': '신중하고 안정적이며 신뢰감을 주는 성격입니다',
      '금': '원칙적이고 정의로우며 결단력이 있습니다',
      '수': '지혜롭고 유연하며 적응력이 뛰어납니다',
    };
    
    return {
      'element': maxElement,
      'interpretation': interpretations[maxElement] ?? '균형잡힌 성격입니다',
    };
  }

  Map<String, String> _getLackingElement() {
    String minElement = '목';
    double minCount = 999;

    widget.elementBalance.forEach((element, rawCount) {
      final count = rawCount is num ? rawCount.toDouble() : 0.0;
      if (count < minCount) {
        minCount = count;
        minElement = element;
      }
    });
    
    final interpretations = {
      '목': '새로운 도전과 성장이 필요한 시기입니다',
      '화': '열정과 적극성을 키워나가면 좋겠습니다',
      '토': '안정감과 신뢰성을 더 키울 필요가 있습니다',
      '금': '원칙과 의지력을 강화하면 도움이 됩니다',
      '수': '유연함과 지혜를 기를 필요가 있습니다',
    };
    
    return {
      'element': minElement,
      'interpretation': interpretations[minElement] ?? '보완이 필요합니다',
    };
  }

  String _getElementStrength(double count) {
    if (count >= 2.5) return '강함';
    if (count >= 1.5) return '보통';
    if (count >= 0.5) return '약함';
    return '없음';
  }

  Color _getElementColor(BuildContext context, String element) {
    final colors = context.colors;
    switch (element) {
      case '목':
        return colors.success;
      case '화':
        return colors.error;
      case '토':
        return colors.warning;
      case '금':
        return colors.textSecondary;
      case '수':
        return colors.accent;
      default:
        return colors.textTertiary;
    }
  }
}