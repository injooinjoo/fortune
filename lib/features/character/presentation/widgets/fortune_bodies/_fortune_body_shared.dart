import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';

// ═══════════════════════════════════════════════════════════════════
// Shared visual components for fortune body widgets
// Used across all 9 design families for consistent, high-quality UI
// ═══════════════════════════════════════════════════════════════════

/// Hero emoji + one-line summary at the top of every fortune card body
class FortuneEmojiHeader extends StatelessWidget {
  final String emoji;
  final String text;

  const FortuneEmojiHeader({
    super.key,
    required this.emoji,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 36, height: 1.2),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          text,
          textAlign: TextAlign.center,
          style: context.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

/// Section card with emoji title and content area
class FortuneSectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget child;

  const FortuneSectionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: context.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// Single metric row: emoji + label + value
class FortuneMetricRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const FortuneMetricRow({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: DSSpacing.xs),
          Text(
            label,
            style: context.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Keyword pill tags in a wrap layout
class FortuneTagPillWrap extends StatelessWidget {
  final List<String> tags;

  const FortuneTagPillWrap({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                tag,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

/// Highlighted tip card with accent left border
class FortuneTipCard extends StatelessWidget {
  final String emoji;
  final String text;

  const FortuneTipCard({
    super.key,
    this.emoji = '💡',
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.accentSecondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Do's and Don'ts split card
class FortuneDosDontsCard extends StatelessWidget {
  final List<String> dosList;
  final List<String> dontsList;

  const FortuneDosDontsCard({
    super.key,
    required this.dosList,
    required this.dontsList,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.35),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dosList.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ DO',
                      style: context.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    ...dosList.take(3).map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: DSSpacing.xxs),
                            child: Text(
                              '• $item',
                              style: context.bodySmall.copyWith(height: 1.55),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            if (dosList.isNotEmpty && dontsList.isNotEmpty)
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
                color: colors.border.withValues(alpha: 0.35),
              ),
            if (dontsList.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '❌ DON\'T',
                      style: context.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    ...dontsList.take(3).map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: DSSpacing.xxs),
                            child: Text(
                              '• $item',
                              style: context.bodySmall.copyWith(
                                color: colors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lucky items in a 2-column grid with emojis
class FortuneLuckyItemGrid extends StatelessWidget {
  final Map<String, dynamic> items;

  const FortuneLuckyItemGrid({super.key, required this.items});

  static const _emojiMap = {
    'color': '🎨',
    'number': '🔢',
    'direction': '🧭',
    'item': '✨',
    'time': '⏰',
    'place': '📍',
    'food': '🍀',
    'day': '📅',
    'avoid': '🚫',
  };

  static const _labelMap = {
    'color': '행운 색상',
    'number': '행운 숫자',
    'direction': '행운 방향',
    'item': '행운 아이템',
    'time': '행운 시간',
    'place': '행운 장소',
    'food': '행운 음식',
    'day': '행운 요일',
    'avoid': '피할 것',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entries = items.entries
        .where((e) =>
            e.value != null &&
            e.value.toString().trim().isNotEmpty &&
            e.key != 'colorHex' &&
            e.key != 'emoji')
        .toList(growable: false);
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍀 행운 포인트',
            style: context.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: entries.map((e) {
              final emoji = _emojiMap[e.key] ?? '🌟';
              final label = _labelMap[e.key] ?? e.key;
              return _LuckyChip(
                emoji: emoji,
                label: label,
                value: e.value.toString(),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

/// Horizontal progress bar with label and percentage
class FortuneProgressBar extends StatelessWidget {
  final String label;
  final int score;
  final String? emoji;

  const FortuneProgressBar({
    super.key,
    required this.label,
    required this.score,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = (score / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: DSSpacing.xxs),
          ],
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: context.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.accentSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          SizedBox(
            width: 32,
            child: Text(
              '$score%',
              style: context.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quote block with accent left bar
class FortuneQuoteBlock extends StatelessWidget {
  final String emoji;
  final String title;
  final String text;

  const FortuneQuoteBlock({
    super.key,
    this.emoji = '🔮',
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: colors.accentSecondary.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DSRadius.lg),
                bottomLeft: Radius.circular(DSRadius.lg),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        title,
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    text,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bullet list with emoji bullets
class FortuneBulletList extends StatelessWidget {
  final List<String> items;
  final String bullet;
  final bool isWarning;

  const FortuneBulletList({
    super.key,
    required this.items,
    this.bullet = '•',
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bullet,
                    style: context.bodySmall.copyWith(
                      color: isWarning ? colors.warning : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      item,
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: isWarning
                            ? colors.textSecondary
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

// ═══ Private Widgets ═══

class _LuckyChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _LuckyChip({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: DSSpacing.xxs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: context.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══ Helper Functions ═══

String? fortuneStr(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

int? fortuneInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<String> fortuneStrList(dynamic value) {
  if (value is! List) return const [];
  return value.map(fortuneStr).whereType<String>().toList(growable: false);
}

List<Map<String, dynamic>> fortuneMapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map(fortuneAsMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

Map<String, dynamic>? fortuneAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return null;
}
