import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../widgets/moving_input_unified.dart';
import '../../domain/models/conditions/moving_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../services/ad_service.dart';

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
        // ✅ result.isBlurred 동기화
        if (_isBlurred != result.isBlurred || _blurredSections.length != result.blurredSections.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections = List<String>.from(result.blurredSections);
              });
            }
          });
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    style: TypographyUnified.heading2.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 운세 점수 카드 (공개)
                  _buildScoreCard(score, summaryKeyword, isDark),
                  const SizedBox(height: 20),

                  // 전반적인 운세 (공개)
                  if (overallFortune.isNotEmpty)
                    _buildSectionCard(
                      title: '전반적인 운세',
                      icon: Icons.brightness_5,
                      content: overallFortune,
                      isDark: isDark,
                    ),
                  const SizedBox(height: 16),

                  // 방위 분석 (블러)
                  if (directionContent.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'direction_analysis',
                      child: _buildSectionCard(
                        title: '방위 분석',
                        icon: Icons.explore,
                        content: directionContent,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 시기 분석 (블러)
                  if (timingContent.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'timing_analysis',
                      child: _buildSectionCard(
                        title: '시기 분석',
                        icon: Icons.calendar_today,
                        content: timingContent,
                        isDark: isDark,
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
                        color: TossDesignSystem.warningYellow,
                        isDark: isDark,
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
                        color: TossDesignSystem.tossBlue,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 행운의 날 (블러)
                  if (luckyDates.isNotEmpty)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'lucky_dates',
                      child: _buildLuckyDatesCard(luckyDates, isDark),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ✅ FloatingBottomButton (블러 상태일 때만)
            if (_isBlurred)
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
        onUserEarnedReward: (ad, rewardItem) {
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이사운이 잠금 해제되었습니다!')),
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
  Widget _buildScoreCard(int score, String keyword, bool isDark) {
    // 점수에 따른 색상 결정
    Color scoreColor;
    String scoreText;
    if (score >= 80) {
      scoreColor = TossDesignSystem.successGreen;
      scoreText = '매우 좋음';
    } else if (score >= 60) {
      scoreColor = TossDesignSystem.tossBlue;
      scoreText = '좋음';
    } else if (score >= 40) {
      scoreColor = TossDesignSystem.warningYellow;
      scoreText = '보통';
    } else {
      scoreColor = TossDesignSystem.errorRed;
      scoreText = '주의 필요';
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
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
                style: TypographyUnified.displayLarge.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  '/100',
                  style: TypographyUnified.heading3.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 점수 텍스트
          Text(
            scoreText,
            style: TypographyUnified.bodyLarge.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (keyword.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                keyword,
                style: TypographyUnified.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
    required bool isDark,
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
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
    required bool isDark,
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
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
                      style: TossDesignSystem.body2.copyWith(
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
  Widget _buildLuckyDatesCard(List<String> dates, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.tossBlue.withValues(alpha: 0.1),
          TossDesignSystem.tossBlue.withValues(alpha: 0.05),
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
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '행운의 날',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  date,
                  style: TossDesignSystem.body2.copyWith(
                    color: TossDesignSystem.tossBlue,
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
}
