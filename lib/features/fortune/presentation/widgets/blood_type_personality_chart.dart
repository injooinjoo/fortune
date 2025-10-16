import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/blood_type_analysis_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class BloodTypePersonalityChart extends StatefulWidget {
  final String bloodType;
  final String rhType;
  final bool showAnimation;

  const BloodTypePersonalityChart({
    super.key,
    required this.bloodType,
    required this.rhType,
    this.showAnimation = true,
  });

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
      vsync: this)..repeat();
    
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
        const SizedBox(height: AppSpacing.spacing5),
        _buildTabSelector(),
        const SizedBox(height: AppSpacing.spacing5),
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
                height: AppSpacing.spacing20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.errorRed.withValues(alpha: 0.6),
                      TossDesignSystem.errorRed.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.errorRed.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${widget.bloodType}${widget.rhType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacing5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.bloodType}형 ${widget.rhType} 혈액형',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TossDesignSystem.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing1),
                  Text(
                    '${characteristics['element']} 원소 · ${rhData['description']}',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                duration: TossDesignSystem.durationShort,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)])
                      : null,
                  borderRadius: AppDimensions.borderRadiusSmall),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha: 0.7),
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
                padding: AppSpacing.paddingAll20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '성격 개요',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TossDesignSystem.white)),
                    const SizedBox(height: AppSpacing.spacing3),
                    Text(
                      characteristics['personality'],
                      style: Theme.of(context).textTheme.bodyMedium)])),
              const SizedBox(height: AppSpacing.spacing4),
              Row(
                children: [
                  Expanded(
                    child: _buildTraitCard(
                      '긍정적 특성',
                      characteristics['positive_traits'],
                      TossDesignSystem.successGreen,
                      Icons.thumb_up)),
                  const SizedBox(width: AppSpacing.spacing4),
                  Expanded(
                    child: _buildTraitCard(
                      '부정적 특성',
                      characteristics['negative_traits'],
                      TossDesignSystem.warningOrange,
                      Icons.thumb_down))]),
              const SizedBox(height: AppSpacing.spacing4),
              _buildLifeStyleCard(characteristics),
              const SizedBox(height: AppSpacing.spacing4),
              _buildRhInfluence(rhData)]));
    });
  }

  Widget _buildTraitCard(String title, List<String> traits, Color color, IconData icon) {
    return GlassContainer(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: AppDimensions.borderRadiusSmall),
                child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: AppSpacing.spacing3),
          ...traits.map((trait) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing2),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: AppSpacing.spacing1 * 1.5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  trait,
                  style: Theme.of(context).textTheme.bodyMedium)])))]));
  }

  Widget _buildLifeStyleCard(Map<String, dynamic> characteristics) {
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '라이프스타일',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white)),
          const SizedBox(height: AppSpacing.spacing4),
          _buildLifeStyleItem(
            '연애 스타일',
            characteristics['love_style'],
            Icons.favorite,
            TossDesignSystem.pinkPrimary),
          const SizedBox(height: AppSpacing.spacing3),
          _buildLifeStyleItem(
            '업무 스타일',
            characteristics['work_style'],
            Icons.work,
            TossDesignSystem.tossBlue),
          const SizedBox(height: AppSpacing.spacing3),
          _buildLifeStyleItem(
            '스트레스 반응',
            characteristics['stress_response'],
            Icons.psychology,
            TossDesignSystem.purple),
          const SizedBox(height: AppSpacing.spacing3),
          _buildLifeStyleItem(
            '건강 조언',
            characteristics['health_tips'],
            Icons.health_and_safety,
            TossDesignSystem.successGreen)]));
  }

  Widget _buildLifeStyleItem(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: AppDimensions.borderRadiusSmall),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: AppSpacing.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.spacing1),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          TossDesignSystem.purple.withValues(alpha: 0.1),
          TossDesignSystem.purple.withValues(alpha: 0.05)]),
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science,
                color: TossDesignSystem.purple,
                size: 20),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                'Rh${widget.rhType} 특성',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            rhData['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.spacing2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (rhData['traits'] as List<String>).map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1 * 1.5),
                decoration: BoxDecoration(
                  color: TossDesignSystem.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TossDesignSystem.purple.withValues(alpha: 0.4),
                    width: 1)),
                child: Text(
                  trait,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
          ),
          if (rhData.containsKey('special_note')) ...[
            const SizedBox(height: AppSpacing.spacing3),
            Container(
              padding: AppSpacing.paddingAll12,
              decoration: BoxDecoration(
                color: TossDesignSystem.warningYellow.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall,
                border: Border.all(
                  color: TossDesignSystem.warningYellow.withValues(alpha: 0.3),
                  width: 1)),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: TossDesignSystem.warningYellow,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      rhData['special_note'],
                      style: Theme.of(context).textTheme.bodyMedium,
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
      _selectedDate);
    
    return Column(
      children: [
        GlassContainer(
          padding: AppSpacing.paddingAll16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '선택된 날짜',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      width: 1)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: AppSpacing.spacing2),
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
        const SizedBox(height: AppSpacing.spacing5),
        AnimatedBuilder(
          animation: _biorhythmController,
          builder: (context, child) {
            return GlassContainer(
              padding: AppSpacing.paddingAll20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 바이오리듬',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TossDesignSystem.white)),
                  const SizedBox(height: AppSpacing.spacing5),
                  ...biorhythm.entries.map((entry) {
                    final color = _getBiorhythmColor(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.spacing4),
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
                                    height: AppSpacing.spacing2,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.spacing2),
                                  Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Text(
                                '${(entry.value * 100).toInt()}%',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spacing2),
                          ClipRRect(
                            borderRadius: AppDimensions.borderRadiusSmall,
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
                  }),
                ],
              ),
            );
          }),
        ],
      );
  }

  Widget _buildStrengthRadar() {
    final strengths = BloodTypeAnalysisService.analyzePersonalityStrengths(
      widget.bloodType,
      widget.rhType
    );
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassContainer(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성격 강도 분석',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.white)),
                const SizedBox(height: AppSpacing.spacing5),
                SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      radarBorderData: BorderSide(
                        color: TossDesignSystem.white.withValues(alpha: 0.3),
                        width: 2),
                      gridBorderData: BorderSide(
                        color: TossDesignSystem.white.withValues(alpha: 0.2),
                        width: 1),
                      tickBorderData: BorderSide(
                        color: TossDesignSystem.white.withValues(alpha: 0.2),
                        width: 1),
                      titlePositionPercentageOffset: 0.2,
                      radarBackgroundColor: TossDesignSystem.transparent,
                      dataSets: [
                        RadarDataSet(
                          fillColor: TossDesignSystem.errorRed.withValues(alpha: 0.3),
                          borderColor: TossDesignSystem.errorRed,
                          borderWidth: 2,
                          dataEntries: strengths.entries
                              .map((e) => RadarEntry(value: e.value * 100))
                              .toList())],
                      getTitle: (index, angle) {
                        final titles = strengths.keys.toList();
                        return RadarChartTitle(
                          text: titles[index],
                          angle: 0);
                      },
                      tickCount: 5,
                      ticksTextStyle: TextStyle(
                        color: TossDesignSystem.white.withValues(alpha: 0.5),
                        fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                      titleTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing5),
                _buildStrengthLegend(strengths),
              ],
            ),
          ),
        );
      });
  }
  
  Widget _buildStrengthLegend(Map<String, double> strengths) {
    final sortedStrengths = strengths.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 강점',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.spacing3),
        ...sortedStrengths.take(3).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing2),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: TossDesignSystem.warningYellow,
                  size: 16),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${(entry.value * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getBiorhythmColor(String type) {
    switch (type) {
      case '체력': return TossDesignSystem.errorRed;
      case '감정':
        return TossDesignSystem.tossBlue;
      case '지성':
        return TossDesignSystem.successGreen;
      case '직관':
        return TossDesignSystem.purple;
      case '사회성': return TossDesignSystem.warningOrange;
      default:
        return TossDesignSystem.gray400;
    }
  }
}