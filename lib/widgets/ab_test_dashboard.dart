import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ab_test_experiment.dart';
import '../models/ab_test_result.dart';
import '../services/ab_test_service.dart';
import '../core/theme/app_theme.dart';

/// AB 테스트 대시보드 위젯
class ABTestDashboard extends ConsumerStatefulWidget {
  const ABTestDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<ABTestDashboard> createState() => _ABTestDashboardState();
}

class _ABTestDashboardState extends ConsumerState<ABTestDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final abTestService = ref.watch(abTestServiceProvider);
    final experiments = abTestService.getActiveExperiments();
    final results = abTestService.getAllResults();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('A/B 테스트 대시보드'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: experiments.isEmpty
          ? Center(
              child: Text(
                '진행 중인 실험이 없습니다',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: experiments.length,
              itemBuilder: (context, index) {
                final experiment = experiments.values.elementAt(index);
                final result = results[experiment.id];
                
                return _ExperimentCard(
                  experiment: experiment,
                  result: result,
                  onConclude: () => _concludeExperiment(experiment.id),
                );
              },
            ),
    );
  }

  Future<void> _concludeExperiment(String experimentId) async {
    final abTestService = ref.read(abTestServiceProvider);
    await abTestService.concludeExperiment(experimentId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('실험 $experimentId가 종료되었습니다'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }
}

/// 실험 카드 위젯
class _ExperimentCard extends StatelessWidget {
  final ABTestExperiment experiment;
  final ABTestResult? result;
  final VoidCallback onConclude;

  const _ExperimentCard({
    Key? key,
    required this.experiment,
    this.result,
    required this.onConclude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 실험 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experiment.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        experiment.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  isRunning: experiment.isRunning,
                  isSignificant: result?.isStatisticallySignificant ?? false,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 실험 결과가 있는 경우
            if (result != null) ...[
              // 전체 통계
              _StatisticsRow(
                label: '전체',
                impressions: result.totalImpressions,
                conversions: result.totalConversions,
                conversionRate: result.overallConversionRate,
                isTotal: true,
              ),
              
              const Divider(color: AppTheme.borderColor, height: 24),
              
              // 변형별 결과
              ...result.variantResults.values.map((variantResult) {
                final isWinner = variantResult.variantId == result.winningVariantId;
                final isControl = variantResult.variantId == 'control';
                
                return _StatisticsRow(
                  label: variantResult.variantName,
                  impressions: variantResult.impressions,
                  conversions: variantResult.conversions,
                  conversionRate: variantResult.conversionRate,
                  isWinner: isWinner,
                  isControl: isControl,
                );
              }).toList(),
              
              // 통계적 유의성
              if (result.confidenceLevel != null) ...[
                const SizedBox(height: 16),
                _ConfidenceIndicator(
                  confidenceLevel: result.confidenceLevel!,
                  uplift: result.uplift,
                ),
              ],
              
              // 실험 종료 버튼
              if (result.isStatisticallySignificant && experiment.isRunning) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onConclude,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: Text('승자 확정: ${result.winningVariantId}'),
                  ),
                ),
              ],
            ] else ...[
              // 결과가 없는 경우
              Center(
                child: Text(
                  '아직 데이터가 수집되지 않았습니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 상태 배지
class _StatusBadge extends StatelessWidget {
  final bool isRunning;
  final bool isSignificant;

  const _StatusBadge({
    Key? key,
    required this.isRunning,
    required this.isSignificant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String text;
    
    if (isSignificant) {
      backgroundColor = AppTheme.success;
      text = '유의미';
    } else if (isRunning) {
      backgroundColor = AppTheme.primary;
      text = '진행중';
    } else {
      backgroundColor = AppTheme.textSecondary;
      text = '종료';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: backgroundColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 통계 행
class _StatisticsRow extends StatelessWidget {
  final String label;
  final int impressions;
  final int conversions;
  final double conversionRate;
  final bool isTotal;
  final bool isWinner;
  final bool isControl;

  const _StatisticsRow({
    Key? key,
    required this.label,
    required this.impressions,
    required this.conversions,
    required this.conversionRate,
    this.isTotal = false,
    this.isWinner = false,
    this.isControl = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 변형 이름
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (isWinner) ...[
                  const Icon(Icons.star, color: AppTheme.gold, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: isTotal || isWinner ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isControl) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Control',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 노출
          Expanded(
            child: Text(
              impressions.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          
          // 전환
          Expanded(
            child: Text(
              conversions.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          
          // 전환율
          Expanded(
            child: Text(
              '${(conversionRate * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isWinner ? AppTheme.success : AppTheme.textPrimary,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 신뢰도 지표
class _ConfidenceIndicator extends StatelessWidget {
  final double confidenceLevel;
  final double? uplift;

  const _ConfidenceIndicator({
    Key? key,
    required this.confidenceLevel,
    this.uplift,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercent = (confidenceLevel * 100).toStringAsFixed(1);
    final isSignificant = confidenceLevel >= 0.95;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSignificant 
            ? AppTheme.success.withValues(alpha: 0.1)
            : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSignificant ? AppTheme.success : AppTheme.warning,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '신뢰도',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '$confidencePercent%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSignificant ? AppTheme.success : AppTheme.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          if (uplift != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '개선율',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '${uplift! > 0 ? '+' : ''}${uplift!.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: uplift! > 0 ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: confidenceLevel,
            backgroundColor: AppTheme.textPrimary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isSignificant ? AppTheme.success : AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }
}