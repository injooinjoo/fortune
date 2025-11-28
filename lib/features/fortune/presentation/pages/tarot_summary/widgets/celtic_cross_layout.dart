import 'package:flutter/material.dart';
import 'mini_card_widget.dart';

class CelticCrossLayout extends StatelessWidget {
  final List<int> cards;
  final double fontScale;
  final Function(int) onCardTap;

  const CelticCrossLayout({
    super.key,
    required this.cards,
    required this.fontScale,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center cards (0, 1)
          Positioned(
            left: 120,
            top: 150,
            child: _buildCard(0),
          ),
          Positioned(
            left: 140,
            top: 130,
            child: Transform.rotate(
              angle: 1.57,
              child: _buildCard(1),
            ),
          ),
          // Cross cards (2, 3, 4, 5)
          Positioned(
            left: 120,
            top: 20,
            child: _buildCard(2),
          ),
          Positioned(
            left: 120,
            bottom: 20,
            child: _buildCard(3),
          ),
          Positioned(
            left: 20,
            top: 150,
            child: _buildCard(4),
          ),
          Positioned(
            right: 120,
            top: 150,
            child: _buildCard(5),
          ),
          // Staff cards (6, 7, 8, 9)
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildCard(6),
          ),
          Positioned(
            right: 20,
            bottom: 120,
            child: _buildCard(7),
          ),
          Positioned(
            right: 20,
            top: 120,
            child: _buildCard(8),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: _buildCard(9),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    if (index >= cards.length) return const SizedBox();

    return MiniCardWidget(
      index: index,
      cardIndex: cards[index],
      fontScale: fontScale,
      onTap: () => onCardTap(index),
    );
  }
}
