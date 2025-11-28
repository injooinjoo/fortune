import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../domain/models/career_coaching_model.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/services/debug_premium_service.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../services/ad_service.dart';
import 'widgets/index.dart';

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
                      : _buildResultContent(isDark),
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

  Widget _buildResultContent(bool isDark) {
    final fortuneData = _fortuneResult!.data;
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
          HealthScoreCard(healthScore: healthScore, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // ✅ 2. 시장 트렌드 (항상 표시)
        if (marketTrends != null) ...[
          MarketTrendsCard(marketTrends: marketTrends, isDark: isDark),
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
                  child: InsightCard(insight: insight, index: index, isDark: isDark),
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
                ActionPlanCard(actionPlan: actionPlan, isDark: isDark),
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
                GrowthRoadmapCard(growthRoadmap: growthRoadmap, isDark: isDark),
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
            child: RecommendationsCard(
              skills: recommendations['skills'] as List,
              isDark: isDark,
            ),
          ),
        ],

        const SizedBox(height: 100), // Bottom padding for floating button
      ],
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
}
