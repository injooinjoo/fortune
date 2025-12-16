import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../core/widgets/blurred_fortune_content.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../core/utils/logger.dart'; // ✅ 로그용
import '../../../../../core/services/fortune_haptic_service.dart';

/// 연애운 결과 페이지 (프리미엄/블러 시스템 적용)
///
/// **블러 섹션** (4개):
/// - compatibilityInsights: 궁합 인사이트
/// - predictions: 미래 예측
/// - actionPlan: 실천 계획
/// - warningArea: 주의사항
///
/// **Floating Button**: "연애 조언 모두 보기"
class LoveFortuneResultPage extends ConsumerStatefulWidget {
  final FortuneResult fortuneResult;

  const LoveFortuneResultPage({
    super.key,
    required this.fortuneResult,
  });

  @override
  ConsumerState<LoveFortuneResultPage> createState() => _LoveFortuneResultPageState();
}

class _LoveFortuneResultPageState extends ConsumerState<LoveFortuneResultPage> {
  late FortuneResult _fortuneResult;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;
    debugPrint('[연애운] 결과 페이지 초기화 - isBlurred: ${_fortuneResult.isBlurred}');

    // 연애운 결과 공개 햅틱 (하트비트 + 점수)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hapticTriggered) {
        _hapticTriggered = true;
        final haptic = ref.read(fortuneHapticServiceProvider);
        final loveScore = _fortuneResult.data['loveScore'] as int? ?? 70;
        // 하트비트 패턴으로 두근두근 느낌
        haptic.loveHeartbeat();
        // 점수에 따른 차별화 햅틱
        Future.delayed(const Duration(milliseconds: 300), () {
          haptic.scoreReveal(loveScore);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false, // 백버튼 제거
          title: Text(
            '연애운세 결과',
            style: DSTypography.headingMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: colors.textPrimary,
              ),
              onPressed: () => context.go('/fortune'),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // 1. 메인 점수 카드 (공개)
              _buildMainScoreCard(colors),
              const SizedBox(height: 24),

              // 2. 연애 성향 (공개)
              _buildLoveStyleSection(colors),

              // 3. 매력 포인트 (공개)
              _buildCharmPointsSection(colors),

              // 4. 개선 포인트 (공개)
              _buildImprovementSection(colors),

              // 5. 궁합 인사이트 (블러)
              _buildBlurredSection(
                title: '궁합 인사이트',
                icon: Icons.people_rounded,
                color: const Color(0xFF9C27B0),
                contentBuilder: () => _buildCompatibilityInsightsContent(colors),
                colors: colors,
              ),

              // 6. 미래 예측 (블러)
              _buildBlurredSection(
                title: '미래 예측',
                icon: Icons.calendar_today_rounded,
                color: colors.accent,
                contentBuilder: () => _buildPredictionsContent(colors),
                colors: colors,
              ),

              // 7. 실천 계획 (블러)
              _buildBlurredSection(
                title: '실천 계획',
                icon: Icons.checklist_rounded,
                color: DSColors.success,
                contentBuilder: () => _buildActionPlanContent(colors),
                colors: colors,
              ),

              // 8. 주의사항 (블러)
              _buildBlurredSection(
                title: '⚠️ 주의사항',
                icon: Icons.warning_rounded,
                color: DSColors.error,
                contentBuilder: () => _buildWarningContent(colors),
                colors: colors,
              ),

              const SizedBox(height: 80), // Floating Button 공간
                ],
              ),
            ),

            // 🎯 Floating Button
            if (_fortuneResult.isBlurred)
              UnifiedButton.floating(
                text: '연애 조언 모두 보기',
                onPressed: _showAdAndUnblur,
                isLoading: false,
                isEnabled: true,
              ),
          ],
        ),
      ),
    );
  }

  // ===== 공개 섹션 빌더 =====

  Widget _buildMainScoreCard(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final loveScore = data['loveScore'] as int? ?? 70;
    final mainMessage = FortuneTextCleaner.clean(data['mainMessage'] as String? ?? '');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF8CC8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 연애운',
            style: DSTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$loveScore점',
            style: DSTypography.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mainMessage,
            style: DSTypography.bodyLarge.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms);
  }

  Widget _buildLoveStyleSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final loveStyle = detailedAnalysis['loveStyle'] as Map<String, dynamic>? ?? {};
    final description = FortuneTextCleaner.clean(loveStyle['description'] as String? ?? '당신만의 특별한 연애 스타일을 가지고 있어요.');

    return _buildDetailSection(
      context,
      '연애 성향',
      description,
      Icons.psychology_rounded,
      colors.accent,
      colors,
    );
  }

  Widget _buildCharmPointsSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final charmPoints = detailedAnalysis['charmPoints'] as Map<String, dynamic>? ?? {};
    final primary = FortuneTextCleaner.clean(charmPoints['primary'] as String? ?? '');
    final details = List<String>.from(charmPoints['details'] ?? []).map((d) => FortuneTextCleaner.clean(d.toString())).toList();

    final content = details.isNotEmpty
        ? '$primary\n\n• ${details.join('\n• ')}'
        : primary;

    return _buildDetailSection(
      context,
      '매력 포인트',
      content.isEmpty ? '당신만의 특별한 매력을 가지고 있어요.' : content,
      Icons.star_rounded,
      DSColors.warning,
      colors,
    );
  }

  Widget _buildImprovementSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final improvementAreas = detailedAnalysis['improvementAreas'] as Map<String, dynamic>? ?? {};
    final main = FortuneTextCleaner.clean(improvementAreas['main'] as String? ?? '');
    final specific = List<String>.from(improvementAreas['specific'] ?? []).map((s) => FortuneTextCleaner.clean(s.toString())).toList();

    final content = specific.isNotEmpty
        ? '$main\n\n• ${specific.join('\n• ')}'
        : main;

    return _buildDetailSection(
      context,
      '개선 포인트',
      content.isEmpty ? '자신의 감정을 솔직하게 표현해보세요.' : content,
      Icons.trending_up_rounded,
      DSColors.success,
      colors,
    );
  }

  // ===== 블러 섹션 빌더 (제목 블러 해제) =====

  /// 블러 처리된 섹션 (제목은 공개, 내용만 블러)
  Widget _buildBlurredSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function() contentBuilder,
    required DSColorScheme colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 (항상 공개)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: DSTypography.headingSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 내용 (블러 처리)
          BlurredFortuneContent(
            fortuneResult: _fortuneResult,
            child: contentBuilder(),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  // 블러 섹션 내용 빌더들

  Widget _buildCompatibilityInsightsContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final compatibilityInsights = detailedAnalysis['compatibilityInsights'] as Map<String, dynamic>? ?? {};

    final bestMatch = FortuneTextCleaner.clean(compatibilityInsights['bestMatch'] as String? ?? '');
    final avoidTypes = FortuneTextCleaner.clean(compatibilityInsights['avoidTypes'] as String? ?? '');
    final tips = List<String>.from(compatibilityInsights['relationshipTips'] ?? []).map((t) => FortuneTextCleaner.clean(t.toString())).toList();

    final content = '''
💖 최고 궁합: $bestMatch

⚠️ 피해야 할 유형: $avoidTypes

💡 관계 팁:
${tips.isNotEmpty ? '• ${tips.join('\n• ')}' : '서로를 존중하고 이해하는 관계를 만들어가세요.'}
''';

    return Text(
      content,
      style: DSTypography.bodyMedium.copyWith(
        color: colors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildPredictionsContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final predictions = data['predictions'] as Map<String, dynamic>? ?? {};

    final thisWeek = FortuneTextCleaner.clean(predictions['thisWeek'] as String? ?? '');
    final thisMonth = FortuneTextCleaner.clean(predictions['thisMonth'] as String? ?? '');
    final nextThreeMonths = FortuneTextCleaner.clean(predictions['nextThreeMonths'] as String? ?? '');

    final content = '''
📅 이번 주: $thisWeek

📅 이번 달: $thisMonth

📅 앞으로 3개월: $nextThreeMonths
''';

    return Text(
      content,
      style: DSTypography.bodyMedium.copyWith(
        color: colors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildActionPlanContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final actionPlan = data['actionPlan'] as Map<String, dynamic>? ?? {};

    final immediate = List<String>.from(actionPlan['immediate'] ?? []).map((i) => FortuneTextCleaner.clean(i.toString())).toList();
    final shortTerm = List<String>.from(actionPlan['shortTerm'] ?? []).map((s) => FortuneTextCleaner.clean(s.toString())).toList();
    final longTerm = List<String>.from(actionPlan['longTerm'] ?? []).map((l) => FortuneTextCleaner.clean(l.toString())).toList();

    final content = '''
⚡ 즉시 실천:
${immediate.isNotEmpty ? '• ${immediate.join('\n• ')}' : '자신의 감정을 정리해보세요.'}

📆 단기 계획:
${shortTerm.isNotEmpty ? '• ${shortTerm.join('\n• ')}' : '상대방과의 소통을 늘려보세요.'}

🎯 장기 계획:
${longTerm.isNotEmpty ? '• ${longTerm.join('\n• ')}' : '서로의 미래를 함께 그려보세요.'}
''';

    return Text(
      content,
      style: DSTypography.bodyMedium.copyWith(
        color: colors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildWarningContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final todaysAdvice = data['todaysAdvice'] as Map<String, dynamic>? ?? {};
    final warningArea = FortuneTextCleaner.clean(todaysAdvice['warningArea'] as String? ?? '과도한 기대는 실망으로 이어질 수 있으니 주의하세요.');

    return Text(
      warningArea,
      style: DSTypography.bodyMedium.copyWith(
        color: colors.textSecondary,
        height: 1.6,
      ),
    );
  }

  // ===== 공통 빌더 =====

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
    DSColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: DSTypography.headingSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: DSTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  // ===== 광고 & 블러 해제 =====

  // ✅ RewardedAd 패턴으로 교체
  Future<void> _showAdAndUnblur() async {
    debugPrint('[연애운] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[연애운] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[연애운] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: DSColors.error,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[연애운] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[연애운] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _fortuneResult = _fortuneResult.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: DSColors.warning,
          ),
        );
      }
    }
  }
}
