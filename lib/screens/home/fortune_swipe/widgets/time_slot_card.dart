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
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 하루를 시간대별로 준비하세요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        // 오전
        if (timeSlots['morning']?.isNotEmpty == true)
          _TimeSlotItem(
            icon: Icons.wb_sunny_rounded,
            title: '오전 (6시-12시)',
            advice: timeSlots['morning']!,
            isActive: currentTimeSlot == 'morning',
            isDark: isDark,
          ),

        if (timeSlots['morning']?.isNotEmpty == true &&
            timeSlots['afternoon']?.isNotEmpty == true)
          const SizedBox(height: 10),

        // 오후
        if (timeSlots['afternoon']?.isNotEmpty == true)
          _TimeSlotItem(
            icon: Icons.wb_cloudy_rounded,
            title: '오후 (12시-18시)',
            advice: timeSlots['afternoon']!,
            isActive: currentTimeSlot == 'afternoon',
            isDark: isDark,
          ),

        if (timeSlots['afternoon']?.isNotEmpty == true &&
            timeSlots['evening']?.isNotEmpty == true)
          const SizedBox(height: 10),

        // 저녁
        if (timeSlots['evening']?.isNotEmpty == true)
          _TimeSlotItem(
            icon: Icons.nightlight_round,
            title: '저녁 (18시-자정)',
            advice: timeSlots['evening']!,
            isActive: currentTimeSlot == 'evening',
            isDark: isDark,
          ),
      ],
    );
  }
}

class _TimeSlotItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String advice;
  final bool isActive;
  final bool isDark;

  const _TimeSlotItem({
    required this.icon,
    required this.title,
    required this.advice,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5)
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
          // 아이콘 (Pulse 스타일)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? accentColor.withValues(alpha: 0.1)
                  : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? accentColor.withValues(alpha: 0.2)
                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? accentColor : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
              size: 20,
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
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Text(
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
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.4,
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
