import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../presentation/providers/providers.dart';

// Admin stats provider
final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
    final response = await apiClient.get(ApiEndpoints.adminTokenStats);
    
    if (response.data['success'] == true) {
      return AdminStats.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['error'] ?? '통계 데이터를 불러올 수 없습니다');
    }
  } catch (e) {
    throw Exception('관리자 통계 조회 실패: $e');
  }
});

// Admin stats model
class AdminStats {
  final DailyStat daily;
  final DailyStat monthly;
  final Map<String, PackageStat> byPackage;
  final List<TimelineStat> timeline;
  final List<TopUser> topUsers;

  AdminStats({
    required this.daily,
    required this.monthly,
    required this.byPackage,
    required this.timeline,
    required this.topUsers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      daily: DailyStat.fromJson(json['daily'] ?? {}),
      monthly: DailyStat.fromJson(json['monthly'] ?? {}),
      byPackage: (json['byPackage'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, PackageStat.fromJson(value)),
      ),
      timeline: (json['timeline'] as List? ?? [])
          .map((e) => TimelineStat.fromJson(e))
          .toList(),
      topUsers: (json['topUsers'] as List? ?? [])
          .map((e) => TopUser.fromJson(e))
          .toList(),
    );
  }
}

class DailyStat {
  final int tokens;
  final double cost;

  DailyStat({required this.tokens, required this.cost});

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      tokens: json['tokens'] ?? 0,
      cost: (json['cost'] ?? 0).toDouble(),
    );
  }
}

class PackageStat {
  final double avgTokensPerRequest;
  final double avgCostPerRequest;
  final double savingsPercent;
  final int requestCount;

  PackageStat({
    required this.avgTokensPerRequest,
    required this.avgCostPerRequest,
    required this.savingsPercent,
    required this.requestCount,
  });

  factory PackageStat.fromJson(Map<String, dynamic> json) {
    return PackageStat(
      avgTokensPerRequest: (json['avgTokensPerRequest'] ?? 0).toDouble(),
      avgCostPerRequest: (json['avgCostPerRequest'] ?? 0).toDouble(),
      savingsPercent: (json['savingsPercent'] ?? 0).toDouble(),
      requestCount: json['requestCount'] ?? 0,
    );
  }
}

class TimelineStat {
  final String date;
  final int tokens;
  final double cost;
  final int requests;

  TimelineStat({
    required this.date,
    required this.tokens,
    required this.cost,
    required this.requests,
  });

  factory TimelineStat.fromJson(Map<String, dynamic> json) {
    return TimelineStat(
      date: json['date'] ?? '',
      tokens: json['tokens'] ?? 0,
      cost: (json['cost'] ?? 0).toDouble(),
      requests: json['requests'] ?? 0,
    );
  }
}

class TopUser {
  final String userId;
  final String userName;
  final int totalTokens;
  final double totalCost;
  final int requestCount;

  TopUser({
    required this.userId,
    required this.userName,
    required this.totalTokens,
    required this.totalCost,
    required this.requestCount,
  });

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      totalTokens: json['totalTokens'] ?? 0,
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      requestCount: json['requestCount'] ?? 0,
    );
  }
}

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedTabIndex = 0;
  final _tabs = const ['개요', '사용량 추이', '패키지별 분석', '상위 사용자'];


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '관리자 대시보드',
              showBackButton: true,
            ),
            Expanded(
              child: statsAsync.when(
                loading: () => const Center(child: LoadingIndicator(size: 60)),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '통계 데이터를 불러올 수 없습니다',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        GlassButton(
                          onPressed: () => ref.invalidate(adminStatsProvider),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text('다시 시도'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (stats) => Column(
                  children: [
                    // Tab Bar
                    Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedTabIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GlassButton(
                              onPressed: () => setState(() => _selectedTabIndex = index),
                              child: Container(
                                decoration: isSelected
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary.withValues(alpha: 0.3),
                                            theme.colorScheme.secondary.withValues(alpha: 0.3),
                                          ],
                                        ),
                                      )
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Center(
                                    child: Text(
                                      _tabs[index],
                                      style: TextStyle(
                                        fontSize: 14 * fontScale,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? theme.colorScheme.primary : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Tab Content
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTabIndex,
                        children: [
                          _OverviewTab(stats: stats, fontScale: fontScale),
                          _UsageTrendTab(stats: stats, fontScale: fontScale),
                          _PackageAnalysisTab(stats: stats, fontScale: fontScale),
                          _TopUsersTab(stats: stats, fontScale: fontScale),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final AdminStats stats;
  final double fontScale;

  const _OverviewTab({
    required this.stats,
    required this.fontScale,
  });

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(value);
  }

  String _formatNumber(int value) {
    return NumberFormat('#,###').format(value);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate cost trend
    double costTrend = 0;
    if (stats.timeline.length > 1) {
      final today = stats.timeline.last;
      final yesterday = stats.timeline[stats.timeline.length - 2];
      if (yesterday.cost > 0) {
        costTrend = ((today.cost - yesterday.cost) / yesterday.cost) * 100;
      }
    }

    // Calculate average savings
    double avgSavings = 0;
    if (stats.byPackage.isNotEmpty) {
      avgSavings = stats.byPackage.values
          .map((p) => p.savingsPercent)
          .reduce((a, b) => a + b) / stats.byPackage.length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _SummaryCard(
                title: '일일 토큰',
                value: _formatNumber(stats.daily.tokens),
                subtitle: '전일 대비 ${costTrend > 0 ? '+' : ''}${costTrend.toStringAsFixed(1)}%',
                icon: Icons.token,
                color: theme.colorScheme.primary,
                fontScale: fontScale,
              ),
              _SummaryCard(
                title: '일일 비용',
                value: _formatCurrency(stats.daily.cost),
                subtitle: costTrend > 0 ? '증가' : '감소',
                icon: Icons.attach_money,
                color: costTrend > 0 ? Colors.red : Colors.green,
                fontScale: fontScale,
              ),
              _SummaryCard(
                title: '월간 토큰',
                value: _formatNumber(stats.monthly.tokens),
                subtitle: '예상 비용: ${_formatCurrency(stats.monthly.cost)}',
                icon: Icons.calendar_month,
                color: theme.colorScheme.secondary,
                fontScale: fontScale,
              ),
              _SummaryCard(
                title: '평균 절감률',
                value: '${avgSavings.toStringAsFixed(1)}%',
                subtitle: '배치 처리 효과',
                icon: Icons.trending_down,
                color: Colors.green,
                fontScale: fontScale,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Activity
          Text(
            '최근 활동',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20 * fontScale,
            ),
          ),
          const SizedBox(height: 16),
          
          // Activity List
          ...stats.timeline.take(5).map((stat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MM월 dd일').format(DateTime.parse(stat.date)),
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatNumber(stat.requests)}개 요청',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatNumber(stat.tokens),
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          _formatCurrency(stat.cost),
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double fontScale;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10 * fontScale,
              color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageTrendTab extends StatelessWidget {
  final AdminStats stats;
  final double fontScale;

  const _UsageTrendTab({
    required this.stats,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Prepare chart data
    final spots = stats.timeline.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.tokens.toDouble());
    }).toList();

    final maxY = spots.isEmpty ? 1000.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '토큰 사용량 추이',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20 * fontScale,
            ),
          ),
          const SizedBox(height: 16),
          
          // Line Chart
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withValues(alpha:  0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < stats.timeline.length) {
                            final date = DateTime.parse(stats.timeline[value.toInt()].date);
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: TextStyle(
                                fontSize: 10 * fontScale,
                                color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY / 5,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compact().format(value),
                            style: TextStyle(
                              fontSize: 10 * fontScale,
                              color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (stats.timeline.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha:  0.1),
                            theme.colorScheme.secondary.withValues(alpha:  0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Daily Stats
          Text(
            '일별 상세',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18 * fontScale,
            ),
          ),
          const SizedBox(height: 16),
          
          ...stats.timeline.reversed.take(7).map((stat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(stat.date)),
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _StatItem(
                                label: '토큰',
                                value: NumberFormat('#,###').format(stat.tokens),
                                color: theme.colorScheme.primary,
                                fontScale: fontScale,
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: '요청',
                                value: NumberFormat('#,###').format(stat.requests),
                                color: theme.colorScheme.secondary,
                                fontScale: fontScale,
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: '비용',
                                value: NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(stat.cost),
                                color: Colors.green,
                                fontScale: fontScale,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double fontScale;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10 * fontScale,
            color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PackageAnalysisTab extends StatelessWidget {
  final AdminStats stats;
  final double fontScale;

  const _PackageAnalysisTab({
    required this.stats,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '패키지별 분석',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20 * fontScale,
            ),
          ),
          const SizedBox(height: 16),
          
          ...stats.byPackage.entries.map((entry) {
            final packageName = entry.key.replaceAll('_', ' ');
            final stat = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          packageName,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha:  0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${stat.savingsPercent.toStringAsFixed(1)}% 절감',
                            style: TextStyle(
                              fontSize: 12 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PackageStat(
                          label: '평균 토큰',
                          value: NumberFormat('#,###').format(stat.avgTokensPerRequest),
                          fontScale: fontScale,
                        ),
                        _PackageStat(
                          label: '평균 비용',
                          value: NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(stat.avgCostPerRequest),
                          fontScale: fontScale,
                        ),
                        _PackageStat(
                          label: '총 요청',
                          value: NumberFormat('#,###').format(stat.requestCount),
                          fontScale: fontScale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // Total Savings
          GlassContainer(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha:  0.1),
                Colors.green.withValues(alpha:  0.05),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.savings,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                Text(
                  '총 절감액',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(
                    stats.byPackage.entries.fold(
                      0.0,
                      (sum, entry) => sum + (entry.value.avgCostPerRequest * 
                          entry.value.requestCount * 
                          entry.value.savingsPercent / 100),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 24 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '배치 처리로 절약한 비용',
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageStat extends StatelessWidget {
  final String label;
  final String value;
  final double fontScale;

  const _PackageStat({
    required this.label,
    required this.value,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10 * fontScale,
            color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TopUsersTab extends StatelessWidget {
  final AdminStats stats;
  final double fontScale;

  const _TopUsersTab({
    required this.stats,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상위 사용자',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20 * fontScale,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '토큰 사용량 기준 상위 ${stats.topUsers.length}명',
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          ...stats.topUsers.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final color = colors[index % colors.length];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha:  0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.userName,
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${NumberFormat('#,###').format(user.requestCount)}회 요청',
                            style: TextStyle(
                              fontSize: 12 * fontScale,
                              color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${NumberFormat('#,###').format(user.totalTokens)} 토큰',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(user.totalCost),
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}