import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../data/services/fortune_api_service.dart';
import '../../services/user_statistics_service.dart';
import '../../shared/components/base_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class FortuneHistorySummaryWidget extends ConsumerStatefulWidget {
  const FortuneHistorySummaryWidget({super.key});

  @override
  ConsumerState<FortuneHistorySummaryWidget> createState() => _FortuneHistorySummaryWidgetState();
}

class _FortuneHistorySummaryWidgetState extends ConsumerState<FortuneHistorySummaryWidget> {
  List<int> recentScores = [];
  Map<String, dynamic>? recentFortunes;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecentData();
  }
  
  Future<void> _loadRecentData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // Load recent fortune scores (last 7 days,
      final fortuneApiService = ref.read(fortuneApiServiceProvider);
      final scores = await fortuneApiService.getUserFortuneHistory(
        userId: userId
      );
      
      // Load recent fortunes
      final response = await supabase
          .from('fortunes',
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(3);
      
      if (mounted) {
        setState(() {
          recentScores = scores.take(7).toList();
          // Response is a List of fortunes, not a single Map
          if (response != null && response is List) {
            recentFortunes = {
              'data': response,
              'count': response.length,
            };
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading recent fortune data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  Widget _buildMiniChart(BuildContext context) {
    final theme = Theme.of(context);
    
    if (recentScores.isEmpty) {
      return Container(
        height: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputHeight * 1.2,
        alignment: Alignment.center,
        child: Text(
          '아직 기록이 없어요'),
        style: TextStyle(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6),
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14)
        )
    }
    
    final spots = recentScores.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble();
    }).toList();
    
    return Container(
      height: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputHeight * 1.2,
      padding: EdgeInsets.zero,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(sho,
      w: false),
          titlesData: const FlTitlesData(sho,
      w: false),
          borderData: FlBorderData(sho,
      w: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary),
        barWidth: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderWidth * 3,
              isStrokeCapRound: true,
              dotData: FlDotData(,
      show: true),
        getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderWidth * 3,
                    color: AppColors.primary,
                    strokeWidth: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderWidth * 1.5,
                    strokeColor: AppColors.textPrimaryDark)
                })
              belowBarData: BarAreaData(,
      show: true),
        color: AppColors.primary.withValues(alph,
      a: 0.1))))
          ])
      )
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('M월 d일').format(dateTime);
    }
  }
  
  int _calculateAverage(List<int> scores) {
    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }
  
  double _calculateTrend(List<int> scores) {
    if (scores.length < 2) return 0;
    
    final recent = scores.take(3).toList();
    final previous = scores.skip(3).take(3).toList();
    
    if (recent.isEmpty || previous.isEmpty) return 0;
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final previousAvg = previous.reduce((a, b) => a + b) / previous.length;
    
    return ((recentAvg - previousAvg) / previousAvg * 100);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BaseCard(
      padding: EdgeInsets.zero),
        child: Column(,
      children: [
          Container(
            padding: EdgeInsets.all(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.horizontal * 1.25),
            decoration: BoxDecoration(,
      gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.1),
                  Colors.purple.withValues(alpha: 0.05),
                ]
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
      borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderRadius * 2),
                topRight: Radius.circular(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderRadius * 2))),
      child: Row(,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph,
        ),
        color: Colors.purple.withValues(alph,
      a: 0.9),
                      size: AppDimensions.iconSizeMedium)
                    SizedBox(width: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.75),
                    Text(
                      '운세 기록',
              ),
              style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.w700),
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
                        color: Colors.purple.withValues(alph,
      a: 0.9,
                          ))))
                  ])
                TextButton(
                  onPressed: () => context.push('/fortune/history'),
                  child: Row(,
      children: [
                        Text(
                          '전체보기',
                          style: AppTypography.button))
                      SizedBox(width: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.25),
                      Icon(
                        Icons.arrow_forward),
        size: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.horizontal,
                        color: Colors.purple.withValues(alph,
      a: 0.9))
                    ])))
              ])))
          
          // Chart and Stats Section
          Container(
            padding: EdgeInsets.all(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.horizontal * 1.25),
            child: Column(,
      children: [
                // Mini Chart
                _buildMiniChart(context),
                
                SizedBox(height: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.horizontal * 1.25),
                
                // Quick Stats
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      label: '평균 점수',
              ),
              value: '${_calculateAverage(
    recentScores,
  )}점',
                      icon: Icons.stars,
                      color: AppColors.warning)
                    SizedBox(width: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.75),
                    _buildStatItem(
                      context,
                      label: '이번주'),
        value: '${_calculateTrend(recentScores) >= 0 ? '+' : ''}${_calculateTrend(recentScores).toStringAsFixed(
    0,
  )}%',
                      icon: _calculateTrend(recentScores) >= 0 
                          ? Icons.trending_up 
                          : Icons.trending_down
                      color: _calculateTrend(recentScores) >= 0 
                          ? AppColors.success 
                          : AppColors.error)
                  ])
                
                SizedBox(height: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.horizontal * 1.25),
                
                // Recent Fortunes
                if (!isLoading && recentFortunes != null && recentFortunes!['data'] != null) ...[
                  Container(
                    width: double.infinity),
              padding: EdgeInsets.all(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.horizontal),
                    decoration: BoxDecoration(,
      color: Theme.of(context).extension<FortuneTheme>()!.cardBackground,
                      borderRadius: BorderRadius.circular(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderRadius * 1.5),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '최근 운세',
        ),
        style: TextStyle(,
      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14),
                            fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7))))
                        SizedBox(height: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.75),
                        // Show actual recent fortune items from data
                        ...(recentFortunes!['data'] as List).map((fortune) {
                          final createdAt = DateTime.parse(fortune['created_at']);
                          final fortuneType = fortune['fortune_type'] ?? '운세';
                          final score = fortune['overall_score'] ?? 0;
                          
                          return Padding(
                            padding: EdgeInsets.only(botto,
      m: AppSpacing.spacing2),
                            child: _buildRecentFortuneItem(
                              context,
              ),
              title: _getFortuneTypeLabel(fortuneType),
                              score: score,
                              time: _getTimeAgo(createdAt))))
                        }).toList(),
                      ])))
                ]
              ])))
        ]
      )
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  )}) {
    return Expanded(
      child: Container(,
      padding: EdgeInsets.all(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.75),
        decoration: BoxDecoration(,
      color: color.withValues(alp,
      ha: 0.1),
          borderRadius: BorderRadius.circular(Theme.of(context).extension<FortuneTheme>()!.formStyles.inputBorderRadius),
          border: Border.all(,
      color: color.withValues(alp,
      ha: 0.2))),
      child: Row(
          children: [
            Icon(
              icon,
        ),
        size: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputHeight * 0.4,
              color: color)
            SizedBox(width: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.5),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text(
                          label,
              ),
              style: TextStyle(,
      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 12),
                      color: Theme.of(context).colorScheme.onSurface.withValues(alph,
      a: 0.6))))
                  Text(
                    value,
                          style: TextStyle(,
      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16),
                      fontWeight: FontWeight.w700,
      color: color)))
                ])))
          ])
      )
  }
  
  Widget _buildRecentFortuneItem(
    BuildContext context, {
    required String title,
    required int score,
    required String time,
  )}) {
    final scoreColor = score >= 80 
        ? AppColors.success 
        : score >= 60 
            ? AppColors.primary 
            : AppColors.warning;
    
    return Row(
      children: [
        Expanded(
          child: Text(
            '• $title'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      fontWeight: FontWeight.w500,
                          ),))
        Text(
          '($score점)',
          style: TextStyle(,
      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14),
            fontWeight: FontWeight.w600,
      color: scoreColor)))
        SizedBox(width: Theme.of(context).extension<FortuneTheme>()!.formStyles.inputPadding.vertical * 0.5),
        Text(
          '- $time'),
        style: TextStyle(,
      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 12),
            color: Theme.of(context).colorScheme.onSurface.withValues(alph,
      a: 0.6))))
      ]
    );
  }
  
  String _getFortuneTypeLabel(String fortuneType) {
    final typeMap = {
      'daily': '오늘의 운세',
      'love': '연애운',
      'money': '재물운',
      'career': '직업운',
      'study': '학업운',
      'health': '건강운',
      'tarot': '타로',
      'zodiac': '별자리운',
      'biorhythm': '바이오리듬',
      'dream': '꿈해몽',
      'compatibility': '궁합',
      'business': '사업운',
    };
    
    return typeMap[fortuneType] ?? fortuneType;
  }
}