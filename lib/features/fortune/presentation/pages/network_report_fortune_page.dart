import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import '../../../../core/theme/typography_unified.dart';

class NetworkReportFortunePage extends ConsumerWidget {
  const NetworkReportFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '인맥 리포트',
      fortuneType: 'network-report',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
      inputBuilder: (context, onSubmit) => _NetworkReportInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _NetworkReportFortuneResult(
        result: result,
        onShare: onShare));
  }
}

class _NetworkReportInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _NetworkReportInputForm({required this.onSubmit});

  @override
  State<_NetworkReportInputForm> createState() => _NetworkReportInputFormState();
}

class _NetworkReportInputFormState extends State<_NetworkReportInputForm> {
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedMbti;
  String? _selectedNetworkingStyle;
  final List<String> _selectedInterests = [];
  
  final List<String> _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];
  
  final List<String> _networkingStyles = [
    '적극적 네트워커',
    '선택적 네트워커',
    '자연스러운 만남 선호',
    '온라인 네트워킹 선호',
    '소규모 모임 선호',
    '대규모 행사 선호',
  ];
  
  final List<String> _interests = [
    '비즈니스',
    '기술/IT',
    '예술/문화',
    '스포츠/건강',
    '교육/학습',
    '여행/레저',
    '투자/재테크',
    '봉사/사회공헌',
    '음식/요리',
    '패션/뷰티',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF4FACFE),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(
            '당신의 인맥 운세를 분석하고\n네트워킹 전략을 제시해드립니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.8),
              height: 1.5)),
          SizedBox(height: 24),
          // Name Input
          Text(
            '이름',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Birth Date Selection
          Text(
            '생년월일',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha:0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary.withValues(alpha:0.7)),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                      : '생년월일을 선택하세요',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _birthDate != null 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurface.withValues(alpha:0.5),
                  ),
                ),
              ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Job Input
          Text(
            '직업/직무',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _jobController,
            decoration: InputDecoration(
              hintText: '예: 마케팅 매니저, 개발자, 디자이너',
              prefixIcon: const Icon(Icons.work_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
            ),
          ),
          SizedBox(height: 20),
          // MBTI Selection
          Text(
            'MBTI 유형',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _mbtiTypes.length,
              itemBuilder: (context, index) {
                final mbti = _mbtiTypes[index];
                final isSelected = _selectedMbti == mbti;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMbti = mbti;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary.withValues(alpha:0.2)
                          : theme.colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha:0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        mbti,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Networking Style Selection
          Text(
            '네트워킹 스타일',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _networkingStyles.map((style) {
              final isSelected = _selectedNetworkingStyle == style;
              return ChoiceChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedNetworkingStyle = selected ? style : null;
                  });
                },
                selectedColor: theme.colorScheme.primary.withValues(alpha:0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          // Interests Selection
          Text(
            '관심 분야 (복수 선택 가능)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                selectedColor: theme.colorScheme.secondary.withValues(alpha:0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
              const SizedBox(height: 32),
              
              // 하단 버튼 공간만큼 여백 추가
              const BottomButtonSpacing(),
            ],
          ),
        ),
        
        // Floating 버튼
        TossFloatingProgressButtonPositioned(
          text: '인맥 리포트 확인하기',
          isEnabled: true,
          showProgress: false,
          isVisible: true,
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이름을 입력해주세요')),
              );
              return;
            }
            if (_birthDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('생년월일을 선택해주세요')),
              );
              return;
            }
            if (_jobController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('직업을 입력해주세요')),
              );
              return;
            }
            
            widget.onSubmit({
              'name': _nameController.text,
              'birthDate': _birthDate!.toIso8601String(),
              'job': _jobController.text,
              'mbti': _selectedMbti ?? 'INFP',
              'networkingStyle': _selectedNetworkingStyle ?? '자연스러운 만남 선호',
              'interests': _selectedInterests.isEmpty ? ['비즈니스'] : _selectedInterests,
            });
          },
          style: TossButtonStyle.primary,
          size: TossButtonSize.large,
        ),
      ],
    );
  }
}

class _NetworkReportFortuneResult extends ConsumerWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _NetworkReportFortuneResult({
    required this.result,
    required this.onShare});

  double _getFontSizeOffset(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return -2.0;
      case FontSize.medium:
        return 0.0;
      case FontSize.large:
        return 2.0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Extract network data from result
    final networkScore = result.overallScore ?? 75;
    final networkTypes = result.additionalInfo?['networkTypes'] ?? {};
    final keyPeople = result.additionalInfo?['keyPeople'] ?? [];
    final networkingTips = result.recommendations ?? [];
    final monthlyForecast = result.additionalInfo?['monthlyForecast'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Network Score Card
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people_alt,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '인맥 운세 점수',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$networkScore점',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: _getScoreColor(networkScore),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24 + fontSize,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getScoreMessage(networkScore),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Network Score Gauge
                SizedBox(
                  height: 180,
                  child: _buildNetworkGauge(networkScore, theme),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Network Types Analysis
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart,
                      color: TossDesignSystem.purple,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '인맥 유형 분석',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildNetworkTypesChart(networkTypes, theme),
                ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: networkTypes.entries.map((entry) {
                    final color = _getTypeColor(entry.key);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.key}: ${entry.value}%',
                          style: theme.textTheme.bodySmall),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Key People to Meet
        if (keyPeople.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: TossDesignSystem.warningOrange,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '주목해야 할 인맥',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...keyPeople.map((person) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha:0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withValues(alpha:0.1),
                            child: Text(
                              person['initial'] ?? '?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person['type'] ?? '',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14 + fontSize,
                                  ),
                                ),
                                if (person['description'] != null)
                                  Text(
                                    person['description'],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                                      fontSize: 12 + fontSize,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Monthly Networking Forecast
        if (monthlyForecast.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timeline,
                        color: TossDesignSystem.primaryBlue,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '월별 인맥 운세',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildMonthlyChart(monthlyForecast, theme),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Networking Tips
        if (networkingTips.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: TossDesignSystem.successGreen,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '네트워킹 전략',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...networkingTips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              fontSize: 14 + fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Share Button
        Center(
          child: TossButton(
            text: '운세 공유하기',
            onPressed: onShare,
            style: TossButtonStyle.ghost,
            size: TossButtonSize.medium,
            icon: Icon(Icons.share),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNetworkGauge(int score, ThemeData theme) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(
            value: score.toDouble(),
            color: _getScoreColor(score),
            radius: 20,
            showTitle: false),
          PieChartSectionData(
            value: (100 - score).toDouble(),
            color: theme.colorScheme.outline.withValues(alpha:0.1),
            radius: 20,
            showTitle: false)]));
  }
  
  Widget _buildNetworkTypesChart(Map<String, dynamic> types, ThemeData theme) {
    final List<PieChartSectionData> sections = [];

    types.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: (value as num).toDouble(),
          color: _getTypeColor(key),
          radius: 50,
          title: '$value%',
          titleStyle: TypographyUnified.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.white,
          ),
        ),
      );
    });
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
  
  Widget _buildMonthlyChart(Map<String, dynamic> forecast, ThemeData theme) {
    final List<BarChartGroupData> barGroups = [];
    int index = 0;
    
    forecast.forEach((month, score) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (score as num).toDouble(),
              color: theme.colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
      index++;
    });
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha:0.1),
              strokeWidth: 1
            );
          }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TypographyUnified.labelTiny);
              })),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = forecast.keys.toList();
                if (value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: TypographyUnified.labelTiny,
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.success;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.error;
  }
  
  String _getScoreMessage(int score) {
    if (score >= 80) return '매우 좋음';
    if (score >= 60) return '좋음';
    if (score >= 40) return '보통';
    return '주의 필요';
  }
  
  Color _getTypeColor(String type) {
    final colors = [
      TossDesignSystem.tossBlue,
      TossDesignSystem.purple,
      TossDesignSystem.success,
      TossDesignSystem.warningOrange,
      TossDesignSystem.pinkPrimary,
      TossDesignSystem.tossBlue,
      TossDesignSystem.warningYellow,
      TossDesignSystem.tossBlue];
    
    final index = type.hashCode % colors.length;
    return colors[index];
  }
}