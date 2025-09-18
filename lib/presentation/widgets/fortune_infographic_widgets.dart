import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';

/// Collection of infographic widgets for fortune completion page
class FortuneInfographicWidgets {
  
  /// 토스 스타일 메인 점수 표시 (깔끔한 흰 배경)
  static Widget buildTossStyleMainScore({
    required int score,
    required String message,
    double size = 280,
  }) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : const Color(0xFFF2F4F6),
            width: 1,
          ),
        ),
      child: Column(
        children: [
          // 토스 스타일 점수 표시 (큰 숫자만)
          Text(
            '$score',
            style: TextStyle(
              color: TossDesignSystem.gray900,
              fontSize: size * 0.3,
              fontWeight: FontWeight.w300,
              letterSpacing: -4,
              height: 1.0,
            ),
          ).animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 600.ms),
          
          const SizedBox(height: 24),
          
          // 메시지
          Text(
            message,
            style: const TextStyle(
              color: TossDesignSystem.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.2, curve: Curves.easeOut),
        ],
      ),
    ));
  }

  /// Circular progress chart for overall fortune score (토스 스타일)
  static Widget buildHeroScoreChart({
    required int score,
    required String message,
    required String userName,
    double size = 200,
  }) {
    return Builder(
      builder: (context) => Container(
        width: size + 20,
        height: size + 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.black.withValues(alpha:0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Center(
        child: Container(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Progress circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: TossDesignSystem.gray100,
                  valueColor: const AlwaysStoppedAnimation<Color>(TossDesignSystem.gray600),
                ),
              ).animate()
                .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 600.ms),
              
              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        color: TossDesignSystem.gray900,
                        fontSize: size * 0.18,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
                    
                    Text(
                      '점',
                      style: TextStyle(
                        color: TossDesignSystem.gray600,
                        fontSize: size * 0.06,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  /// 토스 스타일 5각형 레이더 차트 (총운 중심)
  static Widget buildTossStyleRadarChart({
    required Map<String, int> categories,
    double size = 300, // 사이즈 증가
  }) {
    // 기본 5개 카테고리: 총운, 재물운, 연애운, 건강운, 학업운
    final categoryOrder = ['총운', '학업운', '재물운', '연애운', '건강운'];
    final scores = categoryOrder.map((cat) => categories[cat]?.toDouble() ?? 70.0).toList();

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
        width: size,
        height: size + 30, // 높이 더 증가로 텍스트 잘림 방지
        padding: const EdgeInsets.all(30), // 패딩 더 증가
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : const Color(0xFFF2F4F6),
            width: 1,
          ),
        ),
      child: Stack(
        children: [
          // 토스 스타일 5각형 차트 (더 연한 색상)
          Container(
            padding: const EdgeInsets.all(35), // 패딩 조정
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF4ECDC4).withValues(alpha:0.15), // 더 연하게
                    borderColor: const Color(0xFF4ECDC4),
                    entryRadius: 3,
                    dataEntries: scores.map((score) => RadarEntry(value: score)).toList(),
                    borderWidth: 2,
                  ),
                ],
                radarBackgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(color: TossDesignSystem.white.withValues(alpha: 0.0)),
                titlePositionPercentageOffset: 0.15, // 텍스트를 차트에서 더 멀리
                titleTextStyle: TextStyle(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: categoryOrder[index],
                    angle: 0, // 항상 수평으로 표시
                  );
                },
                tickCount: 5,
                ticksTextStyle: TextStyle(
                  color: TossDesignSystem.white.withValues(alpha: 0.0), // 숫자 숨김
                  fontSize: 0,
                ),
                tickBorderData: BorderSide(color: TossDesignSystem.white.withValues(alpha: 0.0)),
                gridBorderData: BorderSide(
                  color: isDark ? TossDesignSystem.grayDark400 : const Color(0xFFF2F4F6),
                  width: 1
                ), // 다크모드에서 보이는 격자
                radarShape: RadarShape.polygon,
              ),
            ),
          ),
          
          // 각 카테고리 점수 표시 (토스 스타일) - 텍스트 직하단 위치
          ...categoryOrder.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final score = categories[category] ?? 70;
            
            // 텍스트 위치를 기준으로 점수 위치 계산
            final chartCenter = size * 0.5;
            final textRadius = size * 0.42; // 텍스트 위치 반지름
            final angleRadians = (index * 2 * math.pi / 5) - math.pi / 2;
            final scoreCircleRadius = 12.0; // 점수 원 반지름 축소
            
            // 텍스트 바로 아래에 점수 위치 계산
            final textX = chartCenter + textRadius * math.cos(angleRadians);
            final textY = chartCenter + textRadius * math.sin(angleRadians);
            
            return Positioned(
              left: textX - scoreCircleRadius,
              top: textY + 12, // 텍스트 바로 아래 12px 간격
              child: Container(
                width: scoreCircleRadius * 2,
                height: scoreCircleRadius * 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha:0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      color: TossDesignSystem.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
      },
    ).animate()
      .fadeIn(duration: 800.ms, delay: 500.ms)
      .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut);
  }

  /// Radar chart for fortune categories (토스 스타일)
  static Widget buildRadarChart({
    required Map<String, int> scores,
    double size = 180,
  }) {
    return Builder(
      builder: (context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : TossDesignSystem.gray200,
            width: 1,
          ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(enabled: false),
          dataSets: [
            RadarDataSet(
              fillColor: TossDesignSystem.gray600.withValues(alpha:0.1),
              borderColor: TossDesignSystem.gray600,
              entryRadius: 3,
              dataEntries: scores.entries.map((entry) {
                return RadarEntry(value: entry.value.toDouble());
              }).toList(),
              borderWidth: 2,
            ),
          ],
          radarBackgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(color: TossDesignSystem.gray200, width: 1),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(
            color: TossDesignSystem.gray600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          getTitle: (index, angle) {
            final categories = scores.keys.toList();
            return RadarChartTitle(
              text: categories[index],
              angle: angle,
            );
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(
            color: TossDesignSystem.gray600,
            fontSize: 9,
          ),
          tickBorderData: BorderSide(color: TossDesignSystem.gray300, width: 1),
          gridBorderData: BorderSide(color: TossDesignSystem.gray200, width: 1),
        ),
      ),
    )).animate()
      .fadeIn(duration: 800.ms, delay: 500.ms)
      .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut);
  }

  /// 5대 카테고리 점수 카드 (토스 스타일) - 미니멀 디자인
  static Widget buildCategoryCards(Map<String, dynamic>? categories, {bool isDarkMode = true}) {
    if (categories == null) return const SizedBox.shrink();
    
    final categoryList = [
      {'key': 'total', 'title': '총운', 'icon': Icons.star_outline},
      {'key': 'love', 'title': '연애운', 'icon': Icons.favorite_outline},
      {'key': 'money', 'title': '재물운', 'icon': Icons.monetization_on_outlined},
      {'key': 'work', 'title': '직장운', 'icon': Icons.work_outline},
      {'key': 'health', 'title': '건강운', 'icon': Icons.health_and_safety_outlined},
    ];
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: categoryList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categoryList[index];
        final categoryData = categories[category['key']] as Map<String, dynamic>?;
        final score = categoryData?['score'] ?? 0;
        
        return _buildTossStyleCategoryCard(category, score, index);
      },
    );
  }

  static Widget _buildTossStyleCategoryCard(Map<String, dynamic> category, int score, int index) {
    return Builder(
      builder: (context) {
        // 토스 스타일 점수별 색상
        Color scoreColor;
        Color backgroundColor = Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark200
            : TossDesignSystem.white;
    
    if (score >= 90) {
      scoreColor = const Color(0xFF0066FF); // 토스 블루
    } else if (score >= 80) {
      scoreColor = const Color(0xFF10B981); // 성공 그린
    } else if (score >= 70) {
      scoreColor = const Color(0xFF000000); // 일반 블랙
    } else if (score >= 60) {
      scoreColor = const Color(0xFFF59E0B); // 경고 오렌지
    } else {
      scoreColor = const Color(0xFFEF4444); // 에러 레드
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark300
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              category['icon'] as IconData,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.gray400
                  : const Color(0xFF666666),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // 카테고리 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.white
                        : const Color(0xFF000000),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getScoreGrade(score),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
          
          // 점수
          Text(
            '$score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : scoreColor,
              height: 1.0,
            ),
          ),

          Text(
            '점',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.white.withValues(alpha:0.7)
                  : scoreColor.withValues(alpha:0.7),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 100 * index))
      .slideX(begin: 0.2, curve: Curves.easeOut);
      },
    );
  }

  /// 추천 활동 번호 매김 리스트 (토스 스타일)
  static Widget buildActionChecklist(List<Map<String, dynamic>>? actions, {bool isDarkMode = true}) {
    if (actions == null || actions.isEmpty) return const SizedBox.shrink();

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions.take(3).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          final title = action['title'] ?? '';
          final why = action['why'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark200
                  : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark300
                    : TossDesignSystem.gray200,
                width: 1,
              ),
            boxShadow: [
              BoxShadow(
                color: TossDesignSystem.black.withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: TossDesignSystem.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.gray900,
                        height: 1.3,
                      ),
                    ),
                    if (why.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: TossDesignSystem.gray300,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          why,
                          style: const TextStyle(
                            fontSize: 13,
                            color: TossDesignSystem.gray600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 180 * index))
          .slideX(begin: 0.2, curve: Curves.easeOutBack);
      }).toList(),
      ),
    );
  }

  /// 사주 기반 행운 요소 (토스 스타일)
  static Widget buildSajuLuckyItems(Map<String, dynamic>? sajuInsight, {bool isDarkMode = true}) {
    if (sajuInsight == null) return const SizedBox.shrink();

    final luckyColor = sajuInsight['lucky_color'] ?? '파란색';
    final luckyItem = sajuInsight['lucky_item'] ?? '작은 노트';
    final luckDirection = sajuInsight['luck_direction'] ?? '동쪽';
    final keyword = sajuInsight['keyword'] ?? '정돈';

    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : TossDesignSystem.gray200,
            width: 1,
          ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: TossDesignSystem.gray600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '행운 요소',
                style: TextStyle(
                  color: TossDesignSystem.gray900,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildLuckyItem('🎨', '행운의 색', luckyColor),
              _buildLuckyItem('🎁', '행운 아이템', luckyItem),
              _buildLuckyItem('🧭', '행운의 방향', luckDirection),
              _buildLuckyItem('🔑', '오늘의 키워드', keyword),
            ],
          ),
        ],
      ),
    )).animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: 0.2, curve: Curves.easeOutBack);
  }
  
  static Widget _buildLuckyItem(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TossDesignSystem.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  emoji, 
                  style: const TextStyle(fontSize: 14)
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: TossDesignSystem.gray600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: TossDesignSystem.gray900,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 날씨와 운세 연계 표시
  static Widget buildWeatherFortune(Map<String, dynamic>? weather, int? score) {
    if (weather == null || score == null) return const SizedBox.shrink();
    
    // 다양한 데이터 구조를 지원
    final weatherData = weather['weather'] ?? weather; // 중첩된 구조 지원
    
    final icon = weatherData['icon'] ?? weatherData['weather_icon'] ?? '☀';
    final condition = weatherData['condition'] ?? weatherData['weather_condition'] ?? '맑음';
    final tempHigh = weatherData['temp_high'] ?? weatherData['high_temp'] ?? weatherData['temperature'] ?? 25;
    final tempLow = weatherData['temp_low'] ?? weatherData['low_temp'] ?? weatherData['min_temp'] ?? 18;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TossDesignSystem.tossBlue.withValues(alpha: 0.7),
            TossDesignSystem.tossBlue.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition,
                  style: const TextStyle(
                    color: TossDesignSystem.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$tempLow°C - $tempHigh°C',
                  style: TextStyle(
                    color: TossDesignSystem.white.withValues(alpha:0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '날씨와 운세가 조화를 이루는 날',
                  style: TextStyle(
                    color: TossDesignSystem.white.withValues(alpha:0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score점',
              style: const TextStyle(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideX(begin: -0.3, curve: Curves.easeOut);
  }

  /// 공유용 카드 UI
  static Widget buildShareableCard(Map<String, dynamic>? shareCard) {
    if (shareCard == null) return const SizedBox.shrink();
    
    final title = shareCard['title'] ?? '오늘의 운세';
    final subtitle = shareCard['subtitle'] ?? '';
    final emoji = shareCard['emoji'] ?? '✨';
    final hashtags = (shareCard['hashtags'] as List?)?.cast<String>() ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TossDesignSystem.pinkPrimary.withValues(alpha: 0.7),
            TossDesignSystem.warningOrange.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.pinkPrimary.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: TossDesignSystem.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: TossDesignSystem.white.withValues(alpha:0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: TossDesignSystem.white),
                onPressed: () {
                  // TODO: 공유 기능 구현
                },
              ),
            ],
          ),
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: hashtags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TossDesignSystem.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: TossDesignSystem.white.withValues(alpha:0.9),
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms)
      .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
  }

  /// Keyword tag cloud
  static Widget buildKeywordCloud({
    required List<String> keywords,
    required List<double> importance, // 0.0 to 1.0
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keywords.asMap().entries.map((entry) {
        final index = entry.key;
        final keyword = entry.value;
        final weight = importance.length > index ? importance[index] : 0.5;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 + (weight * 8),
            vertical: 6 + (weight * 4),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getKeywordColor(weight).withValues(alpha:0.8),
                _getKeywordColor(weight).withValues(alpha:0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getKeywordColor(weight).withValues(alpha:0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '#$keyword',
            style: TextStyle(
              color: TossDesignSystem.white,
              fontSize: 12 + (weight * 6),
              fontWeight: weight > 0.7 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ).animate(delay: Duration(milliseconds: index * 100))
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
      }).toList(),
    );
  }

  /// 토스 스타일 일별 운세 곡선 그래프
  static Widget buildTossStyleWeeklyChart({
    List<int>? dailyScores, // 7일간 점수
    int? todayIndex, // 오늘의 인덱스 (자동 계산)
    int? currentScore, // 현재 점수 (메인 스코어와 동일하게 사용)
    double height = 160, // 높이 증가
  }) {
    // 실제 DB 데이터 사용 (dailyScores가 null이면 빈 배열)
    final scores = dailyScores ?? [];
    final today = todayIndex ?? (scores.length - 1); // 오늘은 마지막 인덱스
    final todayScore = currentScore ?? (scores.isNotEmpty ? scores.last : 75); // 오늘의 총점수
    final weekdays = ['6일전', '5일전', '4일전', '3일전', '2일전', '어제', '오늘']; // 7일 데이터
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: height + 90, // 총점수 표시 공간 추가
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF2F4F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '일별 운세',
                style: TextStyle(
                  color: TossDesignSystem.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        // 안전한 인덱스 범위 체크
                        if (index >= 0 && index < weekdays.length && index < scores.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weekdays[index],
                              style: TextStyle(
                                color: index == today 
                                    ? const Color(0xFF4ECDC4)
                                    : TossDesignSystem.gray600,
                                fontSize: 12,
                                fontWeight: index == today 
                                    ? FontWeight.w600 
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: math.min(scores.length - 1, weekdays.length - 1).toDouble(),
                minY: math.max(0, scores.reduce(math.min) - 10).toDouble(),
                maxY: math.min(100, scores.reduce(math.max) + 10).toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: scores.asMap().entries.where((entry) {
                      // 유효한 인덱스만 사용
                      return entry.key >= 0 && entry.key < weekdays.length;
                    }).map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4ECDC4),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == today ? 6 : 4,
                          color: index == today 
                              ? const Color(0xFF4ECDC4)
                              : TossDesignSystem.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4ECDC4),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4ECDC4).withValues(alpha:0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}점',
                          const TextStyle(
                            color: TossDesignSystem.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          // 오늘 점수 강조 표시 (실제 API 점수 사용)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${weekdays[today]} ${todayScore}점',
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  /// 24-hour timeline mini chart (토스 스타일)
  static Widget buildTimelineChart({
    required List<int> hourlyScores, // 24 items
    int? currentHour,
    double height = 80,
  }) {
    return Container(
      height: height + 40,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 6 == 0) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: TossDesignSystem.gray600,
                        fontSize: 9,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 16,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: hourlyScores.asMap().entries.map((entry) {
            final hour = entry.key;
            final score = entry.value;
            final isCurrent = hour == currentHour;
            
            return BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  toY: score.toDouble(),
                  color: isCurrent ? TossDesignSystem.gray600 : TossDesignSystem.gray300,
                  width: 3,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideX(begin: 0.2, curve: Curves.easeOut);
  }

  /// Lucky items grid
  static Widget buildLuckyItemsGrid({
    required Map<String, String> luckyItems,
    double itemSize = 100,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: luckyItems.entries.map((entry) {
        final type = entry.key;
        final value = entry.value;
        
        return Container(
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getLuckyItemColor(type).withValues(alpha:0.8),
                _getLuckyItemColor(type).withValues(alpha:0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getLuckyItemColor(type).withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getLuckyItemIcon(type),
                color: TossDesignSystem.white,
                size: itemSize * 0.3,
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: TossDesignSystem.white.withValues(alpha:0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: TossDesignSystem.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: luckyItems.keys.toList().indexOf(type) * 150))
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
      }).toList(),
    );
  }

  /// AI insights card (토스 스타일)
  static Widget buildAIInsightsCard({
    required String insight,
    required List<String> tips,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: TossDesignSystem.black.withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: isDark ? TossDesignSystem.gray400 : TossDesignSystem.gray600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI 인사이트',
                    style: TextStyle(
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                insight,
                style: TextStyle(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              if (tips.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 700.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  /// Mini statistics dashboard (토스 스타일)
  static Widget buildMiniStatsDashboard({
    required Map<String, dynamic> stats,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark200
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context: context,
            icon: Icons.trending_up,
            label: '연속 일수',
            value: '${stats['streak'] ?? 0}일',
          ),
          _buildStatItem(
            context: context,
            icon: Icons.favorite,
            label: '평균 점수',
            value: '${stats['average'] ?? 0}점',
          ),
          _buildStatItem(
            context: context,
            icon: Icons.star,
            label: '최고 점수',
            value: '${stats['highest'] ?? 0}점',
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 800.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  static Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.gray400
                : TossDesignSystem.gray600,
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: TossDesignSystem.gray900,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: TossDesignSystem.gray600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Helper methods
  static Color _getScoreColor(int score) {
    if (score >= 90) return TossDesignSystem.success;
    if (score >= 80) return TossDesignSystem.tossBlue;
    if (score >= 70) return TossDesignSystem.warningOrange;
    if (score >= 60) return TossDesignSystem.warningYellow;
    return TossDesignSystem.error;
  }
  
  static String _getScoreGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 75) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 65) return 'B-';
    if (score >= 60) return 'C+';
    if (score >= 55) return 'C';
    if (score >= 50) return 'C-';
    return 'D';
  }
  
  static Color _getScoreGradeColor(int score) {
    if (score >= 85) return const Color(0xFF10B981); // 그린
    if (score >= 75) return const Color(0xFF3B82F6); // 블루
    if (score >= 65) return const Color(0xFFF59E0B); // 앤버
    if (score >= 55) return const Color(0xFFF97316); // 오렌지
    return const Color(0xFFEF4444); // 레드
  }

  static Color _getKeywordColor(double weight) {
    if (weight > 0.8) return TossDesignSystem.pinkPrimary;
    if (weight > 0.6) return TossDesignSystem.purple;
    if (weight > 0.4) return TossDesignSystem.tossBlue;
    if (weight > 0.2) return TossDesignSystem.tossBlue;
    return TossDesignSystem.success;
  }

  static Color _getLuckyItemColor(String type) {
    switch (type.toLowerCase()) {
      case '색상':
      case 'color':
        return TossDesignSystem.pinkPrimary;
      case '숫자':
      case 'number':
        return TossDesignSystem.tossBlue;
      case '시간':
      case 'time':
        return TossDesignSystem.warningOrange;
      case '방향':
      case 'direction':
        return TossDesignSystem.success;
      case '음식':
      case 'food':
        return TossDesignSystem.error;
      default:
        return TossDesignSystem.purple;
    }
  }

  static IconData _getLuckyItemIcon(String type) {
    switch (type.toLowerCase()) {
      case '색상':
      case 'color':
        return Icons.palette;
      case '숫자':
      case 'number':
        return Icons.looks_one;
      case '시간':
      case 'time':
        return Icons.access_time;
      case '방향':
      case 'direction':
        return Icons.explore;
      case '음식':
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.star;
    }
  }

  /// 토스 스타일 행운의 요소 태그들
  static Widget buildTossStyleLuckyTags({
    required BuildContext context,
    String? luckyColor,
    String? luckyFood,
    List<String>? luckyNumbers,
    String? luckyDirection,
  }) {
    final items = <Map<String, String>>[];
    
    if (luckyColor != null) items.add({'label': '색상', 'value': luckyColor});
    if (luckyFood != null) items.add({'label': '음식', 'value': luckyFood});
    if (luckyNumbers != null && luckyNumbers.isNotEmpty) {
      items.add({'label': '숫자', 'value': luckyNumbers.join(', ')});
    }
    if (luckyDirection != null) items.add({'label': '방향', 'value': luckyDirection});
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : const Color(0xFFF2F4F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '행운을 가져오는 것들',
            style: TextStyle(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w700, // 토스 스타일 굵은 제목
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5, // 가로:세로 비율 조정
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark300 : const Color(0xFFF2F4F6), // 토스 배경색
                borderRadius: BorderRadius.circular(24), // 더 둥글게
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['label']!,
                    style: TextStyle(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item['value']!,
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 400.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  /// 토스 스타일 행운의 코디 섹션
  static Widget buildTossStyleLuckyOutfit({
    required BuildContext context,
    required String title,
    required String description,
    List<String>? items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : const Color(0xFFF2F4F6),
          width: 1,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (items != null && items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 500.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  /// 토스 스타일 유명인 리스트 (띠별/별자리별)
  static Widget buildTossStyleCelebrityList({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Map<String, String>> celebrities,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ...celebrities.map((celeb) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      celeb['year'] ?? '',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        celeb['name'] ?? '',
                        style: TextStyle(
                          color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if ((celeb['description'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          celeb['description'] ?? '',
                          style: TextStyle(
                            color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  /// 토스 스타일 년생별 운세 카드
  static Widget buildTossStyleAgeFortuneCard({
    required String ageGroup,
    required String title,
    required String description,
    String? zodiacAnimal,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ageGroup,
                style: const TextStyle(
                  color: TossDesignSystem.gray900,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (zodiacAnimal != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    zodiacAnimal,
                    style: const TextStyle(
                      color: TossDesignSystem.gray600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: TossDesignSystem.gray900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: TossDesignSystem.gray600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 700.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  /// 토스 스타일 운세 요약 위젯
  static Widget buildTossStyleFortuneSummary({
    required Map<String, dynamic>? fortuneSummary,
    required String? userZodiacAnimal,
    required String? userZodiacSign,
    required String? userMBTI,
  }) {
    if (fortuneSummary == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark200
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : const Color(0xFFE5E7EB),
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '나만의 오늘 운세',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 탭 형태의 운세 요약
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // 탭 바
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    isScrollable: false, // 균등 분할을 위해 추가
                    indicator: BoxDecoration(
                      color: TossDesignSystem.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: TossDesignSystem.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    indicatorSize: TabBarIndicatorSize.tab, // 탭 전체 영역을 지시자로 사용
                    labelColor: const Color(0xFF1F2937),
                    unselectedLabelColor: const Color(0xFF6B7280),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    dividerHeight: 0,
                    tabAlignment: TabAlignment.fill, // 탭을 균등하게 채움
                    tabs: [
                      // 각 탭의 높이와 패딩을 통일
                      Container(
                        height: 40, // 고정 높이
                        alignment: Alignment.center,
                        child: const Text('띠'),
                      ),
                      Container(
                        height: 40, // 고정 높이
                        alignment: Alignment.center,
                        child: const Text('별자리'),
                      ),
                      Container(
                        height: 40, // 고정 높이
                        alignment: Alignment.center,
                        child: const Text('MBTI'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 탭 내용
                SizedBox(
                  height: 180,
                  child: TabBarView(
                    children: [
                      // 띠 기준 운세
                      _buildFortuneSummaryTab(
                        type: '띠',
                        userType: userZodiacAnimal ?? '',
                        fortuneData: fortuneSummary['byZodiacAnimal'],
                        icon: '🐉',
                      ),
                      
                      // 별자리 기준 운세
                      _buildFortuneSummaryTab(
                        type: '별자리',
                        userType: userZodiacSign ?? '',
                        fortuneData: fortuneSummary['byZodiacSign'],
                        icon: '⭐',
                      ),
                      
                      // MBTI 기준 운세
                      _buildFortuneSummaryTab(
                        type: 'MBTI',
                        userType: userMBTI ?? '',
                        fortuneData: fortuneSummary['byMBTI'],
                        icon: '🧠',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 800.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  static Widget _buildFortuneSummaryTab({
    required String type,
    required String userType,
    required Map<String, dynamic>? fortuneData,
    required String icon,
  }) {
    if (fortuneData == null) {
      return const Center(
        child: Text(
          '운세 정보를 불러올 수 없습니다',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      );
    }

    final title = fortuneData['title'] as String? ?? '';
    final content = fortuneData['content'] as String? ?? '';
    final score = fortuneData['score'] as int? ?? 80;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '$userType인 당신',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$score점',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(score),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 운세 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          
          // 운세 내용
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 토스 스타일 공유 섹션
  static Widget buildTossStyleShareSection({
    required String shareCount,
    VoidCallback? onShare,
    VoidCallback? onSave,
    VoidCallback? onReview,
    VoidCallback? onOtherFortune,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '나의 운세를 공유해보세요!',
            style: TextStyle(
              color: TossDesignSystem.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$shareCount명이 공유했습니다.',
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha:0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildShareButton(
                      icon: Icons.share,
                      label: '공유하기',
                      onTap: onShare,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShareButton(
                      icon: Icons.bookmark,
                      label: '저장하기',
                      onTap: onSave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildShareButton(
                      icon: Icons.refresh,
                      label: '다시보기',
                      onTap: onReview,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShareButton(
                      icon: Icons.auto_awesome,
                      label: '다른운세보기',
                      onTap: onOtherFortune,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 800.ms)
      .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  static Widget _buildShareButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: TossDesignSystem.white.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TossDesignSystem.white.withValues(alpha:0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TossDesignSystem.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: TossDesignSystem.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: TossDesignSystem.white.withValues(alpha:0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ));
  }

  /// 토스 스타일 액션 버튼들 (공유하기, 저장하기, 다시보기, 다른운세보기)
  static Widget buildTossStyleActionButtons({
    VoidCallback? onShare,
    VoidCallback? onSave,
    VoidCallback? onReview,
    VoidCallback? onOtherFortune,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTossActionButton(
            icon: Icons.share,
            label: '공유하기',
            onTap: onShare,
          ),
          _buildTossActionButton(
            icon: Icons.bookmark,
            label: '저장하기',
            onTap: onSave,
          ),
          _buildTossActionButton(
            icon: Icons.refresh,
            label: '다시보기',
            onTap: onReview,
          ),
          _buildTossActionButton(
            icon: Icons.auto_awesome,
            label: '다른운세보기',
            onTap: onOtherFortune,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 900.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  static Widget _buildTossActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}