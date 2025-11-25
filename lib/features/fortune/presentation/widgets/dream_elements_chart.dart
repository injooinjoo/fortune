import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/dream_elements_analysis_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class DreamElementsChart extends StatefulWidget {
  final Map<String, double> elementWeights;
  final Map<String, List<String>> elements;
  final bool showAnimation;

  const DreamElementsChart({
    super.key,
    required this.elementWeights,
    required this.elements,
    this.showAnimation = true,
  });

  @override
  State<DreamElementsChart> createState() => _DreamElementsChartState();
}

class _DreamElementsChartState extends State<DreamElementsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.durationShimmer,
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
        _buildChart(),
        const SizedBox(height: AppSpacing.spacing5),
        _buildElementsList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '꿈 요소 분석',
          style: Theme.of(context).textTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1 * 1.5),
          decoration: BoxDecoration(
            color: TossDesignSystem.purple.withValues(alpha:0.2),
            borderRadius: AppDimensions.borderRadius(TossDesignSystem.radiusXL),
            border: Border.all(
              color: TossDesignSystem.purple.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${_getTotalElements()}개 요소 발견',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  int _getTotalElements() {
    int total = 0;
    for (final list in widget.elements.values) {
      total += list.length;
    }
    return total;
  }

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassContainer(
          height: AppSpacing.spacing24 * 3.125,
          padding: AppSpacing.paddingAll20,
          child: Stack(
            children: [
              // 파이 차트
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse?.touchedSection != null) {
                          _selectedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                        } else {
                          _selectedIndex = null;
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 80,
                  sections: _getPieChartSections(),
                ),
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
              ),
              // 중앙 텍스트
              Center(
                child: _buildCenterInfo(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final sections = <PieChartSectionData>[];
    int index = 0;
    
    for (final entry in widget.elementWeights.entries) {
      final isSelected = _selectedIndex == index;
      final value = entry.value * _animation.value;
      
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: _getCategoryColor(entry.key),
            value: value * 100,
            title: '${(value * 100).toInt()}%',
            radius: isSelected ? 80 : 70,
            titleStyle: TextStyle(
              fontSize: isSelected ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
            badgeWidget: _buildBadge(entry.key),
            badgePositionPercentageOffset: 1.3,
          ),
        );
      }
      index++;
    }
    
    return sections;
  }

  Widget _buildBadge(String category) {
    return Container(
      padding: AppSpacing.paddingAll8,
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withValues(alpha:0.2),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: _getCategoryColor(category).withValues(alpha:0.5),
          width: 1,
        ),
      ),
      child: Icon(
        _getCategoryIcon(category),
        size: 20,
        color: _getCategoryColor(category),
      ),
    );
  }

  Widget _buildCenterInfo() {
    if (_selectedIndex == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bedtime,
            size: 32,
            color: TossDesignSystem.white.withValues(alpha: 0.54),
          ),
          const SizedBox(height: AppSpacing.spacing2),
          Text(
            '꿈 요소',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }
    
    final categories = widget.elementWeights.keys.toList();
    if (_selectedIndex! < categories.length) {
      final category = categories[_selectedIndex!];
      final count = widget.elements[category]?.length ?? 0;
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 32,
            color: _getCategoryColor(category),
          ),
          const SizedBox(height: AppSpacing.spacing1),
          Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '$count개',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildElementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '발견된 요소 상세',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.spacing3),
        ...widget.elements.entries.where((e) => e.value.isNotEmpty).map((entry) {
          return _buildCategorySection(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing3),
      padding: AppSpacing.paddingAll12,
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withValues(alpha:0.1),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: _getCategoryColor(category).withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 16,
                color: _getCategoryColor(category),
              ),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                category,
                style: TextStyle(
                  color: _getCategoryColor(category),
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return GestureDetector(
                onTap: () => _showElementDetail(category, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1 * 1.5),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withValues(alpha:0.1),
                    borderRadius: AppDimensions.borderRadiusLarge,
                    border: Border.all(
                      color: TossDesignSystem.white.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showElementDetail(String category, String element) {
    final symbolData = DreamElementsAnalysisService.symbolDatabase[element];
    if (symbolData == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: TossDesignSystem.transparent,
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
                color: TossDesignSystem.white.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Icon(
              _getCategoryIcon(category),
              size: 48,
              color: _getCategoryColor(category),
            ),
            const SizedBox(height: AppSpacing.spacing3),
            Text(
              element,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              symbolData['meaning'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spacing5),
            _buildMeaningSection(
              '긍정적 의미',
              symbolData['positive'],
              TossDesignSystem.successGreen,
            ),
            const SizedBox(height: AppSpacing.spacing3),
            _buildMeaningSection(
              '부정적 의미',
              symbolData['negative'],
              TossDesignSystem.warningOrange,
            ),
            const SizedBox(height: AppSpacing.spacing3),
            _buildMeaningSection(
              '심리학적 해석',
              symbolData['psychological'],
              TossDesignSystem.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningSection(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.spacing1),
          Text(
            content,
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha:0.8),
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '동물': return TossDesignSystem.warningOrange;
      case '사람':
        return TossDesignSystem.primaryBlue;
      case '장소':
        return TossDesignSystem.successGreen;
      case '행동':
        return TossDesignSystem.errorRed;
      case '사물':
        return TossDesignSystem.warningOrange;
      case '자연':
        return TossDesignSystem.successGreen;
      case '색상':
        return TossDesignSystem.purple;
      case '감정': 
        return TossDesignSystem.purple;
      default:
        return TossDesignSystem.gray500;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '동물': return Icons.pets;
      case '사람':
        return Icons.people;
      case '장소':
        return Icons.location_on;
      case '행동':
        return Icons.directions_run;
      case '사물':
        return Icons.category;
      case '자연':
        return Icons.nature;
      case '색상':
        return Icons.palette;
      case '감정': 
        return Icons.favorite;
      default:
        return Icons.help_outline;
    }
  }
}