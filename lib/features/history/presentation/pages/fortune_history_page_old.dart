import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/fortune_type_names.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../services/user_statistics_service.dart';
import '../../../../services/storage_service.dart';
import 'package:share_plus/share_plus.dart';

// Fortune history provider
final fortuneHistoryProvider = FutureProvider.autoDispose<List<FortuneHistory>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
    final response = await apiClient.get(ApiEndpoints.fortuneHistory);
    
    if (response.data['success'] == true) {
      final historyList = response.data['data'] as List;
      return historyList.map((item) => FortuneHistory.fromJson(item)).toList(};
    } else {
      throw Exception(response.data['error'] ?? '운세 기록을 불러올 수 없습니다'};
    }
  } catch (e) {
    throw Exception('Fortune cached'};
  }
});

// User statistics provider
final userStatisticsProvider = FutureProvider.autoDispose<UserStatistics>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    throw Exception('사용자 정보를 찾을 수 없습니다'};
  }
  
  final statisticsService = UserStatisticsService(supabase, StorageService());
  return await statisticsService.getUserStatistics(userId);
});

// Fortune history model
class FortuneHistory {
  final String id;
  final String fortuneType;
  final String title;
  final DateTime createdAt;
  final Map<String, dynamic> summary;
  final int tokenUsed;

  FortuneHistory({
    required this.id,
    required this.fortuneType,
    required this.title,
    required this.createdAt,
    required this.summary,
    required this.tokenUsed});

  factory FortuneHistory.fromJson(Map<String, dynamic> json) {
    return FortuneHistory(
      id: json['id'] ?? '',
      fortuneType: json['fortune_type'] ?? '',
      title: json['title'] ?? '운세',
      createdAt: DateTime.parse(json['created_at'],
      summary: json['summary'],
      tokenUsed: json['token_used']};
  }
}

class FortuneHistoryPage extends ConsumerStatefulWidget {
  const FortuneHistoryPage({super.key});

  @override
  ConsumerState<FortuneHistoryPage> createState() => _FortuneHistoryPageState();
}

class _FortuneHistoryPageState extends ConsumerState<FortuneHistoryPage> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all': 'daily': 'love', 'wealth', 'career', 'health'];
  DateTimeRange? _selectedDateRange;
  
  Widget _buildStatisticsDashboard(BuildContext context, UserStatistics statistics, double fontScale) {
    final theme = Theme.of(context};
    
    // Find most used fortune type
    String? mostUsedType;
    int maxCount = 0;
    statistics.fortuneTypeCount.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedType = type;
      }
    });
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 운세 통계',
            style: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Stats cards grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                context: context,
                icon: Icons.auto_awesome,
                title: '총 운세',
                value: '${statistics.totalFortunes}회',
                color: Colors.purple,
                fontScale: fontScale),
              _buildStatCard(
                context: context,
                icon: Icons.local_fire_department,
                title: '연속 접속',
                value: '${statistics.consecutiveDays}일',
                color: Colors.orange,
                fontScale: fontScale),
              _buildStatCard(
                context: context,
                icon: Icons.toll,
                title: '사용 토큰',
                value: '${statistics.totalTokensUsed}개',
                color: Colors.blue,
                fontScale: fontScale),
              _buildStatCard(
                context: context,
                icon: Icons.favorite,
                title: '즐겨찾는 운세',
                value: mostUsedType != null ? FortuneTypeNames.getName(mostUsedType!) : '-',
                color: Colors.pink,
                fontScale: fontScale,
                isText: true)]),
          
          const SizedBox(height: 20),
          
          // Insights section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.primary.withOpacity(0.02)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.1)),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                  size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getPersonalizedInsight(statistics),
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      color: theme.colorScheme.onSurface.withOpacity(0.8))])]));
  }
  
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double fontScale,
    bool isText = false}) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05)]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: theme.colorScheme.onSurface.withOpacity(0.7)))]),
            Text(
              value,
              style: TextStyle(
                fontSize: isText ? 16 * fontScale : 20 * fontScale,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
              overflow: TextOverflow.ellipsis)]))};
  }
  
  String _getPersonalizedInsight(UserStatistics statistics) {
    // Generate personalized insights based on user statistics
    if (statistics.consecutiveDays >= 7) {
      return '🎆 일주일 연속 접속하셨네요! 꾸준한 운세 확인이 행운을 불러옵니다.';
    }
    
    if (statistics.totalFortunes > 50) {
      return '✨ 이미 $statistics.totalFortunes번의 운세를 확인하셨네요! 당신은 진정한 운세 마스터입니다.';
    }
    
    String? favoriteType = statistics.favoriteFortuneType;
    if (favoriteType != null) {
      final typeName = FortuneTypeNames.getName(favoriteType};
      return '💕 $typeName을(를) 가장 많이 확인하셨네요. 오늘도 확인해보세요!';
    }
    
    return '🌟 다양한 운세를 확인하고 나만의 행운을 찾아보세요!';
  }
  
  // Group history by month for trend chart
  Map<String, int> _groupHistoryByMonth(List<FortuneHistory> history) {
    final Map<String, int> monthlyData = {};
    final now = DateTime.now();
    
    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('yyyy-MM').format(month};
      monthlyData[key] = 0;
    }
    
    // Count fortunes per month
    for (final item in history) {
      final key = DateFormat('yyyy-MM').format(item.createdAt};
      if (monthlyData.containsKey(key)) {
        monthlyData[key] = monthlyData[key]! + 1;
      }
    }
    
    return monthlyData;
  }
  
  // Group history by category for pie chart
  Map<String, int> _groupHistoryByCategory(List<FortuneHistory> history) {
    final Map<String, int> categoryData = {};
    
    for (final item in history) {
      final category = FortuneTypeNames.getCategory(item.fortuneType};
      categoryData[category] = (categoryData[category] ?? 0) + 1;
    }
    
    return categoryData;
  }
  
  // Build category distribution pie chart
  Widget _buildCategoryPieChart(BuildContext context, List<FortuneHistory> history, double fontScale) {
    final theme = Theme.of(context);
    final categoryData = _groupHistoryByCategory(history);
    final total = categoryData.values.fold(0, (sum, count) => sum + count);
    
    if (total == 0) return const SizedBox.shrink()
    
    final colors = [
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.indigo,
      Colors.cyan];
    
    int colorIndex = 0;
    final sections = categoryData.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12 * fontScale,
          fontWeight: FontWeight.bold,
          color: Colors.white)};
    }).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리별 분포',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pie chart
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(enabled: false)),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryData.entries.map((entry) {
                    final index = categoryData.keys.toList().indexOf(entry.key);
                    final color = colors[index % colors.length];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                          const SizedBox(width: 8},
                          Expanded(
                            child: Text(
                              '${entry.key} (${entry.value}회)',
                              style: TextStyle(
                                fontSize: 12 * fontScale,
                                color: theme.colorScheme.onSurface.withOpacity(0.8)),
                              overflow: TextOverflow.ellipsis)]);
                  }).toList()))])]));
  }
  
  // Build monthly trend chart
  Widget _buildMonthlyTrendChart(BuildContext context, List<FortuneHistory> history, double fontScale) {
    final theme = Theme.of(context);
    final monthlyData = _groupHistoryByMonth(history);
    final months = monthlyData.keys.toList();
    final values = monthlyData.values.toList();
    final maxValue = values.isEmpty ? 10 : values.reduce((a, b) => a > b ? a : b).toDouble() + 5;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월별 운세 조회 트렌드',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1)),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 1);
                  }),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          final month = months[value.toInt()];
                          final date = DateFormat('yyyy-MM').parse(month);
                          return Text(
                            DateFormat('M월'),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12));
                        }
                        return const Text('');
                      })),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12));
                      })),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1),
                    left: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1)),
                minX: 0,
                maxX: months.length - 1,
                minY: 0,
                maxY: maxValue.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: values.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface);
                      }),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withOpacity(0.1))]))]));
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
    if (_selectedFilter == 'all') return filtered;
    
    return filtered.where((item) {
      switch (_selectedFilter) {
        case 'daily':
          return item.fortuneType.contains('daily') || 
                 item.fortuneType.contains('today') || 
                 item.fortuneType.contains('tomorrow');
        case 'love':
          return item.fortuneType.contains('love') || 
                 item.fortuneType.contains('compatibility') || 
                 item.fortuneType.contains('marriage');
        case 'wealth':
          return item.fortuneType.contains('wealth') || 
                 item.fortuneType.contains('investment') || 
                 item.fortuneType.contains('business');
        case 'career':
          return item.fortuneType.contains('career') || 
                 item.fortuneType.contains('job') || 
                 item.fortuneType.contains('employment');
        case 'health':
          return item.fortuneType.contains('health') || 
                 item.fortuneType.contains('biorhythm'};
        default:
          return true;
      }
    }).toList();
  }

  String _getFortuneIcon(String fortuneType) {
    if (fortuneType.contains('love') || fortuneType.contains('compatibility')) return '❤️';
    if (fortuneType.contains('wealth') || fortuneType.contains('investment')) return '💰';
    if (fortuneType.contains('career') || fortuneType.contains('job')) return '💼';
    if (fortuneType.contains('health')) return '🏥';
    if (fortuneType.contains('daily') || fortuneType.contains('today')) return '☀️';
    if (fortuneType.contains('mbti')) return '🧠';
    if (fortuneType.contains('zodiac')) return '✨';
    return '🔮';
  }

  Color _getFortuneColor(String fortuneType) {
    if (fortuneType.contains('love') || fortuneType.contains('compatibility')) return Colors.pink;
    if (fortuneType.contains('wealth') || fortuneType.contains('investment')) return Colors.green;
    if (fortuneType.contains('career') || fortuneType.contains('job')) return Colors.blue;
    if (fortuneType.contains('health')) return Colors.orange;
    return Colors.purple;
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  Widget _buildLuckyItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double fontScale}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10 * fontScale,
                      color: color.withOpacity(0.8)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 11 * fontScale,
                      color: color,
                      fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)])])};
  }
  
  Future<void> _shareFortuneDetail(FortuneHistory item) async {
    final score = item.summary['score'] as int? ?? 0;
    final content = item.summary['content'] as String? ?? '';
    final keywords = (item.summary['keywords'] as List?)?.join(': ') ?? '';
    
    String shareText = '''날짜: ${DateFormat('yyyy년 M월 d일').format(item.createdAt)}
점수: $score점

${content.isNotEmpty ? '내용:\n$content\n' : ''}
${keywords.isNotEmpty ? '🏷️ 키워드: $keywords\n' : ''}

Fortune 앱에서 나만의 운세를 확인해보세요!
https://fortune.app''';
    
    await Share.share(
      shareText,
      subject: '${item.title} - Fortune 운세');
  }
  
  Widget _buildTimelineView(BuildContext context, List<FortuneHistory> history, double fontScale) {
    final theme = Theme.of(context);
    
    // Group history by month
    final Map<String, List<FortuneHistory>> groupedByMonth = {};
    for (final item in history) {
      final monthKey = DateFormat('yyyy-MM').format(item.createdAt);
      groupedByMonth.putIfAbsent(monthKey, () => []).add(item);
    }
    
    // Sort months in descending order
    final sortedMonths = groupedByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (sortedMonths.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 운세 여정',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Timeline
          ...sortedMonths.take(3).map((month) {
            final monthData = groupedByMonth[month]!;
            final date = DateFormat('yyyy-MM').parse(month);
            final isCurrentMonth = month == DateFormat('yyyy-MM').format(DateTime.now());
            
            // Calculate average score for the month
            final scores = monthData
                .where((item) => item.summary['score'] != null)
                .map((item) => item.summary['score'] as int)
                .toList();
            final avgScore = scores.isEmpty 
                ? 0 
                : (scores.reduce((a, b) => a + b) / scores.length).round();
            
            // Count fortune types
            final Map<String, int> typeCount = {};
            for (final item in monthData) {
              final type = FortuneTypeNames.getName(item.fortuneType);
              typeCount[type] = (typeCount[type] ?? 0) + 1;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isCurrentMonth 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.primary.withOpacity(0.5),
                          shape: BoxShape.circle)),
                      if (month != sortedMonths.last)
                        Container(
                          width: 2,
                          height: 80,
                          color: theme.colorScheme.primary.withOpacity(0.2))]),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy년 M월'),
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.bold)),
                              if (avgScore > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(avgScore).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  child: Text(
                                    '평균 ${avgScore}점',
                                    style: TextStyle(
                                      fontSize: 12 * fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: _getScoreColor(avgScore)))]),
                          const SizedBox(height: 8),
                          
                          // Fortune type breakdown
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: typeCount.entries.take(3).map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)},
                                child: Text(
                                  '${entry.key} x${entry.value}',
                                  style: TextStyle(
                                    fontSize: 11 * fontScale,
                                    color: theme.colorScheme.primary)));
                            }).toList()),
                          
                          // Achievement badges
                          if (monthData.length >= 20) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 16,
                                  color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '이달의 운세 마스터!',
                                  style: TextStyle(
                                    fontSize: 12 * fontScale,
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.w600))])]]))]);
          }).toList()]));
  }
  
  void _showFortuneDetail(BuildContext context, FortuneHistory item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          final color = _getFortuneColor(item.fortuneType);
          
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            _getFortuneIcon(item.fortuneType),
                            style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold)),
                            Text(
                              DateFormat('HH:mm')$1',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6))]),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop()]),
                
                const Divider(height: 1),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Score section
                        if (item.summary['score'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.1),
                                  color.withOpacity(0.05)]),
                              borderRadius: BorderRadius.circular(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '운세 점수',
                                  style: theme.textTheme.titleMedium},
                                Text(
                                  '${item.summary['score']}점',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: _getScoreColor(item.summary['score'],
                                    fontWeight: FontWeight.bold)]),
                          const SizedBox(height: 20)],
                        
                        // Summary content
                        if (item.summary['content'] != null) ...[
                          Text(
                            '운세 내용',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            item.summary['content'] ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6)),
                          const SizedBox(height: 20)],
                        
                        // Keywords
                        if (item.summary['keywords'] != null) ...[
                          Text(
                            '핵심 키워드',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (item.summary['keywords'] as List).map<Widget>((keyword) {
                              return Chip(
                                label: Text(keyword.toString()),
                                backgroundColor: color.withOpacity(0.1),
                                side: BorderSide(
                                  color: color.withOpacity(0.3))};
                            }).toList()),
                          const SizedBox(height: 20)],
                        
                        // Lucky items
                        if (item.summary['luckyItems'] != null) ...[
                          Text(
                            '행운 아이템',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...((item.summary['luckyItems'] as Map).entries.map<Widget>((entry) {
                            IconData icon;
                            String label;
                            switch (entry.key) {
                              case 'color':
                                icon = Icons.palette;
                                label = '행운의 색';
                                break;
                              case 'number':
                                icon = Icons.looks_one;
                                label = '행운의 숫자';
                                break;
                              case 'item':
                                icon = Icons.diamond;
                                label = '행운의 물건';
                                break;
                              default:
                                icon = Icons.star;
                                label = entry.key;
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(icon, size: 20, color: color),
                                  const SizedBox(width: 12),
                                  Text(
                                    label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  const Spacer(),
                                  Text(
                                    entry.value.toString(),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600)]);
                          }).toList())],
                        
                        const SizedBox(height: 40),
                        
                        // Share button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Implement share functionality
                              await _shareFortuneDetail(item};
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('운세 공유하기'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)))]))]));
        }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final historyAsync = ref.watch(fortuneHistoryProvider);
    final statisticsAsync = ref.watch(userStatisticsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '운세 기록',
              showBackButton: true,
              showTokenBalance: true),
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(child: LoadingIndicator(size: 60)),
                error: (error, stack) => '',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          '운세 기록을 불러올 수 없습니다',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        GlassButton(
                          onPressed: () => ref.invalidate(fortuneHistoryProvider),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text('다시 시도'))]),
                data: (history) {
                  final filteredHistory = _filterHistory(history);
                  
                  return CustomScrollView(
                    slivers: [
                      // Statistics Dashboard
                      SliverToBoxAdapter(
                        child: statisticsAsync.when(
                          loading: () => const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (statistics) => _buildStatisticsDashboard(context, statistics, fontScale)),
                      
                      // Monthly trend chart
                      SliverToBoxAdapter(
                        child: statisticsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (_) => _buildMonthlyTrendChart(context, history, fontScale)),
                      
                      // Timeline View
                      SliverToBoxAdapter(
                        child: _buildTimelineView(context, history, fontScale)),
                      
                      // Category distribution pie chart
                      SliverToBoxAdapter(
                        child: statisticsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (_) => _buildCategoryPieChart(context, history, fontScale)),
                      
                      // Filter section
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Date range selector
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        final range = await showDateRangePicker(
                                          context: context,
                                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                          lastDate: DateTime.now(),
                                          initialDateRange: _selectedDateRange,
                                          builder: (context, child) {
                                            return Theme(
                                              data: theme.copyWith(
                                                colorScheme: theme.colorScheme.copyWith(
                                                  primary: theme.colorScheme.primary)),
                                              child: child!};
                                          });
                                        
                                        if (range != null) {
                                          setState(() {
                                            _selectedDateRange = range;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedDateRange != null
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.outline.withOpacity(0.3)),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              size: 20,
                                              color: _selectedDateRange != null
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurface.withOpacity(0.6)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _selectedDateRange != null
                                                    ? '${DateFormat('M/d').format(_selectedDateRange!.start)} - ${DateFormat('M/d').format(_selectedDateRange!.end)}'
                                                    : '기간 선택',
                                                style: TextStyle(
                                                  fontSize: 14 * fontScale,
                                                  color: _selectedDateRange != null
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                                  fontWeight: _selectedDateRange != null
                                                      ? FontWeight.w600
                                                      : FontWeight.normal)),
                                            if (_selectedDateRange != null)
                                              IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  size: 18,
                                                  color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedDateRange = null;
                                                  });
                                                },
                                                constraints: const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32),
                                                padding: EdgeInsets.zero)]))]),
                            
                            // Category filter chips
                            Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = _selectedFilter == filter;
                            final filterLabels = {
                              'all': '전체',
                              'daily': '일일 운세',
                              'love': '연애/결혼',
                              'wealth': '재물/투자',
                              'career': '직업/사업',
                              'health': '건강'};
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  filterLabels[filter] ?? filter,
                                  style: TextStyle(fontSize: 14 * fontScale)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                                backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                                checkmarkColor: theme.colorScheme.primary));
                          })]),
                      
                      // History list
                      filteredHistory.isEmpty
                            ? SliverFillRemaining(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 64,
                                        color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                      const SizedBox(height: 16),
                                      Text(
                                        '운세 기록이 없습니다',
                                        style: TextStyle(
                                          fontSize: 18 * fontScale,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7))]))
                            : SliverPadding(
                                padding: const EdgeInsets.all(16),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  final item = filteredHistory[index];
                                  final color = _getFortuneColor(item.fortuneType);
                                  
                                  // Score from summary if available
                                  final score = item.summary['score'] as int? ?? 0;
                                  final luckyItems = item.summary['luckyItems'] as Map<String, dynamic>?;
                                  final keywords = item.summary['keywords'] as List<dynamic>?;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showFortuneDetail(context, item};
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              color.withOpacity(0.15),
                                              color.withOpacity(0.05)]),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: color.withOpacity(0.2),
                                            width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4))]),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Header with score
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      color.withOpacity(0.3),
                                                      color.withOpacity(0.15)])),
                                                child: Row(
                                                  children: [
                                                    // Icon and title
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.9),
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: color.withOpacity(0.3),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2))]),
                                                      child: Center(
                                                        child: Text(
                                                          _getFortuneIcon(item.fortuneType),
                                                          style: const TextStyle(fontSize: 24)),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            item.title,
                                                            style: TextStyle(
                                                              fontSize: 16 * fontScale,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white)),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            DateFormat('HH:mm'), 'ko': null,
                                                            style: TextStyle(
                                                              fontSize: 12 * fontScale,
                                                              color: Colors.white.withOpacity(0.8))]),
                                                    // Score gauge
                                                    if (score > 0)
                                                      Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          SizedBox(
                                                            width: 60,
                                                            height: 60,
                                                            child: CircularProgressIndicator(
                                                              value: score / 100,
                                                              strokeWidth: 6,
                                                              backgroundColor: Colors.white.withOpacity(0.2),
                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                _getScoreColor(score)),
                                                          Text(
                                                            '$score',
                                                            style: TextStyle(
                                                              fontSize: 18 * fontScale,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white))])])),
                                              
                                              // Content
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Keywords or summary
                                                    if (keywords != null && keywords.isNotEmpty) ...[
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: keywords.take(3).map((keyword) {
                                                          return Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: color.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(16),
                                                              border: Border.all(
                                                                color: color.withOpacity(0.3)),
                                                            child: Text(
                                                              keyword.toString(),
                                                              style: TextStyle(
                                                                fontSize: 12 * fontScale,
                                                                color: color,
                                                                fontWeight: FontWeight.w600))};
                                                        }).toList()),
                                                      const SizedBox(height: 12)] else if (item.summary['brief'] != null) ...[
                                                      Text(
                                                        item.summary['brief'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 14 * fontScale,
                                                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                                                          height: 1.4),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis),
                                                      const SizedBox(height: 12)],
                                                    
                                                    // Lucky items
                                                    if (luckyItems != null && luckyItems.isNotEmpty)
                                                      Row(
                                                        children: [
                                                          if (luckyItems['color'] != null)
                                                            _buildLuckyItem(
                                                              icon: Icons.palette,
                                                              label: '색상',
                                                              value: luckyItems['color'],
                                                              color: color,
                                                              fontScale: fontScale),
                                                          if (luckyItems['number'] != null)
                                                            _buildLuckyItem(
                                                              icon: Icons.looks_one,
                                                              label: '숫자',
                                                              value: luckyItems['number'],
                                                              color: color,
                                                              fontScale: fontScale)]),
                                                    
                                                    // Bottom info
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        // Category badge
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: theme.colorScheme.surface,
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: theme.colorScheme.outline.withOpacity(0.2)),
                                                          child: Text(
                                                            FortuneTypeNames.getCategory(item.fortuneType),
                                                            style: TextStyle(
                                                              fontSize: 11 * fontScale,
                                                              color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                                        // Token info
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.toll,
                                                              size: 16,
                                                              color: theme.colorScheme.primary),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${item.tokenUsed} 토큰',
                                                              style: TextStyle(
                                                                fontSize: 12 * fontScale,
                                                                color: theme.colorScheme.primary,
                                                                fontWeight: FontWeight.w600))])])])])));
                                    },
                                    childCount: filteredHistory.length)))]);
                })]));
  }
}