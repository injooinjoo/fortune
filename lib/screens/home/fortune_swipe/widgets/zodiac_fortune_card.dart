import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../screens/profile/widgets/add_profile_sheet.dart';
import '../utils/fortune_swipe_helpers.dart';

/// 🐉 띠별 운세 카드
class ZodiacFortuneCard extends StatelessWidget {
  final List<Map<String, dynamic>> zodiacFortunes;
  final bool isDark;
  final VoidCallback? onShare; // F03: 공유버튼 콜백

  const ZodiacFortuneCard({
    super.key,
    required this.zodiacFortunes,
    required this.isDark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // F03: 헤더 + 공유버튼
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '띠별 운세',
                    style: context.heading3.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '나와 주변 사람들의 오늘 운세',
                    style: context.bodySmall.copyWith(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // F03: 공유버튼
            if (onShare != null)
              IconButton(
                onPressed: onShare,
                icon: Icon(
                  Icons.share_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 22,
                ),
                tooltip: '띠별 운세 공유',
              ),
          ],
        ),

        const SizedBox(height: 16),

        ...zodiacFortunes.map((fortune) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? DSColors.surface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              // 전통 금색 테두리 (내 띠 강조)
              border: fortune['isUser'] == true
                  ? Border.all(color: const Color(0xFFDAA520).withValues(alpha: 0.5), width: 2) // 고유 색상 - 전통 금색
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
                                '${FortuneSwipeHelpers.getRepresentativeYears(fortune['name'] as String)}년생 ${fortune['name']}띠',
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
                                    // 고유 색상 - 전통 금색 (귀한 것을 상징)
                                    color: const Color(0xFFDAA520),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '내 띠',
                                    style: context.labelTiny.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10, // 예외: 초소형 배지
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
                        style: context.labelSmall.copyWith(
                          color: FortuneSwipeHelpers.getZodiacScoreColor(fortune['score'] as int),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // U08: 점수 시각화 바 추가 - 가독성 개선
                _buildScoreBar(fortune['score'] as int),
                const SizedBox(height: 10),
                Text(
                  fortune['description'] as String,
                  style: context.labelTiny.copyWith(
                    color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black.withValues(alpha: 0.87),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        )),

        // F01: 멀티프로필 추가 버튼
        const SizedBox(height: 12),
        _buildAddProfileButton(context),
      ],
    );
  }

  /// U08: 점수 시각화 바 - 가독성 개선
  Widget _buildScoreBar(int score) {
    final scoreColor = FortuneSwipeHelpers.getZodiacScoreColor(score);
    final percentage = score / 100.0;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 채워진 부분
              Container(
                width: constraints.maxWidth * percentage,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scoreColor.withValues(alpha: 0.7),
                      scoreColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// F01: 멀티프로필 추가 유도 버튼
  Widget _buildAddProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: DSColors.overlay,
          builder: (_) => const AddProfileSheet(
            title: '가족/친구 추가',
            subtitle: '소중한 사람의 띠별 운세도 함께 확인하세요',
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : DSFortuneColors.hanjiCream, // 고유 색상(dark) + hanjiCream(light)
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFDAA520).withValues(alpha: 0.3), // 고유 색상 - 전통 금색
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFDAA520).withValues(alpha: 0.15), // 고유 색상 - 전통 금색
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_add_outlined,
                color: Color(0xFFDAA520), // 고유 색상 - 전통 금색
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '가족/친구 추가하기',
                    style: context.labelMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '소중한 사람의 운세도 한눈에 확인하세요',
                    style: context.labelTiny.copyWith(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
