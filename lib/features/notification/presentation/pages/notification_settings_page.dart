import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/notification/fcm_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/design_system/design_system.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  late final FCMService _fcmService;
  late NotificationSettings _settings;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isSendingTestNotification = false;

  @override
  void initState() {
    super.initState();
    _fcmService = FCMService();
    _settings = _fcmService.settings;
    _initializeSettings();
  }

  void _initializeSettings() {
    if (_settings.dailyFortuneTime != null) {
      final parts = _settings.dailyFortuneTime!.split(':');
      _morningTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: colors.textPrimary,
        ),
        title: Text(
          '알림 설정',
          style: typography.headingMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSSpacing.md),

              _buildMasterSwitch(context),
              const SizedBox(height: DSSpacing.xl),

              // Notification Categories
              _buildSectionTitle(context, '알림 카테고리'),
              const SizedBox(height: DSSpacing.md),
              _buildNotificationCategories(context),
              const SizedBox(height: DSSpacing.xl),

              // Notification Schedule
              _buildSectionTitle(context, '알림 시간'),
              const SizedBox(height: DSSpacing.md),
              _buildNotificationSchedule(context),
              const SizedBox(height: DSSpacing.xxl),

              _buildTestNotificationButton(context),
              const SizedBox(height: DSSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.colors;
    final typography = context.typography;

    return Text(
      title,
      style: typography.labelSmall.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMasterSwitch(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.divider,
          width: 1,
        ),
        boxShadow: context.shadows.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: colors.accent,
            size: 22,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 허용',
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '모든 알림을 켜거나 끕니다',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          DSToggle(
            value: _settings.enabled,
            onChanged: (value) {
              HapticUtils.lightImpact();
              setState(() {
                _settings = NotificationSettings(
                  enabled: value,
                  dailyFortune: _settings.dailyFortune,
                  tokenAlert: _settings.tokenAlert,
                  promotion: _settings.promotion,
                  dailyFortuneTime: _settings.dailyFortuneTime,
                );
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCategories(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.divider,
          width: 1,
        ),
        boxShadow: context.shadows.sm,
      ),
      child: Column(
        children: [
          _buildCategoryItem(
            context,
            icon: Icons.sunny,
            title: '일일 운세',
            subtitle: '매일 아침 오늘의 운세를 알려드립니다',
            value: _settings.dailyFortune,
            onChanged: (value) {
              setState(() {
                _settings = NotificationSettings(
                  enabled: _settings.enabled,
                  dailyFortune: value,
                  tokenAlert: _settings.tokenAlert,
                  promotion: _settings.promotion,
                  dailyFortuneTime: _settings.dailyFortuneTime,
                );
              });
              _saveSettings();
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.toll,
            title: '복주머니 알림',
            subtitle: '복주머니가 부족할 때 알려드립니다',
            value: _settings.tokenAlert,
            onChanged: (value) {
              setState(() {
                _settings = NotificationSettings(
                  enabled: _settings.enabled,
                  dailyFortune: _settings.dailyFortune,
                  tokenAlert: value,
                  promotion: _settings.promotion,
                  dailyFortuneTime: _settings.dailyFortuneTime,
                );
              });
              _saveSettings();
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.local_offer,
            title: '이벤트 및 프로모션',
            subtitle: '특별 이벤트와 할인 소식을 받아보세요',
            value: _settings.promotion,
            onChanged: (value) {
              setState(() {
                _settings = NotificationSettings(
                  enabled: _settings.enabled,
                  dailyFortune: _settings.dailyFortune,
                  tokenAlert: _settings.tokenAlert,
                  promotion: value,
                  dailyFortuneTime: _settings.dailyFortuneTime,
                );
              });
              _saveSettings();
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSchedule(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.divider,
          width: 1,
        ),
        boxShadow: context.shadows.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: colors.accent,
            size: 22,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아침 알림 시간',
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '매일 ${_morningTime.format(context)}',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _settings.enabled && _settings.dailyFortune
                ? () => _selectTime(true)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: colors.accent,
            ),
            child: Text(
              '변경',
              style: typography.labelSmall.copyWith(
                color: _settings.enabled && _settings.dailyFortune
                    ? colors.accent
                    : colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : colors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: colors.textSecondary,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          DSToggle(
            value: value && _settings.enabled,
            onChanged: _settings.enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isEnabled = _settings.enabled && !_isSendingTestNotification;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isEnabled ? _sendTestNotification : null,
            icon: _isSendingTestNotification
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  )
                : Icon(
                    Icons.notifications_active,
                    color: isEnabled ? colors.accent : colors.textTertiary,
                  ),
            label: Text(
              _isSendingTestNotification ? '전송 중...' : '테스트 알림 보내기',
              style: typography.buttonMedium.copyWith(
                color: isEnabled ? colors.accent : colors.textTertiary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
              side: BorderSide(
                color: isEnabled ? colors.accent : colors.textTertiary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              foregroundColor: colors.accent,
            ),
          ),
        ),
        if (!_settings.enabled)
          Padding(
            padding: const EdgeInsets.only(top: DSSpacing.sm),
            child: Text(
              '알림을 허용하면 테스트 알림을 보낼 수 있습니다',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectTime(bool isMorning) async {
    final TimeOfDay initialTime = isMorning ? _morningTime : _eveningTime;
    final colors = context.colors;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.accent,
              secondary: colors.textSecondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
          _settings = NotificationSettings(
            enabled: _settings.enabled,
            dailyFortune: _settings.dailyFortune,
            tokenAlert: _settings.tokenAlert,
            promotion: _settings.promotion,
            dailyFortuneTime:
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        } else {
          _eveningTime = picked;
        }
      });
      _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    final colors = context.colors;

    try {
      await _fcmService.updateSettings(_settings);

      // 일일 운세 알림 재설정
      if (_settings.dailyFortune) {
        await _fcmService.scheduleDailyFortuneNotification();
      }

      HapticUtils.success();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('알림 설정이 저장되었습니다'),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('알림 설정 저장 실패', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('설정 저장에 실패했습니다'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    final colors = context.colors;

    setState(() {
      _isSendingTestNotification = true;
    });

    HapticUtils.lightImpact();

    try {
      await _fcmService.sendTestNotification();

      HapticUtils.success();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('테스트 알림을 전송했습니다. 알림을 확인해주세요!'),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('테스트 알림 전송 실패', e);

      HapticUtils.error();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('테스트 알림 전송에 실패했습니다. 알림 권한을 확인해주세요.'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingTestNotification = false;
        });
      }
    }
  }
}
