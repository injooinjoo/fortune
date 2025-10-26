/// 재능 발견 운세 결과 페이지
///
/// 4개 파트로 구성:
/// - Part 1: 종합 브리핑 (재능 아키타입, 일간 분석, 오행 스탯)
/// - Part 2: TOP 3 재능 (십성 기반)
/// - Part 3: 커리어 로드맵
/// - Part 4: 평생 성장 가이드

import 'dart:ui'; // ✅ ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../domain/models/talent_input_model.dart';
import '../../domain/models/sipseong_talent.dart';
import '../../domain/models/saju_elements.dart';
import '../../data/services/saju_calculator.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/talent_top3_widget.dart';
import '../widgets/career_roadmap_widget.dart';
import '../widgets/growth_timeline_widget.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/token_provider.dart'; // ✅ Premium 체크용
import '../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../shared/components/floating_bottom_button.dart'; // ✅ FloatingBottomButton용
import '../../../../core/utils/logger.dart'; // ✅ 로그용

class TalentFortuneResultsPage extends ConsumerStatefulWidget {
  final TalentInputData inputData;

  const TalentFortuneResultsPage({
    super.key,
    required this.inputData,
  });

  @override
  ConsumerState<TalentFortuneResultsPage> createState() => _TalentFortuneResultsPageState();
}

class _TalentFortuneResultsPageState extends ConsumerState<TalentFortuneResultsPage> {
  late Map<String, dynamic> _sajuResult;
  late WuxingDistribution _wuxingDistribution;
  late List<SipseongTalent> _top3Talents;
  late List<Map<String, dynamic>> _daeunList;
  late int _currentAge;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  @override
  void initState() {
    super.initState();
    _analyzeSaju();
  }

  void _analyzeSaju() {
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

    // ✅ Premium 체크 & Blur 로직
    final tokenState = ref.read(tokenProvider);
    final isPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
    debugPrint('💎 [TalentFortune] Premium 상태: $isPremium');

    _isBlurred = !isPremium;
    _blurredSections = _isBlurred
        ? ['top3_talents', 'career_roadmap', 'growth_timeline']
        : [];

    debugPrint('🔒 [TalentFortune] isBlurred: $_isBlurred, blurredSections: $_blurredSections');
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
      body: Stack(
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

                // Part 2: TOP 3 재능 (Premium)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBlurWrapper(
                    sectionKey: 'top3_talents',
                    child: TalentTop3Widget(
                      top3Talents: _top3Talents,
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ),
                ),

                const SizedBox(height: 24),

                // Part 3: 커리어 로드맵 (Premium)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBlurWrapper(
                    sectionKey: 'career_roadmap',
                    child: CareerRoadmapWidget(
                      primaryTalent: _top3Talents.first,
                      allTalents: _top3Talents,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ),
                ),

                const SizedBox(height: 24),

                // Part 4: 평생 성장 가이드 (Premium)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBlurWrapper(
                    sectionKey: 'growth_timeline',
                    child: GrowthTimelineWidget(
                      primaryTalent: _top3Talents.first,
                      daeunList: _daeunList,
                      currentAge: _currentAge,
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

  /// Part 1: 종합 브리핑
  Widget _buildOverviewSection(bool isDark) {
    final ilgan = _sajuResult['ilgan'] as String;
    final ilganInfo = SajuCalculator.getIlganDescription(ilgan);

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
            Text(
              '종합 브리핑',
              style: TypographyUnified.heading1.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '당신의 타고난 기질과 재능을 한눈에',
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // 재능 아키타입 (TOP 3 요약)
            TalentTop3Summary(top3Talents: _top3Talents),
            const SizedBox(height: 16),

            // 핵심 기질 (일간 분석)
            _buildIlganCard(isDark, ilgan, ilganInfo),
            const SizedBox(height: 16),

            // 재능 오각형 스탯 (오행)
            WuxingDetailCard(distribution: _wuxingDistribution),
            const SizedBox(height: 16),

            // 현재 대운 요약
            DaeunSummaryWidget(daeunList: _daeunList),
          ],
        ),
      ),
    );
  }

  Widget _buildIlganCard(bool isDark, String ilgan, Map<String, String> ilganInfo) {
    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.tossBlue,
                      TossDesignSystem.tossBlueDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    ilgan,
                    style: TypographyUnified.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '핵심 기질',
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '일간(日干) $ilgan · ${ilganInfo['element']}',
                      style: TypographyUnified.heading4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ilganInfo['character'] ?? '',
              style: TypographyUnified.bodySmall.copyWith(
                height: 1.6,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
