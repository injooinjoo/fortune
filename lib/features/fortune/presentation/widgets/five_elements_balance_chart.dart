import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

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
      'color': AppColors.success,
      'icon': Icons.park,
      'meaning': '성장, 발전, 인자함',
      'season': '봄',
      'direction': '동쪽',
      'organ': '간, 담',
    },
    '화': {
      'color': AppColors.warning,
      'icon': Icons.local_fire_department,
      'meaning': '열정, 활력, 예의',
      'season': '여름',
      'direction': '남쪽',
      'organ': '심장, 소장',
    },
    '토': {
      'color': FortuneColors.goldLight,
      'icon': Icons.terrain,
      'meaning': '안정, 신뢰, 중용',
      'season': '환절기',
      'direction': '중앙',
      'organ': '비장, 위',
    },
    '금': {
      'color': AppColors.textSecondary,
      'icon': Icons.diamond,
      'meaning': '결단, 정의, 수렴',
      'season': '가을',
      'direction': '서쪽',
      'organ': '폐, 대장',
    },
    '수': {
      'color': AppColors.primary,
      'icon': Icons.water_drop,
      'meaning': '지혜, 유연성, 겸손',
      'season': '겨울',
      'direction': '북쪽',
      'organ': '신장, 방광',
    }
  };

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.spacing5),
        _buildRadarChart(),
        const SizedBox(height: AppSpacing.spacing5),
        _buildElementDetails(),
        const SizedBox(height: AppSpacing.spacing4),
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spacing1),
            Text(
              '당신의 사주에 나타난 오행의 분포',
              style: Theme.of(context).textTheme.bodyMedium,
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
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
          const SizedBox(width: AppSpacing.spacing1),
          Text(
            '총 $total점',
            style: Theme.of(context).textTheme.bodyMedium,
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
          height: AppSpacing.spacing24 * 3.125,
          padding: AppSpacing.paddingAll20,
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
                      fillColor: Colors.purple.withOpacity(0.3),
                      borderColor: Colors.purple,
                      borderWidth: 2,
                      entryRadius: 4,
                      dataEntries: _getRadarEntries(),
                    ),
                  ],
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              elementInfo[strongestElement]!['icon'],
              color: elementInfo[strongestElement]!['color'],
              size: 24,
            ),
            const SizedBox(width: AppSpacing.spacing1),
            Text(
              strongestElement,
              style: Theme.of(context).textTheme.bodyMedium,
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
            margin: const EdgeInsets.only(bottom: AppSpacing.spacing2),
            padding: AppSpacing.paddingAll12,
            decoration: BoxDecoration(
              color: (info['color'] as Color).withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusMedium,
              border: Border.all(
                color: isStrongest
                    ? (info['color'] as Color).withOpacity(0.3)
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
                    color: (info['color'] as Color).withOpacity(0.2),
                    borderRadius: AppDimensions.borderRadiusSmall,
                  ),
                  child: Icon(
                    info['icon'],
                    color: info['color'],
                    size: 24,
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
                            '$element원소',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: AppSpacing.spacing2),
                          if (isStrongest) Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacing2,
                                vertical: AppSpacing.spacing0 * 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: AppDimensions.borderRadiusMedium,
                              ),
                              child: Text(
                                '최강',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          if (isWeakest) Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacing2,
                                vertical: AppSpacing.spacing0 * 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: AppDimensions.borderRadiusMedium,
                              ),
                              child: Text(
                                '보충필요',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        info['meaning'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // 개수 표시
                Container(
                  width: AppSpacing.spacing12 * 1.04,
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '개',
                        style: Theme.of(context).textTheme.bodyMedium,
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
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오행 상생상극',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.spacing3),
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
              const SizedBox(width: AppSpacing.spacing3),
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
      padding: AppSpacing.paddingAll12,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: AppSpacing.spacing1),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing1),
          Text(
            relation,
            style: Theme.of(context).textTheme.bodyMedium,
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
            Icon(
              info['icon'],
              color: info['color'],
              size: 48,
            ),
            const SizedBox(height: AppSpacing.spacing3),
            Text(
              '$element원소',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spacing5),
            _buildDetailRow('의미', info['meaning']),
            _buildDetailRow('계절', info['season']),
            _buildDetailRow('방위', info['direction']),
            _buildDetailRow('장기', info['organ']),
            const SizedBox(height: AppSpacing.spacing5),
            Text(
              '개수: ${widget.elementBalance[element] ?? 0}개',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
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
      ..color = Colors.white.withOpacity(0.1);
    
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