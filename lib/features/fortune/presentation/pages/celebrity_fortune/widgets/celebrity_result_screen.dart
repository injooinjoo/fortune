import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../domain/entities/fortune.dart';
import '../../../../../../data/models/celebrity_simple.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../presentation/providers/ad_provider.dart';
import '../../../../../../presentation/providers/token_provider.dart';
import '../../../../../../presentation/providers/subscription_provider.dart';
import '../../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../../core/utils/fortune_completion_helper.dart';
import '../../../../../../presentation/widgets/hexagon_chart.dart';
import 'celebrity_saju_widgets.dart';

class CelebrityResultScreen extends ConsumerStatefulWidget {
  final Fortune fortune;
  final Celebrity? selectedCelebrity;
  final String connectionType;
  final VoidCallback onReset;

  const CelebrityResultScreen({
    super.key,
    required this.fortune,
    required this.selectedCelebrity,
    required this.connectionType,
    required this.onReset,
  });

  @override
  ConsumerState<CelebrityResultScreen> createState() => _CelebrityResultScreenState();
}

class _CelebrityResultScreenState extends ConsumerState<CelebrityResultScreen> {
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // 추가 데이터 추출
  Map<String, dynamic>? get _detailedAnalysis =>
      widget.fortune.additionalInfo?['detailed_analysis'] as Map<String, dynamic>?;

  List<String>? get _strengths =>
      (widget.fortune.additionalInfo?['strengths'] as List?)?.cast<String>();

  List<String>? get _challenges =>
      (widget.fortune.additionalInfo?['challenges'] as List?)?.cast<String>();

  Map<String, dynamic>? get _luckyFactors =>
      widget.fortune.additionalInfo?['lucky_factors'] as Map<String, dynamic>?;

  String? get _compatibilityGrade =>
      widget.fortune.additionalInfo?['compatibilityGrade'] as String?;

  // 새로운 사주 분석 데이터
  Map<String, dynamic>? get _sajuAnalysis =>
      widget.fortune.additionalInfo?['saju_analysis'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _pastLife =>
      widget.fortune.additionalInfo?['past_life'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _destinedTiming =>
      widget.fortune.additionalInfo?['destined_timing'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _intimateCompatibility =>
      widget.fortune.additionalInfo?['intimate_compatibility'] as Map<String, dynamic>?;

  @override
  void initState() {
    super.initState();
    _isBlurred = widget.fortune.isBlurred;
    _blurredSections = List<String>.from(widget.fortune.blurredSections);

    // 연예인 운세 결과 공개 햅틱 (신비로운 공개)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  @override
  void didUpdateWidget(CelebrityResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fortune != oldWidget.fortune) {
      setState(() {
        _isBlurred = widget.fortune.isBlurred;
        _blurredSections = List<String>.from(widget.fortune.blurredSections);
      });
    }
  }

  Future<void> _showAdAndUnblur() async {
    final adService = ref.read(adServiceProvider);

    await adService.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
        await ref.read(fortuneHapticServiceProvider).premiumUnlock();

        // NEW: 게이지 증가 호출
        if (mounted) {
          FortuneCompletionHelper.onFortuneViewed(context, ref, 'celebrity');
        }

        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
        // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
        if (mounted) {
          final tokenState = ref.read(tokenProvider);
          SubscriptionSnackbar.showAfterAd(
            context,
            hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Celebrity info header with grade badge
              _CelebrityHeader(
                celebrity: widget.selectedCelebrity,
                connectionType: widget.connectionType,
                score: widget.fortune.score,
                compatibilityGrade: _compatibilityGrade,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 20),

              // 2. Hexagon Chart (무료)
              if (widget.fortune.hexagonScores != null) ...[
                _HexagonChartSection(
                  hexagonScores: widget.fortune.hexagonScores!,
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 20),
              ],

              // 3. Main fortune message (무료)
              _FortuneMessage(message: widget.fortune.message)
                  .animate().fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // 4. Strengths section (무료)
              if (_strengths?.isNotEmpty ?? false) ...[
                _StrengthsSection(strengths: _strengths!)
                    .animate().fadeIn(duration: 500.ms, delay: 300.ms),
                const SizedBox(height: 20),
              ],

              // 5. 사주 분석 섹션 (블러) - 오행, 일주, 합
              if (_sajuAnalysis != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'saju_analysis',
                  fortuneType: 'celebrity',
                  child: SajuAnalysisSection(sajuAnalysis: _sajuAnalysis),
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 20),
              ],

              // 6. 속궁합 분석 섹션 (블러)
              if (_intimateCompatibility != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'intimate_compatibility',
                  fortuneType: 'celebrity',
                  child: IntimateCompatibilitySection(
                    intimateCompatibility: _intimateCompatibility,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 450.ms),
                const SizedBox(height: 20),
              ],

              // 7. 전생 인연 섹션 (블러)
              if (_pastLife != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'past_life',
                  fortuneType: 'celebrity',
                  child: PastLifeSection(pastLife: _pastLife),
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                const SizedBox(height: 20),
              ],

              // 8. 운명의 시기 섹션 (블러)
              if (_destinedTiming != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'destined_timing',
                  fortuneType: 'celebrity',
                  child: DestinedTimingSection(destinedTiming: _destinedTiming),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                const SizedBox(height: 20),
              ],

              // 9. Detailed Analysis (블러)
              if (_detailedAnalysis != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'detailed_analysis',
                  fortuneType: 'celebrity',
                  child: _DetailedAnalysisSection(analysis: _detailedAnalysis!),
                ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                const SizedBox(height: 20),
              ],

              // 9. Challenges section (블러)
              if (_challenges?.isNotEmpty ?? false) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'challenges',
                  fortuneType: 'celebrity',
                  child: _ChallengesSection(challenges: _challenges!),
                ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                const SizedBox(height: 20),
              ],

              // 10. Lucky Factors (블러)
              if (_luckyFactors != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'lucky_factors',
                  fortuneType: 'celebrity',
                  child: _LuckyFactorsSection(luckyFactors: _luckyFactors!),
                ).animate().fadeIn(duration: 500.ms, delay: 900.ms),
                const SizedBox(height: 20),
              ],

              // 11. Recommendations (블러)
              if (widget.fortune.recommendations?.isNotEmpty ?? false) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'recommendations',
                  fortuneType: 'celebrity',
                  child: _Recommendations(recommendations: widget.fortune.recommendations!),
                ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 100), // Floating 버튼을 위한 하단 여백
            ],
          ),
        ),

        // FloatingBottomButton (구독자 제외)
        if (_isBlurred && !ref.watch(isPremiumProvider))
          UnifiedButton.floating(
            text: '🔮 궁합 분석 모두 보기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 116),
          ),

        // 하단 버튼 제거됨 (다시해보기, 공유하기)
      ],
    );
  }
}

// ============================================================
// _CelebrityHeader - 헤더 (프로필 + 점수 + 등급)
// ============================================================
class _CelebrityHeader extends StatelessWidget {
  final Celebrity? celebrity;
  final String connectionType;
  final int score;
  final String? compatibilityGrade;

  const _CelebrityHeader({
    required this.celebrity,
    required this.connectionType,
    required this.score,
    this.compatibilityGrade,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 프로필 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: celebrity?.characterImageUrl != null
                      ? colors.backgroundSecondary
                      : _getCelebrityColor(celebrity?.name ?? ''),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: celebrity?.characterImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          celebrity!.characterImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              celebrity?.name.substring(0, 1) ?? '?',
                              style: DSTypography.headingMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          celebrity?.name.substring(0, 1) ?? '?',
                          style: DSTypography.headingMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${celebrity?.name}님과의 궁합',
                      style: DSTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getConnectionTypeText(connectionType),
                      style: DSTypography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 점수 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                child: Text(
                  '$score점',
                  style: DSTypography.buttonMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getScoreColor(score),
                  ),
                ),
              ),
            ],
          ),
          // 등급 배지
          if (compatibilityGrade != null) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradeGradient(compatibilityGrade!),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getGradeIcon(compatibilityGrade!),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    compatibilityGrade!,
                    style: DSTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Color _getCelebrityColor(String name) {
    final colors = [
      Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1),
      Color(0xFF96CEB4), Color(0xFFDDA0DD), Color(0xFFFFD93D),
      Color(0xFF6C5CE7), Color(0xFFFD79A8), Color(0xFF00B894),
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getConnectionTypeText(String type) {
    switch (type) {
      case 'ideal_match':
        return '이상형 매치';
      case 'compatibility':
        return '전체 궁합';
      case 'career_advice':
        return '조언 구하기';
      default:
        return '궁합 분석';
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }

  List<Color> _getGradeGradient(String grade) {
    switch (grade) {
      case '천생연분':
        return [Color(0xFFFF6B6B), Color(0xFFFF8E53)];
      case '좋음':
        return [Color(0xFF4ECDC4), Color(0xFF44B09E)];
      case '보통':
        return [Color(0xFFFFD93D), Color(0xFFFF9F43)];
      case '노력필요':
        return [Color(0xFFA0A0A0), Color(0xFF808080)];
      default:
        return [Color(0xFF6C5CE7), Color(0xFF8A7EFF)];
    }
  }

  IconData _getGradeIcon(String grade) {
    switch (grade) {
      case '천생연분':
        return Icons.favorite;
      case '좋음':
        return Icons.thumb_up;
      case '보통':
        return Icons.sentiment_neutral;
      case '노력필요':
        return Icons.fitness_center;
      default:
        return Icons.stars;
    }
  }
}

// ============================================================
// _HexagonChartSection - 육각형 레이더 차트
// ============================================================
class _HexagonChartSection extends StatelessWidget {
  final Map<String, int> hexagonScores;

  const _HexagonChartSection({required this.hexagonScores});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: colors.accent, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '궁합 분석',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Center(
            child: HexagonChart(
              scores: hexagonScores,
              size: 180,
              primaryColor: colors.accent,
              showValues: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _FortuneMessage - 메인 운세 메시지
// ============================================================
class _FortuneMessage extends StatelessWidget {
  final String message;

  const _FortuneMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: DSColors.accentSecondary,
            size: 32,
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            message,
            style: DSTypography.buttonMedium.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _StrengthsSection - 장점 섹션 (무료)
// ============================================================
class _StrengthsSection extends StatelessWidget {
  final List<String> strengths;

  const _StrengthsSection({required this.strengths});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: DSColors.warning, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '궁합의 장점',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: strengths.map((strength) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DSColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: DSColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: DSColors.success, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      strength,
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _DetailedAnalysisSection - 상세 분석 (블러)
// ============================================================
class _DetailedAnalysisSection extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const _DetailedAnalysisSection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final items = [
      {'icon': Icons.psychology, 'title': '성격 궁합', 'key': 'personality_match'},
      {'icon': Icons.bolt, 'title': '에너지 궁합', 'key': 'energy_compatibility'},
      {'icon': Icons.timeline, 'title': '인생 경로', 'key': 'life_path_connection'},
    ];

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: colors.accent, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '상세 분석',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...items.map((item) {
            final value = analysis[item['key']] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: colors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: DSTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: DSTypography.labelSmall.copyWith(
                            height: 1.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
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
}

// ============================================================
// _ChallengesSection - 도전과제 섹션 (블러)
// ============================================================
class _ChallengesSection extends StatelessWidget {
  final List<String> challenges;

  const _ChallengesSection({required this.challenges});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: DSColors.warning, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '함께 극복해야 할 점',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...challenges.map((challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: DSColors.warning,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    challenge,
                    style: DSTypography.labelSmall.copyWith(
                      height: 1.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ============================================================
// _LuckyFactorsSection - 행운 요소 섹션 (블러)
// ============================================================
class _LuckyFactorsSection extends StatelessWidget {
  final Map<String, dynamic> luckyFactors;

  const _LuckyFactorsSection({required this.luckyFactors});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final items = [
      {'icon': Icons.access_time, 'title': '베스트 타이밍', 'key': 'best_time_to_connect'},
      {'icon': Icons.sports_esports, 'title': '행운의 활동', 'key': 'lucky_activity'},
      {'icon': Icons.interests, 'title': '공유 관심사', 'key': 'shared_interest'},
    ];

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: DSColors.accentSecondary, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '행운 요소',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...items.map((item) {
            final value = luckyFactors[item['key']] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DSColors.accentSecondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  border: Border.all(
                    color: DSColors.accentSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: DSColors.accentSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: DSTypography.labelSmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: DSTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// _Recommendations - 추천 조언 섹션 (블러)
// ============================================================
class _Recommendations extends StatelessWidget {
  final List<String> recommendations;

  const _Recommendations({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: colors.accent, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '추천 조언',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...recommendations.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: DSTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: DSTypography.labelSmall.copyWith(
                      height: 1.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
