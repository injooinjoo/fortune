import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 히스토리 목록용 인사이트 카드 (관계유형 + 날짜 + scores 미니 pill)
class InsightHistoryCard extends StatelessWidget {
  final ChatInsightResult result;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const InsightHistoryCard({
    super.key,
    required this.result,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final meta = result.analysisMeta;

    return Semantics(
      label: '${_relationLabel(meta.relationType)} 대화 분석. '
          '${DateFormat('yyyy.MM.dd').format(meta.createdAt)}. '
          '온도 ${result.scores.temperature.value}점',
      child: GestureDetector(
        onTap: onTap,
        child: DSCard.elevated(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 관계유형 + 날짜 + 삭제
              Row(
                children: [
                  // 관계 아이콘 + 라벨
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: DSSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _relationIcon(meta.relationType),
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.xxs),
                        Text(
                          _relationLabel(meta.relationType),
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  // 날짜
                  Text(
                    DateFormat('yyyy.MM.dd').format(meta.createdAt),
                    style: typography.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  // 메시지 수
                  Text(
                    '${meta.messageCount}개 메시지',
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: DSSpacing.xs),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: DSSpacing.sm),

              // 중단: 요약 첫 줄
              if (result.highlights.summaryBullets.isNotEmpty)
                Text(
                  result.highlights.summaryBullets.first,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: DSSpacing.sm),

              // 하단: 미니 스코어 pills
              Row(
                children: result.scores.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: DSSpacing.xs),
                    child: _MiniPill(
                      label: entry.key,
                      value: entry.value.value,
                      colors: colors,
                      typography: typography,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relationLabel(RelationType type) {
    const labels = {
      RelationType.lover: '연인',
      RelationType.crush: '썸',
      RelationType.friend: '친구',
      RelationType.family: '가족',
      RelationType.boss: '상사',
      RelationType.other: '기타',
    };
    return labels[type] ?? '기타';
  }

  IconData _relationIcon(RelationType type) {
    const icons = {
      RelationType.lover: Icons.favorite,
      RelationType.crush: Icons.favorite_border,
      RelationType.friend: Icons.people_outline,
      RelationType.family: Icons.home_outlined,
      RelationType.boss: Icons.work_outline,
      RelationType.other: Icons.person_outline,
    };
    return icons[type] ?? Icons.person_outline;
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final int value;
  final DSColorScheme colors;
  final DSTypographyScheme typography;

  const _MiniPill({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 70
        ? colors.success
        : value >= 40
            ? colors.accentSecondary
            : colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.xs),
      ),
      child: Text(
        '$label $value',
        style: typography.labelSmall.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }
}
