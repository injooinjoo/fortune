import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// ⏰ 시간대별 조언 카드 - ChatGPT Pulse 스타일
class TimeSlotCard extends StatelessWidget {
  final Map<String, String> timeSlots;
  final bool isDark;

  const TimeSlotCard({
    super.key,
    required this.timeSlots,
    required this.isDark,
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
          style: context.calligraphyTitle.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 하루를 시간대별로 준비하세요',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
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
            isDark: isDark,
            accentColor: const Color(0xFFDAA520), // 고유 색상 - 황금색 (아침 햇살)
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
            isDark: isDark,
            accentColor: const Color(0xFFDC143C), // 고유 색상 - 진홍색 (화기)
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
            isDark: isDark,
            accentColor: const Color(0xFF1E3A5F), // 고유 색상 - 남색 (수기)
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
  final bool isDark;
  final Color accentColor;

  const _TimeSlotItem({
    required this.emoji,
    required this.title,
    required this.advice,
    required this.isActive,
    required this.isDark,
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
              // 다크모드에서 더 밝은 배경으로 가독성 개선
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white, // 고유 색상 - 다크 모달 배경
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: ctx.calligraphySubtitle.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(
                        Icons.close,
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
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
                  style: ctx.calligraphyBody.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.8),
                    fontSize: 15,
                    height: 1.8,
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
    return GestureDetector(
      onTap: () => _showDetailPopup(context),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5)
            : Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이모지 아이콘 (전통 스타일)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? accentColor.withValues(alpha: 0.15)
                  : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? accentColor.withValues(alpha: 0.3)
                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
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
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
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
                        fontSize: 10, // 예외: 초소형 힌트
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
