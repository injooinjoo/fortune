import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/theme/obangseok_colors.dart';
import '../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';

/// 건강운세 결과 페이지 (프리미엄/블러 시스템 적용)
///
/// **블러 섹션** (6개):
/// - body_part_advice: 부위별 건강 조언
/// - cautions: 주의사항
/// - recommended_activities: 추천 활동
/// - diet_advice: 식습관 조언
/// - exercise_advice: 운동 조언
/// - health_keyword: 건강 키워드
///
/// **Floating Button**: "건강 조언 모두 보기"
class HealthFortuneResultPage extends ConsumerStatefulWidget {
  final FortuneResult fortuneResult;

  const HealthFortuneResultPage({
    super.key,
    required this.fortuneResult,
  });

  @override
  ConsumerState<HealthFortuneResultPage> createState() => _HealthFortuneResultPageState();
}

class _HealthFortuneResultPageState extends ConsumerState<HealthFortuneResultPage> {
  late FortuneResult _fortuneResult;

  // GPT 스타일 타이핑 효과 섹션 관리
  int _currentTypingSection = 0;
  bool _hapticTriggered = false;

  // HanjiColorScheme.health 색상 (청록색 계열)
  static const Color _healthAccent = Color(0xFF38A169);
  static const Color _healthAccentLight = Color(0xFF68D391);

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;
    _currentTypingSection = 0;
    Logger.info('[건강운] 결과 페이지 초기화 - isBlurred: ${_fortuneResult.isBlurred}');

    // 건강운 결과 공개 햅틱
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hapticTriggered) {
        _hapticTriggered = true;
        final score = _fortuneResult.score ?? 70;
        ref.read(fortuneHapticServiceProvider).scoreReveal(score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? ObangseokColors.hanjiBackgroundDark
            : ObangseokColors.hanjiBackground,
        appBar: _buildAppBar(isDark),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 메인 점수 카드 (공개)
                  _buildMainScoreCard(isDark),
                  const SizedBox(height: 24),

                  // 2. 전반적인 건강운 (공개)
                  _buildOverallHealthSection(isDark),

                  // 3. 부위별 건강 조언 (블러)
                  _buildBlurredSection(
                    title: '부위별 건강 조언',
                    hanja: '體',
                    icon: Icons.medical_services_rounded,
                    isDark: isDark,
                    contentBuilder: () => _buildBodyPartAdviceContent(isDark),
                  ),

                  // 4. 주의사항 (블러)
                  _buildBlurredSection(
                    title: '주의사항',
                    hanja: '警',
                    icon: Icons.warning_rounded,
                    isDark: isDark,
                    accentColor: ObangseokColors.jeokMuted,
                    contentBuilder: () => _buildCautionsContent(isDark),
                  ),

                  // 5. 추천 활동 (블러)
                  _buildBlurredSection(
                    title: '추천 활동',
                    hanja: '動',
                    icon: Icons.directions_run_rounded,
                    isDark: isDark,
                    contentBuilder: () => _buildRecommendedActivitiesContent(isDark),
                  ),

                  // 6. 식습관 조언 (블러)
                  _buildBlurredSection(
                    title: '식습관 조언',
                    hanja: '食',
                    icon: Icons.restaurant_rounded,
                    isDark: isDark,
                    accentColor: ObangseokColors.hwang,
                    contentBuilder: () => _buildDietAdviceContent(isDark),
                  ),

                  // 7. 운동 조언 (블러)
                  _buildBlurredSection(
                    title: '운동 조언',
                    hanja: '運',
                    icon: Icons.fitness_center_rounded,
                    isDark: isDark,
                    contentBuilder: () => _buildExerciseAdviceContent(isDark),
                  ),

                  // 8. 건강 키워드 (블러)
                  _buildBlurredSection(
                    title: '오늘의 건강 키워드',
                    hanja: '健',
                    icon: Icons.tag_rounded,
                    isDark: isDark,
                    contentBuilder: () => _buildHealthKeywordContent(isDark),
                  ),

                  const SizedBox(height: 80), // Floating Button 공간
                ],
              ),
            ),

            // 🎯 Floating Button (프리미엄 사용자는 자동 숨김)
            if (_fortuneResult.isBlurred)
              UnifiedAdUnlockButton(
                onPressed: _showAdAndUnblur,
                customText: '🎁 건강 조언 모두 보기',
              ),
          ],
        ),
      ),
    );
  }

  // ===== AppBar =====

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? ObangseokColors.hanjiBackgroundDark
          : ObangseokColors.hanjiBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: ObangseokColors.getMeok(context),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        '건강운세 결과',
        style: TextStyle(
          fontFamily: 'NanumMyeongjo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ObangseokColors.getMeok(context),
        ),
      ),
      centerTitle: true,
    );
  }

  // ===== 공개 섹션 빌더 =====

  Widget _buildMainScoreCard(bool isDark) {
    final data = _fortuneResult.data;
    final healthScore = data['score'] as int? ?? 75;
    final healthAppData = data['health_app_data'] as Map<String, dynamic>?;

    return HanjiCard(
      style: HanjiCardStyle.elevated,
      colorScheme: HanjiColorScheme.health,
      showSealStamp: true,
      sealText: '健',
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObangseokColors.baek.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: isDark ? ObangseokColors.baekDark : _healthAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          // 제목
          Text(
            '오늘의 건강운',
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 16,
              color: isDark
                  ? ObangseokColors.baekMuted
                  : ObangseokColors.meokFaded,
            ),
          ),
          const SizedBox(height: 8),

          // 점수
          Text(
            '$healthScore점',
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: isDark ? ObangseokColors.baekDark : _healthAccent,
            ),
          ),
          const SizedBox(height: 12),

          // 상태 텍스트
          Text(
            _getHealthEmoji(healthScore),
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 18,
              color: isDark ? ObangseokColors.baekMuted : ObangseokColors.meok,
            ),
          ),

          // Health 데이터 뱃지 (있을 경우)
          if (healthAppData != null) ...[
            const SizedBox(height: 20),
            _buildHealthDataBadges(healthAppData, isDark),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  /// Apple Health 데이터 뱃지 빌더
  Widget _buildHealthDataBadges(Map<String, dynamic> data, bool isDark) {
    final badges = <Widget>[];

    // 걸음수
    final steps = data['average_daily_steps'];
    if (steps != null) {
      badges.add(_buildBadge('👣 ${_formatNumber(steps)}보 기반', isDark));
    }

    // 수면
    final sleep = data['average_sleep_hours'];
    if (sleep != null) {
      badges.add(_buildBadge('😴 $sleep시간 수면', isDark));
    }

    // 심박수
    final heartRate = data['average_heart_rate'];
    if (heartRate != null) {
      badges.add(_buildBadge('❤️ ${heartRate}bpm', isDark));
    }

    // 체중
    final weight = data['weight_kg'];
    if (weight != null) {
      badges.add(_buildBadge('⚖️ ${weight}kg', isDark));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ObangseokColors.baek.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 14,
                color: isDark ? ObangseokColors.baekDark : _healthAccent,
              ),
              const SizedBox(width: 6),
              Text(
                'Apple Health 데이터 반영',
                style: TextStyle(
                  fontFamily: 'NanumMyeongjo',
                  fontSize: 12,
                  color: isDark ? ObangseokColors.baekMuted : ObangseokColors.meokFaded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: badges,
        ),
      ],
    );
  }

  Widget _buildBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.baekDark.withValues(alpha: 0.15)
            : _healthAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ObangseokColors.baekDark.withValues(alpha: 0.3)
              : _healthAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NanumMyeongjo',
          fontSize: 13,
          color: isDark ? ObangseokColors.baekDark : _healthAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final n = number is String ? int.tryParse(number) ?? 0 : number as int;
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  Widget _buildOverallHealthSection(bool isDark) {
    final data = _fortuneResult.data;
    final overallHealthRaw = data['overall_health'];
    final overallHealth = FortuneTextCleaner.clean(
      overallHealthRaw is String ? overallHealthRaw : '건강하십니다.',
    );

    return HanjiSectionCard(
      title: '전반적인 건강운',
      hanja: '氣',
      colorScheme: HanjiColorScheme.health,
      margin: const EdgeInsets.only(bottom: 16),
      child: GptStyleTypingText(
        text: overallHealth,
        style: TextStyle(
          fontFamily: 'NanumMyeongjo',
          fontSize: 16,
          height: 1.8,
          color: isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight,
        ),
        startTyping: _currentTypingSection >= 0,
        showGhostText: true,
        onComplete: () {
          if (mounted) setState(() => _currentTypingSection = 1);
        },
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  // ===== 블러 섹션 빌더 =====

  Widget _buildBlurredSection({
    required String title,
    required String hanja,
    required IconData icon,
    required bool isDark,
    required Widget Function() contentBuilder,
    Color? accentColor,
  }) {
    final sectionKey = _getSectionKeyFromTitle(title);

    return HanjiSectionCard(
      title: title,
      hanja: hanja,
      colorScheme: HanjiColorScheme.health,
      margin: const EdgeInsets.only(bottom: 16),
      accentColor: accentColor,
      child: UnifiedBlurWrapper(
        isBlurred: _fortuneResult.isBlurred,
        blurredSections: _fortuneResult.blurredSections,
        sectionKey: sectionKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: contentBuilder(),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildBodyPartAdviceContent(bool isDark) {
    final data = _fortuneResult.data;
    final bodyPartAdviceRaw = data['body_part_advice'];
    final textColor = isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight;

    // Map 형식일 경우 처리 (LLM이 부위별로 Map으로 반환할 수 있음)
    if (bodyPartAdviceRaw is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (bodyPartAdviceRaw as Map<String, dynamic>).entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}:',
                  style: TextStyle(
                    fontFamily: 'NanumMyeongjo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  FortuneTextCleaner.clean(entry.value.toString()),
                  style: TextStyle(
                    fontFamily: 'NanumMyeongjo',
                    fontSize: 15,
                    height: 1.6,
                    color: textColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // String 형식일 경우 (기본)
    final bodyPartAdvice = FortuneTextCleaner.clean(
      bodyPartAdviceRaw is String ? bodyPartAdviceRaw : '주의가 필요합니다.',
    );
    return Text(
      bodyPartAdvice,
      style: TextStyle(
        fontFamily: 'NanumMyeongjo',
        fontSize: 15,
        height: 1.6,
        color: textColor,
      ),
    );
  }

  Widget _buildCautionsContent(bool isDark) {
    final data = _fortuneResult.data;
    final cautions = data['cautions'] as List? ?? ['규칙적 생활', '충분한 휴식', '정기 검진'];
    final textColor = isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cautions.map((caution) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(
                  fontFamily: 'NanumMyeongjo',
                  fontSize: 15,
                  color: ObangseokColors.jeokMuted,
                ),
              ),
              Expanded(
                child: Text(
                  FortuneTextCleaner.clean(caution.toString()),
                  style: TextStyle(
                    fontFamily: 'NanumMyeongjo',
                    fontSize: 15,
                    height: 1.6,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedActivitiesContent(bool isDark) {
    final data = _fortuneResult.data;
    final activities = data['recommended_activities'] as List? ?? ['산책', '요가', '스트레칭'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: activities.map((activity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _healthAccent.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _healthAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            activity.toString(),
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _healthAccentLight : _healthAccent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietAdviceContent(bool isDark) {
    final data = _fortuneResult.data;
    final dietAdviceRaw = data['diet_advice'];
    final dietAdvice = FortuneTextCleaner.clean(
      dietAdviceRaw is String ? dietAdviceRaw : '균형잡힌 식사를 하세요.',
    );
    final textColor = isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight;

    return Text(
      dietAdvice,
      style: TextStyle(
        fontFamily: 'NanumMyeongjo',
        fontSize: 15,
        height: 1.6,
        color: textColor,
      ),
    );
  }

  Widget _buildExerciseAdviceContent(bool isDark) {
    final data = _fortuneResult.data;
    final exerciseAdviceRaw = data['exercise_advice'];
    final exerciseAdvice = FortuneTextCleaner.clean(
      exerciseAdviceRaw is String ? exerciseAdviceRaw : '꾸준한 운동이 중요합니다.',
    );
    final textColor = isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight;

    return Text(
      exerciseAdvice,
      style: TextStyle(
        fontFamily: 'NanumMyeongjo',
        fontSize: 15,
        height: 1.6,
        color: textColor,
      ),
    );
  }

  Widget _buildHealthKeywordContent(bool isDark) {
    final data = _fortuneResult.data;
    final healthKeywordRaw = data['health_keyword'];
    final healthKeyword = healthKeywordRaw is String ? healthKeywordRaw : '건강';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _healthAccent,
            _healthAccentLight,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: ObangseokColors.baek,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            healthKeyword,
            style: const TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ObangseokColors.baek,
            ),
          ),
        ],
      ),
    );
  }

  // ===== 헬퍼 메서드 =====

  String _getHealthEmoji(int score) {
    if (score >= 80) return '💚 매우 건강';
    if (score >= 60) return '💛 양호';
    if (score >= 40) return '🧡 주의 필요';
    return '❤️ 관리 필요';
  }

  String _getSectionKeyFromTitle(String title) {
    final keyMap = {
      '부위별 건강 조언': 'body_part_advice',
      '주의사항': 'cautions',
      '추천 활동': 'recommended_activities',
      '식습관 조언': 'diet_advice',
      '운동 조언': 'exercise_advice',
      '오늘의 건강 키워드': 'health_keyword',
    };
    return keyMap[title] ?? title.toLowerCase().replaceAll(' ', '_');
  }

  // ===== 광고 & 블러 해제 =====

  Future<void> _showAdAndUnblur() async {
    Logger.info('[건강운] 광고 시청 시작');

    try {
      final adService = AdService.instance;

      // RewardedAd 로딩 확인 (최대 5초 대기)
      if (!adService.isRewardedAdReady) {
        Logger.info('[건강운] RewardedAd 로딩 시작');
        await adService.loadRewardedAd();

        // 최대 5초 대기 (500ms × 10회 폴링)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          Logger.warning('[건강운] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: ObangseokColors.jeok,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          Logger.info('[건강운] ✅ 광고 시청 완료, 블러 해제');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'health');
          }

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
      Logger.error('[건강운] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _fortuneResult = _fortuneResult.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: ObangseokColors.hwang,
          ),
        );
      }
    }
  }
}
