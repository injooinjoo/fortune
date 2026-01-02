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

    // Backward compatibility: string format
    if (exerciseAdviceRaw is String) {
      return _buildLegacyExerciseAdvice(exerciseAdviceRaw, isDark);
    }

    // New structured format
    if (exerciseAdviceRaw is Map<String, dynamic>) {
      return _buildStructuredExerciseAdvice(exerciseAdviceRaw, isDark);
    }

    // Fallback
    return _buildLegacyExerciseAdvice('꾸준한 운동이 중요합니다.', isDark);
  }

  /// Legacy string format (backward compatibility)
  Widget _buildLegacyExerciseAdvice(String advice, bool isDark) {
    final textColor = isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight;
    return Text(
      FortuneTextCleaner.clean(advice),
      style: TextStyle(
        fontFamily: 'NanumMyeongjo',
        fontSize: 15,
        height: 1.6,
        color: textColor,
      ),
    );
  }

  /// New structured format with cards and grid
  Widget _buildStructuredExerciseAdvice(Map<String, dynamic> advice, bool isDark) {
    final morning = advice['morning'] as Map<String, dynamic>?;
    final afternoon = advice['afternoon'] as Map<String, dynamic>?;
    final weekly = advice['weekly'] as Map<String, dynamic>?;
    final overallTip = advice['overall_tip'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Morning exercise card
        if (morning != null)
          _buildTimeSlotCard(
            timeSlot: morning,
            icon: Icons.wb_sunny_rounded,
            label: '오전 운동',
            isDark: isDark,
            gradientColors: [
              const Color(0xFFFFA726).withValues(alpha: isDark ? 0.3 : 0.2),
              const Color(0xFFFFCC02).withValues(alpha: isDark ? 0.2 : 0.1),
            ],
          ),

        if (morning != null && afternoon != null)
          const SizedBox(height: 12),

        // Afternoon exercise card
        if (afternoon != null)
          _buildTimeSlotCard(
            timeSlot: afternoon,
            icon: Icons.wb_twilight_rounded,
            label: '오후 운동',
            isDark: isDark,
            gradientColors: [
              _healthAccent.withValues(alpha: isDark ? 0.3 : 0.2),
              _healthAccentLight.withValues(alpha: isDark ? 0.2 : 0.1),
            ],
          ),

        if (weekly != null)
          const SizedBox(height: 16),

        // Weekly schedule grid
        if (weekly != null)
          _buildWeeklyScheduleGrid(weekly, isDark),

        // Overall tip
        if (overallTip != null && overallTip.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildOverallTipBanner(overallTip, isDark),
        ],
      ],
    );
  }

  /// Individual time slot card (morning/afternoon)
  Widget _buildTimeSlotCard({
    required Map<String, dynamic> timeSlot,
    required IconData icon,
    required String label,
    required bool isDark,
    required List<Color> gradientColors,
  }) {
    final time = timeSlot['time'] as String? ?? '';
    final title = timeSlot['title'] as String? ?? '';
    final description = timeSlot['description'] as String? ?? '';
    final duration = timeSlot['duration'] as String? ?? '';
    final intensity = timeSlot['intensity'] as String? ?? '';
    final tip = timeSlot['tip'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _healthAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + label + time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _healthAccent.withValues(alpha: isDark ? 0.3 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark ? _healthAccentLight : _healthAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'NanumMyeongjo',
                        fontSize: 12,
                        color: isDark ? ObangseokColors.baekMuted : ObangseokColors.meokFaded,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'NanumMyeongjo',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
                      ),
                    ),
                  ],
                ),
              ),
              // Time badge
              if (time.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _healthAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'NanumMyeongjo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _healthAccentLight : _healthAccent,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          if (description.isNotEmpty)
            Text(
              description,
              style: TextStyle(
                fontFamily: 'NanumMyeongjo',
                fontSize: 14,
                height: 1.5,
                color: isDark ? ObangseokColors.baekMuted : ObangseokColors.meokLight,
              ),
            ),

          const SizedBox(height: 12),

          // Duration + Intensity badges row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (duration.isNotEmpty)
                _buildExerciseInfoBadge(
                  icon: Icons.timer_outlined,
                  text: duration,
                  isDark: isDark,
                ),
              if (intensity.isNotEmpty)
                _buildExerciseInfoBadge(
                  icon: Icons.speed_outlined,
                  text: intensity,
                  isDark: isDark,
                  color: _getIntensityColor(intensity),
                ),
            ],
          ),

          // Tip
          if (tip.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: ObangseokColors.hwang,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontFamily: 'NanumMyeongjo',
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? ObangseokColors.baekMuted.withValues(alpha: 0.8) : ObangseokColors.meokFaded,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Small badge for duration/intensity
  Widget _buildExerciseInfoBadge({
    required IconData icon,
    required String text,
    required bool isDark,
    Color? color,
  }) {
    final badgeColor = color ?? _healthAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? badgeColor.withValues(alpha: 0.9) : badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? badgeColor.withValues(alpha: 0.9) : badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on exercise intensity
  Color _getIntensityColor(String intensity) {
    switch (intensity) {
      case '가벼움':
        return const Color(0xFF68D391); // Light green
      case '중간':
        return const Color(0xFFFFA726); // Orange
      case '높음':
        return const Color(0xFFEF5350); // Red
      default:
        return _healthAccent;
    }
  }

  /// Weekly schedule grid (Mon-Sun)
  Widget _buildWeeklyScheduleGrid(Map<String, dynamic> weekly, bool isDark) {
    final summary = weekly['summary'] as String? ?? '';
    final schedule = weekly['schedule'] as Map<String, dynamic>? ?? {};

    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: isDark ? _healthAccentLight : _healthAccent,
            ),
            const SizedBox(width: 8),
            Text(
              '주간 운동 계획',
              style: TextStyle(
                fontFamily: 'NanumMyeongjo',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
              ),
            ),
          ],
        ),

        if (summary.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            summary,
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 13,
              color: isDark ? ObangseokColors.baekMuted : ObangseokColors.meokFaded,
            ),
          ),
        ],

        const SizedBox(height: 12),

        // 7-day grid
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 48) / 7; // 48 = 6 gaps * 8px

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final dayKey = days[index];
                final dayLabel = dayLabels[index];
                final activity = schedule[dayKey] as String? ?? '-';
                final isRest = activity.contains('휴식') || activity == '-';

                return _buildDayCell(
                  width: itemWidth,
                  dayLabel: dayLabel,
                  activity: activity,
                  isRest: isRest,
                  isDark: isDark,
                );
              }),
            );
          },
        ),
      ],
    );
  }

  /// Individual day cell in weekly grid
  Widget _buildDayCell({
    required double width,
    required String dayLabel,
    required String activity,
    required bool isRest,
    required bool isDark,
  }) {
    final bgColor = isRest
        ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
        : _healthAccent.withValues(alpha: isDark ? 0.2 : 0.1);

    final borderColor = isRest
        ? Colors.transparent
        : _healthAccent.withValues(alpha: 0.3);

    final textColor = isRest
        ? (isDark ? ObangseokColors.baekMuted.withValues(alpha: 0.6) : ObangseokColors.meokFaded)
        : (isDark ? _healthAccentLight : _healthAccent);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Day label
          Text(
            dayLabel,
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
            ),
          ),
          const SizedBox(height: 4),
          // Activity (truncated)
          Text(
            _truncateActivity(activity),
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 10,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Rest icon
          if (isRest)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.self_improvement_rounded,
                size: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  /// Truncate long activity text for grid display
  String _truncateActivity(String activity) {
    if (activity.length <= 8) return activity;
    return '${activity.substring(0, 6)}...';
  }

  /// Overall tip banner at bottom
  Widget _buildOverallTipBanner(String tip, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _healthAccent.withValues(alpha: isDark ? 0.25 : 0.15),
            _healthAccentLight.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _healthAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _healthAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: isDark ? _healthAccentLight : _healthAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontFamily: 'NanumMyeongjo',
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
              ),
            ),
          ),
        ],
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
