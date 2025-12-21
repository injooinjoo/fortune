import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../domain/models/tarot_card_model.dart';

class DeckFlashLayer extends StatefulWidget {
  final TarotDeckType deckType;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback? onTap;

  const DeckFlashLayer({
    super.key,
    required this.deckType,
    required this.fadeAnimation,
    required this.slideAnimation,
    this.onTap,
  });

  @override
  State<DeckFlashLayer> createState() => _DeckFlashLayerState();
}

class _DeckFlashLayerState extends State<DeckFlashLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 페이드인 (0-500ms) -> 유지 (500-2500ms) -> 페이드아웃 (2500-3000ms)
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 16.7, // ~500ms
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 66.6, // ~2000ms
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 16.7, // ~500ms
      ),
    ]).animate(_flashController);

    _flashController.forward();
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final deckId = _getDeckId(widget.deckType);
    final deck = TarotDeckMetadata.availableDecks[deckId];

    if (deck == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: colors.background,
        child: Stack(
          children: [
            // 배경 그래디언트
            _buildBackground(colors, deck),

            // 중앙 덱 프리뷰
            Center(
              child: FadeTransition(
                opacity: widget.fadeAnimation,
                child: SlideTransition(
                  position: widget.slideAnimation,
                  child: _buildDeckPreview(deck),
                ),
              ),
            ),

            // 상단 플래시 레이어
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _flashOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _flashOpacity.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 60,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            deck.primaryColor.withOpacity(0.95),
                            deck.primaryColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '오늘의 타로 카드덱은?',
                              style: DSTypography.labelMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              deck.koreanName,
                              style: DSTypography.displayMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 하단 탭 안내
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _flashOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _flashOpacity.value * 0.7,
                    child: Center(
                      child: Text(
                        '탭하여 계속하기',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(DSColorScheme colors, TarotDeck deck) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.background,
            deck.primaryColor.withOpacity(0.1),
            colors.background,
          ],
        ),
      ),
    );
  }

  Widget _buildDeckPreview(TarotDeck deck) {
    // 3장의 카드를 팬 형태로 표시
    return SizedBox(
      width: 280,
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(
          deck.previewCards.length.clamp(0, 3),
          (index) {
            final angles = <double>[-0.15, 0.0, 0.15];
            final offsets = <double>[-50.0, 0.0, 50.0];

            return Positioned(
              left: offsets[index] + 60,
              child: Transform.rotate(
                angle: angles[index],
                child: Container(
                  width: 140,
                  height: 210,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: deck.primaryColor.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      deck.getCardImagePath(
                          'major/${deck.previewCards[index]}.jpg'),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                deck.primaryColor,
                                deck.secondaryColor,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.style,
                            color: Colors.white.withOpacity(0.5),
                            size: 48,
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
    );
  }

  String _getDeckId(TarotDeckType deckType) {
    switch (deckType) {
      case TarotDeckType.riderWaite:
        return 'rider_waite';
      case TarotDeckType.thoth:
        return 'thoth';
      case TarotDeckType.ancientItalian:
        return 'ancient_italian';
      case TarotDeckType.beforeTarot:
        return 'before_tarot';
      case TarotDeckType.afterTarot:
        return 'after_tarot';
      case TarotDeckType.goldenDawnCicero:
        return 'golden_dawn_cicero';
      case TarotDeckType.goldenDawnWang:
        return 'golden_dawn_wang';
      case TarotDeckType.grandEtteilla:
        return 'grand_etteilla';
    }
  }
}
