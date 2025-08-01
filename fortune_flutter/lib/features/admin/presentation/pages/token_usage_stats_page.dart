import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/features/admin/presentation/providers/token_usage_provider.dart';
import 'package:fortune/features/admin/data/models/token_usage_detail_model.dart';
import 'package:fortune/features/admin/presentation/widgets/admin_guard.dart';
import 'package:fortune/features/admin/presentation/widgets/stats_card.dart';
import 'package:fortune/features/admin/presentation/widgets/chart_card.dart';
import 'package:fortune/shared/components/app_header.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TokenUsageStatsPage extends ConsumerWidget {
  const TokenUsageStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(tokenUsagePeriodProvider);
    
    return AdminGuard(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: '토큰 사용량 통계',
                showBackButton: true,
              ),
              Expanded(
                child: RefreshIndicator(
          onRefresh: () => ref.read(tokenUsageProvider.notifier).fetchTokenUsageStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                _buildPeriodSelector(context, ref, period),
                const SizedBox(height: 16),
                
                ref.watch(tokenUsageProvider).when(
                  data: (stats) => Column(
                    children: [
                      // Summary Cards
                      _buildSummaryCards(stats.summary),
                      const SizedBox(height: 16),
                      
                      // Daily Usage Chart
                      _buildDailyUsageChart(context, stats.dailyUsage),
                      const SizedBox(height: 16),
                      
                      // Usage by Type
                      _buildUsageByType(context, stats.usageByType),
                      const SizedBox(height: 16),
                      
                      // Package Efficiency
                      _buildPackageEfficiency(context, stats.packageEfficiency),
                      const SizedBox(height: 16),
                      
                      // Usage Trend
                      _buildUsageTrend(context, stats.trend),
                      const SizedBox(height: 16),
                      
                      // Top Users
                      _buildTopUsers(context, stats.topUsers),
                    ],
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
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
                            '토큰 사용량 통계를 불러올 수 없습니다',
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
                            onPressed: () => ref.read(tokenUsageProvider.notifier).fetchTokenUsageStats(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref, String selectedPeriod) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PeriodButton(
            label: '7일',
            value: '7d',
            isSelected: selectedPeriod == '7d',
            onTap: () => ref.read(tokenUsageProvider.notifier).changePeriod('7d'),
          ),
          _PeriodButton(
            label: '30일',
            value: '30d',
            isSelected: selectedPeriod == '30d',
            onTap: () => ref.read(tokenUsageProvider.notifier).changePeriod('30d'),
          ),
          _PeriodButton(
            label: '90일',
            value: '90d',
            isSelected: selectedPeriod == '90d',
            onTap: () => ref.read(tokenUsageProvider.notifier).changePeriod('90d'),
          ),
        ],
      );
  }

  Widget _buildSummaryCards(TokenUsageSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          title: '총 사용 토큰',
          value: NumberFormat('#,###').format(summary.totalTokensUsed),
          icon: Icons.token,
          iconColor: Colors.blue,
          subtitle: summary.period,
        ),
        StatsCard(
          title: '총 구매 토큰',
          value: NumberFormat('#,###').format(summary.totalTokensPurchased),
          icon: Icons.shopping_cart,
          iconColor: Colors.green,
          subtitle: summary.period,
        ),
        StatsCard(
          title: '활성 사용자',
          value: NumberFormat('#,###').format(summary.activeUsers),
          icon: Icons.people,
          iconColor: Colors.purple,
          subtitle: '토큰 사용자',
        ),
        StatsCard(
          title: '평균 사용량',
          value: summary.averageUsagePerUser.toStringAsFixed(1),
          icon: Icons.analytics,
          iconColor: Colors.orange,
          subtitle: '사용자당',
        ),
      ],
    );
  }

  Widget _buildDailyUsageChart(BuildContext context, List<DailyTokenUsage> dailyUsage) {
    final theme = Theme.of(context);
    
    final usedBars = dailyUsage.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.tokensUsed.toDouble(),
            color: theme.colorScheme.primary,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: entry.value.tokensPurchased.toDouble(),
            color: Colors.green,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return ChartCard(
      title: '일별 토큰 사용량',
      subtitle: '사용(파랑) vs 구매(초록)',
      height: 250,
      chart: BarChart(
        BarChartData(
          barGroups: usedBars,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value >= 1000) {
                    return Text('${(value / 1000).toStringAsFixed(0)}k');
                  }
                  return Text(value.toInt().toString());
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < dailyUsage.length) {
                    final date = dailyUsage[value.toInt()].date;
                    return Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1000,
          ),
          borderData: FlBorderData(show: false),
        ),
      );
  }

  Widget _buildUsageByType(BuildContext context, List<TokenUsageByType> usageByType) {
    final theme = Theme.of(context);
    final topTypes = usageByType.take(10).toList();
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운세별 사용량 TOP 10',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ...topTypes.map((type) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.fortuneType,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        type.fortuneCategory,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(type.tokensUsed)} 토큰',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${type.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      );
  }

  Widget _buildPackageEfficiency(BuildContext context, PackageEfficiency efficiency) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '패키지 효율성',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: '가장 인기 있는 패키지',
                  value: efficiency.mostPopular,
                  icon: Icons.star,
                  iconColor: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoCard(
                  title: '가장 가치 있는 패키지',
                  value: efficiency.bestValue,
                  icon: Icons.attach_money,
                  iconColor: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...efficiency.packages.entries.map((entry) {
            final stats = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stats.packageName,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stats.purchaseCount}회 구매',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '₩${NumberFormat('#,###').format(stats.totalRevenue)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
  }

  Widget _buildUsageTrend(BuildContext context, TokenUsageTrend trend) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: '일일 성장률',
            value: '${trend.dailyGrowth > 0 ? '+' : ''}${trend.dailyGrowth.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            iconColor: trend.dailyGrowth > 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: '주간 성장률',
            value: '${trend.weeklyGrowth > 0 ? '+' : ''}${trend.weeklyGrowth.toStringAsFixed(1)}%',
            icon: Icons.show_chart,
            iconColor: trend.weeklyGrowth > 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTopUsers(BuildContext context, List<TopUserUsage> topUsers) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상위 사용자',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('사용자')),
                DataColumn(label: Text('사용 토큰')),
                DataColumn(label: Text('구매 토큰')),
                DataColumn(label: Text('운세 횟수')),
                DataColumn(label: Text('상태')),
              ],
              rows: topUsers.map((user) => DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.displayName ?? 'Unknown',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(NumberFormat('#,###').format(user.tokensUsed))),
                  DataCell(Text(NumberFormat('#,###').format(user.tokensPurchased))),
                  DataCell(Text(user.fortuneCount.toString())),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isUnlimited ? Colors.purple.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isUnlimited ? '무제한' : '일반',
                        style: TextStyle(
                          color: user.isUnlimited ? Colors.purple : Colors.blue),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              )).toList(),
            ),
          ),
        ],
      );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
  }
}