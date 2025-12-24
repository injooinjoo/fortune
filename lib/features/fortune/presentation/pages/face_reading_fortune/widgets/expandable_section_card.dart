import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/fortune_result.dart';

/// 접이식 섹션 카드
/// 오관, 십이궁 등 상세 분석 섹션을 접을 수 있는 형태로 제공합니다.
/// 기본적으로 접힌 상태(요약만 표시)로 시작합니다.
class ExpandableSectionCard extends StatefulWidget {
  /// 섹션 제목
  final String title;

  /// 섹션 부제목 (선택적)
  final String? subtitle;

  /// 요약 텍스트 (접힌 상태에서 표시)
  final String summary;

  /// 상세 콘텐츠 위젯
  final Widget detailContent;

  /// 아이콘
  final IconData icon;

  /// 테마 색상
  final Color color;

  /// 다크모드 여부
  final bool isDark;

  /// 블러 처리 여부
  final bool isBlurred;

  /// 블러 처리된 섹션들
  final List<String>? blurredSections;

  /// 섹션 키 (블러 처리용)
  final String sectionKey;

  /// 초기 펼침 상태
  final bool initiallyExpanded;

  /// 프리미엄 배지 표시 여부
  final bool showPremiumBadge;

  /// 펼침 상태 변경 콜백
  final ValueChanged<bool>? onExpansionChanged;

  /// 잠금 해제 요청 콜백
  final VoidCallback? onUnlockRequested;

  const ExpandableSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.summary,
    required this.detailContent,
    required this.icon,
    required this.color,
    required this.isDark,
    this.isBlurred = false,
    this.blurredSections,
    required this.sectionKey,
    this.initiallyExpanded = false,
    this.showPremiumBadge = false,
    this.onExpansionChanged,
    this.onUnlockRequested,
  });

  @override
  State<ExpandableSectionCard> createState() => _ExpandableSectionCardState();
}

class _ExpandableSectionCardState extends State<ExpandableSectionCard>
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
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

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
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedBlurWrapper(
      isBlurred: widget.isBlurred,
      blurredSections: widget.blurredSections ?? [],
      sectionKey: widget.sectionKey,
      child: AppCard(
        style: AppCardStyle.filled,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 헤더 (항상 표시)
            _buildHeader(context),

            // 요약 (접힌 상태)
            if (!_isExpanded) _buildSummary(context),

            // 상세 콘텐츠 (펼친 상태)
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
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 제목 및 부제목
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: context.heading2.copyWith(
                          color: widget.isDark
                              ? DSColors.textPrimaryDark
                              : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.showPremiumBadge) ...[
                        const SizedBox(width: 8),
                        _buildPremiumBadge(context),
                      ],
                    ],
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: context.labelSmall.copyWith(
                        color: widget.isDark
                            ? DSColors.textSecondaryDark
                            : DSColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 펼침/접힘 아이콘
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

  Widget _buildPremiumBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            size: 12,
            color: widget.color,
          ),
          const SizedBox(width: 4),
          Text(
            '프리미엄',
            style: context.labelSmall.copyWith(
              color: widget.color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.format_quote,
              color: widget.color.withValues(alpha: 0.5),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.summary,
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
                color: widget.color,
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark
              ? DSColors.backgroundSecondaryDark.withValues(alpha: 0.3)
              : DSColors.backgroundSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.detailContent,
      ),
    );
  }
}

/// 오관/십이궁 요약 아이템
class SimplifiedAnalysisItem extends StatelessWidget {
  /// 부위/궁 이름
  final String name;

  /// 한자 이름 (선택적)
  final String? hanjaName;

  /// 요약 설명
  final String summary;

  /// 점수 (0-100)
  final int? score;

  /// 아이콘
  final IconData icon;

  /// 색상
  final Color color;

  /// 다크모드 여부
  final bool isDark;

  const SimplifiedAnalysisItem({
    super.key,
    required this.name,
    this.hanjaName,
    required this.summary,
    this.score,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.surfaceDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: context.labelLarge.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hanjaName != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        hanjaName!,
                        style: context.labelSmall.copyWith(
                          color: isDark
                              ? DSColors.textSecondaryDark
                              : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: context.bodySmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 점수 (있는 경우)
          if (score != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getScoreColor(score!).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$score점',
                style: context.labelSmall.copyWith(
                  color: _getScoreColor(score!),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }
}
