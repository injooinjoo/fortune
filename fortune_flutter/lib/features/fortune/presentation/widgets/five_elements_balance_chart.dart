import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';

class FiveElementsBalanceChart extends StatefulWidget {
  final Map<String, int> elementBalance;
  final bool showAnimation;

  const FiveElementsBalanceChart({
    Key? key,
    required this.elementBalance,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<FiveElementsBalanceChart> createState() => _FiveElementsBalanceChartState();
}

class _FiveElementsBalanceChartState extends State<FiveElementsBalanceChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedIndex;

  // 오행 정보
  static const Map<String, Map<String, dynamic>> elementInfo = {
    '목': {
      'color': Color(0xFF4CAF50),
      'icon': Icons.park,
      'meaning': '성장, 발전, 인자함',
      'season': '봄',
      'direction': '동쪽',
      'organ': '간, 담',
    },
    '화': {
      'color': Color(0xFFFF5722),
      'icon': Icons.local_fire_department,
      'meaning': '열정, 활력, 예의',
      'season': '여름',
      'direction': '남쪽',
      'organ': '심장, 소장',
    },
    '토': {
      'color': Color(0xFFFFB300),
      'icon': Icons.terrain,
      'meaning': '안정, 신뢰, 중용',
      'season': '환절기',
      'direction': '중앙',
      'organ': '비장, 위',
    },
    '금': {
      'color': Color(0xFF9E9E9E),
      'icon': Icons.diamond,
      'meaning': '결단, 정의, 수렴',
      'season': '가을',
      'direction': '서쪽',
      'organ': '폐, 대장',
    },
    '수': {
      'color': Color(0xFF2196F3),
      'icon': Icons.water_drop,
      'meaning': '지혜, 유연성, 겸손',
      'season': '겨울',
      'direction': '북쪽',
      'organ': '신장, 방광',
    },
  };

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
        _buildElementDetails(),
        const SizedBox(height: 16),
        _buildElementRelations(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오행 균형도',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '당신의 사주에 나타난 오행의 분포',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        _buildTotalScore(),
      ],
    );
  }

  Widget _buildTotalScore() {
    final total = widget.elementBalance.values.fold(0, (sum, count) => sum + count);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.purple,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '총 $total점',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassContainer(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // 배경 원
              CustomPaint(
                size: Size.infinite,
                painter: _RadarBackgroundPainter(),
              ),
              // 레이더 차트
              RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 4,
                  ticksTextStyle: TextStyle(
                    color: Colors.white30,
                    fontSize: 10,
                  ),
                  tickBorderData: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  gridBorderData: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  radarBorderData: BorderSide(
                    color: Colors.purple.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  titlePositionPercentageOffset: 0.2,
                  getTitle: (index, angle) {
                    final elements = ['목', '화', '토', '금', '수'];
                    return RadarChartTitle(
                      text: elements[index],
                      angle: angle,
                    );
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.purple.withValues(alpha: 0.3),
                      borderColor: Colors.purple,
                      borderWidth: 2,
                      entryRadius: 4,
                      dataEntries: _getRadarEntries(),
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
              ),
              // 중앙 정보
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
    final elements = ['목', '화', '토', '금', '수'];
    final maxValue = 4.0; // 최대값 설정
    
    return elements.map((element) {
      final value = (widget.elementBalance[element] ?? 0) * _animation.value;
      return RadarEntry(value: value.toDouble() / maxValue);
    }).toList();
  }

  Widget _buildCenterInfo() {
    final strongestElement = _getStrongestElement();
    final weakestElement = _getWeakestElement();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '주 원소',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              elementInfo[strongestElement]!['icon'] as IconData,
              color: elementInfo[strongestElement]!['color'] as Color,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(
              strongestElement,
              style: TextStyle(
                color: elementInfo[strongestElement]!['color'] as Color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElementDetails() {
    return Column(
      children: elementInfo.entries.map((entry) {
        final element = entry.key;
        final info = entry.value;
        final count = widget.elementBalance[element] ?? 0;
        final isStrongest = element == _getStrongestElement();
        final isWeakest = element == _getWeakestElement();
        
        return GestureDetector(
          onTap: () => _showElementDetail(element, info),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (info['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isStrongest
                    ? (info['color'] as Color)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (info['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    info['icon'] as IconData,
                    color: info['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$element원소',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isStrongest)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '최강',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isWeakest)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '보충필요',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info['meaning'] as String,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // 개수 표시
                Container(
                  width: 50,
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(
                          color: info['color'] as Color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '개',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildElementRelations() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오행 상생상극',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRelationInfo(
                  '상생',
                  '목→화→토→금→수→목',
                  Colors.green,
                  Icons.refresh,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRelationInfo(
                  '상극',
                  '목→토→수→화→금→목',
                  Colors.red,
                  Icons.close,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelationInfo(
    String title,
    String relation,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            relation,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStrongestElement() {
    var strongest = '토';
    var maxCount = -1;
    
    widget.elementBalance.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        strongest = element;
      }
    });
    
    return strongest;
  }

  String _getWeakestElement() {
    var weakest = '토';
    var minCount = 999;
    
    widget.elementBalance.forEach((element, count) {
      if (count < minCount) {
        minCount = count;
        weakest = element;
      }
    });
    
    return weakest;
  }

  void _showElementDetail(String element, Map<String, dynamic> info) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              info['icon'] as IconData,
              color: info['color'] as Color,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              '$element원소',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: info['color'] as Color,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('의미', info['meaning'] as String),
            _buildDetailRow('계절', info['season'] as String),
            _buildDetailRow('방위', info['direction'] as String),
            _buildDetailRow('장기', info['organ'] as String),
            const SizedBox(height: 20),
            Text(
              '보유 개수: ${widget.elementBalance[element] ?? 0}개',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
    
    // 동심원 그리기
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, paint);
    }
    
    // 오각형 선 그리기
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}