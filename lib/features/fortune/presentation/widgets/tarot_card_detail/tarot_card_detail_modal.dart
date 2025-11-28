import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:fortune/core/widgets/unified_button.dart';
import 'package:fortune/core/widgets/unified_button_enums.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'widgets/card_header.dart';
import 'widgets/page_indicator.dart';
import 'widgets/card_image_page.dart';
import 'widgets/story_page.dart';
import 'widgets/symbolism_page.dart';
import 'widgets/meanings_page.dart';
import 'widgets/deep_interpretation_page.dart';
import 'widgets/practical_guide_page.dart';
import 'widgets/relationships_page.dart';
import 'widgets/advice_page.dart';
import 'widgets/card_helpers.dart';

class TarotCardDetailModal extends StatefulWidget {
  final int cardIndex;
  final String? position;

  const TarotCardDetailModal({
    super.key,
    required this.cardIndex,
    this.position,
  });

  static Future<void> show({
    required BuildContext context,
    required int cardIndex,
    String? position,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.transparent,
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
      duration: TossDesignSystem.durationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

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
    final cardInfo = TarotCardHelpers.getCardInfo(widget.cardIndex);
    final imagePath = TarotCardHelpers.getCardImagePath(widget.cardIndex);
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                      margin: const EdgeInsets.only(
                          top: TossDesignSystem.spacingS),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4 * 0.5),
                      ),
                    ),

                    // Header
                    TarotCardHeader(
                      cardInfo: cardInfo,
                      position: widget.position,
                      currentPage: _currentPage,
                    ),

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
                              CardImagePage(
                                cardInfo: cardInfo,
                                imagePath: imagePath,
                                scaleAnimation: _scaleAnimation,
                              ),
                              StoryPage(
                                cardInfo: cardInfo,
                                cardIndex: widget.cardIndex,
                              ),
                              SymbolismPage(cardInfo: cardInfo),
                              MeaningsPage(cardInfo: cardInfo),
                              DeepInterpretationPage(
                                cardInfo: cardInfo,
                                cardIndex: widget.cardIndex,
                              ),
                              PracticalGuidePage(
                                cardInfo: cardInfo,
                                cardIndex: widget.cardIndex,
                              ),
                              RelationshipsPage(
                                cardInfo: cardInfo,
                                cardIndex: widget.cardIndex,
                              ),
                              AdvicePage(cardInfo: cardInfo),
                            ],
                          ),

                          // Left arrow
                          if (_currentPage > 0)
                            Positioned(
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: TossDesignSystem.gray900
                                          .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios,
                                      color: TossDesignSystem.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: TossDesignSystem.durationMedium,
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),

                          // Right arrow
                          if (_currentPage < 7)
                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: TossDesignSystem.gray900
                                          .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: TossDesignSystem.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: TossDesignSystem.durationMedium,
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Page indicator
                    TarotPageIndicator(
                      currentPage: _currentPage,
                      pageController: _pageController,
                    ),

                    // Close button
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(TossDesignSystem.spacingM),
                        child: SizedBox(
                          width: double.infinity,
                          child: UnifiedButton(
                            text: '닫기',
                            onPressed: () => Navigator.of(context).pop(),
                            style: UnifiedButtonStyle.primary,
                            size: UnifiedButtonSize.large,
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
}
