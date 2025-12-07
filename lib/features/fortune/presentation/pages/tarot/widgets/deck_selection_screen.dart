import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../domain/models/tarot_card_model.dart';

class DeckSelectionScreen extends StatelessWidget {
  final TarotDeckType selectedDeck;
  final Function(TarotDeckType) onDeckSelected;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const DeckSelectionScreen({
    super.key,
    required this.selectedDeck,
    required this.onDeckSelected,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allDecks = TarotDeckMetadata.getAllDecks();

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 헤더 (컴팩트)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED),
                            const Color(0xFF3B82F6),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.style,
                        color: TossDesignSystem.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '타로 덱 선택',
                      style: TypographyUnified.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '당신에게 맞는 타로 덱을 선택하세요',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 덱 리스트
              ...allDecks.map((deck) => _DeckCard(
                deck: deck,
                isSelected: selectedDeck.name.toLowerCase() == deck.id.replaceAll('_', ''),
                onTap: () => onDeckSelected(_deckIdToType(deck.id)),
                isDark: isDark,
              )),

              const SizedBox(height: 100), // FloatingButton 공간
            ],
          ),
        ),
      ),
    );
  }

  // deck id를 TarotDeckType으로 변환
  TarotDeckType _deckIdToType(String deckId) {
    switch (deckId) {
      case 'rider_waite':
        return TarotDeckType.riderWaite;
      case 'thoth':
        return TarotDeckType.thoth;
      case 'ancient_italian':
        return TarotDeckType.ancientItalian;
      case 'before_tarot':
        return TarotDeckType.beforeTarot;
      case 'after_tarot':
        return TarotDeckType.afterTarot;
      case 'golden_dawn_cicero':
        return TarotDeckType.goldenDawnCicero;
      case 'golden_dawn_wang':
        return TarotDeckType.goldenDawnWang;
      case 'grand_etteilla':
        return TarotDeckType.grandEtteilla;
      default:
        return TarotDeckType.riderWaite;
    }
  }
}

class _DeckCard extends StatelessWidget {
  final TarotDeck deck;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DeckCard({
    required this.deck,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : (isDark ? TossDesignSystem.gray700 : TossDesignSystem.gray200),
            width: isSelected ? 2 : 1,
          ),
          color: isDark
              ? TossDesignSystem.gray800.withValues(alpha: 0.5)
              : TossDesignSystem.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 프리뷰 카드들 (3장 팬 형태)
              SizedBox(
                width: 90,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: List.generate(
                    deck.previewCards.length.clamp(0, 3),
                    (index) {
                      final angles = <double>[-0.15, 0.0, 0.15];
                      final offsets = <double>[-15.0, 0.0, 15.0];
                      return Positioned(
                        left: offsets[index] + 15,
                        child: Transform.rotate(
                          angle: angles[index],
                          child: Container(
                            width: 50,
                            height: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: TossDesignSystem.gray900.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                deck.getCardImagePath('major/${deck.previewCards[index]}.jpg'),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: deck.primaryColor.withValues(alpha: 0.3),
                                    child: Center(
                                      child: Icon(
                                        Icons.style,
                                        color: TossDesignSystem.white.withValues(alpha: 0.5),
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 덱 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deck.koreanName,
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: TossDesignSystem.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.artist} (${deck.year})',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DeckTag(text: deck.difficulty.displayName, color: deck.difficulty.color),
                        const SizedBox(width: 8),
                        _DeckTag(text: deck.style.displayName, color: deck.primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckTag extends StatelessWidget {
  final String text;
  final Color color;

  const _DeckTag({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TypographyUnified.labelTiny.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
