import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/mbti_cognitive_functions_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class CognitiveFunctionsRadarChart extends StatefulWidget {
  final String mbtiType;
  final Map<String, double> functionLevels;
  final bool showAnimation;

  const CognitiveFunctionsRadarChart({
    super.key,
    required this.mbtiType,
    required this.functionLevels,
    this.showAnimation = true,
  });

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeInfo = MbtiCognitiveFunctionsService.mbtiDescriptions[widget.mbtiType]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인지기능 분석',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing1),
            Text(
              '${widget.mbtiType} - ${typeInfo['title']}의 오늘 상태',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1 * 1.5),
          decoration: BoxDecoration(
            color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))).withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))).withValues(alpha:0.5),
              width: 1,
            ),
          ),
          child: Text(
            typeInfo['group'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Color(int.parse(typeInfo['color'].replaceFirst('#', '0xFF'))),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                painter: _RadarGridPainter(isDark: isDark),
              ),
              // 레이더 차트
              RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray600,
                  ) ?? TextStyle(
                    fontSize: 12,
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray600,
                  ),
                  tickBorderData: BorderSide(
                    color: isDark ? TossDesignSystem.grayDark300.withValues(alpha:0.3) : TossDesignSystem.gray300.withValues(alpha:0.3),
                    width: 1,
                  ),
                  gridBorderData: BorderSide(
                    color: isDark ? TossDesignSystem.grayDark300.withValues(alpha:0.3) : TossDesignSystem.gray300.withValues(alpha:0.3),
                    width: 1,
                  ),
                  radarBorderData: BorderSide(
                    color: TossDesignSystem.purple.withValues(alpha:0.5),
                    width: 2,
                  ),
                  titleTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    fontWeight: FontWeight.w600,
                  ) ?? TextStyle(
                    fontSize: 12,
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    fontWeight: FontWeight.w600,
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
                      fillColor: TossDesignSystem.purple.withValues(alpha:0.3),
                      borderColor: TossDesignSystem.purple,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stack = MbtiCognitiveFunctionsService.mbtiStacks[widget.mbtiType]!;
    final dominantFunction = stack[0];
    final dominantLevel = widget.functionLevels[dominantFunction] ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '주기능',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
          decoration: BoxDecoration(
            color: _getFunctionColor(dominantFunction).withValues(alpha:0.2),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: _getFunctionColor(dominantFunction).withValues(alpha:0.5),
              width: 1,
            ),
          ),
          child: Text(
            dominantFunction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getFunctionColor(dominantFunction),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Text(
          '${(dominantLevel * 100).toInt()}%',
          style: TextStyle(
            color: _getLevelColor(dominantLevel),
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionsList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
              color: _getFunctionColor(function).withValues(alpha:0.1),
              borderRadius: AppDimensions.borderRadiusMedium,
              border: Border.all(
                color: _selectedIndex == MbtiCognitiveFunctionsService.cognitiveFunctions.indexOf(function)
                    ? _getFunctionColor(function)
                    : TossDesignSystem.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getFunctionColor(function).withValues(alpha:0.2),
                    borderRadius: AppDimensions.borderRadiusSmall,
                  ),
                  child: Center(
                    child: Text(
                      info['icon'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                      ),
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacing2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacing2,
                              vertical: 4 * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStackPositionColor(stackIndex).withValues(alpha:0.2),
                              borderRadius: AppDimensions.borderRadiusMedium,
                            ),
                            child: Text(
                              _getStackPositionName(stackIndex),
                              style: TextStyle(
                                color: _getStackPositionColor(stackIndex),
                                fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.85,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        info['nameEn'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                          fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.9,
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
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getFunctionStatus(level),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.85,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인지기능 스택 구조',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStackLegend('주기능', TossDesignSystem.purple, 'Hero'),
              _buildStackLegend('부기능', TossDesignSystem.tossBlue, 'Parent'),
              _buildStackLegend('3차기능', TossDesignSystem.successGreen, 'Child'),
              _buildStackLegend('열등기능', TossDesignSystem.warningOrange, 'Inferior'),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            '* 주기능부터 열등기능까지 4개가 의식적으로 사용되는 기능입니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
              fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackLegend(String name, Color color, String english) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
            fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.9,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          english,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.8,
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
    if (level >= 0.8) return TossDesignSystem.successGreen;
    if (level >= 0.6) return TossDesignSystem.tossBlue;
    if (level >= 0.4) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

  Color _getStackPositionColor(int index) {
    switch (index) {
      case 0: return TossDesignSystem.purple;
      case 1: return TossDesignSystem.tossBlue;
      case 2: return TossDesignSystem.successGreen;
      case 3: return TossDesignSystem.warningOrange;
      default: return TossDesignSystem.gray400;
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
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
                color: TossDesignSystem.white.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(4 * 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Text(
              info['icon'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing3),
            Text(
              '$function - ${info['name']}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              info['nameEn'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              info['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Row(
              children: [
                Expanded(
                  child: _buildDetailSection(
                    '강점',
                    (info['strengths'] as List<String>),
                    TossDesignSystem.successGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: _buildDetailSection(
                    '약점',
                    (info['weaknesses'] as List<String>),
                    TossDesignSystem.warningOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Text(
              '활성도: ${(widget.functionLevels[function]! * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getLevelColor(widget.functionLevels[function]!),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<String> items, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final bool isDark;

  _RadarGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = isDark
          ? TossDesignSystem.grayDark400.withValues(alpha:0.2)
          : TossDesignSystem.gray300.withValues(alpha:0.3);
    
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