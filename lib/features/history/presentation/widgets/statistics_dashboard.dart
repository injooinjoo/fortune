import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import 'package:intl/intl.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class UserStatistics {
  final int totalCount;
  final int monthlyCount;
  final double averageScore;
  final Map<String, int> categoryCount;
  final String mostFrequentCategory;
  final DateTime lastFortuneDate;

  UserStatistics({
    required this.totalCount,
    required this.monthlyCount,
    required this.averageScore,
    required this.categoryCount,
    required this.mostFrequentCategory,
    required this.lastFortuneDate});
}

class StatisticsDashboard extends StatelessWidget {
  final UserStatistics statistics;
  final double fontScale;

  const StatisticsDashboard({
    super.key,
    required this.statistics,
    required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 운세 통계',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.bold)),
              Text(
                DateFormat('yyyy년 MM월').format(DateTime.now()),
                style: context.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))]),
          const SizedBox(height: 20),
          
          // Quick Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                context: context,
                icon: Icons.calendar_today,
                title: '총 운세 횟수',
                value: '${statistics.totalCount}회',
                color: DSColors.accentDark,
                fontScale: fontScale),
              _buildStatCard(
                context: context,
                icon: Icons.calendar_month,
                title: '이번 달',
                value: '${statistics.monthlyCount}회',
                color: DSColors.textSecondaryDark,
                fontScale: fontScale),
              _buildStatCard(
                context: context,
                icon: Icons.star,
                title: '평균 점수',
                value: '${statistics.averageScore.toStringAsFixed(1)}점',
                color: DSColors.success,
                fontScale: fontScale),
              _buildStatCard(
                context: context,
                icon: Icons.favorite,
                title: '자주 본 운세',
                value: statistics.mostFrequentCategory,
                color: DSColors.error,
                fontScale: fontScale)]),
          const SizedBox(height: 20),
          
          // Personalized Insight
          GlassContainer(
            padding: const EdgeInsets.all(16),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      size: 20,
                      color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 인사이트',
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getPersonalizedInsight(statistics),
                  style: context.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double fontScale}) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: Icon(
              icon,
              size: 24,
              color: color)),
          const SizedBox(height: 8),
          Text(
            title,
            style: context.labelMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color),
            textAlign: TextAlign.center)]));
  }

  String _getPersonalizedInsight(UserStatistics statistics) {
    if (statistics.averageScore >= 80) {
      return '최근 운세가 아주 좋네요! 이 기운을 유지하세요 ✨';
    } else if (statistics.averageScore >= 60) {
      return '전반적으로 안정적인 운세를 보이고 있어요. 꾸준히 노력하세요!';
    } else if (statistics.averageScore >= 40) {
      return '조금 더 긍정적인 마음가짐이 필요해 보여요. 화이팅!';
    } else {
      return '새로운 시작을 준비하는 시기입니다. 희망을 가지세요!';
    }
  }
}