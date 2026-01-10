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
import '../../../fortune/domain/models/past_life_result.dart';

/// 채팅용 전생 운세 결과 카드
///
/// - 조선시대 자화상 스타일 초상화
/// - 전생 신분 뱃지 (왕, 기생, 선비 등)
/// - 전생 스토리 (300-500자)
/// - 현생과의 연결 조언
/// - 블러 처리 및 광고 언락
class ChatPastLifeResultCard extends ConsumerStatefulWidget {
  final PastLifeResult result;

  const ChatPastLifeResultCard({
    super.key,
    required this.result,
  });

  @override
  ConsumerState<ChatPastLifeResultCard> createState() =>
      _ChatPastLifeResultCardState();
}

class _ChatPastLifeResultCardState
    extends ConsumerState<ChatPastLifeResultCard> {
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  bool _isStoryExpanded = true; // 기본으로 펼쳐서 시작

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

  /// 초상화 풀스크린 확대 보기
  void _showFullScreenPortrait(BuildContext context) {
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
                    path: widget.result.portraitUrl,
                    fit: BoxFit.contain,
                    errorWidget: _buildDefaultPortrait(),
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

              // 하단 신분 정보
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      '${_getStatusEmoji(widget.result.pastLifeStatusEn)} ${widget.result.pastLifeStatus}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.result.pastLifeEra} • ${widget.result.pastLifeName}',
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
          FortuneCompletionHelper.onFortuneViewed(context, ref, 'past-life');
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
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 초상화 헤더
          _buildPortraitHeader(context).animate().fadeIn(duration: 500.ms),

          // 2. 신분 뱃지
          _buildStatusBadge(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),

          // 3. 요약 메시지 (무료)
          _buildSummary(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),

          // 4. 전생 스토리 (블러)
          _buildStorySection(context, isDark)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),

          // 5. 현생 조언 (블러)
          if (widget.result.advice.isNotEmpty)
            _buildAdviceSection(context, isDark)
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms),

          // 6. 언락 버튼 (블러 상태 + 비구독자)
          if (_isBlurred && !isPremium)
            _buildUnlockButton(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildPortraitHeader(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        // 배경 그라데이션
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ObangseokColors.hwangMuted.withValues(alpha: 0.3),
                ObangseokColors.hwangDark.withValues(alpha: 0.2),
                colors.surface.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),

        // 초상화 이미지 (탭하면 풀스크린)
        Center(
          child: GestureDetector(
            onTap: widget.result.portraitUrl.isNotEmpty
                ? () => _showFullScreenPortrait(context)
                : null,
            child: Container(
              margin: const EdgeInsets.only(top: DSSpacing.md),
              width: 200,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: ObangseokColors.hwangMuted.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ObangseokColors.hwangDark.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DSRadius.md - 2),
                child: widget.result.portraitUrl.isNotEmpty
                    ? SmartImage(
                        path: widget.result.portraitUrl,
                        width: 200,
                        height: 260,
                        fit: BoxFit.cover,
                        errorWidget: _buildDefaultPortrait(),
                      )
                    : _buildDefaultPortrait(),
              ),
            ),
          ),
        ),

        // 점수 뱃지 + 액션 버튼 (우상단)
        Positioned(
          top: DSSpacing.md,
          right: DSSpacing.md,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(widget.result.score),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreColor(widget.result.score).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.result.score}',
                      style: context.typography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              // 좋아요 + 공유 버튼
              FortuneActionButtons(
                contentId: 'past_life_${widget.result.pastLifeName}_${DateTime.now().millisecondsSinceEpoch}',
                contentType: 'past_life',
                shareTitle: '${widget.result.pastLifeStatus} - 전생탐험',
                shareContent: widget.result.summary.isNotEmpty
                    ? widget.result.summary
                    : widget.result.story,
                iconSize: 18,
                iconColor: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ObangseokColors.hwangMuted.withValues(alpha: 0.15),
            ObangseokColors.hwangLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: ObangseokColors.hwangMuted.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // 신분 이름 (한글 + 영문)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getStatusEmoji(widget.result.pastLifeStatusEn),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                widget.result.pastLifeStatus,
                style: typography.headingMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 시대 • 이름 • 성별
          Text(
            '${widget.result.pastLifeEra} • ${widget.result.pastLifeName} • ${widget.result.pastLifeGenderKo}',
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (widget.result.summary.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 18)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              widget.result.summary,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final isBlurredSection = _blurredSections.contains('story');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isStoryExpanded = !_isStoryExpanded;
                });
                DSHaptics.light();
              },
              borderRadius: BorderRadius.circular(DSRadius.md),
              child: Padding(
                padding: const EdgeInsets.all(DSSpacing.sm),
                child: Row(
                  children: [
                    const Text('📜', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        '전생 이야기',
                        style: typography.labelMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_isBlurred && isBlurredSection)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '🔒',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    const SizedBox(width: DSSpacing.xs),
                    Icon(
                      _isStoryExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 내용
          if (_isStoryExpanded)
            UnifiedBlurWrapper(
              isBlurred: _isBlurred && isBlurredSection,
              blurredSections: _blurredSections,
              sectionKey: 'story',
              fortuneType: 'past-life',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.md,
                  0,
                  DSSpacing.md,
                  DSSpacing.md,
                ),
                child: Text(
                  widget.result.story,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final isBlurredSection = _blurredSections.contains('advice');

    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: ObangseokColors.hwangMuted.withValues(alpha: 0.2),
        ),
      ),
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred && isBlurredSection,
        blurredSections: _blurredSections,
        sectionKey: 'advice',
        fortuneType: 'past-life',
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '현생과의 연결',
                    style: typography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                widget.result.advice,
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
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
                colors: [ObangseokColors.hwangMuted, ObangseokColors.hwangLight],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '전생 이야기 모두 보기',
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

  Widget _buildDefaultPortrait() {
    return Container(
      color: ObangseokColors.hwangMuted.withValues(alpha: 0.2),
      child: const Center(
        child: Text(
          '🎎',
          style: TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  String _getStatusEmoji(String statusEn) {
    switch (statusEn.toLowerCase()) {
      case 'king':
        return '👑';
      case 'queen':
        return '👸';
      case 'gisaeng':
        return '💃';
      case 'scholar':
        return '📚';
      case 'warrior':
      case 'general':
        return '⚔️';
      case 'farmer':
        return '🌾';
      case 'merchant':
        return '💰';
      case 'noble':
        return '🏯';
      case 'monk':
        return '🙏';
      case 'artisan':
        return '🔨';
      case 'servant':
        return '🏠';
      case 'shaman':
        return '🔮';
      default:
        return '🎭';
    }
  }

  Color _getScoreColor(int score) {
    // 동양화 스타일 - 황토색 계열 (ObangseokColors 황색)
    if (score >= 90) return ObangseokColors.hwangDark;
    if (score >= 80) return ObangseokColors.hwang;
    if (score >= 70) return ObangseokColors.hwangMuted;
    if (score >= 60) return ObangseokColors.hwangLight;
    return ObangseokColors.hwangMuted;
  }
}
