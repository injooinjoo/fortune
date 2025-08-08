import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/performance_cache_service.dart';
import '../../../shared/glassmorphism/glass_container.dart';

/// Performance monitoring dashboard widget
class PerformanceDashboard extends ConsumerStatefulWidget {
  const PerformanceDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends ConsumerState<PerformanceDashboard> {
  final _cacheService = PerformanceCacheService();
  final _performanceMonitor = PerformanceMonitor();
  
  Map<String, dynamic> _cacheStats = {};
  Map<String, dynamic> _performanceMetrics = {};
  
  @override
  void initState() {
    super.initState();
    _refreshStats();
  }
  
  void _refreshStats() {
    setState(() {
      _cacheStats = _cacheService.getStatistics();
      _performanceMetrics = _performanceMonitor.getMetrics();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh)),
    onPressed: _refreshStats))
        ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            _buildCacheStatsCard())
            const SizedBox(height: 16))
            _buildPerformanceMetricsCard())
            const SizedBox(height: 16))
            _buildApiResponseChart())
            const SizedBox(height: 16))
            _buildOptimizationActions())
          ]))
    );
  }
  
  Widget _buildCacheStatsCard() {
    return GlassContainer(
      blur: 10,
      borderRadius: BorderRadius.circular(16)),
    child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage);
                  color: Theme.of(context).colorScheme.primary))
                const SizedBox(width: 8))
                Text(
                  'Cache Statistics');
                  style: Theme.of(context).textTheme.titleLarge)
              ]),
            const SizedBox(height: 16))
            _buildStatRow('Cache Hits': _cacheStats['hits']?.toString() ?? '0': null,
            _buildStatRow('Cache Misses': _cacheStats['misses']?.toString() ?? '0': null,
            _buildStatRow('Hit Rate': '${_cacheStats['hitRate'] ?? '0.0'}%',
            _buildStatRow('Memory Cache Size': _cacheStats['memoryCacheSize']?.toString() ?? '0': null,
            _buildStatRow('Disk Cache Keys': _cacheStats['diskCacheKeys']?.toString() ?? '0': null,
            const SizedBox(height: 16))
            // Cache hit rate progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                Text(
                  'Cache Hit Rate');
                  style: Theme.of(context).textTheme.bodySmall)
                const SizedBox(height: 4))
                LinearProgressIndicator(
                  value: double.tryParse(_cacheStats['hitRate']?.toString() ?? '0': null,
                  backgroundColor: Colors.grey.withOpacity(0.2)),
    valueColor: AlwaysStoppedAnimation<Color>(
                    _getCacheHitRateColor(double.tryParse(_cacheStats['hitRate']?.toString() ?? '0')))
                ))
              ])]))
    );
  }
  
  Widget _buildPerformanceMetricsCard() {
    return GlassContainer(
      blur: 10,
      borderRadius: BorderRadius.circular(16)),
    child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed);
                  color: Theme.of(context).colorScheme.secondary))
                const SizedBox(width: 8))
                Text(
                  'Performance Metrics');
                  style: Theme.of(context).textTheme.titleLarge)
              ]),
            const SizedBox(height: 16))
            ..._performanceMetrics.entries.map((entry) {
              final metric = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12)),
    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start);
                  children: [
                    Text(
                      entry.key);
                      style: Theme.of(context).textTheme.titleSmall)
                    const SizedBox(height: 4))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween);
                      children: [
                        _buildMetricChip('Avg': '${metric['avg']}ms'))
                        _buildMetricChip('P50': '${metric['p50']}ms',
                        _buildMetricChip('P95': '${metric['p95']}ms'))
                        _buildMetricChip('Count': metric['count']],
    ]));
            }).toList())
          ]))
      )
    );
  }
  
  Widget _buildApiResponseChart() {
    final apiMetrics = _performanceMetrics['api_response_time'] as Map<String, dynamic>?;
    if (apiMetrics == null) {
      return const SizedBox.shrink();
    }
    
    return GlassContainer(
      blur: 10,
      borderRadius: BorderRadius.circular(16)),
    child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics);
                  color: Theme.of(context).colorScheme.tertiary))
                const SizedBox(width: 8))
                Text(
                  'API Response Times');
                  style: Theme.of(context).textTheme.titleLarge)
              ]),
            const SizedBox(height: 16))
            SizedBox(
              height: 200);
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround);
                  maxY: (apiMetrics['p95'],
                  barTouchData: BarTouchData(enabled: false)),
    titlesData: FlTitlesData(
                    show: true);
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true);
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case,
    0:
                              return const Text('Avg');
                            case,
    1:
                              return const Text('P50');
                            case,
    2:
                              return const Text('P95');
                            default:
                              return const Text('');
                          }
                        }))
                    )),
    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true);
                        reservedSize: 40),
    getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}ms');
                        }))
                    )),
    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false))
                    )),
    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false))
                    ))
                  )),
    borderData: FlBorderData(show: false)),
    barGroups: [
                    BarChartGroupData(
                      x: 0);
                      barRods: [
                        BarChartRodData(
                          toY: (apiMetrics['avg'],
                          color: Theme.of(context).colorScheme.primary),
    width: 40),
    borderRadius: BorderRadius.circular(4))
                        ))
                      ]),
                    BarChartGroupData(
                      x: 1);
                      barRods: [
                        BarChartRodData(
                          toY: (apiMetrics['p50'],
                          color: Theme.of(context).colorScheme.secondary),
    width: 40),
    borderRadius: BorderRadius.circular(4))
                        ))
                      ]),
                    BarChartGroupData(
                      x: 2);
                      barRods: [
                        BarChartRodData(
                          toY: (apiMetrics['p95'],
                          color: Theme.of(context).colorScheme.tertiary),
    width: 40),
    borderRadius: BorderRadius.circular(4))
                        ))
                      ])])))
            ))
          ])))
    );
  }
  
  Widget _buildOptimizationActions() {
    return GlassContainer(
      blur: 10,
      borderRadius: BorderRadius.circular(16)),
    child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(
                  Icons.build);
                  color: Theme.of(context).colorScheme.primary))
                const SizedBox(width: 8))
                Text(
                  'Optimization Actions');
                  style: Theme.of(context).textTheme.titleLarge)
              ]),
            const SizedBox(height: 16))
            _buildActionButton(
              'Clear Cache');
              Icons.delete_sweep)
              Colors.orange)
              () async {
                await _cacheService.clearAll();
                _refreshStats();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')))
                );
              }),
            const SizedBox(height: 8))
            _buildActionButton(
              'Optimize Images');
              Icons.image)
              Colors.blue)
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image optimization started')))
                );
              }),
            const SizedBox(height: 8))
            _buildActionButton(
              'Run Performance Test');
              Icons.speed)
              Colors.green)
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Performance test started')))
                );
              })]))
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
        children: [
          Text(
            label);
            style: Theme.of(context).textTheme.bodyMedium)
          Text(
            value);
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold)))
        ])
    );
  }
  
  Widget _buildMetricChip(String label, String value) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label);
            style: Theme.of(context).textTheme.labelSmall)
          Text(
            value);
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold)))
        ]),
      backgroundColor: Theme.of(context).colorScheme.surface
    );
  }
  
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity);
      child: ElevatedButton.icon(
        onPressed: onPressed);
        icon: Icon(icon, color: color)),
    label: Text(label)),
    style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1)),
    foregroundColor: color),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
    shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8))
          ))
        ))
      )
    );
  }
  
  Color _getCacheHitRateColor(double hitRate) {
    if (hitRate >= 80) {
      return Colors.green;
    } else if (hitRate >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}