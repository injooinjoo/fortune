import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../domain/entities/fortune.dart';
import '../../../../../../data/models/celebrity_simple.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../presentation/providers/ad_provider.dart';
import '../../../../../../presentation/providers/token_provider.dart';
import '../../../../../../presentation/providers/subscription_provider.dart';
import '../../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../../core/services/fortune_haptic_service.dart';

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
      },
    );
  }

  // ✅ UnifiedBlurWrapper로 마이그레이션 완료 (2024-12-07)

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Celebrity info header
              _CelebrityHeader(
                celebrity: widget.selectedCelebrity,
                connectionType: widget.connectionType,
                score: widget.fortune.score,
              ),
              const SizedBox(height: 20),

              // Main fortune message
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'fortune_message',
                child: _FortuneMessage(message: widget.fortune.message),
              ),
              const SizedBox(height: 20),

              // Recommendations
              if (widget.fortune.recommendations?.isNotEmpty ?? false) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'recommendations',
                  child: _Recommendations(recommendations: widget.fortune.recommendations!),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 100), // Floating 버튼을 위한 하단 여백
            ],
          ),
        ),

        // FloatingBottomButton (구독자 제외)
        if (_isBlurred && !ref.watch(isPremiumProvider))
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 116),
          ),

        // Floating 버튼
        if (!_isBlurred)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: UnifiedButton(
                      text: '다시 해보기',
                      style: UnifiedButtonStyle.secondary,
                      onPressed: widget.onReset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UnifiedButton(
                      text: '공유하기',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('공유 기능이 곧 추가될 예정입니다')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _CelebrityHeader extends StatelessWidget {
  final Celebrity? celebrity;
  final String connectionType;
  final int score;

  const _CelebrityHeader({
    required this.celebrity,
    required this.connectionType,
    required this.score,
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
      child: Row(
        children: [
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
                Text(
                  _getConnectionTypeText(connectionType),
                  style: DSTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Text(
              '${score}점',
              style: DSTypography.buttonMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: _getScoreColor(score),
              ),
            ),
          ),
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
}

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
          ...recommendations.map((advice) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    advice,
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
