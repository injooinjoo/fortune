import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/obangseok_colors.dart';
import '../../../../core/theme/typography_unified.dart';

/// 관상/전통운세 진입을 위한 강조 카드
///
/// 특징:
/// - 160px 높이 (일반 타일의 2배)
/// - 탭 시 해당 페이지로 라우팅
/// - 다크모드 대응
/// - 이미지 또는 이모지 지원
class FortuneEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? emoji;
  final String? imagePath;
  final String routePath;
  final bool isDark;
  final Color accentColor;

  const FortuneEntryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
    this.imagePath,
    required this.routePath,
    required this.isDark,
    required this.accentColor,
  }) : assert(emoji != null || imagePath != null, 'Either emoji or imagePath must be provided');

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? ObangseokColors.heukLight.withValues(alpha: 0.8)
        : ObangseokColors.misaek;
    final borderColor = isDark
        ? ObangseokColors.baek.withValues(alpha: 0.15)
        : ObangseokColors.meok.withValues(alpha: 0.1);
    final textColor = isDark ? ObangseokColors.baekDark : ObangseokColors.meok;
    final subtitleColor = isDark
        ? ObangseokColors.baekMuted.withValues(alpha: 0.7)
        : ObangseokColors.meokFaded;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(routePath);
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 악센트 컬러 상단 라인
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
            // 컨텐츠
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이미지 또는 이모지
                  if (imagePath != null)
                    Image.asset(
                      imagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8), delay: 100.ms)
                  else
                    Text(
                      emoji!,
                      style: const TextStyle(fontSize: 48),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8), delay: 100.ms),
                  const SizedBox(height: 12),
                  // 제목
                  Text(
                    title,
                    style: context.calligraphyTitle.copyWith(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                  const SizedBox(height: 4),
                  // 부제목
                  Text(
                    subtitle,
                    style: context.bodySmall.copyWith(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                ],
              ),
            ),
            // 화살표 아이콘 (우하단)
            Positioned(
              right: 12,
              bottom: 12,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: subtitleColor,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}
