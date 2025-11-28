import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: TossDesignSystem.purple,
          ),
          const SizedBox(height: 16),
          Text(
            '전체 해석을 생성하고 있습니다...',
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
