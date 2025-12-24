import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/face_reading_result_v2.dart';

/// 명궁(命宮) 상세 분석 카드
/// 미간 위쪽 이마의 중심부로, 전체적인 인생 운세와 운명을 나타냅니다.
/// 기본적으로 접힌 상태로 표시됩니다.
class MyeonggungDetailCard extends StatefulWidget {
  /// 명궁 분석 데이터
  final MyeonggungAnalysis analysis;

  /// 다크모드 여부
  final bool isDark;

  /// 블러 처리 여부
  final bool isBlurred;

  /// 블러 처리된 섹션들
  final List<String>? blurredSections;

  /// 초기 펼침 상태
  final bool initiallyExpanded;

  /// 잠금 해제 요청 콜백
  final VoidCallback? onUnlockRequested;

  /// 성별 (콘텐츠 차별화)
  final String? gender;

  const MyeonggungDetailCard({
    super.key,
    required this.analysis,
    required this.isDark,
    this.isBlurred = false,
    this.blurredSections,
    this.initiallyExpanded = false,
    this.onUnlockRequested,
    this.gender,
  });

  @override
  State<MyeonggungDetailCard> createState() => _MyeonggungDetailCardState();
}

class _MyeonggungDetailCardState extends State<MyeonggungDetailCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _heightFactor = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedBlurWrapper(
      isBlurred: widget.isBlurred,
      blurredSections: widget.blurredSections ?? [],
      sectionKey: 'myeonggung',
      child: AppCard(
        style: AppCardStyle.filled,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(context),
            if (!_isExpanded) _buildSummary(context),
            ClipRect(
              child: AnimatedBuilder(
                animation: _heightFactor,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _heightFactor.value,
                    child: child,
                  );
                },
                child: _buildDetailContent(context),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DSColors.accentTertiary.withValues(alpha: 0.2),
                    Colors.amber.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star,
                color: DSColors.accentTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 제목
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '명궁',
                        style: context.heading2.copyWith(
                          color: widget.isDark
                              ? DSColors.textPrimaryDark
                              : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(命宮)',
                        style: context.labelSmall.copyWith(
                          color: widget.isDark
                              ? DSColors.textSecondaryDark
                              : DSColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildScoreBadge(context),
                    ],
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

            RotationTransition(
              turns: _iconTurns,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: widget.isDark
                    ? DSColors.textSecondaryDark
                    : DSColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context) {
    final score = widget.analysis.score;
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$score점',
        style: context.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getSubtitleByGender() {
    if (widget.gender == 'female') {
      return '인생 전반의 운명과 매력 포인트';
    } else if (widget.gender == 'male') {
      return '인생 운과 성공 잠재력';
    }
    return '인생 전반의 운세와 운명';
  }

  Widget _buildSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DSColors.accentTertiary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DSColors.accentTertiary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_quote,
              color: DSColors.accentTertiary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.analysis.summary,
                style: context.bodyMedium.copyWith(
                  color: widget.isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '더보기',
              style: context.labelSmall.copyWith(
                color: DSColors.accentTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상세 분석
          if (widget.analysis.detailedAnalysis != null)
            _buildSection(
              context,
              title: '상세 분석',
              icon: Icons.description,
              content: widget.analysis.detailedAnalysis!,
            ),

          // 운명 특성
          if (widget.analysis.destinyTraits.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTraitsSection(context),
          ],

          // 강점
          if (widget.analysis.strengths.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildListSection(
              context,
              title: '강점',
              icon: Icons.thumb_up,
              items: widget.analysis.strengths,
              color: DSColors.success,
            ),
          ],

          // 약점/주의점
          if (widget.analysis.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildListSection(
              context,
              title: '주의할 점',
              icon: Icons.warning_amber,
              items: widget.analysis.weaknesses,
              color: DSColors.warning,
            ),
          ],

          // 조언
          if (widget.analysis.advice != null) ...[
            const SizedBox(height: 16),
            _buildAdviceSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? DSColors.backgroundSecondaryDark.withValues(alpha: 0.3)
            : DSColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: DSColors.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.labelLarge.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: context.bodyMedium.copyWith(
              color: widget.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColors.accentTertiary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DSColors.accentTertiary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, size: 18, color: DSColors.accentTertiary),
              const SizedBox(width: 8),
              Text(
                '운명 특성',
                style: context.labelLarge.copyWith(
                  color: DSColors.accentTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.analysis.destinyTraits.map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DSColors.accentTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  trait,
                  style: context.labelSmall.copyWith(
                    color: DSColors.accentTertiary,
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

  Widget _buildListSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: context.bodySmall.copyWith(
                          color: widget.isDark
                              ? DSColors.textPrimaryDark
                              : DSColors.textPrimary,
                          height: 1.4,
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

  Widget _buildAdviceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.08),
            Colors.indigo.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 18, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                '운을 높이는 조언',
                style: context.labelLarge.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.analysis.advice!,
            style: context.bodyMedium.copyWith(
              color: widget.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accentTertiary;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }
}
