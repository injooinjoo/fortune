import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 캘린더 연동 옵션 다이얼로그
class CalendarOptionsDialog extends StatelessWidget {
  final Future<bool> Function() onDeviceCalendarSelected;
  final VoidCallback onGoogleCalendarSelected;

  const CalendarOptionsDialog({
    super.key,
    required this.onDeviceCalendarSelected,
    required this.onGoogleCalendarSelected,
  });

  static void show(
    BuildContext context, {
    required Future<bool> Function() onDeviceCalendarSelected,
    required VoidCallback onGoogleCalendarSelected,
    required VoidCallback onSyncComplete,
    required VoidCallback onPermissionDenied,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '캘린더 연동 방법 선택',
              style: context.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              '일정을 불러올 캘린더를 선택해주세요',
              style: context.bodyMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // iOS/Android 기본 캘린더
            CalendarOptionTile(
              icon: Icons.phone_iphone,
              iconColor: TossDesignSystem.tossBlue,
              title: 'iOS 기본 캘린더',
              subtitle: '기기에 연동된 모든 캘린더',
              onTap: () async {
                Navigator.pop(context);
                final hasPermission = await onDeviceCalendarSelected();
                if (hasPermission) {
                  onSyncComplete();
                } else {
                  onPermissionDenied();
                }
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Google Calendar
            CalendarOptionTile(
              icon: Icons.calendar_month,
              iconColor: const Color(0xFF4285F4),
              title: 'Google Calendar',
              subtitle: 'Google 계정에서 직접 연동',
              onTap: () {
                Navigator.pop(context);
                onGoogleCalendarSelected();
              },
              isDark: isDark,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '추천',
                  style: context.labelSmall.copyWith(
                    color: const Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// 캘린더 옵션 타일 위젯
class CalendarOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final Widget? trailing;

  const CalendarOptionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? TossDesignSystem.textPrimaryDark
                          : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.bodySmall.copyWith(
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark
                          : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

/// 권한 거부 다이얼로그
class PermissionDeniedDialog extends StatelessWidget {
  const PermissionDeniedDialog({super.key});

  static void show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: TossDesignSystem.errorRed, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '캘린더 접근 권한 필요',
                style: context.heading3,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '일정 기반 맞춤 운세를 보려면 캘린더 접근 권한이 필요합니다.',
                style: context.bodyMedium.copyWith(height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: TossDesignSystem.tossBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Google Calendar 사용하시나요?',
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'iOS에서 Google Calendar를 보려면\n'
                      '먼저 계정을 추가해주세요:',
                      style: context.bodySmall.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    _buildStepItem('설정 앱 열기 → Calendar', isDark, context),
                    _buildStepItem('Accounts → Add Account', isDark, context),
                    _buildStepItem('Google 선택 → 계정 로그인', isDark, context),
                    _buildStepItem('Calendars 동기화 ON', isDark, context),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '그 다음 Fortune 앱 권한을 허용하세요:',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '설정 > 개인정보 보호 > 캘린더 > Fortune',
                style: context.bodySmall.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('설정 열기'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepItem(String text, bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.labelMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
