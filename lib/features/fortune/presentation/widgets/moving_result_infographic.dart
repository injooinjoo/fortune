import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/theme/typography_unified.dart';

/// 인포그래픽 스타일 이사운 결과 페이지
class MovingResultInfographic extends StatefulWidget {
  final String name;
  final DateTime birthDate;
  final String currentArea;
  final String targetArea;
  final String movingPeriod;
  final String purpose;
  final VoidCallback onRetry;

  const MovingResultInfographic({
    super.key,
    required this.name,
    required this.birthDate,
    required this.currentArea,
    required this.targetArea,
    required this.movingPeriod,
    required this.purpose,
    required this.onRetry,
  });

  @override
  State<MovingResultInfographic> createState() => _MovingResultInfographicState();
}

class _MovingResultInfographicState extends State<MovingResultInfographic> 
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  int _currentPage = 0;
  
  // 운세 데이터
  late MovingFortuneData _fortuneData;
  
  // 애니메이션 컨트롤러들
  late AnimationController _fadeController;
  late AnimationController _scoreController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _generateFortuneData();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scoreAnimation = Tween<double>(begin: 0, end: _fortuneData.overallScore / 100).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });
  }

  void _generateFortuneData() {
    final random = math.Random();
    final now = DateTime.now();
    
    // 종합 점수 계산 (생년월일과 목적에 따라)
    int baseScore = 70;
    if (widget.purpose == '결혼해서') baseScore += 10;
    if (widget.purpose == '투자 목적') baseScore += 5;
    baseScore += random.nextInt(20);
    
    // 방향별 운세 점수
    final directions = {
      '동': 65 + random.nextInt(30),
      '서': 65 + random.nextInt(30),
      '남': 65 + random.nextInt(30),
      '북': 65 + random.nextInt(30),
      '동남': 65 + random.nextInt(30),
      '동북': 65 + random.nextInt(30),
      '서남': 65 + random.nextInt(30),
      '서북': 65 + random.nextInt(30),
    };
    
    // 최고 방향 찾기
    String bestDirection = directions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // 월별 운세 데이터 (3개월)
    final monthlyScores = List.generate(90, (day) {
      double baseValue = 50 + math.sin(day * 0.1) * 30;
      return baseValue + random.nextInt(20);
    });
    
    // 길한 날짜들
    final luckyDates = <DateTime>[];
    for (int i = 0; i < 5; i++) {
      luckyDates.add(now.add(Duration(days: 5 + i * 7 + random.nextInt(5))));
    }
    
    // 예산 브레이크다운
    final budget = {
      '이사업체': 150 + random.nextInt(100),
      '포장재료': 30 + random.nextInt(20),
      '청소비용': 50 + random.nextInt(30),
      '기타비용': 20 + random.nextInt(20),
    };
    
    _fortuneData = MovingFortuneData(
      overallScore: baseScore.clamp(0, 100),
      bestDirection: bestDirection,
      directionScores: directions,
      monthlyScores: monthlyScores,
      luckyDates: luckyDates,
      budgetBreakdown: budget,
      checklistItems: _generateChecklist(),
      houseTypeScores: _generateHouseTypeScores(),
    );
  }

  List<ChecklistItem> _generateChecklist() {
    return [
      ChecklistItem('D-30', '이사업체 견적 받기', false),
      ChecklistItem('D-30', '새 집 계약 확인', false),
      ChecklistItem('D-21', '불필요한 물건 정리', false),
      ChecklistItem('D-14', '주소 이전 신고', false),
      ChecklistItem('D-14', '공과금 정산 예약', false),
      ChecklistItem('D-7', '포장 시작', false),
      ChecklistItem('D-3', '냉장고 정리', false),
      ChecklistItem('D-1', '귀중품 별도 보관', false),
    ];
  }

  Map<String, int> _generateHouseTypeScores() {
    final random = math.Random();
    final scores = <String, int>{};
    
    // 목적에 따라 점수 조정
    switch (widget.purpose) {
      case '직장 때문에':
        scores['오피스텔'] = 85 + random.nextInt(10);
        scores['원룸/투룸'] = 80 + random.nextInt(10);
        scores['아파트'] = 70 + random.nextInt(10);
        scores['단독주택'] = 60 + random.nextInt(10);
        break;
      case '결혼해서':
        scores['아파트'] = 90 + random.nextInt(10);
        scores['빌라'] = 75 + random.nextInt(10);
        scores['단독주택'] = 70 + random.nextInt(10);
        scores['오피스텔'] = 60 + random.nextInt(10);
        break;
      case '교육 환경':
        scores['아파트'] = 95 + random.nextInt(5);
        scores['단독주택'] = 80 + random.nextInt(10);
        scores['빌라'] = 75 + random.nextInt(10);
        scores['오피스텔'] = 50 + random.nextInt(10);
        break;
      default:
        scores['아파트'] = 75 + random.nextInt(20);
        scores['빌라'] = 75 + random.nextInt(20);
        scores['오피스텔'] = 75 + random.nextInt(20);
        scores['단독주택'] = 75 + random.nextInt(20);
    }
    
    return scores;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 헤더
                _buildHeader(),

                // 페이지 인디케이터
                _buildPageIndicator(),

                // 메인 콘텐츠 (PageView)
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        HapticFeedback.lightImpact();
                      },
                      children: [
                        _buildOverviewPage(),
                        _buildTimingPage(),
                        _buildDirectionPage(),
                        _buildChecklistPage(),
                        _buildBudgetPage(),
                      ],
                    ),
                  ),
                ),

                // 하단 버튼 공간 확보
                const BottomButtonSpacing(),
              ],
            ),

            // Floating 버튼
            TossFloatingProgressButtonPositioned(
              text: '다시 보기',
              onPressed: widget.onRetry,
              isEnabled: true,
              showProgress: false,
              isVisible: true,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // 뒤로가기 버튼
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossDesignSystem.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 20,
                  color: TossTheme.textBlack,
                ),
              ),
            ),
          ),
          // 제목
          Column(
            children: [
              Text(
                '${widget.name}님의',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '이사운 분석 완료',
                style: TossTheme.heading1.copyWith(
                  
                  fontWeight: FontWeight.w800,
                  color: TossTheme.textBlack,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? TossTheme.primaryBlue : TossTheme.borderGray300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // 페이지 1: 종합 점수와 요약
  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 종합 점수 카드
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '종합 이사운',
                  style: TossTheme.heading3,
                ),
                const SizedBox(height: 24),
                // 원형 점수 게이지
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(200, 200),
                            painter: CircularScorePainter(
                              score: _scoreAnimation.value,
                              color: _getScoreColor(_fortuneData.overallScore),
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              return Text(
                                '${(_scoreAnimation.value * 100).toInt()}',
                                style: TypographyUnified.displayLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _getScoreColor(_fortuneData.overallScore),
                                ),
                              );
                            },
                          ),
                          Text(
                            _getScoreDescription(_fortuneData.overallScore),
                            style: TossTheme.body2.copyWith(
                              
                              fontWeight: FontWeight.w600,
                              color: _getScoreColor(_fortuneData.overallScore),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 핵심 메시지
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getScoreColor(_fortuneData.overallScore).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        color: _getScoreColor(_fortuneData.overallScore),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMainAdvice(),
                          style: TossTheme.body2.copyWith(
                            height: 1.5,
                            color: TossTheme.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 16),
          
          // 빠른 요약 카드들
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  '최적 방향',
                  _fortuneData.bestDirection,
                  Icons.explore_rounded,
                  TossTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoCard(
                  '최적 시기',
                  '${_fortuneData.luckyDates.first.month}월 ${_fortuneData.luckyDates.first.day}일',
                  Icons.calendar_today_rounded,
                  TossDesignSystem.warningOrange,
                ),
              ),
            ],
          ).animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  '추천 주거',
                  _fortuneData.houseTypeScores.entries.first.key,
                  Icons.home_rounded,
                  TossDesignSystem.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoCard(
                  '예상 비용',
                  '${_fortuneData.budgetBreakdown.values.reduce((a, b) => a + b)}만원',
                  Icons.payments_rounded,
                  TossDesignSystem.primaryBlue,
                ),
              ),
            ],
          ).animate()
            .fadeIn(delay: 600.ms)
            .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 페이지 2: 시기별 운세
  Widget _buildTimingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3개월 이사운 흐름',
            style: TossTheme.heading2,
          ),
          const SizedBox(height: 20),
          
          // 운세 차트
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                            color: TossTheme.borderGray200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 30,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now().add(Duration(days: value.toInt()));
                              return Text(
                                '${date.month}/${date.day}',
                                style: TossTheme.caption,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: TossTheme.caption,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 89,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _fortuneData.monthlyScores.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              TossTheme.primaryBlue.withValues(alpha: 0.8),
                              TossTheme.primaryBlue,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                TossTheme.primaryBlue.withValues(alpha: 0.1),
                                TossTheme.primaryBlue.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 범례
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegend('매우 좋음', TossDesignSystem.success),
                    _buildLegend('좋음', TossTheme.primaryBlue),
                    _buildLegend('보통', TossDesignSystem.warningOrange),
                    _buildLegend('주의', TossDesignSystem.error),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 추천 날짜 리스트
          Text(
            '추천 이사 날짜 TOP 5',
            style: TossTheme.heading3,
          ),
          const SizedBox(height: 12),
          
          ..._fortuneData.luckyDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TossCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: index == 0 
                            ? TossDesignSystem.warningOrange.withValues(alpha: 0.2)
                            : TossTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TossTheme.heading3.copyWith(
                            color: index == 0 ? TossDesignSystem.warningOrange : TossTheme.primaryBlue,
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
                            '${date.month}월 ${date.day}일 (${_getWeekdayName(date.weekday)})',
                            style: TossTheme.heading4,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            index == 0 ? '최고의 이사 날짜입니다' : '좋은 기운이 가득한 날입니다',
                            style: TossTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    if (index == 0)
                      Icon(
                        Icons.star_rounded,
                        color: TossDesignSystem.warningOrange,
                        size: 24,
                      ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: Duration(milliseconds: 200 + index * 100))
                .slideX(begin: 0.1, end: 0),
            );
          }),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 페이지 3: 방향별 운세
  Widget _buildDirectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방향별 이사운',
            style: TossTheme.heading2,
          ),
          const SizedBox(height: 20),
          
          // 레이더 차트
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      radarBorderData: BorderSide(color: TossTheme.borderGray300),
                      gridBorderData: BorderSide(color: TossTheme.borderGray200),
                      tickBorderData: BorderSide(color: TossTheme.borderGray200),
                      titleTextStyle: TossTheme.body2,
                      tickCount: 5,
                      ticksTextStyle: TypographyUnified.labelTiny,
                      dataSets: [
                        RadarDataSet(
                          fillColor: TossTheme.primaryBlue.withValues(alpha: 0.2),
                          borderColor: TossTheme.primaryBlue,
                          borderWidth: 2,
                          dataEntries: _fortuneData.directionScores.values
                              .map((score) => RadarEntry(value: score.toDouble()))
                              .toList(),
                        ),
                      ],
                      getTitle: (index, angle) {
                        final titles = _fortuneData.directionScores.keys.toList();
                        return RadarChartTitle(
                          text: titles[index],
                          angle: 0,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 최적 방향 강조
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossTheme.primaryBlue.withValues(alpha: 0.1),
                        TossTheme.primaryBlue.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: TossTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.navigation_rounded,
                          color: TossDesignSystem.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '최적 방향: ${_fortuneData.bestDirection}쪽',
                              style: TossTheme.heading3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.currentArea}에서 ${_fortuneData.bestDirection}쪽 방향이 가장 좋습니다',
                              style: TossTheme.body2.copyWith(
                                color: TossTheme.textGray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 방향별 상세 점수
          Text(
            '방향별 상세 분석',
            style: TossTheme.heading3,
          ),
          const SizedBox(height: 12),
          
          ..._fortuneData.directionScores.entries.map((entry) {
            final isBest = entry.key == _fortuneData.bestDirection;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isBest ? TossTheme.primaryBlue.withValues(alpha: 0.05) : TossDesignSystem.white,
                  border: Border.all(
                    color: isBest ? TossTheme.primaryBlue : TossTheme.borderGray200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TossTheme.heading4.copyWith(
                        color: isBest ? TossTheme.primaryBlue : TossTheme.textBlack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: entry.value / 100,
                        backgroundColor: TossTheme.borderGray200,
                        valueColor: AlwaysStoppedAnimation(
                          isBest ? TossTheme.primaryBlue : TossTheme.textGray400,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.value}점',
                      style: TossTheme.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isBest ? TossTheme.primaryBlue : TossTheme.textGray600,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TossTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '최적',
                          style: TossTheme.caption.copyWith(
                            color: TossDesignSystem.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 페이지 4: 체크리스트
  Widget _buildChecklistPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이사 준비 체크리스트',
            style: TossTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            '시기별로 준비해야 할 사항들입니다',
            style: TossTheme.body2.copyWith(color: TossTheme.textGray600),
          ),
          const SizedBox(height: 20),
          
          // 타임라인 형태의 체크리스트
          ..._fortuneData.checklistItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLastItem = index == _fortuneData.checklistItems.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타임라인 라인
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.isCompleted 
                            ? TossDesignSystem.success 
                            : TossTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: item.isCompleted
                            ? Icon(Icons.check, color: TossDesignSystem.white, size: 20)
                            : Text(
                                '${index + 1}',
                                style: TossTheme.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: TossTheme.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                    if (!isLastItem)
                      Container(
                        width: 2,
                        height: 60,
                        color: TossTheme.borderGray200,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // 체크리스트 아이템
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TossCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTimeColor(item.timing).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.timing,
                                  style: TossTheme.caption.copyWith(
                                    color: _getTimeColor(item.timing),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (item.isCompleted)
                                Text(
                                  '완료',
                                  style: TossTheme.caption.copyWith(
                                    color: TossDesignSystem.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.task,
                            style: TossTheme.body2.copyWith(
                              decoration: item.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: item.isCompleted 
                                  ? TossTheme.textGray400 
                                  : TossTheme.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate()
              .fadeIn(delay: Duration(milliseconds: 100 + index * 50))
              .slideX(begin: 0.05, end: 0);
          }),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 페이지 5: 예산 분석
  Widget _buildBudgetPage() {
    final totalBudget = _fortuneData.budgetBreakdown.values.reduce((a, b) => a + b);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예상 이사 비용',
            style: TossTheme.heading2,
          ),
          const SizedBox(height: 20),
          
          // 총 비용 카드
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '예상 총 비용',
                  style: TossTheme.body2.copyWith(color: TossTheme.textGray600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalBudget.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}만원',
                  style: TypographyUnified.displayLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TossTheme.primaryBlue,
                  ),
                ).animate()
                  .fadeIn()
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                const SizedBox(height: 20),
                
                // 도넛 차트
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _fortuneData.budgetBreakdown.entries.map((entry) {
                        final percentage = (entry.value / totalBudget * 100).round();
                        return PieChartSectionData(
                          color: _getBudgetColor(entry.key),
                          value: entry.value.toDouble(),
                          title: '$percentage%',
                          radius: 40,
                          titleStyle: TossTheme.caption.copyWith(
                            color: TossDesignSystem.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 항목별 상세
          Text(
            '항목별 상세',
            style: TossTheme.heading3,
          ),
          const SizedBox(height: 12),
          
          ..._fortuneData.budgetBreakdown.entries.map((entry) {
            final percentage = (entry.value / totalBudget * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TossDesignSystem.white,
                  border: Border.all(color: TossTheme.borderGray200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getBudgetColor(entry.key),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TossTheme.body2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '전체의 $percentage%',
                            style: TossTheme.caption.copyWith(
                              color: TossTheme.textGray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.value}만원',
                      style: TossTheme.heading4,
                    ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 20),
          
          // 절약 팁
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.savings_rounded,
                  color: TossDesignSystem.warningOrange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '절약 TIP',
                        style: TossTheme.heading4.copyWith(
                          color: TossDesignSystem.warningOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '평일 이사 시 약 20% 절약 가능합니다',
                        style: TossTheme.body2.copyWith(
                          color: TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(String title, String value, IconData icon, Color color) {
    return TossCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TossTheme.heading3.copyWith(
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TossTheme.caption),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.success;
    if (score >= 60) return TossTheme.primaryBlue;
    return TossDesignSystem.warningOrange;
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '최고의 이사운!';
    if (score >= 80) return '매우 좋은 이사운';
    if (score >= 70) return '좋은 이사운';
    if (score >= 60) return '양호한 이사운';
    return '보통 이사운';
  }

  String _getMainAdvice() {
    switch (widget.purpose) {
      case '직장 때문에':
        return '출퇴근이 편리한 ${_fortuneData.bestDirection}쪽이 최적입니다. 교통 접근성을 우선 고려하세요.';
      case '결혼해서':
        return '두 분의 새로운 시작에 ${_fortuneData.bestDirection}쪽이 길합니다. 남향집이 화목한 가정을 만듭니다.';
      case '교육 환경':
        return '자녀의 학업운이 ${_fortuneData.bestDirection}쪽에서 상승합니다. 조용하고 안전한 환경을 선택하세요.';
      case '투자 목적':
        return '${_fortuneData.bestDirection}쪽 지역의 가치 상승이 예상됩니다. 교통 개발 계획을 확인하세요.';
      default:
        return '${_fortuneData.bestDirection}쪽으로의 이사가 새로운 행운을 가져다 줄 것입니다.';
    }
  }

  Color _getTimeColor(String timing) {
    if (timing.contains('D-30')) return TossDesignSystem.primaryBlue;
    if (timing.contains('D-21') || timing.contains('D-14')) return TossDesignSystem.warningOrange;
    if (timing.contains('D-7') || timing.contains('D-3') || timing.contains('D-1')) return TossDesignSystem.error;
    return TossTheme.primaryBlue;
  }

  Color _getBudgetColor(String category) {
    switch (category) {
      case '이사업체': return TossTheme.primaryBlue;
      case '포장재료': return TossDesignSystem.warningOrange;
      case '청소비용': return TossDesignSystem.success;
      case '기타비용': return TossDesignSystem.primaryBlue;
      default: return TossDesignSystem.gray300;
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
}

// 데이터 모델들
class MovingFortuneData {
  final int overallScore;
  final String bestDirection;
  final Map<String, int> directionScores;
  final List<double> monthlyScores;
  final List<DateTime> luckyDates;
  final Map<String, int> budgetBreakdown;
  final List<ChecklistItem> checklistItems;
  final Map<String, int> houseTypeScores;

  MovingFortuneData({
    required this.overallScore,
    required this.bestDirection,
    required this.directionScores,
    required this.monthlyScores,
    required this.luckyDates,
    required this.budgetBreakdown,
    required this.checklistItems,
    required this.houseTypeScores,
  });
}

class ChecklistItem {
  final String timing;
  final String task;
  final bool isCompleted;

  ChecklistItem(this.timing, this.task, this.isCompleted);
}

// 원형 점수 그리기 Painter
class CircularScorePainter extends CustomPainter {
  final double score;
  final Color color;

  CircularScorePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 배경 원
    final backgroundPaint = Paint()
      ..color = TossDesignSystem.gray300.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    
    canvas.drawCircle(center, radius - 6, backgroundPaint);
    
    // 점수 원
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * score;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}