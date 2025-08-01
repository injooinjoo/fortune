import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../../../routes/app_router.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/widgets/animated_tarot_card_widget.dart';
import '../../../interactive/presentation/widgets/bottom_tarot_deck_widget.dart';
import '../../../../core/constants/tarot_metadata.dart';

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
  late Animation<double> _cardExpansionPositionAnimation;
  late Animation<double> _cardExpansionSizeAnimation;
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
    'health': GlobalKey();
  
  // Card detail state
  int? selectedCardIndex;
  bool isShowingCardDetail = false;
  late AnimationController _cardFlipController;
  late Animation<double> _flipAnimation;
  
  // Card animation state
  Offset? _cardStartPosition;
  Size? _cardStartSize;
  late Animation<Offset> _cardDetailPositionAnimation;
  late Animation<double> _cardDetailScaleAnimation;
  
  late PageController _pageController;
  int? _lastPage = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize PageController
    _pageController = PageController(
      viewportFraction: 0.4),
                  initialPage: 0);
    
    // Add haptic feedback on page changes
    _pageController.addListener(() {
      if (_pageController.page != null) {
        final currentPage = _pageController.page!.round();
        if (_lastPage != currentPage) {
          HapticFeedback.selectionClick();
          _lastPage = currentPage;
}
      },
});
    
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
      parent: _cardAnimationController),
                  curve: Curves.elasticOut)
    ));
    
    _cardRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController),
                  curve: Curves.easeOutBack)
    ));
    
    _cardAnimationController.forward();
    
    // Initialize transition animations
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _bottomCardsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this
    );
    
    // Create staggered animations for bottom cards
    _bottomCardAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _bottomCardsController,
        curve: Interval(
          index * 0.15,
          0.4 + index * 0.15),
                  curve: Curves.easeOutCubic)
        )));
});
    
    // Initialize card expansion animations
    _cardExpansionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardExpansionPositionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardExpansionController),
                  curve: Curves.easeInOutCubic)
    ));
    
    _cardExpansionSizeAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardExpansionController),
                  curve: Curves.easeInOutCubic)
    ));
    
    _cardRadiusAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardExpansionController),
                  curve: Curves.easeInOutCubic)
    ));
    
    // Initialize swap animation controller
    _swapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize card flip animation controller
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardFlipController),
                  curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)));
    
    // Position animation will be initialized when card is selected
    _cardDetailPositionAnimation = const AlwaysStoppedAnimation(Offset.zero);
    _cardDetailScaleAnimation = const AlwaysStoppedAnimation(1.0);
    
    _swapProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swapAnimationController),
                  curve: Curves.easeInOutCubic)
    ));
    
    _swapScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        weight: 0.5,
      )).animate(CurvedAnimation(
      parent: _swapAnimationController),
                  curve: Curves.easeInOut)
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
    _cardFlipController.dispose();
    _pageController.dispose();
    super.dispose();
}
  
  void _startTransition() async {
    setState(() {
      _currentState = TarotPageState.transitioning;
});
    
    // Start bottom cards fade out animation
    _bottomCardsController.forward();
    
    // Wait a bit before expanding the card
    await Future.delayed(const Duration(milliseconds: 300);
    
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
    if (_isSwapping || cardType == _selectedCardType) {
      return;
}
    
    // Store previous card data for the card moving down
    Map<String, dynamic>? prevData;
    if (_selectedCardType == 'daily') {
      prevData = {
        'title': 'Daily fortune'
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFFFA726);
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
    await Future.delayed(const Duration(milliseconds: 50);
    
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
    final currentDate = DateTime.now();
    final dateString = '${_getWeekday(currentDate.weekday)}, ${_getMonth(currentDate.month)} ${currentDate.day}';
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // Animated mystical background
          AnimatedBuilder(
            animation: _bottomCardsController),
                  builder: (context, child) {
              final rawOpacity = 1.0 - (_bottomCardsController.value * 0.5);
              final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
              return Opacity(
                opacity: clampedOpacity),
                  child: _buildAnimatedBackground();
},
          ),
          
          // Main content
          SafeArea(
            child: Stack(
              children: [
                // Initial layout (header, subtitle, bottom cards), Column(
                  children: [
                // Header
                AnimatedBuilder(
                  animation: _bottomCardsController),
                  builder: (context, child) {
                    final rawOpacity = 1.0 - _bottomCardsController.value;
                    final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: clampedOpacity),
                  child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  children: [
                            Text(
                              'My tarot'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white),
                  fontWeight: FontWeight.bold)
                              ),
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white70),
                              onPressed: () {},
                            ),
                      
                    );
},
                ),
                
                // Subtitle
                AnimatedBuilder(
                  animation: _bottomCardsController),
                  builder: (context, child) {
                    final rawOpacity = 1.0 - _bottomCardsController.value;
                    final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: clampedOpacity),
                  child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Everything has its unseen roots'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white60)
                            ),
                        ));
},
                ),
                
                // Large space for card placement and to push Tarot Reading section down
                const SizedBox(height: 350), // Space for card + margin
                
                // Tarot Reading section
                AnimatedBuilder(
                  animation: _bottomCardsController),
                  builder: (context, child) {
                    final rawOpacity = 1.0 - _bottomCardsController.value;
                    final clampedOpacity = rawOpacity.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: clampedOpacity),
                  child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tarot Reading'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white),
                  fontWeight: FontWeight.bold)
                            ),
                        ));
},
                ),
                
                const SizedBox(height: 16),
                
                // Horizontal scroll of tarot types with PageView
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    pageSnapping: true,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final cards = [
                        {'title': 'Love', 'icon': Icons.favorite, 'color': const Color(0xFFE91E63), 'type': 'love'},
                        {'title': 'Career', 'icon': Icons.work, 'color': const Color(0xFF4CAF50), 'type': 'career'},
                        {'title': 'Choice', 'icon': Icons.alt_route, 'color': const Color(0xFFFF9800), 'type': 'choice'},
                        {'title': 'Health', 'icon': Icons.favorite_border, 'color': const Color(0xFF2196F3), 'type': 'health'},
                      ];
                      
                      final card = cards[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: _buildAnimatedBottomCard(
                          index: index,
                          title: card['title'] as String,
                          icon: card['icon'] as IconData,
                          color: card['color'] as Color),
                  cardType: card['type'] as String);
},
                  ),
                ),
                
                // Show the card moving down during swap (with higher z-index,
                if (_isSwapping && _swappingFromCardType != null && _previousCardData != null)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _swapAnimationController),
                  builder: (context, child) {
                        final swapProgress = _swapProgressAnimation.value;
                        
                        // Find target position (where the clicked card was,
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
                          top: animatedTop
                          left: animatedLeft,
                          child: Transform.scale(
                            scale: _swapScaleAnimation.value,
                            child: Container(
                                  width: animatedWidth),
                  height: animatedHeight),
                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,,
                  colors: [
                                        (() {
                                          final alpha = 0.8;
                                          return (_previousCardData!['color'] as Color).withValues(alpha: alpha);
})(),
                                        _previousCardData!['color'] as Color,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (() {
                                          final alpha = 0.4;
                                          return (_previousCardData!['color'] as Color).withValues(alpha: alpha);
})(),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                  child: Stack(
                                    children: [
                                      // Background icon
                                      if (_previousCardData!['icon'] != null), Positioned(
                                          top: 30,
                                          left: 0,
                                          right: 0,
                                          child: Icon(
                                            _previousCardData!['icon'] as IconData),
                  color: (() {
                                              final alpha = 0.3;
                                              return Colors.white.withValues(alpha: alpha);
})(),
                                            size: 80 - (20 * swapProgress),
                                        ),
                                      // Title
                                      Positioned(
                                        bottom: 20 - (10 * swapProgress),
                                        left: 20,
                                        right: 20,
                                        child: Text(
                                          _previousCardData!['title'] ?? ''),
                  style: TextStyle(
                                            color: Colors.white),
                  fontSize: 24 - (8 * swapProgress),
                                            fontWeight: FontWeight.bold,
                                          ),
                                      ),
                            ));
},
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
                    // Removed repetitive logging
                    
                    return Positioned(
                      top: topPosition,
                      left: leftPosition,
                      right: rightPosition,
                      child: Opacity(
                        opacity: clampedOpacity,
                        child: Transform.scale(
                          scale: _isSwapping ? _swapScaleAnimation.value : 1.0),
                  child: GestureDetector(
                            key: _mainCardKey),
                  onTap: () {
                              if (_currentState == TarotPageState.initial) {
                                // All cards use the same transition effect
                                _startTransition();
}
                            },
                            child: Hero(
                              tag: 'daily-tarot-card'),
                  child: _buildMainCard(dateString),
                          ),
                      ));
},
                ),
                
                // New content when card is expanded
                if (_currentState == TarotPageState.cardExpanded) ...[
                  (() {
                    return Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: 0,
                      right: 0,
                      child: Center(
                      child: Text(
                        _selectedCardData != null ? _selectedCardData!['title'] : 'Daily fortune'
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32),
                  fontWeight: FontWeight.bold)
                        ),
                    ));
})(),
                  
                  // Tarot deck when card is expanded
                  (() {
                    return Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildTarotDeck();
})(),
          ),
          
          // Card detail overlay with full-screen dark background
          if (isShowingCardDetail && selectedCardIndex != null) ...[
            // Full-screen dark background with mystical animation
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _cardFlipController.reverse().then((_) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        isShowingCardDetail = false;
                        selectedCardIndex = null;
});
});
});
},
                child: AnimatedBuilder(
                  animation: _cardFlipController),
                  builder: (context, child) {
                    return Container(
                      color: const Color(0xFF0A0E27).withValues(alpha: _cardFlipController.value * 0.95),
                      child: _cardFlipController.value > 0.3 
                          ? Opacity(
                              opacity: (_cardFlipController.value - 0.3) / 0.7,
                              child: _buildAnimatedBackground(),
                            ),
                          : null
                    );
},
                ),
            ),
            
            // Card detail with Hero animation - removed to integrate with scrollable view
              
            // Overlay UI elements with scrollable content
            AnimatedBuilder(
              animation: _flipAnimation),
                  builder: (context, child) {
                // Only show after flip completes
                if (_flipAnimation.value < 0.5) return const SizedBox();
                
                final cardInfo = selectedCardIndex != null 
                    ? TarotMetadata.getCard(selectedCardIndex!) ?? TarotMetadata.majorArcana[0]!
                    : TarotMetadata.majorArcana[0]!;
                
                return Opacity(
                  opacity: (_flipAnimation.value - 0.5) * 2, // Fade in after flip
                  child: _buildFullScreenCardDetail(context, cardInfo));
},
            ));
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
        // print('[TarotMainPage] _cardSizeAnimation value: ${_cardExpansionSizeAnimation.value}');
        // print('[TarotMainPage] _cardRadiusAnimation value: ${_cardRadiusAnimation.value}');
        
        // Calculate position and size based on animation
        final cardWidth = screenSize.width * (_cardExpansionSizeAnimation.value);
        final cardHeight = 280 + (expansionValue * 120); // Expand height
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity(,
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
                  gradientEnd),
              boxShadow: [
                BoxShadow(
                  color: (() {
                    final alpha = 0.4;
                    // Removed repetitive logging
                    return gradientStart.withValues(alpha: alpha);
})(),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
            child: Stack(
              children: [
                // Card background pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_cardRadiusAnimation.value),
                    child: AnimatedTarotCardWidget(),
                ),
                
                // Icon for non-daily cards
                if (icon != null && _currentState != TarotPageState.cardExpanded), Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Icon(
                      icon),
                  color: (() {
                        final alpha = 0.3;
                        return Colors.white.withValues(alpha: alpha);
})(),
                      size: 80,
                    ),
                
                // Card content
                if (_currentState != TarotPageState.cardExpanded), Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateString),
                  style: const TextStyle(
                            color: Colors.white70),
                  fontSize: 14)
                          ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24),
                  fontWeight: FontWeight.bold)
                          ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                  vertical: 8),
                          decoration: BoxDecoration(
                            color: (() {
                              final alpha = 0.2;
                              // Removed repetitive logging
                              return Colors.white.withValues(alpha: alpha);
})(),
                            borderRadius: BorderRadius.circular(20),
                          child: const Text(
                            'DRAW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                  letterSpacing: 1.2)
                            ),
                        ),
                  ),
          ));
}
    );
}
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimationController),
                  builder: (context, child) {
        // Removed logging - this runs 60 times per second
        return CustomPaint(
          painter: _MysticalBackgroundPainter(
            animation: _backgroundAnimationController.value),
          child: Container());
}
    );
}
  
  Widget _buildTarotTypeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
    String cardType,
    GlobalKey cardKey)
  ) {
    final currentDate = DateTime.now();
    final dateString = '${_getWeekday(currentDate.weekday)}, ${_getMonth(currentDate.month)} ${currentDate.day}';
    
    return GestureDetector(
      onTap: () => _onCardSwap(cardType, {
        'title': title,
        'icon': icon,
        'color': color,
        'route': route),
}),
      child: Container(
        key: cardKey,
        width: 140),
                  height: 180),
                  decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,,
                  colors: [
              color.withValues(alpha: 0.8),
              color,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        child: Stack(
          children: [
            // Card background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedTarotCardWidget(),
            ),
            
            // Icon at top
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Icon(
                icon),
                  color: Colors.white.withValues(alpha: 0.3),
                size: 60,
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
                      color: Colors.white),
                  fontSize: 20),
                  fontWeight: FontWeight.bold)
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  vertical: 6),
                    decoration: BoxDecoration(
                      color: (() {
                        final alpha = 0.2;
                        // Removed repetitive logging
                        return Colors.white.withValues(alpha: alpha);
})(),
                      borderRadius: BorderRadius.circular(16),
                    child: const Text(
                      'DRAW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  letterSpacing: 1.2)
                      ),
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
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: BottomTarotDeckWidget(
        onCardSelected: (cardIndex, position, size) {
          
          setState(() {
            selectedCardIndex = cardIndex; // Use the actual random card index
            isShowingCardDetail = true;
});
          
          // Delay flip animation to let Hero animation complete
          Future.delayed(const Duration(milliseconds: 300), () {
            _cardFlipController.forward();
});
},
      
    );
}
  
  Widget _buildCardDetail() {
    // If not showing detail, return the deck card design matching BottomTarotDeckWidget
    if (!isShowingCardDetail) {
      return Container(
        width: 60),
                  height: 84),
                  decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,,
                  colors: [
              const Color(0xFF1E3A5F),
              const Color(0xFF0D1B2A),
              const Color(0xFF415A77),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 5,
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomPaint(
            painter: TarotCardBackPainter(isHighlighted: true),
        
      );
}
    
    // Standard card size (tarot card ratio 1: 1.4,
    final cardWidth = 300.0;
    final cardHeight = cardWidth * 1.4;
    
    return AnimatedBuilder(
      animation: _flipAnimation),
                  builder: (context, child) {
        final isShowingFront = _flipAnimation.value < 0.5;
        
        return Container(
          width: cardWidth,
          height: cardHeight,
          child: Transform(
            alignment: Alignment.center),
                  transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * math.pi),
            child: isShowingFront
                ? _buildCardBack() // Card back design
                : Transform(
                    alignment: Alignment.center),
                  transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCardFront(), // Card front (THE FOOL, etc.,
                  ),
        );
},
    );
}
  
  Widget _buildCardBack() {
    // Card back design with rounded corners
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,,
                  colors: [
            const Color(0xFF1E3A5F),
            const Color(0xFF0D1B2A),
            const Color(0xFF415A77),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: TarotCardBackDetailPainter(),
      
    );
}
  
  Widget _buildCardFront() {
    // Get card metadata
    final cardInfo = selectedCardIndex != null 
        ? TarotMetadata.getCard(selectedCardIndex!) ?? TarotMetadata.majorArcana[0]!
        : TarotMetadata.majorArcana[0]!;
    
    // Get the appropriate image path - use rider_waite deck
    String imagePath;
    if (selectedCardIndex != null && selectedCardIndex! < 22) {
      // Major Arcana names
      final cardNames = [
        'fool', 'magician', 'high_priestess', 'empress', 'emperor',
        'hierophant', 'lovers', 'chariot', 'strength', 'hermit',
        'wheel_of_fortune', 'justice', 'hanged_man', 'death', 'temperance',
        'devil', 'tower', 'star', 'moon', 'sun', 'judgement', 'world',
];
      imagePath = 'assets/images/tarot/decks/rider_waite/major/${selectedCardIndex.toString().padLeft(2, '0')}_${cardNames[selectedCardIndex!]}.jpg';
} else {
      imagePath = 'assets/images/tarot/decks/rider_waite/major/00_fool.jpg';
}
    
    // Card design with rounded corners and shadow
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand),
                  children: [
            // Card image
            Image.asset(
              imagePath),
                  fit: BoxFit.cover),
                  errorBuilder: (context, error, stackTrace) {
                // Fallback to solid color with card name
                return Container(
                  color: const Color(0xFF2A2A2A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported),
                  color: Colors.white54),
                  size: 48),
                        const SizedBox(height: 16),
                        Text(
                          cardInfo.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24),
                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                  ));
},
            ),
      
    );
}
  
  Widget _buildFullScreenCardDetail(BuildContext context, TarotCardInfo cardInfo) {
    final themeColor = _getThemeColor();
    
    return Stack(
      children: [
        // Main scrollable content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Space for card
              const SizedBox(height: 100),
              
              // Card with Hero animation
              Center(
                child: Hero(
                  tag: 'tarot-card-$selectedCardIndex'),
                  child: _buildCardDetail(),
              ),
              
              const SizedBox(height: 40),
              
              // Scroll indicator
              _buildScrollIndicator(),
              
              const SizedBox(height: 30),
              
              // Content sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Theme-specific interpretation
                    _buildSectionCard(
                      title: _getThemeTitle(),
                      content: _getThemeSpecificInterpretation(cardInfo),
                      color: themeColor,
                      icon: _getThemeIcon(),
                    
                    const SizedBox(height: 20),
                    
                    // Keywords
                    if (cardInfo.keywords.isNotEmpty) ...[
                      _buildKeywordsSection(cardInfo.keywords),
                      const SizedBox(height: 20),
                    
                    // General meaning
                    _buildSectionCard(
                      title: '기본 의미',
                      content: cardInfo.uprightMeaning,
                      color: Colors.purple,
                      icon: Icons.auto_awesome),
                    
                    const SizedBox(height: 20),
                    
                    // Advice
                    _buildSectionCard(
                      title: '조언',
                      content: cardInfo.advice,
                      color: Colors.blue,
                      icon: Icons.lightbulb_outline),
                    
                    const SizedBox(height: 20),
                    
                    // Questions for reflection
                    if (cardInfo.questions.isNotEmpty) ...[
                      _buildQuestionsSection(cardInfo.questions),
                      const SizedBox(height: 20),
                    
                    // Affirmations
                    if (cardInfo.affirmations != null && cardInfo.affirmations!.isNotEmpty) ...[
                      _buildAffirmationsSection(cardInfo.affirmations!),
                      const SizedBox(height: 20),
                    
                    // Bottom padding
                    const SizedBox(height: 100),
              ),
        ),
        
        // Fixed header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter),
                  end: Alignment.bottomCenter,,
                  colors: [
                  Colors.black.withValues(alpha: 0.9),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
              ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () {
                        _cardFlipController.reverse().then((_) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            setState(() {
                              isShowingCardDetail = false;
                              selectedCardIndex = null;
});
});
});
},
                    ),
                    Text(
                      cardInfo.name.split('(')[0].trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)
                      ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
              ),
          ))
    );
}
  
  
  Widget _buildScrollIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          alignment: Alignment.center),
                  child: Column(
            children: [
              Transform.translate(
                offset: Offset(0, math.sin(value * 2 * math.pi) * 5),
                child: Icon(
                  Icons.expand_more),
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 32,
                ),
              Text(
                '아래로 스크롤하여 더 많은 내용을 확인하세요'),
                  style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
          ));
}
    );
}
  
  Widget _buildSectionCard({
    required String title,
    required String content,
    required Color color,
    required IconData icon),
}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18),
                  fontWeight: FontWeight.bold)
                ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16),
                  height: 1.6)
            ),
      
    );
}
  
  Widget _buildKeywordsSection(List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '키워드',
          style: TextStyle(
            color: Colors.white),
                  fontSize: 18),
                  fontWeight: FontWeight.bold)
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8),
                  children: keywords.map((keyword) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Text(
                keyword,
                style: const TextStyle(
                  color: Colors.white),
                  fontSize: 14)
                ),
            );
}).toList(),
    );
}
  
  Widget _buildQuestionsSection(List<String> questions) {
    return _buildSectionCard(
      title: '성찰을 위한 질문'),
                  content: questions.map((q) => '• $q').join('\n'),
      color: Colors.amber,
      icon: Icons.help_outline,
    );
}
  
  Widget _buildAffirmationsSection(List<String> affirmations) {
    return _buildSectionCard(
      title: '확언'),
                  content: affirmations.map((a) => '"$a"').join('\n\n'),
      color: Colors.green,
      icon: Icons.format_quote
    );
}
  
  String _getThemeTitle() {
    switch (_selectedCardType) {
      case 'daily':
        return '오늘의 메시지';
      case 'love':
        return '사랑과 관계';
      case 'career':
        return '일과 성공';
      case 'choice':
        return '선택의 지혜';
      case 'health':
        return '건강과 활력';
      default:
        return '카드의 메시지';
}
  }
  
  IconData _getThemeIcon() {
    switch (_selectedCardType) {
      case 'love':
        return Icons.favorite;
      case 'career':
        return Icons.work;
      case 'choice':
        return Icons.alt_route;
      case 'health':
        return Icons.favorite_border;
      case 'daily':
      default:
        return Icons.auto_awesome;
}
  }
  
  String _getCardImagePath(int cardIndex) {
    // Default to rider_waite deck
    const deckPath = 'assets/images/tarot/decks/rider_waite';
    
    if (cardIndex < 22) {
      // Major Arcana names
      final cardNames = [
        'fool', 'magician', 'high_priestess', 'empress', 'emperor',
        'hierophant', 'lovers', 'chariot', 'strength', 'hermit',
        'wheel_of_fortune', 'justice', 'hanged_man', 'death', 'temperance',
        'devil', 'tower', 'star', 'moon', 'sun', 'judgement', 'world',
];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
}
    return '$deckPath/major/00_fool.jpg';
}
  
  Widget _buildInfoBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min),
                  children: [
          Icon(icon, size: 16, color: Colors.white60),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60),
                  fontSize: 14)
            ),
      
    );
}
  
  String _getThemeSpecificInterpretation(TarotCardInfo cardInfo) {
    switch (_selectedCardType) {
      case 'daily':
        return "오늘의 운세: ${cardInfo.dailyApplications?.join(' ') ?? cardInfo.uprightMeaning}";
      case 'love':
        return "연애운: 이 카드는 사랑과 관계에서 ${cardInfo.psychologicalMeaning ?? cardInfo.uprightMeaning}";
      case 'career':
        return "직업운: 당신의 커리어에서 ${cardInfo.spiritualMeaning ?? cardInfo.uprightMeaning}";
      case 'choice':
        return "선택의 순간: 이 카드가 제시하는 방향은 ${cardInfo.advice}";
      case 'health':
        return "건강운: ${cardInfo.healthMessage ?? cardInfo.uprightMeaning}";
      default:
        return cardInfo.uprightMeaning;
}
  }
  
  Color _getThemeColor() {
    switch (_selectedCardType) {
      case 'love':
        return const Color(0xFFE91E63);
      case 'career':
        return const Color(0xFF4CAF50);
      case 'choice':
        return const Color(0xFFFF9800);
      case 'health':
        return const Color(0xFF2196F3);
      case 'daily':
      default:
        return const Color(0xFFFFA726);
}
  }
  
  IconData _getAstrologyIcon(String astrology) {
    // Simple icon mapping for astrology signs
    switch (astrology) {
      case '천왕성':
      case 'Uranus':
        return Icons.circle_outlined;
      case '수성':
      case 'Mercury':
        return Icons.brightness_7;
      case '달':
      case 'Moon':
        return Icons.nightlight_round;
      case '금성':
      case 'Venus':
        return Icons.favorite_border;
      case '화성':
      case 'Mars':
        return Icons.whatshot;
      case '목성':
      case 'Jupiter':
        return Icons.public;
      case '토성':
      case 'Saturn':
        return Icons.change_circle_outlined;
      case '해왕성':
      case 'Neptune':
        return Icons.waves;
      case '명왕성':
      case 'Pluto':
        return Icons.dark_mode;
      default: return Icons.stars;
}
  }
  
  Widget _buildAnimatedBottomCard({
    required int index,
    required String title,
    required IconData icon,
    required Color color,
    required String cardType),
}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _bottomCardAnimations[index],
            _swapAnimationController)
            _pageController),
]),
          builder: (context, child) {
            // Calculate page offset for 3D effect
            double pageOffset = 0;
            if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
              pageOffset = index - _pageController.page!;
}
            
            // Enhanced animations with smooth curves
            final absOffset = pageOffset.abs();
            final normalizedOffset = absOffset.clamp(0.0, 1.0);
            
            // Smooth scale with enhanced 3D effect
            double scale = 1.0 - (normalizedOffset * 0.2);
            scale = Curves.easeOutCubic.transform(scale);
            
            // Dynamic rotation for depth
            double rotationY = pageOffset * 0.4 * math.pi / 6;
            double rotationZ = math.sin(pageOffset * math.pi) * 0.02;
            
            // Enhanced opacity with glow effect
            double opacity = Curves.easeIn.transform(1.0 - normalizedOffset * 0.6).clamp(0.2, 1.0);
            
            // Parallax offset
            double xOffset = pageOffset * 30;
            double yOffset = (1 - _bottomCardAnimations[index].value) * 100;
            
            // Dynamic blur based on distance
            double blurAmount = 15 + (normalizedOffset * 10);
            
            // Swap animations
            if (_isSwapping && _swappingToCardType == cardType) {
              final targetTop = -400.0;
              yOffset = targetTop * _swapProgressAnimation.value;
              scale = 1.0 + (0.5 * _swapProgressAnimation.value);
}
            
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002) // Enhanced perspective
                ..rotateY(rotationY)
                ..rotateZ(rotationZ)
                ..scale(scale),
              child: Transform.translate(
                offset: Offset(xOffset, yOffset),
                child: Opacity(
                  opacity: _bottomCardAnimations[index].value.clamp(0.0, 1.0) * opacity,
                  child: GestureDetector(
                    onTap: () => _onCardSwap(cardType, {
                      'title': title,
                      'icon': icon,
                      'color': color,
                      'route': ''),
}),
                    child: Container(
                      key: _bottomCardKeys[cardType]),
                  decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          // Primary glow
                          BoxShadow(
                            color: color.withValues(alpha: 0.5 * opacity),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: Offset(0, 15),
                          // Secondary shadow for depth
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3 * opacity),
                            blurRadius: 20,
                            spreadRadius: -5,
                            offset: Offset(0, 20),
                          // Inner glow
                          BoxShadow(
                            color: color.withValues(alpha: 0.3 * opacity),
                            blurRadius: 15,
                            spreadRadius: -10,
                            offset: Offset(0, -5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: blurAmount),
                  sigmaY: blurAmount),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft),
                  end: Alignment.bottomRight,,
                  colors: [
                                  color.withValues(alpha: 0.9),
                                  color.withValues(alpha: 0.7),
                                  color.withValues(alpha: 0.5),
                                stops: [0.0, 0.5, 1.0],
                              ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,,
                  colors: [
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              child: Stack(
                                children: [
                                  // Animated background pattern
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _CardPatternPainter(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        animation: _backgroundAnimationController.value,
                                      ),
                                  ),
                                  // Content
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center),
                  children: [
                                      // Icon with glow effect
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.3),
                                              Colors.white.withValues(alpha: 0.1),
                                              Colors.transparent,
                                            stops: [0.0, 0.5, 1.0],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                        child: Icon(
                                          icon,
                                          size: 42),
                  color: Colors.white),
                  shadows: [
                                            Shadow(
                                              color: color.withValues(alpha: 0.8),
                                              blurRadius: 10,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Title with enhanced styling
                                      Text(
                                        title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                  letterSpacing: 1.5),
                  shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                            Shadow(
                                              color: color.withValues(alpha: 0.8),
                                              blurRadius: 8,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Subtle animation indicator
                                      Container(
                                        width: 40,
                                        height: 3),
                  decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent)
                                              Colors.white.withValues(alpha: 0.6),
                                              Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(1.5),
                                      ),
                              ),
                          ),
                      ),
                  ),
              ));
},
        );
}
    );
}
}

class TarotCardBackPainter extends CustomPainter {
  final bool isHighlighted;
  
  TarotCardBackPainter({required this.isHighlighted});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Center design
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw stars pattern
    paint.color = Colors.white.withValues(alpha: isHighlighted ? 0.4 : 0.2);
    
    // Center star
    _drawStar(canvas, center, size.width * 0.15, paint);
    
    // Surrounding stars
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final starPos = Offset(
        center.dx + size.width * 0.25 * math.cos(angle),
        center.dy + size.width * 0.25 * math.sin(angle);
      _drawStar(canvas, starPos, size.width * 0.08, paint);
}
    
    // Draw border pattern
    final borderRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05)
      size.width * 0.8)
      size.height * 0.9
    );
    paint.strokeWidth = 1.0;
    canvas.drawRect(borderRect, paint);
    
    // Inner border
    final innerRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.08)
      size.width * 0.7)
      size.height * 0.84
    );
    paint.strokeWidth = 0.5;
    canvas.drawRect(innerRect, paint);
}
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final angle = -math.pi / 2;
    
    for (int i = 0; i < 5; i++) {
      final outerX = center.dx + radius * math.cos(angle + i * 2 * math.pi / 5);
      final outerY = center.dy + radius * math.sin(angle + i * 2 * math.pi / 5);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
} else {
        path.lineTo(outerX, outerY);
}
      
      final innerRadius = radius * 0.4;
      final innerAngle = angle + (i * 2 + 1) * math.pi / 5;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
}
    
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
}
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TarotCardBackDetailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Center design
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw larger central star
    paint.color = Colors.white.withValues(alpha: 0.3);
    _drawStar(canvas, center, size.width * 0.25, paint);
    
    // Draw surrounding stars in a circle
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final starPos = Offset(
        center.dx + size.width * 0.35 * math.cos(angle),
        center.dy + size.width * 0.35 * math.sin(angle);
      _drawStar(canvas, starPos, size.width * 0.1, paint);
}
    
    // Draw border pattern
    final borderRect = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.05)
      size.width * 0.9)
      size.height * 0.9
    );
    paint.strokeWidth = 2.0;
    canvas.drawRect(borderRect, paint);
}
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final angle = -math.pi / 2;
    
    for (int i = 0; i < 5; i++) {
      final outerX = center.dx + radius * math.cos(angle + i * 2 * math.pi / 5);
      final outerY = center.dy + radius * math.sin(angle + i * 2 * math.pi / 5);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
} else {
        path.lineTo(outerX, outerY);
}
      
      final innerRadius = radius * 0.4;
      final innerAngle = angle + (i * 2 + 1) * math.pi / 5;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
}
    
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
}
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MysticalBackgroundPainter extends CustomPainter {
  final double animation;
  
  _MysticalBackgroundPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const,
      MaskFilter.blur(BlurStyle.normal, 50);
    
    // Animated orbs
    for (int i = 0; i < 5; i++) {
      final progress = (animation + i * 0.2) % 1.0;
      final rawOpacity = math.sin(progress * math.pi) * 0.3;
      final opacity = rawOpacity.abs(); // Ensure positive value
      // Removed logging - this runs hundreds of times per second
      
      paint.color = Color.lerp(
        const Color(0xFF6A5ACD),
        const Color(0xFFFF6B6B),
        (i / 5))!.withValues(alpha: opacity);
      
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

class _CardPatternPainter extends CustomPainter {
  final Color color;
  final double animation;
  
  _CardPatternPainter({required this.color, required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style =,
      PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Create animated mystical patterns
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw rotating circles
    for (int i = 0; i < 3; i++) {
      final radius = size.width * (0.3 + i * 0.15);
      final opacity = (1.0 - i * 0.3) * 0.3;
      paint.color = color.withValues(alpha: opacity);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(animation * 2 * math.pi + i * math.pi / 3);
      canvas.translate(-center.dx, -center.dy);
      
      // Draw circle with gradient effect
      final rect = Rect.fromCenter(center: center, width: radius * 2, height: radius * 2);
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      
      // Draw decorative elements
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 3, paint..style = PaintingStyle.fill);
}
      
      canvas.restore();
}
    
    // Draw corner ornaments
    paint
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final cornerSize = size.width * 0.15;
    final corners = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height);
    
    for (int i = 0; i < corners.length; i++) {
      final corner = corners[i];
      final path = Path();
      
      if (i == 0) { // Top-left
        path.moveTo(corner.dx + cornerSize, corner.dy);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx, corner.dy + cornerSize);
} else if (i == 1) { // Top-right
        path.moveTo(corner.dx - cornerSize, corner.dy);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx, corner.dy + cornerSize);
} else if (i == 2) { // Bottom-left
        path.moveTo(corner.dx + cornerSize, corner.dy);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx, corner.dy - cornerSize);
} else { // Bottom-right
        path.moveTo(corner.dx - cornerSize, corner.dy);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx, corner.dy - cornerSize);
}
      
      canvas.drawPath(path, paint);
}
  }
  
  @override
  bool shouldRepaint(_CardPatternPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
}
}