import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../widgets/moving_input_unified.dart';
import '../../domain/models/conditions/moving_fortune_conditions.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';

/// 토스 스타일 이사운 페이지 (UnifiedFortuneBaseWidget 사용)
class MovingFortunePage extends ConsumerStatefulWidget {
  const MovingFortunePage({super.key});

  @override
  ConsumerState<MovingFortunePage> createState() => _MovingFortunePageState();
}

class _MovingFortunePageState extends ConsumerState<MovingFortunePage> {
  String? _currentArea;
  String? _targetArea;
  String? _period;
  String? _purpose;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ✅ GPT 스타일 타이핑 효과
  int _currentTypingSection = 0;

  // ✅ 햅틱 피드백 트리거 여부
  bool _hasTriggeredHaptic = false;

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'moving',
      title: '이사운',
      description: '새로운 보금자리로의 이동 운세를 분석해드립니다',
      dataSource: FortuneDataSource.api,
      // 입력 UI
      inputBuilder: (context, onComplete) {
        return MovingInputUnified(
          onComplete: (currentArea, targetArea, period, purpose) {
            setState(() {
              _currentArea = currentArea;
              _targetArea = targetArea;
              _period = period;
              _purpose = purpose;
            });
            onComplete();
          },
        );
      },

      // 조건 객체 생성
      conditionsBuilder: () async {
        return MovingFortuneConditions(
          currentArea: _currentArea ?? '',
          targetArea: _targetArea ?? '',
          movingPeriod: _period ?? '',
          purpose: _purpose ?? '',
        );
      },

      // 결과 표시 UI
      resultBuilder: (context, result) {
        // ✅ result.isBlurred 동기화 + 햅틱 피드백
        if (_isBlurred != result.isBlurred || _blurredSections.length != result.blurredSections.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // ✅ 이사운 결과 공개 시 햅틱 피드백 (최초 1회)
              if (!_hasTriggeredHaptic) {
                final score = result.score ?? 70;
                ref.read(fortuneHapticServiceProvider).scoreReveal(score);
                _hasTriggeredHaptic = true;
              }

              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections = List<String>.from(result.blurredSections);
                // 결과가 바뀌면 타이핑 섹션 리셋
                _currentTypingSection = 0;
              });
            }
          });
        }

        final colors = context.colors;
        final data = result.data;

        // API에서 받은 데이터 추출 (새 응답 구조에 맞게)
        final title = FortuneTextCleaner.clean(data['title'] as String? ?? '이사운');
        final overallFortune = FortuneTextCleaner.cleanNullable(data['overall_fortune'] as String?);
        final score = result.score ?? 50;

        // 방위 분석 (객체)
        final directionAnalysis = data['direction_analysis'] as Map<String, dynamic>?;
        final directionContent = directionAnalysis != null
            ? '${FortuneTextCleaner.cleanNullable(directionAnalysis['direction_meaning'] as String?)}\n\n'
              '오행: ${FortuneTextCleaner.cleanNullable(directionAnalysis['element'] as String?)} - '
              '${FortuneTextCleaner.cleanNullable(directionAnalysis['element_effect'] as String?)}\n\n'
              '궁합도: ${directionAnalysis['compatibility'] ?? 0}점\n'
              '${FortuneTextCleaner.cleanNullable(directionAnalysis['compatibility_reason'] as String?)}'
            : '';

        // 시기 분석 (객체)
        final timingAnalysis = data['timing_analysis'] as Map<String, dynamic>?;
        final timingContent = timingAnalysis != null
            ? '${FortuneTextCleaner.cleanNullable(timingAnalysis['season_meaning'] as String?)}\n\n'
              '이달의 운: ${timingAnalysis['month_luck'] ?? 0}점\n'
              '${FortuneTextCleaner.cleanNullable(timingAnalysis['recommendation'] as String?)}'
            : '';

        // 주의사항 (객체 안의 배열)
        final cautionsData = data['cautions'] as Map<String, dynamic>?;
        final cautions = <String>[];
        if (cautionsData != null) {
          final movingDay = (cautionsData['moving_day'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final firstWeek = (cautionsData['first_week'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final thingsToAvoid = (cautionsData['things_to_avoid'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          cautions.addAll(movingDay);
          cautions.addAll(firstWeek);
          cautions.addAll(thingsToAvoid);
        }

        // 추천사항 (객체 안의 배열)
        final recommendationsData = data['recommendations'] as Map<String, dynamic>?;
        final recommendations = <String>[];
        if (recommendationsData != null) {
          final beforeMoving = (recommendationsData['before_moving'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final movingDayRitual = (recommendationsData['moving_day_ritual'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final afterMoving = (recommendationsData['after_moving'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          recommendations.addAll(beforeMoving);
          recommendations.addAll(movingDayRitual);
          recommendations.addAll(afterMoving);
        }

        // 행운의 날 (객체 안의 배열)
        final luckyDatesData = data['lucky_dates'] as Map<String, dynamic>?;
        final luckyDates = (luckyDatesData?['recommended_dates'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];

        // 풍수 조언 (객체 안의 문자열)
        final fengShuiTipsData = data['feng_shui_tips'] as Map<String, dynamic>?;
        final fengShuiEntrance = FortuneTextCleaner.cleanNullable(fengShuiTipsData?['entrance'] as String?);
        final fengShuiLivingRoom = FortuneTextCleaner.cleanNullable(fengShuiTipsData?['living_room'] as String?);
        final fengShuiBedroom = FortuneTextCleaner.cleanNullable(fengShuiTipsData?['bedroom'] as String?);
        final fengShuiKitchen = FortuneTextCleaner.cleanNullable(fengShuiTipsData?['kitchen'] as String?);

        // 행운 아이템 (객체 안의 배열)
        final luckyItemsData = data['lucky_items'] as Map<String, dynamic>?;
        final luckyItems = (luckyItemsData?['items'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final luckyColors = (luckyItemsData?['colors'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final luckyPlants = (luckyItemsData?['plants'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];

        // 지형 분석 (배산임수, 사신사)
        final terrainAnalysis = data['terrain_analysis'] as Map<String, dynamic>?;
        final terrainType = FortuneTextCleaner.cleanNullable(terrainAnalysis?['terrain_type'] as String?);
        final fengShuiQuality = terrainAnalysis?['feng_shui_quality'] as int? ?? 75;
        final qualityDescription = FortuneTextCleaner.cleanNullable(terrainAnalysis?['quality_description'] as String?);
        final fourGuardians = terrainAnalysis?['four_guardians'] as Map<String, dynamic>?;
        final waterEnergy = FortuneTextCleaner.cleanNullable(terrainAnalysis?['water_energy'] as String?);
        final mountainEnergy = FortuneTextCleaner.cleanNullable(terrainAnalysis?['mountain_energy'] as String?);
        final energyFlow = FortuneTextCleaner.cleanNullable(terrainAnalysis?['energy_flow'] as String?);
        final terrainRecommendations = (terrainAnalysis?['recommendations'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];

        // 요약 키워드
        final summaryData = data['summary'] as Map<String, dynamic>?;
        final summaryKeyword = summaryData?['one_line'] as String? ?? '';

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, _isBlurred ? 140 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    title,
                    style: context.heading2.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 운세 점수 카드 (공개)
                  _buildScoreCard(score, summaryKeyword, colors),
                  const SizedBox(height: 20),

                  // 전반적인 운세 (공개) - 타이핑 섹션 0
                  if (overallFortune.isNotEmpty)
                    _buildSectionCard(
                      title: '전반적인 운세',
                      icon: Icons.brightness_5,
                      content: overallFortune,
                      colors: colors,
                      sectionIndex: 0,
                      onTypingComplete: () {
                        if (mounted) setState(() => _currentTypingSection = 1);
                      },
                    ),
                  const SizedBox(height: 16),

                  // 방위 분석 (블러) - 타이핑 섹션 1
                  if (directionContent.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'direction_analysis',
                      child: _buildSectionCard(
                        title: '방위 분석',
                        icon: Icons.explore,
                        content: directionContent,
                        colors: colors,
                        sectionIndex: 1,
                        onTypingComplete: () {
                          if (mounted) setState(() => _currentTypingSection = 2);
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 시기 분석 (블러) - 타이핑 섹션 2
                  if (timingContent.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'timing_analysis',
                      child: _buildSectionCard(
                        title: '시기 분석',
                        icon: Icons.calendar_today,
                        content: timingContent,
                        colors: colors,
                        sectionIndex: 2,
                        onTypingComplete: () {
                          // 마지막 섹션 완료
                          if (mounted) setState(() => _currentTypingSection = 3);
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 주의사항 (블러)
                  if (cautions.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'cautions',
                      child: _buildListCard(
                        title: '주의사항',
                        icon: Icons.warning_amber_rounded,
                        items: cautions,
                        color: DSColors.warning,
                        colors: colors,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 추천사항 (블러)
                  if (recommendations.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'recommendations',
                      child: _buildListCard(
                        title: '추천사항',
                        icon: Icons.star_rounded,
                        items: recommendations,
                        color: DSColors.accent,
                        colors: colors,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 행운의 날 (블러)
                  if (luckyDates.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'lucky_dates',
                      child: _buildLuckyDatesCard(luckyDates, colors),
                    ),
                  const SizedBox(height: 16),

                  // 풍수 조언 (블러)
                  if (fengShuiTipsData != null && (fengShuiEntrance.isNotEmpty || fengShuiLivingRoom.isNotEmpty))
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'feng_shui_tips',
                      child: _buildFengShuiTipsCard(
                        entrance: fengShuiEntrance,
                        livingRoom: fengShuiLivingRoom,
                        bedroom: fengShuiBedroom,
                        kitchen: fengShuiKitchen,
                        colors: colors,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 행운 아이템 (블러)
                  if (luckyItemsData != null && (luckyItems.isNotEmpty || luckyColors.isNotEmpty))
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'lucky_items',
                      child: _buildLuckyItemsCard(
                        items: luckyItems,
                        luckyColors: luckyColors,
                        plants: luckyPlants,
                        colors: colors,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 지형 분석 (블러)
                  if (terrainAnalysis != null && terrainType.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'terrain_analysis',
                      child: _buildTerrainAnalysisCard(
                        terrainType: terrainType,
                        quality: fengShuiQuality,
                        qualityDescription: qualityDescription,
                        fourGuardians: fourGuardians,
                        waterEnergy: waterEnergy,
                        mountainEnergy: mountainEnergy,
                        energyFlow: energyFlow,
                        recommendations: terrainRecommendations,
                        colors: colors,
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ✅ FloatingBottomButton (블러 상태일 때만, 구독자 제외)
            if (_isBlurred && !ref.watch(isPremiumProvider))
              UnifiedButton.floating(
                text: '광고 보고 전체 내용 확인하기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
              ),
          ],
        );
      },
    );
  }

  /// 광고 보고 블러 제거
  Future<void> _showAdAndUnblur() async {
    try {
      final adService = AdService();

      // 광고 준비 확인
      if (!adService.isRewardedAdReady) {
        await adService.loadRewardedAd();

        // 최대 5초 대기
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
            );
          }
          return;
        }
      }

      // 광고 표시
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, rewardItem) async {
          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'moving');
          }

          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
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
    } catch (e) {
      // 에러 발생 시에도 블러 해제 (사용자 경험 우선)
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
      }
    }
  }

  /// 운세 점수 카드
  Widget _buildScoreCard(int score, String keyword, DSColorScheme colors) {
    // 점수에 따른 색상 결정
    Color scoreColor;
    String scoreText;
    if (score >= 80) {
      scoreColor = DSColors.success;
      scoreText = '매우 좋음';
    } else if (score >= 60) {
      scoreColor = DSColors.accent;
      scoreText = '좋음';
    } else if (score >= 40) {
      scoreColor = DSColors.warning;
      scoreText = '보통';
    } else {
      scoreColor = DSColors.error;
      scoreText = '주의 필요';
    }

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      gradient: LinearGradient(
        colors: [
          scoreColor.withValues(alpha: 0.1),
          scoreColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        children: [
          // 점수
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: context.displayLarge.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  '/100',
                  style: context.heading3.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 점수 텍스트
          Text(
            scoreText,
            style: context.bodyLarge.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (keyword.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                keyword,
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 섹션 카드 (전반적인 운세, 방위 분석, 시기 분석)
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    required DSColorScheme colors,
    int? sectionIndex,
    VoidCallback? onTypingComplete,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: DSColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ GPT 스타일 타이핑 효과 적용
          sectionIndex != null
              ? GptStyleTypingText(
                  text: content,
                  style: context.bodyLarge.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                  startTyping: _currentTypingSection >= sectionIndex,
                  showGhostText: true,
                  onComplete: onTypingComplete,
                )
              : Text(
                  content,
                  style: context.bodyLarge.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                ),
        ],
      ),
    );
  }

  /// 리스트 카드 (주의사항, 추천사항)
  Widget _buildListCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
    required DSColorScheme colors,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: context.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 행운의 날 카드
  Widget _buildLuckyDatesCard(List<String> dates, DSColorScheme colors) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          DSColors.accent.withValues(alpha: 0.1),
          DSColors.accent.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_available,
                  color: DSColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '행운의 날',
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dates.map((date) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: DSColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DSColors.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  date,
                  style: context.bodyMedium.copyWith(
                    color: DSColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 풍수 조언 카드
  Widget _buildFengShuiTipsCard({
    required String entrance,
    required String livingRoom,
    required String bedroom,
    required String kitchen,
    required DSColorScheme colors,
  }) {
    final tips = [
      {'icon': '🚪', 'title': '현관', 'content': entrance},
      {'icon': '🛋️', 'title': '거실', 'content': livingRoom},
      {'icon': '🛏️', 'title': '침실', 'content': bedroom},
      {'icon': '🍳', 'title': '부엌', 'content': kitchen},
    ].where((tip) => (tip['content'] as String).isNotEmpty).toList();

    if (tips.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: DSColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '공간별 풍수 조언',
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < tips.length - 1 ? 16 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tip['icon'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tip['title'] as String,
                        style: context.bodyLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip['content'] as String,
                    style: context.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 행운 아이템 카드
  Widget _buildLuckyItemsCard({
    required List<String> items,
    required List<String> luckyColors,
    required List<String> plants,
    required DSColorScheme colors,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          DSColors.warning.withValues(alpha: 0.1),
          DSColors.warning.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: DSColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '행운 아이템',
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),

          // 행운의 물건
          if (items.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              '🎁 행운의 물건',
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: DSColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          // 행운의 색상
          if (luckyColors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '🎨 행운의 색상',
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: luckyColors.map((color) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DSColors.warning.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  color,
                  style: context.bodyLarge.copyWith(
                    color: DSColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],

          // 행운의 식물
          if (plants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '🌿 행운의 식물',
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plants.map((plant) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DSColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  plant,
                  style: context.bodyLarge.copyWith(
                    color: DSColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 지형 분석 카드 (배산임수, 사신사)
  Widget _buildTerrainAnalysisCard({
    required String terrainType,
    required int quality,
    required String qualityDescription,
    required Map<String, dynamic>? fourGuardians,
    required String waterEnergy,
    required String mountainEnergy,
    required String energyFlow,
    required List<String> recommendations,
    required DSColorScheme colors,
  }) {
    // 지형 점수 색상
    Color qualityColor;
    if (quality >= 80) {
      qualityColor = DSColors.success;
    } else if (quality >= 60) {
      qualityColor = DSColors.accent;
    } else if (quality >= 40) {
      qualityColor = DSColors.warning;
    } else {
      qualityColor = DSColors.error;
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.landscape_rounded,
                  color: Color(0xFF8B7355),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '지형 풍수 분석',
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 지형 유형 및 품질
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: qualityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        terrainType,
                        style: context.labelLarge.copyWith(
                          color: qualityColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$quality점',
                      style: context.heading3.copyWith(
                        color: qualityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (qualityDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    qualityDescription,
                    style: context.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 사신사 (四神砂)
          if (fourGuardians != null) ...[
            const SizedBox(height: 20),
            Text(
              '🐉 사신사(四神砂)',
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildGuardianItem('🐉', '좌청룡', FortuneTextCleaner.cleanNullable(fourGuardians['left_azure_dragon'] as String?), const Color(0xFF2196F3), colors),
            _buildGuardianItem('🐯', '우백호', FortuneTextCleaner.cleanNullable(fourGuardians['right_white_tiger'] as String?), const Color(0xFF9E9E9E), colors),
            _buildGuardianItem('🦅', '전주작', FortuneTextCleaner.cleanNullable(fourGuardians['front_red_phoenix'] as String?), const Color(0xFFF44336), colors),
            _buildGuardianItem('🐢', '후현무', FortuneTextCleaner.cleanNullable(fourGuardians['back_black_turtle'] as String?), const Color(0xFF424242), colors),
          ],

          // 수기/산기/기의 흐름
          if (waterEnergy.isNotEmpty || mountainEnergy.isNotEmpty || energyFlow.isNotEmpty) ...[
            const SizedBox(height: 20),
            if (waterEnergy.isNotEmpty)
              _buildEnergySection('💧', '수기(水氣)', waterEnergy, const Color(0xFF2196F3), colors),
            if (mountainEnergy.isNotEmpty)
              _buildEnergySection('⛰️', '산기(山氣)', mountainEnergy, const Color(0xFF66BB6A), colors),
            if (energyFlow.isNotEmpty)
              _buildEnergySection('🌀', '기의 흐름', energyFlow, const Color(0xFFAB47BC), colors),
          ],

          // 지형 보완 방법
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              '✨ 지형 보완 방법',
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B7355),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec,
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        height: 1.6,
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

  /// 사신사 개별 항목
  Widget _buildGuardianItem(String emoji, String title, String description, Color color, DSColorScheme colors) {
    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 에너지 섹션 (수기/산기/기의 흐름)
  Widget _buildEnergySection(String emoji, String title, String content, Color color, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: context.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
