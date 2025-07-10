import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyFortunePage extends BaseFortunePage {
  const MonthlyFortunePage({Key? key})
      : super(
          key: key,
          title: '월간 운세',
          description: '이번 달의 전체적인 운세 흐름을 확인해보세요',
          fortuneType: 'monthly',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<MonthlyFortunePage> createState() => _MonthlyFortunePageState();
}

class _MonthlyFortunePageState extends BaseFortunePageState<MonthlyFortunePage> {
  DateTime _selectedMonth = DateTime.now();
  int? _selectedDay;
  
  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // TODO: Replace with actual API call
    // final fortune = await ref.read(fortuneServiceProvider).generateMonthlyFortune(
    //   userId: user.id,
    //   month: _selectedMonth,
    // );

    // Mock data for now
    final description = '''${_selectedMonth.month}월은 전반적으로 상승세를 보이는 한 달이 될 것입니다.
      
월초에는 새로운 기회가 찾아오며, 중순에는 안정적인 흐름을 유지할 것으로 보입니다. 월말에는 그동안의 노력이 결실을 맺는 시기가 될 것입니다.

특히 15일을 전후로 중요한 전환점이 있을 예정이니, 이 시기에는 더욱 신중하게 행동하세요. 전체적으로 긍정적인 에너지가 흐르는 달이지만, 건강 관리에는 주의가 필요합니다.

재물운은 중순 이후 상승하며, 대인관계에서는 새로운 인연을 만날 가능성이 높습니다.''';
    
    return Fortune(
      id: 'monthly_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'monthly',
      overallScore: 77,
      scoreBreakdown: {
        '전체운': 77,
        '애정운': 82,
        '재물운': 74,
        '건강운': 72,
        '대인운': 80,
      },
      description: description,
      luckyItems: {
        '이번 달 행운의 날': '15일',
        '행운의 색': '초록색',
        '행운의 숫자': '8',
        '행운의 방향': '북동쪽',
      },
      recommendations: [
        '월초: 새로운 프로젝트나 계획을 시작하기 좋은 시기',
        '중순: 인간관계 확장과 네트워킹에 집중',
        '월말: 재정 정리와 다음 달 계획 수립',
        '건강: 규칙적인 운동과 충분한 수면 필요',
      ],
      metadata: {
        'dailyScores': _generateDailyScores(),
        'monthlyHighlights': _getMonthlyHighlights(),
        'luckyDays': _getLuckyDays(),
        'categoryDistribution': _getCategoryDistribution(),
      },
    );
  }

  Map<int, int> _generateDailyScores() {
    final scores = <int, int>{};
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    
    for (int i = 1; i <= daysInMonth; i++) {
      // Generate score based on some pattern
      scores[i] = 60 + ((i * 7 + i * i) % 30);
    }
    return scores;
  }

  List<Map<String, dynamic>> _getMonthlyHighlights() {
    return [
      {
        'date': 5,
        'type': '기회',
        'description': '새로운 비즈니스 기회가 찾아올 수 있습니다',
        'icon': Icons.business_center,
        'color': Colors.blue,
      },
      {
        'date': 15,
        'type': '전환점',
        'description': '이번 달의 가장 중요한 날, 신중한 결정이 필요합니다',
        'icon': Icons.change_circle,
        'color': Colors.amber,
      },
      {
        'date': 23,
        'type': '행운',
        'description': '예상치 못한 좋은 소식이 있을 예정입니다',
        'icon': Icons.star,
        'color': Colors.green,
      },
    ];
  }

  List<int> _getLuckyDays() {
    return [5, 8, 15, 23, 28];
  }

  Map<String, double> _getCategoryDistribution() {
    return {
      '애정운': 0.25,
      '재물운': 0.20,
      '건강운': 0.15,
      '대인운': 0.22,
      '학업/업무운': 0.18,
    };
  }

  @override
  Widget buildInputForm() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월 선택',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('yyyy년 M월').format(_selectedMonth),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildCalendarHeatmap(),
        _buildSelectedDayDetail(),
        _buildMonthlyHighlights(),
        _buildCategoryPieChart(),
        _buildMonthlyTips(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCalendarHeatmap() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final dailyScores = fortune.metadata?['dailyScores'] as Map<int, int>?;
    if (dailyScores == null) return const SizedBox.shrink();

    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
    final luckyDays = fortune.metadata?['luckyDays'] as List<int>? ?? [];

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
                  Icons.calendar_month,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedMonth.month}월 운세 캘린더',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['월', '화', '수', '목', '금', '토', '일']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final dayOffset = index - firstWeekday + 2;
                if (dayOffset < 1 || dayOffset > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final score = dailyScores[dayOffset] ?? 50;
                final isLucky = luckyDays.contains(dayOffset);
                final isSelected = _selectedDay == dayOffset;
                final isToday = DateTime.now().day == dayOffset &&
                    DateTime.now().month == _selectedMonth.month &&
                    DateTime.now().year == _selectedMonth.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = dayOffset;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(score).withOpacity(isSelected ? 0.8 : 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                        width: isSelected || isToday ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$dayOffset',
                            style: TextStyle(
                              color: score > 70 ? Colors.white : Colors.black87,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isLucky)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('나쁨', _getHeatmapColor(40)),
                const SizedBox(width: 16),
                _buildLegendItem('보통', _getHeatmapColor(60)),
                const SizedBox(width: 16),
                _buildLegendItem('좋음', _getHeatmapColor(80)),
                const SizedBox(width: 16),
                _buildLegendItem('최고', _getHeatmapColor(95)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetail() {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final dailyScores = fortune.metadata?['dailyScores'] as Map<int, int>?;
    if (dailyScores == null) return const SizedBox.shrink();

    final score = dailyScores[_selectedDay] ?? 50;
    final highlights = fortune.metadata?['monthlyHighlights'] as List<Map<String, dynamic>>?;
    final dayHighlight = highlights?.firstWhere(
      (h) => h['date'] == _selectedDay,
      orElse: () => {},
    );

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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedMonth.month}월 $_selectedDay일',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$score점',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (dayHighlight != null && dayHighlight.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (dayHighlight['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (dayHighlight['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      dayHighlight['icon'] as IconData,
                      color: dayHighlight['color'] as Color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayHighlight['type'] as String,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: dayHighlight['color'] as Color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayHighlight['description'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _getDayAdvice(score),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHighlights() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final highlights = fortune.metadata?['monthlyHighlights'] as List<Map<String, dynamic>>?;
    if (highlights == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 주요 날짜',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
                      child: Center(
                        child: Text(
                          '${highlight['date']}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                highlight['icon'] as IconData,
                                size: 20,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  highlight['type'] as String,
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
                            highlight['description'] as String,
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

  Widget _buildCategoryPieChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final distribution = fortune.metadata?['categoryDistribution'] as Map<String, double>?;
    if (distribution == null) return const SizedBox.shrink();

    final colors = [
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운세 카테고리별 분포',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: distribution.entries.toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value.key;
                          final percentage = entry.value.value;
                          
                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: percentage,
                            title: '${(percentage * 100).toInt()}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: distribution.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value.key;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTips() {
    final tips = [
      '월초에는 새로운 시작을 위한 계획을 세우세요',
      '중순에는 인간관계에 집중하는 것이 좋습니다',
      '월말에는 한 달을 정리하고 다음 달을 준비하세요',
      '건강 관리는 꾸준히 해야 합니다',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '월간 행운 팁',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getHeatmapColor(int score) {
    if (score >= 90) return Colors.green.shade700;
    if (score >= 80) return Colors.green.shade500;
    if (score >= 70) return Colors.green.shade300;
    if (score >= 60) return Colors.yellow.shade600;
    if (score >= 50) return Colors.orange.shade400;
    if (score >= 40) return Colors.orange.shade600;
    return Colors.red.shade500;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getDayAdvice(int score) {
    if (score >= 90) return '최고의 날입니다! 중요한 일을 진행하기에 완벽한 시기입니다.';
    if (score >= 80) return '매우 좋은 날입니다. 적극적으로 활동하세요.';
    if (score >= 70) return '좋은 날입니다. 계획했던 일들을 진행하기 좋습니다.';
    if (score >= 60) return '평균적인 날입니다. 일상적인 업무에 집중하세요.';
    if (score >= 50) return '조심스러운 날입니다. 중요한 결정은 미루는 것이 좋습니다.';
    if (score >= 40) return '어려운 날이 될 수 있습니다. 신중하게 행동하세요.';
    return '힘든 날이지만 이 또한 지나갈 것입니다. 긍정적인 마음을 유지하세요.';
  }
}