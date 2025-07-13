import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/notification/fcm_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  final FCMService _fcmService = FCMService();
  late NotificationSettings _settings;
  bool _isLoading = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _settings = _fcmService.settings;
    _initializeTime();
  }

  void _initializeTime() {
    if (_settings.dailyFortuneTime != null) {
      final parts = _settings.dailyFortuneTime!.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '알림 설정'),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMasterSwitch(),
          const SizedBox(height: 24),
          _buildNotificationCategories(),
          const SizedBox(height: 24),
          _buildDailyFortuneTime(),
          const SizedBox(height: 24),
          _buildTestNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '알림 허용',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '모든 알림을 켜거나 끕니다',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
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
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildNotificationCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '알림 카테고리',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
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
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value && _settings.enabled,
              onChanged: _settings.enabled ? onChanged : null,
              activeColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildDailyFortuneTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일일 운세 시간',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '알림 시간',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '매일 ${_selectedTime.format(context)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _settings.enabled && _settings.dailyFortune
                      ? _selectTime
                      : null,
                  child: const Text('변경'),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().scale(),
      ],
    );
  }

  Widget _buildTestNotificationButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _sendTestNotification,
        icon: const Icon(Icons.notifications_active),
        label: const Text('테스트 알림 보내기'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _settings = NotificationSettings(
          enabled: _settings.enabled,
          dailyFortune: _settings.dailyFortune,
          tokenAlert: _settings.tokenAlert,
          promotion: _settings.promotion,
          dailyFortuneTime: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        );
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
          SnackBar(
            content: const Text('알림 설정이 저장되었습니다'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('알림 설정 저장 실패', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('설정 저장에 실패했습니다'),
            backgroundColor: AppColors.error,
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
          SnackBar(
            content: const Text('테스트 알림을 전송했습니다'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('테스트 알림 전송 실패', error: e);
    }
  }
}