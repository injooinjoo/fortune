import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/face_reading_result_v2.dart';

/// 미간(眉間) 상세 분석 카드
/// 양 눈썹 사이의 영역으로, 직업운과 성취력을 나타냅니다.
/// 기본적으로 접힌 상태로 표시됩니다.
class MiganDetailCard extends StatefulWidget {
  /// 미간 분석 데이터
  final MiganAnalysis analysis;

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

  const MiganDetailCard({
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
  State<MiganDetailCard> createState() => _MiganDetailCardState();
}

class _MiganDetailCardState extends State<MiganDetailCard>
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
      sectionKey: 'migan',
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
                    DSColors.accent.withValues(alpha: 0.2),
                    Colors.indigo.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work,
                color: DSColors.accent,
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
                        '미간',
                        style: context.heading2.copyWith(
                          color: widget.isDark
                              ? DSColors.textPrimaryDark
                              : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(眉間)',
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
      return '직업운, 성취력, 면접 인상';
    } else if (widget.gender == 'male') {
      return '직업운, 리더십, 사업 성공 잠재력';
    }
    return '직업운과 성취력';
  }

  Widget _buildSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DSColors.accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DSColors.accent.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_quote,
              color: DSColors.accent,
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
                color: DSColors.accent,
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

          // 직업 적성
          if (widget.analysis.careerAptitudes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCareerSection(context),
          ],

          // 추천 직종/분야
          if (widget.analysis.recommendedFields.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRecommendedFieldsSection(context),
          ],

          // 성취 스타일
          if (widget.analysis.achievementStyle != null) ...[
            const SizedBox(height: 16),
            _buildAchievementStyleSection(context),
          ],

          // 주의할 점
          if (widget.analysis.cautions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCautionsSection(context),
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

  Widget _buildCareerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '직업 적성',
                style: context.labelLarge.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.analysis.careerAptitudes.map((aptitude) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  aptitude,
                  style: context.labelSmall.copyWith(
                    color: Colors.blue,
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

  Widget _buildRecommendedFieldsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.success.withValues(alpha: 0.08),
            Colors.teal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DSColors.success.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recommend, size: 18, color: DSColors.success),
              const SizedBox(width: 8),
              Text(
                _getRecommendedFieldsTitle(),
                style: context.labelLarge.copyWith(
                  color: DSColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.analysis.recommendedFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: DSColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        field,
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

  String _getRecommendedFieldsTitle() {
    if (widget.gender == 'female') {
      return '어울리는 분야';
    } else if (widget.gender == 'male') {
      return '성공 가능성 높은 분야';
    }
    return '추천 분야';
  }

  Widget _buildAchievementStyleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                '성취 스타일',
                style: context.labelLarge.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.analysis.achievementStyle!,
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

  Widget _buildCautionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 18, color: DSColors.warning),
              const SizedBox(width: 8),
              Text(
                '주의할 점',
                style: context.labelLarge.copyWith(
                  color: DSColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.analysis.cautions.map((caution) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: DSColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        caution,
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
                '성공을 위한 조언',
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
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }
}
