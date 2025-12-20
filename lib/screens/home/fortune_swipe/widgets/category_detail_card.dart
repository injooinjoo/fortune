import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/typography_unified.dart';
import '../utils/fortune_swipe_helpers.dart';

/// ❤️ 카테고리 상세 카드 (연애/금전/직장/학업/건강)
class CategoryDetailCard extends StatelessWidget {
  final String title;
  final String categoryKey;
  final int score;
  final String advice;
  final bool isDark;

  const CategoryDetailCard({
    super.key,
    required this.title,
    required this.categoryKey,
    required this.score,
    required this.advice,
    required this.isDark,
  });

  /// 카테고리별 민화 이미지 목록 (각 4개씩)
  static const Map<String, List<Map<String, String>>> _categoryImages = {
    'love': [
      {'image': 'assets/images/minhwa/minhwa_love_mandarin.png', 'emoji': '🦆', 'label': '원앙 민화'},
      {'image': 'assets/images/minhwa/minhwa_love_butterfly.png', 'emoji': '🦋', 'label': '나비 민화'},
      {'image': 'assets/images/minhwa/minhwa_love_magpie_bridge.png', 'emoji': '🌉', 'label': '오작교 민화'},
      {'image': 'assets/images/minhwa/minhwa_love_peony.png', 'emoji': '🌺', 'label': '모란 민화'},
    ],
    'money': [
      {'image': 'assets/images/minhwa/minhwa_money_carp.png', 'emoji': '🐟', 'label': '잉어 민화'},
      {'image': 'assets/images/minhwa/minhwa_money_pig.png', 'emoji': '🐷', 'label': '돼지 민화'},
      {'image': 'assets/images/minhwa/minhwa_money_toad.png', 'emoji': '🐸', 'label': '두꺼비 민화'},
      {'image': 'assets/images/minhwa/minhwa_money_treasure.png', 'emoji': '💰', 'label': '보물 민화'},
    ],
    'work': [
      {'image': 'assets/images/minhwa/minhwa_work_crane.png', 'emoji': '🦢', 'label': '학 민화'},
      {'image': 'assets/images/minhwa/minhwa_work_bamboo.png', 'emoji': '🎋', 'label': '대나무 민화'},
      {'image': 'assets/images/minhwa/minhwa_work_eagle.png', 'emoji': '🦅', 'label': '독수리 민화'},
      {'image': 'assets/images/minhwa/minhwa_work_waterfall.png', 'emoji': '🌊', 'label': '폭포 민화'},
    ],
    'study': [
      {'image': 'assets/images/minhwa/minhwa_study_magpie.png', 'emoji': '🐦', 'label': '까치 민화'},
      {'image': 'assets/images/minhwa/minhwa_study_brush.png', 'emoji': '🖌️', 'label': '문방사우 민화'},
      {'image': 'assets/images/minhwa/minhwa_study_owl.png', 'emoji': '🦉', 'label': '부엉이 민화'},
      {'image': 'assets/images/minhwa/minhwa_study_plum.png', 'emoji': '🌸', 'label': '매화 민화'},
    ],
    'health': [
      {'image': 'assets/images/minhwa/minhwa_health_deer.png', 'emoji': '🦌', 'label': '사슴 민화'},
      {'image': 'assets/images/minhwa/minhwa_health_crane_turtle.png', 'emoji': '🐢', 'label': '학과 거북 민화'},
      {'image': 'assets/images/minhwa/minhwa_health_mountain.png', 'emoji': '⛰️', 'label': '산수 민화'},
      {'image': 'assets/images/minhwa/minhwa_health_pine.png', 'emoji': '🌲', 'label': '소나무 민화'},
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
        ).animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.95, 0.95), duration: 500.ms, curve: Curves.easeOut),

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
              style: context.calligraphyTitle.copyWith(
                color: isDark ? Colors.white : Colors.black87,
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
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '점',
                    style: context.bodyMedium.copyWith(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
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
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
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
                    ).animate()
                      .scaleX(begin: 0, duration: 800.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 조언 텍스트
              Text(
                advice,
                style: context.calligraphyBody.copyWith(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }
}
