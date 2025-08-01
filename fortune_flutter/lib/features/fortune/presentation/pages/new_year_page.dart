import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import 'package:fl_chart/fl_chart.dart';

class NewYearPage extends ConsumerWidget {
  const NewYearPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '새해 운세',
      fortuneType: 'new-year')
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft)
        end: Alignment.bottomRight)
        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)])
      ),
      inputBuilder: (context, onSubmit) => _NewYearInputForm(onSubmit: onSubmit))
      resultBuilder: (context, result, onShare) => _NewYearResult(
        result: result)
        onShare: onShare)
      )
    );
  }
}

class _NewYearInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _NewYearInputForm({required this.onSubmit});

  @override
  State<_NewYearInputForm> createState() => _NewYearInputFormState();
}

class _NewYearInputFormState extends State<_NewYearInputForm> {
  String? _selectedGoal;
  String? _selectedImportant;
  final _wishController = TextEditingController();

  final List<String> _goals = ['건강', '재물', '사랑', '학업', '직장', '자기계발'];
  final List<String> _importantThings = ['가족', '친구', '연인', '일', '취미', '성장'];

  @override
  void dispose() {
    _wishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '올 한 해 당신의 운세를 확인하세요')
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8))
            height: 1.5)
          ))
        ))
        const SizedBox(height: 24))
        
        // Goal Selection
        Text(
          '올해 목표')
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)
          ))
        ))
        const SizedBox(height: 12))
        DropdownButtonFormField<String>(
          value: _selectedGoal)
          decoration: InputDecoration(
            hintText: '목표를 선택하세요')
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))
            ))
          ))
          items: _goals.map((goal) {
            return DropdownMenuItem(
              value: goal)
              child: Text(goal))
            );
          }).toList())
          onChanged: (value) {
            setState(() {
              _selectedGoal = value;
            });
          },
        ))
        const SizedBox(height: 20))
        
        // Important Thing Selection
        Text(
          '가장 중요한 것')
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)
          ))
        ))
        const SizedBox(height: 12))
        DropdownButtonFormField<String>(
          value: _selectedImportant)
          decoration: InputDecoration(
            hintText: '중요한 것을 선택하세요')
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))
            ))
          ))
          items: _importantThings.map((thing) {
            return DropdownMenuItem(
              value: thing)
              child: Text(thing))
            );
          }).toList())
          onChanged: (value) {
            setState(() {
              _selectedImportant = value;
            });
          },
        ))
        const SizedBox(height: 20))
        
        // Wish Input
        Text(
          '새해 소망')
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)
          ))
        ))
        const SizedBox(height: 12))
        TextField(
          controller: _wishController)
          maxLines: 3)
          decoration: InputDecoration(
            hintText: '올 한 해 이루고 싶은 소망을 적어주세요')
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))
            ))
          ))
        ))
        const SizedBox(height: 32))
        
        // Submit Button
        SizedBox(
          width: double.infinity)
          child: ElevatedButton(
            onPressed: () {
              if (_selectedGoal == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('올해 목표를 선택해주세요')))
                );
                return;
              }
              if (_selectedImportant == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('가장 중요한 것을 선택해주세요')),
                );
                return;
              }
              
              widget.onSubmit({
                'goal': _selectedGoal,
                'important': _selectedImportant,
                'wish': _wishController.text)
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16))
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))
              ))
              backgroundColor: theme.colorScheme.primary)
            ))
            child: Text(
              '새해 운세 확인하기')
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white)
                fontWeight: FontWeight.bold)
              ))
            ))
          ))
        ))
      ]
    );
  }
}

class _NewYearResult extends ConsumerStatefulWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _NewYearResult({
    required this.result,
    required this.onShare,
  });

  @override
  ConsumerState<_NewYearResult> createState() => _NewYearResultState();
}

class _NewYearResultState extends ConsumerState<_NewYearResult> {
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
    final overallScore = widget.result.overallScore ?? 75;
    final monthlyScores = _parseMonthlyScores(widget.result.additionalInfo?['monthly_scores']);
    final seasonalFortune = _parseSeasonalFortune(widget.result.additionalInfo?['seasonal_fortune']);
    final keyDates = widget.result.additionalInfo?['key_dates'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverallScoreCard(overallScore))
        const SizedBox(height: 24))
        _buildSummaryCard())
        const SizedBox(height: 24))
        _buildMonthlyChart(monthlyScores))
        const SizedBox(height: 24))
        _buildSeasonalFortune(seasonalFortune))
        const SizedBox(height: 24))
        _buildKeyDatesSection(keyDates))
        const SizedBox(height: 24))
        _buildAdviceSection())
        const SizedBox(height: 24))
        Center(
          child: OutlinedButton.icon(
            onPressed: widget.onShare)
            icon: const Icon(Icons.share))
            label: const Text('새해 운세 공유하기'))
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12))
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))
              ))
            ))
          ))
        ))
      ])
    );
  }

  Widget _buildOverallScoreCard(int score) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    return GlassContainer(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400)
              Colors.pink.shade400)
            ])
            begin: Alignment.topLeft,
            end: Alignment.bottomRight)
          ))
          borderRadius: BorderRadius.circular(20))
        ))
        child: Column(
          children: [
            Text(
              '${DateTime.now().year}년 종합 운세',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white)
                fontWeight: FontWeight.bold)
              ))
            ))
            const SizedBox(height: 20))
            Stack(
              alignment: Alignment.center)
              children: [
                SizedBox(
                  width: 150)
                  height: 150)
                  child: CircularProgressIndicator(
                    value: score / 100)
                    strokeWidth: 15)
                    backgroundColor: Colors.white.withValues(alpha: 0.3))
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score >= 80 ? Colors.green : 
                      score >= 60 ? Colors.blue : 
                      score >= 40 ? Colors.orange : 
                      Colors.red)
                    ))
                  ))
                ))
                Text(
                  '$score점')
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white)
                    fontWeight: FontWeight.bold)
                    fontSize: 36 + _getFontSizeOffset(fontSize))
                  ))
                ))
              ])
            ),
            const SizedBox(height: 16))
            Text(
              _getScoreMessage(score))
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white)
                fontSize: 16 + _getFontSizeOffset(fontSize))
              ))
            ))
          ])
        ),
      )
    );
  }

  Widget _buildSummaryCard() {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    if (widget.result.mainFortune == null) return const SizedBox.shrink();
    
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary))
                const SizedBox(width: 8))
                Text(
                  '종합 분석')
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)
                  ))
                ))
              ])
            ),
            const SizedBox(height: 12))
            Text(
              widget.result.mainFortune!)
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5)
                fontSize: 16 + _getFontSizeOffset(fontSize))
              ))
            ))
          ])
        ),
      )
    );
  }

  Widget _buildMonthlyChart(List<MonthScore> scores) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white)
        borderRadius: BorderRadius.circular(16))
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1))
            blurRadius: 10)
            offset: const Offset(0, 4))
          ))
        ])
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          const Text(
            '월별 운세 흐름')
            style: TextStyle(
              fontSize: 18)
              fontWeight: FontWeight.bold)
            ))
          ))
          const SizedBox(height: 20))
          SizedBox(
            height: 250)
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true)
                  drawVerticalLine: false)
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200)
                      strokeWidth: 1
                    );
                  })
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true)
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}')
                        style: const TextStyle(fontSize: 12),
                      ))
                      reservedSize: 40)
                    ))
                  ))
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true)
                      getTitlesWidget: (value, meta) {
                        final months = ['1월', '2월', '3월', '4월', '5월', '6월', 
                                       '7월', '8월', '9월', '10월', '11월', '12월'];
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 10)
                          );
                        }
                        return const Text('');
                      },
                    ))
                  ))
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false))
                  ))
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false))
                  ))
                ))
                borderData: FlBorderData(show: false))
                minX: 0)
                maxX: 11)
                minY: 0)
                maxY: 100)
                lineBarsData: [
                  LineChartBarData(
                    spots: scores.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.score.toDouble();
                    }).toList())
                    isCurved: true,
                    color: Colors.purple)
                    barWidth: 3)
                    dotData: FlDotData(
                      show: true)
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4)
                          color: Colors.purple)
                          strokeWidth: 2)
                          strokeColor: Colors.white)
                        );
                      })
                    ),
                    belowBarData: BarAreaData(
                      show: true)
                      color: Colors.purple.withValues(alpha: 0.1))
                    ))
                  ))
                ])
              ),
            ))
          ))
        ])
      )
    );
  }

  Widget _buildSeasonalFortune(Map<String, SeasonData> seasonalData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50)
        borderRadius: BorderRadius.circular(16))
      ))
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Row(
            children: [
              Icon(Icons.nature, color: Colors.blue.shade700))
              const SizedBox(width: 8))
              Text(
                '계절별 운세')
                style: TextStyle(
                  fontSize: 18)
                  fontWeight: FontWeight.bold)
                  color: Colors.blue.shade900)
                ))
              ))
            ])
          ),
          const SizedBox(height: 16))
          GridView.count(
            shrinkWrap: true)
            physics: const NeverScrollableScrollPhysics())
            crossAxisCount: 2)
            childAspectRatio: 1.5)
            mainAxisSpacing: 12)
            crossAxisSpacing: 12)
            children: seasonalData.entries.map((entry) {
              return _buildSeasonCard(entry.key, entry.value);
            }).toList())
          ),
        ])
      )
    );
  }

  Widget _buildSeasonCard(String season, SeasonData data) {
    final seasonIcons = {
      '봄': Icons.local_florist,
      '여름': Icons.wb_sunny,
      '가을': Icons.park,
      '겨울': Icons.ac_unit)
    };
    
    final seasonColors = {
      '봄': Colors.pink,
      '여름': Colors.green,
      '가을': Colors.orange,
      '겨울': Colors.blue)
    };
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white)
        borderRadius: BorderRadius.circular(12))
      ))
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center)
        children: [
          Icon(
            seasonIcons[season] ?? Icons.nature,
            color: seasonColors[season] ?? Colors.grey,
            size: 30)
          ))
          const SizedBox(height: 8))
          Text(
            season)
            style: const TextStyle(
              fontSize: 16)
              fontWeight: FontWeight.bold)
            ))
          ))
          const SizedBox(height: 4))
          Text(
            '${data.score}점')
            style: TextStyle(
              fontSize: 14,
              color: seasonColors[season] ?? Colors.grey,
              fontWeight: FontWeight.w600)
            ))
          ))
          const SizedBox(height: 4))
          Text(
            data.keyword)
            style: const TextStyle(
              fontSize: 12)
              color: Colors.grey)
            ))
          ))
        ])
      )
    );
  }

  Widget _buildKeyDatesSection(List<dynamic> keyDates) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50)
        borderRadius: BorderRadius.circular(16))
      ))
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Row(
            children: [
              Icon(Icons.event, color: Colors.amber.shade700))
              const SizedBox(width: 8))
              Text(
                '주요 날짜')
                style: TextStyle(
                  fontSize: 18)
                  fontWeight: FontWeight.bold)
                  color: Colors.amber.shade900)
                ))
              ))
            ])
          ),
          const SizedBox(height: 16))
          ...keyDates.map((date) => Padding(
            padding: const EdgeInsets.only(bottom: 12))
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6))
                  decoration: BoxDecoration(
                    color: Colors.amber.shade200)
                    borderRadius: BorderRadius.circular(20))
                  ))
                  child: Text(
                    date['date'] ?? '',
                    style: TextStyle(
                      fontSize: 14)
                      fontWeight: FontWeight.w600)
                      color: Colors.amber.shade900)
                    ))
                  ))
                ))
                const SizedBox(width: 12))
                Expanded(
                  child: Text(
                    date['description'] ?? '',
                    style: const TextStyle(fontSize: 14))
                  ))
                ))
              ])
            ),
          )).toList())
        ])
      )
    );
  }

  Widget _buildAdviceSection() {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final advice = widget.result.additionalInfo?['yearly_advice'] ?? '올 한 해도 행운이 함께하길 바랍니다!';
    final luckyItems = widget.result.additionalInfo?['lucky_items'] as List<dynamic>? ?? [];
    
    return GlassContainer(
      gradient: LinearGradient(
        colors: [Colors.purple.shade50, Colors.pink.shade50],
        begin: Alignment.topLeft)
        end: Alignment.bottomRight)
      ))
      child: Padding(
        padding: const EdgeInsets.all(20))
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: theme.colorScheme.primary))
                const SizedBox(width: 8))
                Text(
                  '새해 조언')
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)
                  ))
                ))
              ])
            ),
            const SizedBox(height: 12))
            Text(
              advice)
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5)
                fontSize: 16 + _getFontSizeOffset(fontSize))
              ))
            ))
            if (luckyItems.isNotEmpty) ...[
              const SizedBox(height: 16))
              Text(
                '올해의 행운 아이템')
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600)
                ))
              ))
              const SizedBox(height: 8))
              Wrap(
                spacing: 8)
                runSpacing: 8)
                children: luckyItems.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6))
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2))
                    borderRadius: BorderRadius.circular(20))
                  ))
                  child: Text(
                    item.toString())
                    style: TextStyle(
                      color: theme.colorScheme.primary)
                      fontSize: 12 + _getFontSizeOffset(fontSize))
                    ))
                  ))
                )).toList())
              ))
            ])
          ],
        ))
      )
    );
  }

  List<MonthScore> _parseMonthlyScores(dynamic data) {
    if (data == null || data is! Map) {
      // 기본값 생성
      return List.generate(12, (index) => MonthScore(
        month: index + 1,
        score: 60 + (index * 3 % 30))
      ));
    }
    
    return List.generate(12, (index) {
      final month = index + 1;
      return MonthScore(
        month: month,
        score: data['$month'] ?? 60
      );
    });
  }

  Map<String, SeasonData> _parseSeasonalFortune(dynamic data) {
    if (data == null || data is! Map) {
      return {
        '봄': SeasonData(score: 75, keyword: '새로운 시작'),
        '여름': SeasonData(score: 85, keyword: '열정적인 도전'))
        '가을': SeasonData(score: 70, keyword: '결실의 시간'))
        '겨울': SeasonData(score: 65, keyword: '내면의 성장'))
      };
    }
    
    final result = <String, SeasonData>{};
    data.forEach((key, value) {
      if (value is Map) {
        result[key] = SeasonData(
          score: value['score'] ?? 70,
          keyword: value['keyword'] ?? ''
        );
      }
    });
    
    return result;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 한 해가 될 거예요!';
    if (score >= 80) return '매우 좋은 한 해가 예상됩니다';
    if (score >= 70) return '전반적으로 순조로운 한 해';
    if (score >= 60) return '평균적인 운세의 한 해';
    if (score >= 50) return '조금 주의가 필요한 한 해';
    return '신중하게 보내야 할 한 해';
  }
}

class MonthScore {
  final int month;
  final int score;

  MonthScore({required this.month, required this.score});
}

class SeasonData {
  final int score;
  final String keyword;

  SeasonData({required this.score, required this.keyword});
}