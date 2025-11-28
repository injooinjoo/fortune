import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class DailyFortuneSection extends StatelessWidget {
  final DailyFortune dailyFortune;

  const DailyFortuneSection({
    super.key,
    required this.dailyFortune,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue,
            isDark ? TossDesignSystem.tossBlueDark.withValues(alpha: 0.7) : TossDesignSystem.tossBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: TossDesignSystem.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '오늘의 운세',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: TossDesignSystem.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 행운 색상
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(dailyFortune.luckyColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: TossDesignSystem.white, width: 2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '행운의 색',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: TossDesignSystem.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      dailyFortune.luckyColor,
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 행운 숫자
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: TossDesignSystem.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      '행운 번호',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: TossDesignSystem.white.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${dailyFortune.luckyNumber}',
                      style: TypographyUnified.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 에너지 레벨 프로그레스 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 에너지',
                    style: TypographyUnified.labelMedium.copyWith(
                      color: TossDesignSystem.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '${dailyFortune.energyLevel}%',
                    style: TypographyUnified.heading4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TossDesignSystem.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: dailyFortune.energyLevel / 100,
                  minHeight: 8,
                  backgroundColor: TossDesignSystem.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 추천 활동
          _FortuneItem(
            icon: Icons.lightbulb_outline,
            title: '추천 활동',
            content: dailyFortune.recommendedActivity,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 주의사항
          _FortuneItem(
            icon: Icons.warning_amber_outlined,
            title: '주의사항',
            content: dailyFortune.caution,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 오늘의 베스트 매치
          _FortuneItem(
            icon: Icons.favorite_outline,
            title: '오늘의 베스트 매치',
            content: dailyFortune.bestMatchToday,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorName) {
    // 색상 이름을 Color로 변환하는 간단한 매핑
    final colorMap = {
      '로즈 골드': Color(0xFFB76E79),
      '코랄 핑크': Color(0xFFFF6F61),
      '민트 그린': Color(0xFF98D8C8),
      '라벤더': Color(0xFFE6E6FA),
      '스카이 블루': Color(0xFF87CEEB),
      '페일 옐로우': Color(0xFFFFFACD),
      '피치': Color(0xFFFFDAB9),
      '라일락': Color(0xFFC8A2C8),
      '베이비 블루': Color(0xFF89CFF0),
      '아이보리': Color(0xFFFFFFF0),
      '세이지 그린': Color(0xFF9DC183),
      '샴페인': Color(0xFFF7E7CE),
    };
    return colorMap[colorName] ?? TossDesignSystem.white;
  }
}

class _FortuneItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;

  const _FortuneItem({
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
        Icon(
          icon,
          color: TossDesignSystem.white,
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TypographyUnified.labelMedium.copyWith(
                  color: TossDesignSystem.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 2),
              Text(
                content,
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: TossDesignSystem.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
