import 'dart:ui'; // ✅ ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../widgets/moving_input_unified.dart';
import '../../domain/models/conditions/moving_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/ad_provider.dart';

import '../../../../core/widgets/unified_button.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';

/// 토스 스타일 이사운 페이지 (UnifiedFortuneBaseWidget 사용)
class MovingFortuneTossPage extends ConsumerStatefulWidget {
  const MovingFortuneTossPage({super.key});

  @override
  ConsumerState<MovingFortuneTossPage> createState() => _MovingFortuneTossPageState();
}

class _MovingFortuneTossPageState extends ConsumerState<MovingFortuneTossPage> {
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

        // API에서 받은 데이터 추출
        final title = FortuneTextCleaner.clean(data['title'] as String? ?? '이사운');
        final overallFortune = FortuneTextCleaner.cleanNullable(data['overall_fortune'] as String?);
        final directionAnalysis = FortuneTextCleaner.cleanNullable(data['direction_analysis'] as String?);
        final timingAnalysis = FortuneTextCleaner.cleanNullable(data['timing_analysis'] as String?);
        final cautions = (data['cautions'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final recommendations = (data['recommendations'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final luckyDates = (data['lucky_dates'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final summaryKeyword = FortuneTextCleaner.cleanNullable(data['summary_keyword'] as String?);
        final score = result.score ?? 50;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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

              // 운세 점수 카드
              _buildScoreCard(score, summaryKeyword, isDark),
              const SizedBox(height: 20),

              // 전반적인 운세
              if (overallFortune.isNotEmpty)
                _buildSectionCard(
                  title: '전반적인 운세',
                  icon: Icons.brightness_5,
                  content: overallFortune,
                  isDark: isDark,
                ),
              const SizedBox(height: 16),

              // 방위 분석
              if (directionAnalysis.isNotEmpty)
                _buildBlurWrapper(
                  sectionKey: 'direction_analysis',
                  child: _buildSectionCard(
                    title: '방위 분석',
                    icon: Icons.explore,
                    content: directionAnalysis,
                    isDark: isDark,
                  ),
                ),
              const SizedBox(height: 16),

              // 시기 분석
              if (timingAnalysis.isNotEmpty)
                _buildBlurWrapper(
                  sectionKey: 'timing_analysis',
                  child: _buildSectionCard(
                    title: '시기 분석',
                    icon: Icons.calendar_today,
                    content: timingAnalysis,
                    isDark: isDark,
                  ),
                ),
              const SizedBox(height: 16),

              // 주의사항
              if (cautions.isNotEmpty)
                _buildBlurWrapper(
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

              // 추천사항
              if (recommendations.isNotEmpty)
                _buildListCard(
                  title: '추천사항',
                  icon: Icons.star_rounded,
                  items: recommendations,
                  color: TossDesignSystem.tossBlue,
                  isDark: isDark,
                ),
              const SizedBox(height: 16),

              // 행운의 날
              if (luckyDates.isNotEmpty)
                _buildLuckyDatesCard(luckyDates, isDark),
              const SizedBox(height: 32),
                ],
              ),
            ),

            // ✅ FloatingBottomButton
            if (_isBlurred)
              UnifiedButton.floating(
                text: '광고 보고 전체 내용 확인하기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 116), // bottom: 100 효과
              ),
          ],
        );
      },
    );
  }

  /// 광고 보고 블러 제거
  Future<void> _showAdAndUnblur() async {
    final adService = ref.read(adServiceProvider);

    await adService.showRewardedAd(
      onUserEarnedReward: (ad, rewardItem) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
      },
    );
  }

  /// 블러 wrapper
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
              borderRadius: BorderRadius.circular(16),
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
