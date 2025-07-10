import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import 'package:fl_chart/fl_chart.dart';

class NetworkReportPage extends ConsumerWidget {
  const NetworkReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '인맥 리포트',
      fortuneType: 'network-report',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      ),
      inputBuilder: (context, onSubmit) => _NetworkReportInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _NetworkReportResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _NetworkReportInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _NetworkReportInputForm({required this.onSubmit});

  @override
  State<_NetworkReportInputForm> createState() => _NetworkReportInputFormState();
}

class _NetworkReportInputFormState extends State<_NetworkReportInputForm> {
  String? _selectedInterestArea;
  String? _selectedNetworkStatus;
  String? _selectedGoal;
  final _challengeController = TextEditingController();

  final List<String> _interestAreas = ['비즈니스', '학업', '취미', '연애', '가족', '친구'];
  final List<String> _networkStatuses = ['매우 좁음', '좁음', '보통', '넓음', '매우 넓음'];
  final List<String> _networkGoals = [
    '새로운 인맥 확장',
    '기존 인맥 강화',
    '전문 네트워크 구축',
    '멘토/멘티 찾기',
    '비즈니스 파트너 찾기'
  ];

  @override
  void dispose() {
    _challengeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 인간관계를 분석하고 개선 방안을 제시합니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Interest Area Selection
        Text(
          '주요 관심 분야',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedInterestArea,
          decoration: InputDecoration(
            hintText: '관심 분야를 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _interestAreas.map((area) {
            return DropdownMenuItem(
              value: area,
              child: Text(area),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedInterestArea = value;
            });
          },
        ),
        const SizedBox(height: 20),
        
        // Network Status
        Text(
          '현재 인맥 상태',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedNetworkStatus,
          decoration: InputDecoration(
            hintText: '인맥 상태를 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _networkStatuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedNetworkStatus = value;
            });
          },
        ),
        const SizedBox(height: 20),
        
        // Network Goal
        Text(
          '인맥 관리 목표',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedGoal,
          decoration: InputDecoration(
            hintText: '목표를 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _networkGoals.map((goal) {
            return DropdownMenuItem(
              value: goal,
              child: Text(goal),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGoal = value;
            });
          },
        ),
        const SizedBox(height: 20),
        
        // Current Challenge
        Text(
          '현재 인맥 관련 고민',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _challengeController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '인맥 관련 고민이나 어려움을 자유롭게 작성해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedInterestArea == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('관심 분야를 선택해주세요')),
                );
                return;
              }
              if (_selectedNetworkStatus == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('인맥 상태를 선택해주세요')),
                );
                return;
              }
              
              widget.onSubmit({
                'interestArea': _selectedInterestArea,
                'networkStatus': _selectedNetworkStatus,
                'goal': _selectedGoal ?? '새로운 인맥 확장',
                'challenge': _challengeController.text,
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              '인맥 리포트 확인하기',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkReportResult extends ConsumerStatefulWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _NetworkReportResult({
    required this.result,
    required this.onShare,
  });

  @override
  ConsumerState<_NetworkReportResult> createState() => _NetworkReportResultState();
}

class _NetworkReportResultState extends ConsumerState<_NetworkReportResult> {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    // Extract data from result
    final networkScore = widget.result.overallScore ?? 0;
    final networkAnalysis = widget.result.additionalInfo?['networkAnalysis'] ?? {};
    final strengths = widget.result.additionalInfo?['strengths'] as List<dynamic>? ?? [];
    final weaknesses = widget.result.additionalInfo?['weaknesses'] as List<dynamic>? ?? [];
    final opportunities = widget.result.additionalInfo?['opportunities'] as List<dynamic>? ?? [];
    final strategies = widget.result.additionalInfo?['strategies'] as List<dynamic>? ?? [];
    final chartData = widget.result.additionalInfo?['chartData'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Network Score Card
        GlassContainer(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  '인맥 지수',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$networkScore점',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 56 + _getFontSizeOffset(fontSize),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreDescription(networkScore),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Network Analysis Chart
        if (chartData.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인맥 분석 차트',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        radarBorderData: const BorderSide(color: Colors.transparent),
                        gridBorderData: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 1),
                        tickBorderData: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 1),
                        titleTextStyle: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        tickCount: 5,
                        dataSets: [
                          RadarDataSet(
                            fillColor: theme.colorScheme.primary.withOpacity(0.3),
                            borderColor: theme.colorScheme.primary,
                            borderWidth: 2,
                            dataEntries: _getRadarDataEntries(chartData),
                          ),
                        ],
                        getTitle: (index, angle) {
                          final titles = ['깊이', '다양성', '신뢰도', '활발함', '성장성'];
                          return RadarChartTitle(text: titles[index % titles.length]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Main Analysis
        if (widget.result.mainFortune != null) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '종합 분석',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.result.mainFortune!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 16 + _getFontSizeOffset(fontSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Strengths
        if (strengths.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '강점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...strengths.map((strength) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strength.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14 + _getFontSizeOffset(fontSize),
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
        
        // Weaknesses
        if (weaknesses.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '개선점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...weaknesses.map((weakness) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            weakness.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14 + _getFontSizeOffset(fontSize),
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
        
        // Opportunities
        if (opportunities.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '기회',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...opportunities.map((opportunity) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        opportunity.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14 + _getFontSizeOffset(fontSize),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Strategies
        if (strategies.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rocket_launch, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        '전략 제안',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...strategies.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14 + _getFontSizeOffset(fontSize),
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
          child: OutlinedButton.icon(
            onPressed: widget.onShare,
            icon: const Icon(Icons.share),
            label: const Text('리포트 공유하기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  List<RadarEntry> _getRadarDataEntries(Map<String, dynamic> chartData) {
    return [
      RadarEntry(value: (chartData['depth'] ?? 0).toDouble()),
      RadarEntry(value: (chartData['diversity'] ?? 0).toDouble()),
      RadarEntry(value: (chartData['trust'] ?? 0).toDouble()),
      RadarEntry(value: (chartData['activity'] ?? 0).toDouble()),
      RadarEntry(value: (chartData['growth'] ?? 0).toDouble()),
    ];
  }
  
  String _getScoreDescription(int score) {
    if (score >= 90) return '매우 우수한 인맥 관리 능력';
    if (score >= 80) return '우수한 인맥 관리 능력';
    if (score >= 70) return '양호한 인맥 관리 수준';
    if (score >= 60) return '평균적인 인맥 관리 수준';
    if (score >= 50) return '개선이 필요한 인맥 관리';
    return '적극적인 개선이 필요함';
  }
}