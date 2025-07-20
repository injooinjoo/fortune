import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../../services/screenshot_detection_service.dart';

/// Provider for screenshot detection preference
final screenshotDetectionEnabledProvider = StateNotifierProvider<ScreenshotDetectionNotifier, bool>((ref) {
  return ScreenshotDetectionNotifier(ref);
});

class ScreenshotDetectionNotifier extends StateNotifier<bool> {
  final Ref ref;
  static const String _prefKey = 'screenshot_detection_enabled';
  
  ScreenshotDetectionNotifier(this.ref) : super(true) {
    _loadPreference();
  }
  
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefKey) ?? true;
  }
  
  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, state);
    
    // Update the service
    final service = ref.read(screenshotDetectionServiceProvider);
    if (state) {
      await service.initialize();
    } else {
      service.dispose();
    }
    
    Logger.info('Screenshot detection ${state ? "enabled" : "disabled"}');
  }
}

class ScreenshotSettingsPage extends ConsumerWidget {
  const ScreenshotSettingsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(screenshotDetectionEnabledProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('스크린샷 설정'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Feature Description Card
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.screenshot_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '스크린샷 감지 기능',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '스크린샷을 찍으면 자동으로 감지하여 더 예쁜 이미지로 공유할 수 있도록 도와드립니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Enable/Disable Toggle
          Card(
            elevation: 0,
            child: SwitchListTile(
              title: const Text('스크린샷 감지 활성화'),
              subtitle: const Text('스크린샷을 찍을 때 공유 옵션 표시'),
              value: isEnabled,
              onChanged: (value) async {
                await ref.read(screenshotDetectionEnabledProvider.notifier).toggle();
              },
              secondary: const Icon(Icons.camera_alt_outlined),
            ),
          ),
          const SizedBox(height: 16),
          
          // Feature Benefits
          if (isEnabled) ...[
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이런 기능이 제공됩니다',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      context,
                      Icons.auto_fix_high,
                      '예쁜 디자인',
                      '앱 로고와 함께 깔끔하게 디자인된 이미지로 저장',
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(
                      context,
                      Icons.share,
                      '쉬운 공유',
                      'SNS나 메신저로 바로 공유 가능',
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(
                      context,
                      Icons.qr_code,
                      'QR 코드',
                      '친구들이 앱을 다운로드할 수 있는 QR 코드 포함',
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Privacy Notice
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '개인정보 보호',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '스크린샷 감지는 기기 내에서만 작동하며, 이미지나 개인 정보는 서버로 전송되지 않습니다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}