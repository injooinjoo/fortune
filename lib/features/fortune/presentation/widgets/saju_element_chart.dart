import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/components/toss_card.dart';

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
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return TossCard(
          padding: const EdgeInsets.all(TossTheme.spacingL),
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
                      color: TossTheme.brandBlue,
                      size: 24,
                    ),
                    const SizedBox(width: TossTheme.spacingS),
                    Text(
                      '오행 균형',
                      style: TossTheme.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingS),
              
              FadeTransition(
                opacity: _titleAnimation,
                child: Text(
                  '천간지지의 오행 분포를 확인해보세요',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 차트와 범례
              Row(
                children: [
                  // 파이 차트
                  Expanded(
                    flex: 3,
                    child: _buildPieChart(),
                  ),
                  
                  const SizedBox(width: TossTheme.spacingL),
                  
                  // 범례
                  Expanded(
                    flex: 2,
                    child: _buildLegend(),
                  ),
                ],
              ),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 오행 해석
              _buildElementInterpretation(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart() {
    final totalCount = widget.elementBalance.values.fold<int>(0, (sum, count) => sum + (count as int));
    
    if (totalCount == 0) {
      return Container(
        height: 150,
        child: Center(
          child: Text(
            '오행 데이터가 없습니다',
            style: TossTheme.caption.copyWith(
              color: TossTheme.textGray500,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 150,
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
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 50 * _chartAnimation.value,
          sections: _buildPieChartSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final elements = ['목', '화', '토', '금', '수'];
    final totalCount = widget.elementBalance.values.fold<int>(0, (sum, count) => sum + (count as int));
    
    return elements.asMap().entries.map((entry) {
      final index = entry.key;
      final element = entry.value;
      final count = widget.elementBalance[element] as int? ?? 0;
      final percentage = totalCount > 0 ? count / totalCount * 100 : 0.0;
      final isTouched = index == _touchedIndex;
      
      final radius = (isTouched ? 65.0 : 55.0) * _chartAnimation.value;
      final color = _getElementColor(element);
      
      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: count > 0 ? '${percentage.round()}%' : '',
        radius: radius,
        titleStyle: TossTheme.caption.copyWith(
          color: TossDesignSystem.white,
          fontWeight: FontWeight.bold,
          fontSize: isTouched ? 14 : 12,
        ),
        titlePositionPercentageOffset: 0.6,
        badgeWidget: isTouched ? _buildBadge(element, count) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(String element, int count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getElementColor(element),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getElementColor(element).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$element: $count',
        style: TossTheme.caption.copyWith(
          color: TossDesignSystem.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return FadeTransition(
      opacity: _chartAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.elementBalance.entries.map((entry) {
          final element = entry.key;
          final count = entry.value as int;
          final color = _getElementColor(element);
          final strength = _getElementStrength(count);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: TossTheme.spacingS),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: TossTheme.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            element,
                            style: TossTheme.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$count',
                            style: TossTheme.body2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        strength,
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.textGray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildElementInterpretation() {
    final dominantElement = _getDominantElement();
    final lackingElement = _getLackingElement();
    
    return FadeTransition(
      opacity: _chartAnimation,
      child: Container(
        padding: const EdgeInsets.all(TossTheme.spacingM),
        decoration: BoxDecoration(
          color: TossTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(TossTheme.radiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: TossTheme.brandBlue,
                  size: 20,
                ),
                const SizedBox(width: TossTheme.spacingS),
                Text(
                  '오행 분석',
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: TossTheme.spacingM),
            
            // 강한 오행
            _buildAnalysisItem(
              '강한 오행',
              dominantElement['element'] ?? '',
              dominantElement['interpretation'] ?? '',
              _getElementColor(dominantElement['element'] ?? ''),
              Icons.trending_up,
            ),
            
            const SizedBox(height: TossTheme.spacingS),
            
            // 부족한 오행
            _buildAnalysisItem(
              '부족한 오행',
              lackingElement['element'] ?? '',
              lackingElement['interpretation'] ?? '',
              _getElementColor(lackingElement['element'] ?? ''),
              Icons.trending_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String element, String interpretation, Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: TossTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TossTheme.caption.copyWith(
                      color: TossTheme.textGray600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: TossTheme.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      element,
                      style: TossTheme.caption.copyWith(
                        color: TossDesignSystem.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                interpretation,
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _getDominantElement() {
    String maxElement = '목';
    int maxCount = 0;
    
    widget.elementBalance.forEach((element, count) {
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
    int minCount = 999;
    
    widget.elementBalance.forEach((element, count) {
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

  String _getElementStrength(int count) {
    if (count >= 3) return '강함';
    if (count >= 2) return '보통';
    if (count >= 1) return '약함';
    return '없음';
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return TossTheme.success;
      case '화':
        return TossTheme.error;
      case '토':
        return TossTheme.warning;
      case '금':
        return TossTheme.textGray600;
      case '수':
        return TossTheme.brandBlue;
      default:
        return TossTheme.textGray500;
    }
  }
}