import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class DreamTimelineWidget extends StatefulWidget {
  final List<double> emotionalFlow;
  final List<String> scenes;
  final bool showAnimation;

  const DreamTimelineWidget({
    Key? key,
    required this.emotionalFlow,
    required this.scenes,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<DreamTimelineWidget> createState() => _DreamTimelineWidgetState();
}

class _DreamTimelineWidgetState extends State<DreamTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildTimelineChart(),
        const SizedBox(height: 20),
        _buildScenesList(),
        const SizedBox(height: 16),
        _buildEmotionalSummary(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.timeline,
          color: Colors.teal,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '꿈의 감정 흐름',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassContainer(
          height: 250,
          padding: const EdgeInsets.all(20),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.2,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.scenes.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '장면 ${index + 1}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.2,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      String emotionText;
                      if (value >= 0.8) {
                        emotionText = '매우\n긍정';
                      } else if (value >= 0.6) {
                        emotionText = '긍정';
                      } else if (value >= 0.4) {
                        emotionText = '중립';
                      } else if (value >= 0.2) {
                        emotionText = '부정';
                      } else {
                        emotionText = '매우\n부정';
                      }
                      return Text(
                        emotionText,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: widget.emotionalFlow.length.toDouble() - 1,
              minY: 0,
              maxY: 1,
              lineBarsData: [
                LineChartBarData(
                  spots: _getChartSpots(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.withValues(alpha: 0.8),
                      Colors.blue.withValues(alpha: 0.8),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final isSelected = _selectedPoint == index;
                      return FlDotCirclePainter(
                        radius: isSelected ? 8 : 5,
                        color: _getEmotionColor(spot.y),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.withValues(alpha: 0.1),
                        Colors.blue.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (touchResponse?.lineBarSpots != null) {
                    setState(() {
                      _selectedPoint = touchResponse!.lineBarSpots!.first.spotIndex;
                    });
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  showOnTopOfTheChartBoxArea: true,
                  fitInsideHorizontally: true,
                  tooltipMargin: 0,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final emotionValue = spot.y;
                      String emotionText;
                      if (emotionValue >= 0.8) {
                        emotionText = '매우 긍정적';
                      } else if (emotionValue >= 0.6) {
                        emotionText = '긍정적';
                      } else if (emotionValue >= 0.4) {
                        emotionText = '중립적';
                      } else if (emotionValue >= 0.2) {
                        emotionText = '부정적';
                      } else {
                        emotionText = '매우 부정적';
                      }
                      
                      return LineTooltipItem(
                        '장면 ${spot.x.toInt() + 1}\n$emotionText',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _getChartSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < widget.emotionalFlow.length; i++) {
      final value = widget.emotionalFlow[i] * _animation.value;
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  Color _getEmotionColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.lightGreen;
    if (value >= 0.4) return Colors.amber;
    if (value >= 0.2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildScenesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 장면',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.scenes.asMap().entries.map((entry) {
          final index = entry.key;
          final scene = entry.value;
          final emotion = index < widget.emotionalFlow.length 
              ? widget.emotionalFlow[index] 
              : 0.5;
          final isSelected = _selectedPoint == index;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPoint = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? _getEmotionColor(emotion).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? _getEmotionColor(emotion).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getEmotionColor(emotion).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: _getEmotionColor(emotion),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getEmotionIcon(emotion),
                              size: 16,
                              color: _getEmotionColor(emotion),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getEmotionText(emotion),
                              style: TextStyle(
                                color: _getEmotionColor(emotion),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  IconData _getEmotionIcon(double value) {
    if (value >= 0.8) return Icons.sentiment_very_satisfied;
    if (value >= 0.6) return Icons.sentiment_satisfied;
    if (value >= 0.4) return Icons.sentiment_neutral;
    if (value >= 0.2) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  String _getEmotionText(double value) {
    if (value >= 0.8) return '매우 긍정적';
    if (value >= 0.6) return '긍정적';
    if (value >= 0.4) return '중립적';
    if (value >= 0.2) return '부정적';
    return '매우 부정적';
  }

  Widget _buildEmotionalSummary() {
    final avgEmotion = widget.emotionalFlow.reduce((a, b) => a + b) / widget.emotionalFlow.length;
    final maxEmotion = widget.emotionalFlow.reduce((a, b) => a > b ? a : b);
    final minEmotion = widget.emotionalFlow.reduce((a, b) => a < b ? a : b);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '감정 분석 요약',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '평균',
                avgEmotion,
                Icons.analytics,
              ),
              _buildSummaryItem(
                '최고',
                maxEmotion,
                Icons.arrow_upward,
              ),
              _buildSummaryItem(
                '최저',
                minEmotion,
                Icons.arrow_downward,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInterpretation(avgEmotion, maxEmotion, minEmotion),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: _getEmotionColor(value),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: _getEmotionColor(value),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInterpretation(double avg, double max, double min) {
    String interpretation;
    
    if (avg >= 0.7) {
      interpretation = '전반적으로 매우 긍정적인 꿈입니다. 좋은 일이 예상됩니다.';
    } else if (avg >= 0.5) {
      interpretation = '균형잡힌 꿈으로, 안정적인 심리 상태를 반영합니다.';
    } else if (avg >= 0.3) {
      interpretation = '약간의 불안이나 우려가 반영된 꿈입니다. 스트레스 관리가 필요합니다.';
    } else {
      interpretation = '부정적 감정이 강한 꿈입니다. 내면의 갈등 해결이 필요합니다.';
    }
    
    if (max - min > 0.6) {
      interpretation += ' 감정의 변화가 큰 꿈으로, 내적 갈등이나 변화의 시기를 암시합니다.';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        interpretation,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}