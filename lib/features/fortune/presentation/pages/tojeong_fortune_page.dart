import 'package:flutter/material.dart' hide Icon;
import 'package:flutter/material.dart' as material show Icon;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../domain/models/conditions/tojeong_fortune_conditions.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';

class TojeongFortunePage extends ConsumerStatefulWidget {
  const TojeongFortunePage({Key? key}) : super(key: key);

  @override
  ConsumerState<TojeongFortunePage> createState() => _TojeongFortunePageState();
}

class _TojeongFortunePageState extends ConsumerState<TojeongFortunePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _hexagramController;
  late Animation<double> _hexagramAnimation;

  // Store hexagram data for result display
  Map<String, dynamic>? _currentHexagram;
  List<Map<String, dynamic>>? _monthlyFortunes;

  final Map<String, Map<String, dynamic>> _hexagrams = {
    '111111': {
      'name': '건위천(乾爲天)',
      'symbol': '☰',
      'meaning': '하늘',
      'description': '강건함과 창조의 기운이 충만한 때입니다. 모든 일이 순조롭게 진행될 것입니다.',
      'element': '금(金)',
      'color': TossDesignSystem.warningOrange
    },
    '000000': {
      'name': '곤위지(坤爲地)',
      'symbol': '☷',
      'meaning': '땅',
      'description': '포용력과 수용의 자세가 필요한 때입니다. 겸손함으로 성공을 이룰 수 있습니다.',
      'element': '토(土)',
      'color': TossDesignSystem.brownPrimary
    },
    '100010': {
      'name': '수뢰둔(水雷屯)',
      'symbol': '☵',
      'meaning': '어려움',
      'description': '시작의 어려움이 있으나 인내하면 좋은 결과를 얻을 것입니다.',
      'element': '수(水)',
      'color': TossDesignSystem.tossBlue
    },
    '010001': {
      'name': '산수몽(山水蒙)',
      'symbol': '☶',
      'meaning': '계몽',
      'description': '배움과 깨달음의 시기입니다. 스승을 찾아 가르침을 받으세요.',
      'element': '토(土)',
      'color': TossDesignSystem.gray500
    }
  };
  final List<String> _monthlyMeanings = [
    '새로운 시작의 기운이 강합니다. 계획을 세우기 좋은 때입니다.',
    '인내가 필요한 시기입니다. 조급해하지 마세요.'
    '활력이 넘치는 달입니다. 적극적으로 행동하세요.',
    '조화와 균형이 중요한 시기입니다.'
    '변화의 바람이 불어옵니다. 유연하게 대처하세요.',
    '안정을 추구하며 기반을 다지는 시기입니다.'
    '인간관계가 중요한 달입니다. 소통을 늘리세요.',
    '수확의 시기입니다. 그동안의 노력이 결실을 맺습니다.'
    '정리와 마무리가 필요한 때입니다.',
    '새로운 도전을 준비하는 시기입니다.'
    '지혜가 필요한 달입니다. 신중하게 결정하세요.',
    '한 해를 마무리하고 다음을 준비하는 시기입니다.'
  ];

  @override
  void initState() {
    super.initState();
    _hexagramController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2));
    _hexagramAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _hexagramController,
        curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hexagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'tojeong',
      title: '토정비결',
      description: '전통 64괘로 보는 한 해 운세',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) => _buildInputForm(onComplete),
      conditionsBuilder: () async {
        final userProfile = await ref.read(userProfileProvider.future);
        final birthDate = userProfile?.birthDate ?? DateTime.now();
        final currentYear = DateTime.now().year;

        // Calculate hexagram data for result display
        final upperTrigram = _calculateUpperTrigram(birthDate, currentYear);
        final lowerTrigram = _calculateLowerTrigram(birthDate, currentYear);
        final hexagramKey = upperTrigram + lowerTrigram;
        final hexagram = _hexagrams[hexagramKey] ?? _hexagrams['111111']!;
        final monthlyFortunes = _generateMonthlyFortunes(birthDate, currentYear);

        setState(() {
          _currentHexagram = hexagram;
          _monthlyFortunes = monthlyFortunes;
        });

        _hexagramController.forward();

        return TojeongFortuneConditions(
          birthDate: birthDate,
          consultDate: DateTime.now(),
          lunarCalendar: null,
        );
      },
      resultBuilder: (context, result) => _buildFortuneResult(result),
    );
  }

  Widget _buildInputForm(VoidCallback onComplete) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                material.Icon(
                  Icons.auto_stories,
                  size: 48,
                  color: TossDesignSystem.warningOrange,
                ),
                const SizedBox(height: 16),
                Text(
                  '토정비결',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '전통 64괘로 보는 한 해 운세',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  '생년월일 정보를 바탕으로 올 한 해의 운세를 64괘로 풀이해드립니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TossButton.primary(
            text: '운세 보기',
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }

  String _calculateUpperTrigram(DateTime birthDate, int currentYear) {
    final sum = birthDate.year + birthDate.month + currentYear;
    final index = sum % 8;
    return _getTrigramBinary(index);
  }

  String _calculateLowerTrigram(DateTime birthDate, int currentYear) {
    final sum = birthDate.day + birthDate.hour + currentYear;
    final index = sum % 8;
    return _getTrigramBinary(index);
  }

  String _getTrigramBinary(int index) {
    final trigrams = [
      '111', '110',
      '101', '100',
      '011', '010',
      '001', '000'
    ];
    return trigrams[index % 8];
  }

  int _calculateChangingLine(DateTime birthDate, int currentYear) {
    return ((birthDate.day + birthDate.month + birthDate.year + currentYear) % 6) + 1;
  }

  String _getChangingLineAdvice(int line) {
    final advices = [
      '시작과 기초',
      '내면의 충실',
      '변화와 도전',
      '안정과 조화',
      '리더십과 책임',
      '완성과 새로운 시작'
    ];
    return advices[(line - 1) % advices.length];
  }

  List<Map<String, dynamic>> _generateMonthlyFortunes(DateTime birthDate, int year) {
    final fortunes = <Map<String, dynamic>>[];
    for (int month = 1; month <= 12; month++) {
      final score = 60 + ((birthDate.day + month + year) % 35);
      fortunes.add({
        'month': month,
        'score': score,
        'meaning': _monthlyMeanings[month - 1],
        'element': _getMonthElement(month)});
    }
    return fortunes;
  }

  String _getMonthElement(int month) {
    final elements = ['목', '목', '토', '화', '화', '토', '금', '금', '토', '수', '수', '토'];
    return elements[(month - 1) % elements.length];
  }

  String _formatMonthlyFortunes(List<Map<String, dynamic>> fortunes) {
    return fortunes.map((f) {
      final month = f['month'];
      final score = f['score'];
      final filledStars = score ~/ 20;
      final emptyStars = 5 - filledStars.toInt();
      final stars = '★' * filledStars.toInt() + '☆' * emptyStars.toInt();
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
      '수(水)': '북쪽'
    };
    return directions[element] ?? '중앙';
  }

  String _getColorName(Color color) {
    if (color == TossDesignSystem.warningOrange) return '황금색';
    if (color == TossDesignSystem.brownPrimary) return '갈색';
    if (color == TossDesignSystem.tossBlue) return '파란색';
    if (color == TossDesignSystem.gray500) return '회색';
    if (color == TossDesignSystem.successGreen) return '초록색';
    if (color == TossDesignSystem.errorRed) return '빨간색';
    return '흰색';
  }

  Widget _buildFortuneResult(dynamic result) {
    if (_currentHexagram == null || _monthlyFortunes == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHexagramDisplay(),
          const SizedBox(height: 16),
          _buildOverallScore(result),
          const SizedBox(height: 16),
          _buildDescription(result),
          const SizedBox(height: 16),
          _buildMonthlyChart(),
          _buildElementBalance(),
          _buildChangingLineInfo(result),
          _buildRecommendations(result),
          _buildTojeongTips(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // BaseFortunePage의 위젯들을 토정비결 페이지용으로 구현
  Widget _buildOverallScore(dynamic result) {
    final score = result.score ?? 70;
    final scoreColor = _getScoreColor(score);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scoreColor.withValues(alpha: 0.2),
                  scoreColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: scoreColor.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$score점',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getScoreLabel(score),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return '매우 좋음';
    if (score >= 75) return '좋음';
    if (score >= 60) return '보통';
    if (score >= 40) return '주의';
    return '노력 필요';
  }

  Widget _buildDescription(dynamic result) {
    final content = result.data['content'] as String?;
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
      ),
    );
  }

  Widget _buildRecommendations(dynamic result) {
    final recommendations = (result.data['recommendations'] as List?)?.cast<String>();
    if (recommendations == null || recommendations.isEmpty) {
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
                material.Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '조언',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    material.Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagramDisplay() {
    final hexagram = _currentHexagram;
    if (hexagram == null) return const SizedBox.shrink();

    // Calculate trigrams from current hexagram
    final birthDate = DateTime.now(); // This will be properly set from user profile
    final currentYear = DateTime.now().year;
    final upperTrigram = _calculateUpperTrigram(birthDate, currentYear);
    final lowerTrigram = _calculateLowerTrigram(birthDate, currentYear);

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
                          (hexagram['color'] as Color).withValues(alpha: 0.2),
                          (hexagram['color'] as Color).withValues(alpha: 0.6)]),
                      boxShadow: [
                        BoxShadow(
                          color: (hexagram['color'] as Color).withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10)]),
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
                    hexagram['name'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (hexagram['color'] as Color).withValues(alpha: 0.1),
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
          style: Theme.of(context).textTheme.bodySmall),
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
                    : TossDesignSystem.white.withValues(alpha: 0.0),
                border: bit == '0'
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2)
                    : null,
                borderRadius: BorderRadius.circular(4)
              )
            );
          }).toList()
        )
      ]
    );
  }

  Widget _buildMonthlyChart() {
    final monthlyFortunes = _monthlyFortunes;
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
                material.Icon(
                  Icons.calendar_month,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '월별 운세',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyFortunes.map((fortune) {
                  final month = fortune['month'] as int;
                  final score = fortune['score'] as int;
                  const maxScore = 100;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: fortune['meaning'],
                            child: Container(
                              height: (score / maxScore) * 150,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    _getScoreColor(score),
                                    _getScoreColor(score).withValues(alpha: 0.5)]),
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
    if (score >= 85) return TossDesignSystem.successGreen;
    if (score >= 70) return TossDesignSystem.tossBlue;
    if (score >= 55) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

  Widget _buildElementBalance() {
    final monthlyFortunes = _monthlyFortunes;
    if (monthlyFortunes == null) return const SizedBox.shrink();

    final elementCounts = <String, int>{};
    for (final f in monthlyFortunes) {
      final element = f['element'] as String;
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
                material.Icon(
                  Icons.balance,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오행 균형',
                  style: Theme.of(context).textTheme.headlineSmall)]),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '$count개월',
                          style: Theme.of(context).textTheme.bodyMedium)]),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getElementColor(element)),
                      minHeight: 8
                    )
                  ]
                )
              );
            }).toList()
          ]
        )
      )
    );
  }

  Color _getElementColor(String element) {
    final colors = {
      '목': TossDesignSystem.successGreen,
      '화': TossDesignSystem.errorRed,
      '토': TossDesignSystem.brownPrimary,
      '금': TossDesignSystem.warningOrange,
      '수': TossDesignSystem.tossBlue};
    return colors[element] ?? TossDesignSystem.gray500;
  }

  Widget _buildChangingLineInfo(dynamic result) {
    // Calculate changing line from result data
    final birthDate = DateTime.now(); // Will be set from user profile
    final currentYear = DateTime.now().year;
    final changingLine = _calculateChangingLine(birthDate, currentYear);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.purple.withValues(alpha: 0.1),
            TossDesignSystem.purple.withValues(alpha: 0.05)]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                material.Icon(
                  Icons.change_circle,
                  color: TossDesignSystem.purple),
                const SizedBox(width: 8),
                Text(
                  '변효 해석',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.purple.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '제${changingLine}효',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: TossDesignSystem.purple,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _getChangingLineAdvice(changingLine),
                    style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Text(
                    _getChangingLineDetail(changingLine),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7)
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
              material.Icon(
                Icons.tips_and_updates,
                color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '토정비결 활용법',
                style: Theme.of(context).textTheme.headlineSmall)]),
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
                  material.Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary),
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
