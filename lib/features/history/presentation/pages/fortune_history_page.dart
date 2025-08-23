import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/fortune_type_names.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/fortune_history_provider.dart';
import '../../../../presentation/widgets/fortune_explanation_bottom_sheet.dart';
import '../../domain/models/fortune_history.dart';
import '../widgets/statistics_dashboard.dart';
import '../widgets/fortune_charts.dart';
import '../widgets/timeline_view.dart';
import '../widgets/fortune_calendar_view.dart';

class FortuneHistoryPage extends ConsumerStatefulWidget {
  const FortuneHistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FortuneHistoryPage> createState() => _FortuneHistoryPageState();
}

class _FortuneHistoryPageState extends ConsumerState<FortuneHistoryPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
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
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final historyState = ref.watch(fortuneHistoryProvider);
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 토스 스타일 헤더
            Container(
              padding: const EdgeInsets.all(TossTheme.spacingL),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: TossTheme.textBlack),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      '운세 기록',
                      style: TossTheme.heading2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: TossTheme.textBlack),
                    onPressed: _showFilterOptions,
                  ),
                ],
              ),
            ),
            
            // 토스 스타일 탭 바
            Container(
              margin: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
              child: Row(
                children: [
                  Expanded(
                    child: TossCard(
                      onTap: () => setState(() => _tabController.index = 0),
                      style: _tabController.index == 0 
                        ? TossCardStyle.filled 
                        : TossCardStyle.outlined,
                      padding: const EdgeInsets.symmetric(
                        vertical: TossTheme.spacingS, 
                        horizontal: TossTheme.spacingM,
                      ),
                      child: Text(
                        '타임라인',
                        style: TossTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 0 
                            ? Colors.white 
                            : TossTheme.textGray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: TossTheme.spacingS),
                  Expanded(
                    child: TossCard(
                      onTap: () => setState(() => _tabController.index = 1),
                      style: _tabController.index == 1 
                        ? TossCardStyle.filled 
                        : TossCardStyle.outlined,
                      padding: const EdgeInsets.symmetric(
                        vertical: TossTheme.spacingS, 
                        horizontal: TossTheme.spacingM,
                      ),
                      child: Text(
                        '통계',
                        style: TossTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 1 
                            ? Colors.white 
                            : TossTheme.textGray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: TossTheme.spacingS),
                  Expanded(
                    child: TossCard(
                      onTap: () => setState(() => _tabController.index = 2),
                      style: _tabController.index == 2 
                        ? TossCardStyle.filled 
                        : TossCardStyle.outlined,
                      padding: const EdgeInsets.symmetric(
                        vertical: TossTheme.spacingS, 
                        horizontal: TossTheme.spacingM,
                      ),
                      child: Text(
                        '차트',
                        style: TossTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 2 
                            ? Colors.white 
                            : TossTheme.textGray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  // 일일 운세 탭
                  Expanded(
                    child: TossCard(
                      onTap: () => setState(() => _tabController.index = 3),
                      style: _tabController.index == 3 
                        ? TossCardStyle.filled 
                        : TossCardStyle.outlined,
                      padding: const EdgeInsets.symmetric(
                        horizontal: TossTheme.spacingM,
                        vertical: TossTheme.spacingS,
                      ),
                      child: Text(
                        '일일운세',
                        style: TossTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 3 
                            ? Colors.white 
                            : TossTheme.textGray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: TossTheme.spacingL),
            
            // Tab Content
            Expanded(
              child: historyState.when(
                data: (history) {
                  if (history.isEmpty) {
                    return _buildEmptyState(fontScale);
                  }
                  
                  final filteredHistory = _filterHistory(history);
                  final statistics = _calculateStatistics(filteredHistory);
                  
                  return Column(
                    children: [
                      // 이번 달 요약 카드 (토스 스타일)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
                        child: TossCard(
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
                                          '${statistics.averageScore.toStringAsFixed(1)}',
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
                            SingleChildScrollView(
                              child: TimelineView(
                                history: filteredHistory,
                                fontScale: fontScale,
                                onItemTap: _showFortuneDetail)),
                            
                            // Statistics Tab
                            SingleChildScrollView(
                              child: StatisticsDashboard(
                                statistics: statistics,
                                fontScale: fontScale)),
                            
                            // Charts Tab
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CategoryPieChart(
                                    history: filteredHistory,
                                    fontScale: fontScale),
                                  const SizedBox(height: 32),
                                  MonthlyTrendChart(
                                    history: filteredHistory,
                                    fontScale: fontScale),
                                ],
                              ),
                            ),
                            
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
                    style: TextStyle(fontSize: 16 * fontScale)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FortuneBottomNavigationBar(
        currentIndex: 3),
    );
  }

  Widget _buildEmptyState(double fontScale) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(TossTheme.spacingXL),
        child: TossCard(
          padding: const EdgeInsets.all(TossTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📜',
                style: TextStyle(fontSize: 64),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TossTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TossTheme.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '운세 보러 가기',
                    style: TossTheme.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
                   item.fortuneType.contains('job');
          case 'health':
            return item.fortuneType.contains('health');
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }

  UserStatistics _calculateStatistics(List<FortuneHistory> history) {
    if (history.isEmpty) {
      return UserStatistics(
        totalCount: 0,
        monthlyCount: 0,
        averageScore: 0,
        categoryCount: {},
        mostFrequentCategory: '',
        lastFortuneDate: DateTime.now());
    }
    
    // Calculate total and monthly count
    final now = DateTime.now();
    final thisMonthHistory = history.where((item) {
      return item.createdAt.year == now.year && item.createdAt.month == now.month;
    }).toList();
    
    // Calculate average score
    final scores = history
        .where((item) => item.summary['score'] != null)
        .map((item) => item.summary['score'] as int)
        .toList();
    final averageScore = scores.isEmpty 
        ? 0.0 
        : scores.reduce((a, b) => a + b) / scores.length;
    
    // Count by category
    final Map<String, int> categoryCount = {};
    for (final item in history) {
      final category = FortuneTypeNames.getName(item.fortuneType);
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    
    // Find most frequent category
    String mostFrequentCategory = '';
    int maxCount = 0;
    categoryCount.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentCategory = category;
      }
    });
    
    return UserStatistics(
      totalCount: history.length,
      monthlyCount: thisMonthHistory.length,
      averageScore: averageScore,
      categoryCount: categoryCount,
      mostFrequentCategory: mostFrequentCategory,
      lastFortuneDate: history.first.createdAt);
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet());
  }

  Widget _buildFilterSheet() {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '필터 옵션',
                style: TextStyle(
                  fontSize: 20 * fontScale,
                  fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'all';
                    _selectedDateRange = null;
                  });
                  Navigator.pop(context);
                },
                child: Text('초기화'))]),
          const SizedBox(height: 20),
          
          // Category Filter
          Text(
            '카테고리',
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('all', '전체', fontScale),
              _buildFilterChip('daily', '일일 운세', fontScale),
              _buildFilterChip('weekly', '주간 운세', fontScale),
              _buildFilterChip('monthly', '월간 운세', fontScale),
              _buildFilterChip('love', '연애운', fontScale),
              _buildFilterChip('money', '금전운', fontScale),
              _buildFilterChip('career', '직장운', fontScale),
              _buildFilterChip('health', '건강운', fontScale)]),
          const SizedBox(height: 20),
          
          // Date Range Filter
          Text(
            '기간',
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedDateRange);
              if (range != null) {
                setState(() {
                  _selectedDateRange = range;
                });
              }
            },
            icon: Icon(Icons.date_range),
            label: Text(
              _selectedDateRange != null
                  ? '${DateFormat('yyyy.MM.dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy.MM.dd').format(_selectedDateRange!.end)}'
                  : '기간 선택',
              style: TextStyle(fontSize: 14 * fontScale)),
          ),
          const SizedBox(height: 20),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '적용',
                style: TextStyle(fontSize: 16 * fontScale)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, double fontScale) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(fontSize: 14 * fontScale)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      });
  }

  void _showFortuneDetail(FortuneHistory item) {
    HapticUtils.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FortuneExplanationBottomSheet(
        fortuneType: item.fortuneType,
        fortuneData: item.summary));
  }

  Future<void> _shareFortuneDetail(FortuneHistory item) async {
    final score = item.summary['score'] as int? ?? 0;
    final content = item.summary['content'] as String? ?? '';
    final advice = item.summary['advice'] as String? ?? '';
    
    final shareText = '''
${item.title}
점수: $score점
날짜: ${DateFormat('yyyy년 MM월 dd일').format(item.createdAt)}

$content

조언: $advice

- Fortune 앱에서 공유 -
''';
    
    await Share.share(
      shareText,
      subject: '${item.title} - Fortune 운세');
  }

  Widget _buildDailyFortuneCalendar(List<FortuneHistory> history) {
    // 일일 운세만 필터링
    final dailyHistory = history.where((item) => item.fortuneType == 'daily').toList();
    
    return SingleChildScrollView(
      child: Column(
        children: [
          if (dailyHistory.isNotEmpty)
            FortuneCalendarView(
              history: dailyHistory,
              onDateTap: (fortuneHistory) {
                _showDailyFortuneDetail(fortuneHistory);
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(TossTheme.spacingXXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: TossTheme.textGray600,
                  ),
                  const SizedBox(height: TossTheme.spacingL),
                  Text(
                    '아직 일일 운세 기록이 없습니다',
                    style: TossTheme.heading2.copyWith(
                      color: TossTheme.textGray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TossTheme.spacingM),
                  Text(
                    '홈에서 오늘의 운세를 확인하면\n여기에서 기록을 볼 수 있습니다',
                    style: TossTheme.body2.copyWith(
                      color: TossTheme.textGray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDailyFortuneDetail(FortuneHistory fortuneHistory) {
    HapticUtils.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(TossTheme.radiusL),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(TossTheme.spacingL),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: TossTheme.borderGray200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fortuneHistory.title,
                            style: TossTheme.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: TossTheme.spacingXS),
                          Text(
                            DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(fortuneHistory.createdAt),
                            style: TossTheme.caption.copyWith(
                              color: TossTheme.textGray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(TossTheme.spacingL),
                  child: _buildDailyFortuneContent(fortuneHistory),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildDailyFortuneContent(FortuneHistory fortuneHistory) {
    final summary = fortuneHistory.summary;
    final score = summary['score'] as int? ?? 80;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 점수 표시
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getScoreColor(score),
                width: 8,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TossTheme.heading1.copyWith(
                      fontSize: 36,
                      color: _getScoreColor(score),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '점',
                    style: TossTheme.body2.copyWith(
                      color: _getScoreColor(score),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: TossTheme.spacingXL),
        
        // 운세 내용
        if (summary['content'] != null) ...[
          Text(
            '오늘의 운세',
            style: TossTheme.heading2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingL),
            decoration: BoxDecoration(
              color: TossTheme.borderGray200,
              borderRadius: BorderRadius.circular(TossTheme.radiusM),
            ),
            child: Text(
              summary['content'] as String,
              style: TossTheme.body1,
            ),
          ),
          const SizedBox(height: TossTheme.spacingL),
        ],
        
        // 행운 정보
        if (summary['luckyColor'] != null || summary['luckyNumber'] != null) ...[
          Text(
            '행운 아이템',
            style: TossTheme.heading2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          Row(
            children: [
              if (summary['luckyColor'] != null)
                Expanded(
                  child: _buildLuckyItem('🎨', '행운 색상', summary['luckyColor'] as String),
                ),
              if (summary['luckyColor'] != null && summary['luckyNumber'] != null)
                const SizedBox(width: TossTheme.spacingM),
              if (summary['luckyNumber'] != null)
                Expanded(
                  child: _buildLuckyItem('🔢', '행운 숫자', '${summary['luckyNumber']}'),
                ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingL),
        ],
        
        // 조언
        if (summary['advice'] != null) ...[
          Text(
            '오늘의 조언',
            style: TossTheme.heading2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossTheme.radiusM),
            ),
            child: Text(
              summary['advice'] as String,
              style: TossTheme.body1,
            ),
          ),
          const SizedBox(height: TossTheme.spacingL),
        ],
        
        // 주의사항
        if (summary['caution'] != null) ...[
          Text(
            '주의사항',
            style: TossTheme.heading2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossTheme.radiusM),
            ),
            child: Text(
              summary['caution'] as String,
              style: TossTheme.body1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLuckyItem(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        color: TossTheme.borderGray200,
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: TossTheme.spacingXS),
          Text(
            label,
            style: TossTheme.caption.copyWith(
              color: TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: TossTheme.spacingXS),
          Text(
            value,
            style: TossTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // green
    if (score >= 70) return TossTheme.primaryBlue;
    if (score >= 60) return const Color(0xFFF59E0B); // yellow
    return const Color(0xFFEF4444); // red
  }
}