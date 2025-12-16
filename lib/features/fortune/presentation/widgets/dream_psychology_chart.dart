import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/design_system/design_system.dart';

class DreamPsychologyChart extends StatefulWidget {
  final Map<String, double> psychologicalState;
  final bool showAnimation;

  const DreamPsychologyChart({
    super.key,
    required this.psychologicalState,
    this.showAnimation = true,
  });

  @override
  State<DreamPsychologyChart> createState() => _DreamPsychologyChartState();
}

class _DreamPsychologyChartState extends State<DreamPsychologyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildRadarChart(),
        const SizedBox(height: 20),
        _buildBalanceIndicators(),
        const SizedBox(height: 16),
        _buildInsightSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.psychology,
          color: DSColors.accentSecondary,
          size: 24),
        const SizedBox(width: 8),
        Text(
          '심리 상태 분석',
          style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildRadarChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassContainer(
          height: 96 * 3.125,
          padding: EdgeInsets.all(20),
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _RadarBackgroundPainter()),
              RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: Theme.of(context).textTheme.bodyMedium ?? DSTypography.labelMedium,
                  tickBorderData: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1),
                  gridBorderData: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1),
                  radarBorderData: BorderSide(
                    color: DSColors.accentSecondary.withValues(alpha: 0.5),
                    width: 2),
                  titleTextStyle: Theme.of(context).textTheme.bodyMedium ?? DSTypography.labelMedium,
                  titlePositionPercentageOffset: 0.15,
                  getTitle: (index, angle) {
                    final titles = ['의식', '무의식', '긍정', '부정', '안정', '변화', '내향', '외향'];
                    return RadarChartTitle(
                      text: titles[index],
                      angle: 0);
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: DSColors.accentSecondary.withValues(alpha: 0.3),
                      borderColor: DSColors.accentSecondary,
                      borderWidth: 2,
                      entryRadius: 4,
                      dataEntries: _getRadarEntries()),
                  ],
                ),
              ),
              Center(
                child: _buildCenterInfo(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<RadarEntry> _getRadarEntries() {
    final states = ['의식', '무의식', '긍정', '부정', '안정', '변화', '내향', '외향'];
    
    return states.map((state) {
      final value = (widget.psychologicalState[state] ?? 0.5) * _animation.value;
      return RadarEntry(value: value);
    }).toList();
  }

  Widget _buildCenterInfo() {
    // 전체적인 심리 상태 계산
    final consciousness = widget.psychologicalState['의식'] ?? 0.5;
    final positivity = widget.psychologicalState['긍정'] ?? 0.5;
    
    String stateText;
    Color stateColor;
    
    if (consciousness > 0.6 && positivity > 0.6) {
      stateText = '의식적 긍정';
      stateColor = DSColors.success;
    } else if (consciousness > 0.6 && positivity < 0.4) {
      stateText = '의식적 우려';
      stateColor = DSColors.warning;
    } else if (consciousness < 0.4 && positivity > 0.6) {
      stateText = '무의식적 희망';
      stateColor = DSColors.accent;
    } else if (consciousness < 0.4 && positivity < 0.4) {
      stateText = '무의식적 불안';
      stateColor = DSColors.error;
    } else {
      stateText = '균형 상태';
      stateColor = DSColors.accentSecondary;
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '전반적 상태',
          style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: stateColor.withValues(alpha: 0.5),
              width: 1),
          ),
          child: Text(
            stateText,
            style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildBalanceIndicators() {
    return Column(
      children: [
        _buildBalanceBar('의식', '무의식', DSColors.accent, DSColors.accentSecondary),
        const SizedBox(height: 12),
        _buildBalanceBar('긍정', '부정', DSColors.success, DSColors.error),
        const SizedBox(height: 12),
        _buildBalanceBar('안정', '변화', DSColors.accent, DSColors.warning),
        const SizedBox(height: 12),
        _buildBalanceBar('내향', '외향', DSColors.accentSecondary, DSColors.warning),
      ],
    );
  }

  Widget _buildBalanceBar(String left, String right, Color leftColor, Color rightColor) {
    final leftValue = widget.psychologicalState[left] ?? 0.5;
    final rightValue = widget.psychologicalState[right] ?? 0.5;
    final total = leftValue + rightValue;
    final leftPercent = (leftValue / total * 100).toInt();
    final rightPercent = (rightValue / total * 100).toInt();
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$left $leftPercent%',
                style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '$right $rightPercent%',
                style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(DSRadius.sm),
            child: LinearProgressIndicator(
              value: leftValue / total,
              backgroundColor: rightColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(leftColor),
              minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection() {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: DSColors.warning,
                size: 20),
              const SizedBox(width: 8),
              Text(
                '심리학적 통찰',
                style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _generateInsight(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5),
          ),
          const SizedBox(height: 12),
          _buildRecommendations(),
        ],
      ),
    );
  }

  String _generateInsight() {
    final consciousness = widget.psychologicalState['의식'] ?? 0.5;
    final unconsciousness = widget.psychologicalState['무의식'] ?? 0.5;
    final positivity = widget.psychologicalState['긍정'] ?? 0.5;
    final stability = widget.psychologicalState['안정'] ?? 0.5;
    
    final insights = <String>[];
    
    if (unconsciousness > consciousness) {
      insights.add('무의식적 메시지가 강하게 나타나고 있습니다. 내면의 소리에 귀 기울여보세요');
    }
    
    if (positivity > 0.7) {
      insights.add('긍정적인 에너지가 충만한 상태입니다. 이 에너지를 활용해 새로운 시작을 해보세요');
    } else if (positivity < 0.3) {
      insights.add('부정적인 감정이 누적되어 있을 수 있습니다. 스트레스 해소가 필요합니다');
    }
    
    if (stability < 0.3) {
      insights.add('변화에 대한 강한 욕구가 보입니다. 새로운 도전을 고려해보세요');
    }
    
    return insights.isNotEmpty 
        ? insights.join('. ')
        : '전반적으로 균형잡힌 심리 상태를 보이고 있습니다.';
  }

  Widget _buildRecommendations() {
    final recommendations = _getRecommendations();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 활동',
          style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(color: DSColors.warning),
              ),
              Expanded(
                child: Text(
                  rec,
                  style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    
    final consciousness = widget.psychologicalState['의식'] ?? 0.5;
    final positivity = widget.psychologicalState['긍정'] ?? 0.5;
    final stability = widget.psychologicalState['안정'] ?? 0.5;
    final introversion = widget.psychologicalState['내향'] ?? 0.5;
    
    if (consciousness < 0.4) {
      recommendations.add('명상이나 일기 쓰기로 무의식과 대화해보세요');
    }
    
    if (positivity < 0.4) {
      recommendations.add('긍정적인 활동(운동, 취미)에 시간을 투자하세요');
    }
    
    if (stability < 0.4) {
      recommendations.add('새로운 경험이나 환경 변화를 시도해보세요');
    }
    
    if (introversion > 0.6) {
      recommendations.add('혼자만의 시간을 충분히 가지고 재충전하세요');
    } else if (introversion < 0.4) {
      recommendations.add('사람들과의 교류를 통해 에너지를 얻으세요');
    }
    
    return recommendations;
  }
}

class _RadarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.1);
    
    // 동심원
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * i / 5, paint);
    }
    
    // 8방향 선
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}