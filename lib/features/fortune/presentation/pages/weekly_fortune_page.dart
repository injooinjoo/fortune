import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyFortunePage extends BaseFortunePage {
  const WeeklyFortunePage({Key? key})
      : super(
          key: key,
          title: '주간 운세',
          description: '이번 주 7일간의 운세 흐름을 확인해보세요',
          fortuneType: 'weekly',
          requiresUserInfo: false);

  @override
  ConsumerState<WeeklyFortunePage> createState() => _WeeklyFortunePageState();
}

class _WeeklyFortunePageState extends BaseFortunePageState<WeeklyFortunePage> {
  final DateTime _startOfWeek = _getStartOfWeek();
  int _selectedDayIndex = DateTime.now().weekday - 1;
  
  static DateTime _getStartOfWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return now.subtract(Duration(days: weekday - 1));
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Use the fortune service to generate weekly fortune
    final fortune = await ref.read(fortuneServiceProvider).getWeeklyFortune(
      userId: user.id
    );

    return fortune;
  }

  Map<String, dynamic> _generateDailyScores() {
    final scores = <String, dynamic>{};
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    
    for (int i = 0; i < 7; i++) {
      scores[days[i]] = {
        'score': 65 + (i * 5) % 20,
        'highlight': _getDayHighlight(i),
        'warning': null
      };
    }
    return scores;
  }

  String _getDayHighlight(int dayIndex) {
    final highlights = [
      '새로운 시작의 기회', '협력과 소통의 날',
      '성찰과 휴식의 시간', '도전과 성장의 기회',
      '행운이 가듍한 날', '인연과 만남의 시간',
      '가족과 함께하는 날',
    ];
    return highlights[dayIndex];
  }

  String _getDayWarning(int dayIndex) {
    final warnings = [
      '서두르지 말고 신중하게', '오해가 생기지 않도록 주의',
      '건강 관리에 신경쓰세요', '충동적인 결정은 피하세요',
      '과도한 지출을 조심하세요', '늦은 귀가는 삼가세요',
      '충분한 휴식을 취하세요',
    ];
    return warnings[dayIndex];
  }

  List<Map<String, dynamic>> _getWeekHighlights() {
    return [
      {
        'day': '월요일', 'type': '시작', 'description': '새로운 프로젝트나 계획을 시작하기 좋은 날', 'icon': Icons.rocket_launch,
        'color': Colors.orange,
      },
      {
        'day': '수요일', 'type': '전환점', 'description': '주간 목표를 재점검하고 방향을 조정하는 시기', 'icon': Icons.change_circle,
        'color': Colors.blue,
      },
      {
        'day': '금요일', 'type': '최고조', 'description': '이번 주 가장 운이 좋은 날, 중요한 일을 처리하세요', 'icon': Icons.star,
        'color': Colors.amber,
      },
    ];
  }

  Map<String, List<double>> _getCategoryTrends() {
    return {
      '애정운': [70, 72, 75, 78, 85, 88, 82],
      '재물운': [65, 68, 70, 72, 75, 73, 70],
      '건강운': [75, 70, 68, 65, 70, 75, 72],
      '대인운': [72, 75, 78, 80, 82, 85, 80]
    };
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildWeeklyChart(),
        _buildDaySelector(),
        _buildSelectedDayDetail(),
        _buildWeekHighlights(),
        _buildCategoryTrendsChart(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final dailyScores = fortune.metadata?['dailyScores'] as Map<String, dynamic>?;
    if (dailyScores == null) return const SizedBox.shrink();

    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final scores = days.map((day) {
      final dayData = dailyScores[day] as Map<String, dynamic>;
      return (dayData['score'] as int).toDouble();
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주간 운세 트렌드',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                      if (response != null && 
                          response.spot != null &&
                          event is FlTapUpEvent) {
                        setState(() {
                          _selectedDayIndex = response.spot!.touchedBarGroupIndex;
                        });
                      }
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipColor: (BarChartGroupData group) => Theme.of(context).colorScheme.primary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${days[group.x.toInt()]}: ${rod.toY.toInt()}점',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)
                        );
                      })),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final isSelected = value.toInt() == _selectedDayIndex;
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          );
                        })),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10)),
                        }),
                      ),
                    ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  ),
                  barGroups: List.generate(7, (index) {
                    final isSelected = index == _selectedDayIndex;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: scores[index],
                          gradient: LinearGradient(
                            colors: isSelected
                              ? [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7)]
                              : [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                  Theme.of(context).colorScheme.primary.withOpacity(0.4)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          itemBuilder: (context, index) {
            final isSelected = index == _selectedDayIndex;
            final date = _startOfWeek.add(Duration(days: index));
            final isToday = date.day == DateTime.now().day;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.8)])
                      : null,
                    color: !isSelected 
                      ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                      : null,
                    borderRadius: BorderRadius.circular(16),
                    border: isToday && !isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2)
                      : null),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      );
  }
  }

  Widget _buildSelectedDayDetail() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final dailyScores = fortune.metadata?['dailyScores'] as Map<String, dynamic>?;
    if (dailyScores == null) return const SizedBox.shrink();

    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final selectedDay = days[_selectedDayIndex];
    final dayData = dailyScores[selectedDay] as Map<String, dynamic>;
    final selectedDate = _startOfWeek.add(Duration(days: _selectedDayIndex));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedDate.month}월 ${selectedDate.day}일 ${selectedDay}요일',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  ),
                const Spacer(),
                Text(
                  '${dayData['score']}점',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _getScoreColor(dayData['score']),
                    fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 포인트',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayData['highlight'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주의사항',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.error),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayData['warning'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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

  Widget _buildWeekHighlights() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final highlights = fortune.metadata?['weekHighlights'] as List<Map<String, dynamic>>?;
    if (highlights == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 주 하이라이트',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...highlights.map((highlight) {
              final color = highlight['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        highlight['icon'],
                        color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                highlight['day'],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  highlight['type'],
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            highlight['description'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTrendsChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final categoryTrends = fortune.metadata?['categoryTrends'] as Map<String, List<double>>?;
    if (categoryTrends == null) return const SizedBox.shrink();

    final colors = {
      '애정운': Colors.pink,
      '재물운': Colors.green,
      '건강운': Colors.orange,
      '대인운': Colors.blue
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리별 주간 트렌드',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: colors.entries.map((entry) {
                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
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
                    }),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['월', '화', '수', '목', '금', '토', '일'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        })),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10)),
                        }),
                      ),
                    ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 50,
                  maxY: 100,
                  lineBarsData: categoryTrends.entries.map((entry) {
                    final color = colors[entry.key]!;
                    return LineChartBarData(
                      spots: entry.value.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: color,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
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