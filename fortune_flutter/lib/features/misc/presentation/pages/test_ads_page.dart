import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/toast.dart';

// Mock ad types
enum AdType {
  banner,
  interstitial,
  rewarded,
  native,
}

// Ad test configuration
class AdTestConfig {
  final AdType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  bool isTestMode;

  AdTestConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isTestMode = true,
  });
}

// Providers
final testModeProvider = StateProvider<bool>((ref) => true);
final adConfigsProvider = StateProvider<List<AdTestConfig>>((ref) => [
  AdTestConfig(
    type: AdType.banner,
    name: '배너 광고',
    description: '320x50 또는 320x100 크기의 광고',
    icon: Icons.view_agenda_rounded,
    color: const Color(0xFF3B82F6),
  ),
  AdTestConfig(
    type: AdType.interstitial,
    name: '전면 광고',
    description: '전체 화면으로 표시되는 광고',
    icon: Icons.fullscreen_rounded,
    color: const Color(0xFF10B981),
  ),
  AdTestConfig(
    type: AdType.rewarded,
    name: '보상형 광고',
    description: '시청 후 보상을 받는 광고',
    icon: Icons.card_giftcard_rounded,
    color: const Color(0xFFF59E0B),
  ),
  AdTestConfig(
    type: AdType.native,
    name: '네이티브 광고',
    description: '콘텐츠와 자연스럽게 어우러지는 광고',
    icon: Icons.view_list_rounded,
    color: const Color(0xFF8B5CF6),
  ),
]);

class TestAdsPage extends ConsumerStatefulWidget {
  const TestAdsPage({super.key});

  @override
  ConsumerState<TestAdsPage> createState() => _TestAdsPageState();
}

class _TestAdsPageState extends ConsumerState<TestAdsPage> {
  final Map<AdType, int> _impressionCounts = {
    AdType.banner: 0,
    AdType.interstitial: 0,
    AdType.rewarded: 0,
    AdType.native: 0,
  };

  final Map<AdType, int> _clickCounts = {
    AdType.banner: 0,
    AdType.interstitial: 0,
    AdType.rewarded: 0,
    AdType.native: 0,
  };

  void _showAd(AdType type) {
    setState(() {
      _impressionCounts[type] = (_impressionCounts[type] ?? 0) + 1;
    });

    switch (type) {
      case AdType.banner:
        _showBannerAd();
        break;
      case AdType.interstitial:
        _showInterstitialAd();
        break;
      case AdType.rewarded:
        _showRewardedAd();
        break;
      case AdType.native:
        _showNativeAd();
        break;
    }
  }

  void _showBannerAd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 100,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ref.watch(testModeProvider) ? 'TEST BANNER AD' : 'BANNER AD',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _clickCounts[AdType.banner] = (_clickCounts[AdType.banner] ?? 0) + 1;
                  });
                  Navigator.of(context).pop();
                  Toast.show(context, message: '배너 광고 클릭됨', type: ToastType.info);
                },
                child: const Text('Click Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInterstitialAd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.ad_units_rounded,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      ref.watch(testModeProvider) ? 'TEST INTERSTITIAL AD' : 'INTERSTITIAL AD',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _clickCounts[AdType.interstitial] = (_clickCounts[AdType.interstitial] ?? 0) + 1;
                        });
                        Navigator.of(context).pop();
                        Toast.show(context, message: '전면 광고 클릭됨', type: ToastType.info);
                      },
                      child: const Text('Visit Advertiser'),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                top: 40,
                right: 60,
                child: Text(
                  '5',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto close after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showRewardedAd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                ref.watch(testModeProvider) ? 'TEST REWARDED VIDEO' : 'REWARDED VIDEO',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '동영상을 끝까지 시청하면\n10 토큰을 받을 수 있습니다',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _clickCounts[AdType.rewarded] = (_clickCounts[AdType.rewarded] ?? 0) + 1;
                      });
                      Navigator.of(context).pop();
                      _showRewardDialog();
                    },
                    child: const Text('시청하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration_rounded,
                size: 60,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                '보상 획득!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('10 토큰을 받았습니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNativeAd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image),
                      ),
                      title: Text(
                        ref.watch(testModeProvider)
                            ? 'Test Native Ad ${index + 1}'
                            : 'Sponsored Content ${index + 1}',
                      ),
                      subtitle: const Text('This is a native ad that blends with content'),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() {
                            _clickCounts[AdType.native] = (_clickCounts[AdType.native] ?? 0) + 1;
                          });
                          Navigator.of(context).pop();
                          Toast.show(context, message: '네이티브 광고 클릭됨', type: ToastType.info);
                        },
                        child: const Text('Learn More'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final testMode = ref.watch(testModeProvider);
    final adConfigs = ref.watch(adConfigsProvider);

    return Scaffold(
      appBar: AppHeader(
        title: '광고 테스트',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Mode Toggle
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '테스트 모드',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: fontSize.value + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '실제 광고 대신 테스트 광고 표시',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: fontSize.value - 2,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: testMode,
                    onChanged: (value) {
                      ref.read(testModeProvider.notifier).state = value;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ad SDK Info
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Google AdMob 정보',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: fontSize.value + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, fontSize.value, 'App ID', 'ca-app-pub-xxxxx~xxxxx'),
                  const SizedBox(height: 8),
                  _buildInfoRow(theme, fontSize.value, 'Banner Unit', 'ca-app-pub-xxxxx/xxxxx'),
                  const SizedBox(height: 8),
                  _buildInfoRow(theme, fontSize.value, 'SDK Version', '3.0.0'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ad Types
            Text(
              '광고 유형 테스트',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: fontSize.value + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...adConfigs.map((config) => _buildAdTypeCard(theme, fontSize.value, config)),

            const SizedBox(height: 24),

            // Statistics
            Text(
              '테스트 통계',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: fontSize.value + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _buildStatRow(
                    theme,
                    fontSize.value,
                    '총 노출 수',
                    _impressionCounts.values.fold(0, (a, b) => a + b).toString(),
                    Icons.visibility_rounded,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    theme,
                    fontSize.value,
                    '총 클릭 수',
                    _clickCounts.values.fold(0, (a, b) => a + b).toString(),
                    Icons.touch_app_rounded,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    theme,
                    fontSize.value,
                    'CTR',
                    _calculateCTR(),
                    Icons.analytics_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, double fontSize, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize - 2,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize - 2,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildAdTypeCard(ThemeData theme, double fontSize, AdTestConfig config) {
    final impressions = _impressionCounts[config.type] ?? 0;
    final clicks = _clickCounts[config.type] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    config.icon,
                    color: config.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        config.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: fontSize - 4,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '노출: $impressions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize - 2,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '클릭: $clicks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize - 2,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showAd(config.type),
                  child: const Text('테스트'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    ThemeData theme,
    double fontSize,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _calculateCTR() {
    final totalImpressions = _impressionCounts.values.fold(0, (a, b) => a + b);
    final totalClicks = _clickCounts.values.fold(0, (a, b) => a + b);
    
    if (totalImpressions == 0) return '0%';
    
    final ctr = (totalClicks / totalImpressions) * 100;
    return '${ctr.toStringAsFixed(1)}%';
  }
}