import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../utils/fortune_swipe_helpers.dart';

/// 📊 오늘의 운세 카드 - ChatGPT Pulse 스타일
class OverallCard extends StatefulWidget {
  final int score;
  final String message;
  final String? subtitle;
  final String fullDescription;

  const OverallCard({
    super.key,
    required this.score,
    required this.message,
    this.subtitle,
    required this.fullDescription,
  });

  @override
  State<OverallCard> createState() => _OverallCardState();
}

class _OverallCardState extends State<OverallCard> {
  /// 인사이트 민화 이미지 목록 (6개)
  static const List<Map<String, String>> _overallImages = [
    {
      'image': 'assets/images/minhwa/minhwa_overall_tiger.webp',
      'emoji': '🐅',
      'label': '호랑이 민화'
    },
    {
      'image': 'assets/images/minhwa/minhwa_overall_dragon.webp',
      'emoji': '🐉',
      'label': '용 민화'
    },
    {
      'image': 'assets/images/minhwa/minhwa_overall_moon.webp',
      'emoji': '🌕',
      'label': '보름달 민화'
    },
    {
      'image': 'assets/images/minhwa/minhwa_overall_phoenix.webp',
      'emoji': '🦅',
      'label': '봉황 민화'
    },
    {
      'image': 'assets/images/minhwa/minhwa_overall_sunrise.webp',
      'emoji': '🌅',
      'label': '일출 민화'
    },
    {
      'image': 'assets/images/minhwa/minhwa_overall_turtle.webp',
      'emoji': '🐢',
      'label': '거북이 민화'
    },
  ];

  /// 오늘 날짜 기반 이미지 선택 (하루 동안 일관성 유지)
  Map<String, String> _getTodayImage() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _overallImages.length;
    return _overallImages[index];
  }

  /// 텍스트 확장 모달 표시
  void _showExpandedModal(BuildContext context, Color scoreColor) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      barrierColor: DSColors.overlay,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: a1, child: child),
        );
      },
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // 다크모드에서 더 밝은 배경으로 가독성 개선
              color: context.isDark
                  ? DSColors.surfaceSecondary
                  : context.colors.surface, // 다크 모달 배경
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 (사자성어 + 닫기 버튼)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        style: ctx.heading4.copyWith(
                          color: ctx.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(
                        Icons.close,
                        color:
                            context.colors.textPrimary.withValues(alpha: 0.72),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: scoreColor.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: 16),
                // 스크롤 가능한 전체 텍스트
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      widget.fullDescription,
                      style: ctx.bodyMedium.copyWith(
                        color:
                            context.colors.textPrimary.withValues(alpha: 0.8),
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = FortuneSwipeHelpers.getPulseScoreColor(widget.score);
    final minhwaInfo = _getTodayImage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 민화 이미지 (날짜별 랜덤)
        Container(
          height: 180,
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
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          minhwaInfo['label']!,
                          style: context.labelMedium.copyWith(
                            color: context.colors.textPrimary
                                .withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).scale(
            begin: const Offset(0.95, 0.95),
            duration: 600.ms,
            curve: Curves.easeOut),

        // 헤더 (카드 제목 - category_detail_card와 통일)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🌟',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Text(
              '오늘의 운세',
              style: context.heading3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: DSSpacing.md),

        // 카드 컨테이너 (Pulse 스타일 - 흰색 배경 + 그림자)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 점수 - 크고 임팩트 있는 숫자 + "점" 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.score}',
                    style: context.displayLarge.copyWith(
                      fontSize: 72, // 예외: 초대형 숫자
                      color: scoreColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '점',
                    style: context.bodyLarge.copyWith(
                      color: context.colors.textPrimary.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 500.ms,
                  curve: Curves.easeOut),

              const SizedBox(height: DSSpacing.md),

              // 프로그레스 바 (얇고 심플)
              Stack(
                children: [
                  // 배경 바
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  // 진행 바 (단색)
                  FractionallySizedBox(
                    widthFactor: widget.score / 100,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ).animate().scaleX(
                          begin: 0,
                          duration: 1000.ms,
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                        ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),

        const SizedBox(height: 12),

        // 사자성어 카드 (제목만)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.message,
              style: context.heading4.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(
            begin: 0.06,
            duration: 500.ms,
            delay: 300.ms,
            curve: Curves.easeOut),

        const SizedBox(height: 10),

        // 300자 상세 설명 카드 (탭하면 중앙 모달로 확장)
        GestureDetector(
          onTap: () => _showExpandedModal(context, scoreColor),
          child: Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  widget.fullDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall.copyWith(
                    color: context.colors.textPrimary.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                // 확장 힌트
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '탭하여 자세히 보기',
                        style: context.labelSmall.copyWith(
                          color: scoreColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: scoreColor.withValues(alpha: 0.6),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(
            begin: 0.06,
            duration: 500.ms,
            delay: 400.ms,
            curve: Curves.easeOut),
      ],
    );
  }
}
