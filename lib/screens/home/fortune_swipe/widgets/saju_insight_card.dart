import 'package:flutter/material.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/utils/hanja_utils.dart';
import '../../../../core/theme/saju_colors.dart';
import '../../../../core/theme/obangseok_colors.dart';

/// 🔮 사주 인사이트 카드
class SajuInsightCard extends StatelessWidget {
  final Map<String, String?> sajuData;
  final bool isDark;

  const SajuInsightCard({
    super.key,
    required this.sajuData,
    required this.isDark,
  });

  /// 사주 민화 이미지 목록 (4개)
  static const List<Map<String, String>> _sajuImages = [
    {'image': 'assets/images/minhwa/minhwa_saju_dragon.png', 'emoji': '🐉', 'label': '용 민화'},
    {'image': 'assets/images/minhwa/minhwa_saju_fourguardians.png', 'emoji': '🏯', 'label': '사신도 민화'},
    {'image': 'assets/images/minhwa/minhwa_saju_tiger_dragon.png', 'emoji': '🐅', 'label': '용호상박 민화'},
    {'image': 'assets/images/minhwa/minhwa_saju_yin_yang.png', 'emoji': '☯️', 'label': '음양 민화'},
  ];

  /// 오늘 날짜 기반 이미지 선택 (하루 동안 일관성 유지)
  Map<String, String> _getTodayImage() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _sajuImages.length;
    return _sajuImages[index];
  }

  @override
  Widget build(BuildContext context) {
    final minhwaInfo = _getTodayImage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주 인사이트',
          style: context.heading3.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '당신의 사주가 말하는 오늘',
          style: context.labelLarge.copyWith(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),

        const SizedBox(height: 16),

        // 민화 이미지 (날짜별 랜덤)
        Container(
          height: 140,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F0E6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              minhwaInfo['image']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                        ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                        : [const Color(0xFFF5F0E6), const Color(0xFFEDE8DC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          minhwaInfo['emoji']!,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          minhwaInfo['label']!,
                          style: context.labelSmall.copyWith(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
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

        // 사주 기둥 표시 - 청색(목/木) 계열: 지혜와 성장 상징
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? ObangseokColors.cheongMuted : ObangseokColors.cheong,
                isDark ? ObangseokColors.cheongDark : ObangseokColors.cheongMuted,
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
                  style: context.labelLarge.copyWith(
                    color: Colors.white,
                    height: 1.5,
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
              style: context.labelMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              koreanLabel,
              style: context.labelTiny.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 9, // 예외: 초소형 텍스트
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
                  style: context.heading3.copyWith(
                    color: elementColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              // 한글 작게 (보조)
              Text(
                value,
                style: context.labelTiny.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
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
                    style: context.labelTiny.copyWith(
                      color: elementColor,
                      fontSize: 9, // 예외: 초소형 태그
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
