import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/fortune/domain/models/match_insight.dart';

/// 채팅용 경기 인사이트 결과 카드
///
/// 경기 정보, 승률 예측, 팀 분석, 행운 요소 표시
class ChatMatchInsightCard extends ConsumerStatefulWidget {
  final MatchInsight insight;
  final bool isBlurred;

  const ChatMatchInsightCard({
    super.key,
    required this.insight,
    this.isBlurred = false,
  });

  @override
  ConsumerState<ChatMatchInsightCard> createState() => _ChatMatchInsightCardState();
}

class _ChatMatchInsightCardState extends ConsumerState<ChatMatchInsightCard> {
  MatchInsight get insight => widget.insight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 경기 정보
          _buildHeader(colors, typography, isDark),

          // 승률 예측 바
          _buildPredictionBar(colors, typography),

          // 팀 분석
          _buildTeamAnalysis(colors, typography, isDark),

          // 행운 요소
          _buildFortuneElements(colors, typography, isDark),

          // 조언
          _buildAdvice(colors, typography),

          // 면책 메시지
          _buildCaution(colors, typography),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.lg),
        ),
      ),
      child: Row(
        children: [
          // 종목 이모지
          Text(
            insight.sportEmoji,
            style: const TextStyle(fontSize: 28),
          ),

          const SizedBox(width: DSSpacing.sm),

          // 경기 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.matchTitle,
                  style: typography.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${insight.leagueName} · ${_formatGameDate(insight.gameDate)}',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(insight.score).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Text(
              '${insight.score}점',
              style: typography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(insight.score),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionBar(DSColorScheme colors, DSTypographyScheme typography) {
    final prediction = insight.prediction;
    final winProb = prediction.winProbability;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '승리 예측',
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                prediction.confidenceEmoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                '신뢰도: ${prediction.confidenceText}',
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.sm),

          // 승률 바
          Stack(
            children: [
              // 배경
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
              ),

              // 진행 바
              FractionallySizedBox(
                widthFactor: insight.winProbabilityProgress,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.accent,
                        colors.accent.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '$winProb%',
                    style: typography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 핵심 변수
          if (prediction.keyFactors.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: prediction.keyFactors.map((factor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Text(
                    factor,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamAnalysis(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '팀 분석',
            style: typography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),

          // 응원팀 분석
          _buildTeamCard(
            insight.favoriteTeamAnalysis,
            isOurs: true,
            colors: colors,
            typography: typography,
            isDark: isDark,
          ),

          const SizedBox(height: DSSpacing.xs),

          // 상대팀 분석
          _buildTeamCard(
            insight.opponentAnalysis,
            isOurs: false,
            colors: colors,
            typography: typography,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(
    TeamAnalysis team, {
    required bool isOurs,
    required DSColorScheme colors,
    required DSTypographyScheme typography,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isOurs
            ? colors.accent.withValues(alpha: 0.05)
            : colors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isOurs
              ? colors.accent.withValues(alpha: 0.2)
              : colors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (team.formEmoji != null) ...[
                Text(team.formEmoji!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
              ],
              Text(
                team.name,
                style: typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                team.recentForm,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),

          if (team.strengths.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '강점: ${team.strengths.join(', ')}',
              style: typography.labelSmall.copyWith(
                color: AppColors.positive,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (team.concerns.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '우려: ${team.concerns.join(', ')}',
              style: typography.labelSmall.copyWith(
                color: AppColors.negative,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFortuneElements(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    final elements = insight.fortuneElements;

    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍀', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '행운 요소',
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.sm),

          // 그리드
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              _buildElementChip(
                '🎨 색상',
                elements.luckyColor,
                colors,
                typography,
              ),
              _buildElementChip(
                '🔢 숫자',
                elements.luckyNumber.toString(),
                colors,
                typography,
              ),
              _buildElementChip(
                '⏰ 시간',
                elements.luckyTime,
                colors,
                typography,
              ),
              _buildElementChip(
                '🎁 아이템',
                elements.luckyItem,
                colors,
                typography,
              ),
              if (elements.luckySection != null)
                _buildElementChip(
                  '🎯 주목',
                  elements.luckySection!,
                  colors,
                  typography,
                ),
              if (elements.luckyAction != null)
                _buildElementChip(
                  '👏 응원',
                  elements.luckyAction!,
                  colors,
                  typography,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementChip(
    String label,
    String value,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: typography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvice(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💬', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '오늘의 조언',
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            insight.advice,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaution(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.only(
        left: DSSpacing.md,
        right: DSSpacing.md,
        bottom: DSSpacing.md,
      ),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              insight.cautionMessage,
              style: typography.labelSmall.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGameDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.month}/${date.day}($weekday) $hour:$minute';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.positive;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return Colors.orange;
    return AppColors.negative;
  }
}
