import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/widgets/hexagon_chart.dart';
import '../../../../services/ad_service.dart';
import '../../../../shared/widgets/smart_image.dart';

/// 채팅용 유명인 궁합 결과 카드
///
/// - 유명인 아바타 + 점수 헤더
/// - 육각형 차트 (무료)
/// - 메인 메시지 (무료)
/// - 접히는 블러 섹션 (사주 분석, 속궁합, 전생 인연, 운명의 시기)
class ChatCelebrityResultCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String? celebrityName;
  final String? celebrityImageUrl;
  final String connectionType;

  const ChatCelebrityResultCard({
    super.key,
    required this.fortune,
    this.celebrityName,
    this.celebrityImageUrl,
    this.connectionType = 'ideal_match',
  });

  @override
  ConsumerState<ChatCelebrityResultCard> createState() =>
      _ChatCelebrityResultCardState();
}

class _ChatCelebrityResultCardState
    extends ConsumerState<ChatCelebrityResultCard> {
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  final Set<String> _expandedSections = {};

  // 데이터 추출
  Map<String, dynamic>? get _sajuAnalysis =>
      widget.fortune.additionalInfo?['saju_analysis'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _pastLife =>
      widget.fortune.additionalInfo?['past_life'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _destinedTiming =>
      widget.fortune.additionalInfo?['destined_timing']
          as Map<String, dynamic>?;

  Map<String, dynamic>? get _intimateCompatibility =>
      widget.fortune.additionalInfo?['intimate_compatibility']
          as Map<String, dynamic>?;

  @override
  void initState() {
    super.initState();
    // 블러 제거 - 모든 콘텐츠 바로 표시
    _isBlurred = false;
    _blurredSections = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  Future<void> _showAdAndUnblur() async {
    final adService = AdService();

    await adService.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        await ref.read(fortuneHapticServiceProvider).premiumUnlock();

        if (mounted) {
          FortuneCompletionHelper.onFortuneViewed(context, ref, 'celebrity');
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

  void _toggleSection(String section) {
    setState(() {
      if (_expandedSections.contains(section)) {
        _expandedSections.remove(section);
      } else {
        _expandedSections.add(section);
      }
    });
    DSHaptics.light();
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
          // 1. 헤더 (유명인 + 점수)
          _buildHeader(context).animate().fadeIn(duration: 400.ms),

          // 2. 육각형 차트 (무료)
          if (widget.fortune.hexagonScores != null)
            _buildHexagonChart(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms),

          // 3. 메인 메시지 (무료)
          _buildMainMessage(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),

          // 4. 블러 섹션들 (접히는 형태)
          _buildBlurredSections(context, isDark)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),

          // 5. 언락 버튼 (블러 상태 + 비구독자)
          if (_isBlurred && !isPremium)
            _buildUnlockButton(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = widget.fortune.score;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE91E63).withValues(alpha: 0.15),
            const Color(0xFF9C27B0).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // 유명인 아바타
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE91E63).withValues(alpha: 0.2),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: widget.celebrityImageUrl != null
                  ? SmartImage(
                      path: widget.celebrityImageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: DSSpacing.md),

          // 이름 + 관계
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.celebrityName ?? '유명인'}과의 궁합',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getConnectionTypeLabel(widget.connectionType),
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수 배지
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getScoreColor(score),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: typography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '점',
                  style: typography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonChart(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        children: [
          Text(
            '궁합 분석 차트',
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 180,
            child: HexagonChart(
              scores: widget.fortune.hexagonScores!,
              size: 140,
              showValues: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMessage(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Text(
        widget.fortune.message.isNotEmpty
            ? widget.fortune.message
            : widget.fortune.content,
        style: typography.bodyMedium.copyWith(
          color: colors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBlurredSections(BuildContext context, bool isDark) {
    final colors = context.colors;

    final sections = <_SectionData>[
      if (_sajuAnalysis != null)
        _SectionData(
          key: 'saju_analysis',
          title: '사주 분석',
          emoji: '🎴',
          content: _buildSajuContent(context),
        ),
      if (_intimateCompatibility != null)
        _SectionData(
          key: 'intimate_compatibility',
          title: '속궁합 분석',
          emoji: '💕',
          content: _buildIntimateContent(context),
        ),
      if (_pastLife != null)
        _SectionData(
          key: 'past_life',
          title: '전생 인연',
          emoji: '🌙',
          content: _buildPastLifeContent(context),
        ),
      if (_destinedTiming != null)
        _SectionData(
          key: 'destined_timing',
          title: '운명의 시기',
          emoji: '⏰',
          content: _buildDestinedTimingContent(context),
        ),
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        children: sections.map((section) {
          final isExpanded = _expandedSections.contains(section.key);
          final isBlurredSection = _blurredSections.contains(section.key);

          return Container(
            margin: const EdgeInsets.only(bottom: DSSpacing.xs),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.backgroundSecondary
                  : colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: colors.textPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                // 헤더 (탭하여 펼치기)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleSection(section.key),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      child: Row(
                        children: [
                          Text(section.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Text(
                              section.title,
                              style: context.typography.labelMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: DSSpacing.xs),
                          Icon(
                            isExpanded
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

                // 내용 (펼쳤을 때)
                if (isExpanded)
                  UnifiedBlurWrapper(
                    isBlurred: _isBlurred && isBlurredSection,
                    blurredSections: _blurredSections,
                    sectionKey: section.key,
                    fortuneType: 'celebrity',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DSSpacing.sm,
                        0,
                        DSSpacing.sm,
                        DSSpacing.sm,
                      ),
                      child: section.content,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSajuContent(BuildContext context) {
    final ohaeng = _sajuAnalysis?['ohaeng'] as String?;
    final ilju = _sajuAnalysis?['ilju'] as String?;
    final hap = _sajuAnalysis?['hap'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ohaeng != null) ...[
          _buildInfoRow(context, '오행 분석', ohaeng),
          const SizedBox(height: DSSpacing.xs),
        ],
        if (ilju != null) ...[
          _buildInfoRow(context, '일주 분석', ilju),
          const SizedBox(height: DSSpacing.xs),
        ],
        if (hap != null) _buildInfoRow(context, '합 분석', hap),
      ],
    );
  }

  Widget _buildIntimateContent(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final description =
        _intimateCompatibility?['description'] as String? ?? '';
    final score = _intimateCompatibility?['score'] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (score != null) ...[
          Row(
            children: [
              Text(
                '속궁합 점수: ',
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '$score점',
                style: typography.labelMedium.copyWith(
                  color: _getScoreColor(score),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        Text(
          description,
          style: typography.bodySmall.copyWith(
            color: colors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPastLifeContent(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final story = _pastLife?['story'] as String? ?? '';
    final connection = _pastLife?['connection_type'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (connection != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              connection,
              style: typography.labelSmall.copyWith(
                color: const Color(0xFF9C27B0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        Text(
          story,
          style: typography.bodySmall.copyWith(
            color: colors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinedTimingContent(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final bestYear = _destinedTiming?['best_year'] as String?;
    final bestMonth = _destinedTiming?['best_month'] as String?;
    final description = _destinedTiming?['description'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bestYear != null || bestMonth != null)
          Row(
            children: [
              if (bestYear != null)
                _buildTimingBadge(context, '최적의 해', bestYear),
              if (bestYear != null && bestMonth != null)
                const SizedBox(width: DSSpacing.xs),
              if (bestMonth != null)
                _buildTimingBadge(context, '최적의 달', bestMonth),
            ],
          ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            description,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimingBadge(BuildContext context, String label, String value) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: typography.labelSmall.copyWith(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
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
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔮', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '궁합 분석 모두 보기',
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFE91E63).withValues(alpha: 0.3),
      child: const Icon(
        Icons.star,
        size: 28,
        color: Color(0xFFE91E63),
      ),
    );
  }

  String _getConnectionTypeLabel(String type) {
    switch (type) {
      case 'ideal_match':
        return '💘 이상형으로';
      case 'friend':
        return '🤝 친구로';
      case 'colleague':
        return '💼 동료로';
      case 'fan':
        return '⭐ 팬으로';
      default:
        return '💫 궁합 분석';
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFFE91E63);
    if (score >= 80) return const Color(0xFF9C27B0);
    if (score >= 70) return const Color(0xFF2196F3);
    if (score >= 60) return const Color(0xFF4CAF50);
    return const Color(0xFF607D8B);
  }
}

class _SectionData {
  final String key;
  final String title;
  final String emoji;
  final Widget content;

  _SectionData({
    required this.key,
    required this.title,
    required this.emoji,
    required this.content,
  });
}
