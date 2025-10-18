/// 재능 발견 운세 결과 페이지
///
/// 4개 파트로 구성:
/// - Part 1: 종합 브리핑 (재능 아키타입, 일간 분석, 오행 스탯)
/// - Part 2: TOP 3 재능 (십성 기반)
/// - Part 3: 커리어 로드맵
/// - Part 4: 평생 성장 가이드

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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: StandardFortuneAppBar(
        title: '재능 발견 결과',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Part 1: 종합 브리핑
            _buildOverviewSection(isDark)
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Part 2: TOP 3 재능
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TalentTop3Widget(
                top3Talents: _top3Talents,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),

            const SizedBox(height: 24),

            // Part 3: 커리어 로드맵
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CareerRoadmapWidget(
                primaryTalent: _top3Talents.first,
                allTalents: _top3Talents,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),

            const SizedBox(height: 24),

            // Part 4: 평생 성장 가이드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GrowthTimelineWidget(
                primaryTalent: _top3Talents.first,
                daeunList: _daeunList,
                currentAge: _currentAge,
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ),

            const SizedBox(height: 40),
          ],
        ),
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
