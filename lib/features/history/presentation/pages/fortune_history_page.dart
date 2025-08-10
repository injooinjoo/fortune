import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/fortune_type_names.dart';
import '../../../../core/utils/haptic_utils.dart';
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
    _tabController = TabController(length: 3, vsync: this);
    
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
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '운세 기록',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFilterOptions)]),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2))]),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.primary),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                labelStyle: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: '타임라인'),
                  Tab(text: '통계'),
                  Tab(text: '차트')])),
            
            // Tab Content
            Expanded(
              child: historyState.when(
                data: (history) {
                  if (history.isEmpty) {
                    return _buildEmptyState(fontScale);
                  }
                  
                  final filteredHistory = _filterHistory(history);
                  final statistics = _calculateStatistics(filteredHistory);
                  
                  return TabBarView(
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
                              fontScale: fontScale)]))]);
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    '운세 기록을 불러올 수 없습니다',
                    style: TextStyle(fontSize: 16 * fontScale)))))])),
      bottomNavigationBar: const FortuneBottomNavigationBar(
        currentIndex: 3));
  }

  Widget _buildEmptyState(double fontScale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            '아직 운세 기록이 없습니다',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '운세를 보고 나면 여기에 기록됩니다',
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))]));
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
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
              style: TextStyle(fontSize: 14 * fontScale))),
          const SizedBox(height: 20),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '적용',
                style: TextStyle(fontSize: 16 * fontScale))))]));
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
}