import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/auth_provider.dart';

class SajuPage extends BaseFortunePage {
  const SajuPage({Key? key})
      : super(
          key: key,
          title: '사주팔자',
          description: '당신의 사주팔자를 통해 타고난 운명을 확인해보세요',
          fortuneType: 'saju',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<SajuPage> createState() => _SajuPageState();
}

class _SajuPageState extends BaseFortunePageState<SajuPage> {
  Map<String, dynamic>? _sajuData;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock saju data
    _sajuData = {
      'elements': {
        '목(木)': 85,
        '화(火)': 70,
        '토(土)': 60,
        '금(金)': 75,
        '수(水)': 90,
      },
      'talents': [
        {'title': '리더십', 'description': '타고난 지도자의 기질을 가지고 있습니다', 'score': 90},
        {'title': '창의성', 'description': '독창적인 아이디어가 풍부합니다', 'score': 85},
        {'title': '인간관계', 'description': '사람들과 쉽게 친해집니다', 'score': 80},
      ],
      'pastLife': {
        'role': '조선시대 선비',
        'description': '학문을 사랑하고 정의를 추구했던 선비였습니다',
        'karma': '현생에서도 지식을 추구하고 올바른 길을 걷게 됩니다',
      },
    };

    return Fortune(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      type: 'saju',
      content: '당신은 수(水) 기운이 강한 사주를 가지고 있습니다.',
      createdAt: DateTime.now(),
      // Extended properties
      category: 'saju',
      overallScore: 82,
      description: '당신은 수(水) 기운이 강한 사주를 가지고 있습니다. 지혜롭고 유연한 성격으로 어떤 상황에서도 잘 적응합니다. 특히 창의적인 분야에서 큰 성과를 낼 수 있습니다.',
      scoreBreakdown: {
        '재물운': 75,
        '직업운': 85,
        '건강운': 70,
        '애정운': 80,
      },
      luckyItems: {
        '행운색': '검은색, 파란색',
        '행운숫자': '1, 6',
        '행운방향': '북쪽',
      },
      recommendations: [
        '물과 관련된 활동이 행운을 가져다줍니다',
        '창의적인 일을 시작하기 좋은 시기입니다',
        '건강 관리에 더 신경 쓰세요',
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          super.buildFortuneResult(),
          if (_sajuData != null) ...[
            _buildElementsChart(),
            const SizedBox(height: 16),
            _buildTalentAnalysis(),
            const SizedBox(height: 16),
            _buildPastLifeSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildElementsChart() {
    final elements = _sajuData!['elements'] as Map<String, dynamic>;
    
    return GlassCard(
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
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오행 분석',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                ),
                radarBorderData: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                gridBorderData: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 0.5,
                ),
                titleTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                dataSets: [
                  RadarDataSet(
                    fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderColor: Theme.of(context).colorScheme.primary,
                    borderWidth: 2,
                    dataEntries: elements.values
                        .map((value) => RadarEntry(value: value.toDouble()))
                        .toList(),
                  ),
                ],
                getTitle: (index, angle) {
                  final titles = elements.keys.toList();
                  return RadarChartTitle(
                    text: titles[index],
                    angle: 0,
                  );
                },
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
          ),
          const SizedBox(height: 20),
          ...elements.entries.map((entry) {
            final color = _getElementColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${entry.value}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
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

  Widget _buildTalentAnalysis() {
    final talents = _sajuData!['talents'] as List<dynamic>;

    return GlassCard(
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
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '재능 분석',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...talents.asMap().entries.map((entry) {
            final index = entry.key;
            final talent = entry.value as Map<String, dynamic>;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                blur: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          talent['title'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${talent['score']}점',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      talent['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: talent['score'] / 100,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              ).animate()
                  .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
                  .slideX(begin: 0.1, end: 0),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPastLifeSection() {
    final pastLife = _sajuData!['pastLife'] as Map<String, dynamic>;

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      liquidColors: [
        Colors.indigo.shade300,
        Colors.purple.shade300,
        Colors.deepPurple.shade300,
      ],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade400,
                  Colors.indigo.shade600,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '전생 분석',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.indigo.withOpacity(0.3),
              ),
            ),
            child: Text(
              pastLife['role'],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            pastLife['description'],
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.amber.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pastLife['karma'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: 500.ms)
        .shimmer(delay: 1000.ms, duration: 2000.ms);
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목(木)':
        return Colors.green;
      case '화(火)':
        return Colors.red;
      case '토(土)':
        return Colors.brown;
      case '금(金)':
        return Colors.amber;
      case '수(水)':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}