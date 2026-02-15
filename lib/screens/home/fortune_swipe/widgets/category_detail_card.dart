import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../utils/fortune_swipe_helpers.dart';

/// ❤️ 카테고리 상세 카드 (연애/금전/직장/학업/건강)
class CategoryDetailCard extends StatelessWidget {
  final String title;
  final String categoryKey;
  final int score;
  final String advice;

  const CategoryDetailCard({
    super.key,
    required this.title,
    required this.categoryKey,
    required this.score,
    required this.advice,
  });

  /// 카테고리별 민화 이미지 목록 (각 4개씩)
  static const Map<String, List<Map<String, String>>> _categoryImages = {
    'love': [
      {
        'image': 'assets/images/minhwa/minhwa_love_mandarin.webp',
        'emoji': '🦆',
        'label': '원앙 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_love_butterfly.webp',
        'emoji': '🦋',
        'label': '나비 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_love_magpie_bridge.webp',
        'emoji': '🌉',
        'label': '오작교 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_love_peony.webp',
        'emoji': '🌺',
        'label': '모란 민화'
      },
    ],
    'money': [
      {
        'image': 'assets/images/minhwa/minhwa_money_carp.webp',
        'emoji': '🐟',
        'label': '잉어 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_money_pig.webp',
        'emoji': '🐷',
        'label': '돼지 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_money_toad.webp',
        'emoji': '🐸',
        'label': '두꺼비 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_money_treasure.webp',
        'emoji': '💰',
        'label': '보물 민화'
      },
    ],
    'work': [
      {
        'image': 'assets/images/minhwa/minhwa_work_crane.webp',
        'emoji': '🦢',
        'label': '학 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_work_bamboo.webp',
        'emoji': '🎋',
        'label': '대나무 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_work_eagle.webp',
        'emoji': '🦅',
        'label': '독수리 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_work_waterfall.webp',
        'emoji': '🌊',
        'label': '폭포 민화'
      },
    ],
    'study': [
      {
        'image': 'assets/images/minhwa/minhwa_study_magpie.webp',
        'emoji': '🐦',
        'label': '까치 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_study_brush.webp',
        'emoji': '🖌️',
        'label': '문방사우 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_study_owl.webp',
        'emoji': '🦉',
        'label': '부엉이 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_study_plum.webp',
        'emoji': '🌸',
        'label': '매화 민화'
      },
    ],
    'health': [
      {
        'image': 'assets/images/minhwa/minhwa_health_deer.webp',
        'emoji': '🦌',
        'label': '사슴 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_health_crane_turtle.webp',
        'emoji': '🐢',
        'label': '학과 거북 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_health_mountain.webp',
        'emoji': '⛰️',
        'label': '산수 민화'
      },
      {
        'image': 'assets/images/minhwa/minhwa_health_pine.webp',
        'emoji': '🌲',
        'label': '소나무 민화'
      },
    ],
  };

  /// 오늘 날짜 기반 이미지 선택 (하루 동안 일관성 유지)
  Map<String, String> _getMinhwaInfo() {
    final images = _categoryImages[categoryKey];
    if (images == null || images.isEmpty) {
      return {'image': '', 'emoji': '🎨', 'label': '민화'};
    }
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % images.length;
    return images[index];
  }

  @override
  Widget build(BuildContext context) {
    final emoji = FortuneSwipeHelpers.getCategoryEmoji(categoryKey);
    final scoreColor = FortuneSwipeHelpers.getPulseScoreColor(score);
    final minhwaInfo = _getMinhwaInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 민화 이미지
        Container(
          height: 120,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.isDark
                ? DSColors.surface
                : DSColors.backgroundSecondaryDark,
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
                      colors: context.isDark
                          ? [
                              DSColors.surfaceSecondary,
                              DSColors.surface
                            ] // 고유 색상(dark gradient start)
                          : [
                              DSColors.backgroundSecondaryDark,
                              const Color(0xFFEDE8DC)
                            ], // 고유 색상(light gradient end)
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
                            color: context.colors.textPrimary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
            begin: const Offset(0.95, 0.95),
            duration: 500.ms,
            curve: Curves.easeOut),

        // 헤더 (가운데 정렬)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: context.heading3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 카드 (Pulse 스타일)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 점수 표시 - 크고 임팩트 있게
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: context.displayMedium.copyWith(
                      fontSize: 48, // 카테고리별 점수
                      color: scoreColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '점',
                    style: context.bodyMedium.copyWith(
                      color: context.colors.textPrimary.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 프로그레스 바
              Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: score / 100,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate().scaleX(
                        begin: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerLeft),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 조언 텍스트
              Text(
                advice,
                style: context.bodySmall.copyWith(
                  color: context.colors.textPrimary.withValues(alpha: 0.7),
                  height: 1.7,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }
}
