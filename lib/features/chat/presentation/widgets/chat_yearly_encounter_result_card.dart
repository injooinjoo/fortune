import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/theme/obangseok_colors.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../services/ad_service.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../fortune/domain/models/yearly_encounter_result.dart';

/// 채팅용 올해의 인연 결과 카드
///
/// - AI 생성 미래 인연 이미지
/// - 외모 해시태그 (3개)
/// - 첫 만남 장소/시간
/// - 인연의 시그널
/// - 성격/특징
/// - 비주얼 궁합 점수
/// - 전통 스타일 (매화꽃 + 황금 프레임 + 베이지 배경)
class ChatYearlyEncounterResultCard extends ConsumerStatefulWidget {
  final YearlyEncounterResult result;

  const ChatYearlyEncounterResultCard({
    super.key,
    required this.result,
  });

  @override
  ConsumerState<ChatYearlyEncounterResultCard> createState() =>
      _ChatYearlyEncounterResultCardState();
}

class _ChatYearlyEncounterResultCardState
    extends ConsumerState<ChatYearlyEncounterResultCard> {
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  @override
  void initState() {
    super.initState();
    _isBlurred = widget.result.isBlurred;
    _blurredSections = List<String>.from(widget.result.blurredSections);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  /// 이미지 풀스크린 확대 보기
  void _showFullScreenImage(BuildContext context) {
    DSHaptics.light();

    showDialog(
      context: context,
      barrierColor: DSColors.overlay,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // 이미지 (핀치 줌 지원)
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: SmartImage(
                    path: widget.result.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: _buildDefaultImage(),
                  ),
                ),
              ),

              // 닫기 버튼
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // 하단 정보
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      '2026 올해의 인연',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.result.hashtagsString,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAdAndUnblur() async {
    final adService = AdService();

    await adService.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        await ref.read(fortuneHapticServiceProvider).premiumUnlock();

        if (mounted) {
          FortuneCompletionHelper.onFortuneViewed(
              context, ref, 'yearly-encounter');
        }

        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

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
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = ref.watch(isPremiumProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        // 베이지 그라데이션 배경
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  colors.backgroundSecondary,
                  colors.surface,
                ]
              : [
                  const Color(0xFFF5F0E6), // 베이지 상단
                  const Color(0xFFEDE5D8), // 베이지 하단
                ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: ObangseokColors.hwangMuted.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 타이틀 헤더
          _buildTitleHeader(context).animate().fadeIn(duration: 500.ms),

          // 2. 이미지 섹션 (황금 원형 프레임 + 매화꽃 장식)
          _buildImageSection(context)
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms),

          // 3. 2열 그리드 (외모 해시태그 + 첫만남 장소)
          _buildInfoGrid(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),

          // 4. 인연의 시그널
          _buildSignalSection(context, isDark)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),

          // 5. 성격/특징
          _buildPersonalitySection(context, isDark)
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms),

          // 6. 비주얼 궁합 점수
          _buildCompatibilityScore(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 500.ms),

          // 7. 언락 버튼 (블러 상태 + 비구독자)
          if (_isBlurred && !isPremium)
            _buildUnlockButton(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms),

          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ObangseokColors.hwangMuted.withValues(alpha: 0.2),
            ObangseokColors.hwangLight.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          const Text('💕', style: TextStyle(fontSize: 24)),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Text(
              '2026 올해의 인연은?',
              style: typography.headingMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 액션 버튼
          FortuneActionButtons(
            contentId:
                'yearly_encounter_${widget.result.targetGender}_${DateTime.now().millisecondsSinceEpoch}',
            contentType: 'yearly_encounter',
            shareTitle: '2026 올해의 인연',
            shareContent:
                '${widget.result.hashtagsString}\n\n${widget.result.encounterSpot}',
            iconSize: 18,
            iconColor: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 매화꽃 장식 (좌상단)
          Positioned(
            top: 0,
            left: DSSpacing.md,
            child: Text(
              '🌸',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          // 매화꽃 장식 (우상단)
          Positioned(
            top: 0,
            right: DSSpacing.md,
            child: Text(
              '🌸',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          // 매화꽃 장식 (좌하단)
          Positioned(
            bottom: 0,
            left: DSSpacing.lg,
            child: Text(
              '✿',
              style: TextStyle(
                fontSize: 20,
                color: ObangseokColors.jeokMuted.withValues(alpha: 0.6),
              ),
            ),
          ),
          // 매화꽃 장식 (우하단)
          Positioned(
            bottom: 0,
            right: DSSpacing.lg,
            child: Text(
              '✿',
              style: TextStyle(
                fontSize: 20,
                color: ObangseokColors.jeokMuted.withValues(alpha: 0.6),
              ),
            ),
          ),

          // 메인 이미지 (황금 프레임)
          GestureDetector(
            onTap: widget.result.imageUrl.isNotEmpty
                ? () => _showFullScreenImage(context)
                : null,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ObangseokColors.hwangMuted,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ObangseokColors.hwangDark.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: UnifiedBlurWrapper(
                  isBlurred: _isBlurred && _blurredSections.contains('image'),
                  blurredSections: _blurredSections,
                  sectionKey: 'image',
                  fortuneType: 'yearly-encounter',
                  child: widget.result.imageUrl.isNotEmpty
                      ? SmartImage(
                          path: widget.result.imageUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: _buildDefaultImage(),
                        )
                      : _buildDefaultImage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 외모 해시태그
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.backgroundSecondary
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '외모',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  ...widget.result.appearanceHashtags.map(
                    (tag) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        tag,
                        style: typography.bodySmall.copyWith(
                          color: ObangseokColors.jeokMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          // 오른쪽: 첫만남 장소
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.backgroundSecondary
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '첫만남 장소와 시간',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    widget.result.encounterSpot,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalSection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final isBlurredSection = _blurredSections.contains('signal');

    return Container(
      margin: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.sm,
        DSSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? colors.backgroundSecondary
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred && isBlurredSection,
        blurredSections: _blurredSections,
        sectionKey: 'signal',
        fortuneType: 'yearly-encounter',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '인연의 시그널',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              widget.result.fateSignal,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final isBlurredSection = _blurredSections.contains('personality');

    return Container(
      margin: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.sm,
        DSSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? colors.backgroundSecondary
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred && isBlurredSection,
        blurredSections: _blurredSections,
        sectionKey: 'personality',
        fortuneType: 'yearly-encounter',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💫', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '성격/특징',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              widget.result.personality,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityScore(BuildContext context) {
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ObangseokColors.jeokMuted.withValues(alpha: 0.8),
            ObangseokColors.hwangMuted.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.full),
        boxShadow: [
          BoxShadow(
            color: ObangseokColors.jeokMuted.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✦', style: TextStyle(fontSize: 14, color: Colors.white)),
          const SizedBox(width: DSSpacing.xs),
          Text(
            '내 얼굴과의 비주얼 합계: ${widget.result.compatibilityScore}',
            style: typography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          const Text('✦', style: TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAdAndUnblur,
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ObangseokColors.jeokMuted, ObangseokColors.hwangMuted],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💕', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '인연 정보 모두 보기',
                  style: typography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: ObangseokColors.hwangMuted.withValues(alpha: 0.2),
      child: const Center(
        child: Text(
          '💕',
          style: TextStyle(fontSize: 80),
        ),
      ),
    );
  }
}
