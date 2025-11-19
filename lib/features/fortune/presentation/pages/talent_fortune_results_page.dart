/// 재능 발견 운세 결과 페이지
///
/// UnifiedFortuneService를 사용하여 LLM 분석 데이터 표시:
/// - API 호출로 상세 재능 분석 데이터 수신
/// - 블러 처리된 프리미엄 콘텐츠
/// - 광고 시청 후 블러 해제
library;

import 'dart:ui'; // ✅ ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../domain/models/talent_input_model.dart';
import '../../domain/models/sipseong_talent.dart';
import '../../domain/models/saju_elements.dart';
import '../../data/services/saju_calculator.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/token_provider.dart'; // ✅ Premium 체크용
import '../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../shared/components/floating_bottom_button.dart'; // ✅ FloatingBottomButton용
import '../../../../core/utils/logger.dart'; // ✅ 로그용
import '../../../../core/services/unified_fortune_service.dart'; // ✅ UnifiedFortuneService
import '../../../../core/models/fortune_result.dart'; // ✅ FortuneResult

class TalentFortuneResultsPage extends ConsumerStatefulWidget {
  final TalentInputData inputData;
  final FortuneResult? fortuneResult; // ✅ 입력 페이지에서 전달받은 API 결과

  const TalentFortuneResultsPage({
    super.key,
    required this.inputData,
    this.fortuneResult, // ✅ Optional - 전달되지 않으면 직접 호출
  });

  @override
  ConsumerState<TalentFortuneResultsPage> createState() => _TalentFortuneResultsPageState();
}

class _TalentFortuneResultsPageState extends ConsumerState<TalentFortuneResultsPage> {
  // API 응답 데이터
  FortuneResult? _fortuneResult;
  bool _isLoading = true;
  String? _error;

  // 로컬 사주 계산 (기본 정보용)
  late Map<String, dynamic> _sajuResult;
  late WuxingDistribution _wuxingDistribution;
  late List<SipseongTalent> _top3Talents;
  late List<Map<String, dynamic>> _daeunList;
  late int _currentAge;

  // Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  late UnifiedFortuneService _fortuneService;

  @override
  void initState() {
    super.initState();
    _fortuneService = UnifiedFortuneService(Supabase.instance.client);

    // ✅ 입력 페이지에서 전달받은 결과가 있으면 바로 사용
    if (widget.fortuneResult != null) {
      Logger.info('[TalentFortune] ✅ 전달받은 API 결과 사용');
      Logger.info('[TalentFortune] 📊 FortuneResult 상세:');
      Logger.info('[TalentFortune]   - Type: ${widget.fortuneResult!.type}');
      Logger.info('[TalentFortune]   - Score: ${widget.fortuneResult!.score}');
      Logger.info('[TalentFortune]   - isBlurred: ${widget.fortuneResult!.isBlurred}');
      Logger.info('[TalentFortune]   - blurredSections: ${widget.fortuneResult!.blurredSections}');
      Logger.info('[TalentFortune]   - Data keys: ${widget.fortuneResult!.data.keys.toList()}');
      Logger.info('[TalentFortune]   - Summary keys: ${widget.fortuneResult!.summary.keys.toList()}');

      // 🔍 API 데이터 상세 확인
      Logger.info('[TalentFortune] 🎯 API 데이터 내용:');
      Logger.info('[TalentFortune]   - content: ${widget.fortuneResult!.data['content']}');
      Logger.info('[TalentFortune]   - description: ${widget.fortuneResult!.data['description']}');
      Logger.info('[TalentFortune]   - hexagonScores: ${widget.fortuneResult!.data['hexagonScores']}');
      Logger.info('[TalentFortune]   - talentInsights: ${widget.fortuneResult!.data['talentInsights']}');
      Logger.info('[TalentFortune]   - weeklyPlan: ${widget.fortuneResult!.data['weeklyPlan']}');
      Logger.info('[TalentFortune]   - luckyItems: ${widget.fortuneResult!.data['luckyItems']}');

      _fortuneResult = widget.fortuneResult;
      _isBlurred = widget.fortuneResult!.isBlurred;
      _blurredSections = widget.fortuneResult!.blurredSections;
      _isLoading = false;
      _calculateLocalSaju(); // 로컬 사주만 계산
    } else {
      // ✅ 전달받은 결과가 없으면 직접 호출 (fallback)
      Logger.warning('[TalentFortune] ⚠️ 전달받은 결과 없음 → API 직접 호출');
      _loadFortuneData();
    }
  }

  /// API 호출 + 로컬 사주 계산 (fallback용)
  Future<void> _loadFortuneData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Logger.info('[TalentFortune] 🎯 운세 데이터 로딩 시작');

      // 1. 로컬 사주 계산 (기본 정보용)
      _calculateLocalSaju();

      // 2. Premium 체크
      final tokenState = ref.read(tokenProvider);
      final isPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      Logger.info('[TalentFortune] 💎 Premium 상태: $isPremium');

      // 3. UnifiedFortuneService로 LLM 분석 호출
      final inputConditions = {
        'birth_date': widget.inputData.birthDate!.toIso8601String().split('T')[0],
        'birth_time': '${widget.inputData.birthTime!.hour.toString().padLeft(2, '0')}:${widget.inputData.birthTime!.minute.toString().padLeft(2, '0')}',
        'gender': widget.inputData.gender!,
        if (widget.inputData.birthCity != null)
          'birth_city': widget.inputData.birthCity!,
        if (widget.inputData.currentOccupation != null)
          'current_occupation': widget.inputData.currentOccupation!,
        'concern_areas': widget.inputData.concernAreas,
        'interest_areas': widget.inputData.interestAreas,
        if (widget.inputData.selfStrengths != null)
          'self_strengths': widget.inputData.selfStrengths!,
        if (widget.inputData.selfWeaknesses != null)
          'self_weaknesses': widget.inputData.selfWeaknesses!,
        'work_style': widget.inputData.workStyle,
        'energy_source': widget.inputData.energySource,
        'problem_solving': widget.inputData.problemSolving,
        'preferred_role': widget.inputData.preferredRole,
        'isPremium': isPremium,
      };

      Logger.info('[TalentFortune] 📡 API 호출 준비');
      Logger.info('[TalentFortune]   concern_areas: ${widget.inputData.concernAreas}');
      Logger.info('[TalentFortune]   interest_areas: ${widget.inputData.interestAreas}');

      final fortuneResult = await _fortuneService.getFortune(
        fortuneType: 'talent',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        isPremium: isPremium,
      );

      Logger.info('[TalentFortune] ✅ API 응답 수신');
      Logger.info('[TalentFortune]   Title: ${fortuneResult.title}');
      Logger.info('[TalentFortune]   Score: ${fortuneResult.score}');
      Logger.info('[TalentFortune]   IsBlurred: ${fortuneResult.isBlurred}');

      setState(() {
        _fortuneResult = fortuneResult;
        _isBlurred = fortuneResult.isBlurred;
        _blurredSections = fortuneResult.blurredSections;
        _isLoading = false;
      });

      Logger.info('[TalentFortune] 🎨 UI 렌더링 완료');
    } catch (e, stackTrace) {
      Logger.error('[TalentFortune] ❌ API 호출 실패', e, stackTrace);

      // Fallback: 로컬 사주만 표시
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isBlurred = false; // 에러 시 블러 없이 로컬 데이터 표시
      });
    }
  }

  /// 로컬 사주 계산 (API 실패 시 fallback용)
  void _calculateLocalSaju() {
    final birthDate = widget.inputData.birthDate!;
    final birthTime = widget.inputData.birthTime!;
    final gender = widget.inputData.gender!;

    // 현재 나이 계산
    final now = DateTime.now();
    _currentAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      _currentAge--;
    }

    Logger.info('[TalentFortune] 🎂 나이 계산:');
    Logger.info('[TalentFortune]   - 생년월일: $birthDate');
    Logger.info('[TalentFortune]   - 현재 날짜: $now');
    Logger.info('[TalentFortune]   - 계산된 나이: $_currentAge살');

    // 사주 계산
    _sajuResult = SajuCalculator.calculateSaju(
      birthDate,
      birthTime.hour,
      birthTime.minute,
    );

    // 오행 분포
    _wuxingDistribution = WuxingDistribution.fromCounts(_sajuResult['wuxing']);

    // 십성 분석
    final sipseongCounts = SajuCalculator.analyzeSipseongInSaju(_sajuResult);
    _top3Talents = SipseongTalentProvider.getTop3Talents(sipseongCounts);

    // 대운 계산
    _daeunList = SajuCalculator.calculateDaeun(birthDate, gender, _currentAge);

    Logger.info('[TalentFortune] ✅ 로컬 사주 계산 완료');
  }

  // ✅ Phase 5: 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    debugPrint('[TalentFortune] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[TalentFortune] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[TalentFortune] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[TalentFortune] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[TalentFortune] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  // ✅ Phase 6: Blur wrapper helper
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: StandardFortuneAppBar(
        title: '재능 발견 결과',
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : Stack(
                  children: [
                    // 메인 콘텐츠
                    SingleChildScrollView(
            child: Column(
              children: [
                // Part 1: 종합 브리핑
                _buildOverviewSection(isDark)
                    .animate()
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // Part 2: TOP 3 재능 인사이트 (Premium - LLM 분석)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBlurWrapper(
                    sectionKey: 'top3_talents',
                    child: _buildTalentInsights(isDark)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ),
                ),

                const SizedBox(height: 24),

                // Part 3: 주간 실행 계획 (Premium - LLM 분석)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBlurWrapper(
                    sectionKey: 'career_roadmap',
                    child: _buildWeeklyPlan(isDark)
                      .animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ),
                ),

                const SizedBox(height: 24),

                // Part 4: 상세 분석 & 육각형 스탯 (Premium - LLM 분석)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBlurWrapper(
                    sectionKey: 'growth_timeline',
                    child: Column(
                      children: [
                        _buildDetailedAnalysis(isDark),
                        const SizedBox(height: 16),
                        // ✅ 신규: 멘탈 모델 분석
                        _buildMentalModel(isDark),
                        const SizedBox(height: 16),
                        // ✅ 신규: 협업 궁합
                        _buildCollaboration(isDark),
                        const SizedBox(height: 16),
                        // ✅ 신규: 성장 로드맵
                        _buildGrowthRoadmap(isDark),
                        const SizedBox(height: 16),
                        // ✅ 신규: 학습 전략
                        _buildLearningStrategy(isDark),
                      ],
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                  ),
                ),

                const SizedBox(height: 100), // 버튼 공간 확보
              ],
            ),
          ),

          // ✅ FloatingBottomButton (블러 상태일 때만 표시)
          if (_isBlurred)
            FloatingBottomButton(
              text: '광고 보고 전체 내용 확인하기',
              onPressed: _showAdAndUnblur,
              isEnabled: true,
            ),
                  ],
                ),
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: TossDesignSystem.tossBlue,
          ),
          const SizedBox(height: 24),
          Text(
            '재능을 분석하고 있어요...',
            style: TypographyUnified.bodyMedium.copyWith(
              color: TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'LLM이 당신의 사주와 성향을 분석 중입니다',
            style: TypographyUnified.labelMedium.copyWith(
              color: TossDesignSystem.gray500,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: TossDesignSystem.errorRed,
            ),
            const SizedBox(height: 24),
            Text(
              '운세 데이터를 불러오지 못했어요',
              style: TypographyUnified.heading3.copyWith(
                color: TossDesignSystem.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? '알 수 없는 오류',
              style: TypographyUnified.bodySmall.copyWith(
                color: TossDesignSystem.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadFortuneData,
              style: ElevatedButton.styleFrom(
                backgroundColor: TossDesignSystem.tossBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                '다시 시도',
                style: TypographyUnified.buttonMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '로컬 사주 분석 데이터로 기본 정보를 확인할 수 있습니다',
              style: TypographyUnified.labelSmall.copyWith(
                color: TossDesignSystem.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Part 1: 종합 브리핑 (LLM 분석 결과)
  Widget _buildOverviewSection(bool isDark) {
    // ✅ API 데이터 사용 (content - 항상 공개)
    final content = _fortuneResult?.data['content'] as String? ?? '';
    final score = _fortuneResult?.score ?? 0;
    final luckyItems = _fortuneResult?.data['luckyItems'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.tossBlue.withOpacity(0.1),
            TossDesignSystem.tossBlueDark.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '재능 발견 운세',
                        style: TypographyUnified.heading1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'LLM이 분석한 당신의 재능과 잠재력',
                        style: TypographyUnified.bodySmall.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ 종합 점수 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.tossBlue,
                        TossDesignSystem.tossBlueDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score점',
                        style: TypographyUnified.heading2.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '재능 점수',
                        style: TypographyUnified.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ✅ LLM 분석 브리핑 (항상 공개)
            if (content.isNotEmpty)
              TossCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: TossDesignSystem.tossBlue,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI 재능 브리핑',
                          style: TypographyUnified.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: TypographyUnified.bodyMedium.copyWith(
                        height: 1.7,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

            if (content.isNotEmpty) const SizedBox(height: 16),

            // ✅ 행운 아이템 (항상 공개)
            if (luckyItems != null)
              TossCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: TossDesignSystem.warningOrange,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '행운 아이템',
                          style: TypographyUnified.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLuckyItem('색상', luckyItems['color'] as String? ?? '', Icons.palette, isDark),
                    _buildLuckyItem('숫자', '${luckyItems['number'] ?? ''}', Icons.filter_9_plus, isDark),
                    _buildLuckyItem('방향', luckyItems['direction'] as String? ?? '', Icons.explore, isDark),
                    _buildLuckyItem('도구', luckyItems['tool'] as String? ?? '', Icons.build_circle, isDark),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 행운 아이템 개별 항목
  Widget _buildLuckyItem(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: TossDesignSystem.tossBlue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: TypographyUnified.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Part 2: 재능 인사이트 (LLM 분석 - talentInsights) ✅ 확장됨
  Widget _buildTalentInsights(bool isDark) {
    final talentInsights = _fortuneResult?.data['talentInsights'] as List<dynamic>? ?? [];

    if (talentInsights.isEmpty) {
      return TossCard(
        child: Center(
          child: Text(
            '재능 인사이트 데이터가 없습니다',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: TossDesignSystem.warningOrange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'TOP ${talentInsights.length} 재능 인사이트',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...talentInsights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value as Map<String, dynamic>;
            final talent = insight['talent'] as String? ?? '';
            final potential = insight['potential'] as int? ?? 0;
            final description = insight['description'] as String? ?? '';
            final developmentPath = insight['developmentPath'] as String? ?? '';
            final practicalApplications = (insight['practicalApplications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final monetizationStrategy = insight['monetizationStrategy'] as String? ?? '';
            final portfolioBuilding = insight['portfolioBuilding'] as String? ?? '';
            final recommendedResources = (insight['recommendedResources'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

            return Padding(
              padding: EdgeInsets.only(bottom: index < talentInsights.length - 1 ? 16 : 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.tossBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                TossDesignSystem.tossBlue,
                                TossDesignSystem.tossBlueDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: TypographyUnified.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            talent,
                            style: TypographyUnified.heading4.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                            ),
                          ),
                        ),
                        Text(
                          '$potential점',
                          style: TypographyUnified.buttonMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: TypographyUnified.bodySmall.copyWith(
                          height: 1.6,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                      ),
                    ],
                    if (developmentPath.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.tossBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📈 6개월 개발 로드맵',
                              style: TypographyUnified.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: TossDesignSystem.tossBlue,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              developmentPath,
                              style: TypographyUnified.bodySmall.copyWith(
                                height: 1.5,
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ✅ 신규: 실전 활용법
                    if (practicalApplications.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '💼 실전 활용법',
                        style: TypographyUnified.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.warningOrange,
                        ),
                      ),
                      SizedBox(height: 6),
                      ...practicalApplications.map((app) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TypographyUnified.bodySmall),
                            Expanded(
                              child: Text(
                                app,
                                style: TypographyUnified.bodySmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    // ✅ 신규: 수익화 전략
                    if (monetizationStrategy.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.successGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💰 수익화 전략',
                              style: TypographyUnified.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: TossDesignSystem.successGreen,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              monetizationStrategy,
                              style: TypographyUnified.bodySmall.copyWith(
                                height: 1.5,
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ✅ 신규: 포트폴리오 구축
                    if (portfolioBuilding.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.warningOrange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📁 포트폴리오 구축',
                              style: TypographyUnified.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: TossDesignSystem.warningOrange,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              portfolioBuilding,
                              style: TypographyUnified.bodySmall.copyWith(
                                height: 1.5,
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ✅ 신규: 추천 리소스
                    if (recommendedResources.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '📚 추천 리소스',
                        style: TypographyUnified.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.tossBlue,
                        ),
                      ),
                      SizedBox(height: 6),
                      ...recommendedResources.map((resource) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TypographyUnified.bodySmall),
                            Expanded(
                              child: Text(
                                resource,
                                style: TypographyUnified.bodySmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Part 3: 주간 실행 계획 (LLM 분석 - weeklyPlan)
  Widget _buildWeeklyPlan(bool isDark) {
    final weeklyPlan = _fortuneResult?.data['weeklyPlan'] as List<dynamic>? ?? [];

    if (weeklyPlan.isEmpty) {
      return TossCard(
        child: Center(
          child: Text(
            '주간 계획 데이터가 없습니다',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: TossDesignSystem.tossBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '7일 실행 계획',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...weeklyPlan.asMap().entries.map((entry) {
            final index = entry.key;
            final dayPlan = entry.value as Map<String, dynamic>;
            final day = dayPlan['day'] as String? ?? '';
            final focus = dayPlan['focus'] as String? ?? '';
            final activities = (dayPlan['activities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final timeNeeded = dayPlan['timeNeeded'] as String? ?? '';
            final checklist = (dayPlan['checklist'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final expectedOutcome = dayPlan['expectedOutcome'] as String? ?? '';

            return Padding(
              padding: EdgeInsets.only(bottom: index < weeklyPlan.length - 1 ? 12 : 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: TossDesignSystem.tossBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TypographyUnified.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: TossDesignSystem.tossBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: TypographyUnified.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                                ),
                              ),
                              if (timeNeeded.isNotEmpty)
                                Text(
                                  timeNeeded,
                                  style: TypographyUnified.labelSmall.copyWith(
                                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (focus.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.tossBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🎯 $focus',
                          style: TypographyUnified.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ),
                    ],
                    if (activities.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...activities.map((activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TypographyUnified.bodySmall.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                activity,
                                style: TypographyUnified.bodySmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    // ✅ 신규: 체크리스트
                    if (checklist.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '✅ 체크리스트',
                        style: TypographyUnified.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...checklist.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_box_outline_blank,
                              size: 16,
                              color: TossDesignSystem.successGreen,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item,
                                style: TypographyUnified.labelSmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    // ✅ 신규: 기대 효과
                    if (expectedOutcome.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.successGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: TossDesignSystem.successGreen.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.stars,
                              color: TossDesignSystem.successGreen,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                expectedOutcome,
                                style: TypographyUnified.labelSmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Part 4: 상세 분석 & 육각형 스탯 (LLM 분석 - description, hexagonScores)
  Widget _buildDetailedAnalysis(bool isDark) {
    final description = _fortuneResult?.data['description'] as String? ?? '';
    final hexagonScores = _fortuneResult?.data['hexagonScores'] as Map<String, dynamic>?;

    return Column(
      children: [
        // 상세 분석
        if (description.isNotEmpty)
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: TossDesignSystem.tossBlue,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '상세 분석',
                      style: TypographyUnified.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TypographyUnified.bodyMedium.copyWith(
                    height: 1.7,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

        if (description.isNotEmpty && hexagonScores != null) const SizedBox(height: 16),

        // 육각형 스탯
        if (hexagonScores != null)
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: TossDesignSystem.warningOrange,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '재능 육각형 분석',
                      style: TypographyUnified.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHexagonScore('창의성', hexagonScores['creativity'] as int? ?? 0, Icons.brush, isDark),
                _buildHexagonScore('기술력', hexagonScores['technique'] as int? ?? 0, Icons.build, isDark),
                _buildHexagonScore('열정', hexagonScores['passion'] as int? ?? 0, Icons.local_fire_department, isDark),
                _buildHexagonScore('훈련', hexagonScores['discipline'] as int? ?? 0, Icons.fitness_center, isDark),
                _buildHexagonScore('독창성', hexagonScores['uniqueness'] as int? ?? 0, Icons.auto_awesome, isDark),
                _buildHexagonScore('시장가치', hexagonScores['marketValue'] as int? ?? 0, Icons.trending_up, isDark),
              ],
            ),
          ),
      ],
    );
  }

  /// 육각형 스탯 개별 항목
  Widget _buildHexagonScore(String label, int score, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: TossDesignSystem.tossBlue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '$score',
                      style: TypographyUnified.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TossDesignSystem.tossBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.tossBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 신규: 멘탈 모델 분석
  Widget _buildMentalModel(bool isDark) {
    final mentalModel = _fortuneResult?.data['mentalModel'] as Map<String, dynamic>?;
    if (mentalModel == null) return SizedBox.shrink();

    final thinkingStyle = mentalModel['thinkingStyle'] as String? ?? '';
    final decisionPattern = mentalModel['decisionPattern'] as String? ?? '';
    final learningStyle = mentalModel['learningStyle'] as String? ?? '';

    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: TossDesignSystem.tossBlue, size: 24),
              SizedBox(width: 8),
              Text(
                '🧠 멘탈 모델 분석',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (thinkingStyle.isNotEmpty) ...[
            Text(
              '사고 방식',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.tossBlue,
              ),
            ),
            SizedBox(height: 6),
            Text(
              thinkingStyle,
              style: TypographyUnified.bodySmall.copyWith(
                height: 1.6,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (decisionPattern.isNotEmpty) ...[
            Text(
              '의사결정 패턴',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.successGreen,
              ),
            ),
            SizedBox(height: 6),
            Text(
              decisionPattern,
              style: TypographyUnified.bodySmall.copyWith(
                height: 1.6,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (learningStyle.isNotEmpty) ...[
            Text(
              '효율적인 학습 방법',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.warningOrange,
              ),
            ),
            SizedBox(height: 6),
            Text(
              learningStyle,
              style: TypographyUnified.bodySmall.copyWith(
                height: 1.6,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ 신규: 협업 궁합
  Widget _buildCollaboration(bool isDark) {
    final collaboration = _fortuneResult?.data['collaboration'] as Map<String, dynamic>?;
    if (collaboration == null) return SizedBox.shrink();

    final goodMatch = (collaboration['goodMatch'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final challenges = (collaboration['challenges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final teamRole = collaboration['teamRole'] as String? ?? '';

    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, color: TossDesignSystem.successGreen, size: 24),
              SizedBox(width: 8),
              Text(
                '🤝 협업 궁합',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (teamRole.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                teamRole,
                style: TypographyUnified.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (goodMatch.isNotEmpty) ...[
            Text(
              '✅ 잘 맞는 타입',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.successGreen,
              ),
            ),
            SizedBox(height: 8),
            ...goodMatch.map((match) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 16, color: TossDesignSystem.successGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (challenges.isNotEmpty) ...[
            Text(
              '⚠️ 주의할 타입',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.warningOrange,
              ),
            ),
            SizedBox(height: 8),
            ...challenges.map((challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, size: 16, color: TossDesignSystem.warningOrange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      challenge,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  /// ✅ 신규: 성장 로드맵
  Widget _buildGrowthRoadmap(bool isDark) {
    final growthRoadmap = _fortuneResult?.data['growthRoadmap'] as Map<String, dynamic>?;
    if (growthRoadmap == null) return SizedBox.shrink();

    final periods = ['month1', 'month3', 'month6', 'year1'];
    final periodNames = {'month1': '1개월', 'month3': '3개월', 'month6': '6개월', 'year1': '1년'};

    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: TossDesignSystem.tossBlue, size: 24),
              SizedBox(width: 8),
              Text(
                '📅 단계별 성장 로드맵',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...periods.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final periodData = growthRoadmap[period] as Map<String, dynamic>?;
            if (periodData == null) return SizedBox.shrink();

            final goal = periodData['goal'] as String? ?? '';
            final milestones = (periodData['milestones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final skillsToAcquire = (periodData['skillsToAcquire'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

            return Padding(
              padding: EdgeInsets.only(bottom: index < periods.length - 1 ? 16 : 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.tossBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [TossDesignSystem.tossBlue, TossDesignSystem.tossBlueDark],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        periodNames[period] ?? period,
                        style: TypographyUnified.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (goal.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        goal,
                        style: TypographyUnified.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                    ],
                    if (milestones.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '마일스톤',
                        style: TypographyUnified.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.tossBlue,
                        ),
                      ),
                      SizedBox(height: 6),
                      ...milestones.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TypographyUnified.bodySmall),
                            Expanded(
                              child: Text(
                                m,
                                style: TypographyUnified.bodySmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    if (skillsToAcquire.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '습득할 스킬',
                        style: TypographyUnified.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.successGreen,
                        ),
                      ),
                      SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skillsToAcquire.map((skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            skill,
                            style: TypographyUnified.labelSmall.copyWith(
                              color: TossDesignSystem.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// ✅ 신규: 학습 전략
  Widget _buildLearningStrategy(bool isDark) {
    final learningStrategy = _fortuneResult?.data['learningStrategy'] as Map<String, dynamic>?;
    if (learningStrategy == null) return SizedBox.shrink();

    final effectiveMethods = (learningStrategy['effectiveMethods'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final timeManagement = learningStrategy['timeManagement'] as String? ?? '';
    final recommendedBooks = (learningStrategy['recommendedBooks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final recommendedCourses = (learningStrategy['recommendedCourses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final mentorshipAdvice = learningStrategy['mentorshipAdvice'] as String? ?? '';

    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: TossDesignSystem.tossBlue, size: 24),
              SizedBox(width: 8),
              Text(
                '📖 학습 전략',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (effectiveMethods.isNotEmpty) ...[
            Text(
              '효율적인 학습법',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.tossBlue,
              ),
            ),
            SizedBox(height: 8),
            ...effectiveMethods.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: TypographyUnified.bodySmall.copyWith(
                    height: 1.6,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (timeManagement.isNotEmpty) ...[
            Text(
              '시간 관리 팁',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.warningOrange,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossDesignSystem.warningOrange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeManagement,
                style: TypographyUnified.bodySmall.copyWith(
                  height: 1.6,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (recommendedBooks.isNotEmpty) ...[
            Text(
              '추천 도서',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.successGreen,
              ),
            ),
            SizedBox(height: 8),
            ...recommendedBooks.map((book) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.menu_book, size: 16, color: TossDesignSystem.successGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      book,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (recommendedCourses.isNotEmpty) ...[
            Text(
              '추천 강의',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.tossBlue,
              ),
            ),
            SizedBox(height: 8),
            ...recommendedCourses.map((course) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.play_circle, size: 16, color: TossDesignSystem.tossBlue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      course,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (mentorshipAdvice.isNotEmpty) ...[
            Text(
              '멘토링 찾기',
              style: TypographyUnified.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.warningOrange,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossDesignSystem.warningOrange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mentorshipAdvice,
                style: TypographyUnified.bodySmall.copyWith(
                  height: 1.6,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
