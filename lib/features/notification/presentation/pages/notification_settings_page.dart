import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/paper_runtime_chrome.dart';
import '../../../../core/widgets/paper_runtime_surface_kit.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/notification/fcm_service.dart';

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
    final isDailyFortuneEnabled = _settings.enabled && _settings.dailyFortune;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PaperRuntimeAppBar(title: '알림 설정'),
      body: PaperRuntimeBackground(
        showRings: false,
        applySafeArea: false,
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.md,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            PaperRuntimePanel(
              padding: EdgeInsets.zero,
              elevated: false,
              child: Column(
                children: [
                  _buildCategoryItem(
                    context,
                    title: '일일 운세 알림',
                    subtitle: '매일 아침 오늘의 운세를 알려드려요',
                    value: _settings.enabled && _settings.dailyFortune,
                    onChanged: (value) =>
                        _updateNotificationSetting(value, 'dailyFortune'),
                    showDivider: true,
                  ),
                  _buildCategoryItem(
                    context,
                    title: '캐릭터 메시지',
                    subtitle: '캐릭터가 새 메시지를 보냈을 때',
                    value: _settings.enabled && _settings.characterDm,
                    onChanged: (value) =>
                        _updateNotificationSetting(value, 'characterDm'),
                    showDivider: true,
                  ),
                  _buildCategoryItem(
                    context,
                    title: '이벤트 및 프로모션',
                    subtitle: '특별 이벤트와 할인 정보를 받습니다',
                    value: _settings.enabled && _settings.promotion,
                    onChanged: (value) =>
                        _updateNotificationSetting(value, 'promotion'),
                    showDivider: true,
                  ),
                  _buildCategoryItem(
                    context,
                    title: '토큰 알림',
                    subtitle: '토큰이 부족할 때 미리 알려드려요',
                    value: _settings.enabled && _settings.tokenAlert,
                    onChanged: (value) =>
                        _updateNotificationSetting(value, 'tokenAlert'),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            PaperRuntimePanel(
              padding: EdgeInsets.zero,
              elevated: false,
              child: PaperRuntimeMenuTile(
                title: '아침 알림 시간',
                subtitle: '일일 운세 알림을 받을 시간을 정합니다',
                onTap: isDailyFortuneEnabled ? _selectMorningTime : null,
                showChevron: false,
                showDivider: false,
                trailing: _TimeChip(
                  label: '매일 ${_morningTime.format(context)}',
                  enabled: isDailyFortuneEnabled,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            PaperRuntimePanel(
              elevated: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _settings.enabled
                        ? '알림 권한이 켜져 있어야 테스트 알림을 바로 확인할 수 있어요.'
                        : '알림 권한이 꺼져 있으면 테스트 알림은 동작하지 않습니다.',
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  PaperRuntimeButton(
                    label:
                        _isSendingTestNotification ? '전송 중...' : '테스트 알림 보내기',
                    onPressed: _settings.enabled && !_isSendingTestNotification
                        ? _sendTestNotification
                        : null,
                    isLoading: _isSendingTestNotification,
                  ),
                ],
              ),
            ),
          ],
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

  Future<void> _updateNotificationSetting(bool value, String field) async {
    final messenger = ScaffoldMessenger.of(context);

    if (value && !_settings.enabled) {
      final granted = await _fcmService.requestPermissionsIfNeeded();
      if (!mounted) {
        return;
      }
      if (!granted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('알림 권한이 허용되지 않았습니다. 설정 앱에서 변경할 수 있어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() {
      _settings = switch (field) {
        'dailyFortune' => _settings.copyWith(
            enabled: value ? true : _settings.enabled,
            dailyFortune: value,
          ),
        'characterDm' => _settings.copyWith(
            enabled: value ? true : _settings.enabled,
            characterDm: value,
          ),
        'promotion' => _settings.copyWith(
            enabled: value ? true : _settings.enabled,
            promotion: value,
          ),
        'tokenAlert' => _settings.copyWith(
            enabled: value ? true : _settings.enabled,
            tokenAlert: value,
          ),
        _ => _settings,
      };
    });

    await _saveSettings();
  }

  Future<void> _selectMorningTime() async {
    final colors = context.colors;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: colors.accent,
              secondary: colors.accent,
              surface: colors.surface,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _morningTime = picked;
        _settings = _settings.copyWith(
          dailyFortuneTime:
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        );
      });
      await _saveSettings();
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

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? colors.surfaceSecondary.withValues(alpha: 0.96)
            : colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: colors.border.withValues(alpha: enabled ? 0.9 : 0.6),
        ),
      ),
      child: Text(
        label,
        style: context.labelMedium.copyWith(
          color: enabled ? colors.textPrimary : colors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
