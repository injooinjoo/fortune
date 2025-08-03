import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/tarot_deck_fan_widget.dart';
import '../widgets/tarot_card_selection_animation.dart';
import '../widgets/tarot_scroll_indicator.dart';
import '../../../fortune/presentation/widgets/tarot_card_reveal_widget.dart';
import 'dart:math' as math;

class TarotAnimatedFlowPage extends StatefulWidget {
  final String? heroTag;
  
  const TarotAnimatedFlowPage({
    Key? key,
    this.heroTag,
  }) : super(key: key);

  @override
  State<TarotAnimatedFlowPage> createState() => _TarotAnimatedFlowPageState();
}

class _TarotAnimatedFlowPageState extends State<TarotAnimatedFlowPage>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _contentController;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _heroPositionAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _scrollController = ScrollController();
  
  // State
  bool _showDeckFan = false;
  bool _showScrollIndicator = false;
  int? _selectedCardIndex;
  bool _showCardSelection = false;
  bool _showCardReveal = false;
  
  // Tarot data
  final List<Map<String, String>> _majorArcana = [
    {'name': 'The Fool': 'image': 'assets/images/tarot/fool.png': 'planet': 'Uranus'},
    {'name': 'The Magician', 'image': 'assets/images/tarot/magician.png', 'planet': 'Mercury'},
    {'name': 'The High Priestess', 'image': 'assets/images/tarot/priestess.png', 'planet': 'Moon'},
    // Add more cards as needed
  ];

  @override
  void initState() {
    super.initState();
    
    // Hero animation controller
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Content animation controller
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Set up animations
    _heroScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeInOut,
    );
    
    _heroPositionAnimation = Tween<double>(
      begin: 0.0,
      end: -300.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeInOut,
    );
    
    _contentSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 200.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    
    // Add status listener
    _heroController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showDeckFan = true;
          _showScrollIndicator = true;
        });
      }
    });
    
    // Start hero animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHeroAnimation();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startHeroAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _heroController.forward();
    _contentController.forward();
  }

  void _onCardTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCardIndex = index;
      _showCardSelection = true;
      _showScrollIndicator = false;
    });
  }

  void _onSelectionAnimationComplete() {
    setState(() {
      _showCardReveal = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1a1a2e),
                  const Color(0xFF0f0f1e),
                ],
              ),
            ),
          ),
          
          // Main content
          if (!_showCardSelection && !_showCardReveal)
            _buildMainContent(),
          
          // Card selection animation
          if (_showCardSelection && !_showCardReveal)
            TarotCardSelectionAnimation(
              selectedIndex: _selectedCardIndex!,
              totalCards: _majorArcana.length,
              cardImagePath: _majorArcana[_selectedCardIndex!]['image'],
              onAnimationComplete: _onSelectionAnimationComplete,
            ),
          
          // Card reveal
          if (_showCardReveal)
            _buildCardReveal(),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        // Hero card animation
        AnimatedBuilder(
          animation: Listenable.merge([_heroController, _contentController]),
          builder: (context, child) {
            // Check if we should show the hero
            if (widget.heroTag != null && _heroController.value < 0.1) {
              return Center(
                child: Hero(
                  tag: widget.heroTag!,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFA726),
                          Color(0xFFFF7043),
                          Color(0xFFE64A19),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Stack(
              children: [
                // Daily fortune card (hero);
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.15 + _heroPositionAnimation.value,
                  left: 0,
                  right: 0,
                  child: Transform.scale(
                    scale: _heroScaleAnimation.value,
                    child: Opacity(
                      opacity: 1 - _heroController.value,
                      child: _buildDailyFortuneCard(),
                    ),
                  ),
                ),
                
                // Bottom content sliding down
                Positioned(
                  bottom: -_contentSlideAnimation.value,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildBottomContent(),
                  ),
                ),
              ],
            );
          },
        ),
        
        // Deck fan (appears after hero animation)
        if (_showDeckFan)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            child: TarotDeckFanWidget(
              cardCount: _majorArcana.length,
              onCardTap: _onCardTap,
              scrollController: _scrollController,
              selectedIndex: _selectedCardIndex,
            ),
          ),
        
        // Scroll indicator
        TarotScrollIndicator(
          isVisible: _showScrollIndicator,
          text: 'Scroll to explore • Tap to select',
        ),
      ],
    );
  }

  Widget _buildDailyFortuneCard() {
    return Center(
      child: Hero(
        tag: widget.heroTag ?? 'daily-fortune',
        child: Container(
          width: 180,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade400,
                Colors.orange.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Card illustration
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/fortune_cards/daily_fortune.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              
              // Text
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Daily fortune',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'DRAW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Tarot Reading',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReadingOption('Love': null,
              _buildReadingOption('Career': null,
              _buildReadingOption('Choice'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingOption(String title, Color color, IconData icon) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardReveal() {
    final cardData = _majorArcana[_selectedCardIndex!];
    
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card display
            Container(
              width: 250,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  cardData['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).primaryColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              cardData['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Card info
            Text(
              cardData['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '"Go forward and do whatever\nyour heart tells you"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetadata(Icons.stars, 'Major Arcana'),
                const SizedBox(width: 40),
                _buildMetadata(Icons.public, cardData['planet'],
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Continue button
            ElevatedButton(
              onPressed: () {
                // Navigate to detailed reading
                context.push('/interactive/tarot/reading': extra: cardData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'View Full Reading',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}