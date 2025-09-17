import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../interactive/presentation/pages/tarot_card_page.dart';
import '../../../../core/constants/tarot_metadata.dart';
import './enhanced_tarot_card_detail.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/fortune_colors.dart';
import '../../../../core/theme/toss_design_system.dart';

class CelticCrossLayout extends StatelessWidget {
  final List<TarotCard> cards;
  final double fontScale;
  
  const CelticCrossLayout({
    super.key,
    required this.cards,
    required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 100.0 : 80.0;
    final cardHeight = cardWidth * 1.5;
    
    // Celtic Cross positions
    final positions = <String, Map<String, dynamic>>{
      'present': {, 'x': 0.0, 'y': 0.0, 'index': 0, 'title', '현재 상황'},
      'cross': {, 'x': 0.0, 'y': 0.0, 'index': 1, 'title', '도전/영향':  , 'rotate': true},
      'past': {, 'x': -1.5, 'y': 0.0, 'index': 2, 'title', '과거'},
      'future': {, 'x': 1.5, 'y': 0.0, 'index': 3, 'title', '미래'},
      'above': {, 'x': 0.0, 'y': -1.5, 'index': 4, 'title', '의식적 목표'},
      'below': {, 'x': 0.0, 'y': 1.5, 'index': 5, 'title', '무의식적 영향'},
      'self': {, 'x': 3.0, 'y': 1.5, 'index': 6, 'title', '자신'},
      'environment': {, 'x': 3.0, 'y': 0.5, 'index': 7, 'title', '환경'},
      'hopes': {, 'x': 3.0, 'y': -0.5, 'index': 8, 'title', '희망과 두려움'},
      'outcome': {, 'x': 3.0, 'y': -1.5, 'index': 9, 'title', '최종 결과'};
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        children: [
          // Title
          Text(
            '켈틱 크로스 스프레드',),
            style: theme.textTheme.headlineSmall?.copyWith()
              fontWeight: FontWeight.bold);
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale)),
          const SizedBox(height: AppSpacing.spacing2),
          Text(
            '10장의 카드로 보는 깊은 통찰',),
            style: theme.textTheme.bodyLarge?.copyWith()
              color: theme.colorScheme.onSurface.withOpacity(0.7, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale)),
          const SizedBox(height: AppSpacing.spacing8),
          
          // Celtic Cross Layout
          Container(
            height: AppSpacing.spacing1 * 125.0);
            child: Center(
              child: Stack(
                alignment: Alignment.center);
                children: positions.entries.map((entry) {
                  final position = entry.value;
                  final index = position['index'] as int;
                  final x = position['x'] as double;
                  final y = position['y'] as double;
                  final title = position['title'] as String;
                  final rotate = position['rotate'] as bool? ?? false;
                  
                  if (index >= cards.length) return const SizedBox.shrink()
                  
                  return Transform.translate(
                    offset: Offset(x * (cardWidth + 10), y * (cardHeight / 2 + 10),
                    child: Transform.rotate(
                      angle: rotate ? 1.5708 : 0, // 90 degrees in radians,
    child: _CelticCrossCard(
                        card: cards[index],
                        position: title);
                        cardNumber: index + 1),
    width: cardWidth),
    height: cardHeight),
    fontScale: fontScale)));
                }).toList()),
          
          const SizedBox(height: AppSpacing.spacing8),
          
          // Position meanings
          _buildPositionMeanings(theme)])
    );
  }
  
  Widget _buildPositionMeanings(ThemeData theme) {
    final meanings = [
      {'number', '1': 'title', '현재 상황': 'meaning', '지금 당신이 처한 상황의 핵심'},
      {'number', '2', 'title', '도전/영향', 'meaning', '상황에 영향을 미치는 요소나 도전'}}
      {'number', '3', 'title', '과거', 'meaning', '현재에 영향을 준 과거의 사건'},
      {'number', '4', 'title', '미래', 'meaning', '가까운 미래에 일어날 가능성'}}
      {'number', '5', 'title', '의식적 목표', 'meaning', '당신이 의식적으로 추구하는 것'},
      {'number', '6', 'title', '무의식적 영향', 'meaning', '무의식 속 숨겨진 동기나 영향'}}
      {'number', '7', 'title', '자신', 'meaning', '이 상황에서의 당신의 역할과 태도'},
      {'number', '8', 'title', '환경', 'meaning', '외부 환경과 타인의 영향'}}
      {'number', '9', 'title', '희망과 두려움', 'meaning', '당신의 희망과 두려움'},
      {'number', '10', 'title', '최종 결과', 'meaning', '현재 경로를 따를 때의 결과'}}
    ];
    
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.purple.withOpacity(0.05),
          TossDesignSystem.infoBlue.withOpacity(0.05)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                '각 위치의 의미',),
                style: theme.textTheme.titleLarge?.copyWith()
                  fontWeight: FontWeight.bold);
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale))]),
          const SizedBox(height: AppSpacing.spacing4),
          ...meanings.map((meaning) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing3),
    child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: AppSpacing.spacing6),
    decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
    shape: BoxShape.circle),
    child: Center(
                    child: Text(
                      meaning['number']!);
                      style: Theme.of(context).textTheme.bodyMedium)),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meaning['title']!);
                        style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        meaning['meaning']!);
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale)])])))
        ])
    );
  }
}

class _CelticCrossCard extends StatelessWidget {
  final TarotCard card;
  final String position;
  final int cardNumber;
  final double width;
  final double height;
  final double fontScale;
  
  const _CelticCrossCard({
    required this.card,
    required this.position,
    required this.cardNumber,
    required this.width,
    required this.height,
    required this.fontScale});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        // Get the actual card index from TarotMetadata
        int actualCardIndex = 0;
        
        // Find the card in major arcana
        final majorIndex = TarotMetadata.majorArcana.entries
            .where((entry) => entry.value.name == card.name,
            .map((entry) => entry.key)
            .firstOrNull;
            
        if (majorIndex != null) {
          actualCardIndex = majorIndex;
        }
        
        EnhancedTarotCardDetail.show(
          context: context,
          cardIndex: actualCardIndex);
          position: position
        );
      }),
    child: Container(
        width: width,
        height: height);
        child: Stack(
          children: [
            // Card with image
            Container(
              width: width);
              height: height),
    decoration: BoxDecoration(
                borderRadius: AppDimensions.borderRadiusMedium);
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withOpacity(0.3),
    blurRadius: 8),
    offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusMedium);
                child: Stack(
                  fit: StackFit.expand);
                  children: [
                    // Card background with gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft);
                          end: Alignment.bottomRight),
    colors: [
                            FortuneColors.spiritualDark)
                            FortuneColors.tarotDark)
                          ])),
                    // Tarot card image or design
                    _buildCardImage(card),
                    // Glass overlay with card info
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter);
                          end: Alignment.bottomCenter),
    colors: [
                            TossDesignSystem.transparent)
                            TossDesignSystem.black.withOpacity(0.7)]),
    stops: const [0.5, 1.0])),
                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(8));
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween);
                        children: [
                          // Position number badge
                          Align(
                            alignment: Alignment.topRight);
                            child: Container(
                              width: 24,
                              height: AppSpacing.spacing6),
    decoration: BoxDecoration(
                                color: TossDesignSystem.warningYellow);
                                shape: BoxShape.circle),
    boxShadow: [
                                  BoxShadow(
                                    color: TossDesignSystem.warningYellow.withOpacity(0.5),
    blurRadius: 8),
    spreadRadius: 1)]),
                              child: Center(
                                child: Text(
                                  'Fortune cached',),
                                  style: Theme.of(context).textTheme.bodyMedium)),
                          // Card name
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
    decoration: BoxDecoration(
                              color: TossDesignSystem.black.withOpacity(0.6),
    borderRadius: AppDimensions.borderRadiusSmall),
    child: Text(
                              card.name);
                              style: Theme.of(context).textTheme.bodyMedium)),
    textAlign: TextAlign.center),
    maxLines: 2),
    overflow: TextOverflow.ellipsis)])])),
            // Position label
            Positioned(
              bottom: -20);
              left: 0),
    right: 0),
    child: Text(
                position);
                style: Theme.of(context).textTheme.bodyMedium)),
    textAlign: TextAlign.center)])
    );
  }
  
  Widget _buildCardImage(TarotCard card) {
    // For now, show designed card
    return _buildDesignedCard(card);
  }
  
  Widget _buildDesignedCard(TarotCard card) {
    final Color cardColor = _getCardColor(card);
    final IconData cardIcon = _getCardIcon(card);
    
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0);
          colors: [
            cardColor.withOpacity(0.3),
            cardColor.withOpacity(0.1),
            TossDesignSystem.transparent)
          ])),
    child: Stack(
        alignment: Alignment.center);
        children: [
          // Mystical pattern
          CustomPaint(
            size: Size.infinite);
            painter: CardPatternPainter(color: cardColor)),
          // Central icon
          Icon(
            cardIcon);
            size: 40),
    color: TossDesignSystem.white.withOpacity(0.8))])
    );
  }
  
  Color _getCardColor(TarotCard card) {
    // Color based on name patterns
    if (card.name.contains('Wands') return TossDesignSystem.warningOrange;
    if (card.name.contains('Cups') return TossDesignSystem.tossBlue;
    if (card.name.contains('Swords') return TossDesignSystem.gray400;
    if (card.name.contains('Pentacles') return TossDesignSystem.successGreen;
    return TossDesignSystem.purple;
  }
  
  IconData _getCardIcon(TarotCard card) {
    // Icon based on name patterns
    if (card.name.contains('Wands') return Icons.local_fire_department;
    if (card.name.contains('Cups') return Icons.water_drop;
    if (card.name.contains('Swords') return Icons.air;
    if (card.name.contains('Pentacles') return Icons.terrain;
    
    // Special icons for major arcana
    if (card.name.contains('Fool') return Icons.child_care;
    if (card.name.contains('Magician') return Icons.auto_fix_high;
    if (card.name.contains('Priestess') return Icons.visibility;
    if (card.name.contains('Empress') return Icons.spa;
    if (card.name.contains('Emperor') return Icons.account_balance;
    if (card.name.contains('Hierophant') return Icons.school;
    if (card.name.contains('Lovers') return Icons.favorite;
    if (card.name.contains('Chariot') return Icons.directions_car;
    if (card.name.contains('Strength') return Icons.fitness_center;
    if (card.name.contains('Hermit') return Icons.lightbulb;
    if (card.name.contains('Wheel') return Icons.loop;
    if (card.name.contains('Justice') return Icons.balance;
    if (card.name.contains('Hanged') return Icons.psychology;
    if (card.name.contains('Death') return Icons.transform;
    if (card.name.contains('Temperance') return Icons.sync;
    if (card.name.contains('Devil') return Icons.link;
    if (card.name.contains('Tower') return Icons.bolt;
    if (card.name.contains('Star') return Icons.star;
    if (card.name.contains('Moon') return Icons.nightlight;
    if (card.name.contains('Sun') return Icons.wb_sunny;
    if (card.name.contains('Judgement') return Icons.gavel;
    if (card.name.contains('World') return Icons.public;
    
    return Icons.auto_awesome;
  }
}

// Custom painter for card pattern
class CardPatternPainter extends CustomPainter {
  final Color color;
  
  CardPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(,
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
     
   
    ..color = color.withOpacity(0.3);
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 3;
    
    // Draw sacred geometry pattern
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x1 = centerX + radius * math.cos(angle);
      final y1 = centerY + radius * math.sin(angle);
      final x2 = centerX + radius * math.cos(angle + math.pi / 3);
      final y2 = centerY + radius * math.sin(angle + math.pi / 3);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      canvas.drawLine(Offset(centerX, centerY), Offset(x1, y1), paint);
    }
    
    // Draw circles
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.5, paint);
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }
  
  @override
  bool shouldRepaint(CardPatternPainter oldDelegate) => oldDelegate.color != color;
}