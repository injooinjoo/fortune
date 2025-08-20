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
import '../../../../core/utils/korean_holidays.dart';

class DailyCalendarFortunePage extends BaseFortunePage {
  const DailyCalendarFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '특정일 운세',
          description: '선택한 날짜의 전체적인 운세를 확인하세요',
          fortuneType: 'daily_calendar',
          requiresUserInfo: false,
          initialParams: initialParams,
        );

  @override
  ConsumerState<DailyCalendarFortunePage> createState() => _DailyCalendarFortunePageState();
}

class _DailyCalendarFortunePageState extends BaseFortunePageState<DailyCalendarFortunePage> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedHour;
  String? _holidayName;
  String? _specialName;
  bool _isHoliday = false;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    final userId = ref.read(userProvider).value?.id ?? 'anonymous';
    
    // Use getTimeFortune with daily period for date-based fortune
    return await fortuneService.getTimeFortune(
      userId: userId,
      fortuneType: 'daily_calendar',
      params: {
        'period': 'daily',
        'date': _selectedDate.toIso8601String(),
        'isHoliday': _isHoliday,
        'holidayName': _holidayName,
        'specialName': _specialName,
        'selectedDateFormatted': DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDate),
        ...params,
      }
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    // Get selected date from navigation parameters
    if (widget.initialParams != null) {
      final selectedDateStr = widget.initialParams!['selectedDate'] as String?;
      if (selectedDateStr != null) {
        _selectedDate = DateTime.parse(selectedDateStr);
      }
      
      final fortuneParams = widget.initialParams?['fortuneParams'] as Map<String, dynamic>? ?? {};
      _isHoliday = fortuneParams['isHoliday'] as bool? ?? false;
      _holidayName = fortuneParams['holidayName'] as String?;
      _specialName = fortuneParams['specialName'] as String?;
    }
    
    return {
      'date': _selectedDate.toIso8601String(),
      'isHoliday': _isHoliday,
      'holidayName': _holidayName,
      'specialName': _specialName,
      'selectedDateFormatted': DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDate),
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Selected Date Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '선택된 날짜',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(_selectedDate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (_holidayName != null || _specialName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _holidayName != null
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _holidayName ?? _specialName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _holidayName != null
                                ? Colors.red
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '선택한 날짜의 전반적인 운세와 시간대별 가이드를 확인할 수 있습니다',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    // Add daily-specific sections to the base result with SingleChildScrollView
    return SingleChildScrollView(
      child: Column(
        children: [
          super.buildFortuneResult(),
          _buildDateSummary(),
          _buildLuckyHours(),
          _buildActivityRecommendations()
        ]
      ),
    );
  }

  Widget _buildDateSummary() {
    final theme = Theme.of(context);
    
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
                  Icons.today_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(_selectedDate)} 운세 요약',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildOverallScore(),
            const SizedBox(height: 16),
            if (_holidayName != null || _specialName != null)
              _buildSpecialDayInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScore() {
    final theme = Theme.of(context);
    
    // 모의 점수 생성 (실제로는 API에서 받아올 것)
    final overallScore = 75 + (DateTime.now().millisecond % 25);
    final luckScore = 60 + (DateTime.now().millisecond % 40);
    final healthScore = 70 + (DateTime.now().millisecond % 30);
    final workScore = 80 + (DateTime.now().millisecond % 20);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildScoreCard('전체 운세', overallScore, theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard('행운도', luckScore, Colors.amber),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildScoreCard('건강 운세', healthScore, Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard('업무 운세', workScore, Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(String title, int score, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score점',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialDayInfo() {
    final theme = Theme.of(context);
    final info = _holidayName ?? _specialName!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _holidayName != null
            ? Colors.red.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _holidayName != null
              ? Colors.red.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _holidayName != null ? Icons.celebration : Icons.star,
            color: _holidayName != null ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '특별한 날',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _holidayName != null ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildLuckyHours() {
    final theme = Theme.of(context);
    
    final luckyHours = [
      {'time': '09:00-10:00', 'activity': '중요한 결정', 'score': 95},
      {'time': '14:00-15:00', 'activity': '창의적 작업', 'score': 88},
      {'time': '19:00-20:00', 'activity': '사교 활동', 'score': 92},
      {'time': '22:00-23:00', 'activity': '명상/휴식', 'score': 85}
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
                  Icons.star_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 행운 시간대',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...luckyHours.map((hour) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.1)
                    ]
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3)
                  )
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hour['time'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hour['activity'] as String,
                        style: theme.textTheme.bodyMedium
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getScoreColor(hour['score'] as int).withOpacity(0.2),
                        shape: BoxShape.circle
                      ),
                      child: Text(
                        '${hour['score']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ]
                )
                )
              )
            ).toList()
          ]
        )
      )
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
        'period': '새벽 (00:00-06:00)', 'icon': Icons.nightlight_round,
        'activities': ['깊은 수면', '명상', '일기 쓰기'],
        'color': Colors.indigo
      },
      {
        'period': '아침 (06:00-12:00)', 'icon': Icons.wb_sunny,
        'activities': ['운동', '중요한 업무', '학습'],
        'color': Colors.orange
      },
      {
        'period': '오후 (12:00-18:00)', 'icon': Icons.wb_twilight,
        'activities': ['미팅', '창의적 작업', '네트워킹'],
        'color': Colors.amber
      },
      {
        'period': '저녁 (18:00-24:00)', 'icon': Icons.nights_stay,
        'activities': ['가족 시간', '취미 활동', '휴식'],
        'color': Colors.purple
      }
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
                  Icons.schedule_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '시간대별 추천 활동',
                  style: theme.textTheme.headlineSmall
                )
              ]
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
                      color: (slot['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Icon(
                      slot['icon'] as IconData,
                      size: 24,
                      color: slot['color'] as Color
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['period'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: (slot['activities'] as List<String>).map((activity) {
                            return Chip(
                              label: Text(
                                activity,
                                style: theme.textTheme.bodySmall
                              ),
                              backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 8)
                            );
                          }).toList()
                        )
                      ]
                    )
                  )
                ]
              )
            )).toList()
          ]
        )
      )
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