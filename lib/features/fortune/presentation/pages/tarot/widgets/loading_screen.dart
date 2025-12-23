import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '카드를 뽑고 있어요...',
            style: DSTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
