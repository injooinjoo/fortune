import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/fortune_api_service.dart';
import '../../services/user_statistics_service.dart';
import '../../shared/components/base_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      
      // Load recent fortune scores (last 7 days)
      final fortuneApiService = ref.read(fortuneApiServiceProvider);
      final scores = await fortuneApiService.getUserFortuneHistory(
        userId: userId,
      );
      
      // Load recent fortunes
      final response = await supabase
          .from('fortunes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(3);
      
      if (mounted) {
        setState(() {
          recentScores = scores.take(7).toList();
          recentFortunes = response as Map<String, dynamic>?;
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
        height: 60,
        alignment: Alignment.center,
        child: Text(
          '아직 기록이 없어요',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      );
    }
    
    final spots = recentScores.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();
    
    return Container(
      height: 60,
      padding: const EdgeInsets.only(right: 8),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primary,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
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
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade50,
                  Colors.purple.shade100.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph,
                      color: Colors.purple.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '운세 기록',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push('/fortune/history'),
                  child: Row(
                    children: [
                      Text(
                        '전체보기',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.purple.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Chart and Stats Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Mini Chart
                _buildMiniChart(context),
                
                const SizedBox(height: 20),
                
                // Quick Stats
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      label: '평균 점수',
                      value: '${_calculateAverage(recentScores)}점',
                      icon: Icons.stars,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatItem(
                      context,
                      label: '이번주',
                      value: '${_calculateTrend(recentScores) >= 0 ? '+' : ''}${_calculateTrend(recentScores).toStringAsFixed(0)}%',
                      icon: _calculateTrend(recentScores) >= 0 
                          ? Icons.trending_up 
                          : Icons.trending_down,
                      color: _calculateTrend(recentScores) >= 0 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Recent Fortunes
                if (!isLoading && recentFortunes != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '최근 운세',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Show recent fortune items here
                        // This would need to be implemented based on actual data structure
                        _buildRecentFortuneItem(
                          context,
                          title: '오늘의 운세',
                          score: 85,
                          time: '2시간 전',
                        ),
                        const SizedBox(height: 8),
                        _buildRecentFortuneItem(
                          context,
                          title: '연애운',
                          score: 78,
                          time: '어제',
                        ),
                        const SizedBox(height: 8),
                        _buildRecentFortuneItem(
                          context,
                          title: '재물운',
                          score: 91,
                          time: '2일 전',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentFortuneItem(
    BuildContext context, {
    required String title,
    required int score,
    required String time,
  }) {
    final scoreColor = score >= 80 
        ? Colors.green 
        : score >= 60 
            ? Colors.blue 
            : Colors.orange;
    
    return Row(
      children: [
        Expanded(
          child: Text(
            '• $title',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '($score점)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scoreColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '- $time',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}