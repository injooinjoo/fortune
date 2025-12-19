import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';

/// 오늘의 운세 섹션 - 한국 전통 스타일
///
/// HanjiCard elevated 스타일과 오방색을 사용합니다.
class DailyFortuneSection extends StatelessWidget {
  final DailyFortune dailyFortune;

  const DailyFortuneSection({
    super.key,
    required this.dailyFortune,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HanjiCard(
      style: HanjiCardStyle.elevated,
      colorScheme: HanjiColorScheme.fortune,
      showSealStamp: true,
      sealText: '運',
      sealSize: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '今',
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: DSFortuneColors.getGold(isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '오늘의 운세',
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: DSFortuneColors.getInk(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 행운 색상 + 행운 숫자
          Row(
            children: [
              // 행운 색상
              Expanded(
                child: _FortuneInfoCard(
                  title: '행운의 색',
                  content: dailyFortune.luckyColor,
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _parseColor(dailyFortune.luckyColor),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // 행운 숫자
              Expanded(
                child: _FortuneInfoCard(
                  title: '행운 번호',
                  content: '${dailyFortune.luckyNumber}',
                  leading: const Text(
                    '🎯',
                    style: TextStyle(fontSize: 20),
                  ),
                  isDark: isDark,
                  isHighlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 에너지 레벨
          _EnergyLevelBar(
            energyLevel: dailyFortune.energyLevel,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 추천 활동
          _FortuneDetailRow(
            icon: '💡',
            title: '추천 활동',
            content: dailyFortune.recommendedActivity,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 주의사항
          _FortuneDetailRow(
            icon: '⚠️',
            title: '주의사항',
            content: dailyFortune.caution,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 베스트 매치
          _FortuneDetailRow(
            icon: '💕',
            title: '오늘의 베스트 매치',
            content: dailyFortune.bestMatchToday,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorName) {
    final colorMap = {
      '로즈 골드': const Color(0xFFB76E79),
      '코랄 핑크': const Color(0xFFFF6F61),
      '민트 그린': const Color(0xFF98D8C8),
      '라벤더': const Color(0xFFE6E6FA),
      '스카이 블루': const Color(0xFF87CEEB),
      '페일 옐로우': const Color(0xFFFFFACD),
      '피치': const Color(0xFFFFDAB9),
      '라일락': const Color(0xFFC8A2C8),
      '베이비 블루': const Color(0xFF89CFF0),
      '아이보리': const Color(0xFFFFFFF0),
      '세이지 그린': const Color(0xFF9DC183),
      '샴페인': const Color(0xFFF7E7CE),
    };
    return colorMap[colorName] ?? const Color(0xFFD4AF37);
  }
}

/// 운세 정보 카드
class _FortuneInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Widget leading;
  final bool isDark;
  final bool isHighlight;

  const _FortuneInfoCard({
    required this.title,
    required this.content,
    required this.leading,
    required this.isDark,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight
            ? DSFortuneColors.getGold(isDark).withValues(alpha: isDark ? 0.15 : 0.1)
            : DSFortuneColors.getInk(isDark).withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight
              ? DSFortuneColors.getGold(isDark).withValues(alpha: 0.3)
              : DSFortuneColors.getInk(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'GowunBatang',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isHighlight
                        ? DSFortuneColors.getGold(isDark)
                        : DSFortuneColors.getInk(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 에너지 레벨 바
class _EnergyLevelBar extends StatelessWidget {
  final int energyLevel;
  final bool isDark;

  const _EnergyLevelBar({
    required this.energyLevel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSFortuneColors.getInk(isDark).withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 에너지',
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: 14,
                  color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.7),
                ),
              ),
              Text(
                '$energyLevel%',
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DSFortuneColors.getGold(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: energyLevel / 100,
              minHeight: 8,
              backgroundColor: DSFortuneColors.getInk(isDark).withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                DSFortuneColors.getGold(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 운세 상세 행
class _FortuneDetailRow extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final bool isDark;

  const _FortuneDetailRow({
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'GowunBatang',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: DSFortuneColors.getInk(isDark),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
