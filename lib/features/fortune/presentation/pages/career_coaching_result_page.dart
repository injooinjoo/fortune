import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../domain/models/career_coaching_model.dart';
import '../../../../services/career_coaching_service.dart';

class CareerCoachingResultPage extends ConsumerStatefulWidget {
  final CareerCoachingInput input;
  
  const CareerCoachingResultPage({
    super.key,
    required this.input,
  });

  @override
  ConsumerState<CareerCoachingResultPage> createState() => _CareerCoachingResultPageState();
}

class _CareerCoachingResultPageState extends ConsumerState<CareerCoachingResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CareerCoachingResult? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadResult();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResult() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Use the service provider for API integration
      final service = ref.read(careerCoachingServiceProvider);
      final result = await service.analyzeAndGenerateCoaching(widget.input);
      
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결과를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: TossDesignSystem.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return _buildLoadingView(isDark);
    }
    
    if (_result == null) {
      return const Scaffold(
        body: Center(
          child: Text('결과를 불러올 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.gray50,
      appBar: AppBar(
        backgroundColor: (isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white).withValues(alpha: 0.0),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '커리어 코칭 결과',
          style: TossDesignSystem.heading3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, 
            color: isDark ? TossDesignSystem.white : TossDesignSystem.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined,
              color: isDark ? TossDesignSystem.white : TossDesignSystem.black),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: TossDesignSystem.tossBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(2),
              labelColor: TossDesignSystem.white,
              unselectedLabelColor: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray600,
              labelStyle: TossDesignSystem.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: '종합'),
                Tab(text: '인사이트'),
                Tab(text: '액션플랜'),
                Tab(text: '성장전략'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(isDark),
                _buildInsightsTab(isDark),
                _buildActionPlanTab(isDark),
                _buildGrowthTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Health Score Card
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '커리어 건강도',
                  style: TossDesignSystem.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Circular Score
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: CircularScorePainter(
                          score: _result!.healthScore.overallScore,
                          gradientColors: [
                            TossDesignSystem.tossBlue,
                            TossDesignSystem.successGreen,
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_result!.healthScore.overallScore}',
                            style: TossDesignSystem.heading1.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: TossDesignSystem.tossBlue,
                            ),
                          ),
                          Text(
                            _getScoreLabel(_result!.healthScore.level),
                            style: TossDesignSystem.body2.copyWith(
                              color: TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                // Sub Scores
                _buildSubScores(),
                
                const SizedBox(height: 24),
                
                // Overall Assessment
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _result!.overallAssessment,
                    style: TossDesignSystem.body2.copyWith(
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          // Market Trends
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, 
                      color: TossDesignSystem.tossBlue, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '시장 트렌드',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? TossDesignSystem.textPrimaryDark : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildTrendItem(
                  '업계 전망',
                  _getTrendLabel(_result!.marketTrends.industryOutlook),
                  _getTrendColor(_result!.marketTrends.industryOutlook),
                  isDark,
                ),
                _buildTrendItem(
                  '수요 수준',
                  _getDemandLabel(_result!.marketTrends.demandLevel),
                  _getDemandColor(_result!.marketTrends.demandLevel),
                  isDark,
                ),
                _buildTrendItem(
                  '연봉 추세',
                  _result!.marketTrends.salaryTrend,
                  TossDesignSystem.gray800,
                  isDark,
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ...List.generate(_result!.keyInsights.length, (index) {
            final insight = _result!.keyInsights[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TossCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getInsightColor(insight.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(insight.icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      insight.title,
                                      style: TossDesignSystem.body1.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getImpactColor(insight.impact).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getImpactLabel(insight.impact),
                                      style: TossDesignSystem.caption.copyWith(
                                        color: _getImpactColor(insight.impact),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getCategoryLabel(insight.category),
                                style: TossDesignSystem.caption.copyWith(
                                  color: _getInsightColor(insight.category),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      insight.description,
                      style: TossDesignSystem.body2.copyWith(
                        height: 1.6,
                        color: TossDesignSystem.gray700,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 100 * index))
                .fadeIn(duration: 500.ms)
                .slideX(begin: 0.1),
            );
          }),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionPlanTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Focus Area
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: TossDesignSystem.warningOrange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '집중 영역',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _result!.thirtyDayPlan.focusArea,
                  style: TossDesignSystem.body2.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, 
                        color: TossDesignSystem.successGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '예상 성과: ${_result!.thirtyDayPlan.expectedOutcome}',
                          style: TossDesignSystem.caption.copyWith(
                            color: TossDesignSystem.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          // Weekly Actions
          ...List.generate(_result!.thirtyDayPlan.weeks.length, (index) {
            final week = _result!.thirtyDayPlan.weeks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TossCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: TossDesignSystem.tossBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${week.weekNumber}주',
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            week.theme,
                            style: TossDesignSystem.body1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ...week.tasks.map((task) => 
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: TossDesignSystem.gray400,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task,
                                style: TossDesignSystem.body2.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, 
                            color: TossDesignSystem.gray600, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              week.milestone,
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.gray600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 100 * index))
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1),
            );
          }),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGrowthTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Growth Roadmap
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.route, color: TossDesignSystem.tossBlue, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '성장 로드맵',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Journey Visual
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.gray200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '현재',
                                  style: TossDesignSystem.caption.copyWith(
                                    color: TossDesignSystem.gray600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _result!.growthRoadmap.currentStage,
                                  style: TossDesignSystem.body2.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Icon(Icons.arrow_forward, 
                        color: TossDesignSystem.tossBlue),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                                  TossDesignSystem.successGreen.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: TossDesignSystem.tossBlue,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '목표',
                                  style: TossDesignSystem.caption.copyWith(
                                    color: TossDesignSystem.tossBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _result!.growthRoadmap.nextStage,
                                  style: TossDesignSystem.body2.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: TossDesignSystem.tossBlue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, 
                        color: TossDesignSystem.gray600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '예상 기간: ${_result!.growthRoadmap.estimatedMonths}개월',
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  '핵심 마일스톤',
                  style: TossDesignSystem.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 8),
                
                ..._result!.growthRoadmap.keyMilestones.map((milestone) => 
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, 
                          color: TossDesignSystem.gray500, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            milestone,
                            style: TossDesignSystem.body2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          // Skill Recommendations
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: TossDesignSystem.warningOrange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '추천 스킬',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ..._result!.recommendations.skills.map((skill) => 
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(skill.priority).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPriorityColor(skill.priority).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                skill.name,
                                style: TossDesignSystem.body2.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(skill.priority),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getPriorityLabel(skill.priority),
                                style: TossDesignSystem.caption.copyWith(
                                  color: TossDesignSystem.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skill.reason,
                          style: TossDesignSystem.caption.copyWith(
                            color: TossDesignSystem.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSubScores() {
    final scores = [
      ('성장', _result!.healthScore.growthScore, TossDesignSystem.successGreen),
      ('만족도', _result!.healthScore.satisfactionScore, TossDesignSystem.warningOrange),
      ('시장경쟁력', _result!.healthScore.marketScore, TossDesignSystem.tossBlue),
      ('워라벨', _result!.healthScore.balanceScore, TossDesignSystem.purple),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: scores.map((score) => 
        Column(
          children: [
            Text(
              score.$1,
              style: TossDesignSystem.caption.copyWith(
                color: TossDesignSystem.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: score.$3.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${score.$2}',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: score.$3,
                  ),
                ),
              ),
            ),
          ],
        ).animate(delay: Duration(milliseconds: 100 * scores.indexOf(score)))
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8)),
      ).toList(),
    );
  }

  Widget _buildTrendItem(String label, String value, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TossDesignSystem.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Scaffold(
      backgroundColor: TossDesignSystem.gray50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.tossBlue),
            ),
            const SizedBox(height: 24),
            Text(
              '결과를 불러오는 중...',
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getScoreLabel(String level) {
    switch (level) {
      case 'excellent': return '매우 우수';
      case 'good': return '양호';
      case 'moderate': return '보통';
      case 'needs-attention': return '개선 필요';
      default: return level;
    }
  }

  String _getTrendLabel(String outlook) {
    switch (outlook) {
      case 'positive': return '긍정적';
      case 'stable': return '안정적';
      case 'challenging': return '도전적';
      default: return outlook;
    }
  }

  Color _getTrendColor(String outlook) {
    switch (outlook) {
      case 'positive': return TossDesignSystem.successGreen;
      case 'stable': return TossDesignSystem.tossBlue;
      case 'challenging': return TossDesignSystem.warningOrange;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getDemandLabel(String level) {
    switch (level) {
      case 'high': return '높음';
      case 'moderate': return '보통';
      case 'low': return '낮음';
      default: return level;
    }
  }

  Color _getDemandColor(String level) {
    switch (level) {
      case 'high': return TossDesignSystem.successGreen;
      case 'moderate': return TossDesignSystem.tossBlue;
      case 'low': return TossDesignSystem.warningOrange;
      default: return TossDesignSystem.gray600;
    }
  }

  Color _getInsightColor(String category) {
    switch (category) {
      case 'opportunity': return TossDesignSystem.successGreen;
      case 'warning': return TossDesignSystem.warningOrange;
      case 'trend': return TossDesignSystem.tossBlue;
      case 'advice': return TossDesignSystem.purple;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'opportunity': return '기회';
      case 'warning': return '주의';
      case 'trend': return '트렌드';
      case 'advice': return '조언';
      default: return category;
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'high': return TossDesignSystem.error;
      case 'medium': return TossDesignSystem.warningOrange;
      case 'low': return TossDesignSystem.gray600;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getImpactLabel(String impact) {
    switch (impact) {
      case 'high': return '높음';
      case 'medium': return '중간';
      case 'low': return '낮음';
      default: return impact;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical': return TossDesignSystem.error;
      case 'high': return TossDesignSystem.warningOrange;
      case 'medium': return TossDesignSystem.tossBlue;
      case 'low': return TossDesignSystem.gray600;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'critical': return '필수';
      case 'high': return '높음';
      case 'medium': return '중간';
      case 'low': return '낮음';
      default: return priority;
    }
  }
}

// Custom Painter for Circular Score
class CircularScorePainter extends CustomPainter {
  final int score;
  final List<Color> gradientColors;

  CircularScorePainter({
    required this.score,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = TossDesignSystem.gray200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * score / 100),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * score / 100,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}