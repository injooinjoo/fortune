import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../domain/models/emotion_analysis.dart';

/// 관계 인상 분석 카드
/// 다른 사람에게 어떻게 보이는지 분석 결과를 표시합니다.
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class RelationshipImpressionCard extends StatefulWidget {
  /// 인상 분석 데이터
  final ImpressionAnalysis impressionAnalysis;

  /// 다크 모드 여부
  final bool isDark;

  /// 사용자 성별 (콘텐츠 차별화)
  final String? gender;

  /// 블러 처리 여부
  final bool isBlurred;

  /// 블러 처리된 섹션들
  final List<String>? blurredSections;

  /// 잠금 해제 요청 콜백
  final VoidCallback? onUnlockRequested;

  /// 초기 펼침 상태
  final bool initiallyExpanded;

  const RelationshipImpressionCard({
    super.key,
    required this.impressionAnalysis,
    required this.isDark,
    this.gender,
    this.isBlurred = false,
    this.blurredSections,
    this.onUnlockRequested,
    this.initiallyExpanded = false,
  });

  @override
  State<RelationshipImpressionCard> createState() => _RelationshipImpressionCardState();
}

class _RelationshipImpressionCardState extends State<RelationshipImpressionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedBlurWrapper(
      isBlurred: widget.isBlurred,
      blurredSections: widget.blurredSections ?? [],
      sectionKey: 'relationship_impression',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DSColors.accentSecondary.withValues(alpha: 0.08),
              DSColors.accent.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DSColors.accentSecondary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (항상 표시)
            _buildHeader(context),

            // 첫인상 키워드 태그들 (항상 표시)
            if (widget.impressionAnalysis.firstImpressionKeywords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFirstImpressionTags(context),
              ),

            // 상세 내용 (펼쳤을 때)
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDetailContent(context),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  /// 헤더 빌더
  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DSColors.accentSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people_outline,
                color: DSColors.accentSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // 제목
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '다른 사람 눈에 비친 나',
                    style: context.heading3.copyWith(
                      color: widget.isDark
                          ? DSColors.textPrimaryDark
                          : DSColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitleByGender(),
                    style: context.labelSmall.copyWith(
                      color: widget.isDark
                          ? DSColors.textSecondaryDark
                          : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 펼침/접힘 아이콘
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: widget.isDark
                    ? DSColors.textSecondaryDark
                    : DSColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 성별에 따른 부제목
  String _getSubtitleByGender() {
    if (widget.gender == 'female') {
      return '친구, 연인, 동료가 느끼는 당신의 매력 💝';
    } else if (widget.gender == 'male') {
      return '주변 사람들이 느끼는 당신의 인상';
    }
    return '주변에서 느끼는 당신의 인상';
  }

  /// 첫인상 키워드 태그들
  Widget _buildFirstImpressionTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.impressionAnalysis.firstImpressionKeywords
          .map((keyword) => _buildKeywordTag(context, keyword))
          .toList(),
    );
  }

  /// 키워드 태그
  Widget _buildKeywordTag(BuildContext context, String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DSColors.accentSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$keyword',
        style: context.labelMedium.copyWith(
          color: DSColors.accentSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 상세 콘텐츠
  Widget _buildDetailContent(BuildContext context) {
    final impression = widget.impressionAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 점수 바 섹션
        _buildScoreSection(context),

        const SizedBox(height: 16),

        // 관계별 인상 카드들
        _buildImpressionItem(
          context,
          icon: Icons.favorite_border,
          title: '친구 관계에서',
          description: impression.relationshipImpression,
          color: Colors.pink,
        ),

        const SizedBox(height: 12),

        _buildImpressionItem(
          context,
          icon: Icons.work_outline,
          title: '직장/학교에서',
          description: impression.professionalImpression,
          color: Colors.blue,
        ),

        // 연애 인상 (여성용 또는 데이터가 있는 경우)
        if (impression.romanticImpression != null &&
            impression.romanticImpression!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildImpressionItem(
            context,
            icon: Icons.favorite,
            title: '연애에서',
            description: impression.romanticImpression!,
            color: Colors.red,
          ),
        ],

        // 종합 인상 코멘트
        if (impression.overallImpression != null &&
            impression.overallImpression!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildOverallImpression(context, impression.overallImpression!),
        ],

        // 인상 개선 팁
        if (impression.improvementSuggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildImprovementTips(context, impression.improvementSuggestions),
        ],
      ],
    );
  }

  /// 점수 섹션
  Widget _buildScoreSection(BuildContext context) {
    final impression = widget.impressionAnalysis;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? DSColors.surfaceDark
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildScoreBar(
            context,
            label: '신뢰감',
            score: impression.trustScore,
            color: DSColors.success,
            emoji: '🤝',
          ),
          const SizedBox(height: 12),
          _buildScoreBar(
            context,
            label: '친근감',
            score: impression.approachabilityScore,
            color: DSColors.accentSecondary,
            emoji: '😊',
          ),
          const SizedBox(height: 12),
          _buildScoreBar(
            context,
            label: '카리스마',
            score: impression.charismaScore,
            color: DSColors.accent,
            emoji: '✨',
          ),
        ],
      ),
    );
  }

  /// 점수 바
  Widget _buildScoreBar(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
    required String emoji,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: context.labelMedium.copyWith(
              color: widget.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: widget.isDark
                  ? DSColors.backgroundSecondaryDark
                  : DSColors.backgroundSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 35,
          child: Text(
            '$score',
            style: context.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 인상 항목
  Widget _buildImpressionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodyMedium.copyWith(
                    color: widget.isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 종합 인상 코멘트
  Widget _buildOverallImpression(BuildContext context, String comment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColors.accentSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DSColors.accentSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote,
            color: DSColors.accentSecondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              comment,
              style: context.bodyMedium.copyWith(
                color: widget.isDark
                    ? DSColors.textPrimaryDark
                    : DSColors.textPrimary,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 인상 개선 팁
  Widget _buildImprovementTips(BuildContext context, List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: DSColors.warning,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '더 좋은 인상을 위한 팁',
              style: context.labelLarge.copyWith(
                color: DSColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: context.bodySmall.copyWith(
                    color: widget.isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
