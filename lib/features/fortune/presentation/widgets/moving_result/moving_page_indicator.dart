import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 페이지 인디케이터
class MovingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const MovingPageIndicator({
    super.key,
    required this.currentPage,
    this.totalPages = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final isActive = currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? DSColors.accent : DSColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
