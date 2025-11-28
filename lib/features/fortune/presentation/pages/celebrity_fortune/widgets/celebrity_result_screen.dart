import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../domain/entities/fortune.dart';
import '../../../../../../data/models/celebrity_simple.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../../presentation/providers/ad_provider.dart';

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
      onUserEarnedReward: (ad, reward) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              _buildBlurWrapper(
                sectionKey: 'fortune_message',
                child: _FortuneMessage(message: widget.fortune.message),
              ),
              const SizedBox(height: 20),

              // Recommendations
              if (widget.fortune.recommendations?.isNotEmpty ?? false) ...[
                _buildBlurWrapper(
                  sectionKey: 'recommendations',
                  child: _Recommendations(recommendations: widget.fortune.recommendations!),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 100), // Floating 버튼을 위한 하단 여백
            ],
          ),
        ),

        // FloatingBottomButton
        if (_isBlurred)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
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
              color: _getCelebrityColor(celebrity?.name ?? ''),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                celebrity?.name.substring(0, 1) ?? '?',
                style: TypographyUnified.displaySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: TossDesignSystem.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${celebrity?.name}님과의 궁합',
                  style: TypographyUnified.heading4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                Text(
                  _getConnectionTypeText(connectionType),
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${score}점',
              style: TypographyUnified.buttonMedium.copyWith(
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
    if (score >= 80) return TossDesignSystem.success;
    if (score >= 60) return TossTheme.primaryBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.error;
  }
}

class _FortuneMessage extends StatelessWidget {
  final String message;

  const _FortuneMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Color(0xFFFF6B6B),
            size: 32,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TypographyUnified.buttonMedium.copyWith(
              height: 1.6,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
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
              Icon(Icons.lightbulb_outline, color: TossTheme.primaryBlue, size: 24),
              SizedBox(width: 8),
              Text(
                '추천 조언',
                style: TypographyUnified.heading4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    color: TossTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    advice,
                    style: TypographyUnified.bodySmall.copyWith(
                      height: 1.5,
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
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
