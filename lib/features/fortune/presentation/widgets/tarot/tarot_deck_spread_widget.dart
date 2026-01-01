import 'package:flutter/material.dart';
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
    super.key,
    required this.cardCount,
    required this.selectedDeck,
    required this.onCardSelected,
    this.selectedIndices,
    this.cardWidth = 120,
    this.cardHeight = 180,
    this.fanAngle = 90,
    this.enableHover = true,
    this.enableSelection = true,
    this.spreadType = SpreadType.fan});

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
  
  // 드래그 애니메이션 관련 변수
  int? _draggingCardIndex;
  Offset _dragOffset = Offset.zero;
  double _dragScale = 1.0;
  
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
    debugPrint('[TarotDeckSpread] Card tapped: $index, enableSelection: ${widget.enableSelection}');
    if (widget.enableSelection) {
      HapticUtils.lightImpact();
      widget.onCardSelected(index);
      debugPrint('[TarotDeckSpread] Card selected event fired for index: $index');
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
        height: widget.cardHeight * 2.2, // 카드가 짤리지 않도록 높이 증가
        padding: const EdgeInsets.symmetric(vertical: 20), // 상하 패딩 추가
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // 카드가 컨테이너 밖으로 나갈 수 있도록 허용
          children: List.generate(widget.cardCount, (index) {
            return _buildFanCard(index, screenWidth);
          }),
        ),
      ),
    );
  }

  Widget _buildFanCard(int index, double screenWidth) {
    final isSelected = widget.selectedIndices?.contains(index) ?? false;
    final isHovered = _hoveredIndex == index;
    final isDragging = _draggingCardIndex == index;
    // 선택 순서 계산
    final selectionOrder = isSelected && widget.selectedIndices != null
        ? widget.selectedIndices!.indexOf(index) + 1
        : null;

    return AnimatedBuilder(
      animation: _fanAnimations[index],
      builder: (context, child) {
        final fanProgress = _fanAnimations[index].value;
        final position = TarotAnimations.calculateFanPosition(
          index: index,
          totalCards: widget.cardCount,
          fanAngle: widget.fanAngle,
          radius: screenWidth * 0.6,
          baseRotation: _currentRotation
        );

        // 드래그 중일 때 추가 변환
        double translateX = position.x * fanProgress;
        double translateY = position.y * fanProgress + (1 - fanProgress) * 100;
        double scale = position.scale * fanProgress;

        // 선택된 카드는 위로 올라오고 크기가 커짐
        if (isSelected) {
          translateY -= 40; // 위로 올라옴
          scale *= 1.15; // 크기 증가
        }

        // 호버 시 약간 위로
        if (isHovered && !isSelected) {
          translateY -= 20;
          scale *= 1.08;
        }

        if (isDragging) {
          translateX += _dragOffset.dx;
          translateY += _dragOffset.dy;
          scale *= _dragScale;
        }

        // z-index 조정: 선택된 카드가 맨 위로
        double zIndex = (widget.cardCount - index).toDouble();
        if (isSelected) {
          zIndex += 200; // 선택된 카드는 맨 위로
        } else if (isHovered) {
          zIndex += 100; // 호버된 카드도 위로
        }
        if (isDragging) {
          zIndex += 300;
        }

        // GestureDetector를 Transform 바깥에 배치하여 터치 영역 보존
        return GestureDetector(
          onTap: () => _handleCardTap(index),
          onVerticalDragStart: (details) {
            setState(() {
              _draggingCardIndex = index;
              _dragOffset = Offset.zero;
              _dragScale = 1.0;
            });
            HapticUtils.lightImpact();
          },
          onVerticalDragUpdate: (details) {
            setState(() {
              _dragOffset = Offset(
                _dragOffset.dx + details.delta.dx,
                _dragOffset.dy + details.delta.dy,
              );
              // 위로 드래그할수록 카드가 커지는 효과
              _dragScale = 1.0 + (-_dragOffset.dy / 200).clamp(0.0, 0.5);
            });
          },
          onVerticalDragEnd: (details) {
            // 충분히 위로 드래그했으면 카드 선택
            if (_dragOffset.dy < -50) {
              _handleCardTap(index);
              HapticUtils.mediumImpact();
            }
            setState(() {
              _draggingCardIndex = null;
              _dragOffset = Offset.zero;
              _dragScale = 1.0;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: isDragging ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(translateX, translateY, zIndex)
                ..rotateZ(isSelected ? 0 : position.rotation * fanProgress) // 선택된 카드는 회전 해제
                ..scale(scale, scale),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected || isHovered || isDragging
                    ? 1.0
                    : (0.7 + fanProgress * 0.3).clamp(0.0, 1.0),
                child: MouseRegion(
                  onEnter: widget.enableHover ? (_) => setState(() => _hoveredIndex = index) : null,
                  onExit: widget.enableHover ? (_) => setState(() => _hoveredIndex = -1) : null,
                  child: TarotCardWidget(
                    cardIndex: index,
                    deck: widget.selectedDeck,
                    width: widget.cardWidth,
                    height: widget.cardHeight,
                    showFront: true, // 카드 앞면을 보여줌
                    isSelected: isSelected,
                    isHovered: isHovered || isDragging,
                    selectionOrder: selectionOrder,
                    onTap: null, // GestureDetector에서 처리하므로 제거
                    enableFlipAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );
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
    return SizedBox(
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