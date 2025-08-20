import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/notification/fcm_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  final FCMService _fcmService = FCMService();
  late NotificationSettings _settings;
  bool _isLoading = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);

  // Fortune types for selective notifications
  final Map<String, bool> _fortuneTypeNotifications = {
    'daily': true,
    'love': false,
    'career': false,
    'wealth': false,
    'health': false,
    'lucky': true,
  };

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom header with back button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '알림 설정',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMasterSwitch(),
                  const SizedBox(height: 24),
                  
                  // Notification Methods Section
                  _buildSectionTitle('알림 방법'),
                  const SizedBox(height: 12),
                  _buildNotificationMethods(),
                  const SizedBox(height: 24),
                  
                  // Notification Categories
                  _buildSectionTitle('알림 카테고리'),
                  const SizedBox(height: 12),
                  _buildNotificationCategories(),
                  const SizedBox(height: 24),
                  
                  // Fortune Type Notifications
                  _buildSectionTitle('운세별 알림'),
                  const SizedBox(height: 12),
                  _buildFortuneTypeNotifications(),
                  const SizedBox(height: 24),
                  
                  // Notification Schedule
                  _buildSectionTitle('알림 시간'),
                  const SizedBox(height: 12),
                  _buildNotificationSchedule(),
                  const SizedBox(height: 24),
                  
                  // Frequency Settings
                  _buildSectionTitle('알림 빈도'),
                  const SizedBox(height: 12),
                  _buildFrequencySettings(),
                  const SizedBox(height: 32),
                  
                  _buildTestNotificationButton(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildMasterSwitch() {
    final theme = Theme.of(context);
    
    return GlassContainer(
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
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 허용',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '모든 알림을 켜거나 끕니다',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    ).animate().fadeIn().scale();
  }

  Widget _buildNotificationMethods() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.phone_android, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '푸시 알림',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _settings.enabled,
                onChanged: _settings.enabled ? (value) {
                  // Handle push notification toggle
                } : null,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.sms, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '문자 알림',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '프리미엄 회원 전용',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: false,
                onChanged: null,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.email, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '이메일 알림',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: false,
                onChanged: _settings.enabled ? (value) {
                  // Handle email notification toggle
                } : null,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCategories() {
    return Column(
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        _buildCategoryItem(
          icon: Icons.cake,
          title: '생일 운세',
          subtitle: '생일날 특별한 운세를 받아보세요',
          value: true,
          onChanged: (value) {
            // Handle birthday fortune toggle
          },
        ),
      ],
    );
  }

  Widget _buildFortuneTypeNotifications() {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관심있는 운세만 알림받기',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFortuneChip('일일 운세', 'daily'),
              _buildFortuneChip('연애 운세', 'love'),
              _buildFortuneChip('직업 운세', 'career'),
              _buildFortuneChip('재물 운세', 'wealth'),
              _buildFortuneChip('건강 운세', 'health'),
              _buildFortuneChip('행운 운세', 'lucky'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneChip(String label, String key) {
    final theme = Theme.of(context);
    final isSelected = _fortuneTypeNotifications[key] ?? false;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: _settings.enabled ? (value) {
        setState(() {
          _fortuneTypeNotifications[key] = value;
        });
      } : null,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildNotificationSchedule() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아침 알림',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '매일 ${_morningTime.format(context)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _settings.enabled && _settings.dailyFortune
                    ? () => _selectTime(true)
                    : null,
                child: const Text('변경'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '저녁 알림',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '매일 ${_eveningTime.format(context)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: false,
                    onChanged: _settings.enabled ? (value) {} : null,
                    activeColor: AppColors.primary,
                  ),
                  TextButton(
                    onPressed: null,
                    child: const Text('변경'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySettings() {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '알림 빈도 설정',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFrequencyOption('매일'),
          _buildFrequencyOption('주 3회 (월/수/금)'),
          _buildFrequencyOption('주말만'),
          _buildFrequencyOption('평일만'),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String label) {
    final isSelected = false;
    
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: isSelected ? label : null,
      onChanged: _settings.enabled ? (value) {} : null,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return GlassContainer(
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    ).animate().fadeIn().slideX();
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

  Future<void> _selectTime(bool isMorning) async {
    final TimeOfDay initialTime = isMorning ? _morningTime : _eveningTime;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error('테스트 알림 전송 실패', e);
    }
  }
}