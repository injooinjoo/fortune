import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/tarot_minor_arcana.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class TarotCardDetailModal extends StatefulWidget {
  final int cardIndex;
  final String? position;

  const TarotCardDetailModal({
    Key? key,
    required this.cardIndex,
    this.position,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required int cardIndex,
    String? position,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TarotCardDetailModal(
        cardIndex: cardIndex,
        position: position,
      ),
    );
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
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
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                // Background blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Content
                Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Header
                    _buildHeader(cardInfo),
                    
                    // Main content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          _buildCardImagePage(cardInfo),
                          _buildSymbolismPage(cardInfo),
                          _buildMeaningsPage(cardInfo),
                          _buildAdvicePage(cardInfo),
                        ],
                      ),
                    ),
                    
                    // Page indicator
                    _buildPageIndicator(),
                    
                    // Close button
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '닫기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> cardInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            cardInfo['name'] ?? 'Unknown Card',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (widget.position != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.position!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardImagePage(Map<String, dynamic> cardInfo) {
    final imagePath = _getCardImagePath();
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card image
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/tarot/$imagePath',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Basic info
            GlassContainer(
              padding: const EdgeInsets.all(16),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.indigo.withOpacity(0.1),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    icon: Icons.local_fire_department,
                    label: '원소',
                    value: cardInfo['element'] ?? 'Unknown',
                  ),
                  if (cardInfo['astrology'] != null)
                    _buildInfoItem(
                      icon: Icons.stars,
                      label: '점성술',
                      value: cardInfo['astrology'],
                    ),
                  if (cardInfo['numerology'] != null)
                    _buildInfoItem(
                      icon: Icons.looks_one,
                      label: '수비학',
                      value: cardInfo['numerology'].toString(),
                    ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카드의 상징',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Keywords
          if (cardInfo['keywords'] != null) ...[
            _buildSectionTitle('핵심 키워드'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (cardInfo['keywords'] as List).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Imagery
          if (cardInfo['imagery'] != null) ...[
            _buildSectionTitle('이미지 해석'),
            const SizedBox(height: 8),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Text(
                cardInfo['imagery'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Element meaning
          _buildSectionTitle('원소의 의미'),
          const SizedBox(height: 8),
          _buildElementMeaning(cardInfo['element']),
        ],
      ),
    );
  }

  Widget _buildMeaningsPage(Map<String, dynamic> cardInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카드의 의미',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Upright meaning
          if (cardInfo['uprightMeaning'] != null) ...[
            _buildMeaningCard(
              title: '정방향',
              meaning: cardInfo['uprightMeaning'],
              icon: Icons.arrow_upward,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
          ],
          
          // Reversed meaning
          if (cardInfo['reversedMeaning'] != null) ...[
            _buildMeaningCard(
              title: '역방향',
              meaning: cardInfo['reversedMeaning'],
              icon: Icons.arrow_downward,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
          ],
          
          // Related cards
          if (cardInfo['relatedCards'] != null) ...[
            _buildSectionTitle('관련 카드'),
            const SizedBox(height: 8),
            ...cardInfo['relatedCards'].map<Widget>((card) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      card,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvicePage(Map<String, dynamic> cardInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '실천 조언',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Main advice
          if (cardInfo['advice'] != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.1),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    size: 48,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cardInfo['advice'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Questions for reflection
          if (cardInfo['questions'] != null) ...[
            _buildSectionTitle('성찰을 위한 질문'),
            const SizedBox(height: 16),
            ...(cardInfo['questions'] as List).map((question) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.indigo.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 20,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? Colors.purple
                  : Colors.white.withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  Widget _buildMeaningCard({
    required String title,
    required String meaning,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meaning,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementMeaning(String? element) {
    final elementData = {
      '불': {
        'color': Colors.red,
        'meaning': '열정, 창의성, 행동력, 영감',
        'description': '불의 원소는 적극적이고 역동적인 에너지를 상징합니다.',
      },
      '물': {
        'color': Colors.blue,
        'meaning': '감정, 직관, 치유, 흐름',
        'description': '물의 원소는 감정의 깊이와 직관적 지혜를 나타냅니다.',
      },
      '공기': {
        'color': Colors.yellow,
        'meaning': '지성, 소통, 아이디어, 자유',
        'description': '공기의 원소는 명확한 사고와 의사소통을 상징합니다.',
      },
      '땅': {
        'color': Colors.green,
        'meaning': '안정, 실용성, 물질, 인내',
        'description': '땅의 원소는 현실적이고 안정적인 기반을 나타냅니다.',
      },
    };

    final data = elementData[element] ?? {
      'color': Colors.purple,
      'meaning': '신비, 변화, 가능성',
      'description': '이 카드는 특별한 에너지를 담고 있습니다.',
    };

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [
          (data['color'] as Color).withOpacity(0.1),
          (data['color'] as Color).withOpacity(0.05),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                TarotHelper.getElementIcon(element ?? ''),
                color: data['color'] as Color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                element ?? '특별한 원소',
                style: TextStyle(
                  color: data['color'] as Color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['meaning'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['description'] as String,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCardInfo() {
    // Major Arcana (0-21)
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
          'relatedCards': TarotHelper.getRelatedCards(widget.cardIndex),
        };
      }
    }
    
    // Minor Arcana (22-77)
    TarotCardInfo? minorCard;
    
    // Wands (22-35)
    if (widget.cardIndex >= 22 && widget.cardIndex < 36) {
      final wandsCards = TarotMinorArcana.wands.values.toList();
      final index = widget.cardIndex - 22;
      if (index < wandsCards.length) {
        minorCard = wandsCards[index];
      }
    }
    // Cups (36-49)
    else if (widget.cardIndex >= 36 && widget.cardIndex < 50) {
      final cupsCards = TarotMinorArcana.cups.values.toList();
      final index = widget.cardIndex - 36;
      if (index < cupsCards.length) {
        minorCard = cupsCards[index];
      }
    }
    // Swords (50-63)
    else if (widget.cardIndex >= 50 && widget.cardIndex < 64) {
      final swordsCards = TarotMinorArcana.swords.values.toList();
      final index = widget.cardIndex - 50;
      if (index < swordsCards.length) {
        minorCard = swordsCards[index];
      }
    }
    // Pentacles (64-77)
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
        'relatedCards': TarotHelper.getRelatedCards(widget.cardIndex),
      };
    }
    
    // Fallback
    return {
      'name': 'Unknown Card',
      'element': 'Mystery',
    };
  }

  String _getCardImagePath() {
    if (widget.cardIndex < 22) {
      return 'major_${widget.cardIndex.toString().padLeft(2, '0')}.jpg';
    } else if (widget.cardIndex < 36) {
      return 'wands_${(widget.cardIndex - 21).toString().padLeft(2, '0')}.jpg';
    } else if (widget.cardIndex < 50) {
      return 'cups_${(widget.cardIndex - 35).toString().padLeft(2, '0')}.jpg';
    } else if (widget.cardIndex < 64) {
      return 'swords_${(widget.cardIndex - 49).toString().padLeft(2, '0')}.jpg';
    } else {
      return 'pentacles_${(widget.cardIndex - 63).toString().padLeft(2, '0')}.jpg';
    }
  }
}