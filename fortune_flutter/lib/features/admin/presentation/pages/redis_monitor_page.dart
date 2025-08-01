import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/features/admin/presentation/providers/redis_stats_provider.dart';
import 'package:fortune/features/admin/data/models/redis_stats_model.dart';
import 'package:fortune/features/admin/presentation/widgets/admin_guard.dart';
import 'package:fortune/features/admin/presentation/widgets/stats_card.dart';
import 'package:fortune/features/admin/presentation/widgets/chart_card.dart';
import 'package:fortune/shared/components/app_header.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RedisMonitorPage extends ConsumerStatefulWidget {
  const RedisMonitorPage({super.key});

  @override
  ConsumerState<RedisMonitorPage> createState() => _RedisMonitorPageState();
}

class _RedisMonitorPageState extends ConsumerState<RedisMonitorPage> {
  @override
  void initState() {
    super.initState();
    // Start auto-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(redisStatsProvider.notifier).startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Stop auto-refresh when leaving the page
    ref.read(redisStatsProvider.notifier).stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: 'Redis 모니터링',
                showBackButton: true,
              ),
              Expanded(
                child: RefreshIndicator(
          onRefresh: () => ref.read(redisStatsProvider.notifier).fetchRedisStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ref.watch(redisStatsProvider).when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status
                  _buildConnectionStatus(stats.connection),
                  const SizedBox(height: 16),
                  
                  // Cache Performance
                  _buildCachePerformance(stats.cache),
                  const SizedBox(height: 16),
                  
                  // Operation Stats
                  _buildOperationStats(stats.operations),
                  const SizedBox(height: 16),
                  
                  // Performance Metrics
                  _buildPerformanceMetrics(stats.performance),
                  const SizedBox(height: 16),
                  
                  // Rate Limits
                  _buildRateLimits(stats.rateLimits),
                ],
              ),
              loading: () => const Center(
                child: const CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Redis 통계를 불러올 수 없습니다',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(redisStatsProvider.notifier).fetchRedisStats(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(RedisConnectionInfo connection) {
    final theme = Theme.of(context);
    final isConnected = connection.connected;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Redis 연결 상태',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  connection.status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                if (connection.error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    connection.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${connection.activeConnections}/${connection.totalConnections}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '활성 연결',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCachePerformance(RedisCacheStats cache) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 8.0,
                  percent: cache.hitRate / 100,
                  center: Text(
                    '${cache.hitRate.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold),
                    ),
                  ),
                  progressColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  '캐시 적중률',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          cache.hits.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hits',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          cache.misses.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Misses',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              StatsCard(
                title: '총 키 개수',
                value: cache.totalKeys.toString(),
                icon: Icons.key,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              StatsCard(
                title: '메모리 사용량',
                value: cache.memoryUsage,
                icon: Icons.memory,
                iconColor: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationStats(RedisOperationStats operations) {
    final data = [
      PieChartSectionData(
        value: operations.reads.toDouble(),
        title: '읽기\n${operations.reads}',
        color: Colors.blue,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: operations.writes.toDouble(),
        title: '쓰기\n${operations.writes}',
        color: Colors.green,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: operations.deletes.toDouble(),
        title: '삭제\n${operations.deletes}',
        color: Colors.orange,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      if (operations.errors > 0)
        PieChartSectionData(
          value: operations.errors.toDouble(),
          title: '오류\n${operations.errors}',
          color: Colors.red,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return ChartCard(
      title: '작업 통계',
      subtitle: '총 ${operations.totalOperations}개 작업',
      height: 200,
      chart: PieChart(
        PieChartData(
          sections: data,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(RedisPerformanceStats performance) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          title: '평균 응답 시간',
          value: '${performance.avgResponseTime.toStringAsFixed(2)}ms',
          icon: Icons.speed,
          iconColor: Colors.teal,
        ),
        StatsCard(
          title: '최대 응답 시간',
          value: '${performance.maxResponseTime.toStringAsFixed(2)}ms',
          icon: Icons.trending_up,
          iconColor: Colors.red,
        ),
        StatsCard(
          title: '최소 응답 시간',
          value: '${performance.minResponseTime.toStringAsFixed(2)}ms',
          icon: Icons.trending_down,
          iconColor: Colors.green,
        ),
        StatsCard(
          title: '느린 쿼리',
          value: performance.slowQueries.toString(),
          icon: Icons.warning,
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRateLimits(Map<String, RateLimitInfo> rateLimits) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '레이트 리밋 현황',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ...rateLimits.entries.map((entry) {
            final info = entry.value;
            final percentage = info.limit > 0 ? info.used / info.limit : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        info.tier.toUpperCase(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${info.used} / ${info.limit}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 0.8 ? Colors.red : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '재설정: ${_formatResetTime(info.resetAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatResetTime(DateTime resetAt) {
    final now = DateTime.now();
    final difference = resetAt.difference(now);
    
    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}초 후';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 후';
    } else {
      return '${difference.inHours}시간 후';
    }
  }
}