import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
import 'providers/character_relationships_provider.dart';

class ProfileRelationshipsPage extends ConsumerWidget {
  const ProfileRelationshipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileRelationshipStatsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PaperRuntimeAppBar(title: '스토리 캐릭터 관계도'),
      body: PaperRuntimeBackground(
        applySafeArea: false,
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.md,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          children: [
            PaperRuntimePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '관계 요약',
                    style: context.heading4.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    _summaryText(stats),
                    style: context.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  Wrap(
                    spacing: DSSpacing.sm,
                    runSpacing: DSSpacing.sm,
                    children: [
                      _MetricChip(
                        label: '활성 관계',
                        value: '${stats.activeRelationshipCount}명',
                      ),
                      _MetricChip(
                        label: '총 대화',
                        value: '${stats.totalMessages}개',
                      ),
                      _MetricChip(
                        label: '읽지 않음',
                        value: '${stats.totalUnread}개',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            if (stats.entries.isEmpty)
              PaperRuntimePanel(
                elevated: false,
                child: Text(
                  '아직 관계 데이터가 없어요. 캐릭터와 대화를 시작하면 여기에서 흐름을 한눈에 볼 수 있습니다.',
                  style: context.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    height: 1.55,
                  ),
                ),
              )
            else
              ...stats.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.md),
                  child: _RelationshipEntryCard(entry: entry),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _summaryText(ProfileRelationshipStats stats) {
    final topEntry = stats.topEntry;
    if (topEntry == null) {
      return '아직 깊어진 관계가 없어요. 캐릭터와 대화를 시작해 보세요.';
    }

    return '${topEntry.character.name}님과 가장 가까워요. '
        '${topEntry.phaseName} 단계, 호감도 ${topEntry.lovePercent}%입니다.';
  }
}

class _RelationshipEntryCard extends StatelessWidget {
  const _RelationshipEntryCard({
    required this.entry,
  });

  final ProfileRelationshipEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PaperRuntimePanel(
      elevated: false,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CharacterAvatar(entry: entry),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.character.name,
                        style: context.bodyLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusChip(entry: entry),
                  ],
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  entry.character.shortDescription,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSSpacing.sm),
                Wrap(
                  spacing: DSSpacing.xs,
                  runSpacing: DSSpacing.xs,
                  children: [
                    _InfoChip(label: entry.phaseName),
                    _InfoChip(label: '호감도 ${entry.lovePercent}%'),
                    _InfoChip(label: '대화 ${entry.totalMessages}'),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                Text(
                  entry.hasConversation
                      ? entry.previewText
                      : '아직 대화를 시작하지 않았어요. 먼저 말을 걸어 관계를 시작해 보세요.',
                  style: context.labelMedium.copyWith(
                    color: colors.textTertiary,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterAvatar extends StatelessWidget {
  const _CharacterAvatar({
    required this.entry,
  });

  final ProfileRelationshipEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = entry.character.name.trim().isEmpty
        ? '관'
        : entry.character.name.trim().characters.first;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: entry.character.accentColor,
        borderRadius: BorderRadius.circular(DSRadius.full),
      ),
      child: entry.character.avatarAsset.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(DSRadius.full),
              child: Image.asset(
                entry.character.avatarAsset,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: Text(
                initial,
                style: context.heading4.copyWith(
                  color: colors.background,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.entry,
  });

  final ProfileRelationshipEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUnread = entry.unreadCount > 0;
    final label = hasUnread
        ? '새 메시지 ${entry.unreadCount}'
        : entry.hasConversation
            ? '대화 중'
            : '휴면 중';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: hasUnread
            ? colors.successBackground.withValues(alpha: 0.88)
            : colors.surfaceSecondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: hasUnread
              ? colors.toggleActive.withValues(alpha: 0.36)
              : colors.border.withValues(alpha: 0.82),
        ),
      ),
      child: Text(
        label,
        style: context.labelSmall.copyWith(
          color: hasUnread ? colors.toggleActive : colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.82),
        ),
      ),
      child: Text(
        label,
        style: context.labelSmall.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(color: colors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: context.labelSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
