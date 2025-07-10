import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/components/toast.dart';

class BiorhythmFortunePage extends ConsumerWidget {
  const BiorhythmFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '바이오리듬',
      fortuneType: 'biorhythm',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      inputBuilder: (context, onSubmit) => _BiorhythmInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _BiorhythmFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _BiorhythmInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _BiorhythmInputForm({required this.onSubmit});

  @override
  State<_BiorhythmInputForm> createState() => _BiorhythmInputFormState();
}

class _BiorhythmInputFormState extends State<_BiorhythmInputForm> {
  DateTime? _birthDate;
  DateTime _targetDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '신체, 감성, 지성의 리듬을 분석하여\n최적의 컨디션을 확인해보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Birth Date Selection
        Text(
          '생년월일',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              locale: const Locale('ko', 'KR'),
            );
            if (date != null) {
              setState(() {
                _birthDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _birthDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Target Date Selection
        Text(
          '분석할 날짜',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _targetDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('ko', 'KR'),
            );
            if (date != null) {
              setState(() {
                _targetDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_targetDate.year}년 ${_targetDate.month}월 ${_targetDate.day}일',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Biorhythm Explanation
        ShimmerGlass(
          shimmerColor: const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '바이오리듬이란?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '생체 리듬의 주기적 변화를 분석하여 신체(23일), 감정(28일), 지적(33일) 상태를 예측하는 이론입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRhythmInfo(theme, '신체 리듬', '23일', Colors.red),
                const SizedBox(height: 8),
                _buildRhythmInfo(theme, '감정 리듬', '28일', Colors.blue),
                const SizedBox(height: 8),
                _buildRhythmInfo(theme, '지적 리듬', '33일', Colors.green),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _birthDate != null
                ? () {
                    widget.onSubmit({
                      'birthDate': _birthDate!.toIso8601String(),
                      'targetDate': _targetDate.toIso8601String(),
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '바이오리듬 분석하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRhythmInfo(ThemeData theme, String name, String cycle, Color color) {
    return Row(
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
          name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($cycle 주기)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _BiorhythmFortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _BiorhythmFortuneResult({
    required this.result,
    required this.onShare,
  });

  // Biorhythm calculation constants
  static const int physicalCycle = 23;
  static const int emotionalCycle = 28;
  static const int intellectualCycle = 33;

  double calculateBiorhythm(int daysSinceBirth, int cycleLength) {
    return math.sin(2 * math.pi * daysSinceBirth / cycleLength);
  }

  Map<String, double> calculateBiorhythms(DateTime birthDate, DateTime targetDate) {
    final daysSinceBirth = targetDate.difference(birthDate).inDays;
    
    return {
      'physical': calculateBiorhythm(daysSinceBirth, physicalCycle),
      'emotional': calculateBiorhythm(daysSinceBirth, emotionalCycle),
      'intellectual': calculateBiorhythm(daysSinceBirth, intellectualCycle),
    };
  }

  List<FlSpot> generateChartData(DateTime birthDate, DateTime startDate, int cycleLength, int daysToShow) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < daysToShow; i++) {
      final date = startDate.add(Duration(days: i));
      final daysSinceBirth = date.difference(birthDate).inDays;
      final value = calculateBiorhythm(daysSinceBirth, cycleLength);
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Extract dates from result
    final birthDate = DateTime.parse(result.details?['birthDate'] ?? DateTime(1990).toIso8601String());
    final targetDate = DateTime.parse(result.details?['targetDate'] ?? DateTime.now().toIso8601String());
    
    // Calculate biorhythms
    final biorhythms = calculateBiorhythms(birthDate, targetDate);
    final physicalPercent = ((biorhythms['physical']! + 1) * 50).round();
    final emotionalPercent = ((biorhythms['emotional']! + 1) * 50).round();
    final intellectualPercent = ((biorhythms['intellectual']! + 1) * 50).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(20),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.timeline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '바이오리듬 분석',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${targetDate.year}년 ${targetDate.month}월 ${targetDate.day}일',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  result.mainFortune ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Current Status Card
        GlassContainer(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.speed_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '현재 바이오리듬 상태',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRhythmIndicator(context, '신체', physicalPercent, Colors.red),
              const SizedBox(height: 12),
              _buildRhythmIndicator(context, '감정', emotionalPercent, Colors.blue),
              const SizedBox(height: 12),
              _buildRhythmIndicator(context, '지적', intellectualPercent, Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Biorhythm Chart
        GlassContainer(
          borderRadius: BorderRadius.circular(16),
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
                    '7일간 바이오리듬 예측',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 0.5,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        if (value == 0) {
                          return FlLine(
                            color: theme.colorScheme.outline,
                            strokeWidth: 2,
                          );
                        }
                        return FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final date = targetDate.add(Duration(days: value.toInt()));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.month}/${date.day}',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 0.5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: theme.textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    minX: 0,
                    maxX: 6,
                    minY: -1.2,
                    maxY: 1.2,
                    lineBarsData: [
                      // Physical rhythm
                      LineChartBarData(
                        spots: generateChartData(birthDate, targetDate, physicalCycle, 7),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.red,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withOpacity(0.1),
                        ),
                      ),
                      // Emotional rhythm
                      LineChartBarData(
                        spots: generateChartData(birthDate, targetDate, emotionalCycle, 7),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blue,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                      // Intellectual rhythm
                      LineChartBarData(
                        spots: generateChartData(birthDate, targetDate, intellectualCycle, 7),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.green,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('신체', Colors.red),
                  _buildLegendItem('감정', Colors.blue),
                  _buildLegendItem('지적', Colors.green),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Analysis Details
        if (result.details?['analysis'] != null) ...[
          _buildAnalysisCard(
            context,
            title: '신체 리듬 분석',
            icon: Icons.fitness_center_rounded,
            color: Colors.red,
            status: result.details!['analysis']['physical']['status'] ?? '',
            description: result.details!['analysis']['physical']['description'] ?? '',
            advice: result.details!['analysis']['physical']['advice'] ?? '',
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            context,
            title: '감정 리듬 분석',
            icon: Icons.favorite_rounded,
            color: Colors.blue,
            status: result.details!['analysis']['emotional']['status'] ?? '',
            description: result.details!['analysis']['emotional']['description'] ?? '',
            advice: result.details!['analysis']['emotional']['advice'] ?? '',
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            context,
            title: '지적 리듬 분석',
            icon: Icons.psychology_rounded,
            color: Colors.green,
            status: result.details!['analysis']['intellectual']['status'] ?? '',
            description: result.details!['analysis']['intellectual']['description'] ?? '',
            advice: result.details!['analysis']['intellectual']['advice'] ?? '',
          ),
          const SizedBox(height: 16),
        ],

        // Best and Caution Days
        if (result.details?['bestDays'] != null || result.details?['cautionDays'] != null) ...[
          GlassContainer(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '주요 일정 가이드',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (result.details?['bestDays'] != null) ...[
                  _buildDaysList(
                    context,
                    title: '최적의 날',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    days: List<String>.from(result.details!['bestDays']),
                    description: '중요한 일정이나 새로운 도전에 좋은 시기입니다.',
                  ),
                  const SizedBox(height: 12),
                ],
                if (result.details?['cautionDays'] != null) ...[
                  _buildDaysList(
                    context,
                    title: '주의할 날',
                    icon: Icons.warning_rounded,
                    color: Colors.orange,
                    days: List<String>.from(result.details!['cautionDays']),
                    description: '휴식을 취하고 무리한 일정은 피하는 것이 좋습니다.',
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRhythmIndicator(BuildContext context, String label, int percentage, Color color) {
    final theme = Theme.of(context);
    final isPositive = percentage > 50;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String status,
    required String description,
    required String advice,
  }) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysList(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> days,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days.map((day) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'high':
        return '최고';
      case 'medium':
        return '양호';
      case 'low':
        return '주의';
      case 'critical':
        return '위험';
      default:
        return status;
    }
  }
}