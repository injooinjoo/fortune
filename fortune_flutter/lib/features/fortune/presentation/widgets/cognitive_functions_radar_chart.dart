import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/mbti_cognitive_functions_service.dart';

class CognitiveFunctionsRadarChart extends StatefulWidget {
  final String mbtiType;
  final Map<String, double> functionLevels;
  final bool showAnimation;

  const CognitiveFunctionsRadarChart({
    Key? key,
    required this.mbtiType,
    required this.functionLevels,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<CognitiveFunctionsRadarChart> createState() => _CognitiveFunctionsRadarChartState();
}

class _CognitiveFunctionsRadarChartState extends State<CognitiveFunctionsRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedIndex;

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

  String _getFunctionStatus(double level) {
    if (level >= 0.9) return '최상의 상태';
    if (level >= 0.7) return '좋은 상태';
    if (level >= 0.5) return '보통 상태';
    if (level >= 0.3) return '저조한 상태';
    return '주의 필요';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildChart(),
        const SizedBox(height: 20),
        _buildFunctionsList(),
        const SizedBox(height: 16),
        _buildStackInfo(),
      ],
    );
  }

  Widget _buildHeader() {
    final typeInfo = MbtiCognitiveFunctionsService.mbtiDescriptions[widget.mbtiType]!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인지기능 분석',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.mbtiType} - ${typeInfo['title']}의 오늘 상태',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            typeInfo['group'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassContainer(
          height: 350,
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // 배경 그리드
              CustomPaint(
                size: Size.infinite,
                painter: _RadarGridPainter(),
              ),
              // 레이더 차트
              RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: TextStyle(
                    color: Colors.white30,
                    fontSize: 10,
                  ),
                  tickBorderData: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  gridBorderData: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  radarBorderData: BorderSide(
                    color: Colors.purple.withOpacity(0.5),
                    width: 2,
                  ),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  titlePositionPercentageOffset: 0.15,
                  getTitle: (index, angle) {
                    final functions = MbtiCognitiveFunctionsService.cognitiveFunctions;
                    return RadarChartTitle(
                      text: functions[index],
                      angle: 0,
                    );
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.purple.withOpacity(0.3),
                      borderColor: Colors.purple,
                      borderWidth: 2,
                      entryRadius: 4,
                      dataEntries: _getRadarEntries(),
                    ),
                  ],
                  radarTouchData: RadarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.touchedSpot != null) {
                          _selectedIndex = response!.touchedSpot!.touchedDataSetIndex;
                        } else {
                          _selectedIndex = null;
                        }
                      });
                    },
                  ),
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
    final functions = MbtiCognitiveFunctionsService.cognitiveFunctions;
    
    return functions.map((function) {
      final value = (widget.functionLevels[function] ?? 0) * _animation.value;
      return RadarEntry(value: value);
    }).toList();
  }

  Widget _buildCenterInfo() {
    final stack = MbtiCognitiveFunctionsService.mbtiStacks[widget.mbtiType]!;
    final dominantFunction = stack[0];
    final dominantLevel = widget.functionLevels[dominantFunction] ?? 0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '주기능',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getFunctionColor(dominantFunction).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getFunctionColor(dominantFunction).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            dominantFunction,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(dominantLevel * 100).toInt()}%',
          style: TextStyle(
            color: _getLevelColor(dominantLevel),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionsList() {
    final stack = MbtiCognitiveFunctionsService.mbtiStacks[widget.mbtiType]!;
    
    return Column(
      children: stack.take(4).map((function) {
        final level = widget.functionLevels[function] ?? 0;
        final info = MbtiCognitiveFunctionsService.functionDescriptions[function]!;
        final stackIndex = stack.indexOf(function);
        
        return GestureDetector(
          onTap: () => _showFunctionDetail(function, info),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getFunctionColor(function).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedIndex == MbtiCognitiveFunctionsService.cognitiveFunctions.indexOf(function)
                    ? _getFunctionColor(function)
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
                    color: _getFunctionColor(function).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      info['icon'] as String,
                      style: TextStyle(fontSize: 20),
                    ),
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
                            '$function - ${info['name']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStackPositionColor(stackIndex).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStackPositionName(stackIndex),
                              style: TextStyle(
                                color: _getStackPositionColor(stackIndex),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info['nameEn'] as String,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // 레벨 표시
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(level * 100).toInt()}%',
                      style: TextStyle(
                        color: _getLevelColor(level),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getFunctionStatus(level),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStackInfo() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인지기능 스택 구조',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStackLegend('주기능', Colors.purple, 'Hero'),
              _buildStackLegend('부기능', Colors.blue, 'Parent'),
              _buildStackLegend('3차기능', Colors.green, 'Child'),
              _buildStackLegend('열등기능', Colors.orange, 'Inferior'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '* 주기능부터 열등기능까지 4개가 의식적으로 사용되는 기능입니다',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackLegend(String name, Color color, String english) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        Text(
          english,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getFunctionColor(String function) {
    final colorString = MbtiCognitiveFunctionsService.functionDescriptions[function]?['color'] ?? '#FFFFFF';
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  }

  Color _getLevelColor(double level) {
    if (level >= 0.8) return Colors.green;
    if (level >= 0.6) return Colors.blue;
    if (level >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getStackPositionColor(int index) {
    switch (index) {
      case 0: return Colors.purple;
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getStackPositionName(int index) {
    switch (index) {
      case 0: return '주기능';
      case 1: return '부기능';
      case 2: return '3차기능';
      case 3: return '열등기능';
      default: return '그림자';
    }
  }

  void _showFunctionDetail(String function, Map<String, dynamic> info) {
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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              info['icon'] as String,
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              '$function - ${info['name']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getFunctionColor(function),
              ),
            ),
            Text(
              info['nameEn'] as String,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              info['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDetailSection(
                    '강점',
                    (info['strengths'] as List).cast<String>(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailSection(
                    '약점',
                    (info['weaknesses'] as List).cast<String>(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '현재 활성도: ${(widget.functionLevels[function]! * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getLevelColor(widget.functionLevels[function]!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(color: color),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.1);
    
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