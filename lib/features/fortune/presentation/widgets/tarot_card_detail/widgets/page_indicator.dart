import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

class TarotPageIndicator extends StatelessWidget {
  final int currentPage;
  final PageController pageController;

  const TarotPageIndicator({
    super.key,
    required this.currentPage,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final pageNames = [
      '이미지',
      '스토리',
      '상징',
      '의미',
      '심화해석',
      '실천',
      '관계',
      '조언'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            DSColors.textPrimary.withValues(alpha: 0.3)
          ],
        ),
      ),
      child: Column(
        children: [
          // Page dots with labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                final isActive = currentPage == index;
                return GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      index,
                      duration: DSAnimation.durationMedium,
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4 * 1.5),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: DSAnimation.durationQuick,
                          width: isActive ? 40 : 32,
                          height: isActive ? 40 : 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? DSColors.accentSecondary
                                : Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: isActive
                                  ? DSColors.accentSecondary
                                      .withValues(alpha: 0.5)
                                  : Colors.white
                                      .withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: DSColors.accentSecondary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white
                                        .withValues(alpha: 0.7),
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: isActive ? 14 : 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pageNames[index],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Swipe hint with animation
          if (currentPage == 0) ...[
            const SizedBox(height: 8),
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
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '좌우로 스와이프하거나 숫자를 탭하세요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
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
}
