import 'package:flutter/material.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';

/// 🔮 사주 인사이트 카드
class SajuInsightCard extends StatelessWidget {
  final Map<String, String?> sajuData;
  final bool isDark;

  const SajuInsightCard({
    super.key,
    required this.sajuData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주 인사이트',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '당신의 사주가 말하는 오늘',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 32),

        // 사주 기둥 표시
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF7C3AED) : const Color(0xFF9333EA),
                isDark ? const Color(0xFF6D28D9) : const Color(0xFF7C3AED),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SajuPillar(label: '시', value: sajuData['hour_pillar'] ?? '○○', color: Colors.white),
                  _SajuPillar(label: '일', value: sajuData['day_pillar'] ?? '○○', color: Colors.white),
                  _SajuPillar(label: '월', value: sajuData['month_pillar'] ?? '○○', color: Colors.white),
                  _SajuPillar(label: '년', value: sajuData['year_pillar'] ?? '○○', color: Colors.white),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  FortuneTextCleaner.clean(sajuData['insight']?.toString() ??
                  '당신의 사주는 균형잡힌 에너지를 가지고 있습니다. 오늘은 본래의 성향을 잘 활용하면 좋은 결과를 얻을 수 있습니다.'),
                  style: TypographyUnified.bodySmall.copyWith(
                    color: Colors.white,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SajuPillar extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SajuPillar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
