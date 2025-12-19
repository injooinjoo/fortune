import 'package:flutter/material.dart';
import '../../../../core/theme/typography_unified.dart';
import '../utils/fortune_swipe_helpers.dart';

/// 🐉 띠별 운세 카드
class ZodiacFortuneCard extends StatelessWidget {
  final List<Map<String, dynamic>> zodiacFortunes;
  final bool isDark;

  const ZodiacFortuneCard({
    super.key,
    required this.zodiacFortunes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '띠별 운세',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '나와 주변 사람들의 오늘 운세',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        ...zodiacFortunes.map((fortune) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              // 전통 금색 테두리 (내 띠 강조)
              border: fortune['isUser'] == true
                  ? Border.all(color: const Color(0xFFDAA520).withValues(alpha: 0.5), width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fortune['emoji'] as String? ?? '✨',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${fortune['year']}년생 ${fortune['name']}띠',
                                style: context.bodySmall.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (fortune['isUser'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    // 전통 금색 (귀한 것을 상징)
                                    color: const Color(0xFFDAA520),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '내 띠',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FortuneSwipeHelpers.getZodiacScoreColor(fortune['score'] as int).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${fortune['score']}점',
                        style: TextStyle(
                          color: FortuneSwipeHelpers.getZodiacScoreColor(fortune['score'] as int),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  fortune['description'] as String,
                  style: context.bodySmall.copyWith(
                    color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black.withValues(alpha: 0.87),
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
