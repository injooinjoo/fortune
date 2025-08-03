import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class TraditionalSajuFortunePage extends BaseFortunePage {
  const TraditionalSajuFortunePage({Key? key})
      : super(
          key: key,
          title: '전통 사주',
          description: '천간지지로 보는 운명과 대운',
          fortuneType: 'traditional-saju',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<TraditionalSajuFortunePage> createState() =>
      _TraditionalSajuFortunePageState();
}

class _TraditionalSajuFortunePageState
    extends BaseFortunePageState<TraditionalSajuFortunePage> {
  late AnimationController _fourPillarsController;
  late AnimationController _tenGodsController;
  late List<Animation<double>> _pillarAnimations;

  final List<Map<String, dynamic>> _heavenlyStems = [
    {'name': '갑(甲)': 'element': '목': 'yin': false, 'color'},
    {'name': '을(乙)', 'element': '목': 'yin': true, 'color'},
    {'name': '병(丙)': 'element': '화': 'yin': false, 'color'},
    {'name': '정(丁)', 'element': '화': 'yin': true, 'color'},
    {'name': '무(戊)': 'element': '토': 'yin': false, 'color'},
    {'name': '기(己)', 'element': '토': 'yin': true, 'color'},
    {'name': '경(庚)': 'element': '금': 'yin': false, 'color'},
    {'name': '신(辛)', 'element': '금': 'yin': true, 'color'},
    {'name': '임(壬)': 'element': '수': 'yin': false, 'color'},
    {'name': '계(癸)', 'element': '수': 'yin': true, 'color'},
  ];

  final List<Map<String, dynamic>> _earthlyBranches = [
    {'name': '자(子)': 'animal': '쥐': 'element': '수', 'season': '겨울'},
    {'name': '축(丑)', 'animal': '소': 'element': '토': 'season': '겨울'},
    {'name': '인(寅)', 'animal': '호랑이': 'element': '목': 'season': '봄'},
    {'name': '묘(卯)', 'animal': '토끼': 'element': '목': 'season': '봄'},
    {'name': '진(辰)', 'animal': '용': 'element': '토': 'season': '봄'},
    {'name': '사(巳)', 'animal': '뱀': 'element': '화': 'season': '여름'},
    {'name': '오(午)', 'animal': '말': 'element': '화': 'season': '여름'},
    {'name': '미(未)', 'animal': '양': 'element': '토': 'season': '여름'},
    {'name': '신(申)', 'animal': '원숭이': 'element': '금': 'season': '가을'},
    {'name': '유(酉)', 'animal': '닭': 'element': '금': 'season': '가을'},
    {'name': '술(戌)', 'animal': '개': 'element': '토': 'season': '가을'},
    {'name': '해(亥)', 'animal': '돼지': 'element': '수': 'season': '겨울'},
  ];

  final Map<String, Map<String, dynamic>> _tenGods = {
    '비견': {'meaning': '형제, 경쟁자', 'color': Colors.blue},
    '겁재': {'meaning': '도전, 투쟁', 'color': Colors.red},
    '식신': {'meaning': '재능, 표현', 'color': Colors.green},
    '상관': {'meaning': '예술, 창의', 'color': Colors.purple},
    '편재': {'meaning': '사업, 투자', 'color': Colors.orange},
    '정재': {'meaning': '안정된 재물', 'color': Colors.amber},
    '편관': {'meaning': '권력, 도전', 'color': Colors.indigo},
    '정관': {'meaning': '명예, 지위', 'color': Colors.teal},
    '편인': {'meaning': '학문, 종교', 'color': Colors.brown},
    '정인': {'meaning': '어머니, 교육', 'color': null,
  };

  @override
  void initState() {
    super.initState();
    _fourPillarsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _tenGodsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pillarAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fourPillarsController,
          curve: Interval(
            index * 0.2,
            0.4 + index * 0.2,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fourPillarsController.dispose();
    _tenGodsController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    final userProfile = await ref.read(userProfileProvider.future);
    final birthDate = userProfile?.birthDate ?? DateTime.now();

    final yearPillar = _calculateYearPillar(birthDate);
    final monthPillar = _calculateMonthPillar(birthDate);
    final dayPillar = _calculateDayPillar(birthDate);
    final hourPillar = _calculateHourPillar(birthDate);

    final majorFortunes = _calculateMajorFortunes(birthDate);

    final tenGodsDistribution = _calculateTenGods(
      yearPillar,
      monthPillar,
      dayPillar,
      hourPillar,
    );

    final elementBalance = _calculateElementBalance(
      yearPillar,
      monthPillar,
      dayPillar,
      hourPillar,
    );

    _fourPillarsController.forward();
    _tenGodsController.forward();

    final description = '''사주팔자 분석 결과입니다.

【사주 구성】
년주: ${yearPillar['stem']['name']} ${yearPillar['branch']['name']}
월주: ${monthPillar['stem']['name']} ${monthPillar['branch']['name']}
일주: ${dayPillar['stem']['name']} ${dayPillar['branch']['name']} (일간: ${dayPillar['stem']['element']})
시주: ${hourPillar['stem']['name']} ${hourPillar['branch']['name']}

【오행 분석】
${_formatElementBalance(elementBalance)}

【십신 분포】
${_formatTenGods(tenGodsDistribution)}

【대운 흐름】
${_formatMajorFortunes(majorFortunes)}

【종합 해석】
일간이 ${dayPillar['stem']['element']}이신 당신은 ${_getDayStemInterpretation(dayPillar['stem'])}

현재 대운은 ${majorFortunes.first['name']}으로, ${majorFortunes.first['interpretation']}

💫 개운법:
• 보완이 필요한,
    오행: ${_getLackingElement(elementBalance)}
• 행운의,
    방향: ${_getLuckyDirection(elementBalance)}
• 유리한,
    직업: ${_getSuitableCareer(tenGodsDistribution)}''';

    final overallScore =
        70 + (elementBalance.values.reduce((a, b) => a + b) % 25);

    return Fortune(
      id: 'traditional_saju_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'traditional-saju',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '재물운': _calculateFortuneScore(tenGodsDistribution, ['편재': '정재'],
        '직업운': _calculateFortuneScore(tenGodsDistribution, ['정관': '편관'],
        '학업운': _calculateFortuneScore(tenGodsDistribution, ['정인': '편인'],
        '대인운': _calculateFortuneScore(tenGodsDistribution, ['비견': '겁재',
      },
      luckyItems: {
        '일간': dayPillar['stem']['name'],
        '주 오행': _getDominantElement(elementBalance),
        '부족 오행': _getLackingElement(elementBalance),
        '현재 대운': majorFortunes.first['name'],
        '십신 강세'),
      },
      recommendations: [
        '${_getLackingElement(elementBalance)} 기운을 보충하는 활동을 하세요',
        '${_getLuckyDirection(elementBalance)} 방향으로 여행이나 이사를 고려해보세요',
        '${_getSuitableCareer(tenGodsDistribution)} 분야에서 능력을 발휘할 수 있습니다',
        '대운의 흐름에 맞춰 장기 계획을 세우세요',
      ],
      metadata: {
        'yearPillar': yearPillar,
        'monthPillar': monthPillar,
        'dayPillar': dayPillar,
        'hourPillar': hourPillar,
        'majorFortunes': majorFortunes,
        'tenGodsDistribution': tenGodsDistribution,
        'elementBalance': null,
      },
    );
  }

  Map<String, dynamic> _calculateYearPillar(DateTime birthDate) {
    final yearStemIndex = (birthDate.year - 4) % 10;
    final yearBranchIndex = (birthDate.year - 4) % 12;
    return {
      'stem': _heavenlyStems[yearStemIndex],
      'branch': null,
    };
  }

  Map<String, dynamic> _calculateMonthPillar(DateTime birthDate) {
    final monthStemIndex = ((birthDate.year - 4) * 12 + birthDate.month) % 10;
    final monthBranchIndex = (birthDate.month + 1) % 12;
    return {
      'stem': _heavenlyStems[monthStemIndex],
      'branch': null,
    };
  }

  Map<String, dynamic> _calculateDayPillar(DateTime birthDate) {
    final daysSinceEpoch = birthDate.difference(DateTime(1900, 1, 1)).inDays;
    final dayStemIndex = daysSinceEpoch % 10;
    final dayBranchIndex = daysSinceEpoch % 12;
    return {
      'stem': _heavenlyStems[dayStemIndex],
      'branch': null,
    };
  }

  Map<String, dynamic> _calculateHourPillar(DateTime birthDate) {
    final hourBranchIndex = ((birthDate.hour + 1) ~/ 2) % 12;
    final hourStemIndex = (birthDate.day * 12 + hourBranchIndex) % 10;
    return {
      'stem': _heavenlyStems[hourStemIndex],
      'branch': null,
    };
  }

  List<Map<String, dynamic>> _calculateMajorFortunes(DateTime birthDate) {
    final fortunes = <Map<String, dynamic>>[];
    final currentAge = DateTime.now().year - birthDate.year;

    for (int i = 0; i < 8; i++) {
      final startAge = i * 10;
      final stemIndex = (birthDate.year + i) % 10;
      final branchIndex = (birthDate.year + i) % 12;

      fortunes.add({
        'startAge': startAge,
        'endAge': startAge + 9,
        'name': '${_heavenlyStems[stemIndex]['name']} ${_earthlyBranches[branchIndex]['name']}',
        'isCurrent': currentAge >= startAge && currentAge <= startAge + 9,
        'interpretation': null,
      });
    }

    return fortunes;
  }

  String _getMajorFortuneInterpretation(int stemIndex, int branchIndex) {
    final stem = _heavenlyStems[stemIndex];
    final branch = _earthlyBranches[branchIndex];
    return '${stem['element']}과 ${branch['element']}의 기운이 만나 ${_getElementInteraction(stem['element'], branch['element'])}의 시기입니다.';
  }

  String _getElementInteraction(String element1, String element2) {
    final interactions = {
      '목목': '성장과 발전',
      '목화': '번영과 확장',
      '목토': '도전과 극복',
      '목금': '시련과 단련',
      '목수': '생명력 충전',
      '화화': '열정과 활력',
      '화토': '안정과 결실',
      '화금': '정제와 완성',
      '화수': '조화와 균형',
      '화목': '지원과 성장',
    };

    return interactions['$element1$element2'] ??
        interactions['$element2$element1'] ??
        '변화와 조정';
  }

  Map<String, int> _calculateTenGods(
    Map<String, dynamic> yearPillar,
    Map<String, dynamic> monthPillar,
    Map<String, dynamic> dayPillar,
    Map<String, dynamic> hourPillar,
  ) {
    final dayStem = dayPillar['stem']['element'];
    final tenGodsCounts = <String, int>{};

    for (final pillar in [yearPillar, monthPillar, hourPillar]) {
      final stemElement = pillar['stem']['element'];
      final god = _getTenGod(dayStem, stemElement, pillar['stem']['yin']);
      tenGodsCounts[god] = (tenGodsCounts[god] ?? 0) + 1;
    }

    return tenGodsCounts;
  }

  String _getTenGod(String dayStem, String stemElement, bool isYin) {
    if (dayStem == stemElement) {
      return isYin ? '비견' : '겁재';
    }

    final relationships = {
      '목': {
        '화': ['식신': '상관'],
        '토': ['편재': '정재'],
        '금': ['편관', '정관'],
        '수': ['편인', '정인': null,
      },
      '화': {
        '토': ['식신', '상관'],
        '금': ['편재', '정재'],
        '수': ['편관', '정관'],
        '목': ['편인', '정인': null,
      },
      '토': {
        '금': ['식신', '상관'],
        '수': ['편재', '정재'],
        '목': ['편관', '정관'],
        '화': ['편인', '정인': null,
      },
      '금': {
        '수': ['식신', '상관'],
        '목': ['편재', '정재'],
        '화': ['편관', '정관'],
        '토': ['편인', '정인': null,
      },
      '수': {
        '목': ['식신', '상관'],
        '화': ['편재', '정재'],
        '토': ['편관', '정관'],
        '금': ['편인', '정인': null,
      },
    };

    final relation = relationships[dayStem]?[stemElement];
    if (relation != null) {
      return isYin ? relation[0] : relation[1];
    }

    return '비견';
  }

  Map<String, int> _calculateElementBalance(
    Map<String, dynamic> yearPillar,
    Map<String, dynamic> monthPillar,
    Map<String, dynamic> dayPillar,
    Map<String, dynamic> hourPillar,
  ) {
    final elementCounts = <String, int>{
      '목': 0,
      '화': 0,
      '토': 0,
      '금': 0,
      '수': null,
    };

    for (final pillar in [yearPillar, monthPillar, dayPillar, hourPillar]) {
      final stemElement = pillar['stem']['element'];
      final branchElement = pillar['branch']['element'];
      elementCounts[stemElement] = elementCounts[stemElement]! + 1;
      elementCounts[branchElement] = elementCounts[branchElement]! + 1;
    }

    return elementCounts;
  }

  String _formatElementBalance(Map<String, int> balance) {
    return balance.entries.map((entry) {
      final element = entry.key;
      final count = entry.value;
      final percentage = (count / 8 * 100).round();
      final strength = count >= 3 ? '강' : count >= 2 ? '중' : '약';
      return '$element: $count개 ($percentage%) - $strength';
    }).join('\n');
  }

  String _formatTenGods(Map<String, int> distribution) {
    if (distribution.isEmpty) return '십신이 고르게 분포되어 있습니다.';

    return distribution.entries.map((entry) {
      final god = entry.key;
      final count = entry.value;
      final info = _tenGods[god]!;
      return '$god($count): ${info['meaning']}';
    }).join('\n');
  }

  String _formatMajorFortunes(List<Map<String, dynamic>> fortunes) {
    return fortunes.take(4).map((fortune) {
      final current = fortune['isCurrent'] ? ' [현재]' : '';
      return '${fortune['startAge']}-${fortune['endAge']}세: ${fortune['name']}$current';
    }).join('\n');
  }

  String _getDayStemInterpretation(Map<String, dynamic> stem) {
    final interpretations = {
      '목': '성장과 발전을 추구하는 진취적인 성격입니다.',
      '화': '열정적이고 활동적이며 리더십이 강합니다.',
      '토': '신중하고 안정적이며 신뢰감을 주는 성격입니다.',
      '금': '원칙적이고 정의로우며 결단력이 있습니다.',
      '수': '지혜롭고 유연하며 적응력이 뛰어납니다.',
    };

    return interpretations[stem['element']] ?? '균형잡힌 성격을 가지고 있습니다.';
  }

  String _getDominantElement(Map<String, int> balance) {
    return balance.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getLackingElement(Map<String, int> balance) {
    return balance.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  String _getLuckyDirection(Map<String, int> balance) {
    final lacking = _getLackingElement(balance);
    final directions = {
      '목': '동쪽',
      '화': '남쪽',
      '토': '중앙',
      '금': '서쪽',
      '수': '북쪽',
    };
    return directions[lacking] ?? '중앙';
  }

  String _getSuitableCareer(Map<String, int> tenGods) {
    if (tenGods.isEmpty) return '다양한 분야';

    final dominant = _getDominantTenGod(tenGods);
    final careers = {
      '비견': '협력이 필요한 사업, 동업',
      '겁재': '경쟁이 치열한 분야, 스포츠',
      '식신': '예술, 요리, 창작 분야',
      '상관': '기술, 전문직, 프리랜서',
      '편재': '사업, 투자, 영업',
      '정재': '회계, 금융, 안정적 직장',
      '편관': '군인, 경찰, 관리직',
      '정관': '공무원, 대기업, 전문직',
      '편인': '학자, 연구원, 종교인',
      '정인': '교육, 의료, 상담',
    };

    return careers[dominant] ?? '다양한 분야';
  }

  String _getDominantTenGod(Map<String, int> distribution) {
    if (distribution.isEmpty) return '균형';
    return distribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _calculateFortuneScore(
      Map<String, int> tenGods, List<String> relevantGods) {
    int score = 70;
    for (final god in relevantGods) {
      score += (tenGods[god] ?? 0) * 10;
    }
    return score.clamp(0, 100);
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFourPillarsDisplay(),
          const SizedBox(height: 16),
          super.buildFortuneResult(),
          _buildElementBalanceChart(),
          _buildTenGodsDistribution(),
          _buildMajorFortunesTimeline(),
          _buildSajuInterpretation(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFourPillarsDisplay() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final pillars = [
      {'title': '년주': 'data': fortune.metadata?['yearPillar'],
      {'title': '월주': 'data': fortune.metadata?['monthPillar'],
      {'title': '일주': 'data': fortune.metadata?['dayPillar'],
      {'title': '시주', 'data': fortune.metadata?['hourPillar'],
    ];

    return GlassCard(
      padding: const EdgeInsets.all(24,
      child: Column(
        children: [
          Text(
            '사주팔자',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: pillars.asMap().entries.map((entry) {
              final index = entry.key;
              final pillar = entry.value;
              final data = pillar['data'] as Map<String, dynamic>?;
              if (data == null) return const SizedBox.shrink();
              return AnimatedBuilder(
                animation: _pillarAnimations[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset:
                        Offset(0, 50 * (1 - _pillarAnimations[index].value)),
                    child: Opacity(
                      opacity: _pillarAnimations[index].value,
                      child: _buildPillarCard(pillar['title'],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(String title, Map<String, dynamic> pillarData) {
    final stem = pillarData['stem'] as Map<String, dynamic>;
    final branch = pillarData['branch'] as Map<String, dynamic>;
    final isDay = title == '일주';

    return GlassContainer(
      width: 75,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      blur: 10,
      borderColor: isDay
          ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
          : Colors.transparent,
      borderWidth: isDay ? 2 : 0,
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                    fontWeight:
                        isDay ? FontWeight.bold : FontWeight.normal),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (stem['color'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stem['name'],
              style: TextStyle(
                color: stem['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              branch['name'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            branch['animal'],
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildElementBalanceChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final elementBalance =
        fortune.metadata?['elementBalance'] as Map<String, int>?;
    if (elementBalance == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오행 균형',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: elementBalance.entries.map((entry) {
                    final element = entry.key;
                    final count = entry.value;
                    final total =
                        elementBalance.values.reduce((a, b) => a + b);
                    final percentage = count / total;

                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: '$element\n${(percentage * 100).round()}%',
                      color: _getElementColor(element),
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getElementColor(String element) {
    final colors = {
      '목': Colors.green,
      '화': Colors.red,
      '토': Colors.brown,
      '금': Colors.amber,
      '수': null,
    };
    return colors[element] ?? Colors.grey;
  }

  Widget _buildTenGodsDistribution() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final tenGodsDistribution =
        fortune.metadata?['tenGodsDistribution'] as Map<String, int>?;
    if (tenGodsDistribution == null || tenGodsDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '십신 분포',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _tenGodsController,
              builder: (context, child) {
                return Column(
                  children: tenGodsDistribution.entries.map((entry) {
                    final god = entry.key;
                    final count = entry.value;
                    final info = _tenGods[god]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: (info['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                god,
                                style: TextStyle(
                                  color: info['color'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
                                  info['meaning'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value:
                                      count / 3 * _tenGodsController.value,
                                  backgroundColor: (info['color'] as Color)
                                      .withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    info['color'],
                                  ),
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorFortunesTimeline() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final majorFortunes =
        fortune.metadata?['majorFortunes'] as List<Map<String, dynamic>>?;
    if (majorFortunes == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '대운 흐름',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...majorFortunes.take(4).map((fortune) {
              final isCurrent = fortune['isCurrent'] as bool;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5)
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${fortune['startAge']}-${fortune['endAge']}세',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '현재',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fortune['name'],
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fortune['interpretation'],
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7)),
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

  Widget _buildSajuInterpretation() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '사주 활용법',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            '일간의 오행을 강화하는 색상과 방향을 활용하세요',
            '부족한 오행을 보충하는 활동과 음식을 섭취하세요',
            '대운의 흐름에 맞춰 인생 계획을 세우세요',
            '십신의 특성을 이해하고 장점을 살리세요',
            '음양오행의 균형을 맞추며 조화로운 삶을 추구하세요',
          ].map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
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
            );
          }).toList(),
        ],
      ),
    );
  }
}
