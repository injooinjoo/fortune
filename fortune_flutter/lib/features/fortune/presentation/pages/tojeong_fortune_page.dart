import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class TojeongFortunePage extends BaseFortunePage {
  const TojeongFortunePage({Key? key})
      : super(
          key: key,
          title: '토정비결',
          description: '전통 64괘로 보는 한 해 운세',
          fortuneType: 'tojeong',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<TojeongFortunePage> createState() => _TojeongFortunePageState();
}

class _TojeongFortunePageState extends BaseFortunePageState<TojeongFortunePage> {
  late AnimationController _hexagramController;
  late Animation<double> _hexagramAnimation;
  
  // 64괘 정보
  final Map<String, Map<String, dynamic>> _hexagrams = {
    '111111': {
      'name': '건위천(乾爲天)',
      'symbol': '☰',
      'meaning': '하늘',
      'description': '강건함과 창조의 기운이 충만한 때입니다. 모든 일이 순조롭게 진행될 것입니다.',
      'element': '금(金)',
      'color': Colors.amber,
    },
    '000000': {
      'name': '곤위지(坤爲地)',
      'symbol': '☷',
      'meaning': '땅',
      'description': '포용력과 수용의 자세가 필요한 때입니다. 겸손함으로 성공을 이룰 수 있습니다.',
      'element': '토(土)',
      'color': Colors.brown,
    },
    '100010': {
      'name': '수뢰둔(水雷屯)',
      'symbol': '☵',
      'meaning': '어려움',
      'description': '시작의 어려움이 있으나 인내하면 좋은 결과를 얻을 것입니다.',
      'element': '수(水)',
      'color': Colors.blue,
    },
    '010001': {
      'name': '산수몽(山水蒙)',
      'symbol': '☶',
      'meaning': '계몽',
      'description': '배움과 깨달음의 시기입니다. 스승을 찾아 가르침을 받으세요.',
      'element': '토(土)',
      'color': Colors.grey,
    },
    // ... 실제로는 64개 모두 정의해야 함
  };

  // 12달 운세 해석
  final List<String> _monthlyMeanings = [
    '새로운 시작의 기운이 강합니다. 계획을 세우기 좋은 때입니다.',
    '인내가 필요한 시기입니다. 조급해하지 마세요.',
    '활력이 넘치는 달입니다. 적극적으로 행동하세요.',
    '조화와 균형이 중요한 시기입니다.',
    '변화의 바람이 불어옵니다. 유연하게 대처하세요.',
    '안정을 추구하며 기반을 다지는 시기입니다.',
    '인간관계가 중요한 달입니다. 소통을 늘리세요.',
    '수확의 시기입니다. 그동안의 노력이 결실을 맺습니다.',
    '정리와 마무리가 필요한 때입니다.',
    '새로운 도전을 준비하는 시기입니다.',
    '지혜가 필요한 달입니다. 신중하게 결정하세요.',
    '한 해를 마무리하고 다음을 준비하는 시기입니다.',
  ];

  @override
  void initState() {
    super.initState();
    _hexagramController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _hexagramAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _hexagramController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hexagramController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Get user profile for birth date
    final userProfile = await ref.read(userProfileProvider.future);
    
    // Calculate hexagram based on birth date and current year
    final birthDate = userProfile?.birthDate ?? DateTime.now();
    final currentYear = DateTime.now().year;
    
    // 상괘와 하괘 계산
    final upperTrigram = _calculateUpperTrigram(birthDate, currentYear);
    final lowerTrigram = _calculateLowerTrigram(birthDate, currentYear);
    final hexagramKey = upperTrigram + lowerTrigram;
    
    // 기본 괘 정보 (실제로는 64개 중에서 선택)
    final hexagram = _hexagrams[hexagramKey] ?? _hexagrams['111111']!;
    
    // 변효 계산 (변하는 효)
    final changingLine = _calculateChangingLine(birthDate, currentYear);
    
    // 월별 운세 생성
    final monthlyFortunes = _generateMonthlyFortunes(birthDate, currentYear);
    
    // Start animation
    _hexagramController.forward();

    final description = '''【${hexagram['name']}】괘를 얻으셨습니다.

${hexagram['symbol']} ${hexagram['meaning']}의 기운이 함께합니다.

${hexagram['description']}

🎯 올해의 핵심 조언:
변효가 ${changingLine}효에 있으니, 특히 ${_getChangingLineAdvice(changingLine)}에 주의하세요.

📅 월별 운세:
${_formatMonthlyFortunes(monthlyFortunes)}

💫 행운의 요소:
• 원소: ${hexagram['element']}
• 방향: ${_getDirectionFromElement(hexagram['element'])}
• 색상: ${_getColorName(hexagram['color'] as Color)}
• 숫자: ${(birthDate.day + currentYear) % 9 + 1}

올 한 해 ${hexagram['name']}의 기운을 잘 활용하여 좋은 결과를 얻으시길 바랍니다.''';

    final overallScore = 70 + (hexagram.hashCode % 25);

    return Fortune(
      id: 'tojeong_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'tojeong',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '상반기': 75 + (upperTrigram.hashCode % 20),
        '하반기': 70 + (lowerTrigram.hashCode % 25),
        '변화운': 80 + (changingLine % 15),
      },
      description: description,
      luckyItems: {
        '주괘': hexagram['name'],
        '원소': hexagram['element'],
        '방향': _getDirectionFromElement(hexagram['element']),
        '행운의 달': '${_getBestMonth(monthlyFortunes)}월',
        '주의할 달': '${_getWorstMonth(monthlyFortunes)}월',
      },
      recommendations: [
        '${hexagram['element']}의 기운을 강화하는 활동을 하세요',
        '${_getDirectionFromElement(hexagram['element'])} 방향으로 여행을 가면 좋습니다',
        '${_getColorName(hexagram['color'] as Color)}색 물건을 소지하세요',
        '매월 초에 월별 운세를 확인하고 계획을 세우세요',
      ],
      metadata: {
        'hexagram': hexagram,
        'upperTrigram': upperTrigram,
        'lowerTrigram': lowerTrigram,
        'changingLine': changingLine,
        'monthlyFortunes': monthlyFortunes,
        'year': currentYear,
      },
    );
  }

  String _calculateUpperTrigram(DateTime birthDate, int currentYear) {
    // 상괘 계산 로직 (년월일 기반)
    final sum = birthDate.year + birthDate.month + currentYear;
    final trigramIndex = sum % 8;
    return _getTrigramBinary(trigramIndex);
  }

  String _calculateLowerTrigram(DateTime birthDate, int currentYear) {
    // 하괘 계산 로직 (일시 기반)
    final sum = birthDate.day + birthDate.hour + currentYear;
    final trigramIndex = sum % 8;
    return _getTrigramBinary(trigramIndex);
  }

  String _getTrigramBinary(int index) {
    // 8괘를 3비트 이진수로 표현
    final trigrams = [
      '111', // 건(乾) - 하늘
      '110', // 태(兌) - 연못
      '101', // 이(離) - 불
      '100', // 진(震) - 우레
      '011', // 손(巽) - 바람
      '010', // 감(坎) - 물
      '001', // 간(艮) - 산
      '000', // 곤(坤) - 땅
    ];
    return trigrams[index % 8];
  }

  int _calculateChangingLine(DateTime birthDate, int currentYear) {
    // 변효 계산 (1-6)
    return ((birthDate.day + birthDate.month + birthDate.year + currentYear) % 6) + 1;
  }

  String _getChangingLineAdvice(int line) {
    final advices = [
      '시작과 기초',
      '내면의 충실',
      '변화와 도전',
      '안정과 조화',
      '리더십과 책임',
      '완성과 새로운 시작',
    ];
    return advices[line - 1];
  }

  List<Map<String, dynamic>> _generateMonthlyFortunes(DateTime birthDate, int year) {
    final fortunes = <Map<String, dynamic>>[];
    
    for (int month = 1; month <= 12; month++) {
      final score = 60 + ((birthDate.day + month + year) % 35);
      fortunes.add({
        'month': month,
        'score': score,
        'meaning': _monthlyMeanings[month - 1],
        'element': _getMonthElement(month),
      });
    }
    
    return fortunes;
  }

  String _getMonthElement(int month) {
    final elements = ['목', '목', '토', '화', '화', '토', '금', '금', '토', '수', '수', '토'];
    return elements[month - 1];
  }

  String _formatMonthlyFortunes(List<Map<String, dynamic>> fortunes) {
    return fortunes.map((f) {
      final month = f['month'];
      final score = f['score'];
      final filledStars = (score ~/ 20).toInt();
      final emptyStars = (5 - filledStars).toInt();
      final stars = '★' * filledStars + '☆' * emptyStars;
      return '$month월: $stars (${f['element']})';
    }).join('\n');
  }

  int _getBestMonth(List<Map<String, dynamic>> fortunes) {
    fortunes.sort((a, b) => b['score'].compareTo(a['score']));
    return fortunes.first['month'];
  }

  int _getWorstMonth(List<Map<String, dynamic>> fortunes) {
    fortunes.sort((a, b) => a['score'].compareTo(b['score']));
    return fortunes.first['month'];
  }

  String _getDirectionFromElement(String element) {
    final directions = {
      '목(木)': '동쪽',
      '화(火)': '남쪽',
      '토(土)': '중앙',
      '금(金)': '서쪽',
      '수(水)': '북쪽',
    };
    return directions[element] ?? '중앙';
  }

  String _getColorName(Color color) {
    if (color == Colors.amber) return '황금색';
    if (color == Colors.brown) return '갈색';
    if (color == Colors.blue) return '파란색';
    if (color == Colors.grey) return '회색';
    if (color == Colors.green) return '초록색';
    if (color == Colors.red) return '빨간색';
    return '흰색';
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHexagramDisplay(),
          const SizedBox(height: 16),
          super.buildFortuneResult(),
          _buildMonthlyChart(),
          _buildElementBalance(),
          _buildChangingLineInfo(),
          _buildTojeongTips(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHexagramDisplay() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final hexagram = fortune.metadata?['hexagram'] as Map<String, dynamic>?;
    final upperTrigram = fortune.metadata?['upperTrigram'] as String?;
    final lowerTrigram = fortune.metadata?['lowerTrigram'] as String?;
    
    if (hexagram == null || upperTrigram == null || lowerTrigram == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _hexagramAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_hexagramAnimation.value * 0.2),
          child: Opacity(
            opacity: _hexagramAnimation.value,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '괘상',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (hexagram['color'] as Color).withValues(alpha: 0.3),
                          (hexagram['color'] as Color).withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (hexagram['color'] as Color).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTrigram(upperTrigram, '상괘'),
                          const SizedBox(height: 16),
                          _buildTrigram(lowerTrigram, '하괘'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hexagram['name'] as String,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (hexagram['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${hexagram['meaning']} • ${hexagram['element']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hexagram['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrigram(String trigram, String label) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Column(
          children: trigram.split('').map((bit) {
            return Container(
              width: 60,
              height: 8,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: bit == '1' 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
                border: bit == '0' 
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final monthlyFortunes = fortune.metadata?['monthlyFortunes'] as List<Map<String, dynamic>>?;
    if (monthlyFortunes == null) return const SizedBox.shrink();

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
                  Icons.calendar_month,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '월별 운세',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyFortunes.map((fortune) {
                  final month = fortune['month'] as int;
                  final score = fortune['score'] as int;
                  final maxScore = 100;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: fortune['meaning'] as String,
                            child: Container(
                              height: (score / maxScore) * 150,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    _getScoreColor(score),
                                    _getScoreColor(score).withValues(alpha: 0.5),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$month월',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 55) return Colors.orange;
    return Colors.red;
  }

  Widget _buildElementBalance() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final monthlyFortunes = fortune.metadata?['monthlyFortunes'] as List<Map<String, dynamic>>?;
    if (monthlyFortunes == null) return const SizedBox.shrink();

    // 오행별 개수 계산
    final elementCounts = <String, int>{};
    for (final fortune in monthlyFortunes) {
      final element = fortune['element'] as String;
      elementCounts[element] = (elementCounts[element] ?? 0) + 1;
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
                  Icons.balance,
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
            ...elementCounts.entries.map((entry) {
              final element = entry.key;
              final count = entry.value;
              final percentage = count / 12;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          element,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$count개월',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getElementColor(element),
                      ),
                      minHeight: 8,
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

  Color _getElementColor(String element) {
    final colors = {
      '목': Colors.green,
      '화': Colors.red,
      '토': Colors.brown,
      '금': Colors.amber,
      '수': Colors.blue,
    };
    return colors[element] ?? Colors.grey;
  }

  Widget _buildChangingLineInfo() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final changingLine = fortune.metadata?['changingLine'] as int?;
    if (changingLine == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.change_circle,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  '변효 해석',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '제${changingLine}효',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getChangingLineAdvice(changingLine),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getChangingLineDetail(changingLine),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChangingLineDetail(int line) {
    final details = [
      '새로운 시작을 위한 준비가 필요합니다. 기초를 탄탄히 하세요.',
      '내면의 목소리에 귀를 기울이고 진실된 마음을 유지하세요.',
      '변화의 시기입니다. 유연하게 대처하되 중심을 잃지 마세요.',
      '안정과 조화를 추구하며 주변과의 관계를 돈독히 하세요.',
      '리더십을 발휘할 때입니다. 책임감을 가지고 행동하세요.',
      '한 사이클이 끝나고 새로운 시작을 준비하는 시기입니다.',
    ];
    return details[line - 1];
  }

  Widget _buildTojeongTips() {
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
                '토정비결 활용법',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            '매월 초에 해당 월의 운세를 다시 확인하고 계획을 세우세요',
            '변효가 나타내는 시기에는 특히 신중하게 행동하세요',
            '본인의 오행과 맞는 색상, 방향, 음식을 활용하세요',
            '좋은 달에는 적극적으로, 주의할 달에는 보수적으로 행동하세요',
            '토정비결은 참고용이며, 본인의 노력이 가장 중요합니다',
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