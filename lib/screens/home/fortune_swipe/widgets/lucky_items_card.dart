import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ✨ 행운 아이템 카드 - ChatGPT Pulse 스타일
class LuckyItemsCard extends StatelessWidget {
  final Map<String, String> luckyItems;
  final bool isDark;

  const LuckyItemsCard({
    super.key,
    required this.luckyItems,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '오늘의 행운 아이템',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '오늘 행운을 불러올 아이템들',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // 행운 아이템 그리드 (Pulse 스타일) - LayoutBuilder로 정확한 너비 계산
        LayoutBuilder(
          builder: (context, constraints) {
            // 사용 가능한 전체 너비
            final availableWidth = constraints.maxWidth;
            // 2열 그리드: (전체 너비 - 중간 간격) / 2
            final itemWidth = (availableWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: luckyItems.entries.map((entry) {
                return Container(
                  width: itemWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOut);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
