import 'package:flutter/material.dart';

import '../../../../core/services/asset_delivery_service.dart';
import '../../../../core/constants/asset_pack_config.dart';
import '../../../../core/models/asset_pack.dart';

/// 저장소 관리 위젯
///
/// 다운로드된 자산 팩을 관리하고 삭제할 수 있는 UI
class StorageManagementWidget extends StatefulWidget {
  const StorageManagementWidget({super.key});

  @override
  State<StorageManagementWidget> createState() =>
      _StorageManagementWidgetState();
}

class _StorageManagementWidgetState extends State<StorageManagementWidget> {
  final _assetService = AssetDeliveryService();
  StorageUsage? _storageUsage;
  Map<String, AssetPackStatus> _packStatuses = {};
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadStorageUsage();
  }

  Future<void> _loadStorageUsage() async {
    setState(() => _isLoading = true);

    try {
      await _assetService.initialize();
      final usage = await _assetService.getStorageUsage();

      // 각 팩의 상태 가져오기
      final statuses = <String, AssetPackStatus>{};
      for (final packId in AssetPackConfig.packs.keys) {
        statuses[packId] = await _assetService.getPackStatus(packId);
      }

      if (mounted) {
        setState(() {
          _storageUsage = usage;
          _packStatuses = statuses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('📦 [StorageManagement] ❌ 로드 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAllDownloads() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 다운로드 삭제'),
        content: const Text(
          '다운로드된 모든 자산을 삭제하시겠습니까?\n'
          '삭제된 자산은 다시 다운로드해야 합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _assetService.clearAllDownloadedAssets();
      await _loadStorageUsage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 다운로드가 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _deletePack(String packId) async {
    setState(() => _isDeleting = true);

    try {
      await _assetService.deleteAssetPack(packId);
      await _loadStorageUsage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AssetPackConfig.packs[packId]?.displayName ?? packId} 삭제됨',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.storage_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                '저장소 관리',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 저장소 사용량 요약
        if (_storageUsage != null) _buildUsageSummary(theme),

        const Divider(),

        // 다운로드된 자산 팩 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '다운로드된 자산',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        _buildDownloadedPacksList(theme),

        const SizedBox(height: 16),

        // 모두 삭제 버튼
        if (_storageUsage != null && _storageUsage!.downloadedSize > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : _deleteAllDownloads,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_sweep_rounded),
                label: const Text('모든 다운로드 삭제'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUsageSummary(ThemeData theme) {
    final usage = _storageUsage!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUsageItem(
                '번들 자산',
                _formatBytes(usage.bundledSize),
                Icons.inventory_2_outlined,
                theme,
              ),
              _buildUsageItem(
                '다운로드',
                _formatBytes(usage.downloadedSize),
                Icons.download_done_rounded,
                theme,
              ),
              _buildUsageItem(
                '전체',
                _formatBytes(usage.totalSize),
                Icons.pie_chart_rounded,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadedPacksList(ThemeData theme) {
    // 설치된 팩만 필터링 (번들 제외)
    final installedPacks = AssetPackConfig.packs.entries
        .where((e) =>
            e.value.tier != AssetTier.bundled &&
            _packStatuses[e.key] == AssetPackStatus.installed)
        .toList();

    if (installedPacks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.cloud_download_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                '다운로드된 자산이 없습니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: installedPacks.length,
      itemBuilder: (context, index) {
        final entry = installedPacks[index];
        final pack = entry.value;
        final packId = entry.key;
        final size = _storageUsage?.packSizes[packId] ?? pack.estimatedSize;

        return ListTile(
          leading: _getPackIcon(pack),
          title: Text(pack.displayName),
          subtitle: Text(_formatBytes(size)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : () => _deletePack(packId),
            color: Colors.red,
          ),
        );
      },
    );
  }

  Widget _getPackIcon(AssetPack pack) {
    IconData icon;
    Color color;

    if (pack.id.startsWith('tarot_')) {
      icon = Icons.auto_awesome;
      color = Colors.purple;
    } else if (pack.id.contains('mbti')) {
      icon = Icons.psychology;
      color = Colors.blue;
    } else if (pack.id.contains('zodiac')) {
      icon = Icons.stars;
      color = Colors.amber;
    } else if (pack.id.contains('hero')) {
      icon = Icons.image;
      color = Colors.green;
    } else {
      icon = Icons.folder;
      color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

/// 저장소 관리 페이지 (전체 화면)
class StorageManagementPage extends StatelessWidget {
  const StorageManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장소 관리'),
      ),
      body: const SingleChildScrollView(
        child: StorageManagementWidget(),
      ),
    );
  }
}
