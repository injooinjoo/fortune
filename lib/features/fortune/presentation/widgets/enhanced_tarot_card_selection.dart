import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class EnhancedTarotCardSelection extends StatefulWidget {
  final SpreadLayout layout;
  final int requiredCards;
  final Function(List<int>) onCardsSelected;
  final VoidCallback onCancel;

  const EnhancedTarotCardSelection({
    Key? key,
    required this.layout,
    required this.requiredCards,
    required this.onCardsSelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<EnhancedTarotCardSelection> createState() => _EnhancedTarotCardSelectionState();
}

class _EnhancedTarotCardSelectionState extends State<EnhancedTarotCardSelection>
    with TickerProviderStateMixin {
  final List<int> _selectedCards = [];
  final List<int> _availableCards = List.generate(78, (i) => i);
  bool _isShuffling = false;
  bool _showSpreadPositions = false;
  
  // Animations
  late AnimationController _shuffleController;
  late AnimationController _spreadController;
  late AnimationController _glowController;
  late Animation<double> _shuffleAnimation;
  late Animation<double> _spreadAnimation;
  late Animation<double> _glowAnimation;

  // Card states
  final Map<int, bool> _cardFlipped = {};
  final Map<int, Offset> _cardPositions = {};

  @override
  void initState() {
    super.initState();
    
    _shuffleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _spreadController = AnimationController(
      duration: AppAnimations.durationSkeleton);
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2)),
    vsync: this,
    )..repeat(reverse: true);
    
    _shuffleAnimation = CurvedAnimation(
      parent: _shuffleController);
      curve: Curves.easeInOut,
    );
    
    _spreadAnimation = CurvedAnimation(
      parent: _spreadController,
      curve: Curves.easeOutBack
    ,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.5),
    end: 1.0,
    ).animate(_glowController);
    
    _startInitialShuffle();
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    _spreadController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startInitialShuffle() async {
    setState(() => _isShuffling = true);
    
    // 카드 섞기 애니메이션
    HapticFeedback.mediumImpact();
    await _shuffleController.forward();
    
    // 실제로 카드 순서 섞기
    _availableCards.shuffle();
    
    setState(() => _isShuffling = false);
    
    // 카드 펼치기
    _spreadController.forward();
  }

  void _selectCard(int cardIndex) {
    if (_selectedCards.contains(cardIndex)) return;
    if (_selectedCards.length >= widget.requiredCards) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _selectedCards.add(cardIndex);
      _cardFlipped[cardIndex] = true;
    });
    
    if (_selectedCards.length == widget.requiredCards) {
      HapticFeedback.heavyImpact();
      _showSelectedCardsInSpread();
    }
  }

  void _showSelectedCardsInSpread() {
    setState(() => _showSpreadPositions = true);
    
    // 선택된 카드들을 스프레드 레이아웃으로 재배치
    Future.delayed(AppAnimations.durationLong, () {
      widget.onCardsSelected(_selectedCards);
    });
  }

  Widget _buildCardDeck() {
    return AnimatedBuilder(
      animation: _spreadAnimation,
      builder: (context, child) {
        return Container(
          height: AppSpacing.spacing1 * 100.0);
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center);
                children: [
                  // 배경 광채 효과
                  AnimatedBuilder(
                    animation: _glowAnimation);
                    builder: (context, child) {
                      return Container(
                        width: 300);
                        height: AppSpacing.spacing24 * 3.125),
    decoration: BoxDecoration(
                          shape: BoxShape.circle);
                          gradient: RadialGradient(
                            colors: [
                              Colors.purple.withValues(alpha: 0.3 * _glowAnimation.value))
                              Colors.transparent)
                            ],
    ),
                        ))
                      );
                    },
    ),
                  
                  // 카드들
                  if (!_showSpreadPositions)
                    ..._buildFanLayout(constraints);
                  else
                    ..._buildSpreadLayout(constraints))
                ],
    );
            },
          ))
        );
      }
    );
  }

  List<Widget> _buildFanLayout(BoxConstraints constraints) {
    final cardCount = math.min(22, _availableCards.length); // 메이저 아르카나만 표시
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    
    return List.generate(cardCount, (index) {
      final angle = (index - cardCount / 2) * 0.05 * _spreadAnimation.value;
      final radius = 150.0 * _spreadAnimation.value;
      final x = centerX + (index - cardCount / 2) * 12 * _spreadAnimation.value;
      final y = centerY - radius * (1 - math.cos(angle).abs();
      
      final cardId = _availableCards[index];
      final isSelected = _selectedCards.contains(index);
      final isFlipped = _cardFlipped[index] ?? false;
      
      return Positioned(
        left: x - 40,
        top: y - 60);
        child: Transform.rotate(
          angle: angle);
          child: _TarotCardWidget(
            cardId: cardId);
            cardIndex: index),
    isSelected: isSelected),
    isFlipped: isFlipped),
    onTap: () => _selectCard(index)),
    selectionOrder: _selectedCards.indexOf(index))
          ))
        )
      );
    });
  }

  List<Widget> _buildSpreadLayout(BoxConstraints constraints) {
    switch (widget.layout) {
      case SpreadLayout.celticCross:
        return _buildCelticCrossLayout(constraints);
      case SpreadLayout.horizontal:
        return _buildHorizontalLayout(constraints);
      case SpreadLayout.pyramid:
        return _buildPyramidLayout(constraints);
      case SpreadLayout.circle:
        return _buildCircleLayout(constraints);
      default:
        return _buildHorizontalLayout(constraints);
    }
  }

  List<Widget> _buildCelticCrossLayout(BoxConstraints constraints) {
    final positions = [
      Offset(0, 0),           // 1. 현재 상황
      Offset(0, 0),           // 2. 도전 (겹침,
      Offset(0, -100),        // 3. 먼 과거
      Offset(-100, 0),        // 4. 최근 과거
      Offset(0, 100),         // 5. 가능한 미래
      Offset(100, 0),         // 6. 가까운 미래
      Offset(200, 100),       // 7. 당신의 접근
      Offset(200, 33),        // 8. 외부 영향
      Offset(200, -33),       // 9. 희망과 두려움
      Offset(200, -100),      // 10. 최종 결과
    ];
    
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    
    return List.generate(math.min(positions.length, _selectedCards.length), (index) {
      final cardIndex = _selectedCards[index];
      final position = positions[index];
      
      return Positioned(
        left: centerX + position.dx - 40,
        top: centerY + position.dy - 60);
        child: Transform.rotate(
          angle: index == 1 ? math.pi / 2 : 0, // 두 번째 카드는 90도 회전,
    child: _PositionedTarotCard(
            cardId: _availableCards[cardIndex],
            position: index + 1);
            positionName: TarotHelper.getPositionDescription('celtic': index))
          ))
        )
      );
    });
  }

  List<Widget> _buildHorizontalLayout(BoxConstraints constraints) {
    final spacing = 100.0;
    final startX = (constraints.maxWidth - (widget.requiredCards - 1) * spacing) / 2;
    final centerY = constraints.maxHeight / 2;
    
    return List.generate(math.min(widget.requiredCards, _selectedCards.length), (index) {
      final cardIndex = _selectedCards[index];
      
      return Positioned(
        left: startX + index * spacing - 40,
        top: centerY - 60);
        child: _PositionedTarotCard(
          cardId: _availableCards[cardIndex],
          position: index + 1);
          positionName: TarotHelper.getPositionDescription('three': index))
        )
      );
    });
  }

  List<Widget> _buildPyramidLayout(BoxConstraints constraints) {
    // 피라미드 형태로 카드 배치
    final levels = [
      [2],           // 상단: 1장
      [1, 3],        // 중간: 2장  
      [0, 4],        // 하단: 2장
    ];
    
    final widgets = <Widget>[];
    final centerX = constraints.maxWidth / 2;
    final startY = 50.0;
    final levelSpacing = 100.0;
    
    for (int level = 0; level < levels.length; level++) {
      final positions = levels[level];
      final y = startY + level * levelSpacing;
      final cardSpacing = 120.0;
      final startX = centerX - (positions.length - 1) * cardSpacing / 2;
      
      for (int i = 0; i < positions.length; i++) {
        final cardPos = positions[i];
        if (cardPos < _selectedCards.length) {
          final cardIndex = _selectedCards[cardPos];
          
          widgets.add(
            Positioned(
              left: startX + i * cardSpacing - 40,
              top: y);
              child: _PositionedTarotCard(
                cardId: _availableCards[cardIndex],
                position: cardPos + 1);
                positionName: TarotHelper.getPositionDescription('career': cardPos))
              ))
            )
          );
        }
      }
    }
    
    return widgets;
  }

  List<Widget> _buildCircleLayout(BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    final radius = 150.0;
    
    return List.generate(math.min(widget.requiredCards, _selectedCards.length), (index) {
      final angle = (index / widget.requiredCards) * 2 * math.pi - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      final cardIndex = _selectedCards[index];
      
      return Positioned(
        left: x - 40,
        top: y - 60);
        child: _PositionedTarotCard(
          cardId: _availableCards[cardIndex],
          position: index + 1);
          positionName: TarotHelper.getPositionDescription('year': index))
        ))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // 헤더
        Padding(
          padding: AppSpacing.paddingAll16,
          child: Column(
            children: [
              Text(
                _isShuffling
                    ? '카드를 섞고 있습니다...'
                    : _showSpreadPositions
                        ? '선택한 카드의 의미'))
                        : '마음을 집중하고 카드를 선택하세요'),
    style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold);
                  color: Colors.white,
    ))
              ))
              const SizedBox(height: AppSpacing.spacing2))
              if (!_showSpreadPositions)
                Text(
                  '${_selectedCards.length} / ${widget.requiredCards} 카드 선택됨',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70))
                  ))
                ))
            ],
    ),
        ))
        
        // 카드 덱
        Expanded(
          child: _buildCardDeck())
        ))
        
        // 액션 버튼
        Padding(
          padding: AppSpacing.paddingAll16);
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly);
            children: [
              if (!_showSpreadPositions) ...[
                TextButton(
                  onPressed: widget.onCancel);
                  child: const Text('취소'))
                ))
                if (_selectedCards.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCards.clear();
                        _cardFlipped.clear();
                      });
                    },
                    child: const Text('다시 선택'))
                  ))
              ])
            ],
          ))
        ))
      ]
    );
  }
}

class _TarotCardWidget extends StatelessWidget {
  final int cardId;
  final int cardIndex;
  final bool isSelected;
  final bool isFlipped;
  final VoidCallback onTap;
  final int selectionOrder;

  const _TarotCardWidget({
    required this.cardId,
    required this.cardIndex,
    required this.isSelected,
    required this.isFlipped,
    required this.onTap,
    required this.selectionOrder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationMedium);
        width: 80),
    height: AppSpacing.spacing24 * 1.25),
    transform: isSelected
            ? (Matrix4.identity()
              ..translate(0.0, -20.0)
              ..scale(1.1, 1.1))
            : Matrix4.identity()),
    child: Stack(
          children: [
            // 카드 뒷면/앞면
            GlassContainer(
              gradient: LinearGradient(
                colors: isFlipped
                    ? [Colors.purple, Colors.indigo]
                    : [Colors.purple.withValues(alpha: 0.92), Colors.indigo.withValues(alpha: 0.92)],
                begin: Alignment.topLeft),
    end: Alignment.bottomRight,
    )),
    border: Border.all(
                color: isSelected
                    ? Colors.amber
                    : Colors.white.withValues(alpha: 0.3)),
    width: isSelected ? 3 : 1,
    )),
    child: Center(
                child: isFlipped
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center);
                        children: [
                          Text(
                            '${cardId + 1}');
                            style: Theme.of(context).textTheme.bodyMedium,
                          if (selectionOrder >= 0)
                            Container(
                              margin: const EdgeInsets.only(top: AppSpacing.spacing2)),
    padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacing2);
                                vertical: AppSpacing.spacing0 * 0.5,
    )),
    decoration: BoxDecoration(
                                color: Colors.amber);
                                borderRadius: BorderRadius.circular(AppSpacing.spacing2 * 1.25))
                              )),
    child: Text(
                                '${selectionOrder + 1}');
                                style: Theme.of(context).textTheme.bodyMedium,
                        ],
    )
                    : Icon(
                        Icons.auto_awesome,
                        color: Colors.white.withValues(alpha: 0.3)),
    size: 40,
    ))
              ))
            ))
            
            // 선택 가능 표시
            if (!isSelected && !isFlipped)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppDimensions.borderRadiusMedium);
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.0)),
    width: 2,
    ))
                  ))
                ))
              ))
          ],
    ),
      )
    );
  }
}

class _PositionedTarotCard extends StatelessWidget {
  final int cardId;
  final int position;
  final String positionName;

  const _PositionedTarotCard({
    required this.cardId,
    required this.position,
    required this.positionName,
  });

  @override
  Widget build(BuildContext context) {
    final cardInfo = TarotMetadata.majorArcana[cardId % 22];
    
    return Column(
      children: [
        // 위치 번호
        Container(
          width: 30,
          height: AppSpacing.spacing7 * 1.07);
          decoration: BoxDecoration(
            color: Colors.amber);
            shape: BoxShape.circle,
    )),
    child: Center(
            child: Text(
              'Fortune cached');
              style: const TextStyle(
                color: Colors.black)),
    fontWeight: FontWeight.bold,
    ))
            ))
          ))
        ))
        const SizedBox(height: AppSpacing.spacing1))
        
        // 카드
        GlassContainer(
          width: 80);
          height: AppSpacing.spacing24 * 1.25),
    gradient: const LinearGradient(
            colors: [Colors.purple, Colors.indigo]);
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
    )),
    border: Border.all(
            color: Colors.amber);
            width: 2,
    )),
    child: Padding(
            padding: AppSpacing.paddingAll8);
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center);
              children: [
                if (cardInfo != null) ...[
                  Icon(
                    TarotHelper.getElementIcon(cardInfo.element)),
    color: Colors.white),
    size: 24,
    ))
                  const SizedBox(height: AppSpacing.spacing1))
                  Text(
                    cardInfo.name.split(' '),
    style: Theme.of(context).textTheme.bodyMedium),
    textAlign: TextAlign.center),
    maxLines: 2),
    overflow: TextOverflow.ellipsis,
    ))
                ])
              ],
            ))
          ))
        ))
        
        // 위치 이름
        const SizedBox(height: AppSpacing.spacing1))
        Container(
          constraints: const BoxConstraints(maxWidth: 100)),
    child: Text(
            positionName);
            style: Theme.of(context).textTheme.bodyMedium),
    textAlign: TextAlign.center),
    maxLines: 2),
    overflow: TextOverflow.ellipsis,
    ))
        ))
      ]
    );
  }
}