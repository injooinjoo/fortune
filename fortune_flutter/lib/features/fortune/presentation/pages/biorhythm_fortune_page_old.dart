import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class BiorhythmFortunePage extends BaseFortunePage {
  const BiorhythmFortunePage({super.key})
      : super(
          title: '바이오리듬',
          description: '당신의 신체, 감성, 지성 리듬을 분석합니다',
          fortuneType: 'biorhythm',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<BiorhythmFortunePage> createState() => _BiorhythmFortunePageState();
}

class _BiorhythmFortunePageState extends BaseFortunePageState<BiorhythmFortunePage> {
  DateTime? _birthDate;
  DateTime _selectedDate = DateTime.now();
  
  // Biorhythm cycles (in days)
  static const int physicalCycle = 23;
  static const int emotionalCycle = 28;
  static const int intellectualCycle = 33;
  static const int intuitionCycle = 38; // Some include a 4th cycle

  @override
  void initState() {
    super.initState();
    _loadBirthDate();
  }

  void _loadBirthDate() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null && userProfile.birthDate != null) {
      setState(() {
        _birthDate = userProfile.birthDate;
      });
    }
  }

  double calculateBiorhythm(int daysSinceBirth, int cycleLength) {
    return math.sin(2 * math.pi * daysSinceBirth / cycleLength);
  }

  Map<String, double> calculateAllBiorhythms(DateTime birthDate, DateTime targetDate) {
    final daysSinceBirth = targetDate.difference(birthDate).inDays;
    
    return {
      'physical': calculateBiorhythm(daysSinceBirth, physicalCycle),
      'emotional': calculateBiorhythm(daysSinceBirth, emotionalCycle),
      'intellectual': calculateBiorhythm(daysSinceBirth, intellectualCycle),
      'intuition': calculateBiorhythm(daysSinceBirth, intuitionCycle),
    };
  }

  List<FlSpot> generateChartData(DateTime birthDate, int cycleLength, int daysToShow) {
    final spots = <FlSpot>[];
    final today = DateTime.now();
    
    for (int i = -daysToShow ~/ 2; i <= daysToShow ~/ 2; i++) {
      final date = today.add(Duration(days: i));
      final daysSinceBirth = date.difference(birthDate).inDays;
      final value = calculateBiorhythm(daysSinceBirth, cycleLength);
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return spots;
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    if (_birthDate == null) {
      throw Exception('생년월일 정보가 필요합니다');
    }

    // Calculate biorhythms
    final biorhythms = calculateAllBiorhythms(_birthDate!, _selectedDate);
    
    // Generate interpretation
    final physicalScore = ((biorhythms['physical']! + 1) * 50).round();
    final emotionalScore = ((biorhythms['emotional']! + 1) * 50).round();
    final intellectualScore = ((biorhythms['intellectual']! + 1) * 50).round();
    final intuitionScore = ((biorhythms['intuition']! + 1) * 50).round();
    
    final overallScore = (physicalScore + emotionalScore + intellectualScore + intuitionScore) ~/ 4;
    
    final description = '''오늘의 바이오리듬 분석 결과입니다.

신체 리듬 (${physicalScore}점): ${_getPhysicalInterpretation(physicalScore)}
감성 리듬 (${emotionalScore}점): ${_getEmotionalInterpretation(emotionalScore)}
지성 리듬 (${intellectualScore}점): ${_getIntellectualInterpretation(intellectualScore)}
직관 리듬 (${intuitionScore}점): ${_getIntuitionInterpretation(intuitionScore)}

종합 분석:
오늘은 전반적으로 ${_getOverallInterpretation(overallScore)} 날입니다.''';

    return Fortune(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      type: 'biorhythm',
      content: description,
      createdAt: DateTime.now(),
      metadata: {
        'physical': physicalScore,
        'emotional': emotionalScore,
        'intellectual': intellectualScore,
        'intuition': intuitionScore,
      },
      overallScore: overallScore,
      category: '바이오리듬',
      description: description,
      scoreBreakdown: {
        'physical': physicalScore,
        'emotional': emotionalScore,
        'intellectual': intellectualScore,
        'intuition': intuitionScore,
      },
      luckyItems: {
        'activity': _getRecommendedActivity(biorhythms),
        'time': _getBestTime(biorhythms),
        'advice': _getDailyAdvice(biorhythms),
      },
      recommendations: [
        _getPhysicalAdvice(physicalScore),
        _getEmotionalAdvice(emotionalScore),
        _getIntellectualAdvice(intellectualScore),
      ],
    );
  }

  String _getPhysicalInterpretation(int score) {
    if (score >= 80) return '신체 에너지가 최고조에 달해 있습니다. 운동이나 활동적인 일에 적합합니다.';
    if (score >= 60) return '신체 상태가 양호합니다. 일상적인 활동에 무리가 없습니다.';
    if (score >= 40) return '평균적인 신체 상태입니다. 무리하지 않는 것이 좋습니다.';
    if (score >= 20) return '신체 에너지가 낮은 편입니다. 충분한 휴식이 필요합니다.';
    return '신체 리듬이 저조합니다. 무리한 활동은 피하고 휴식을 취하세요.';
  }

  String _getEmotionalInterpretation(int score) {
    if (score >= 80) return '감정이 매우 안정적이고 긍정적입니다. 대인관계에 적극적으로 임하세요.';
    if (score >= 60) return '감정 상태가 양호합니다. 원만한 대인관계가 가능합니다.';
    if (score >= 40) return '평범한 감정 상태입니다. 급격한 감정 변화에 주의하세요.';
    if (score >= 20) return '감정이 다소 불안정할 수 있습니다. 스트레스 관리가 필요합니다.';
    return '감정 기복이 클 수 있습니다. 중요한 결정은 미루는 것이 좋습니다.';
  }

  String _getIntellectualInterpretation(int score) {
    if (score >= 80) return '두뇌 활동이 매우 활발합니다. 학습이나 창의적 작업에 최적입니다.';
    if (score >= 60) return '지적 능력이 양호합니다. 집중력이 좋은 상태입니다.';
    if (score >= 40) return '평균적인 지적 상태입니다. 일반적인 업무 수행에 무리가 없습니다.';
    if (score >= 20) return '집중력이 다소 떨어질 수 있습니다. 중요한 결정은 신중히 하세요.';
    return '지적 활동이 저조합니다. 복잡한 일은 피하고 단순한 작업을 하세요.';
  }

  String _getIntuitionInterpretation(int score) {
    if (score >= 80) return '직관력이 매우 뛰어납니다. 영감과 창의성이 샘솟습니다.';
    if (score >= 60) return '직관이 예민한 상태입니다. 새로운 아이디어가 떠오를 수 있습니다.';
    if (score >= 40) return '평균적인 직관 상태입니다. 논리적 사고와 균형을 맞추세요.';
    if (score >= 20) return '직관보다는 논리적 판단이 필요한 시기입니다.';
    return '직관력이 둔한 상태입니다. 중요한 선택은 충분한 정보를 바탕으로 하세요.';
  }

  String _getOverallInterpretation(int score) {
    if (score >= 80) return '매우 좋은';
    if (score >= 60) return '좋은';
    if (score >= 40) return '평범한';
    if (score >= 20) return '주의가 필요한';
    return '휴식이 필요한';
  }

  String _getRecommendedActivity(Map<String, double> biorhythms) {
    final physical = biorhythms['physical']!;
    final intellectual = biorhythms['intellectual']!;
    
    if (physical > 0.5 && intellectual > 0.5) return '운동과 학습을 병행하기 좋은 날';
    if (physical > 0.5) return '활발한 신체 활동이 권장되는 날';
    if (intellectual > 0.5) return '독서나 학습에 집중하기 좋은 날';
    return '가벼운 산책과 명상이 도움이 되는 날';
  }

  String _getBestTime(Map<String, double> biorhythms) {
    final emotional = biorhythms['emotional']!;
    if (emotional > 0.5) return '오전 중 활동이 효과적';
    return '오후나 저녁 시간 활용 권장';
  }

  String _getDailyAdvice(Map<String, double> biorhythms) {
    final avg = biorhythms.values.reduce((a, b) => a + b) / biorhythms.length;
    if (avg > 0.5) return '적극적으로 도전하세요';
    if (avg > 0) return '평상심을 유지하세요';
    return '무리하지 말고 휴식하세요';
  }

  String _getPhysicalAdvice(int score) {
    if (score >= 70) return '운동이나 야외 활동을 즐기세요';
    if (score >= 30) return '가벼운 스트레칭으로 몸을 풀어주세요';
    return '충분한 휴식과 수면을 취하세요';
  }

  String _getEmotionalAdvice(int score) {
    if (score >= 70) return '사람들과 적극적으로 교류하세요';
    if (score >= 30) return '감정을 안정적으로 유지하세요';
    return '혼자만의 시간을 가지세요';
  }

  String _getIntellectualAdvice(int score) {
    if (score >= 70) return '새로운 것을 학습하기 좋은 때입니다';
    if (score >= 30) return '일상적인 업무에 집중하세요';
    return '복잡한 일은 미루고 단순한 작업을 하세요';
  }

  @override
  Widget buildFortuneResult() {
    if (_birthDate == null) return const SizedBox.shrink();
    
    final biorhythms = calculateAllBiorhythms(_birthDate!, _selectedDate);
    
    return Column(
      children: [
        // 날짜 선택기
        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // 바이오리듬 차트
        GlassContainer(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.all(20),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.5,
                verticalInterval: 7,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  if (value == 0) {
                    return FlLine(
                      color: Colors.grey,
                      strokeWidth: 2,
                    );
                  }
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
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
                    interval: 7,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('오늘');
                      return Text('${value.toInt()}');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.5,
                    getTitlesWidget: (value, meta) {
                      return Text('${(value * 100).toInt()}%');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: -15,
              maxX: 15,
              minY: -1.2,
              maxY: 1.2,
              lineBarsData: [
                // Physical rhythm
                LineChartBarData(
                  spots: generateChartData(_birthDate!, physicalCycle, 30),
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // Emotional rhythm
                LineChartBarData(
                  spots: generateChartData(_birthDate!, emotionalCycle, 30),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // Intellectual rhythm
                LineChartBarData(
                  spots: generateChartData(_birthDate!, intellectualCycle, 30),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // Intuition rhythm
                LineChartBarData(
                  spots: generateChartData(_birthDate!, intuitionCycle, 30),
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  dashArray: [5, 5],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('신체', Colors.red),
            _buildLegendItem('감성', Colors.blue),
            _buildLegendItem('지성', Colors.green),
            _buildLegendItem('직관', Colors.purple),
          ],
        ),
        const SizedBox(height: 20),
        
        // 현재 상태 표시
        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '현재 바이오리듬 상태',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRhythmIndicator('신체', biorhythms['physical']!, Colors.red),
              const SizedBox(height: 12),
              _buildRhythmIndicator('감성', biorhythms['emotional']!, Colors.blue),
              const SizedBox(height: 12),
              _buildRhythmIndicator('지성', biorhythms['intellectual']!, Colors.green),
              const SizedBox(height: 12),
              _buildRhythmIndicator('직관', biorhythms['intuition']!, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRhythmIndicator(String label, double value, Color color) {
    final percentage = ((value + 1) * 50).round();
    final isPositive = value > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (value + 1) / 2,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}