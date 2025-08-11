import 'package:flutter/material.dart' hide Icon;
import 'package:flutter/material.dart' as material show Icon;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/components/toast.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';

class LoveFortunePage extends BaseFortunePage {
  const LoveFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams}) : super(
          key: key,
          title: '연애운',
          description: '당신의 연애운을 확인해보세요',
          fortuneType: 'love',
          requiresUserInfo: false,
          initialParams: initialParams
        );

  @override
  ConsumerState<LoveFortunePage> createState() => _LoveFortunePageState();
}

class _LoveFortunePageState extends ConsumerState<LoveFortunePage> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _loveData;
  final List<bool> _missionChecks = List.filled(5, false);
  bool isLoading = false;
  Fortune? currentFortune;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Use actual API call
    final fortuneService = ref.read(fortuneServiceProvider);
    final fortune = await fortuneService.getLoveFortune(userId: user.id);

    // Extract love-specific data from the fortune response
    _loveData = {
      'loveIndex': fortune.overallScore ?? 88,
      'monthlyTrend': fortune.additionalInfo?['monthlyTrend'] ?? {
        '이번 주': 75,
        '다음 주': 82,
        '3주 후': 90,
        '4주 후': 95},
      'singleAdvice': fortune.additionalInfo?['singleAdvice'] ?? {
        'summary': '새로운 만남의 기회가 찾아올 시기입니다': 'details': fortune.content,
        'luckySpots': ['카페': '서점', '운동 시설'],
        'luckyDays': ['금요일': '일요일']},
      'coupleAdvice': fortune.additionalInfo?['coupleAdvice'] ?? {
        'summary': '서로를 더 깊이 이해하게 되는 시기': 'details': '연인과의 관계가 한 단계 더 발전할 수 있는 시기입니다. 진솔한 대화를 통해 서로를 더 잘 알아가세요.': 'activities': ['함께 요리하기': '여행 계획 세우기', '운동 함께하기'],
        'caution': '사소한 일로 다투지 않도록 주의하세요'},
      'reunionAdvice': fortune.additionalInfo?['reunionAdvice'] ?? {
        'summary': '과거를 정리하고 새 출발을 준비할 때': 'details': '지난 관계에서 배운 교훈을 바탕으로 더 나은 사랑을 만날 준비를 하세요.': 'healing': '자신을 먼저 사랑하는 시간을 가지세요': 'newStart': '3주 후부터 새로운 인연이 시작될 수 있습니다'},
      'actionMissions': fortune.additionalInfo?['actionMissions'] ?? [
        '하루에 한 번 자신에게 칭찬하기': '좋아하는 사람에게 먼저 연락하기',
        '새로운 취미 활동 시작하기': '감사 일기 쓰기',
        '운동으로 자신감 키우기'],
      'luckyBooster': fortune.luckyItems ?? {
        '향수': '플로럴 계열': '색상': '핑크, 레드': '액세서리': '하트 모양 펜던트': '꽃': '장미, 튤립'},
      'psychologicalAdvice': fortune.additionalInfo?['psychologicalAdvice'] ?? 
        '사랑은 자신을 먼저 사랑하는 것에서 시작됩니다. 자존감을 높이고 긍정적인 에너지를 발산하세요.'
  };

    return fortune;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연애운'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()
          : currentFortune == null
              ? _buildInitialView()
              : _buildFortuneResultView(),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const material.Icon(Icons.favorite, size: 80, color: Colors.pink),
            const SizedBox(height: 20),
            const Text(
              '당신의 연애운을 확인해보세요',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  final fortune = await generateFortune({});
                  setState(() {
                    currentFortune = fortune;
                    isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: const Text('연애운 확인하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneResultView() {
    return SingleChildScrollView(
      child: buildFortuneResult(),
    );
  }

  Widget buildFortuneResult() {
    return Column(
      children: [
        _buildLoveIndexCard(),
        const SizedBox(height: 24),
        _buildMonthlyTrend(),
        const SizedBox(height: 24),
        _buildAdviceTabs(),
        const SizedBox(height: 24),
        _buildActionMissions(),
        const SizedBox(height: 24),
        _buildLuckyBooster(),
        const SizedBox(height: 24),
        _buildPsychologicalAdvice(),
        const SizedBox(height: 32)]
    );
  }

  Widget _buildLoveIndexCard() {
    final loveIndex = _loveData!['loveIndex'] as int;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.pink.shade300,
                    Colors.pink.shade500]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10)]),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const material.Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 40),
                    const SizedBox(height: 8),
                    Text(
                      '$loveIndex점',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),)),
            const SizedBox(height: 24),
            Text(
              '연애 지수',
              style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _getLoveIndexMessage(loveIndex),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate()
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
            .then()
            .shimmer(delay: 500.ms, duration: 1500.ms);
  }

  Widget _buildMonthlyTrend() {
    final trend = _loveData!['monthlyTrend'] as Map<String, dynamic>;

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
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600]),
                    borderRadius: BorderRadius.circular(12),
                  child: const material.Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '월간 연애운 흐름',
                  style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            ...trend.entries.map((entry) {
              final progress = (entry.value as int) / 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                          '${entry.value}점',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(entry.value as int)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 10,
                      percent: progress,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: _getScoreColor(entry.value as int),
                      barRadius: const Radius.circular(5),
                      animation: true,
                      animationDuration: 1000,
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

  Widget _buildAdviceTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: '싱글'),
                Tab(text: '커플'),
                Tab(text: '재회'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSingleAdvice(),
                _buildCoupleAdvice(),
                _buildReunionAdvice(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleAdvice() {
    final advice = _loveData!['singleAdvice'] as Map<String, dynamic>;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              child: Text(
                advice['summary'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[700]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              advice['details'],
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _buildAdviceSection(
              icon: Icons.place_rounded,
              title: '행운의 장소',
              items: advice['luckySpots']),
            const SizedBox(height: 16),
            _buildAdviceSection(
              icon: Icons.calendar_today_rounded,
              title: '행운의 날',
              items: advice['luckyDays'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupleAdvice() {
    final advice = _loveData!['coupleAdvice'] as Map<String, dynamic>;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              child: Text(
                advice['summary'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              advice['details'],
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _buildAdviceSection(
              icon: Icons.favorite_rounded,
              title: '추천 활동',
              items: advice['activities']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  material.Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade700,
                    size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice['caution'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700),
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

  Widget _buildReunionAdvice() {
    final advice = _loveData!['reunionAdvice'] as Map<String, dynamic>;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              child: Text(
                advice['summary'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              advice['details'],
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _buildAdviceItem(
              icon: Icons.healing_rounded,
              title: '치유',
              content: advice['healing'],
              color: Colors.green),
            const SizedBox(height: 12),
            _buildAdviceItem(
              icon: Icons.stars_rounded,
              title: '새 시작',
              content: advice['newStart'],
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection({
    required IconData icon,
    required String title,
    required List<dynamic> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            material.Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Chip(
              label: Text(item.toString(),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdviceItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          material.Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMissions() {
    final missions = _loveData!['actionMissions'] as List<dynamic>;

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
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600]),
                    borderRadius: BorderRadius.circular(12),
                  child: const material.Icon(
                    Icons.task_alt_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '행운을 부르는 액션 미션',
                  style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            ...missions.asMap().entries.map((entry) {
              final index = entry.key;
              final mission = entry.value as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _missionChecks[index] = !_missionChecks[index];
                    });
                    if (_missionChecks[index]) {
                      Toast.success(context, '미션 완료! 행운이 찾아올 거예요 🍀');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _missionChecks[index]
                          ? Colors.green.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _missionChecks[index]
                            ? Colors.green.withOpacity(0.3)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _missionChecks[index]
                                ? Colors.green
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _missionChecks[index]
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              width: 2)),
                          child: _missionChecks[index]
                              ? const material.Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16)
                              : null),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mission,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: _missionChecks[index]
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: _missionChecks[index]
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideX(begin: 0.1, end: 0);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyBooster() {
    final booster = _loveData!['luckyBooster'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerGlass(
        shimmerColor: Colors.amber,
        borderRadius: BorderRadius.circular(24),
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
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600]),
                      borderRadius: BorderRadius.circular(12),
                    child: const material.Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24)),
                  const SizedBox(width: 12),
                  Text(
                    '행운 부스터',
                    style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: booster.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.shade50,
                          Colors.pink.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.pink.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        material.Icon(
                          _getBoosterIcon(entry.key),
                          color: Colors.pink.shade600,
                          size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.pink.shade800,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                entry.value.toString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade900,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPsychologicalAdvice() {
    final advice = _loveData!['psychologicalAdvice'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.indigo.shade600]),
                shape: BoxShape.circle),
              child: const material.Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 32)),
            const SizedBox(height: 16),
            Text(
              '심리 조언',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              advice,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getLoveIndexMessage(int score) {
    if (score >= 90) return '최고의 연애운! 사랑이 넘치는 시기입니다 💕';
    if (score >= 80) return '좋은 연애운! 적극적으로 행동하세요 ❤️';
    if (score >= 70) return '평균적인 연애운. 노력하면 좋은 결과가 있을 거예요';
    if (score >= 60) return '조금 부족한 연애운. 자신을 먼저 사랑하세요';
    return '충전이 필요한 시기. 혼자만의 시간을 가져보세요';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.pink.shade400;
    if (score >= 60) return Colors.orange.shade400;
    return Colors.blue.shade400;
  }

  IconData _getBoosterIcon(String type) {
    switch (type) {
      case '향수': return Icons.water_drop_rounded;
      case '색상':
        return Icons.palette_rounded;
      case '액세서리':
        return Icons.diamond_rounded;
      case '꽃': return Icons.local_florist_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}