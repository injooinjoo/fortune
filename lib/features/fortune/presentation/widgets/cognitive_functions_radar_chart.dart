import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/mbti_cognitive_functions_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

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
      duration: AppAnimations.durationSkeleton,
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
        const SizedBox(height: AppSpacing.spacing5),
        _buildChart(),
        const SizedBox(height: AppSpacing.spacing5),
        _buildFunctionsList(),
        const SizedBox(height: AppSpacing.spacing4),
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spacing1),
            Text(
              '${widget.mbtiType} - ${typeInfo['title']}의 오늘 상태',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1 * 1.5),
          decoration: BoxDecoration(
            color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))).withOpacity(0.2),
            borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
            border: Border.all(
              color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            typeInfo['group'],
            style: Theme.of(context).textTheme.bodyMedium,
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
          padding: AppSpacing.paddingAll20,
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
                  ticksTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 12),
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
                  titleTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 12),
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
          decoration: BoxDecoration(
            color: _getFunctionColor(dominantFunction).withOpacity(0.2),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: _getFunctionColor(dominantFunction).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            dominantFunction,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Text(
          '${(dominantLevel * 100).toInt()}%',
          style: TextStyle(
            color: _getLevelColor(dominantLevel),
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
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
            margin: const EdgeInsets.only(bottom: AppSpacing.spacing2),
            padding: AppSpacing.paddingAll12,
            decoration: BoxDecoration(
              color: _getFunctionColor(function).withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusMedium,
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
                  height: AppDimensions.buttonHeightSmall,
                  decoration: BoxDecoration(
                    color: _getFunctionColor(function).withOpacity(0.2),
                    borderRadius: AppDimensions.borderRadiusSmall,
                  ),
                  child: Center(
                    child: Text(
                      info['icon'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$function - ${info['name']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: AppSpacing.spacing2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacing2,
                              vertical: AppSpacing.spacing0 * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStackPositionColor(stackIndex).withOpacity(0.2),
                              borderRadius: AppDimensions.borderRadiusMedium,
                            ),
                            child: Text(
                              _getStackPositionName(stackIndex),
                              style: TextStyle(
                                color: _getStackPositionColor(stackIndex),
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        info['nameEn'],
                        style: Theme.of(context).textTheme.bodyMedium,
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
                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getFunctionStatus(level),
                      style: Theme.of(context).textTheme.bodyMedium,
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
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인지기능 스택 구조',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStackLegend('주기능', Colors.purple, 'Hero'),
              _buildStackLegend('부기능', Colors.blue, 'Parent'),
              _buildStackLegend('3차기능', Colors.green, 'Child'),
              _buildStackLegend('열등기능', Colors.orange, 'Inferior'),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            '* 주기능부터 열등기능까지 4개가 의식적으로 사용되는 기능입니다',
            style: Theme.of(context).textTheme.bodyMedium,
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
          height: AppSpacing.spacing3,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          english,
          style: Theme.of(context).textTheme.bodyMedium,
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
        padding: AppSpacing.paddingAll24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: AppSpacing.spacing1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Text(
              info['icon'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spacing3),
            Text(
              '$function - ${info['name']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              info['nameEn'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              info['description'],
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Row(
              children: [
                Expanded(
                  child: _buildDetailSection(
                    '강점',
                    (info['strengths'] as List<String>),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: _buildDetailSection(
                    '약점',
                    (info['weaknesses'] as List<String>),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Text(
              '활성도: ${(widget.functionLevels[function]! * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.spacing2),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spacing1),
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
                  style: Theme.of(context).textTheme.bodyMedium,
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