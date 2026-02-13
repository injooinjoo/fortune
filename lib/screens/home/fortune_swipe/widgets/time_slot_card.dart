import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// ⏰ 시간대별 조언 카드 - ChatGPT Pulse 스타일
class TimeSlotCard extends StatelessWidget {
  final Map<String, String> timeSlots;

  const TimeSlotCard({
    super.key,
    required this.timeSlots,
  });

  String get _currentTimeSlot {
    final currentHour = DateTime.now().hour;
    if (currentHour >= 12 && currentHour < 18) {
      return 'afternoon';
    } else if (currentHour >= 18 || currentHour < 6) {
      return 'evening';
    }
    return 'morning';
  }

  @override
  Widget build(BuildContext context) {
    final currentTimeSlot = _currentTimeSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '시간대별 조언',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 하루를 시간대별로 준비하세요',
          style: context.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // 오전
        if (timeSlots['morning']?.isNotEmpty == true)
          _TimeSlotItem(
            emoji: '🌅',
            title: '오전 (6시-12시)',
            advice: timeSlots['morning']!,
            isActive: currentTimeSlot == 'morning',
            accentColor: context.colors.accentTertiary,
          ),

        if (timeSlots['morning']?.isNotEmpty == true &&
            timeSlots['afternoon']?.isNotEmpty == true)
          const SizedBox(height: 10),

        // 오후
        if (timeSlots['afternoon']?.isNotEmpty == true)
          _TimeSlotItem(
            emoji: '☀️',
            title: '오후 (12시-18시)',
            advice: timeSlots['afternoon']!,
            isActive: currentTimeSlot == 'afternoon',
            accentColor: context.colors.accentSecondary,
          ),

        if (timeSlots['afternoon']?.isNotEmpty == true &&
            timeSlots['evening']?.isNotEmpty == true)
          const SizedBox(height: 10),

        // 저녁
        if (timeSlots['evening']?.isNotEmpty == true)
          _TimeSlotItem(
            emoji: '🌕',
            title: '저녁 (18시-자정)',
            advice: timeSlots['evening']!,
            isActive: currentTimeSlot == 'evening',
            accentColor: context.colors.accent,
          ),
      ],
    );
  }
}

class _TimeSlotItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String advice;
  final bool isActive;
  final Color accentColor;

  const _TimeSlotItem({
    required this.emoji,
    required this.title,
    required this.advice,
    required this.isActive,
    required this.accentColor,
  });

  /// 시간대별 조언 상세 팝업 표시
  void _showDetailPopup(BuildContext context) {
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
            width: MediaQuery.of(ctx).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Theme-aware modal surface
              color: ctx.colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 (이모지 + 제목 + 닫기)
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
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
                        color: ctx.colors.textTertiary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: accentColor.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: 20),
                // 전체 조언 텍스트
                Text(
                  advice,
                  style: ctx.bodyMedium.copyWith(
                    color: ctx.colors.textSecondary,
                    height: 1.7,
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
    final colors = context.colors;

    return GestureDetector(
      onTap: () => _showDetailPopup(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: accentColor.withValues(alpha: 0.4), width: 1.5)
              : Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이모지 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor.withValues(alpha: 0.15)
                    : colors.backgroundTertiary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? accentColor.withValues(alpha: 0.3)
                      : colors.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '지금',
                            style: context.labelTiny.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    advice,
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 확장 힌트
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '탭하여 자세히 보기',
                        style: context.labelTiny.copyWith(
                          color: accentColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: accentColor.withValues(alpha: 0.6),
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
