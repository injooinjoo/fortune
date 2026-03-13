import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/components/cards/fortune_cards.dart';
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
    final meta = result.analysisMeta;
    final summary = result.highlights.summaryBullets.isNotEmpty
        ? result.highlights.summaryBullets.first
        : null;

    return Semantics(
      label: '${_relationLabel(meta.relationType)} 대화 분석. '
          '${DateFormat('yyyy.MM.dd').format(meta.createdAt)}. '
          '온도 ${result.scores.temperature.value}점',
      child: FortuneRecordCard(
        onTap: onTap,
        badgeLabel: _relationLabel(meta.relationType),
        badgeIcon: _relationIcon(meta.relationType),
        metaText: DateFormat('yyyy.MM.dd').format(meta.createdAt),
        trailingText: '${meta.messageCount}개 메시지',
        trailingAction: onDelete != null
            ? GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
              )
            : null,
        summary: summary,
        footer: result.scores.entries
            .map(
              (entry) => FortuneMetricPill(
                label: entry.key,
                value: '${entry.value.value}',
                tone: _scoreTone(entry.value.value),
              ),
            )
            .toList(growable: false),
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

  FortuneCardTone _scoreTone(int value) {
    if (value >= 70) {
      return FortuneCardTone.success;
    }
    if (value >= 40) {
      return FortuneCardTone.accent;
    }
    return FortuneCardTone.danger;
  }
}
