import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/blood_type_analysis_service.dart';

class BloodTypePersonalityChart extends StatefulWidget {
  final String bloodType;
  final String rhType;
  final bool showAnimation;

  const BloodTypePersonalityChart({
    Key? key,
    required this.bloodType,
    required this.rhType,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<BloodTypePersonalityChart> createState() => _BloodTypePersonalityChartState();
}

class _BloodTypePersonalityChartState extends State<BloodTypePersonalityChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _biorhythmController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  int _selectedTab = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _biorhythmController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _biorhythmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildTabSelector(),
        const SizedBox(height: 20),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
    final characteristics = BloodTypeAnalysisService.bloodTypeCharacteristics[widget.bloodType]!;
    final rhData = BloodTypeAnalysisService.rhCharacteristics[widget.rhType]!;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${widget.bloodType}${widget.rhType}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.bloodType}형 ${widget.rhType} 혈액형',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${characteristics['element']} 원소 · ${rhData['description']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['성격 분석', '바이오리듬', '특성 강도'];
    
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPersonalityAnalysis();
      case 1:
        return _buildBiorhythm();
      case 2:
        return _buildStrengthRadar();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalityAnalysis() {
    final characteristics = BloodTypeAnalysisService.bloodTypeCharacteristics[widget.bloodType]!;
    final rhData = BloodTypeAnalysisService.rhCharacteristics[widget.rhType]!;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '성격 개요',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      characteristics['personality'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTraitCard(
                      '긍정적 특성',
                      characteristics['positive_traits'] as List<String>,
                      Colors.green,
                      Icons.thumb_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTraitCard(
                      '부정적 특성',
                      characteristics['negative_traits'] as List<String>,
                      Colors.orange,
                      Icons.thumb_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLifeStyleCard(characteristics),
              const SizedBox(height: 16),
              _buildRhInfluence(rhData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTraitCard(String title, List<String> traits, Color color, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...traits.map((trait) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trait,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildLifeStyleCard(Map<String, dynamic> characteristics) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '라이프스타일',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildLifeStyleItem(
            '연애 스타일',
            characteristics['love_style'],
            Icons.favorite,
            Colors.pink,
          ),
          const SizedBox(height: 12),
          _buildLifeStyleItem(
            '업무 스타일',
            characteristics['work_style'],
            Icons.work,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildLifeStyleItem(
            '스트레스 반응',
            characteristics['stress_response'],
            Icons.psychology,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildLifeStyleItem(
            '건강 조언',
            characteristics['health_tips'],
            Icons.health_and_safety,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildLifeStyleItem(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRhInfluence(Map<String, dynamic> rhData) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.1),
          Colors.purple.withValues(alpha: 0.05),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rh${widget.rhType} 특성',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rhData['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (rhData['traits'] as List<String>).map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  trait,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
          if (rhData.containsKey('special_note')) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rhData['special_note'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBiorhythm() {
    final biorhythm = BloodTypeAnalysisService.calculateDailyBiorhythm(
      widget.bloodType,
      widget.rhType,
      _selectedDate,
    );
    
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '선택된 날짜',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.year}.${_selectedDate.month}.${_selectedDate.day}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _biorhythmController,
          builder: (context, child) {
            return GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 바이오리듬',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...biorhythm.entries.map((entry) {
                    final color = _getBiorhythmColor(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(entry.value * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.value,
                              backgroundColor: color.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStrengthRadar() {
    final strengths = BloodTypeAnalysisService.analyzePersonalityStrengths(
      widget.bloodType,
      widget.rhType,
    );
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성격 강도 분석',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      radarBorderData: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      gridBorderData: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      tickBorderData: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      titlePositionPercentageOffset: 0.2,
                      radarBackgroundColor: Colors.transparent,
                      dataSets: [
                        RadarDataSet(
                          fillColor: Colors.red.withValues(alpha: 0.3),
                          borderColor: Colors.red,
                          borderWidth: 2,
                          dataEntries: strengths.entries
                              .map((e) => RadarEntry(value: e.value * 100))
                              .toList(),
                        ),
                      ],
                      getTitle: (index, angle) {
                        final titles = strengths.keys.toList();
                        return RadarChartTitle(
                          text: titles[index],
                          angle: 0,
                        );
                      },
                      tickCount: 5,
                      ticksTextStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                      titleTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStrengthLegend(strengths),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrengthLegend(Map<String, double> strengths) {
    final sortedStrengths = strengths.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 강점',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        ...sortedStrengths.take(3).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(entry.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getBiorhythmColor(String type) {
    switch (type) {
      case '체력':
        return Colors.red;
      case '감정':
        return Colors.blue;
      case '지성':
        return Colors.green;
      case '직관':
        return Colors.purple;
      case '사회성':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}