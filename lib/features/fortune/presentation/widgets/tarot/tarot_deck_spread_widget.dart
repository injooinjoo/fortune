import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../core/utils/haptic_utils.dart';
import 'tarot_card_widget.dart';
import 'tarot_animations.dart';

/// Reusable widget for displaying tarot cards in a fan spread
class TarotDeckSpreadWidget extends StatefulWidget {
  final int cardCount;
  final TarotDeck selectedDeck;
  final Function(int) onCardSelected;
  final List<int>? selectedIndices;
  final double cardWidth;
  final double cardHeight;
  final double fanAngle;
  final bool enableHover;
  final bool enableSelection;
  final SpreadType spreadType;

  const TarotDeckSpreadWidget({
    Key? key,
    required this.cardCount,
    required this.selectedDeck,
    required this.onCardSelected,
    this.selectedIndices,
    this.cardWidth = 120,
    this.cardHeight = 180,
    this.fanAngle = 90,
    this.enableHover = true,
    this.enableSelection = true,
    this.spreadType = SpreadType.fan}) : super(key: key);

  @override
  State<TarotDeckSpreadWidget> createState() => _TarotDeckSpreadWidgetState();
}

class _TarotDeckSpreadWidgetState extends State<TarotDeckSpreadWidget>
    with TickerProviderStateMixin {
  late TarotAnimationController _animationManager;
  late List<Animation<double>> _fanAnimations;
  
  int _hoveredIndex = -1;
  double _currentRotation = 0;
  double _dragStartX = 0;
  
  @override
  void initState() {
    super.initState();
    _animationManager = TarotAnimationController(vsync: this);
    
    // Create fan animation controller
    final fanController = _animationManager.createController(
      'fan',
      TarotAnimations.fanSpreadDuration);
    
    // Create staggered fan animations
    _fanAnimations = TarotAnimations.createFanAnimations(
      controller: fanController,
      cardCount: widget.cardCount
    );
    
    // Start fan animation
    fanController.forward();
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  void _handleCardTap(int index) {
    if (widget.enableSelection) {
      HapticUtils.lightImpact();
      widget.onCardSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    switch (widget.spreadType) {
      case SpreadType.fan:
        return _buildFanSpread(screenWidth);
      case SpreadType.grid:
        return _buildGridSpread();
      case SpreadType.stack:
        return _buildStackSpread();
    }
  }

  Widget _buildFanSpread(double screenWidth) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _dragStartX = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          final dragDistance = details.globalPosition.dx - _dragStartX;
          _currentRotation = (dragDistance / screenWidth) * math.pi * 0.5;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _currentRotation = 0;
        });
      },
      child: Container(
        height: widget.cardHeight * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(widget.cardCount, (index) {
            return _buildFanCard(index, screenWidth);
          }))));
  }

  Widget _buildFanCard(int index, double screenWidth) {
    print('[TarotFan] === Card $index Build Start ===');
    final isSelected = widget.selectedIndices?.contains(index) ?? false;
    final isHovered = _hoveredIndex == index;
    print('Fortune cached');
    
    return AnimatedBuilder(
      animation: _fanAnimations[index],
      builder: (context, child) {
        final fanProgress = _fanAnimations[index].value;
        print('Fortune cached');
        final position = TarotAnimations.calculateFanPosition(
          index: index,
          totalCards: widget.cardCount,
          fanAngle: widget.fanAngle,
          radius: screenWidth * 0.6,
          baseRotation: _currentRotation
        );
        print('[TarotFan] Card $index - position.x: ${position.x}, position.y: ${position.y}');
        print('[TarotFan] Card $index - position.scale: ${position.scale}, rotation: ${position.rotation}');
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(
              position.x * fanProgress,
              position.y * fanProgress + (1 - fanProgress) * 100,
              (widget.cardCount - index).toDouble())
            ..rotateZ(position.rotation * fanProgress)
            ..scale(position.scale * fanProgress, position.scale * fanProgress),
          child: Opacity(
            opacity: (0.3 + fanProgress * 0.7).clamp(0.0, 1.0),
            child: MouseRegion(
              onEnter: widget.enableHover ? (_) => setState(() => _hoveredIndex = index) : null,
              onExit: widget.enableHover ? (_) => setState(() => _hoveredIndex = -1) : null,
              child: TarotCardWidget(
                cardIndex: index,
                deck: widget.selectedDeck,
                width: widget.cardWidth,
                height: widget.cardHeight,
                isSelected: isSelected,
                isHovered: isHovered,
                onTap: () => _handleCardTap(index),
                enableFlipAnimation: false))));
                  },
    );
  }

  Widget _buildGridSpread() {
    final crossAxisCount = (MediaQuery.of(context).size.width / (widget.cardWidth + 16)).floor();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: widget.cardWidth / widget.cardHeight,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16),
      itemCount: widget.cardCount,
      itemBuilder: (context, index) {
        final isSelected = widget.selectedIndices?.contains(index) ?? false;
        
        return TarotCardEntrance(
          animation: _fanAnimations[index],
          index: index,
          child: TarotCardWidget(
            cardIndex: index,
            deck: widget.selectedDeck,
            width: widget.cardWidth,
            height: widget.cardHeight,
            isSelected: isSelected,
            onTap: () => _handleCardTap(index)));
                },
    );
  }

  Widget _buildStackSpread() {
    return Container(
      height: widget.cardHeight * 1.2,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(widget.cardCount, (index) {
          final isTop = index == widget.cardCount - 1;
          final offset = index * 2.0;
          
          return AnimatedBuilder(
            animation: _fanAnimations[index],
            builder: (context, child) {
              final progress = _fanAnimations[index].value;
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(offset * progress, offset * progress, index.toDouble())
                  ..scale(1.0 - (index * 0.02), 1.0 - (index * 0.02)),
                child: Opacity(
                  opacity: (isTop ? 1.0 : 0.8 * progress).clamp(0.0, 1.0),
                  child: TarotCardWidget(
                    cardIndex: index,
                    deck: widget.selectedDeck,
                    width: widget.cardWidth,
                    height: widget.cardHeight,
                    onTap: isTop ? () => _handleCardTap(index) : null,
                  ),
                ),
              );
            },
          );
        }).reversed.toList()));
  }
}

/// Different spread types for tarot cards
enum SpreadType {
  fan,   // Cards spread in a fan/arc
  grid,  // Cards in a grid layout
  stack, // Cards stacked on top of each other
}