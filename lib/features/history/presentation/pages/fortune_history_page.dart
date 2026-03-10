import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../core/providers/user_settings_provider.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../presentation/providers/fortune_history_provider.dart';
import '../../domain/models/fortune_history.dart';
import '../widgets/statistics_dashboard.dart';
import '../widgets/fortune_charts.dart';
import '../widgets/timeline_view.dart';
import '../../../../core/design_system/design_system.dart';
import '../widgets/fortune_calendar_view.dart';
import '../../../chat_insight/data/storage/insight_storage.dart';
import '../../../chat_insight/data/models/chat_insight_result.dart';
import '../../../chat_insight/presentation/widgets/insight_history_card.dart';

class FortuneHistoryPage extends ConsumerStatefulWidget {
  const FortuneHistoryPage({super.key});

  @override
  ConsumerState<FortuneHistoryPage> createState() => _FortuneHistoryPageState();
}

class _FortuneHistoryPageState extends ConsumerState<FortuneHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedFilter = 'all';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load fortune history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fortuneHistoryProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = ref.watch(userSettingsProvider);
    final fontScale = userSettings.fontScale;
    final historyState = ref.watch(fortuneHistoryProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppHeader(
        title: '인사이트 기록',
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: colors.textSecondary),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: historyState.when(
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState(fontScale);
          }

          final filteredHistory = _filterHistory(history);
          final statistics = _calculateStatistics(filteredHistory);

          return Column(
            children: [
              const SizedBox(height: DSSpacing.lg),

              // 토스 스타일 탭 바
              Container(
                margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                child: Row(
                  children: [
                    _buildTabButton(0, '타임라인'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(1, '통계'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(2, '차트'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(3, '일일인사이트'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(4, '대화분석'),
                  ],
                ),
              ),

              const SizedBox(height: DSSpacing.lg),

              // 이번 달 요약 카드 (토스 스타일)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                child: AppCard(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '이번 달 요약',
                            style: context.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('yyyy년 MM월').format(DateTime.now()),
                            style: context.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${statistics.monthlyCount}',
                                  style: context.heading1.copyWith(
                                    color: colors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '운세 조회',
                                  style: context.labelLarge.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  statistics.averageScore.toStringAsFixed(1),
                                  style: context.heading1.copyWith(
                                    color: colors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '평균 점수',
                                  style: context.labelLarge.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  statistics.mostFrequentCategory,
                                  style: context.heading2.copyWith(
                                    color: colors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '자주 본 운세',
                                  style: context.labelLarge.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DSSpacing.lg),

              // 탭별 컨텐츠
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Timeline Tab
                    _buildTimelineView(filteredHistory),

                    // Statistics Tab
                    _buildStatisticsView(statistics, fontScale),

                    // Charts Tab
                    _buildChartsView(filteredHistory, fontScale),

                    // Daily Fortune Calendar Tab
                    _buildDailyFortuneCalendar(filteredHistory),

                    // Chat Insight History Tab
                    _buildChatInsightHistory(),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(
            '인사이트 기록을 불러올 수 없습니다',
            style: context.labelMedium,
          ),
        ),
      ),
    );
  }

  /// 통일된 탭 버튼 빌더
  Widget _buildTabButton(int index, String label) {
    final isSelected = _tabController.index == index;
    final colors = context.colors;

    return Expanded(
      child: AppCard(
        onTap: () {
          ref.read(fortuneHapticServiceProvider).selection();
          setState(() => _tabController.index = index);
        },
        style: isSelected ? AppCardStyle.filled : AppCardStyle.outlined,
        padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.sm,
          horizontal: DSSpacing.md,
        ),
        child: Text(
          label,
          style: context.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyState(double fontScale) {
    final colors = context.colors;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(DSSpacing.xl),
        child: AppCard(
          padding: const EdgeInsets.all(DSSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📜',
                style: context.displayLarge,
              ),
              const SizedBox(height: DSSpacing.lg),
              Text(
                '아직 인사이트 기록이 없어요',
                style: context.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                '인사이트를 보고 나면 여기에 기록됩니다',
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.lg),
              UnifiedButton(
                text: '인사이트 보러 가기',
                onPressed: () => Navigator.of(context).pop(),
                size: UnifiedButtonSize.large,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FortuneHistory> _filterHistory(List<FortuneHistory> history) {
    var filtered = history;

    // Apply date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((item) {
        return item.createdAt.isAfter(_selectedDateRange!.start) &&
            item.createdAt
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((item) {
        switch (_selectedFilter) {
          case 'daily':
            return item.fortuneType.contains('daily') ||
                item.fortuneType.contains('today') ||
                item.fortuneType.contains('tomorrow');
          case 'weekly':
            return item.fortuneType.contains('weekly');
          case 'monthly':
            return item.fortuneType.contains('monthly');
          case 'love':
            return item.fortuneType.contains('love');
          case 'money':
            return item.fortuneType.contains('money') ||
                item.fortuneType.contains('finance');
          case 'career':
            return item.fortuneType.contains('career') ||
                item.fortuneType.contains('work');
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  // Calculate real statistics from history data
  FortuneStatistics _calculateStatistics(List<FortuneHistory> filteredHistory) {
    // Get current month data
    final now = DateTime.now();
    final monthlyData = filteredHistory.where((item) {
      return item.createdAt.year == now.year &&
          item.createdAt.month == now.month;
    }).toList();

    // Calculate average score
    double avgScore = 0;
    if (monthlyData.isNotEmpty) {
      final scores = monthlyData
          .where((item) => item.summary['score'] != null)
          .map((item) => (item.summary['score'] as num).toDouble())
          .toList();
      if (scores.isNotEmpty) {
        avgScore = scores.reduce((a, b) => a + b) / scores.length;
      }
    }

    // Count fortune types
    final typeCounts = <String, int>{};
    for (final item in filteredHistory) {
      typeCounts[item.fortuneType] = (typeCounts[item.fortuneType] ?? 0) + 1;
    }

    // Find most frequent type
    String mostFrequentType = '일일운세';
    if (typeCounts.isNotEmpty) {
      final sorted = typeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostFrequentType = _getTypeName(sorted.first.key);
    }

    return FortuneStatistics(
      monthlyCount: monthlyData.length,
      averageScore: avgScore,
      mostFrequentCategory: mostFrequentType,
      totalCount: filteredHistory.length,
      typeCounts: typeCounts,
    );
  }

  String _getTypeName(String type) {
    final typeNames = {
      'daily': '일일운세',
      'weekly': '주간운세',
      'monthly': '월간운세',
      'love': '연애운',
      'money': '금전운',
      'career': '직업운',
      'health': '건강운',
      'moving': '이사운',
      'wish': '소원운',
      'traditional': '전통사주',
      'tarot': '타로',
      'dream': '꿈해몽',
      'face': '관상',
    };
    return typeNames[type] ?? type;
  }

  Widget _buildTimelineView(List<FortuneHistory> filteredHistory) {
    return TimelineView(
      history: filteredHistory,
      fontScale: 1.0,
      onItemTap: (FortuneHistory item) {
        context.push('/fortune-history/${item.id}', extra: item);
      },
    );
  }

  Widget _buildStatisticsView(FortuneStatistics statistics, double fontScale) {
    // Convert FortuneStatistics to UserStatistics for the dashboard widget
    final userStats = UserStatistics(
      totalCount: statistics.totalCount,
      monthlyCount: statistics.monthlyCount,
      averageScore: statistics.averageScore,
      categoryCount: statistics.typeCounts,
      mostFrequentCategory: statistics.mostFrequentCategory,
      lastFortuneDate:
          DateTime.now(), // You can get this from the most recent history item
    );
    return StatisticsDashboard(statistics: userStats, fontScale: fontScale);
  }

  Widget _buildChartsView(
      List<FortuneHistory> filteredHistory, double fontScale) {
    return FortuneCharts(
        filteredHistory: filteredHistory, fontScale: fontScale);
  }

  Widget _buildDailyFortuneCalendar(List<FortuneHistory> filteredHistory) {
    return FortuneCalendarView(history: filteredHistory);
  }

  Widget _buildChatInsightHistory() {
    return FutureBuilder<List<ChatInsightResult>>(
      future: InsightStorage.loadAll(),
      builder: (context, snapshot) {
        final colors = context.colors;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_outlined, color: colors.textTertiary, size: 48),
                const SizedBox(height: DSSpacing.md),
                Text(
                  '대화 분석 기록이 없어요',
                  style: context.heading2.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '카톡 대화를 분석하면 여기에 기록됩니다',
                  style: context.bodySmall.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(DSSpacing.md),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: DSSpacing.sm),
          itemBuilder: (context, index) {
            final result = results[index];
            return InsightHistoryCard(
              result: result,
              onDelete: () async {
                await InsightStorage.delete(result.analysisMeta.id);
                setState(() {}); // rebuild to refresh FutureBuilder
              },
            );
          },
        );
      },
    );
  }

  void _showFilterOptions() {
    // Mock filter options
  }
}

// Fortune statistics class
class FortuneStatistics {
  final int monthlyCount;
  final double averageScore;
  final String mostFrequentCategory;
  final int totalCount;
  final Map<String, int> typeCounts;

  FortuneStatistics({
    required this.monthlyCount,
    required this.averageScore,
    required this.mostFrequentCategory,
    required this.totalCount,
    required this.typeCounts,
  });
}
