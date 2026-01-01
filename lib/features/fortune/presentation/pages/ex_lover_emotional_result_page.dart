import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/components/app_card.dart';
import '../../domain/models/ex_lover_simple_model.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/widgets/blurred_fortune_content.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';
import '../../../../core/widgets/today_result_label.dart';
import '../../../../core/widgets/unified_button.dart';

class ExLoverEmotionalResultPage extends ConsumerStatefulWidget {
  final FortuneResult fortuneResult;

  const ExLoverEmotionalResultPage({
    super.key,
    required this.fortuneResult,
  });

  @override
  ConsumerState<ExLoverEmotionalResultPage> createState() =>
      _ExLoverEmotionalResultPageState();
}

class _ExLoverEmotionalResultPageState
    extends ConsumerState<ExLoverEmotionalResultPage> {
  late FortuneResult _fortuneResult;
  late ExLoverEmotionalResultV2 _parsedResult;

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;

    // FortuneResult.data에서 전애인운세 데이터 파싱 (v2)
    _parsedResult = _parseFortuneDataV2(_fortuneResult.data);

    Logger.info(
        '[전애인운세 v2] primaryGoal: ${_parsedResult.primaryGoal}, isPremium: ${!_fortuneResult.isBlurred}');

    // 전애인 운세 결과 공개 햅틱
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final score = _parsedResult.reunionAssessment.score;
        ref.read(fortuneHapticServiceProvider).scoreReveal(score);
      }
    });
  }

  // v2 파싱: Edge Function 응답을 ExLoverEmotionalResultV2로 변환
  ExLoverEmotionalResultV2 _parseFortuneDataV2(dynamic data) {
    if (data is Map<String, dynamic>) {
      final actualData = data['data'] as Map<String, dynamic>? ?? data;

      Logger.info('[전애인운세 v2] 파싱 시작 - keys: ${actualData.keys.toList()}');

      // v2 형식 감지: hardTruth 필드 존재 여부
      if (actualData.containsKey('hardTruth') ||
          actualData.containsKey('hard_truth')) {
        return ExLoverEmotionalResultV2.fromJson(actualData);
      }

      // Legacy v1 형식 → v2로 변환
      if (actualData.containsKey('overall_fortune') ||
          actualData.containsKey('reunion_possibility')) {
        return _convertV1ToV2(actualData);
      }

      Logger.warning(
          '[전애인운세 v2] 예상치 못한 데이터 구조: ${actualData.keys.toList()}');
    }

    Logger.warning('[전애인운세 v2] 기본값 생성 - data type: ${data.runtimeType}');
    return _generateDefaultResultV2();
  }

  // Legacy v1 데이터를 v2 구조로 변환
  ExLoverEmotionalResultV2 _convertV1ToV2(Map<String, dynamic> actualData) {
    final reunionData = actualData['reunion_possibility'];
    final reunionMap =
        reunionData is Map<String, dynamic> ? reunionData : <String, dynamic>{};
    final reunionScore = reunionMap['score'] as int? ?? 50;
    final reunionAnalysis =
        reunionMap['analysis'] as String? ?? '재회 가능성을 분석 중입니다.';
    final reunionTiming =
        reunionMap['favorable_timing'] as String? ?? '조금 더 시간이 필요합니다.';

    final practicalAdvice = actualData['practical_advice'];
    final adviceMap = practicalAdvice is Map<String, dynamic>
        ? practicalAdvice
        : <String, dynamic>{};
    final doNow = adviceMap['do_now'] is List
        ? (adviceMap['do_now'] as List).cast<String>()
        : <String>[];
    final neverDo = adviceMap['never_do'] is List
        ? (adviceMap['never_do'] as List).cast<String>()
        : <String>[];

    return ExLoverEmotionalResultV2(
      title: '솔직한 조언자',
      score: actualData['score'] as int? ?? 70,
      primaryGoal: PrimaryGoal.healing, // v1은 기본값
      coreReason: 'unknown',
      reunionCap: 100,
      hardTruth: HardTruth(
        headline: '현재 상황 진단',
        diagnosis: actualData['overall_fortune'] as String? ?? '상황을 분석 중입니다.',
        realityCheck: neverDo.take(3).toList(),
        mostImportantAdvice: doNow.isNotEmpty ? doNow.first : '천천히 생각해보세요.',
      ),
      reunionAssessment: ReunionAssessment(
        score: reunionScore,
        keyFactors: [reunionAnalysis],
        timing: reunionTiming,
        approach: reunionScore > 50 ? '가능성 있음' : '신중히 접근',
        neverDo: neverDo.take(3).toList(),
      ),
      emotionalPrescription: EmotionalPrescriptionV2(
        currentStateAnalysis:
            actualData['overall_fortune'] as String? ?? '감정 상태를 분석 중입니다.',
        healingFocus: '자기 돌봄에 집중하세요.',
        weeklyActions: doNow.take(3).toList(),
        monthlyMilestone: '한 달 후 감정 점검하기',
      ),
      theirPerspective: TheirPerspective(
        likelyThoughts: reunionAnalysis,
        doTheyThinkOfYou:
            reunionScore > 50 ? '그 사람도 당신을 생각하고 있을 가능성이 높아요.' : '지금은 각자의 시간이 필요해요.',
        whatTheyNeed: reunionScore > 50 ? '시간과 공간' : '새로운 시작',
      ),
      strategicAdvice: StrategicAdvice(
        shortTerm: doNow.isNotEmpty ? doNow.first : '자기 관리에 집중',
        midTerm: '감정 정리 완료하기',
        longTerm: '성장한 모습 보여주기',
      ),
      newBeginning: NewBeginningV2(
        readinessScore: (100 - reunionScore).clamp(30, 90),
        unresolvedIssues: ['감정 정리', '자기 성찰'],
        growthPoints: ['자기 이해', '감정 관리'],
        newLoveTiming: '3-6개월 후',
      ),
      milestones: Milestones(
        oneWeek: ['감정 일기 시작하기', '친구와 대화하기'],
        oneMonth: ['새로운 취미 시작하기', '운동 루틴 만들기'],
        threeMonths: ['성장한 나 돌아보기', '새로운 만남에 열린 마음 갖기'],
      ),
      closingMessage: ClosingMessage(
        empathy: actualData['comfort_message'] as String? ?? '힘든 시간을 보내고 있군요.',
        todayAction: doNow.isNotEmpty ? doNow.first : '오늘은 자신을 위한 시간을 가지세요.',
      ),
    );
  }

  ExLoverEmotionalResultV2 _generateDefaultResultV2() {
    return ExLoverEmotionalResultV2(
      title: '솔직한 조언자',
      score: 70,
      primaryGoal: PrimaryGoal.healing,
      coreReason: 'unknown',
      reunionCap: 100,
      hardTruth: HardTruth(
        headline: '현재 상황 분석 중',
        diagnosis: '데이터를 분석하고 있습니다.',
        realityCheck: ['차분하게 생각하기', '급한 결정 피하기', '감정 정리 우선'],
        mostImportantAdvice: '지금은 자신에게 집중하세요.',
      ),
      reunionAssessment: ReunionAssessment(
        score: 50,
        keyFactors: ['상황 분석 중'],
        timing: '좀 더 시간이 필요합니다.',
        approach: '신중히 접근하세요.',
        neverDo: ['연락 폭탄', 'SNS 스토킹', '술 먹고 연락'],
      ),
      emotionalPrescription: EmotionalPrescriptionV2(
        currentStateAnalysis: '감정 상태를 파악 중입니다.',
        healingFocus: '자기 돌봄에 집중하세요.',
        weeklyActions: ['휴식', '명상', '일기 쓰기'],
        monthlyMilestone: '감정 정리 완료하기',
      ),
      theirPerspective: TheirPerspective(
        likelyThoughts: '분석 중입니다.',
        doTheyThinkOfYou: '상대방의 마음을 파악 중입니다.',
        whatTheyNeed: '분석 중',
      ),
      strategicAdvice: StrategicAdvice(
        shortTerm: '자기 관리에 집중',
        midTerm: '감정 정리',
        longTerm: '성장한 모습으로',
      ),
      newBeginning: NewBeginningV2(
        readinessScore: 50,
        unresolvedIssues: ['감정 정리'],
        growthPoints: ['자기 이해'],
        newLoveTiming: '3-6개월 후',
      ),
      milestones: Milestones(
        oneWeek: ['감정 정리 시작'],
        oneMonth: ['일상 회복'],
        threeMonths: ['새로운 시작 준비'],
      ),
      closingMessage: ClosingMessage(
        empathy: '힘든 시간이죠.',
        todayAction: '오늘은 푹 쉬세요.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background.withValues(alpha: 0.0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '인사이트 결과',
          style: context.heading3.copyWith(
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(
              Icons.close_rounded,
              color: colors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 오늘 날짜 라벨 + 재방문 유도
                const TodayResultLabel(showRevisitHint: true),
                const SizedBox(height: 16),

                // Hard Truth (항상 첫 번째, 프리미엄)
                _buildHardTruthSection(_parsedResult.hardTruth, colors)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // 개인화 분석 섹션 (v3 - 설문 기반)
                if (_parsedResult.personalizedAnalysis != null &&
                    _parsedResult.personalizedAnalysis!.yourStory.isNotEmpty)
                  _buildPersonalizedAnalysisSection(
                          _parsedResult.personalizedAnalysis!, colors)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.1, end: 0),

                if (_parsedResult.personalizedAnalysis != null &&
                    _parsedResult.personalizedAnalysis!.yourStory.isNotEmpty)
                  const SizedBox(height: 24),

                // 스크린샷 분석 섹션 (v3 - Vision API)
                if (_parsedResult.screenshotAnalysis != null &&
                    _parsedResult.screenshotAnalysis!.conversationTone.isNotEmpty)
                  _buildScreenshotAnalysisSection(
                          _parsedResult.screenshotAnalysis!, colors)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms)
                      .slideY(begin: 0.1, end: 0),

                if (_parsedResult.screenshotAnalysis != null &&
                    _parsedResult.screenshotAnalysis!.conversationTone.isNotEmpty)
                  const SizedBox(height: 24),

                // BlurredFortuneContent로 프리미엄 섹션 래핑
                BlurredFortuneContent(
                  fortuneResult: _fortuneResult,
                  child: Column(
                    children: _buildGoalBasedSections(colors),
                  ),
                ),

                const SizedBox(height: 100), // 버튼 공간 확보
              ],
            ),
          ),

          // 광고 버튼 (블러 상태일 때만)
          if (_fortuneResult.isBlurred && !ref.watch(isPremiumProvider))
            UnifiedButton.floating(
              text: '광고 보고 전체 내용 확인하기',
              onPressed: _showAdAndUnblur,
              isEnabled: true,
            ),
        ],
      ),
    );
  }

  // 목표별 섹션 순서 동적 결정
  List<Widget> _buildGoalBasedSections(DSColorScheme colors) {
    final goal = _parsedResult.primaryGoal;
    final sections = <Widget>[];
    int delay = 100;

    switch (goal) {
      case PrimaryGoal.healing:
        // 힐링: 감정 처방 → 마일스톤 → 재회 가능성 (간략) → 새 출발
        sections.add(_buildEmotionalPrescriptionSection(
                _parsedResult.emotionalPrescription, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildMilestonesSection(_parsedResult.milestones, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildReunionAssessmentSection(
                _parsedResult.reunionAssessment, colors,
                isCompact: true)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(
            _buildNewBeginningSection(_parsedResult.newBeginning, colors)
                .animate(delay: Duration(milliseconds: delay))
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.05, end: 0));
        break;

      case PrimaryGoal.reunionStrategy:
        // 재회 전략: 재회 가능성 → 전략적 조언 → 상대방 마음 → 마일스톤
        sections.add(_buildReunionAssessmentSection(
                _parsedResult.reunionAssessment, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildStrategicAdviceSection(
                _parsedResult.strategicAdvice,
                _parsedResult.reunionAssessment.neverDo,
                colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildTheirPerspectiveSection(
                _parsedResult.theirPerspective, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildMilestonesSection(_parsedResult.milestones, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        break;

      case PrimaryGoal.readTheirMind:
        // 상대방 마음: 상대방 마음 → 재회 가능성 → 전략적 조언 → 마일스톤
        sections.add(_buildTheirPerspectiveSection(
                _parsedResult.theirPerspective, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildReunionAssessmentSection(
                _parsedResult.reunionAssessment, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildStrategicAdviceSection(
                _parsedResult.strategicAdvice,
                _parsedResult.reunionAssessment.neverDo,
                colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildMilestonesSection(_parsedResult.milestones, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        break;

      case PrimaryGoal.newStart:
        // 새 출발: 새 출발 준비도 → 감정 처방 → 재회 가능성 (간략) → 마일스톤
        sections.add(
            _buildNewBeginningSection(_parsedResult.newBeginning, colors)
                .animate(delay: Duration(milliseconds: delay))
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildEmotionalPrescriptionSection(
                _parsedResult.emotionalPrescription, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildReunionAssessmentSection(
                _parsedResult.reunionAssessment, colors,
                isCompact: true)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, end: 0));
        delay += 100;
        sections.add(const SizedBox(height: 20));

        sections.add(_buildMilestonesSection(_parsedResult.milestones, colors)
            .animate(delay: Duration(milliseconds: delay))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0));
        break;
    }

    // 클로징 메시지 (항상 마지막)
    sections.add(const SizedBox(height: 20));
    sections.add(_buildClosingSection(_parsedResult.closingMessage, colors)
        .animate(delay: Duration(milliseconds: delay + 100))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0));

    return sections;
  }

  // Hard Truth 섹션 (항상 첫 번째)
  Widget _buildHardTruthSection(HardTruth hardTruth, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFDC2626),
                      Color(0xFFEF4444),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '솔직한 진단',
                      style: context.labelSmall.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hardTruth.headline,
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 진단 내용
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              hardTruth.diagnosis,
              style: context.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 현실 체크
          Text(
            '현실 체크',
            style: context.labelSmall.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...hardTruth.realityCheck.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: context.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // 핵심 조언
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDC2626).withValues(alpha: 0.1),
                  colors.accent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hardTruth.mostImportantAdvice,
                    style: context.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 재회 가능성 섹션 (개선된 게이지)
  Widget _buildReunionAssessmentSection(
      ReunionAssessment assessment, DSColorScheme colors,
      {bool isCompact = false}) {
    final score = assessment.score;
    final gaugeColor = score < 30
        ? const Color(0xFFDC2626)
        : score < 50
            ? const Color(0xFFF59E0B)
            : score < 70
                ? const Color(0xFF10B981)
                : colors.accent;

    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '재회 가능성',
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 게이지 UI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gaugeColor.withValues(alpha: 0.1),
                  colors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // 원형 게이지
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 10,
                          backgroundColor: gaugeColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(gaugeColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score%',
                            style: context.heading2.copyWith(
                              color: gaugeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getScoreLabel(score),
                            style: context.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 16),

                // 권장사항
                Text(
                  assessment.approach,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (!isCompact) ...[
            const SizedBox(height: 16),

            // 핵심 요소
            Text(
              '핵심 요소',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...assessment.keyFactors.map((factor) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: gaugeColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          factor,
                          style: context.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 12),

            // 타이밍
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: gaugeColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      assessment.timing,
                      style: context.bodySmall.copyWith(
                        color: colors.textSecondary,
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

  String _getScoreLabel(int score) {
    if (score < 20) return '매우 낮음';
    if (score < 40) return '낮음';
    if (score < 60) return '보통';
    if (score < 80) return '높음';
    return '매우 높음';
  }

  // 감정 처방 섹션
  Widget _buildEmotionalPrescriptionSection(
      EmotionalPrescriptionV2 prescription, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: colors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '감정 처방',
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 현재 감정 상태
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '현재 감정 상태',
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  prescription.currentStateAnalysis,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 치유 포인트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.healing_rounded,
                  color: colors.accent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '치유 포인트',
                        style: context.labelSmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription.healingFocus,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 이번 주 실천 사항
          _buildListSection(
            '이번 주 실천',
            prescription.weeklyActions,
            Icons.check_circle_rounded,
            DSColors.success,
            colors,
          ),

          const SizedBox(height: 16),

          // 한 달 후 목표
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: DSColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '한 달 후 목표',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prescription.monthlyMilestone,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상대방 마음 섹션
  Widget _buildTheirPerspectiveSection(
      TheirPerspective perspective, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '상대방 마음',
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 그 사람도 생각할까?
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  colors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '그 사람도 나를 생각할까?',
                  style: context.labelSmall.copyWith(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  perspective.doTheyThinkOfYou,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 상대방의 감정
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      size: 16,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '상대방의 감정',
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  perspective.likelyThoughts,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 상대방에게 필요한 것
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '상대방에게 필요한 것',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        perspective.whatTheyNeed,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 전략적 조언 섹션
  Widget _buildStrategicAdviceSection(
      StrategicAdvice advice, List<String> neverDoList, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '전략적 조언',
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 절대 하면 안 되는 것
          if (neverDoList.isNotEmpty) ...[
            _buildListSection(
              '절대 하면 안 되는 것',
              neverDoList,
              Icons.cancel_rounded,
              const Color(0xFFDC2626),
              colors,
            ),
            const SizedBox(height: 16),
          ],

          // 1주일 내 액션
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.looks_one_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1주일 내 액션',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        advice.shortTerm,
                        style: context.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 1개월 내 목표
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.looks_two_rounded,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1개월 내 목표',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        advice.midTerm,
                        style: context.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3개월 후 체크포인트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.looks_3_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3개월 후 체크포인트',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        advice.longTerm,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 새 출발 섹션
  Widget _buildNewBeginningSection(
      NewBeginningV2 newBeginning, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: DSColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '새 출발 준비도',
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 준비도 점수
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새로운 사랑 준비도',
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${newBeginning.readinessScore}%',
                          style: context.labelLarge.copyWith(
                            color: DSColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getReadinessText(newBeginning.readinessScore),
                          style: context.labelSmall.copyWith(
                            color: DSColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: newBeginning.readinessScore / 100,
                        strokeWidth: 4,
                        backgroundColor: DSColors.success.withValues(alpha: 0.1),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(DSColors.success),
                      ),
                    ),
                    Icon(
                      _getReadinessIcon(newBeginning.readinessScore),
                      color: DSColors.success,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 미해결 문제
          if (newBeginning.unresolvedIssues.isNotEmpty) ...[
            _buildListSection(
              '미해결 문제',
              newBeginning.unresolvedIssues,
              Icons.pending_rounded,
              const Color(0xFFF59E0B),
              colors,
            ),
            const SizedBox(height: 16),
          ],

          // 성장 포인트
          _buildListSection(
            '성장 포인트',
            newBeginning.growthPoints,
            Icons.trending_up_rounded,
            DSColors.success,
            colors,
          ),

          const SizedBox(height: 16),

          // 새 인연 시기
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: DSColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '새로운 인연 예상 시기',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        newBeginning.newLoveTiming,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReadinessText(int score) {
    if (score < 30) return '아직 준비 중';
    if (score < 50) return '천천히 준비 중';
    if (score < 70) return '거의 준비됨';
    return '준비 완료!';
  }

  IconData _getReadinessIcon(int score) {
    if (score < 30) return Icons.hourglass_empty_rounded;
    if (score < 50) return Icons.hourglass_bottom_rounded;
    if (score < 70) return Icons.hourglass_top_rounded;
    return Icons.check_circle_rounded;
  }

  // 마일스톤 타임라인 섹션
  Widget _buildMilestonesSection(Milestones milestones, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: colors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '마일스톤',
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 타임라인
          _buildTimelineItem(
            '1주일 후',
            milestones.oneWeek,
            colors.accent,
            colors,
            isFirst: true,
          ),
          _buildTimelineItem(
            '1개월 후',
            milestones.oneMonth,
            const Color(0xFF10B981),
            colors,
          ),
          _buildTimelineItem(
            '3개월 후',
            milestones.threeMonths,
            const Color(0xFF8B5CF6),
            colors,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String period,
    List<String> items,
    Color color,
    DSColorScheme colors, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 도트 & 라인
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: colors.divider,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 내용
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: context.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item,
                            style: context.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // 클로징 메시지 섹션
  Widget _buildClosingSection(ClosingMessage closing, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 공감 메시지
          Text(
            closing.empathy,
            style: context.bodyLarge.copyWith(
              color: colors.textPrimary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 오늘 할 일
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.1),
                  const Color(0xFFEC4899).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.today_rounded,
                      color: colors.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오늘 당장 할 것',
                      style: context.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  closing.todayAction,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
    DSColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: context.bodySmall.copyWith(
                      color: color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: context.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // 개인화 분석 섹션 (v3 - 설문 기반)
  Widget _buildPersonalizedAnalysisSection(
      PersonalizedAnalysis analysis, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.accent,
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '맞춤 분석',
                      style: context.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '당신의 이야기를 분석했어요',
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 당신의 이야기 분석
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '당신의 이야기',
                      style: context.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  analysis.yourStory,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 감정 패턴 분석
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '감정 패턴',
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.emotionalPattern,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // 대화 분석 (있는 경우만)
          if (analysis.chatAnalysis != null &&
              analysis.chatAnalysis!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '대화 분석',
                        style: context.labelSmall.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.chatAnalysis!,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 핵심 인사이트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.1),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: colors.accent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '핵심 인사이트',
                        style: context.labelSmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis.coreInsight,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 스크린샷 분석 섹션 (v3 - Vision API)
  Widget _buildScreenshotAnalysisSection(
      ScreenshotAnalysis analysis, DSColorScheme colors) {
    return AppCard(
      style: AppCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF06B6D4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '카톡 분석',
                      style: context.labelSmall.copyWith(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '대화 스크린샷을 분석했어요',
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 대화 톤 분석
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.record_voice_over_rounded,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '대화 톤',
                      style: context.labelSmall.copyWith(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.conversationTone,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 감정 흐름
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timeline_rounded,
                      size: 16,
                      color: Color(0xFF06B6D4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '감정 흐름',
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.emotionalFlow,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 관계 역학
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '관계 역학',
                      style: context.labelSmall.copyWith(
                        color: const Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.relationshipDynamics,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // 주요 순간들
          if (analysis.keyMoments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildListSection(
              '주요 순간',
              analysis.keyMoments,
              Icons.star_rounded,
              const Color(0xFFF59E0B),
              colors,
            ),
          ],

          const SizedBox(height: 16),

          // 조언
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  const Color(0xFF06B6D4).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '대화 기반 조언',
                        style: context.labelSmall.copyWith(
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis.advice,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 광고 시청 & 블러 해제
  Future<void> _showAdAndUnblur() async {
    if (!_fortuneResult.isBlurred) return;

    try {
      final adService = AdService();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고 로딩에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          Logger.info('[전애인운세 v2] Rewarded ad watched, removing blur');

          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'ex-lover');
          }

          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[전애인운세 v2] Failed to show ad', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
