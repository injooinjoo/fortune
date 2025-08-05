import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import '../../../../data/services/fortune_api_service.dart';
import 'dart:math' as math;

// Provider for user statistics
final userStatisticsProvider = FutureProvider.autoDispose<UserStatistics>((ref) async {
  final fortuneApiService = ref.read(fortuneApiServiceProvider);
  // This would typically fetch from an API
  // For now, we'll use mock data
  return UserStatistics.mock();
});

class UserStatistics {
  final int totalFortunes;
  final int consecutiveDays;
  final int totalTokensEarned;
  final int totalTokensSpent;
  final String favoriteFortune;
  final Map<String, int> fortuneTypeCount;
  final List<DailyActivity> weeklyActivity;
  final List<FortuneScore> fortuneScoreHistory;
  final Map<String, double> categoryDistribution;
  final int achievementCount;
  final double profileCompletion;
  final DateTime memberSince;
  final int totalShares;
  final double averageFortuneScore;
  
  UserStatistics({
    required this.totalFortunes,
    required this.consecutiveDays,
    required this.totalTokensEarned,
    required this.totalTokensSpent,
    required this.favoriteFortune,
    required this.fortuneTypeCount,
    required this.weeklyActivity,
    required this.fortuneScoreHistory,
    required this.categoryDistribution,
    required this.achievementCount,
    required this.profileCompletion,
    required this.memberSince,
    required this.totalShares,
    required this.averageFortuneScore});
  
  factory UserStatistics.mock() {
    final random = math.Random();
    final now = DateTime.now();
    
    return UserStatistics(
      totalFortunes: 156,
      consecutiveDays: 12,
      totalTokensEarned: 3420,
      totalTokensSpent: 2890,
      favoriteFortune: '오늘의 운세',
      fortuneTypeCount: {
        '오늘의 운세': 45,
        '연애운': 32,
        '재물운': 28,
        '건강운': 21,
        'MBTI 운세': 18,
        '타로 운세': 12},
      weeklyActivity: List.generate(7, (index) => DailyActivity(
        date: now.subtract(Duration(days: 6 - index)),
        count: random.nextInt(5) + 1)),
      fortuneScoreHistory: List.generate(30, (index) => FortuneScore(
        date: now.subtract(Duration(days: 29 - index)),
        score: random.nextInt(30) + 70)),
      categoryDistribution: {
        '일일운세': 0.28,
        '연애/결혼': 0.22,
        '재물/사업': 0.18,
        '건강': 0.15,
        '성격/심리': 0.12,
        '기타': 0.05},
      achievementCount: 8,
      profileCompletion: 0.85,
      memberSince: now.subtract(const Duration(days: 180)),
      totalShares: 23,
      averageFortuneScore: 82.5);
  }
}

class DailyActivity {
  final DateTime date;
  final int count;
  
  DailyActivity({required this.date, required this.count});
}

class FortuneScore {
  final DateTime date;
  final int score;
  
  FortuneScore({required this.date, required this.score});
}

class StatisticsDetailPage extends ConsumerStatefulWidget {
  const StatisticsDetailPage({super.key});

  @override
  ConsumerState<StatisticsDetailPage> createState() => _StatisticsDetailPageState();
}

class _StatisticsDetailPageState extends ConsumerState<StatisticsDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 7; // 7, 30, 90 days
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final statsAsync = ref.watch(userStatisticsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop()),
        title: Text(
          '상세 통계',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '개요'),
            Tab(text: '활동 분석'),
            Tab(text: '성과 지표')])),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                '통계를 불러올 수 없습니다',
                style: TextStyle(fontSize: 16 * fontScale))])),
        data: (stats) => TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            _buildOverviewTab(stats, fontScale),
            // Activity Analysis Tab
            _buildActivityTab(stats, fontScale),
            // Performance Tab
            _buildPerformanceTab(stats, fontScale)])));
  }
  
  Widget _buildOverviewTab(UserStatistics stats, double fontScale) {
    final memberDays = DateTime.now().difference(stats.memberSince).inDays;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: '총 운세 조회',
                  value: stats.totalFortunes.toString(),
                  icon: Icons.visibility,
                  color: Colors.blue,
                  fontScale: fontScale)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: '연속 접속일',
                  value: '${stats.consecutiveDays}일',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  fontScale: fontScale))]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: '평균 운세 점수',
                  value: '${stats.averageFortuneScore.toStringAsFixed(1)}점',
                  icon: Icons.score,
                  color: Colors.green,
                  fontScale: fontScale)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: '회원 기간',
                  value: '$memberDays일',
                  icon: Icons.cake,
                  color: Colors.purple,
                  fontScale: fontScale))]),
          
          // Profile Completion
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '프로필 완성도',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600)),
                    Text(
                      '${(stats.profileCompletion * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary))]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: stats.profileCompletion,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8)),
                const SizedBox(height: 8),
                Text(
                  '프로필을 완성하면 더 정확한 운세를 받을 수 있어요',
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: AppColors.textSecondary))])),
          
          // Token Statistics
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.1),
                  Colors.orange.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.token, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '토큰 사용 현황',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600))]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '획득',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalTokensEarned}',
                          style: TextStyle(
                            fontSize: 20 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.green))]),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider),
                    Column(
                      children: [
                        Text(
                          '사용',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalTokensSpent}',
                          style: TextStyle(
                            fontSize: 20 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.red))]),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider),
                    Column(
                      children: [
                        Text(
                          '잔액',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalTokensEarned - stats.totalTokensSpent}',
                          style: TextStyle(
                            fontSize: 20 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary))])])])),
          
          // Achievements
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '달성 업적',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.w600))]),
                    Text(
                      '${stats.achievementCount}개',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary))]),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAchievementBadge('첫 운세', true, fontScale),
                    _buildAchievementBadge('일주일 연속', true, fontScale),
                    _buildAchievementBadge('운세 마스터', false, fontScale),
                    _buildAchievementBadge('공유왕', true, fontScale),
                    _buildAchievementBadge('100일 달성', false, fontScale)])]))]));
  }
  
  Widget _buildActivityTab(UserStatistics stats, double fontScale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodChip('7일', 7, fontScale),
              const SizedBox(width: 8),
              _buildPeriodChip('30일', 30, fontScale),
              const SizedBox(width: 8),
              _buildPeriodChip('90일', 90, fontScale)]),
          
          // Weekly Activity Chart
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주간 활동',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 6,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
                              return Text(
                                weekDays[value.toInt()],
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  color: AppColors.textSecondary));
                            })),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10 * fontScale,
                                  color: AppColors.textSecondary));
                            }))),
                      borderData: FlBorderData(show: false),
                      barGroups: stats.weeklyActivity
                          .asMap()
                          .entries
                          .map((entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.count.toDouble(),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withValues(alpha: 0.7)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                    width: 24,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)))]))
                          .toList())))])),
          
          // Fortune Type Distribution
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운세 유형별 분포',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                ...stats.categoryDistribution.entries.map((entry) {
                  final percentage = (entry.value * 100).toInt();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                color: AppColors.textPrimary)),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary))]),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCategoryColor(entry.key)),
                            minHeight: 6))]));
                })])),
          
          // Most Used Fortunes
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자주 이용하는 운세 TOP 5',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...stats.fortuneTypeCount.entries.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final fortune = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: index == 0 
                                ? Colors.amber 
                                : index == 1 
                                    ? Colors.grey[400] 
                                    : index == 2 
                                        ? Colors.orange[700] 
                                        : AppColors.divider,
                            shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: index < 3 ? Colors.white : AppColors.textSecondary)))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fortune.key,
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                              fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal))),
                        Text(
                          '${fortune.value}회',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))]));
                })]))]));
  }
  
  Widget _buildPerformanceTab(UserStatistics stats, double fontScale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fortune Score Trend
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '운세 점수 추이',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '평균 ${stats.averageFortuneScore.toStringAsFixed(1)}점',
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)))]),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.divider,
                            strokeWidth: 1);
                        }),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              if (value % 5 == 0) {
                                return Text(
                                  '${value.toInt()}일',
                                  style: TextStyle(
                                    fontSize: 10 * fontScale,
                                    color: AppColors.textSecondary));
                              }
                              return const SizedBox.shrink();
                            })),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10 * fontScale,
                                  color: AppColors.textSecondary));
                            }))),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 29,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: stats.fortuneScoreHistory
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry.value.score.toDouble()))
                              .toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7)]),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.primary.withValues(alpha: 0.1)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)))])))])),
          
          // Performance Metrics
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: '최고 점수',
                  value: '98점',
                  subtitle: '2024.01.15',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  fontScale: fontScale)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: '최저 점수',
                  value: '45점',
                  subtitle: '2023.12.23',
                  icon: Icons.trending_down,
                  color: Colors.red,
                  fontScale: fontScale))]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: '이번 달 평균',
                  value: '85.2점',
                  subtitle: '+3.5 vs 지난달',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  fontScale: fontScale)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: '공유 횟수',
                  value: '${stats.totalShares}회',
                  subtitle: '친구들과 함께',
                  icon: Icons.share,
                  color: Colors.purple,
                  fontScale: fontScale))]),
          
          // Insights
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI 인사이트',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary))]),
                const SizedBox(height: 16),
                _buildInsightItem(
                  '운세 점수가 꾸준히 상승하고 있어요! 긍정적인 마인드가 좋은 운을 불러오는 것 같네요.',
                  fontScale),
                _buildInsightItem(
                  '연애운을 자주 확인하시네요. 좋은 인연이 곧 찾아올 거예요!',
                  fontScale),
                _buildInsightItem(
                  '매일 아침 운세를 확인하는 습관이 하루를 계획적으로 보내는데 도움이 되고 있어요.',
                  fontScale)]))]));
  }
  
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double fontScale}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: AppColors.textSecondary)))]),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary))]));
  }
  
  Widget _buildAchievementBadge(String name, bool isUnlocked, double fontScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber.withValues(alpha: 0.2) : AppColors.divider,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? Colors.amber : AppColors.divider)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlocked ? Icons.emoji_events : Icons.lock_outline,
            size: 16,
            color: isUnlocked ? Colors.amber : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12 * fontScale,
              color: isUnlocked ? Colors.amber[800] : AppColors.textSecondary,
              fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal))]));
  }
  
  Widget _buildPeriodChip(String label, int days, double fontScale) {
    final isSelected = _selectedPeriod == days;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = days;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider)),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))));
  }
  
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double fontScale}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: AppColors.textSecondary)))]),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold,
              color: color)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11 * fontScale,
              color: AppColors.textSecondary))]));
  }
  
  Widget _buildInsightItem(String text, double fontScale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14 * fontScale,
                color: AppColors.textPrimary,
                height: 1.5)))]));
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case '일일운세':
        return Colors.blue;
      case '연애/결혼':
        return Colors.pink;
      case '재물/사업':
        return Colors.green;
      case '건강':
        return Colors.orange;
      case '성격/심리':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}