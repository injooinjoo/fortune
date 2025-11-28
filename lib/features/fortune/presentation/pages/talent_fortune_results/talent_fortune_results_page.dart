/// 재능 발견 운세 결과 페이지 (Modular Architecture)
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
import '../../../../../core/theme/toss_design_system.dart';
import '../../../domain/models/talent_input_model.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../services/ad_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/models/fortune_result.dart';

// Import modular widgets
import 'widgets/overview_section.dart';
import 'widgets/talent_insights_section.dart';
import 'widgets/weekly_plan_section.dart';
import 'widgets/detailed_analysis_section.dart';
import 'widgets/mental_model_section.dart';
import 'widgets/collaboration_section.dart';
import 'widgets/growth_roadmap_section.dart';
import 'widgets/learning_strategy_section.dart';

class TalentFortuneResultsPage extends ConsumerStatefulWidget {
  final TalentInputData inputData;
  final FortuneResult? fortuneResult;

  const TalentFortuneResultsPage({
    super.key,
    required this.inputData,
    this.fortuneResult,
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

      _fortuneResult = widget.fortuneResult;
      _isBlurred = widget.fortuneResult!.isBlurred;
      _blurredSections = widget.fortuneResult!.blurredSections;
      _isLoading = false;
      _calculateLocalSaju();
    } else {
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

      _calculateLocalSaju();

      final tokenState = ref.read(tokenProvider);
      final isPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      Logger.info('[TalentFortune] 💎 Premium 상태: $isPremium');

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
    } catch (e, stackTrace) {
      Logger.error('[TalentFortune] ❌ API 호출 실패', e, stackTrace);

      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isBlurred = false;
      });
    }
  }

  /// 로컬 사주 계산 (API 실패 시 fallback용)
  void _calculateLocalSaju() {
    final birthDate = widget.inputData.birthDate!;

    final now = DateTime.now();
    _currentAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      _currentAge--;
    }

    Logger.info('[TalentFortune] 🎂 나이 계산: $_currentAge살');
  }

  /// 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    debugPrint('[TalentFortune] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

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

  /// Blur wrapper helper (제목은 보이게, 내용만 블러)
  Widget _buildSectionWithBlur({
    required String sectionKey,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget Function() contentBuilder,
    required bool isDark,
  }) {
    final shouldBlur = _isBlurred && _blurredSections.contains(sectionKey);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목은 항상 표시
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TypographyUnified.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
              if (shouldBlur)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: TossDesignSystem.tossBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TypographyUnified.labelSmall.copyWith(
                          color: TossDesignSystem.tossBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 내용만 블러 처리
          if (shouldBlur)
            _buildBlurredContent(contentBuilder(), isDark)
          else
            contentBuilder(),
        ],
      ),
    );
  }

  /// 내용만 블러 처리하는 헬퍼
  Widget _buildBlurredContent(Widget child, bool isDark) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.2),
                  (isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '광고 시청 후 확인',
                  style: TypographyUnified.labelMedium.copyWith(
                    color: (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight),
                  ),
                ),
              ],
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
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '재능 발견 결과',
          style: TypographyUnified.heading3.copyWith(
            fontWeight: FontWeight.w700,
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Part 1: 종합 브리핑
                          OverviewSection(
                            fortuneResult: _fortuneResult,
                            isDark: isDark,
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 24),

                          // Part 2: TOP 3 재능 인사이트
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildSectionWithBlur(
                              sectionKey: 'top3_talents',
                              title: 'TOP 3 재능 인사이트',
                              icon: Icons.lightbulb,
                              iconColor: TossDesignSystem.warningOrange,
                              contentBuilder: () => TalentInsightsSection(
                                fortuneResult: _fortuneResult,
                                isDark: isDark,
                              ),
                              isDark: isDark,
                            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                          ),

                          const SizedBox(height: 24),

                          // Part 3: 주간 실행 계획
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildSectionWithBlur(
                              sectionKey: 'career_roadmap',
                              title: '7일 실행 계획',
                              icon: Icons.calendar_today,
                              iconColor: TossDesignSystem.tossBlue,
                              contentBuilder: () => WeeklyPlanSection(
                                fortuneResult: _fortuneResult,
                                isDark: isDark,
                              ),
                              isDark: isDark,
                            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                          ),

                          const SizedBox(height: 24),

                          // Part 4: 상세 분석들
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                _buildSectionWithBlur(
                                  sectionKey: 'growth_timeline',
                                  title: '상세 분석',
                                  icon: Icons.analytics,
                                  iconColor: TossDesignSystem.tossBlue,
                                  contentBuilder: () => DetailedAnalysisSection(
                                    fortuneResult: _fortuneResult,
                                    isDark: isDark,
                                  ),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildSectionWithBlur(
                                  sectionKey: 'growth_timeline',
                                  title: '🧠 멘탈 모델 분석',
                                  icon: Icons.psychology,
                                  iconColor: TossDesignSystem.tossBlue,
                                  contentBuilder: () => MentalModelSection(
                                    fortuneResult: _fortuneResult,
                                    isDark: isDark,
                                  ),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildSectionWithBlur(
                                  sectionKey: 'growth_timeline',
                                  title: '🤝 협업 궁합',
                                  icon: Icons.groups,
                                  iconColor: TossDesignSystem.successGreen,
                                  contentBuilder: () => CollaborationSection(
                                    fortuneResult: _fortuneResult,
                                    isDark: isDark,
                                  ),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildSectionWithBlur(
                                  sectionKey: 'growth_timeline',
                                  title: '📅 단계별 성장 로드맵',
                                  icon: Icons.timeline,
                                  iconColor: TossDesignSystem.tossBlue,
                                  contentBuilder: () => GrowthRoadmapSection(
                                    fortuneResult: _fortuneResult,
                                    isDark: isDark,
                                  ),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildSectionWithBlur(
                                  sectionKey: 'growth_timeline',
                                  title: '📖 학습 전략',
                                  icon: Icons.school,
                                  iconColor: TossDesignSystem.tossBlue,
                                  contentBuilder: () => LearningStrategySection(
                                    fortuneResult: _fortuneResult,
                                    isDark: isDark,
                                  ),
                                  isDark: isDark,
                                ),
                              ],
                            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),

                    // FloatingBottomButton (블러 상태일 때만 표시)
                    if (_isBlurred)
                      UnifiedButton.floating(
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
          ],
        ),
      ),
    );
  }
}
