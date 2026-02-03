import '../../../../core/theme/fortune_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/fortune_haptic_service.dart';

class TarotAnimatedFlowPage extends ConsumerStatefulWidget {
  const TarotAnimatedFlowPage({
    super.key,
  });

  @override
  ConsumerState<TarotAnimatedFlowPage> createState() => _TarotAnimatedFlowPageState();
}

class _TarotAnimatedFlowPageState extends ConsumerState<TarotAnimatedFlowPage>
    with TickerProviderStateMixin {
  PageController? _pageController;
  int? _selectedCardIndex;

  late AnimationController _heroController;

  late AnimationController _fadeController;

  late AnimationController _scaleController;

  final List<Map<String, dynamic>> _majorArcana = [
    {
      'name': 'The Fool',
      'number': 0,
      'image': 'assets/images/tarot/fool.png',
      'meaning': 'New beginnings, innocence, spontaneity',
      'planet': 'Uranus',
      'element': 'Air',
    },
    {
      'name': 'The Magician',
      'number': 1,
      'image': 'assets/images/tarot/magician.png',
      'meaning': 'Power, skill, concentration',
      'planet': 'Mercury',
      'element': 'Air',
    },
    {
      'name': 'The High Priestess',
      'number': 2,
      'image': 'assets/images/tarot/high_priestess.png',
      'meaning': 'Intuition, higher powers, mystery',
      'planet': 'Moon',
      'element': 'Water',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _heroController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.black,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // 페이지 전환 햅틱
          ref.read(fortuneHapticServiceProvider).pageSnap();
          setState(() {});
        },
        children: [
          _buildWelcomePage(),
          _buildCardSelectionPage(),
          if (_selectedCardIndex != null) _buildCardReveal(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TossDesignSystem.purple.withValues(alpha: 0.8),
            TossDesignSystem.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero text
            Text(
              'Mystical Tarot',
              style: TossDesignSystem.heading1.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: TossDesignSystem.purple.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 1000.ms)
              .scale(begin: const Offset(0.5, 0.5)),
            
            const SizedBox(height: 40),
            
            // Subtitle
            Text(
              'Discover your destiny through\nthe ancient wisdom of tarot',
              textAlign: TextAlign.center,
              style: TossDesignSystem.body1.copyWith(
                color: TossDesignSystem.white.withValues(alpha: 0.8),
                height: 1.6,
              ),
            ).animate(delay: 500.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 60),
            
            // Start button
            ElevatedButton(
              onPressed: () {
                _pageController?.nextPage(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TossDesignSystem.purple.withValues(alpha: 0.8),
                foregroundColor: TossDesignSystem.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: TossDesignSystem.purple.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Begin Your Journey',
                    style: TossDesignSystem.button.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 1000.ms)
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelectionPage() {
    return Container(
      color: TossDesignSystem.black,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Choose Your Card',
                    style: TossDesignSystem.heading1.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trust your intuition and select the card that calls to you',
                    textAlign: TextAlign.center,
                    style: TossDesignSystem.body2.copyWith(
                      color: TossDesignSystem.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Cards grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  itemCount: _majorArcana.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _selectCard(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: TossDesignSystem.purple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: TossDesignSystem.purple.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: TossDesignSystem.purple.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: TossDesignSystem.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Card ${index + 1}',
                              style: TossDesignSystem.heading3.copyWith(
                                color: TossDesignSystem.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (200 * index).ms)
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardReveal() {
    final cardData = _majorArcana[_selectedCardIndex!];
    
    return Container(
      color: TossDesignSystem.black,
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
                  cardData['image'] ?? 'assets/images/tarot/back.png',
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
                              color: TossDesignSystem.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              cardData['name'] ?? 'Unknown',
                              style: context.displaySmall.copyWith(
                                color: TossDesignSystem.white,
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
              cardData['name'] ?? 'Unknown Card',
              style: context.displaySmall.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '"Go forward and do whatever\nyour heart tells you"',
              textAlign: TextAlign.center,
              style: context.labelMedium.copyWith(
                color: TossDesignSystem.white.withValues(alpha: 0.8),
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
                _buildMetadata(Icons.public, cardData['planet'] ?? ''),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Continue button
            ElevatedButton(
              onPressed: () {
                // Navigate to detailed reading
                context.push('/interactive/tarot/storytelling', extra: cardData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'View Full Reading',
                style: context.labelMedium.copyWith(
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
        Icon(icon, color: TossDesignSystem.white.withValues(alpha: 0.6), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: context.bodySmall.copyWith(
            color: TossDesignSystem.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  void _selectCard(int index) {
    // 타로 카드 선택 햅틱
    ref.read(fortuneHapticServiceProvider).cardSelect();

    setState(() {
      _selectedCardIndex = index;
    });

    _heroController.forward();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _pageController?.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }
}