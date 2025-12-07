import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/services/unified_calendar_service.dart';

/// 디바이스 이벤트 아이템 위젯
class DeviceEventItem extends StatelessWidget {
  final CalendarEventSummary event;
  final bool isSelected;
  final VoidCallback onTap;

  const DeviceEventItem({
    super.key,
    required this.event,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                : (isDark ? TossDesignSystem.white.withValues(alpha: 0.1) : TossDesignSystem.gray900.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.white.withValues(alpha: 0.24) : TossDesignSystem.gray900.withValues(alpha: 0.12)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark ? TossDesignSystem.white.withValues(alpha: 0.54) : TossDesignSystem.gray900.withValues(alpha: 0.45)),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? TossDesignSystem.textPrimaryDark
                            : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    if (event.startTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.isAllDay
                                ? '종일'
                                : DateFormat('HH:mm', 'ko_KR').format(event.startTime!),
                            style: context.labelMedium.copyWith(
                              color: isDark
                                  ? TossDesignSystem.textSecondaryDark
                                  : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: context.labelMedium.copyWith(
                                color: isDark
                                    ? TossDesignSystem.textSecondaryDark
                                    : TossDesignSystem.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
