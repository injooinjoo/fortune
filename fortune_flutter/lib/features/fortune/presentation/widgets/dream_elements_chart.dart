import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/dream_elements_analysis_service.dart';

class DreamElementsChart extends StatefulWidget {
  final Map<String, double> elementWeights;
  final Map<String, List<String>> elements;
  final bool showAnimation;

  const DreamElementsChart({
    Key? key,
    required this.elementWeights,
    required this.elements,
    this.showAnimation = true,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 1200),
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
        _buildChart(),
        const SizedBox(height: 20),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.deepPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${_getTotalElements()}개 요소 발견',
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
          height: 300,
          padding: const EdgeInsets.all(20),
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
                swapAnimationDuration: const Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
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
              color: Colors.white,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.5),
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
            color: Colors.white54,
          ),
          const SizedBox(height: 8),
          Text(
            '꿈 요소',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
          const SizedBox(height: 4),
          Text(
            category,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count개',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.elements.entries.where((e) => e.value.isNotEmpty).map((entry) {
          return _buildCategorySection(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.3),
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
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  color: _getCategoryColor(category),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return GestureDetector(
                onTap: () => _showElementDetail(category, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
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
            Icon(
              _getCategoryIcon(category),
              size: 48,
              color: _getCategoryColor(category),
            ),
            const SizedBox(height: 12),
            Text(
              element,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              symbolData['meaning'] as String,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 20),
            _buildMeaningSection(
              '긍정적 의미',
              symbolData['positive'] as String,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMeaningSection(
              '부정적 의미',
              symbolData['negative'] as String,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMeaningSection(
              '심리학적 해석',
              symbolData['psychological'] as String,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningSection(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '동물':
        return Colors.amber;
      case '사람':
        return Colors.blue;
      case '장소':
        return Colors.green;
      case '행동':
        return Colors.red;
      case '사물':
        return Colors.orange;
      case '자연':
        return Colors.teal;
      case '색상':
        return Colors.purple;
      case '감정':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '동물':
        return Icons.pets;
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