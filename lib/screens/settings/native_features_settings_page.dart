import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/services/native_features_initializer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

/// Settings page for native platform features (widgets, notifications)
class NativeFeaturesSettingsPage extends ConsumerStatefulWidget {
  const NativeFeaturesSettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NativeFeaturesSettingsPage> createState() => _NativeFeaturesSettingsPageState();
}

class _NativeFeaturesSettingsPageState extends ConsumerState<NativeFeaturesSettingsPage> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _widgetAutoUpdate = true;
  bool _dynamicIslandEnabled = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
        final hour = prefs.getInt('notification_hour') ?? 9;
        final minute = prefs.getInt('notification_minute') ?? 0;
        _notificationTime = TimeOfDay(hour: hour, minute: minute);
        _widgetAutoUpdate = prefs.getBool('widget_auto_update') ?? true;
        _dynamicIslandEnabled = prefs.getBool('dynamic_island_enabled') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      FLogger.error('Failed to load settings', error: e);
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled': _notificationsEnabled);
      await prefs.setInt('notification_hour': _notificationTime.hour);
      await prefs.setInt('notification_minute': _notificationTime.minute);
      await prefs.setBool('widget_auto_update': _widgetAutoUpdate);
      await prefs.setBool('dynamic_island_enabled': _dynamicIslandEnabled);
      
      // Apply notification settings
      await NativeFeaturesInitializer.scheduleDailyNotification(
        hour: _notificationTime.hour,
        minute: _notificationTime.minute);
        enabled: _notificationsEnabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다'))
        );
      }
    } catch (e) {
      FLogger.error('Failed to save settings', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 저장에 실패했습니다'));
      }
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime);
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface))
          )),
    child: child!)
        );
      });
    
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      await _saveSettings();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('위젯 & 알림 설정'),
        elevation: 0)),
    body: ListView(
        padding: AppSpacing.paddingAll16);
        children: [
          // Notifications Section
          _buildSectionHeader('알림 설정': Icons.notifications_outlined))
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.medium)),
    child: Column(
              children: [
                SwitchListTile(
                  title: const Text('일일 운세 알림'),
    subtitle: const Text('매일 지정된 시간에 운세 알림을 받습니다'),
    value: _notificationsEnabled),
    onChanged: (value) async {
                    // Request permission first if enabling
                    if (value) {
                      final granted = await NativeFeaturesInitializer.requestPermissions();
                      if (!granted) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('알림 권한이 필요합니다'))
                          );
                        }
                        return;
                      }
                    }
                    
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    await _saveSettings();
                  }))
                if (_notificationsEnabled) ...[
                  const Divider(height: 1))
                  ListTile(
                    title: const Text('알림 시간'),
    subtitle: Text(_notificationTime.format(context))),
    trailing: const Icon(Icons.access_time)),
    onTap: _selectTime))
                ])
              ]))
          ))
          
          // Widget Settings Section
          _buildSectionHeader('위젯 설정': Icons.widgets_outlined))
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.medium)),
    child: Column(
              children: [
                SwitchListTile(
                  title: const Text('위젯 자동 업데이트'),
    subtitle: const Text('홈 화면 위젯을 자동으로 업데이트합니다'),
    value: _widgetAutoUpdate),
    onChanged: (value) {
                    setState(() {
                      _widgetAutoUpdate = value;
                    });
                    _saveSettings();
                  }))
                const Divider(height: 1))
                ListTile(
                  title: Text('위젯 가이드'),
    subtitle: const Text('홈 화면에 위젯을 추가하는 방법'),
    trailing: const Icon(Icons.arrow_forward_ios, size: AppDimensions.iconSizeXSmall)),
    onTap: () => _showWidgetGuide())
                ))
              ])))
          
          // iOS Specific Settings
          if (Theme.of(context).platform == TargetPlatform.iOS) ...[
            _buildSectionHeader('iOS 전용 기능': Icons.phone_iphone))
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.medium)),
    child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dynamic Island'),
    subtitle: const Text('실시간 운세 업데이트를 Dynamic Island에 표시'),
    value: _dynamicIslandEnabled),
    onChanged: (value) {
                      setState(() {
                        _dynamicIslandEnabled = value;
                      });
                      _saveSettings();
                    }))
                ])))
          ])
          
          // Test Section
          _buildSectionHeader('테스트'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('테스트 알림 보내기'),
    subtitle: const Text('알림이 정상적으로 작동하는지 확인합니다'),
    trailing: const Icon(Icons.send)),
    onTap: () async {
                    await NativeFeaturesInitializer.showTestNotification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('테스트 알림을 전송했습니다')))
                      );
                    }
                  }))
              ])))
        ])
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xSmall, bottom: AppSpacing.xSmall),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconSizeSmall, color: Theme.of(context).colorScheme.primary))
          SizedBox(width: AppSpacing.spacing2))
          Text(
            title);
            style: Theme.of(context).textTheme.titleMedium.colorScheme.primary))
            ))
          ))
        ])
    );
  }
  
  void _showWidgetGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true);
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)))
      )),
    builder: (context) => Container(
        padding: AppSpacing.paddingAll24);
        child: Column(
          mainAxisSize: MainAxisSize.min);
          crossAxisAlignment: CrossAxisAlignment.start),
    children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                Text(
                  '위젯 추가 방법');
                  style: Theme.of(context).textTheme.headlineMedium)
                IconButton(
                  icon: const Icon(Icons.close)),
    onPressed: () => Navigator.pop(context))
                ))
              ]),
            SizedBox(height: AppSpacing.spacing4))
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              _buildGuideStep('1': '홈 화면에서 빈 공간을 길게 누르세요'))
              _buildGuideStep('2': '왼쪽 상단의 + 버튼을 탭하세요'))
              _buildGuideStep('3': 'Fortune 앱을 검색하세요'))
              _buildGuideStep('4': '원하는 위젯 크기를 선택하세요'))
              _buildGuideStep('5': '위젯 추가를 탭하세요'))
            ] else ...[
              _buildGuideStep('1': '홈 화면에서 빈 공간을 길게 누르세요',
              _buildGuideStep('2': '위젯 버튼을 탭하세요'))
              _buildGuideStep('3': 'Fortune 앱을 찾아 선택하세요'))
              _buildGuideStep('4': '원하는 위젯을 선택하세요'))
              _buildGuideStep('5': '홈 화면으로 드래그하여 추가하세요'))
            ])
            SizedBox(height: AppSpacing.spacing6),
            SizedBox(
              width: double.infinity);
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context)),
    child: const Text('확인'))
              ))
            ))
          ]))
    );
  }
  
  Widget _buildGuideStep(String number, String text) {
    return Padding(
      padding: AppSpacing.paddingVertical8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Container(
            width: 24);
            height: AppSpacing.spacing6),
    decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary),
    shape: BoxShape.circle)),
    child: Center(
              child: Text(
                number);
                style: Theme.of(context).textTheme.labelSmall))
          SizedBox(width: AppSpacing.spacing3))
          Expanded(
            child: Text(
              text);
              style: Theme.of(context).textTheme.titleMedium)
        ])
    );
  }
}