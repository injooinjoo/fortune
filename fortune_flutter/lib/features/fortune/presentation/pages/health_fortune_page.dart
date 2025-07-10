import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class HealthFortunePage extends BaseFortunePage {
  const HealthFortunePage({Key? key})
      : super(
          key: key,
          title: '건강운',
          description: '신체와 정신 건강을 위한 맞춤 운세',
          fortuneType: 'health',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<HealthFortunePage> createState() => _HealthFortunePageState();
}

class _HealthFortunePageState extends BaseFortunePageState<HealthFortunePage> {
  String? _healthConcern;
  String? _exerciseFrequency;
  String? _sleepQuality;
  bool _hasChronicCondition = false;
  String? _stressLevel;

  final List<String> _healthConcerns = [
    '체중 관리',
    '피로 회복',
    '스트레스 관리',
    '면역력 강화',
    '수면 개선',
    '소화 건강',
    '관절 건강',
    '피부 건강',
    '정신 건강',
  ];

  final Map<String, String> _exerciseFrequencies = {
    'none': '운동 안함',
    'rarely': '가끔 (월 1-2회)',
    'moderate': '적당히 (주 1-2회)',
    'regular': '규칙적 (주 3-4회)',
    'frequent': '자주 (주 5회 이상)',
  };

  final Map<String, String> _sleepQualities = {
    'poor': '매우 나쁨',
    'below_average': '나쁨',
    'average': '보통',
    'good': '좋음',
    'excellent': '매우 좋음',
  };

  final Map<String, String> _stressLevels = {
    'very_low': '매우 낮음',
    'low': '낮음',
    'moderate': '보통',
    'high': '높음',
    'very_high': '매우 높음',
  };

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params,
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_healthConcern == null || _exerciseFrequency == null || 
        _sleepQuality == null || _stressLevel == null) {
      return null;
    }

    return {
      'healthConcern': _healthConcern,
      'exerciseFrequency': _exerciseFrequency,
      'sleepQuality': _sleepQuality,
      'hasChronicCondition': _hasChronicCondition,
      'stressLevel': _stressLevel,
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Health Concern Selection
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '주요 건강 관심사',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _healthConcerns.map((concern) {
                  final isSelected = _healthConcern == concern;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _healthConcern = concern;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(concern),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Exercise Frequency
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '운동 빈도',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...(_exerciseFrequencies.entries.map((entry) {
                final isSelected = _exerciseFrequency == entry.key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _exerciseFrequency = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Row(
                        children: [
                          Radio<String>(
                            value: entry.key,
                            groupValue: _exerciseFrequency,
                            onChanged: (value) {
                              setState(() {
                                _exerciseFrequency = value;
                              });
                            },
                          ),
                          Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Sleep Quality & Stress Level
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '수면 품질',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sleepQuality,
                decoration: InputDecoration(
                  hintText: '수면 품질을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5),
                ),
                items: _sleepQualities.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sleepQuality = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                '스트레스 수준',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _stressLevel,
                decoration: InputDecoration(
                  hintText: '스트레스 수준을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5),
                ),
                items: _stressLevels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _stressLevel = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Chronic Condition
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '만성 질환이 있으신가요?',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              Switch(
                value: _hasChronicCondition,
                onChanged: (value) {
                  setState(() {
                    _hasChronicCondition = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    // Add health-specific sections to the base result
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildBiorhythmChart(),
        _buildBodyHealthIndex(),
        _buildWellnessRecommendations(),
        _buildDietaryAdvice(),
        _buildExerciseRecommendations(),
      ],
    );
  }

  Widget _buildBiorhythmChart() {
    final theme = Theme.of(context);
    
    // Generate biorhythm data
    final days = List.generate(30, (index) => index);
    final physicalData = days.map((day) => 
      FlSpot(day.toDouble(), 50 + 50 * math.sin(2 * math.pi * day / 23))).toList();
    final emotionalData = days.map((day) => 
      FlSpot(day.toDouble(), 50 + 50 * math.sin(2 * math.pi * day / 28))).toList();
    final intellectualData = days.map((day) => 
      FlSpot(day.toDouble(), 50 + 50 * math.sin(2 * math.pi * day / 33))).toList();
    
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
                  Icons.show_chart_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '바이오리듬',
                  style: theme.textTheme.headlineSmall,
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
                    horizontalInterval: 25,
                    verticalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
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
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 == 0) {
                            return Text(
                              '${value.toInt()}일',
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    // Physical
                    LineChartBarData(
                      spots: physicalData,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    // Emotional
                    LineChartBarData(
                      spots: emotionalData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    // Intellectual
                    LineChartBarData(
                      spots: intellectualData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('신체', Colors.red),
                _buildLegendItem('감정', Colors.blue),
                _buildLegendItem('지성', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBodyHealthIndex() {
    final theme = Theme.of(context);
    
    final bodyParts = [
      {'part': '머리', 'score': 85, 'icon': Icons.face_rounded},
      {'part': '심장', 'score': 90, 'icon': Icons.favorite_rounded},
      {'part': '폐', 'score': 75, 'icon': Icons.air_rounded},
      {'part': '위장', 'score': 70, 'icon': Icons.restaurant_rounded},
      {'part': '간', 'score': 80, 'icon': Icons.local_drink_rounded},
      {'part': '근육', 'score': 65, 'icon': Icons.fitness_center_rounded},
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
                  Icons.healing_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '신체 부위별 건강 지수',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: bodyParts.map((item) {
                final score = item['score'] as int;
                final color = _getHealthColor(score);
                
                return GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  blur: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 24,
                        color: color,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['part'] as String,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildWellnessRecommendations() {
    final theme = Theme.of(context);
    
    final recommendations = [
      {
        'title': '수분 섭취',
        'description': '하루 8잔 이상의 물을 마시세요',
        'icon': Icons.water_drop_rounded,
      },
      {
        'title': '스트레칭',
        'description': '1시간마다 5분씩 스트레칭하세요',
        'icon': Icons.self_improvement_rounded,
      },
      {
        'title': '명상',
        'description': '하루 10분 명상으로 마음을 안정시키세요',
        'icon': Icons.spa_rounded,
      },
      {
        'title': '수면',
        'description': '7-8시간의 충분한 수면을 취하세요',
        'icon': Icons.bedtime_rounded,
      },
    ];
    
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
                  Icons.recommend_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '건강 관리 추천',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['description'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
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

  Widget _buildDietaryAdvice() {
    final theme = Theme.of(context);
    
    final foods = {
      'recommended': [
        {'name': '녹차', 'benefit': '항산화 효과'},
        {'name': '블루베리', 'benefit': '면역력 강화'},
        {'name': '연어', 'benefit': '오메가3 풍부'},
        {'name': '브로콜리', 'benefit': '비타민 공급'},
      ],
      'avoid': [
        {'name': '가공식품', 'reason': '염분 과다'},
        {'name': '탄산음료', 'reason': '당분 과다'},
        {'name': '튀긴 음식', 'reason': '트랜스지방'},
      ],
    };
    
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
                  Icons.restaurant_menu_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '식단 조언',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '추천 음식',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...(foods['recommended'] as List).map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(food['name'] as String),
                  const Text(' - '),
                  Text(
                    food['benefit'] as String,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            Text(
              '피해야 할 음식',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...(foods['avoid'] as List).map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.cancel, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(food['name'] as String),
                  const Text(' - '),
                  Text(
                    food['reason'] as String,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildExerciseRecommendations() {
    final theme = Theme.of(context);
    
    final exercises = [
      {'type': '유산소 운동', 'duration': '30분/일', 'frequency': '주 5회'},
      {'type': '근력 운동', 'duration': '20분/일', 'frequency': '주 3회'},
      {'type': '요가/필라테스', 'duration': '40분/일', 'frequency': '주 2회'},
      {'type': '산책', 'duration': '15분/일', 'frequency': '매일'},
    ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_run_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '운동 추천',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...exercises.map((exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise['type'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise['duration'] as String,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise['frequency'] as String,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}