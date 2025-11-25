import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../domain/models/career_coaching_model.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';

class CareerCoachingResultPage extends ConsumerStatefulWidget {
  final CareerCoachingInput input;

  const CareerCoachingResultPage({
    super.key,
    required this.input,
  });

  @override
  ConsumerState<CareerCoachingResultPage> createState() => _CareerCoachingResultPageState();
}

class _CareerCoachingResultPageState extends ConsumerState<CareerCoachingResultPage> {
  FortuneResult? _fortuneResult;
  bool _isLoading = true;
  String? _error;

  // ✅ Blur state management
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔮 [커리어 코칭] 운세 생성 프로세스 시작');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 1️⃣ 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      debugPrint('');
      debugPrint('1️⃣ 프리미엄 상태 확인');
      debugPrint('   - isPremium: $isPremium');

      // 2️⃣ UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // Input conditions 준비
      final inputConditions = {
        'currentRole': widget.input.currentRole,
        'experienceLevel': widget.input.experienceLevel,
        'primaryConcern': widget.input.primaryConcern,
        'industry': widget.input.industry,
        'shortTermGoal': widget.input.shortTermGoal,
        'coreValue': widget.input.coreValue,
        'skillsToImprove': widget.input.skillsToImprove,
      };

      debugPrint('');
      debugPrint('2️⃣ UnifiedFortuneService.getFortune() 호출');
      debugPrint('   - fortuneType: career_coaching');
      debugPrint('   - isPremium: $isPremium');

      final result = await fortuneService.getFortune(
        fortuneType: 'career_coaching',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        isPremium: isPremium, // ✅ 프리미엄 상태 전달
      );

      debugPrint('');
      debugPrint('3️⃣ 운세 생성 완료');
      debugPrint('   - result.isBlurred: ${result.isBlurred}');
      debugPrint('   - result.blurredSections: ${result.blurredSections}');

      if (mounted) {
        setState(() {
          _fortuneResult = result;
          _isLoading = false;

          // ✅ Blur 상태 동기화
          _isBlurred = result.isBlurred;
          _blurredSections = List<String>.from(result.blurredSections);
        });

        debugPrint('');
        debugPrint('✅ [커리어 코칭] 운세 생성 프로세스 완료!');
        if (result.isBlurred) {
          debugPrint('   → 블러된 섹션: ${result.blurredSections.join(", ")}');
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    } catch (e) {
      debugPrint('');
      debugPrint('❌ [커리어 코칭] 운세 생성 실패!');
      debugPrint('   에러: $e');

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // 4️⃣ 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📺 [광고] 광고 시청 & 블러 해제 프로세스 시작');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final adService = AdService();

      // 광고가 준비되지 않았으면 로드
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('광고를 준비하는 중...')),
          );
        }
        await adService.loadRewardedAd();
      }

      // 리워드 광고 표시
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('✅ 광고 시청 완료!');

          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('운세가 잠금 해제되었습니다!')),
            );
          }

          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('✅ [광고] 블러 해제 프로세스 완료!');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        },
      );
    } catch (e) {
      debugPrint('❌ [광고] 광고 표시 실패: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 에러 발생
    if (_error != null) {
      return _buildErrorView(isDark);
    }

    // ✅ 결과 화면 (단일 컬럼)
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            '커리어 코칭 결과',
            style: context.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
              onPressed: () => context.go('/fortune'),
            ),
          ],
        ),
        body: Stack(
          children: [
            // ✅ 단일 컬럼 스크롤 뷰
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          CircularProgressIndicator(
                            color: TossDesignSystem.tossBlue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '커리어 분석 중...',
                            style: context.bodyMedium.copyWith(
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _fortuneResult == null
                      ? Center(
                          child: Text(
                            '결과를 불러올 수 없습니다',
                            style: context.bodyMedium.copyWith(
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fortune 데이터 추출
                            Builder(
                              builder: (context) {
                                final fortuneData = _fortuneResult!.data as Map<String, dynamic>;
                                final healthScore = fortuneData['health_score'] as Map<String, dynamic>?;
                                final marketTrends = fortuneData['market_trends'] as Map<String, dynamic>?;
                                final insights = fortuneData['key_insights'] as List?;
                                final actionPlan = fortuneData['thirty_day_plan'] as Map<String, dynamic>?;
                                final growthRoadmap = fortuneData['growth_roadmap'] as Map<String, dynamic>?;
                                final recommendations = fortuneData['recommendations'] as Map<String, dynamic>?;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ 1. 종합 - 커리어 건강도 (항상 표시)
                          if (healthScore != null) ...[
                            _buildHealthScoreCard(healthScore, isDark),
                            const SizedBox(height: 16),
                          ],

                          // ✅ 2. 시장 트렌드 (항상 표시)
                          if (marketTrends != null) ...[
                            _buildMarketTrendsCard(marketTrends, isDark),
                            const SizedBox(height: 16),
                          ],

                          // ✅ 3. 핵심 인사이트 (블러 처리)
                          if (insights != null && insights.isNotEmpty) ...[
                            UnifiedBlurWrapper(
                              isBlurred: _isBlurred,
                              blurredSections: _blurredSections,
                              sectionKey: 'key_insights',
                              child: Column(
                                children: insights.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final insight = entry.value as Map<String, dynamic>;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: _buildInsightCard(insight, index, isDark),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          // ✅ 4. 30일 액션플랜 (블러 처리)
                          if (actionPlan != null) ...[
                            UnifiedBlurWrapper(
                              isBlurred: _isBlurred,
                              blurredSections: _blurredSections,
                              sectionKey: 'action_plan',
                              child: Column(
                                children: [
                                  _buildActionPlanCard(actionPlan, isDark),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],

                          // ✅ 5. 성장 로드맵 (블러 처리)
                          if (growthRoadmap != null) ...[
                            UnifiedBlurWrapper(
                              isBlurred: _isBlurred,
                              blurredSections: _blurredSections,
                              sectionKey: 'growth_roadmap',
                              child: Column(
                                children: [
                                  _buildGrowthRoadmapCard(growthRoadmap, isDark),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],

                          // ✅ 6. 추천 스킬 (블러 처리)
                          if (recommendations != null && recommendations['skills'] != null) ...[
                            UnifiedBlurWrapper(
                              isBlurred: _isBlurred,
                              blurredSections: _blurredSections,
                              sectionKey: 'recommendations',
                              child: _buildRecommendationsCard(
                                recommendations['skills'] as List,
                                isDark,
                              ),
                            ),
                          ],

                          const SizedBox(height: 100), // Bottom padding for floating button
                        ],
                      );
                    },
                  ),
                            ],
                          ),
            ),

            // ✅ 광고 버튼 (블러 상태일 때만)
            if (_isBlurred)
              UnifiedButton.floating(
                text: '🎁 광고 보고 전체 운세 보기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
              ),
          ],
        ),
      ),
    );
  }

  // ========== 섹션 빌더 메서드 ==========

  Widget _buildHealthScoreCard(Map<String, dynamic> healthScore, bool isDark) {
    final overallScore = healthScore['overall_score'] as int? ?? 0;
    final level = healthScore['level'] as String? ?? '';
    final growthScore = healthScore['growth_score'] as int? ?? 0;
    final satisfactionScore = healthScore['satisfaction_score'] as int? ?? 0;
    final marketScore = healthScore['market_score'] as int? ?? 0;
    final balanceScore = healthScore['balance_score'] as int? ?? 0;

    return TossCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '커리어 건강도',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
                    score: overallScore,
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
                      '$overallScore',
                      style: context.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TossDesignSystem.tossBlue,
                      ),
                    ),
                    Text(
                      _getScoreLabel(level),
                      style: context.bodyMedium.copyWith(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSubScore('성장', growthScore, TossDesignSystem.successGreen),
              _buildSubScore('만족도', satisfactionScore, TossDesignSystem.warningOrange),
              _buildSubScore('시장', marketScore, TossDesignSystem.tossBlue),
              _buildSubScore('워라벨', balanceScore, AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSubScore(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$score',
              style: context.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketTrendsCard(Map<String, dynamic> marketTrends, bool isDark) {
    final industryOutlook = marketTrends['industry_outlook'] as String? ?? '';
    final demandLevel = marketTrends['demand_level'] as String? ?? '';
    final salaryTrend = marketTrends['salary_trend'] as String? ?? '';

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: TossDesignSystem.tossBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                '시장 트렌드',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTrendItem('업계 전망', _getTrendLabel(industryOutlook), _getTrendColor(industryOutlook), isDark),
          _buildTrendItem('수요 수준', _getDemandLabel(demandLevel), _getDemandColor(demandLevel), isDark),
          _buildTrendItem('연봉 추세', salaryTrend, TossDesignSystem.gray800, isDark),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildTrendItem(String label, String value, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.bodyMedium.copyWith(
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
              style: context.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight, int index, bool isDark) {
    final icon = insight['icon'] as String? ?? '💡';
    final title = insight['title'] as String? ?? '';
    final category = insight['category'] as String? ?? '';
    final impact = insight['impact'] as String? ?? '';
    final description = insight['description'] as String? ?? '';

    return TossCard(
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
                  color: _getInsightColor(category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: context.displaySmall),
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
                            title,
                            style: context.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getImpactColor(impact).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getImpactLabel(impact),
                            style: context.labelSmall.copyWith(
                              color: _getImpactColor(impact),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryLabel(category),
                      style: context.labelMedium.copyWith(
                        color: _getInsightColor(category),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: context.bodyMedium.copyWith(
              height: 1.6,
              color: TossDesignSystem.gray700,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn(duration: 500.ms)
      .slideX(begin: 0.1);
  }

  Widget _buildActionPlanCard(Map<String, dynamic> actionPlan, bool isDark) {
    final focusArea = actionPlan['focus_area'] as String? ?? '';
    final expectedOutcome = actionPlan['expected_outcome'] as String? ?? '';
    final weeks = actionPlan['weeks'] as List? ?? [];

    return Column(
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
                    '30일 액션플랜',
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                focusArea,
                style: context.bodyMedium.copyWith(height: 1.5),
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
                    Icon(Icons.emoji_events, color: TossDesignSystem.successGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '예상 성과: $expectedOutcome',
                        style: context.labelMedium.copyWith(
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
        ),

        const SizedBox(height: 16),

        // Weekly Actions
        ...weeks.asMap().entries.map((entry) {
          final index = entry.key;
          final week = entry.value as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildWeekCard(week, index, isDark),
          );
        }),
      ],
    );
  }

  Widget _buildWeekCard(Map<String, dynamic> week, int index, bool isDark) {
    final weekNumber = week['week_number'] as int? ?? (index + 1);
    final theme = week['theme'] as String? ?? '';
    final tasks = week['tasks'] as List? ?? [];
    final milestone = week['milestone'] as String? ?? '';

    return TossCard(
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
                    '${weekNumber}주',
                    style: context.labelMedium.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  theme,
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...tasks.map((task) =>
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
                      task.toString(),
                      style: context.bodyMedium.copyWith(height: 1.5),
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
                Icon(Icons.flag_outlined, color: TossDesignSystem.gray600, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    milestone,
                    style: context.labelMedium.copyWith(
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
      .slideY(begin: 0.1);
  }

  Widget _buildGrowthRoadmapCard(Map<String, dynamic> growthRoadmap, bool isDark) {
    final currentStage = growthRoadmap['current_stage'] as String? ?? '';
    final nextStage = growthRoadmap['next_stage'] as String? ?? '';
    final estimatedMonths = growthRoadmap['estimated_months'] as int? ?? 0;
    final keyMilestones = growthRoadmap['key_milestones'] as List? ?? [];

    return TossCard(
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
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Journey Visual
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '현재',
                        style: context.labelSmall.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStage,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Icon(Icons.arrow_forward, color: TossDesignSystem.tossBlue),
              ),
              Expanded(
                child: Container(
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
                        style: context.labelSmall.copyWith(
                          color: TossDesignSystem.tossBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextStage,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TossDesignSystem.tossBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '예상 기간: ${estimatedMonths}개월',
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            '핵심 마일스톤',
            style: context.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 8),

          ...keyMilestones.map((milestone) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: TossDesignSystem.gray500, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      milestone.toString(),
                      style: context.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildRecommendationsCard(List skills, bool isDark) {
    return TossCard(
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
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...skills.map((skill) {
            final skillMap = skill as Map<String, dynamic>;
            final name = skillMap['name'] as String? ?? '';
            final priority = skillMap['priority'] as String? ?? '';
            final reason = skillMap['reason'] as String? ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getPriorityColor(priority).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getPriorityLabel(priority),
                          style: context.labelSmall.copyWith(
                            color: TossDesignSystem.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reason,
                    style: context.labelMedium.copyWith(
                      color: TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildLoadingView(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.tossBlue),
            ),
            const SizedBox(height: 24),
            Text(
              '커리어 분석 중...',
              style: context.bodyMedium.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '운세 생성 실패',
              style: context.heading3.copyWith(
                color: TossDesignSystem.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: context.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
                _loadResult();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Helper Methods ==========

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
      case 'advice': return AppTheme.primaryColor;
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
      case 'high': return TossDesignSystem.errorRed;
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
      case 'critical': return TossDesignSystem.errorRed;
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
