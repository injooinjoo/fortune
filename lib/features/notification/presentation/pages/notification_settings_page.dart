import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/notification/fcm_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/theme/toss_design_system.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  late final FCMService _fcmService;
  late NotificationSettings _settings;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isLoading = false;

  // TOSS Design System Helper Methods
  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark50
        : TossDesignSystem.gray50;
  }

  Color _getCardColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark100
        : TossDesignSystem.white;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }

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
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: _getTextColor(context),
        ),
        title: Text(
          '알림 설정',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: TossDesignSystem.marginHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TossDesignSystem.spacingM),

              _buildMasterSwitch(),
              const SizedBox(height: TossDesignSystem.spacingXL),

              // Notification Categories
              _buildSectionTitle('알림 카테고리'),
              const SizedBox(height: TossDesignSystem.spacingM),
              _buildNotificationCategories(),
              const SizedBox(height: TossDesignSystem.spacingXL),

              // Notification Schedule
              _buildSectionTitle('알림 시간'),
              const SizedBox(height: TossDesignSystem.spacingM),
              _buildNotificationSchedule(),
              const SizedBox(height: TossDesignSystem.spacingXXL),

              _buildTestNotificationButton(),
              const SizedBox(height: TossDesignSystem.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TossDesignSystem.caption.copyWith(
        color: _getSecondaryTextColor(context),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDividerColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: TossDesignSystem.tossBlue,
            size: 22,
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 허용',
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '모든 알림을 켜거나 끕니다',
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
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
            activeColor: TossDesignSystem.tossBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCategories() {
    return Container(
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDividerColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCategoryItem(
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
            icon: Icons.toll,
            title: '토큰 알림',
            subtitle: '토큰이 부족할 때 알려드립니다',
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

  Widget _buildNotificationSchedule() {
    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDividerColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: TossDesignSystem.tossBlue,
            size: 22,
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아침 알림 시간',
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '매일 ${_morningTime.format(context)}',
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
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
              foregroundColor: TossDesignSystem.tossBlue,
            ),
            child: Text(
              '변경',
              style: TossDesignSystem.caption.copyWith(
                color: _settings.enabled && _settings.dailyFortune
                    ? TossDesignSystem.tossBlue
                    : _getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.marginHorizontal,
        vertical: TossDesignSystem.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _getDividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: _getSecondaryTextColor(context),
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value && _settings.enabled,
            onChanged: _settings.enabled ? onChanged : null,
            activeColor: TossDesignSystem.tossBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _sendTestNotification,
        icon: const Icon(Icons.notifications_active),
        label: Text(
          '테스트 알림 보내기',
          style: TossDesignSystem.button.copyWith(
            color: TossDesignSystem.tossBlue,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(vertical: TossDesignSystem.spacingM),
          side: const BorderSide(color: TossDesignSystem.tossBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          ),
          foregroundColor: TossDesignSystem.tossBlue,
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isMorning) async {
    final TimeOfDay initialTime = isMorning ? _morningTime : _eveningTime;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TossDesignSystem.tossBlue,
              secondary: TossDesignSystem.gray600,
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
            dailyFortuneTime: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        } else {
          _eveningTime = picked;
        }
      });
      _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      await _fcmService.updateSettings(_settings);
      
      // 일일 운세 알림 재설정
      if (_settings.dailyFortune) {
        await _fcmService.scheduleDailyFortuneNotification();
      }
      
      HapticUtils.success();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림 설정이 저장되었습니다'),
            backgroundColor: TossDesignSystem.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('알림 설정 저장 실패', e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설정 저장에 실패했습니다'),
            backgroundColor: TossDesignSystem.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _fcmService.sendTestNotification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('테스트 알림을 전송했습니다'),
            backgroundColor: TossDesignSystem.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('테스트 알림 전송 실패', e);
    }
  }
}