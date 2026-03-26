import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/notification/fcm_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/paper_runtime_surface_kit.dart';

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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PaperRuntimeAppBar(title: '알림 설정'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.pageHorizontal,
            DSSpacing.md,
            DSSpacing.pageHorizontal,
            DSSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryItem(
                context,
                title: '일일 운세 알림',
                subtitle: '매일 아침 오늘의 운세를 알려드려요',
                value: _settings.enabled && _settings.dailyFortune,
                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (value && !_settings.enabled) {
                    final granted =
                        await _fcmService.requestPermissionsIfNeeded();
                    if (!mounted) return;
                    if (!granted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('알림 권한이 허용되지 않았습니다. 설정 앱에서 변경할 수 있어요.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _settings = _settings.copyWith(
                        enabled: true,
                        dailyFortune: value,
                      );
                    });
                  } else {
                    setState(() {
                      _settings = _settings.copyWith(dailyFortune: value);
                    });
                  }
                  await _saveSettings();
                },
                showDivider: true,
              ),
              _buildCategoryItem(
                context,
                title: '캐릭터 메시지',
                subtitle: '캐릭터가 새 메시지를 보냈을 때',
                value: _settings.enabled && _settings.characterDm,
                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (value && !_settings.enabled) {
                    final granted =
                        await _fcmService.requestPermissionsIfNeeded();
                    if (!mounted) return;
                    if (!granted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('알림 권한이 허용되지 않았습니다. 설정 앱에서 변경할 수 있어요.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _settings = _settings.copyWith(
                        enabled: true,
                        characterDm: value,
                      );
                    });
                  } else {
                    setState(() {
                      _settings = _settings.copyWith(characterDm: value);
                    });
                  }
                  await _saveSettings();
                },
                showDivider: true,
              ),
              _buildCategoryItem(
                context,
                title: '이벤트 및 프로모션',
                subtitle: '특별 이벤트와 할인 정보',
                value: _settings.enabled && _settings.promotion,
                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (value && !_settings.enabled) {
                    final granted =
                        await _fcmService.requestPermissionsIfNeeded();
                    if (!mounted) return;
                    if (!granted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('알림 권한이 허용되지 않았습니다. 설정 앱에서 변경할 수 있어요.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _settings = _settings.copyWith(
                        enabled: true,
                        promotion: value,
                      );
                    });
                  } else {
                    setState(() {
                      _settings = _settings.copyWith(promotion: value);
                    });
                  }
                  await _saveSettings();
                },
                showDivider: true,
              ),
              _buildCategoryItem(
                context,
                title: '토큰 알림',
                subtitle: '토큰이 부족할 때 알려드려요',
                value: _settings.enabled && _settings.tokenAlert,
                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (value && !_settings.enabled) {
                    final granted =
                        await _fcmService.requestPermissionsIfNeeded();
                    if (!mounted) return;
                    if (!granted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('알림 권한이 허용되지 않았습니다. 설정 앱에서 변경할 수 있어요.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _settings = _settings.copyWith(
                        enabled: true,
                        tokenAlert: value,
                      );
                    });
                  } else {
                    setState(() {
                      _settings = _settings.copyWith(tokenAlert: value);
                    });
                  }
                  await _saveSettings();
                },
              ),
              const SizedBox(height: DSSpacing.lg),
              Divider(
                height: 1,
                thickness: 1,
                color: colors.border.withValues(alpha: 0.72),
              ),
              const SizedBox(height: DSSpacing.sm),
              PaperRuntimeMenuTile(
                title: '아침 알림 시간',
                subtitle: '매일 ${_morningTime.format(context)}',
                onTap: _settings.enabled && _settings.dailyFortune
                    ? () => _selectTime(true)
                    : null,
              ),
              const SizedBox(height: DSSpacing.lg),
              _buildTestNotificationButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
    bool showDivider = false,
  }) {
    return PaperRuntimeToggleTile(
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
      showDivider: showDivider || !isLast,
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
          _settings = _settings.copyWith(
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
      final granted = await _fcmService.requestPermissionsIfNeeded();
      if (!granted) {
        throw Exception('notification_permission_denied');
      }

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
