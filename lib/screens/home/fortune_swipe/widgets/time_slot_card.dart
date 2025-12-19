import 'package:flutter/material.dart';
import '../../../../core/theme/typography_unified.dart';

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
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
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
            accentColor: const Color(0xFFDAA520), // 황금색 (아침 햇살)
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
            accentColor: const Color(0xFFDC143C), // 진홍색 (화기)
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
            accentColor: const Color(0xFF1E3A5F), // 남색 (수기)
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
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
                  style: context.bodySmall.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                    height: 1.5,
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
