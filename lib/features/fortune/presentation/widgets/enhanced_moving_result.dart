import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'direction_compass.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class EnhancedMovingResult extends StatelessWidget {
  final Map<String, dynamic> fortuneData;
  final String? selectedDate;
  final String? fromAddress;
  final String? toAddress;
  
  const EnhancedMovingResult({
    Key? key,
    required this.fortuneData,
    this.selectedDate,
    this.fromAddress,
    this.toAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 종합 점수 카드
          _buildOverallScoreCard(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 이사 정보 요약
          if (fromAddress != null || toAddress != null)
            _buildMovingInfoCard(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 방위 나침반
          if (fortuneData['auspiciousDirections'] != null)
            _buildDirectionSection(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 지역 분석
          if (fortuneData['areaAnalysis'] != null)
            _buildAreaAnalysisSection(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 길일 정보
          if (fortuneData['dateAnalysis'] != null)
            _buildDateAnalysisSection(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 상세 점수 분석
          _buildDetailedScoreSection(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 추천사항
          if (fortuneData['recommendations'] != null)
            _buildRecommendationsSection(context),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 주의사항
          if (fortuneData['cautions'] != null)
            _buildCautionsSection(context),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(BuildContext context) {
    final overallScore = fortuneData['overallScore'] ?? 75;
    final scoreColor = _getScoreColor(overallScore);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLarge,
      ),
      child: Container(
        padding: AppSpacing.paddingAll24,
        decoration: BoxDecoration(
          borderRadius: AppDimensions.borderRadiusLarge,
          gradient: LinearGradient(
            colors: [
              scoreColor.withValues(alpha: 0.1),
              scoreColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              '이사 운세 종합 점수',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing5),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: overallScore / 100,
                    strokeWidth: 15,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$overallScore',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '점',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              _getScoreDescription(overallScore),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
    );
  }

  Widget _buildMovingInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '이사 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing4),
            if (fromAddress != null) ...[
              Row(
                children: [
                  Icon(Icons.home_outlined, size: 20),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      '출발: $fromAddress',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing2),
            ],
            if (toAddress != null) ...[
              Row(
                children: [
                  const Icon(Icons.home, size: 20),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      '도착: $toAddress',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing2),
            ],
            if (selectedDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: AppSpacing.spacing2),
                  Text(
                    '예정일: $selectedDate',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionSection(BuildContext context) {
    final auspiciousDirections = List<String>.from(
      fortuneData['auspiciousDirections'],
    );
    final avoidDirections = List<String>.from(
      fortuneData['avoidDirections'] ?? []
    );
    final primaryDirection = fortuneData['primaryDirection'] as String?;
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.explore, color: Theme.of(context).primaryColor),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '방위 분석',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Center(
              child: DirectionCompass(
                auspiciousDirections: auspiciousDirections,
                avoidDirections: avoidDirections,
                primaryDirection: primaryDirection,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaAnalysisSection(BuildContext context) {
    final areaAnalysis = fortuneData['areaAnalysis'] as Map<String, dynamic>?;
    if (areaAnalysis == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: Theme.of(context).primaryColor),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '지역 상세 분석',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing5),
            
            // 지역 점수 차트
            if (areaAnalysis['scores'] != null)
              _buildAreaScoreChart(context, areaAnalysis['scores'],
            const SizedBox(height: AppSpacing.spacing5),
            
            // 교통
            if (areaAnalysis['transportation'] != null)
              _buildAreaItem(
                context,
                Icons.directions_bus,
                '교통',
                areaAnalysis['transportation'],
                Colors.blue,
              ),
            
            // 교육
            if (areaAnalysis['education'] != null)
              _buildAreaItem(
                context,
                Icons.school,
                '교육',
                areaAnalysis['education'],
                Colors.green,
              ),
            
            // 편의시설
            if (areaAnalysis['convenience'] != null)
              _buildAreaItem(
                context,
                Icons.shopping_cart,
                '편의시설',
                areaAnalysis['convenience'],
                Colors.orange,
              ),
            
            // 의료
            if (areaAnalysis['medical'] != null)
              _buildAreaItem(
                context,
                Icons.local_hospital,
                '의료',
                areaAnalysis['medical'],
                Colors.red,
              ),
            
            // 미래 발전성
            if (areaAnalysis['development'] != null)
              _buildAreaItem(
                context,
                Icons.trending_up,
                '발전 가능성',
                areaAnalysis['development'],
                Colors.purple,
              ),
          ],
        ),
      )
    );
  }

  Widget _buildAreaScoreChart(BuildContext context, Map<String, dynamic> scores) {
    final radarData = scores.entries.map((e) => 
      RadarEntry(value: (e.value as num).toDouble())
    ).toList();
    
    return Container(
      height: 200,
      padding: AppSpacing.paddingAll16,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.grey, width: AppSpacing.spacing0 * 0.5),
          gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          titlePositionPercentageOffset: 0.2,
          radarBackgroundColor: Colors.transparent,
          dataSets: [
            RadarDataSet(
              dataEntries: radarData,
              fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              borderColor: Theme.of(context).primaryColor,
              borderWidth: 2,
              entryRadius: 4,
            ),
          ],
          getTitle: (index, angle) {
            final titles = scores.keys.toList();
            return RadarChartTitle(
              text: titles[index],
              angle: 0
            );
          },
          tickCount: 5,
          ticksTextStyle: Theme.of(context).textTheme.bodyMedium,
          tickBorderData: const BorderSide(color: Colors.grey, width: 0.5),
        ),
      )
    );
  }

  Widget _buildAreaItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: AppSpacing.paddingVertical8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.paddingAll8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderRadiusSmall,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing1),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildDateAnalysisSection(BuildContext context) {
    final dateAnalysis = fortuneData['dateAnalysis'] as Map<String, dynamic>?;
    if (dateAnalysis == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Theme.of(context).primaryColor),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '날짜 분석',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing4),
            
            // 손없는날 여부
            if (dateAnalysis['isAuspicious'] == true)
              Container(
                padding: AppSpacing.paddingAll12,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusSmall,
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: AppSpacing.spacing2),
                    Expanded(
                      child: Text(
                        '손없는날 - 모든 방향으로 이사하기 좋은 최고의 날입니다!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.spacing3),
            
            // 음력 정보
            if (dateAnalysis['lunarDate'] != null)
              _buildDateInfoRow(
                context,
                '음력',
                dateAnalysis['lunarDate'],
              ),
            
            // 절기
            if (dateAnalysis['solarTerm'] != null)
              _buildDateInfoRow(
                context,
                '절기',
                dateAnalysis['solarTerm'],
              ),
            
            // 오행
            if (dateAnalysis['fiveElements'] != null)
              _buildDateInfoRow(
                context,
                '오행',
                dateAnalysis['fiveElements'],
              ),
          ],
        ),
      )
    );
  }

  Widget _buildDateInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
    );
  }

  Widget _buildDetailedScoreSection(BuildContext context) {
    final scores = fortuneData['detailedScores'] as Map<String, dynamic>? ?? {
      '날짜 길흉': 85,
      '방위 조화': 75,
      '지역 적합성': 90,
      '가족 운': 80,
      '재물 운'),
    };
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '상세 운세 분석',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing4),
            ...scores.entries.map((entry) => _buildScoreBar(
              context,
              entry.key,
              entry.value.toDouble(),
            )),
          ],
        ),
      )
    );
  }

  Widget _buildScoreBar(BuildContext context, String label, double score) {
    final color = _getScoreColor(score.toInt());
    
    return Padding(
      padding: AppSpacing.paddingVertical8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${score.toInt()}점',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing1),
          ClipRRect(
            borderRadius: AppDimensions.borderRadiusSmall,
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final recommendations = List<String>.from(
      fortuneData['recommendations'] ?? []
    );
    
    if (recommendations.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.withValues(alpha: 0.9)),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '추천사항',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing4),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, 
                    color: Colors.green, 
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCautionsSection(BuildContext context) {
    final cautions = List<String>.from(
      fortuneData['cautions'] ?? []
    );
    
    if (cautions.isEmpty) return const SizedBox.shrink();
    
    return Card(
      color: Colors.red.withValues(alpha: 0.08),
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.withValues(alpha: 0.9)),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '주의사항',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing4),
            ...cautions.map((caution) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, 
                    color: Colors.red.withValues(alpha: 0.9), 
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      caution,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '최고의 이사 운세! 모든 조건이 완벽합니다.';
    if (score >= 80) return '매우 좋은 운세입니다. 순조로운 이사가 예상됩니다.';
    if (score >= 70) return '좋은 운세입니다. 대체로 순조롭게 진행될 것입니다.';
    if (score >= 60) return '보통 운세입니다. 신중한 준비가 필요합니다.';
    if (score >= 50) return '주의가 필요한 운세입니다. 충분한 준비를 하세요.';
    return '어려운 운세입니다. 시기를 재고려해보세요.';
  }
}
