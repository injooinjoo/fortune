import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/font_config.dart';
import '../../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../domain/models/tarot_card_model.dart';

class DeckSelectionScreen extends StatelessWidget {
  final TarotDeckType selectedDeck;
  final Function(TarotDeckType) onDeckSelected;
  final VoidCallback? onDailyTarot; // F12: 오늘의 타로 콜백
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const DeckSelectionScreen({
    super.key,
    required this.selectedDeck,
    required this.onDeckSelected,
    this.onDailyTarot,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '타로 카드 선택',
                      style: DSTypography.headingMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '당신에게 맞는 타로 카드를 선택하세요',
                      style: DSTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // F12: 오늘의 타로 퀵 액션
              if (onDailyTarot != null) ...[
                _DailyTarotCard(
                  onTap: onDailyTarot!,
                  colors: colors,
                ),
                const SizedBox(height: 16),
                // 구분선
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '또는 덱 선택',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.border)),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 덱 리스트
              ...allDecks.map((deck) => _DeckCard(
                deck: deck,
                isSelected: selectedDeck.name.toLowerCase() == deck.id.replaceAll('_', ''),
                onTap: () => onDeckSelected(_deckIdToType(deck.id)),
                colors: colors,
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
  final DSColorScheme colors;

  const _DeckCard({
    required this.deck,
    required this.isSelected,
    required this.onTap,
    required this.colors,
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
                : colors.border,
            width: isSelected ? 2 : 1,
          ),
          color: colors.surface,
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
                                  color: Colors.black.withValues(alpha: 0.2),
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
                                        color: Colors.white.withValues(alpha: 0.5),
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
                            style: DSTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
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
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.artist} (${deck.year})',
                      style: DSTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
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
        style: DSTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// F12: 오늘의 타로 퀵 액션 카드
class _DailyTarotCard extends StatelessWidget {
  final VoidCallback onTap;
  final DSColorScheme colors;

  const _DailyTarotCard({
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF3B82F6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 카드 아이콘
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '오늘의 타로',
                        style: DSTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'QUICK',
                          style: DSTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: FontConfig.captionSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘의 덱으로 타로를 시작해보세요',
                    style: DSTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            // 화살표
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
