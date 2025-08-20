import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/utils/logger.dart';

class FortuneHistorySummaryWidget extends StatefulWidget {
  final String userId;
  
  const FortuneHistorySummaryWidget({
    super.key,
    required this.userId,
  });

  @override
  State<FortuneHistorySummaryWidget> createState() => _FortuneHistorySummaryWidgetState();
}

class _FortuneHistorySummaryWidgetState extends State<FortuneHistorySummaryWidget> {
  final supabase = Supabase.instance.client;
  List<double> recentScores = [];
  Map<String, dynamic>? recentFortunes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load recent scores for chart
      final scoreResponse = await supabase
          .from('fortunes')
          .select('score')
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false)
          .limit(7);
      
      // Load recent fortunes
      final response = await supabase
          .from('fortunes')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false)
          .limit(3);
      
      if (mounted) {
        setState(() {
          recentScores = (scoreResponse as List<dynamic>?)
                  ?.map((item) => (item['score'] as num?)?.toDouble() ?? 0.0)
                  .toList()
                  .reversed
                  .toList() ??
              [];
          recentFortunes = {
            'data': response as List<dynamic>? ?? [],
          };
          isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Failed to load fortune history', e);
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Widget _buildChart(BuildContext context) {
    if (recentScores.isEmpty) {
      return Center(
        child: Text(
          '아직 운세 기록이 없습니다',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    
    final spots = recentScores.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();
    
    return Container(
      height: 120,
      padding: EdgeInsets.only(
        top: AppSpacing.spacing3,
        right: AppSpacing.spacing4,
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortuneTheme = context.fortuneTheme;
    
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: fortuneTheme.cardSurface,
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: fortuneTheme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 운세 히스토리',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconSizeSmall,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.spacing4),
          
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          else if (error != null)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  SizedBox(height: AppSpacing.spacing2),
                  Text(
                    '데이터를 불러올 수 없습니다',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else ...[
            // Chart
            Text(
              '최근 7일 운세 점수',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.spacing3),
            _buildChart(context),
            
            SizedBox(height: AppSpacing.spacing5),
            
            // Recent fortunes
            Text(
              '최근 운세',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.spacing3),
            
            if (recentFortunes != null && recentFortunes!['data'].isNotEmpty)
              Column(
                children: [
                  ...(recentFortunes!['data'] as List).map((fortune) {
                    return _buildFortuneItem(context, fortune);
                  }).toList(),
                ],
              )
            else
              Center(
                child: Text(
                  '아직 확인한 운세가 없습니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFortuneItem(BuildContext context, Map<String, dynamic> fortune) {
    final theme = Theme.of(context);
    final fortuneTheme = context.fortuneTheme;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.spacing3),
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: fortuneTheme.cardBackground,
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(
          color: fortuneTheme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusSmall,
            ),
            child: Center(
              child: Text(
                '${fortune['score'] ?? 0}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fortune['type'] ?? '운세',
                  style: theme.textTheme.titleSmall,
                ),
                SizedBox(height: AppSpacing.spacing1),
                Text(
                  fortune['title'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}