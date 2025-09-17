import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/tarot_minor_arcana.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/toss_design_system.dart';

class TarotCardDetailModal extends StatefulWidget {
  final int cardIndex;
  final String? position;

  const TarotCardDetailModal({
    Key? key,
    required this.cardIndex,
    this.position}) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required int cardIndex,
    String? position}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => TarotCardDetailModal(
        cardIndex: cardIndex,
        position: position));
  }

  @override
  State<TarotCardDetailModal> createState() => _TarotCardDetailModalState();
}

class _TarotCardDetailModalState extends State<TarotCardDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: TossDesignSystem.durationMedium,
      vsync: this
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardInfo = _getCardInfo();
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: screenHeight * 0.9,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray900.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                // Background blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: TossDesignSystem.transparent),
                  ),
                ),
                
                // Content
                Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: TossDesignSystem.spacingS),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4 * 0.5),
                      ),
                    ),
                    
                    // Header
                    _buildHeader(cardInfo),
                    
                    // Main content with navigation arrows
                    Expanded(
                      child: Stack(
                        children: [
                          PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: [
                              _buildCardImagePage(cardInfo),
                              _buildStoryPage(cardInfo),
                              _buildSymbolismPage(cardInfo),
                              _buildMeaningsPage(cardInfo),
                              _buildDeepInterpretationPage(cardInfo),
                              _buildPracticalGuidePage(cardInfo),
                              _buildRelationshipsPage(cardInfo),
                              _buildAdvicePage(cardInfo)]),
                          
                          // Left arrow
                          if (_currentPage > 0) Positioned(
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: TossDesignSystem.gray900.withValues(alpha: 0.5),
                                      shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.arrow_back_ios,
                                      color: TossDesignSystem.white,
                                      size: 20)),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: TossDesignSystem.durationMedium,
                                      curve: Curves.easeInOut);
                                  },
                                ),
                              ),
                            ),
                          
                          // Right arrow
                          if (_currentPage < 7) Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: TossDesignSystem.gray900.withValues(alpha: 0.5),
                                      shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: TossDesignSystem.white,
                                      size: 20)),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: TossDesignSystem.durationMedium,
                                      curve: Curves.easeInOut);
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Page indicator
                    _buildPageIndicator(),
                    
                    // Close button
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                        child: SizedBox(
                          width: double.infinity,
                          child: TossButton(
                            text: '닫기',
                            onPressed: () => Navigator.of(context).pop(),
                            style: TossButtonStyle.primary,
                            size: TossButtonSize.large,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
  }

  Widget _buildHeader(Map<String, dynamic> cardInfo) {
    final pageNames = [
      '카드 이미지',
      '스토리',
      '상징',
      '의미',
      '심화 해석',
      '실천 가이드',
      '관계성',
      '조언'];
    
    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      child: Column(
        children: [
          Text(
            cardInfo['name'] ?? 'Unknown Card',
            style: Theme.of(context).textTheme.bodyLarge),
          if (widget.position != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM, vertical: TossDesignSystem.spacingXXS * 1.5),
              decoration: BoxDecoration(
                color: TossDesignSystem.purple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20)),
              child: Text(
                widget.position!,
                style: Theme.of(context).textTheme.bodyLarge))],
          const SizedBox(height: TossDesignSystem.spacingXS),
          Text(
            pageNames[_currentPage],
            style: Theme.of(context).textTheme.titleMedium)]));
  }

  Widget _buildCardImagePage(Map<String, dynamic> cardInfo) {
    final imagePath = _getCardImagePath();
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.all(TossDesignSystem.spacingL),
        child: Column(
          children: [
            // Card image
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: TossDesignSystem.purple.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5)]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
                    child: Image.asset(
                      'assets/images/tarot/$imagePath',
                      fit: BoxFit.contain)),
                ),
              ),
            ),
            
            const SizedBox(height: TossDesignSystem.spacingL),
            
            // Basic info
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingS),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withValues(alpha: 0.1),
                  TossDesignSystem.primaryBlue.withValues(alpha: 0.1)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    icon: Icons.local_fire_department,
                    label: '원소',
                    value: cardInfo['element'] ?? 'Unknown'),
                  if (cardInfo['astrology'] != null) _buildInfoItem(
                      icon: Icons.stars,
                      label: '점성술',
                      value: cardInfo['astrology']),
                  if (cardInfo['numerology'] != null) _buildInfoItem(
                      icon: Icons.looks_one,
                      label: '수비학',
                      value: cardInfo['numerology'].toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolismPage(Map<String, dynamic> cardInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드의 상징',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TossDesignSystem.spacingM),
          
          // Keywords
          if (cardInfo['keywords'] != null) ...[
            _buildSectionTitle('핵심 키워드'),
            const SizedBox(height: TossDesignSystem.spacingXS),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (cardInfo['keywords'] as List).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM, vertical: TossDesignSystem.spacingXS),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TossDesignSystem.purple.withValues(alpha: 0.3),
                      width: 1)),
                  child: Text(
                    keyword,
                    style: Theme.of(context).textTheme.bodyLarge));
              }).toList()),
            const SizedBox(height: TossDesignSystem.spacingXL)],
          
          // Imagery
          if (cardInfo['imagery'] != null) ...[
            _buildSectionTitle('이미지 해석'),
            const SizedBox(height: TossDesignSystem.spacingXS),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingS),
              child: Text(
                cardInfo['imagery'],
                style: Theme.of(context).textTheme.bodyLarge)),
            const SizedBox(height: TossDesignSystem.spacingXL)],
          
          // Element meaning
          _buildSectionTitle('원소의 의미'),
          const SizedBox(height: TossDesignSystem.spacingXS),
          _buildElementMeaning(cardInfo['element'])]));
  }

  Widget _buildMeaningsPage(Map<String, dynamic> cardInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드의 의미',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TossDesignSystem.spacingM),
          
          // Upright meaning
          if (cardInfo['uprightMeaning'] != null) ...[
            _buildMeaningCard(
              title: '정방향',
              meaning: cardInfo['uprightMeaning'],
              icon: Icons.arrow_upward,
              color: TossDesignSystem.successGreen),
            const SizedBox(height: TossDesignSystem.spacingM)],
          
          // Reversed meaning
          if (cardInfo['reversedMeaning'] != null) ...[
            _buildMeaningCard(
              title: '역방향',
              meaning: cardInfo['reversedMeaning'],
              icon: Icons.arrow_downward,
              color: TossDesignSystem.warningOrange),
            const SizedBox(height: TossDesignSystem.spacingM)],
          
          // Related cards
          if (cardInfo['relatedCards'] != null) ...[
            _buildSectionTitle('관련 카드'),
            const SizedBox(height: TossDesignSystem.spacingXS),
            ...cardInfo['relatedCards'].map<Widget>((card) => 
              Padding(
                padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: TossDesignSystem.purple),
                    const SizedBox(width: TossDesignSystem.spacingXS),
                    Text(
                      card,
                      style: TextStyle(color: TossDesignSystem.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              )
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvicePage(Map<String, dynamic> cardInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '실천 조언',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TossDesignSystem.spacingM),
          
          // Main advice
          if (cardInfo['advice'] != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.warningOrange.withValues(alpha:0.1),
                  TossDesignSystem.warningOrange.withValues(alpha:0.1)]),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    size: 48,
                    color: TossDesignSystem.warningOrange),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    cardInfo['advice'],
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center)])),
            const SizedBox(height: TossDesignSystem.spacingXL)],
          
          // Questions for reflection
          if (cardInfo['questions'] != null) ...[
            _buildSectionTitle('성찰을 위한 질문'),
            const SizedBox(height: TossDesignSystem.spacingM),
            ...(cardInfo['questions'] as List).map((question) {
              return Container(
                margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                padding: const EdgeInsets.all(TossDesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: TossDesignSystem.primaryBlue.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                  border: Border.all(
                    color: TossDesignSystem.primaryBlue.withValues(alpha:0.3),
                    width: 1)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 20,
                      color: TossDesignSystem.primaryBlue),
                    const SizedBox(width: TossDesignSystem.spacingS),
                    Expanded(
                      child: Text(
                        question,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final pageNames = [
      '이미지',
      '스토리',
      '상징',
      '의미',
      '심화해석',
      '실천',
      '관계',
      '조언'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TossDesignSystem.transparent,
            TossDesignSystem.gray900.withValues(alpha:0.3)])),
      child: Column(
        children: [
          // Page dots with labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                final isActive = _currentPage == index;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: TossDesignSystem.durationMedium,
                      curve: Curves.easeInOut);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingXXS * 1.5),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: TossDesignSystem.durationShort,
                          width: isActive ? 40 : 32,
                          height: isActive ? 40 : 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? TossDesignSystem.purple
                                : TossDesignSystem.white.withValues(alpha:0.2),
                            border: Border.all(
                              color: isActive
                                  ? TossDesignSystem.purple.withValues(alpha:0.5)
                                  : TossDesignSystem.white.withValues(alpha:0.3),
                              width: 2),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: TossDesignSystem.purple.withValues(alpha:0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2)]
                                : null),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha:0.7),
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: isActive ? 14 : 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: TossDesignSystem.spacingXXS),
                        Text(
                          pageNames[index],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Swipe hint with animation
          if (_currentPage == 0) ...[
            const SizedBox(height: TossDesignSystem.spacingS),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(sin(value * pi * 2) * 10, 0),
                      child: Icon(
                        Icons.swipe,
                        size: 20,
                        color: TossDesignSystem.white.withValues(alpha:0.7)),
                    ),
                    const SizedBox(width: TossDesignSystem.spacingXS),
                    Text(
                      '좌우로 스와이프하거나 숫자를 탭하세요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value}) {
    return Column(
      children: [
        Icon(icon, color: TossDesignSystem.purple, size: 24),
        const SizedBox(height: TossDesignSystem.spacingXXS),
        Text(
          label,
          style: TextStyle(
            color: TossDesignSystem.white.withValues(alpha:0.7),
            fontSize: Theme.of(context).textTheme.bodySmall!.fontSize),
        ),
        const SizedBox(height: 4 * 0.5),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildMeaningCard({
    required String title,
    required String meaning,
    required IconData icon,
    required Color color}) {
    return GlassContainer(
      padding: const EdgeInsets.all(TossDesignSystem.spacingXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: TossDesignSystem.spacingXS),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacingS),
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );  
  }

  Widget _buildElementMeaning(String? element) {
    final elementData = {
      '불': {
        'color': TossDesignSystem.errorRed,
        'meaning': '열정, 창의성, 행동력, 영감',
        'description': '불의 원소는 적극적이고 역동적인 에너지를 상징합니다.'},
      '물': {
        'color': TossDesignSystem.primaryBlue,
        'meaning': '감정, 직관, 치유, 흐름',
        'description': '물의 원소는 감정의 깊이와 직관적 지혜를 나타냅니다.'},
      '공기': {
        'color': TossDesignSystem.warningOrange,
        'meaning': '지성, 소통, 아이디어, 자유',
        'description': '공기의 원소는 명확한 사고와 의사소통을 상징합니다.'},
      '땅': {
        'color': TossDesignSystem.successGreen,
        'meaning': '안정, 실용성, 물질, 인내',
        'description': '땅의 원소는 현실적이고 안정적인 기반을 나타냅니다.'}};

    final data = elementData[element] ?? {
      'color': TossDesignSystem.purple,
      'meaning': '신비, 변화, 가능성',
      'description': '이 카드는 특별한 에너지를 담고 있습니다.'};

    return GlassContainer(
      padding: const EdgeInsets.all(TossDesignSystem.spacingXS),
      gradient: LinearGradient(
        colors: [
          (data['color'] as Color).withValues(alpha:0.1),
          (data['color'] as Color).withValues(alpha:0.1)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                TarotHelper.getElementIcon(element ?? ''),
                color: data['color'] as Color,
                size: 24),
              const SizedBox(width: TossDesignSystem.spacingXS),
              Text(
                element ?? '특별한 원소',
                style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacingXS),
          Text(
            data['meaning'] as String,
            style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: TossDesignSystem.spacingXXS),
          Text(
            data['description'] as String,
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha:0.7),
              fontSize: Theme.of(context).textTheme.bodySmall!.fontSize),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCardInfo() {
    // Major Arcana (0-21,
    if (widget.cardIndex < 22) {
      final majorCard = TarotMetadata.majorArcana[widget.cardIndex];
      if (majorCard != null) {
        return {
          'name': majorCard.name,
          'keywords': majorCard.keywords,
          'element': majorCard.element,
          'astrology': majorCard.astrology,
          'numerology': majorCard.numerology,
          'imagery': majorCard.imagery,
          'uprightMeaning': majorCard.uprightMeaning,
          'reversedMeaning': majorCard.reversedMeaning,
          'advice': majorCard.advice,
          'questions': majorCard.questions,
          'relatedCards': null};
      }
    }
    
    // Minor Arcana (22-77,
    TarotCardInfo? minorCard;
    
    // Wands (22-35,
    if (widget.cardIndex >= 22 && widget.cardIndex < 36) {
      final wandsCards = TarotMinorArcana.wands.values.toList();
      final index = widget.cardIndex - 22;
      if (index < wandsCards.length) {
        minorCard = wandsCards[index];
      }
    }
    // Cups (36-49,
    else if (widget.cardIndex >= 36 && widget.cardIndex < 50) {
      final cupsCards = TarotMinorArcana.cups.values.toList();
      final index = widget.cardIndex - 36;
      if (index < cupsCards.length) {
        minorCard = cupsCards[index];
      }
    }
    // Swords (50-63,
    else if (widget.cardIndex >= 50 && widget.cardIndex < 64) {
      final swordsCards = TarotMinorArcana.swords.values.toList();
      final index = widget.cardIndex - 50;
      if (index < swordsCards.length) {
        minorCard = swordsCards[index];
      }
    }
    // Pentacles (64-77,
    else if (widget.cardIndex >= 64 && widget.cardIndex < 78) {
      final pentaclesCards = TarotMinorArcana.pentacles.values.toList();
      final index = widget.cardIndex - 64;
      if (index < pentaclesCards.length) {
        minorCard = pentaclesCards[index];
      }
    }
    
    if (minorCard != null) {
      return {
        'name': minorCard.name,
        'keywords': minorCard.keywords,
        'element': minorCard.element,
        'astrology': minorCard.astrology,
        'numerology': minorCard.numerology,
        'imagery': minorCard.imagery,
        'uprightMeaning': minorCard.uprightMeaning,
        'reversedMeaning': minorCard.reversedMeaning,
        'advice': minorCard.advice,
        'questions': minorCard.questions,
        'relatedCards': null};
    }
    
    // Fallback
    return {
      'name': 'Unknown Card',
      'element': 'Mystery'};
  }

  String _getCardImagePath() {
    // Default to rider_waite deck
    const deckPath = 'decks/rider_waite';
    
    if (widget.cardIndex < 22) {
      // Major Arcana
      final cardNames = [
        'fool', 'magician', 'high_priestess', 'empress', 'emperor',
        'hierophant', 'lovers', 'chariot', 'strength', 'hermit',
        'wheel_of_fortune', 'justice', 'hanged_man', 'death', 'temperance',
        'devil', 'tower', 'star', 'moon', 'sun', 'judgement', 'world'];
      return '$deckPath/major/${widget.cardIndex.toString().padLeft(2, '0')}_${cardNames[widget.cardIndex]}.jpg';
    } else if (widget.cardIndex < 36) {
      // Wands
      final wandsIndex = widget.cardIndex - 21;
      final cardName = wandsIndex <= 10 ? 'of_wands' : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (widget.cardIndex < 50) {
      // Cups
      final cupsIndex = widget.cardIndex - 35;
      final cardName = cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (widget.cardIndex < 64) {
      // Swords
      final swordsIndex = widget.cardIndex - 49;
      final cardName = swordsIndex <= 10 ? 'of_swords' : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = widget.cardIndex - 63;
      final cardName = pentaclesIndex <= 10 ? 'of_pentacles' : _getCourtCardName(pentaclesIndex, 'pentacles');
      return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    }
  }

  String _getCourtCardName(int index, String suit) {
    switch (index) {
      case 11: 
        return 'page_of_$suit';
      case 12: 
        return 'knight_of_$suit';
      case 13: 
        return 'queen_of_$suit';
      case 14: 
        return 'king_of_$suit';
      default: 
        return 'of_$suit';
    }
  }

  // New page builders for extended content
  Widget _buildStoryPage(Map<String, dynamic> cardInfo) {
    final tarotCardInfo = widget.cardIndex < 22 
        ? TarotMetadata.majorArcana[widget.cardIndex]
        : null;
    
    if (tarotCardInfo?.story == null) {
      return _buildComingSoonPage('스토리', '곧 업데이트됩니다');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드의 이야기',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TossDesignSystem.spacingL),
          
          GlassContainer(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            gradient: LinearGradient(
              colors: [
                TossDesignSystem.purple.withValues(alpha:0.1),
                TossDesignSystem.primaryBlue.withValues(alpha:0.1)]),
            child: Text(
              tarotCardInfo!.story!,
              style: Theme.of(context).textTheme.bodyLarge)),
          
          if (tarotCardInfo.mythology != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '신화적 연결',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.warningOrange.withValues(alpha:0.1),
                  TossDesignSystem.warningOrange.withValues(alpha:0.1)]),
              child: Text(
                tarotCardInfo.mythology!,
                style: Theme.of(context).textTheme.bodyLarge))],
          
          if (tarotCardInfo.historicalContext != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '역사적 배경',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.successGreen.withValues(alpha:0.1),
                  TossDesignSystem.primaryBlue.withValues(alpha:0.1)]),
              child: Text(
                tarotCardInfo.historicalContext!,
                style: Theme.of(context).textTheme.bodyLarge))]]));  
  }

  Widget _buildDeepInterpretationPage(Map<String, dynamic> cardInfo) {
    final tarotCardInfo = widget.cardIndex < 22 
        ? TarotMetadata.majorArcana[widget.cardIndex]
        : null;
    
    if (tarotCardInfo?.psychologicalMeaning == null && 
        tarotCardInfo?.spiritualMeaning == null) {
      return _buildComingSoonPage('심화 해석', '곧 업데이트됩니다');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tarotCardInfo?.psychologicalMeaning != null) ...[
            Text(
              '심리학적 해석',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withValues(alpha:0.1),
                  TossDesignSystem.purple.withValues(alpha:0.1)]),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 48,
                    color: TossDesignSystem.purple),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    tarotCardInfo!.psychologicalMeaning!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
          
          if (tarotCardInfo?.spiritualMeaning != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '영적 의미',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.primaryBlue.withValues(alpha:0.1),
                  TossDesignSystem.purple.withValues(alpha:0.1)]),
              child: Column(
                children: [
                  const Icon(
                    Icons.self_improvement,
                    size: 48,
                    color: TossDesignSystem.primaryBlue),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    tarotCardInfo!.spiritualMeaning!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPracticalGuidePage(Map<String, dynamic> cardInfo) {
    final tarotCardInfo = widget.cardIndex < 22 
        ? TarotMetadata.majorArcana[widget.cardIndex]
        : null;
    
    if (tarotCardInfo?.dailyApplications == null && 
        tarotCardInfo?.meditation == null &&
        tarotCardInfo?.affirmations == null) {
      return _buildComingSoonPage('실천 가이드', '곧 업데이트됩니다');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tarotCardInfo?.dailyApplications != null) ...[
            Text(
              '일상 적용법',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            ...tarotCardInfo!.dailyApplications!.map((application) => 
              Container(
                margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                child: GlassContainer(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingS),
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.successGreen.withValues(alpha:0.1),
                      TossDesignSystem.successGreen.withValues(alpha:0.1)]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: TossDesignSystem.successGreen,
                        size: 20),
                      const SizedBox(width: TossDesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          application,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ).toList(),
          ],
          
          if (tarotCardInfo?.meditation != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '명상 가이드',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.primaryBlue.withValues(alpha:0.1),
                  TossDesignSystem.primaryBlue.withValues(alpha:0.1)]),
              child: Column(
                children: [
                  const Icon(
                    Icons.spa,
                    size: 48,
                    color: TossDesignSystem.primaryBlue),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    tarotCardInfo!.meditation!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
          
          if (tarotCardInfo?.affirmations != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '확언문',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            ...tarotCardInfo!.affirmations!.map((affirmation) => 
              Container(
                margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                child: GlassContainer(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingS),
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.purple.withValues(alpha:0.1),
                      TossDesignSystem.purple.withValues(alpha:0.1)]),
                  child: Center(
                    child: Text(
                      '"$affirmation"',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRelationshipsPage(Map<String, dynamic> cardInfo) {
    final tarotCardInfo = widget.cardIndex < 22 
        ? TarotMetadata.majorArcana[widget.cardIndex]
        : null;
    
    if (tarotCardInfo?.cardCombinations == null) {
      return _buildComingSoonPage('카드 조합', '곧 업데이트됩니다');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다른 카드와의 조합',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TossDesignSystem.spacingL),
          
          ...tarotCardInfo!.cardCombinations!.entries.map((entry) => 
            Container(
              margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingM),
              child: GlassContainer(
                padding: const EdgeInsets.all(TossDesignSystem.spacingL),
                gradient: LinearGradient(
                  colors: [
                    TossDesignSystem.purple.withValues(alpha:0.1),
                    TossDesignSystem.purple.withValues(alpha:0.1)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: TossDesignSystem.purple,
                          size: 24),
                        const SizedBox(width: TossDesignSystem.spacingS),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TossDesignSystem.spacingS),
                    Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ).toList(),
          
          if (tarotCardInfo.colorSymbolism != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '색채 상징',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.warningOrange.withValues(alpha:0.1),
                  TossDesignSystem.warningOrange.withValues(alpha:0.1)]),
              child: Text(
                tarotCardInfo.colorSymbolism!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
          
          if (tarotCardInfo.crystals != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '연관 크리스탈',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TossDesignSystem.spacingM),
            ...tarotCardInfo.crystals!.map((crystal) => 
              Container(
                margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                child: GlassContainer(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingS),
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.primaryBlue.withValues(alpha:0.1),
                      TossDesignSystem.primaryBlue.withValues(alpha:0.1)]),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.diamond,
                        color: TossDesignSystem.primaryBlue,
                        size: 20),
                      const SizedBox(width: TossDesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          crystal,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).toList(),
          ],
        ],
      ),
    );
}

  Widget _buildComingSoonPage(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hourglass_empty,
            size: 64,
            color: TossDesignSystem.purple),
          const SizedBox(height: TossDesignSystem.spacingXL),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: TossDesignSystem.spacingM),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}