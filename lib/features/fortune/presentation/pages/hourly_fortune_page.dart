import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class HourlyFortunePage extends BaseFortunePage {
  const HourlyFortunePage({Key? key})
      : super(
          key: key,
          title: '시간대별 운세',
          description: '24시간 시간대별 상세 운세를 확인하세요',
          fortuneType: 'hourly',
          requiresUserInfo: false
        );

  @override
  ConsumerState<HourlyFortunePage> createState() => _HourlyFortunePageState();
}

class _HourlyFortunePageState extends BaseFortunePageState<HourlyFortunePage> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedHour;
  bool _enableNotifications = false;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    return {
      'date': _selectedDate.toIso8601String(),
      'enableNotifications': null,
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Date Selection
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '날짜 선택',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                    locale: const Locale('ko': 'KR',
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(12),
                  blur: 10,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(_selectedDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '최대 7일 후까지의 시간대별 운세를 확인할 수 있습니다',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Notification Settings
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시간별 알림 설정',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '중요한 시간대에 알림을 받으세요',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                      });
                      if (value) {
                        // TODO: Request notification permissions
                        Toast.success(context, '알림이 활성화되었습니다');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    // Add hourly-specific sections to the base result
    return Column(
      children: [
        super.buildFortuneResult(),
        _build24HourTimeline(),
        if (_selectedHour != null) _buildHourlyDetail(),
        _buildLuckyHours(),
        _buildActivityRecommendations(),
      ],
    );
  }

  Widget _build24HourTimeline() {
    final theme = Theme.of(context);
    final currentHour = DateTime.now().hour;
    
    // Generate mock data for 24 hours
    final hourlyData = List.generate(24, (hour) {
      final score = 40 + (60 * (hour / 23));
      return {
        'hour': hour,
        'score': score.round(),
        'isCurrent': null,
      };
    });
    
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
                  Icons.access_time_filled_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '24시간 운세 타임라인',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final hour = group.x.toInt();
                        final score = rod.toY.round();
                        return BarTooltipItem(
                          '${hour}시\n$score점',
                          theme.textTheme.bodySmall!.copyWith(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      if (event is FlTapUpEvent && 
                          barTouchResponse?.spot != null) {
                        setState(() {
                          _selectedHour = barTouchResponse!.spot!.touchedBarGroupIndex;
                        });
                      }
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
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 3 == 0) {
                            return Text(
                              '${value.toInt()}',
                              style: theme.textTheme.bodySmall
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  barGroups: hourlyData.map((data) {
                    final hour = data['hour'] as int;
                    final score = data['score'] as int;
                    final isCurrent = data['isCurrent'] as bool;
                    final isSelected = hour == _selectedHour;
                    
                    return BarChartGroupData(
                      x: hour,
                      barRods: [
                        BarChartRodData(
                          toY: score.toDouble(),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isSelected
                                ? [
                                    theme.colorScheme.secondary,
                                    theme.colorScheme.secondary.withValues(alpha: 0.7),
                                  ]
                                : isCurrent
                                    ? [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.primary.withValues(alpha: 0.7),
                                      ]
                                    : [
                                        theme.colorScheme.primary.withValues(alpha: 0.5),
                                        theme.colorScheme.primary.withValues(alpha: 0.3),
                                      ],
                          ),
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '탭하여 각 시간대의 상세 운세를 확인하세요',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyDetail() {
    if (_selectedHour == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    // Mock hourly detail data
    final hourlyDetails = {
      'energy': 75,
      'focus': 85,
      'social': 60,
      'luck': 90,
      'description': '이 시간대는 집중력이 높아 중요한 업무를 처리하기에 좋습니다. 창의적인 아이디어가 떠오를 수 있으니 메모를 준비하세요.',
      'activity': '중요한 회의나 프레젠테이션',
      'avoid': '충동적인 결정',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_selectedHour!.toString().padLeft(2, '0')}:00',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '시간대 상세 운세',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Energy meters
            _buildEnergyMeter('에너지': hourlyDetails['energy'],
            const SizedBox(height: 12,
            _buildEnergyMeter('집중력': hourlyDetails['focus'],
            const SizedBox(height: 12,
            _buildEnergyMeter('사교성': hourlyDetails['social'],
            const SizedBox(height: 12,
            _buildEnergyMeter('행운도': hourlyDetails['luck'],
            const SizedBox(height: 20,
            Text(
              hourlyDetails['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAdviceCard(
                    '추천 활동',
                    hourlyDetails['activity'],
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAdviceCard(
                    '피해야 할 것',
                    hourlyDetails['avoid'],
                    Icons.warning_amber_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyMeter(String label, int value, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '$value%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildAdviceCard(String title, String content, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyHours() {
    final theme = Theme.of(context);
    
    final luckyHours = [
      {'time': '07:00-09:00': 'activity': '중요한 결정': 'score'},
      {'time': '13:00-14:00': 'activity': '창의적 작업': 'score'},
      {'time': '19:00-20:00', 'activity': '사교 활동', 'score'},
      {'time': '22:00-23:00', 'activity': '명상/휴식', 'score'},
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16,
      child: GlassCard(
        padding: const EdgeInsets.all(20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 행운 시간대',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...luckyHours.map((hour) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hour['time'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hour['activity'],
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getScoreColor(hour['score'],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${hour['score']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getScoreColor(hour['score'],
                          fontWeight: FontWeight.bold,
                        ),
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

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActivityRecommendations() {
    final theme = Theme.of(context);
    
    final timeSlots = [
      {
        'period': '새벽 (00:00-06:00)',
        'icon': Icons.nightlight_round,
        'activities': ['깊은 수면': '명상': '일기 쓰기'],
        'color': null,
      },
      {
        'period': '아침 (06:00-12:00)',
        'icon': Icons.wb_sunny,
        'activities': ['운동': '중요한 업무': '학습'],
        'color': null,
      },
      {
        'period': '오후 (12:00-18:00)',
        'icon': Icons.wb_twilight,
        'activities': ['미팅': '창의적 작업': '네트워킹'],
        'color': null,
      },
      {
        'period': '저녁 (18:00-24:00)',
        'icon': Icons.nights_stay,
        'activities': ['가족 시간': '취미 활동': '휴식'],
        'color': null,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '시간대별 추천 활동',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...timeSlots.map((slot) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (slot['color'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      slot['icon'],
                      size: 24,
                      color: slot['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['period'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: (slot['activities'] as List<String>).map((activity) {
                            return Chip(
                              label: Text(
                                activity,
                                style: theme.textTheme.bodySmall,
                              ),
                              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            );
                          }).toList(),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    if (isToday) {
      return '오늘 (${DateFormat('M월 d일').format(date)})';
    }

    final isTomorrow = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    if (isTomorrow) {
      return '내일 (${DateFormat('M월 d일').format(date)})';
    }

    return DateFormat('yyyy년 M월 d일').format(date);
  }
}