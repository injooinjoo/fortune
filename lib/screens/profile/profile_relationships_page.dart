import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import 'providers/character_relationships_provider.dart';

class ProfileRelationshipsPage extends ConsumerWidget {
  const ProfileRelationshipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileRelationshipStatsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '스토리 캐릭터 관계도',
          style: context.heading3.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.md,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        children: [
          DSCard.elevated(
            padding: const EdgeInsets.all(DSSpacing.lg),
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
                  stats.topEntry == null
                      ? '아직 깊어진 관계가 없어요. 캐릭터와 대화를 시작해 보세요.'
                      : '${stats.topEntry!.character.name}님과 가장 가까워요. '
                          '${stats.topEntry!.phaseName} 단계, 호감도 ${stats.topEntry!.lovePercent}%입니다.',
                  style: context.bodyMedium.copyWith(
                    color: colors.textSecondary,
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
          const SizedBox(height: DSSpacing.xl),
          ...stats.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.md),
              child: DSCard.outlined(
                padding: const EdgeInsets.all(DSSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DSRadius.full),
                      child: Image.asset(
                        entry.character.avatarAsset,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                              if (entry.unreadCount > 0)
                                DSChip(
                                  label: '새 메시지 ${entry.unreadCount}',
                                  selected: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            entry.character.shortDescription,
                            style: context.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DSSpacing.sm),
                          Wrap(
                            spacing: DSSpacing.xs,
                            runSpacing: DSSpacing.xs,
                            children: [
                              DSChip(
                                label: entry.phaseName,
                                style: DSChipStyle.outlined,
                              ),
                              DSChip(
                                label: '호감도 ${entry.lovePercent}%',
                                style: DSChipStyle.outlined,
                              ),
                              DSChip(
                                label: '대화 ${entry.totalMessages}',
                                style: DSChipStyle.outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.sm),
                          Text(
                            entry.hasConversation
                                ? entry.previewText
                                : '아직 대화를 시작하지 않았어요.',
                            style: context.labelMedium.copyWith(
                              color: colors.textTertiary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        color: colors.backgroundSecondary,
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
