import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';

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

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;
    Logger.info('[건강운] 결과 페이지 초기화 - isBlurred: ${_fortuneResult.isBlurred}');
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
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            '건강운세 결과',
            style: context.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
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
                  _buildMainScoreCard(),
                  const SizedBox(height: 24),

                  // 2. 전반적인 건강운 (공개)
                  _buildOverallHealthSection(),

                  // 3. 부위별 건강 조언 (블러)
                  _buildBlurredSection(
                    title: '부위별 건강 조언',
                    icon: Icons.medical_services_rounded,
                    color: const Color(0xFF4CAF50),
                    contentBuilder: () => _buildBodyPartAdviceContent(),
                  ),

                  // 4. 주의사항 (블러)
                  _buildBlurredSection(
                    title: '⚠️ 주의사항',
                    icon: Icons.warning_rounded,
                    color: TossTheme.error,
                    contentBuilder: () => _buildCautionsContent(),
                  ),

                  // 5. 추천 활동 (블러)
                  _buildBlurredSection(
                    title: '추천 활동',
                    icon: Icons.directions_run_rounded,
                    color: const Color(0xFF2196F3),
                    contentBuilder: () => _buildRecommendedActivitiesContent(),
                  ),

                  // 6. 식습관 조언 (블러)
                  _buildBlurredSection(
                    title: '식습관 조언',
                    icon: Icons.restaurant_rounded,
                    color: const Color(0xFFFF9800),
                    contentBuilder: () => _buildDietAdviceContent(),
                  ),

                  // 7. 운동 조언 (블러)
                  _buildBlurredSection(
                    title: '운동 조언',
                    icon: Icons.fitness_center_rounded,
                    color: const Color(0xFF9C27B0),
                    contentBuilder: () => _buildExerciseAdviceContent(),
                  ),

                  // 8. 건강 키워드 (블러)
                  _buildBlurredSection(
                    title: '건강 키워드',
                    icon: Icons.tag_rounded,
                    color: const Color(0xFF00BCD4),
                    contentBuilder: () => _buildHealthKeywordContent(),
                  ),

                  const SizedBox(height: 80), // Floating Button 공간
                ],
              ),
            ),

            // 🎯 Floating Button
            if (_fortuneResult.isBlurred)
              FloatingBottomButton(
                text: '건강 조언 모두 보기',
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

  Widget _buildMainScoreCard() {
    final data = _fortuneResult.data;
    final healthScore = data['score'] as int? ?? 75;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF81C784),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: TossDesignSystem.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 건강운',
            style: context.bodyMedium.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$healthScore점',
            style: context.displayLarge.copyWith(
              color: TossDesignSystem.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getHealthEmoji(healthScore),
            style: context.bodyLarge.copyWith(
              color: TossDesignSystem.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildOverallHealthSection() {
    final data = _fortuneResult.data;
    final overallHealth = data['overall_health'] as String? ?? '건강하십니다.';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
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
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '전반적인 건강운',
                style: context.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            overallHealth,
            style: context.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  // ===== 블러 섹션 빌더 =====

  Widget _buildBlurredSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function() contentBuilder,
  }) {
    final sectionKey = _getSectionKeyFromTitle(title);
    final isBlurred = _fortuneResult.isBlurred &&
        _fortuneResult.blurredSections.contains(sectionKey);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
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
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult.isBlurred,
            blurredSections: _fortuneResult.blurredSections,
            sectionKey: sectionKey,
            child: contentBuilder(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildBodyPartAdviceContent() {
    final data = _fortuneResult.data;
    final bodyPartAdviceRaw = data['body_part_advice'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value.toString(),
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // String 형식일 경우 (기본)
    final bodyPartAdvice = bodyPartAdviceRaw as String? ?? '주의가 필요합니다.';
    return Text(
      bodyPartAdvice,
      style: context.bodyMedium.copyWith(
        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
        height: 1.5,
      ),
    );
  }

  Widget _buildCautionsContent() {
    final data = _fortuneResult.data;
    final cautions = data['cautions'] as List? ?? ['규칙적 생활', '충분한 휴식', '정기 검진'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cautions.map((caution) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ ',
                style: context.bodyMedium,
              ),
              Expanded(
                child: Text(
                  caution.toString(),
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedActivitiesContent() {
    final data = _fortuneResult.data;
    final activities = data['recommended_activities'] as List? ?? ['산책', '요가', '스트레칭'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: activities.map((activity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            activity.toString(),
            style: context.bodyMedium.copyWith(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietAdviceContent() {
    final data = _fortuneResult.data;
    final dietAdvice = data['diet_advice'] as String? ?? '균형잡힌 식사를 하세요.';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      dietAdvice,
      style: context.bodyMedium.copyWith(
        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
        height: 1.5,
      ),
    );
  }

  Widget _buildExerciseAdviceContent() {
    final data = _fortuneResult.data;
    final exerciseAdvice = data['exercise_advice'] as String? ?? '꾸준한 운동이 중요합니다.';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      exerciseAdvice,
      style: context.bodyMedium.copyWith(
        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
        height: 1.5,
      ),
    );
  }

  Widget _buildHealthKeywordContent() {
    final data = _fortuneResult.data;
    final healthKeyword = data['health_keyword'] as String? ?? '건강';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: TossDesignSystem.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            healthKeyword,
            style: context.heading3.copyWith(
              color: TossDesignSystem.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===== _buildBlurredContent 제거 - UnifiedBlurWrapper 사용 =====

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
      '⚠️ 주의사항': 'cautions',
      '추천 활동': 'recommended_activities',
      '식습관 조언': 'diet_advice',
      '운동 조언': 'exercise_advice',
      '건강 키워드': 'health_keyword',
    };
    return keyMap[title] ?? title.toLowerCase().replaceAll(' ', '_');
  }

  // ===== 광고 & 블러 해제 =====

  Future<void> _showAdAndUnblur() async {
    Logger.info('[건강운] 광고 시청 시작');

    try {
      final adService = AdService.instance;

      // RewardedAd 로딩 확인 (최대 10초 대기)
      if (!adService.isRewardedAdReady) {
        Logger.warning('[건강운] ⏳ RewardedAd 로딩 중... 10초 대기');
        await Future.delayed(const Duration(seconds: 10));

        if (!adService.isRewardedAdReady) {
          Logger.warning('[건강운] ❌ RewardedAd 로드 타임아웃');
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
          Logger.info('[건강운] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
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
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }
}
