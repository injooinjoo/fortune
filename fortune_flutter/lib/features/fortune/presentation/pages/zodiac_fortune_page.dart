import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ZodiacFortunePage extends BaseFortunePage {
  const ZodiacFortunePage({Key? key})
      : super(
          key: key,
          title: '별자리 운세',
          description: '당신의 별자리로 알아보는 오늘의 운세',
          fortuneType: 'zodiac',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<ZodiacFortunePage> createState() => _ZodiacFortunePageState();
}

class _ZodiacFortunePageState extends BaseFortunePageState<ZodiacFortunePage> {
  String? _selectedZodiac;
  DateTime? _birthDate;
  String _selectedPeriod = 'today';

  final List<Map<String, dynamic>> _zodiacSigns = [
    {'name': '양자리', 'period': '3.21 - 4.19', 'symbol': '♈', 'element': '불', 'color': Colors.red},
    {'name': '황소자리', 'period': '4.20 - 5.20', 'symbol': '♉', 'element': '땅', 'color': Colors.green},
    {'name': '쌍둥이자리', 'period': '5.21 - 6.21', 'symbol': '♊', 'element': '공기', 'color': Colors.yellow},
    {'name': '게자리', 'period': '6.22 - 7.22', 'symbol': '♋', 'element': '물', 'color': Colors.blue},
    {'name': '사자자리', 'period': '7.23 - 8.22', 'symbol': '♌', 'element': '불', 'color': Colors.orange},
    {'name': '처녀자리', 'period': '8.23 - 9.22', 'symbol': '♍', 'element': '땅', 'color': Colors.brown},
    {'name': '천칭자리', 'period': '9.23 - 10.23', 'symbol': '♎', 'element': '공기', 'color': Colors.pink},
    {'name': '전갈자리', 'period': '10.24 - 11.21', 'symbol': '♏', 'element': '물', 'color': Colors.deepPurple},
    {'name': '사수자리', 'period': '11.22 - 12.21', 'symbol': '♐', 'element': '불', 'color': Colors.purple},
    {'name': '염소자리', 'period': '12.22 - 1.19', 'symbol': '♑', 'element': '땅', 'color': Colors.grey},
    {'name': '물병자리', 'period': '1.20 - 2.18', 'symbol': '♒', 'element': '공기', 'color': Colors.cyan},
    {'name': '물고기자리', 'period': '2.19 - 3.20', 'symbol': '♓', 'element': '물', 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _detectZodiacFromBirthDate();
  }

  void _detectZodiacFromBirthDate() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null && userProfile.birthDate != null) {
      setState(() {
        _birthDate = userProfile.birthDate;
        _selectedZodiac = _getZodiacFromDate(userProfile.birthDate!);
      });
    }
  }

  String _getZodiacFromDate(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return '쌍둥이자리';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return '게자리';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return '천칭자리';
    if ((month == 10 && day >= 24) || (month == 11 && day <= 21)) return '전갈자리';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '사수자리';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
    return '물고기자리';
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    if (_selectedZodiac == null) {
      throw Exception('별자리를 선택해주세요');
    }

    // TODO: Replace with actual API call
    // final fortune = await ref.read(fortuneServiceProvider).generateZodiacFortune(
    //   userId: user.id,
    //   zodiac: _selectedZodiac!,
    //   period: _selectedPeriod,
    // );

    // Mock data for now
    final zodiacInfo = _zodiacSigns.firstWhere((z) => z['name'] == _selectedZodiac);
    final description = '''${zodiacInfo['name']}의 오늘 운세입니다.

${zodiacInfo['element']}의 기운이 강하게 작용하는 날입니다. 특히 오전 시간대에는 창의적인 에너지가 충만하여 새로운 아이디어나 영감을 얻기 좋습니다.

대인관계에서는 평소보다 더 적극적인 태도를 보이는 것이 좋겠습니다. 당신의 매력이 빛을 발하는 시기이므로 자신감을 가지고 행동하세요.

재물운은 안정적이며, 건강운은 약간의 주의가 필요합니다. 충분한 휴식과 규칙적인 운동을 병행하면 좋은 컨디션을 유지할 수 있을 것입니다.''';

    return Fortune(
      id: 'zodiac_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'zodiac',
      overallScore: 76,
      scoreBreakdown: {
        '전체운': 76,
        '애정운': 83,
        '재물운': 72,
        '건강운': 68,
        '대인운': 79,
      },
      description: description,
      luckyItems: {
        '행운의 색': zodiacInfo['color'].toString().split('(0x')[1].split(')')[0],
        '행운의 숫자': '${DateTime.now().day % 9 + 1}',
        '행운의 방향': _getLuckyDirection(zodiacInfo['element']),
        '행운의 시간': '${(DateTime.now().day % 12) + 10}시',
      },
      recommendations: [
        '오늘은 ${zodiacInfo['element']}의 기운을 활용하세요',
        '${zodiacInfo['color'] == Colors.red ? '열정적으로' : '차분하게'} 하루를 시작하세요',
        '대인관계에서 좋은 기회가 있을 수 있습니다',
        '건강 관리에 신경 쓰는 것이 좋겠습니다',
      ],
      metadata: {
        'zodiacInfo': zodiacInfo,
        'compatibility': _getCompatibility(_selectedZodiac!),
        'monthlyTrend': _getMonthlyTrend(),
        'elementalBalance': _getElementalBalance(zodiacInfo['element']),
      },
    );
  }

  String _getLuckyDirection(String element) {
    switch (element) {
      case '불':
        return '남쪽';
      case '물':
        return '북쪽';
      case '땅':
        return '중앙';
      case '공기':
        return '동쪽';
      default:
        return '서쪽';
    }
  }

  Map<String, dynamic> _getCompatibility(String zodiac) {
    // Simplified compatibility logic
    final compatibleSigns = {
      '양자리': ['사자자리', '사수자리', '쌍둥이자리'],
      '황소자리': ['처녀자리', '염소자리', '게자리'],
      '쌍둥이자리': ['천칭자리', '물병자리', '양자리'],
      '게자리': ['전갈자리', '물고기자리', '황소자리'],
      '사자자리': ['양자리', '사수자리', '쌍둥이자리'],
      '처녀자리': ['황소자리', '염소자리', '전갈자리'],
      '천칭자리': ['쌍둥이자리', '물병자리', '사자자리'],
      '전갈자리': ['게자리', '물고기자리', '처녀자리'],
      '사수자리': ['양자리', '사자자리', '천칭자리'],
      '염소자리': ['황소자리', '처녀자리', '전갈자리'],
      '물병자리': ['쌍둥이자리', '천칭자리', '사수자리'],
      '물고기자리': ['게자리', '전갈자리', '염소자리'],
    };

    return {
      'best': compatibleSigns[zodiac]![0],
      'good': compatibleSigns[zodiac]!.sublist(1),
      'challenging': _zodiacSigns
          .where((z) => !compatibleSigns[zodiac]!.contains(z['name']) && z['name'] != zodiac)
          .take(2)
          .map((z) => z['name'])
          .toList(),
    };
  }

  List<double> _getMonthlyTrend() {
    // Generate a trend for the current month
    return List.generate(30, (index) => 60 + (index * 2.5 % 30));
  }

  Map<String, double> _getElementalBalance(String primaryElement) {
    final balance = {
      '불': 0.0,
      '물': 0.0,
      '땅': 0.0,
      '공기': 0.0,
    };

    // Set primary element strength
    balance[primaryElement] = 0.8;

    // Set other elements
    balance.forEach((key, value) {
      if (key != primaryElement) {
        balance[key] = 0.2 + (DateTime.now().day % 3) * 0.1;
      }
    });

    return balance;
  }

  @override
  Widget buildInputForm() {
    return Column(
      children: [
        _buildZodiacSelector(),
        const SizedBox(height: 16),
        _buildPeriodSelector(),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildZodiacProfile(),
        _buildCompatibilitySection(),
        _buildMonthlyTrendChart(),
        _buildElementalBalance(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildZodiacSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '별자리 선택',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_birthDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '생년월일: ${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _zodiacSigns.length,
            itemBuilder: (context, index) {
              final zodiac = _zodiacSigns[index];
              final isSelected = _selectedZodiac == zodiac['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedZodiac = zodiac['name'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              zodiac['color'] as Color,
                              (zodiac['color'] as Color).withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: !isSelected
                        ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (zodiac['color'] as Color)
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        zodiac['symbol'],
                        style: TextStyle(
                          fontSize: 32,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        zodiac['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      Text(
                        zodiac['period'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected 
                              ? Colors.white.withOpacity(0.8)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      {'value': 'today', 'label': '오늘'},
      {'value': 'week', 'label': '이번 주'},
      {'value': 'month', 'label': '이번 달'},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기간 선택',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: periods.map((period) {
              final isSelected = _selectedPeriod == period['value'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriod = period['value']!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                ],
                              )
                            : null,
                        color: !isSelected
                            ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          period['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacProfile() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final zodiacInfo = fortune.metadata?['zodiacInfo'] as Map<String, dynamic>?;
    if (zodiacInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            (zodiacInfo['color'] as Color).withOpacity(0.1),
            (zodiacInfo['color'] as Color).withOpacity(0.05),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  zodiacInfo['symbol'],
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zodiacInfo['name'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      zodiacInfo['period'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip('원소', zodiacInfo['element'], zodiacInfo['color'] as Color),
                _buildInfoChip('지배성', _getRulingPlanet(zodiacInfo['name']), zodiacInfo['color'] as Color),
                _buildInfoChip('특성', _getCharacteristic(zodiacInfo['name']), zodiacInfo['color'] as Color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getRulingPlanet(String zodiac) {
    final planets = {
      '양자리': '화성',
      '황소자리': '금성',
      '쌍둥이자리': '수성',
      '게자리': '달',
      '사자자리': '태양',
      '처녀자리': '수성',
      '천칭자리': '금성',
      '전갈자리': '명왕성',
      '사수자리': '목성',
      '염소자리': '토성',
      '물병자리': '천왕성',
      '물고기자리': '해왕성',
    };
    return planets[zodiac] ?? '알 수 없음';
  }

  String _getCharacteristic(String zodiac) {
    final characteristics = {
      '양자리': '열정적',
      '황소자리': '실용적',
      '쌍둥이자리': '호기심',
      '게자리': '감성적',
      '사자자리': '리더십',
      '처녀자리': '완벽주의',
      '천칭자리': '조화',
      '전갈자리': '신비',
      '사수자리': '자유',
      '염소자리': '야망',
      '물병자리': '혁신',
      '물고기자리': '상상력',
    };
    return characteristics[zodiac] ?? '특별함';
  }

  Widget _buildCompatibilitySection() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final compatibility = fortune.metadata?['compatibility'] as Map<String, dynamic>?;
    if (compatibility == null) return const SizedBox.shrink();

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
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '별자리 궁합',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCompatibilityRow(
              '최고의 궁합',
              compatibility['best'] as String,
              Colors.pink,
              Icons.favorite,
            ),
            const SizedBox(height: 12),
            _buildCompatibilityRow(
              '좋은 궁합',
              (compatibility['good'] as List).join(', '),
              Colors.green,
              Icons.thumb_up,
            ),
            const SizedBox(height: 12),
            _buildCompatibilityRow(
              '도전적인 궁합',
              (compatibility['challenging'] as List).join(', '),
              Colors.orange,
              Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityRow(String label, String value, Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final monthlyTrend = fortune.metadata?['monthlyTrend'] as List<double>?;
    if (monthlyTrend == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 운세 흐름',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 5,
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
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 == 0) {
                            return Text(
                              '${value.toInt() + 1}일',
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
                  maxX: monthlyTrend.length - 1,
                  minY: 40,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyTrend.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
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
                        show: false,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementalBalance() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final balance = fortune.metadata?['elementalBalance'] as Map<String, double>?;
    if (balance == null) return const SizedBox.shrink();

    final elementColors = {
      '불': Colors.red,
      '물': Colors.blue,
      '땅': Colors.brown,
      '공기': Colors.cyan,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '원소 밸런스',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ...balance.entries.map((entry) {
              final color = elementColors[entry.key]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${(entry.value * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
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
}