import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/tarot/tarot_card_catalog.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../domain/models/fortune_survey_config.dart';

class ChatTarotDeckPicker extends ConsumerWidget {
  final ValueChanged<SurveyOption> onSelect;

  const ChatTarotDeckPicker({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDeckId = ref.watch(selectedTarotDeckProvider);
    final decks = TarotDeckMetadata.getAllDecks().toList(growable: false)
      ..sort((left, right) {
        if (left.id == selectedDeckId) return -1;
        if (right.id == selectedDeckId) return 1;
        return 0;
      });

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
        itemCount: decks.length,
        separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
        itemBuilder: (context, index) {
          final deck = decks[index];
          final isSelected = deck.id == selectedDeckId;

          return _DeckCard(
            key: ValueKey('tarot-deck-${deck.id}'),
            deck: deck,
            isSelected: isSelected,
            onTap: () async {
              await ref
                  .read(selectedTarotDeckProvider.notifier)
                  .selectDeck(deck.id);
              onSelect(
                SurveyOption(
                  id: deck.id,
                  label: deck.koreanName,
                  emoji: '🃏',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final TarotDeck deck;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeckCard({
    super.key,
    required this.deck,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 176,
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              deck.primaryColor.withValues(alpha: 0.9),
              deck.secondaryColor.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.xl),
          border: Border.all(
            color: isSelected
                ? colors.textPrimary.withValues(alpha: 0.14)
                : colors.border.withValues(alpha: 0.18),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: deck.primaryColor.withValues(alpha: 0.16),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.xs,
                  vertical: DSSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
                child: Text(
                  deck.difficulty.label,
                  style: context.labelSmall.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 72,
              child: Stack(
                children: [
                  for (var i = 0; i < deck.previewCards.length && i < 3; i++)
                    Positioned(
                      left: 20.0 * i,
                      top: 4.0 * i,
                      child: Transform.rotate(
                        angle: (-0.16 + (i * 0.16)),
                        child: _DeckPreviewCard(
                          imagePath: TarotCardCatalog.previewImagePath(
                            deck.id,
                            deck.previewCards[i],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              deck.koreanName,
              style: context.headingSmall.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: DSSpacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.description,
                    style: context.bodySmall.copyWith(
                      color: onPrimary.withValues(alpha: 0.92),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    isSelected ? '최근 선택한 덱' : '이 덱으로 리딩 시작',
                    style: context.labelMedium.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _DeckPreviewCard extends StatelessWidget {
  final String imagePath;

  const _DeckPreviewCard({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      width: 44,
      height: 72,
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: onPrimary.withValues(alpha: 0.28),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
