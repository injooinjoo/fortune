import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../features/fortune/domain/models/match_insight.dart';
import '../../../../shared/widgets/smart_image.dart';

/// 채팅용 경기 인사이트 결과 카드
///
/// 경기 정보, 승률 예측, 팀 분석, 행운 요소 표시
class ChatMatchInsightCard extends ConsumerStatefulWidget {
  final MatchInsight insight;

  const ChatMatchInsightCard({
    super.key,
    required this.insight,
  });

  @override
  ConsumerState<ChatMatchInsightCard> createState() =>
      _ChatMatchInsightCardState();
}

class _ChatMatchInsightCardState extends ConsumerState<ChatMatchInsightCard> {
  MatchInsight get insight => widget.insight;
  static const String _sportsHeroImage =
      'assets/images/chat/backgrounds/bg_sports_game.webp';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

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
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 경기 정보
          _buildHeader(colors, typography),

          // 승률 예측 바
          _buildPredictionBar(colors, typography),

          // 팀 분석
          _buildTeamAnalysis(colors, typography),

          // 행운 요소
          _buildFortuneElements(colors, typography),

          // 조언
          _buildAdvice(colors, typography),

          // 면책 메시지
          _buildCaution(colors, typography),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(DSColorScheme colors, DSTypographyScheme typography) {
    return SizedBox(
      height: 170,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SmartImage(
            path: _sportsHeroImage,
            fit: BoxFit.cover,
            errorWidget: Container(
              color: colors.accent.withValues(alpha: 0.1),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.background.withValues(alpha: 0.1),
                  colors.background.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
          Positioned(
            top: DSSpacing.sm,
            right: DSSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.background.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.border,
                ),
              ),
              child: Text(
                '${insight.score}점',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          Positioned(
            left: DSSpacing.md,
            right: DSSpacing.md,
            bottom: DSSpacing.md,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.sportEmoji,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.matchTitle,
                        style: typography.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          shadows: [
                            Shadow(
                              color: colors.background.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        '${insight.leagueName} · ${_formatGameDate(insight.gameDate)}',
                        style: typography.labelSmall.copyWith(
                          color: colors.textPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionBar(
      DSColorScheme colors, DSTypographyScheme typography) {
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
              const SizedBox(width: DSSpacing.xs),
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
                      color: colors.surface,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildTeamAnalysis(
      DSColorScheme colors, DSTypographyScheme typography) {
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
          ),

          const SizedBox(height: DSSpacing.xs),

          // 상대팀 분석
          _buildTeamCard(
            insight.opponentAnalysis,
            isOurs: false,
            colors: colors,
            typography: typography,
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
                const SizedBox(width: DSSpacing.xs),
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
            const SizedBox(height: DSSpacing.xs),
            Text(
              '강점: ${team.strengths.join(', ')}',
              style: typography.labelSmall.copyWith(
                color: colors.success,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (team.concerns.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '우려: ${team.concerns.join(', ')}',
              style: typography.labelSmall.copyWith(
                color: colors.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFortuneElements(
      DSColorScheme colors, DSTypographyScheme typography) {
    final elements = insight.fortuneElements;
    final itemData = <Map<String, String>>[
      {
        'label': '색상',
        'value': elements.luckyColor,
        'icon': FortuneCardImages.getLuckyColorIcon(
          _normalizeLuckyColor(elements.luckyColor),
        ),
      },
      {
        'label': '숫자',
        'value': elements.luckyNumber.toString(),
        'icon': FortuneCardImages.getLuckyNumberIcon(elements.luckyNumber),
      },
      {
        'label': '시간',
        'value': elements.luckyTime,
        'icon': FortuneCardImages.getLuckyTimeIcon(
          _normalizeLuckyTime(elements.luckyTime),
        ),
      },
      {
        'label': '아이템',
        'value': elements.luckyItem,
        'icon': FortuneCardImages.getSectionIcon('lucky'),
      },
    ];

    if (elements.luckySection != null && elements.luckySection!.isNotEmpty) {
      itemData.add({
        'label': '주목',
        'value': elements.luckySection!,
        'icon': FortuneCardImages.getSectionIcon('timing'),
      });
    }

    if (elements.luckyAction != null && elements.luckyAction!.isNotEmpty) {
      itemData.add({
        'label': '응원',
        'value': elements.luckyAction!,
        'icon': FortuneCardImages.getSectionIcon('action'),
      });
    }

    final visibleItems =
        itemData.where((item) => item['value']!.trim().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SmartImage(
                path: FortuneCardImages.getSectionIcon('lucky'),
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: DSSpacing.xs),
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
            children: visibleItems
                .map((item) => _buildElementChip(
                      label: item['label']!,
                      value: item['value']!,
                      iconPath: item['icon']!,
                      colors: colors,
                      typography: typography,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildElementChip({
    required String label,
    required String value,
    required String iconPath,
    required DSColorScheme colors,
    required DSTypographyScheme typography,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmartImage(
            path: iconPath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: DSSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                value,
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _normalizeLuckyColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('red') || lower.contains('빨') || lower.contains('홍')) {
      return 'red';
    }
    if (lower.contains('orange') || lower.contains('주황')) {
      return 'orange';
    }
    if (lower.contains('yellow') || lower.contains('노랑')) {
      return 'yellow';
    }
    if (lower.contains('green') || lower.contains('초록')) {
      return 'green';
    }
    if (lower.contains('blue') || lower.contains('파랑') || lower.contains('청')) {
      return 'blue';
    }
    if (lower.contains('purple') || lower.contains('보라')) {
      return 'purple';
    }
    if (lower.contains('pink') || lower.contains('분홍')) {
      return 'pink';
    }
    if (lower.contains('white') || lower.contains('흰')) {
      return 'white';
    }
    if (lower.contains('black') || lower.contains('검')) {
      return 'black';
    }
    if (lower.contains('gold') || lower.contains('금')) {
      return 'gold';
    }
    if (lower.contains('silver') || lower.contains('은')) {
      return 'silver';
    }
    if (lower.contains('coral') || lower.contains('코랄')) {
      return 'coral';
    }
    return lower;
  }

  String _normalizeLuckyTime(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('오전') ||
        lower.contains('아침') ||
        lower.contains('morning')) {
      return 'morning';
    }
    if (lower.contains('오후') ||
        lower.contains('점심') ||
        lower.contains('afternoon')) {
      return 'afternoon';
    }
    if (lower.contains('저녁') || lower.contains('evening')) {
      return 'evening';
    }
    if (lower.contains('밤') || lower.contains('night')) {
      return 'night';
    }
    if (lower.contains('새벽') || lower.contains('dawn')) {
      return 'dawn';
    }
    return lower;
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
              const SizedBox(width: DSSpacing.xs),
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
}
