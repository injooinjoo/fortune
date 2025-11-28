import 'package:flutter/material.dart';
import 'mini_card_widget.dart';

class HorizontalCardLayout extends StatelessWidget {
  final List<int> cards;
  final double fontScale;
  final Function(int) onCardTap;

  const HorizontalCardLayout({
    super.key,
    required this.cards,
    required this.fontScale,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        cards.length,
        (index) => MiniCardWidget(
          index: index,
          cardIndex: cards[index],
          fontScale: fontScale,
          onTap: () => onCardTap(index),
        ),
      ),
    );
  }
}
