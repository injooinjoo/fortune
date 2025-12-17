import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/utils/hanja_utils.dart';
import '../../../../core/theme/saju_colors.dart';

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
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '당신의 사주가 말하는 오늘',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 16),

        // 사주 기둥 표시
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF7C3AED) : const Color(0xFF9333EA),
                isDark ? const Color(0xFF6D28D9) : const Color(0xFF7C3AED),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SajuPillar(hanjaLabel: '時柱', koreanLabel: '시주', value: sajuData['hour_pillar'] ?? '○○', isDark: isDark),
                  _SajuPillar(hanjaLabel: '日柱', koreanLabel: '일주', value: sajuData['day_pillar'] ?? '○○', isDark: isDark),
                  _SajuPillar(hanjaLabel: '月柱', koreanLabel: '월주', value: sajuData['month_pillar'] ?? '○○', isDark: isDark),
                  _SajuPillar(hanjaLabel: '年柱', koreanLabel: '년주', value: sajuData['year_pillar'] ?? '○○', isDark: isDark),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  FortuneTextCleaner.clean(sajuData['insight']?.toString() ??
                  '당신의 사주는 균형잡힌 에너지를 가지고 있습니다. 오늘은 본래의 성향을 잘 활용하면 좋은 결과를 얻을 수 있습니다.'),
                  style: DSTypography.bodySmall.copyWith(
                    color: Colors.white,
                    height: 1.5,
                    fontSize: 13,
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
  final String hanjaLabel;   // 時柱, 日柱, 月柱, 年柱
  final String koreanLabel;  // 시주, 일주, 월주, 년주
  final String value;        // 갑자, 을축 등
  final bool isDark;

  const _SajuPillar({
    required this.hanjaLabel,
    required this.koreanLabel,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // 한자 변환 (유효한 천간지지인 경우만)
    final hanja = HanjaUtils.toHanja(value);
    final hasHanja = hanja.isNotEmpty;

    // 천간 추출하여 오행 색상 결정
    final stem = value.isNotEmpty ? value[0] : '';
    final element = HanjaUtils.getStemElement(stem) ?? '';
    final elementColor = SajuColors.getStemColor(stem, isDark: isDark);

    return Column(
      children: [
        // 라벨: 한자 + 한글
        Column(
          children: [
            Text(
              hanjaLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              koreanLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 천간지지 박스
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: elementColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 한자 크게 (주)
              if (hasHanja) ...[
                Text(
                  hanja,
                  style: TextStyle(
                    color: elementColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              // 한글 작게 (보조)
              Text(
                value,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 오행 태그
              if (element.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: elementColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    element,
                    style: TextStyle(
                      color: elementColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
