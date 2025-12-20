import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/theme/toss_theme.dart';
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
    _tabController = TabController(length: 4, vsync: this);
    
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

    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      appBar: AppHeader(
        title: '운세 기록',
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: TossTheme.textGray600),
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
              const SizedBox(height: TossTheme.spacingL),
              
              // 토스 스타일 탭 바
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
                child: Row(
                  children: [
                    _buildTabButton(0, '타임라인'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(1, '통계'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(2, '차트'),
                    const SizedBox(width: DSSpacing.sm),
                    _buildTabButton(3, '일일운세'),
                  ],
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 이번 달 요약 카드 (토스 스타일)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
                child: AppCard(
                  padding: const EdgeInsets.all(TossTheme.spacingL),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '이번 달 요약',
                            style: TossTheme.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('yyyy년 MM월').format(DateTime.now()),
                            style: TossTheme.caption.copyWith(
                              color: TossTheme.textGray600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TossTheme.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${statistics.monthlyCount}',
                                  style: TossTheme.heading1.copyWith(
                                    color: TossTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '운세 조회',
                                  style: TossTheme.caption.copyWith(
                                    color: TossTheme.textGray600,
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
                                  style: TossTheme.heading1.copyWith(
                                    color: TossTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '평균 점수',
                                  style: TossTheme.caption.copyWith(
                                    color: TossTheme.textGray600,
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
                                  style: TossTheme.heading2.copyWith(
                                    color: TossTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '자주 본 운세',
                                  style: TossTheme.caption.copyWith(
                                    color: TossTheme.textGray600,
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
              
              const SizedBox(height: TossTheme.spacingL),
              
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
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(
            '운세 기록을 불러올 수 없습니다',
            style: DSTypography.labelMedium,
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
          style: DSTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyState(double fontScale) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(TossTheme.spacingXL),
        child: AppCard(
          padding: const EdgeInsets.all(TossTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📜',
                style: DSTypography.displayLarge,
              ),
              const SizedBox(height: TossTheme.spacingL),
              Text(
                '아직 운세 기록이 없어요',
                style: TossTheme.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossTheme.spacingS),
              Text(
                '운세를 보고 나면 여기에 기록됩니다',
                style: TossTheme.body2.copyWith(
                  color: TossTheme.textGray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossTheme.spacingL),
              UnifiedButton(
                text: '운세 보러 가기',
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
               item.createdAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
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
      lastFortuneDate: DateTime.now(), // You can get this from the most recent history item
    );
    return StatisticsDashboard(statistics: userStats, fontScale: fontScale);
  }

  Widget _buildChartsView(List<FortuneHistory> filteredHistory, double fontScale) {
    return FortuneCharts(filteredHistory: filteredHistory, fontScale: fontScale);
  }

  Widget _buildDailyFortuneCalendar(List<FortuneHistory> filteredHistory) {
    return FortuneCalendarView(history: filteredHistory);
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