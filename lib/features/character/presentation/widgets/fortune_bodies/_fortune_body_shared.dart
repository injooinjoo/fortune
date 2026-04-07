import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '../../utils/fortune_key_localizer.dart';

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
    const accentBarWidth = 4.0;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: accentBarWidth,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DSRadius.lg),
                  bottomLeft: Radius.circular(DSRadius.lg),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              accentBarWidth + DSSpacing.md,
              DSSpacing.md,
              DSSpacing.md,
              DSSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                child,
              ],
            ),
          ),
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
            style: context.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: context.labelSmall.copyWith(
                color: colors.textPrimary,
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
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                tag,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

/// Highlighted tip card with accent background
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
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.27),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.bodySmall.copyWith(
                height: 1.5,
                color: colors.textSecondary,
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '✅ DO',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    ...dosList.take(3).map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: DSSpacing.xs),
                            child: Text(
                              '• $item',
                              style: context.bodySmall.copyWith(height: 1.6),
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
                color: colors.border.withValues(alpha: 0.2),
              ),
            if (dontsList.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '❌ DON\'T',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    ...dontsList.take(3).map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: DSSpacing.xs),
                            child: Text(
                              '• $item',
                              style: context.bodySmall.copyWith(
                                color: colors.textSecondary,
                                height: 1.6,
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍀 행운 포인트',
            style: context.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...entries.map((e) {
            final emoji = _emojiMap[e.key] ?? '🌟';
            final label =
                _labelMap[e.key] ?? FortuneKeyLocalizer.labelFor(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  Text(
                    '$emoji $label',
                    style: context.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    e.value.toString(),
                    style: context.labelSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
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
            Text(emoji!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: DSSpacing.xs),
          ],
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: context.labelTiny.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          SizedBox(
            width: 20,
            child: Text(
              '$score',
              style: context.labelTiny.copyWith(
                color: colors.accent,
                fontSize: 10,
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
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            text,
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
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
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bullet,
                    style: context.bodyMedium.copyWith(
                      color: isWarning ? colors.warning : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: context.bodyMedium.copyWith(
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

/// Entertainment disclaimer shown at the bottom of fortune results (Apple 1.1.6)
class FortuneEntertainmentDisclaimer extends StatelessWidget {
  const FortuneEntertainmentDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: DSSpacing.md),
      child: Text(
        'For entertainment purposes only. Results are AI-generated and should not be taken as factual advice.\n'
        '본 결과는 엔터테인먼트 목적으로 제공되며, AI가 생성한 콘텐츠입니다. 실제 조언으로 받아들이지 마세요.',
        style: context.labelSmall.copyWith(
          color: colors.textTertiary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Health disclaimer shown at the bottom of health fortune results (Apple 1.4.1)
class FortuneHealthDisclaimer extends StatelessWidget {
  const FortuneHealthDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: DSSpacing.md),
      child: Text(
        'This wellness content is for entertainment and lifestyle reference only. It is not medical advice or a diagnosis.\n'
        '이 웰니스 콘텐츠는 엔터테인먼트 및 생활 참고용이며, 의학적 조언이나 진단이 아닙니다. 건강 문제는 전문가와 상담하세요.',
        style: context.labelSmall.copyWith(
          color: colors.textTertiary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

Map<String, dynamic>? fortuneAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return null;
}
