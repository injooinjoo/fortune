import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../routes/app_router.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/widgets/animated_tarot_card_widget.dart';
import '../../../interactive/presentation/widgets/bottom_tarot_deck_widget.dart';

enum TarotPageState {
  initial,
  transitioning,
  cardExpanded,
}

class TarotMainPage extends ConsumerStatefulWidget {
  const TarotMainPage({super.key});

  @override
  ConsumerState<TarotMainPage> createState() => _TarotMainPageState();
}

class _TarotMainPageState extends ConsumerState<TarotMainPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  
  // New animation controllers for page transition
  late AnimationController _transitionController;
  late AnimationController _bottomCardsController;
  late List<Animation<double>> _bottomCardAnimations;
  
  // Card expansion animations
  late AnimationController _cardExpansionController;
  late Animation<double> _cardPositionAnimation;
  late Animation<double> _cardSizeAnimation;
  late Animation<double> _cardRadiusAnimation;
  
  // Card swap animations
  late AnimationController _swapAnimationController;
  late Animation<double> _swapProgressAnimation;
  late Animation<double> _swapScaleAnimation;
  
  
  // State management
  TarotPageState _currentState = TarotPageState.initial;
  
  // Card swap state
  String _selectedCardType = 'daily'; // 'daily', 'love', 'career', 'choice', 'health'
  String? _swappingToCardType; // The card type we're swapping TO
  String? _swappingFromCardType; // The card type we're swapping FROM
  bool _isSwapping = false;
  Map<String, dynamic>? _selectedCardData;
  Map<String, dynamic>? _previousCardData; // Data of the card moving down
  GlobalKey _mainCardKey = GlobalKey();
  Map<String, GlobalKey> _bottomCardKeys = {
    'love': GlobalKey(),
    'career': GlobalKey(),
    'choice': GlobalKey(),
    'health': GlobalKey(),
  };
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('[TarotMainPage] === initState START ===');
    
    // Background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Card animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _cardRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _cardAnimationController.forward();
    print('[TarotMainPage] Animation controllers initialized');
    
    // Initialize transition animations
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _bottomCardsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    print('[TarotMainPage] _bottomCardsController created with 600ms duration');
    
    // Create staggered animations for bottom cards
    _bottomCardAnimations = List.generate(4, (index) {
      print('[TarotMainPage] Creating bottom card animation $index');
      return Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _bottomCardsController,
        curve: Interval(
          index * 0.15,
          0.4 + index * 0.15,
          curve: Curves.easeOutCubic,
        ),
      ));
    });
    print('[TarotMainPage] Bottom card animations created: ${_bottomCardAnimations.length} animations');
    
    // Initialize card expansion animations
    _cardExpansionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardPositionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardExpansionController,
      curve: Curves.easeInOutCubic,
    ));
    
    _cardSizeAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardExpansionController,
      curve: Curves.easeInOutCubic,
    ));
    
    _cardRadiusAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardExpansionController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Initialize swap animation controller
    _swapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _swapProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swapAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _swapScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        weight: 0.5,
      ),
    ]).animate(CurvedAnimation(
      parent: _swapAnimationController,
      curve: Curves.easeInOut,
    ));
    
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _cardAnimationController.dispose();
    _transitionController.dispose();
    _bottomCardsController.dispose();
    _cardExpansionController.dispose();
    _swapAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _startTransition() async {
    print('[TarotMainPage] === _startTransition START ===');
    print('[TarotMainPage] Current state: $_currentState');
    setState(() {
      _currentState = TarotPageState.transitioning;
    });
    
    // Start bottom cards fade out animation
    print('[TarotMainPage] Starting bottom cards fade out animation');
    _bottomCardsController.forward();
    
    // Wait a bit before expanding the card
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Start card expansion animation
    await _cardExpansionController.forward();
    
    // Update state to expanded
    if (mounted) {
      setState(() {
        _currentState = TarotPageState.cardExpanded;
      });
    }
  }
  
  void _onCardSwap(String cardType, Map<String, dynamic> cardData) async {
    print('[TarotMainPage] === _onCardSwap START ===');
    print('[TarotMainPage] cardType: $cardType, currentType: $_selectedCardType');
    if (_isSwapping || cardType == _selectedCardType) {
      print('[TarotMainPage] Already swapping or same type, returning');
      return;
    }
    
    // Store previous card data for the card moving down
    Map<String, dynamic>? prevData;
    if (_selectedCardType == 'daily') {
      prevData = {
        'title': 'Daily fortune',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFFFA726),
      };
    } else {
      prevData = _selectedCardData;
    }
    
    setState(() {
      _isSwapping = true;
      _swappingToCardType = cardType; // Card moving up
      _swappingFromCardType = _selectedCardType; // Card moving down
      _previousCardData = prevData;
    });
    
    // Small delay to ensure proper layout calculation
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Start swap animation
    await _swapAnimationController.forward();
    
    // Update selected card after animation
    setState(() {
      _selectedCardType = cardType;
      _selectedCardData = cardData;
      _isSwapping = false;
      _swappingToCardType = null;
      _swappingFromCardType = null;
      // Keep initial state - don't show tarot deck yet
      _currentState = TarotPageState.initial;
    });
    
    // Reset animation
    _swapAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    print('[TarotMainPage] === build ===');
    print('[TarotMainPage] Current state: $_currentState');
    print('[TarotMainPage] Is swapping: $_isSwapping');
    final currentDate = DateTime.now();
    final dateString = '${_getWeekday(currentDate.weekday)}, ${_getMonth(currentDate.month)} ${currentDate.day}';
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // Animated mystical background
          AnimatedBuilder(
            animation: _bottomCardsController,
            builder: (context, child) {
              final rawOpacity = 1.0 - (_bottomCardsController.value * 0.5);
              final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
              print('[TarotMainPage] Background opacity: controller=${_bottomCardsController.value}, raw=$rawOpacity, clamped=$clampedOpacity');
              return Opacity(
                opacity: clampedOpacity,
                child: _buildAnimatedBackground(),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Stack(
              children: [
                // Initial layout (header, subtitle, bottom cards)
                Column(
                  children: [
                // Header
                AnimatedBuilder(
                  animation: _bottomCardsController,
                  builder: (context, child) {
                    final rawOpacity = 1.0 - _bottomCardsController.value;
                    final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
                    print('[TarotMainPage] Header opacity: controller=${_bottomCardsController.value}, raw=$rawOpacity, clamped=$clampedOpacity');
                    return Opacity(
                      opacity: clampedOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My tarot',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white70),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Subtitle
                AnimatedBuilder(
                  animation: _bottomCardsController,
                  builder: (context, child) {
                    final rawOpacity = 1.0 - _bottomCardsController.value;
                    final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
                    print('[TarotMainPage] Subtitle opacity: controller=${_bottomCardsController.value}, raw=$rawOpacity, clamped=$clampedOpacity');
                    return Opacity(
                      opacity: clampedOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Everything has its unseen roots',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Large space for card placement and to push Tarot Reading section down
                const SizedBox(height: 350), // Space for card + margin
                
                // Tarot Reading section
                AnimatedBuilder(
                  animation: _bottomCardsController,
                  builder: (context, child) {
                    final rawOpacity = 1.0 - _bottomCardsController.value;
                    final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
                    print('[TarotMainPage] Tarot Reading section opacity: controller=${_bottomCardsController.value}, raw=$rawOpacity, clamped=$clampedOpacity');
                    return Opacity(
                      opacity: clampedOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tarot Reading',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Horizontal scroll of tarot types
                SizedBox(
                  height: 180,
                  child: ListView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildAnimatedBottomCard(
                        index: 0,
                        title: 'Love',
                        icon: Icons.favorite,
                        color: const Color(0xFFE91E63),
                        cardType: 'love',
                      ),
                      const SizedBox(width: 16),
                      _buildAnimatedBottomCard(
                        index: 1,
                        title: 'Career',
                        icon: Icons.work,
                        color: const Color(0xFF4CAF50),
                        cardType: 'career',
                      ),
                      const SizedBox(width: 16),
                      _buildAnimatedBottomCard(
                        index: 2,
                        title: 'Choice',
                        icon: Icons.alt_route,
                        color: const Color(0xFFFF9800),
                        cardType: 'choice',
                      ),
                      const SizedBox(width: 16),
                      _buildAnimatedBottomCard(
                        index: 3,
                        title: 'Health',
                        icon: Icons.favorite_border,
                        color: const Color(0xFF2196F3),
                        cardType: 'health',
                      ),
                    ],
                  ),
                ),
                  ],
                ),
                
                // Show the card moving down during swap (with higher z-index)
                if (_isSwapping && _swappingFromCardType != null && _previousCardData != null)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _swapAnimationController,
                      builder: (context, child) {
                        final swapProgress = _swapProgressAnimation.value;
                        
                        // Find target position (where the clicked card was)
                        final targetKey = _bottomCardKeys[_swappingToCardType];
                        if (targetKey?.currentContext == null) return const SizedBox();
                        
                        final RenderBox targetBox = targetKey!.currentContext!.findRenderObject() as RenderBox;
                        final targetPosition = targetBox.localToGlobal(Offset.zero);
                        
                        // Calculate animated position
                        final startTop = 160.0;
                        final startLeft = screenSize.width * 0.075;
                        
                        // Add SafeArea offset for accurate positioning
                        final safeAreaTop = MediaQuery.of(context).padding.top;
                        final adjustedTargetY = targetPosition.dy - safeAreaTop;
                        
                        // Ensure target position is never negative
                        final clampedTargetY = adjustedTargetY.clamp(0.0, double.infinity);
                        
                        final animatedTop = startTop + (clampedTargetY - startTop) * swapProgress;
                        final animatedLeft = startLeft + (targetPosition.dx - startLeft) * swapProgress;
                        final animatedWidth = screenSize.width * 0.85 - ((screenSize.width * 0.85 - 120) * swapProgress);
                        final animatedHeight = 280 - (280 - 140) * swapProgress;
                        
                        return Positioned(
                          top: animatedTop,
                          left: animatedLeft,
                          child: Transform.scale(
                            scale: _swapScaleAnimation.value,
                            child: Container(
                                  width: animatedWidth,
                                  height: animatedHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        (() {
                                          final alpha = 0.8;
                                          print('[TarotMainPage] Gradient color 1 alpha: $alpha');
                                          return (_previousCardData!['color'] as Color).withValues(alpha: alpha);
                                        })(),
                                        _previousCardData!['color'] as Color,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (() {
                                          final alpha = 0.4;
                                          print('[TarotMainPage] BoxShadow color alpha: $alpha');
                                          return (_previousCardData!['color'] as Color).withValues(alpha: alpha);
                                        })(),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Background icon
                                      if (_previousCardData!['icon'] != null)
                                        Positioned(
                                          top: 30,
                                          left: 0,
                                          right: 0,
                                          child: Icon(
                                            _previousCardData!['icon'] as IconData,
                                            color: (() {
                                              final alpha = 0.3;
                                              print('[TarotMainPage] Icon alpha: $alpha');
                                              return Colors.white.withValues(alpha: alpha);
                                            })(),
                                            size: 80 - (20 * swapProgress),
                                          ),
                                        ),
                                      // Title
                                      Positioned(
                                        bottom: 20 - (10 * swapProgress),
                                        left: 20,
                                        right: 20,
                                        child: Text(
                                          _previousCardData!['title'] ?? '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24 - (8 * swapProgress),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Animated positioned card with swap animation
                AnimatedBuilder(
                  animation: Listenable.merge([_cardExpansionController, _swapAnimationController]),
                  builder: (context, child) {
                    final expansionValue = _cardExpansionController.value;
                    final swapProgress = _swapProgressAnimation.value;
                    
                    // Calculate positions
                    // Initial position: below header and subtitle with proper spacing
                    final initialTop = 160.0; // Position card below header and subtitle
                    final topPosition = (1 - expansionValue) * initialTop + 
                                       expansionValue * MediaQuery.of(context).padding.top;
                    final leftPosition = (1 - expansionValue) * (screenSize.width * 0.075);
                    final rightPosition = leftPosition;
                    
                    // If swapping, hide the main card since we show it separately
                    double animatedOpacity = 1.0;
                    if (_isSwapping) {
                      animatedOpacity = 1.0 - swapProgress;
                    }
                    final clampedOpacity = animatedOpacity.clamp(0.0, 1.0);
                    print('[TarotMainPage] Main card opacity: swapping=$_isSwapping, swapProgress=$swapProgress, raw=$animatedOpacity, clamped=$clampedOpacity');
                    
                    return Positioned(
                      top: topPosition,
                      left: leftPosition,
                      right: rightPosition,
                      child: Opacity(
                        opacity: clampedOpacity,
                        child: Transform.scale(
                          scale: _swapScaleAnimation.value,
                          child: GestureDetector(
                            key: _mainCardKey,
                            onTap: () {
                              if (_currentState == TarotPageState.initial) {
                                // All cards use the same transition effect
                                _startTransition();
                              }
                            },
                            child: Hero(
                              tag: 'daily-tarot-card',
                              child: _buildMainCard(dateString),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // New content when card is expanded
                if (_currentState == TarotPageState.cardExpanded) ...[
                  (() {
                    print('[TarotMainPage] Rendering cardExpanded content - title');
                    return Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: 0,
                      right: 0,
                      child: Center(
                      child: Text(
                        _selectedCardData != null ? _selectedCardData!['title'] : 'Daily fortune',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                  })(),
                  
                  // Tarot deck when card is expanded
                  (() {
                    print('[TarotMainPage] Rendering cardExpanded content - tarot deck');
                    return Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildTarotDeck(),
                  );
                  })(),
                ],
                  
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainCard(String dateString) {
    final screenSize = MediaQuery.of(context).size;
    
    // Determine card properties based on selected type
    String title = 'Daily fortune';
    IconData? icon;
    Color gradientStart = const Color(0xFFFFA726);
    Color gradientEnd = const Color(0xFFE64A19);
    
    if (_selectedCardType != 'daily' && _selectedCardData != null) {
      title = _selectedCardData!['title'];
      icon = _selectedCardData!['icon'];
      final color = _selectedCardData!['color'] as Color;
      final alpha = 0.8;
      print('[TarotMainPage] _buildMainCard gradient alpha: $alpha');
      gradientStart = color.withValues(alpha: alpha);
      gradientEnd = color;
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimationController, _cardExpansionController]),
      builder: (context, child) {
        final expansionValue = _cardExpansionController.value;
        // Commented out frequent logging
        // print('[TarotMainPage] _buildMainCard expansion value: $expansionValue');
        // print('[TarotMainPage] _cardScaleAnimation value: ${_cardScaleAnimation.value}');
        // print('[TarotMainPage] _cardRotationAnimation value: ${_cardRotationAnimation.value}');
        // print('[TarotMainPage] _cardSizeAnimation value: ${_cardSizeAnimation.value}');
        // print('[TarotMainPage] _cardRadiusAnimation value: ${_cardRadiusAnimation.value}');
        
        // Calculate position and size based on animation
        final cardWidth = screenSize.width * (_cardSizeAnimation.value);
        final cardHeight = 280 + (expansionValue * 120); // Expand height
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_cardRotationAnimation.value)
            ..scale(_cardScaleAnimation.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_cardRadiusAnimation.value),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientStart,
                  gradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (() {
                    final alpha = 0.4;
                    print('[TarotMainPage] _buildMainCard shadow alpha: $alpha');
                    return gradientStart.withValues(alpha: alpha);
                  })(),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Card background pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_cardRadiusAnimation.value),
                    child: AnimatedTarotCardWidget(),
                  ),
                ),
                
                // Icon for non-daily cards
                if (icon != null && _currentState != TarotPageState.cardExpanded)
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Icon(
                      icon,
                      color: (() {
                        final alpha = 0.3;
                        print('[TarotMainPage] _buildMainCard icon alpha: $alpha');
                        return Colors.white.withValues(alpha: alpha);
                      })(),
                      size: 80,
                    ),
                  ),
                
                // Card content
                if (_currentState != TarotPageState.cardExpanded)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateString,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: (() {
                              final alpha = 0.2;
                              print('[TarotMainPage] _buildMainCard button bg alpha: $alpha');
                              return Colors.white.withValues(alpha: alpha);
                            })(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DRAW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        // Removed logging - this runs 60 times per second
        return CustomPaint(
          painter: _MysticalBackgroundPainter(
            animation: _backgroundAnimationController.value,
          ),
          child: Container(),
        );
      },
    );
  }
  
  Widget _buildTarotTypeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
    String cardType,
    GlobalKey cardKey,
  ) {
    final currentDate = DateTime.now();
    final dateString = '${_getWeekday(currentDate.weekday)}, ${_getMonth(currentDate.month)} ${currentDate.day}';
    
    return GestureDetector(
      onTap: () => _onCardSwap(cardType, {
        'title': title,
        'icon': icon,
        'color': color,
        'route': route,
      }),
      child: Container(
        key: cardKey,
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Card background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedTarotCardWidget(),
              ),
            ),
            
            // Icon at top
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.3),
                size: 60,
              ),
            ),
            
            // Card content at bottom
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (() {
                        final alpha = 0.2;
                        print('[TarotMainPage] _buildTarotTypeCard label bg alpha: $alpha');
                        return Colors.white.withValues(alpha: alpha);
                      })(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'DRAW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
    );
  }
  
  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
  
  String _getMonth(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
  
  Widget _buildTarotDeck() {
    print('[TarotMainPage] === _buildTarotDeck called ===');
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: BottomTarotDeckWidget(
        onCardSelected: (index) {
          print('[TarotMainPage] Card selected: $index');
          // Navigate to tarot reading
          context.push('/fortune/tarot/animated-flow');
        },
      ),
    );
  }
  
  Widget _buildAnimatedBottomCard({
    required int index,
    required String title,
    required IconData icon,
    required Color color,
    required String cardType,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bottomCardAnimations[index], _swapAnimationController]),
      builder: (context, child) {
        print('[TarotMainPage] Bottom card $index animation value: ${_bottomCardAnimations[index].value}');
        double yOffset = (1 - _bottomCardAnimations[index].value) * 100;
        double scale = 1.0;
        
        // If this card is being swapped to the top (moving up)
        if (_isSwapping && _swappingToCardType == cardType) {
          // Calculate smooth transition to main card position
          final targetTop = -400.0; // Move up significantly
          yOffset = targetTop * _swapProgressAnimation.value;
          scale = 1.0 + (0.5 * _swapProgressAnimation.value); // Scale up moderately
        }
        
        // If this is where the main card should land (moving down)
        if (_isSwapping && _swappingFromCardType != 'daily' && _swappingFromCardType == cardType) {
          // This bottom card position should receive the main card
          // We'll handle this in the main card animation instead
        }
        
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: _bottomCardAnimations[index].value.clamp(0.0, 1.0),
              child: _buildTarotTypeCard(
                context,
                title,
                icon,
                color,
                '/fortune/tarot/animated-flow',
                cardType,
                _bottomCardKeys[cardType]!,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MysticalBackgroundPainter extends CustomPainter {
  final double animation;
  
  _MysticalBackgroundPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    // Animated orbs
    for (int i = 0; i < 5; i++) {
      final progress = (animation + i * 0.2) % 1.0;
      final rawOpacity = math.sin(progress * math.pi) * 0.3;
      final opacity = rawOpacity.abs(); // Ensure positive value
      // Removed logging - this runs hundreds of times per second
      
      paint.color = Color.lerp(
        const Color(0xFF6A5ACD),
        const Color(0xFFFF6B6B),
        (i / 5),
      )!.withValues(alpha: opacity);
      
      final x = size.width * (0.2 + i * 0.15 + math.sin(progress * math.pi * 2) * 0.1);
      final y = size.height * (0.3 + math.cos(progress * math.pi * 2) * 0.2);
      final radius = 100 + math.sin(progress * math.pi) * 30;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(_MysticalBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}