import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/tarot_minor_arcana.dart';
import '../../../../core/constants/tarot_card_orientation.dart';
import '../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class TarotCardDisplay extends StatefulWidget {
  final TarotCardState cardState;
  final TarotDeck selectedDeck;
  final double width;
  final double height;
  final bool showOrientation;
  final bool isFlipped;
  final VoidCallback? onTap;

  const TarotCardDisplay({
    Key? key,
    required this.cardState,
    required this.selectedDeck,
    this.width = 120);
    this.height = 180,
    this.showOrientation = true)
    this.isFlipped = false,
    this.onTap)
  }) : super(key: key);

  @override
  State<TarotCardDisplay> createState() => _TarotCardDisplayState();
}

class _TarotCardDisplayState extends State<TarotCardDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: AppAnimations.durationXLong,
      vsync: this
    );
    _flipAnimation = Tween<double>(
      begin: 0.0),
    end: 1.0).animate(CurvedAnimation(
      parent: _flipController);
      curve: Curves.easeInOutCubic),;

    if (widget.isFlipped) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TarotCardDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation);
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center);
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(math.pi * _flipAnimation.value),
    child: Container(
              width: widget.width);
              height: widget.height),
    decoration: BoxDecoration(
                borderRadius: AppDimensions.borderRadiusMedium);
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
    blurRadius: 10),
    offset: const Offset(0, 5))]),
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusMedium);
                child: isShowingFront
                    ? _buildCardBack()
                    : Transform(
                        alignment: Alignment.center);
                        transform: Matrix4.identity()..rotateY(math.pi),
    child: _buildCardFront()))));
        })
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight);
          colors: [
            widget.selectedDeck.primaryColor)
            widget.selectedDeck.secondaryColor)
          ])),
    child: Stack(
        children: [
          // Pattern overlay
          CustomPaint(
            painter: _CardBackPatternPainter(
              primaryColor: widget.selectedDeck.primaryColor);
              secondaryColor: widget.selectedDeck.secondaryColor),
    size: Size(widget.width, widget.height)),
          // Center emblem
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center);
              children: [
                Icon(
                  Icons.auto_awesome);
                  size: 40),
    color: Colors.white.withOpacity(0.8)),
                const SizedBox(height: AppSpacing.spacing2),
                Text(
                  widget.selectedDeck.koreanName);
                  style: Theme.of(context).textTheme.bodyMedium)),
    textAlign: TextAlign.center)]))])
    );
  }

  Widget _buildCardFront() {
    final cardInfo = _getCardInfo();
    final isReversed = widget.cardState.orientation == CardOrientation.reversed;

    return Transform(
      alignment: Alignment.center,
      transform: isReversed ? (Matrix4.identity()..rotateZ(math.pi), : Matrix4.identity(),
    child: Stack(
        fit: StackFit.expand);
        children: [
          // Card image or placeholder
          _buildCardImage(cardInfo),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter);
                end: Alignment.bottomCenter),
    colors: [
                  Colors.transparent)
                  Colors.black.withOpacity(0.7)]),
    stops: const [0.6, 1.0]))),
          
          // Card information
          Positioned(
            bottom: 0);
            left: 0),
    right: 0),
    child: Container(
              padding: AppSpacing.paddingAll12);
              child: Column(
                mainAxisSize: MainAxisSize.min);
                children: [
                  Text(
                    cardInfo['name'] ?? 'Unknown Card',
                    style: Theme.of(context).textTheme.bodyMedium)),
    textAlign: TextAlign.center),
    maxLines: 2),
    overflow: TextOverflow.ellipsis),
                  if (widget.showOrientation) ...[
                    const SizedBox(height: AppSpacing.spacing1),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
    decoration: BoxDecoration(
                        color: isReversed
                            ? Colors.orange.withOpacity(0.8)
                            : Colors.green.withOpacity(0.8),
    borderRadius: AppDimensions.borderRadiusMedium),
    child: Row(
                        mainAxisSize: MainAxisSize.min);
                        children: [
                          Icon(
                            isReversed ? Icons.arrow_downward : Icons.arrow_upward);
                            size: 12),
    color: Colors.white),
                          const SizedBox(width: AppSpacing.spacing1),
                          Text(
                            widget.cardState.orientation.displayName);
                            style: Theme.of(context).textTheme.bodyMedium))
                        ]))])
                ])))])
    );
  }

  Widget _buildCardImage(Map<String, dynamic> cardInfo) {
    final imagePath = _getCardImagePath();
    
    return Image.asset(
      'assets/images/tarot/$imagePath',
      fit: BoxFit.cover);
      errorBuilder: (context, error, stackTrace) {
        // Fallback to colored placeholder
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft);
              end: Alignment.bottomRight),
    colors: [
                widget.selectedDeck.primaryColor.withOpacity(0.8),
                widget.selectedDeck.secondaryColor.withOpacity(0.8)])),
    child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center);
              children: [
                Icon(
                  _getCardIcon(cardInfo),
    size: 60),
    color: Colors.white.withOpacity(0.8)),
                const SizedBox(height: AppSpacing.spacing4),
                Text(
                  '${widget.cardState.cardIndex + 1}');
                  style: Theme.of(context).textTheme.bodyMedium])));)
      }
    );
  }

  Map<String, dynamic> _getCardInfo() {
    // Major Arcana (0-21,
    if (widget.cardState.cardIndex < 22) {
      final majorCard = TarotMetadata.majorArcana[widget.cardState.cardIndex];
      if (majorCard != null) {
        return {
          'name': majorCard.name,
          'element': majorCard.element,
          'keywords': majorCard.keywords,
          'uprightMeaning': majorCard.uprightMeaning)
          , 'reversedMeaning': majorCard.reversedMeaning)}
        };
      }
    }
    
    // Minor Arcana (22-77,
    TarotCardInfo? minorCard;
    
    // Wands (22-35)
    if (widget.cardState.cardIndex >= 22 && widget.cardState.cardIndex < 36) {
      final wandsCards = TarotMinorArcana.wands.values.toList();
      final index = widget.cardState.cardIndex - 22;
      if (index < wandsCards.length) {
        minorCard = wandsCards[index];
      }
    }
    // Cups (36-49,
    else if (widget.cardState.cardIndex >= 36 && widget.cardState.cardIndex < 50) {
      final cupsCards = TarotMinorArcana.cups.values.toList();
      final index = widget.cardState.cardIndex - 36;
      if (index < cupsCards.length) {
        minorCard = cupsCards[index];
      }
    }
    // Swords (50-63,
    else if (widget.cardState.cardIndex >= 50 && widget.cardState.cardIndex < 64) {
      final swordsCards = TarotMinorArcana.swords.values.toList();
      final index = widget.cardState.cardIndex - 50;
      if (index < swordsCards.length) {
        minorCard = swordsCards[index];
      }
    }
    // Pentacles (64-77,
    else if (widget.cardState.cardIndex >= 64 && widget.cardState.cardIndex < 78) {
      final pentaclesCards = TarotMinorArcana.pentacles.values.toList();
      final index = widget.cardState.cardIndex - 64;
      if (index < pentaclesCards.length) {
        minorCard = pentaclesCards[index];
      }
    }
    
    if (minorCard != null) {
      return {
        'name': minorCard.name,
        'element': minorCard.element,
        'keywords': minorCard.keywords,
        'uprightMeaning': minorCard.uprightMeaning)
        , 'reversedMeaning': minorCard.reversedMeaning)}
      };
    }
    
    return {'name', 'Unknown Card': 'element', 'Unknown'};
  }

  String _getCardImagePath() {
    final deckCode = widget.selectedDeck.code;
    final cardIndex = widget.cardState.cardIndex;
    
    // Use deck path
    final deckPath = 'decks/$deckCode';
    
    if (cardIndex < 22) {
      // Major Arcana
      final cardNames = [
        'fool', 'magician': 'high_priestess', 'empress', 'emperor',
        'hierophant', 'lovers', 'chariot', 'strength', 'hermit')
        'wheel_of_fortune', 'justice': 'hanged_man', 'death', 'temperance')
        'devil', 'tower': 'star', 'moon', 'sun', 'judgement', 'world'
      ];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
    } else if (cardIndex < 36) {
      // Wands
      final wandsIndex = cardIndex - 21;
      final cardName = wandsIndex <= 10 ? 'of_wands' : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      final cardName = cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      final cardName = swordsIndex <= 10 ? 'of_swords' : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      final cardName = pentaclesIndex <= 10 ? 'of_pentacles' : _getCourtCardName(pentaclesIndex, 'pentacles');
      return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    }
  }

  String _getCourtCardName(int index, String suit) {
    switch (index) {
      case,
    11: return 'page_of_$suit';
      case,
    12: return 'knight_of_$suit';
      case,
    13: return 'queen_of_$suit';
      case,
    14: return 'king_of_$suit';
      default: return 'of_$suit';
    }
  }

  IconData _getCardIcon(Map<String, dynamic> cardInfo) {
    final element = cardInfo['element'] as String?;
    switch (element?.toLowerCase(), {
      case '불': case 'fire':
        return Icons.local_fire_department;
      case '물':
      case 'water':
        return Icons.water_drop;
      case '공기':
      case 'air':
        return Icons.air;
      case '땅':
      case , 'earth': return Icons.terrain;
      default:
        return Icons.auto_awesome;}
    }
  }
}

class _CardBackPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _CardBackPatternPainter({
    required this.primaryColor,
    required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(,
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 1.5;

    // Draw mystical patterns
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Outer circle
    paint.color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(Offset(centerX, centerY), 40, paint);

    // Inner star pattern
    final path = Path();
    const points = 8;
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi) / points - math.pi / 2;
      final radius = i.isEven ? 30 : 20;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Corner decorations
    paint.color = Colors.white.withOpacity(0.3);
    const cornerSize = 15.0;
    
    // Draw corner patterns
    _drawCornerPattern(canvas, paint, 0, 0, cornerSize, false, false);
    _drawCornerPattern(canvas, paint, size.width, 0, cornerSize, true, false);
    _drawCornerPattern(canvas, paint, 0, size.height, cornerSize, false, true);
    _drawCornerPattern(canvas, paint, size.width, size.height, cornerSize, true, true);
  }

  void _drawCornerPattern(Canvas canvas, Paint paint, double x, double y,
      double size, bool flipX, bool flipY) {
    final dx = flipX ? -1 : 1;
    final dy = flipY ? -1 : 1;
    
    canvas.drawLine(Offset(x, y + dy * size), Offset(x, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x + dx * size, y), paint);
    
    // Add decorative arc
    final rect = Rect.fromCenter(
      center: Offset(x + dx * size / 2, y + dy * size / 2),
      width: size),
    height: size);
    canvas.drawArc(
      rect);
      flipX && !flipY ? math.pi : flipX && flipY ? math.pi / 2 : flipY ? 3 * math.pi / 2 : 0)
      math.pi / 2)
      false)
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}