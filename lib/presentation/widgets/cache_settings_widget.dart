import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/cache_service.dart';
import '../../data/services/fortune_api_service.dart';
import '../../../../core/theme/toss_design_system.dart';

class CacheSettingsWidget extends ConsumerStatefulWidget {
  const CacheSettingsWidget({super.key});

  @override
  ConsumerState<CacheSettingsWidget> createState() => _CacheSettingsWidgetState();
}

class _CacheSettingsWidgetState extends ConsumerState<CacheSettingsWidget> {
  final _cacheService = CacheService();
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _cacheService.getCacheStats();
      setState(() => _cacheStats = stats);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('저장된 모든 운세 캐시를 삭제하시겠습니까?\n오프라인에서 운세를 볼 수 없게 됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: TossDesignSystem.errorRed),
            child: const Text('삭제'))
        ]));

    if (confirm == true) {
      await _cacheService.clearAllCache();
      await _loadCacheStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('캐시가 삭제되었습니다')),
        );
      }
    }
  }

  Future<void> _cleanExpiredCache() async {
    await _cacheService.cleanExpiredCache();
    await _loadCacheStats();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('만료된 캐시가 정리되었습니다')),
      );
    }
  }

  Future<void> _preloadForOffline() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      final userId = ref.read(currentUserProvider)?.id ?? '';
      
      await apiService.preloadForOfflineUse(userId);
      await _loadCacheStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오프라인용 운세가 준비되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.paddingAll16,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: TossDesignSystem.tossBlue),
                SizedBox(width: AppSpacing.spacing2),
                Text(
                  '캐시 관리',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.spacing4),
            
            // Cache Statistics
            if (_cacheStats != null) ...[
              _buildStatRow('전체 캐시', '${_cacheStats!['total']}개'),
              _buildStatRow('유효한 캐시', '${_cacheStats!['valid']}개'),
              _buildStatRow('만료된 캐시', '${_cacheStats!['expired']}개'),
              _buildStatRow('캐시 크기', _formatBytes(_cacheStats!['sizeInBytes'])),
              const Divider(height: 24),
            ],
            
            // Actions
            _buildActionButton(
              icon: Icons.cloud_download,
              label: '오프라인용 운세 준비',
              onPressed: _isLoading ? null : _preloadForOffline,
              color: TossDesignSystem.tossBlue,
            ),
            SizedBox(height: AppSpacing.spacing2),
            _buildActionButton(
              icon: Icons.cleaning_services,
              label: '만료된 캐시 정리',
              onPressed: _isLoading ? null : _cleanExpiredCache,
              color: TossDesignSystem.warningOrange,
            ),
            SizedBox(height: AppSpacing.spacing2),
            _buildActionButton(
              icon: Icons.delete_outline,
              label: '모든 캐시 삭제',
              onPressed: _isLoading ? null : _clearCache,
              color: TossDesignSystem.errorRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Provider placeholders (replace with actual providers)
final currentUserProvider = Provider<User?>((ref) => null);

class User {
  final String id;
  const User({required this.id});
}