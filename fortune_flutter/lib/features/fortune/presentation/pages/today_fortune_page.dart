import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class TodayFortunePage extends BaseFortunePage {
  const TodayFortunePage({Key? key})
      : super(
          key: key,
          title: '오늘의 운세',
          description: '오늘 하루의 시간대별 상세 운세를 확인해보세요',
          fortuneType: 'today',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<TodayFortunePage> createState() => _TodayFortunePageState();
}

class _TodayFortunePageState extends BaseFortunePageState<TodayFortunePage> {
  final DateTime _today = DateTime.now();
  int _selectedHour = DateTime.now().hour;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // TODO: Replace with actual API call
    // final fortune = await ref.read(fortuneServiceProvider).generateTodayFortune(
    //   userId: user.id,
    //   selectedHour: _selectedHour,
    // );

    // Mock data for now
    final description = '''오늘은 전반적으로 안정적이고 긍정적인 에너지가 흐르는 날입니다. 
      
특히 오전 시간대에는 집중력이 높아져 중요한 업무나 결정을 내리기에 좋습니다. 점심 이후부터는 대인관계에서 좋은 기회가 찾아올 수 있으니 적극적으로 소통하세요.

저녁 시간대에는 가족이나 가까운 사람들과 함께 시간을 보내면 마음의 안정을 찾을 수 있습니다. 오늘은 작은 행운들이 여러 번 찾아오는 날이니 긍정적인 마음가짐을 유지하세요.''';
    
    return Fortune(
      id: 'today_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'today',
      overallScore: 78,
      scoreBreakdown: {
        '전체운': 78,
        '애정운': 85,
        '재물운': 70,
        '건강운': 75,
        '대인운': 80,
      },
      description: description,
      luckyItems: {
        '행운의 색': '하늘색',
        '행운의 숫자': '7',
        '행운의 방향': '동쪽',
        '행운의 시간': '오후 3시',
      },
      recommendations: [
        '오전에 중요한 일정을 잡으세요',
        '점심 식사는 평소와 다른 메뉴를 선택해보세요',
        '오후 3시경 좋은 소식이 있을 수 있습니다',
        '저녁에는 충분한 휴식을 취하세요',
      ],
      metadata: {
        'hourlyData': _generateHourlyData(),
      },
    );
  }

  Map<String, dynamic> _generateHourlyData() {
    final hourlyScores = <String, dynamic>{};
    for (int i = 0; i < 24; i++) {
      hourlyScores['$i'] = {
        'score': 60 + (i * 2.5).toInt() % 30,
        'event': _getHourlyEvent(i),
        'tip': _getHourlyTip(i),
      };
    }
    return hourlyScores;
  }

  String _getHourlyEvent(int hour) {
    final events = {
      6: '상쾌한 아침으로 시작',
      9: '업무 집중력 최고조',
      12: '좋은 인연을 만날 기회',
      15: '행운의 시간대',
      18: '휴식이 필요한 시간',
      21: '가족과의 화목한 시간',
    };
    return events[hour] ?? '평온한 시간';
  }

  String _getHourlyTip(int hour) {
    final tips = {
      6: '가벼운 운동으로 하루를 시작하세요',
      9: '중요한 결정을 내리기 좋은 시간입니다',
      12: '동료들과 점심을 함께 하세요',
      15: '잠시 휴식을 취하며 차를 마셔보세요',
      18: '퇴근 후 여유로운 시간을 가지세요',
      21: '일찍 잠자리에 들어 충분한 휴식을 취하세요',
    };
    return tips[hour] ?? '긍정적인 마음가짐을 유지하세요';
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildHourlyChart(),
        _buildHourlyDetail(),
        _buildCurrentTimeHighlight(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHourlyChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final hourlyData = fortune.metadata?['hourlyData'] as Map<String, dynamic>?;
    if (hourlyData == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '시간대별 운세',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 3,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
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
                        interval: 3,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 3 == 0) {
                            return Text(
                              '${value.toInt()}시',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: 23,
                  minY: 40,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(24, (index) {
                        final data = hourlyData['$index'] as Map<String, dynamic>;
                        return FlSpot(index.toDouble(), (data['score'] as int).toDouble());
                      }),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (index == _selectedHour) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          }
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            Theme.of(context).colorScheme.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (touchResponse != null && 
                          touchResponse.lineBarSpots != null &&
                          touchResponse.lineBarSpots!.isNotEmpty) {
                        final spot = touchResponse.lineBarSpots!.first;
                        setState(() {
                          _selectedHour = spot.x.toInt();
                        });
                      }
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipColor: (LineBarSpot spot) => Theme.of(context).colorScheme.primary,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '${barSpot.x.toInt()}시: ${barSpot.y.toInt()}점',
                            const TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyDetail() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final hourlyData = fortune.metadata?['hourlyData'] as Map<String, dynamic>?;
    if (hourlyData == null) return const SizedBox.shrink();

    final selectedData = hourlyData['$_selectedHour'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_selectedHour:00',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedData['event'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '운세 점수: ${selectedData['score']}점',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getScoreColor(selectedData['score'] as int),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedData['tip'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeHighlight() {
    final currentHour = DateTime.now().hour;
    final nextHour = (currentHour + 1) % 24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '현재 시간 운세',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard(
                    '지금',
                    '$currentHour:00 - $nextHour:00',
                    Icons.access_time_filled,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                    '다음 시간',
                    '$nextHour:00 - ${(nextHour + 1) % 24}:00',
                    Icons.update_rounded,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}