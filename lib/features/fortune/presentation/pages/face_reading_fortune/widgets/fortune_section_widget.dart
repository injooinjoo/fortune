import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/fortune_result.dart';

class FortuneSectionWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final int score;
  final Color color;
  final bool isDark;
  final FortuneResult result;
  final String sectionKey;
  final int delay;

  const FortuneSectionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.score,
    required this.color,
    required this.isDark,
    required this.result,
    required this.sectionKey,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 점수 바
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? TossDesignSystem.grayDark300.withValues(alpha: 0.3)
                                  : TossDesignSystem.gray300.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$score점',
                          style: TossDesignSystem.body2.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );

    // 블러가 필요 없거나, 해당 섹션이 블러 대상이 아니면 그대로 반환
    if (!result.isBlurred || !result.blurredSections.contains(sectionKey)) {
      return cardContent.animate().fadeIn(duration: 500.ms, delay: delay.ms).slideY(begin: 0.1);
    }

    // ✅ MBTI 스타일 블러 적용
    return Stack(
      children: [
        // 원본 콘텐츠 (블러 처리)
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: cardContent,
        ),

        // 반투명 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.3),
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // 중앙 잠금 아이콘만 표시
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 40,
              color: (isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight)
                  .withValues(alpha: 0.4),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: TossDesignSystem.tossBlue.withValues(alpha: 0.2)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: delay.ms).slideY(begin: 0.1);
  }
}
