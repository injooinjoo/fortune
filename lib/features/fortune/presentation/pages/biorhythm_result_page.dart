import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../widgets/biorhythm_widgets.dart';
import '../../../../core/theme/toss_design_system.dart';

class BiorhythmResultPage extends StatefulWidget {
  final DateTime birthDate;
  
  const BiorhythmResultPage({
    super.key,
    required this.birthDate,
  });

  @override
  State<BiorhythmResultPage> createState() => _BiorhythmResultPageState();
}

class _BiorhythmResultPageState extends State<BiorhythmResultPage>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentPage = 0;
  late BiorhythmData _biorhythmData;
  
  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _biorhythmData = BiorhythmData.calculate(widget.birthDate);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: TossDesignSystem.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '바이오리듬 분석 결과',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
              size: 22,
            ),
            onPressed: () {
              // TODO: 공유 기능 구현
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 페이지 인디케이터
          _buildPageIndicator(),
          
          // 메인 콘텐츠
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildTodayStatusPage(),
                  _buildWeeklyTrendPage(),
                  _buildPersonalAdvicePage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? TossTheme.primaryBlue
                  : (isDark ? TossDesignSystem.grayDark400 : TossTheme.borderGray300),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTodayStatusPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 오늘의 전체 컨디션
          TodayOverallStatusCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 3가지 리듬 상세
          RhythmDetailCards(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 오늘의 추천
          TodayRecommendationCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 주간 전망 헤더
          WeeklyForecastHeader(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 주간 차트
          WeeklyRhythmChart(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 주요 날짜들
          ImportantDatesCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 주간 활동 가이드
          WeeklyActivityGuide(biorhythmData: _biorhythmData),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPersonalAdvicePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 개인 맞춤 분석
          PersonalAnalysisCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 라이프 스타일 조언
          LifestyleAdviceCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 건강 관리 팁
          HealthTipsCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 다음 분석 예약
          NextAnalysisCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class BiorhythmData {
  final DateTime birthDate;
  final DateTime today;
  final int totalDays;
  
  // 오늘의 리듬 값 (-100 ~ 100)
  final double physicalToday;
  final double emotionalToday;
  final double intellectualToday;
  
  // 주간 데이터 (7일)
  final List<double> physicalWeek;
  final List<double> emotionalWeek;
  final List<double> intellectualWeek;
  
  // 전체 점수
  final int overallScore;
  final String statusMessage;
  final Color statusColor;

  BiorhythmData._({
    required this.birthDate,
    required this.today,
    required this.totalDays,
    required this.physicalToday,
    required this.emotionalToday,
    required this.intellectualToday,
    required this.physicalWeek,
    required this.emotionalWeek,
    required this.intellectualWeek,
    required this.overallScore,
    required this.statusMessage,
    required this.statusColor,
  });

  factory BiorhythmData.calculate(DateTime birthDate) {
    final today = DateTime.now();
    final totalDays = today.difference(birthDate).inDays;
    
    // 바이오리듬 계산 (각각 23일, 28일, 33일 주기)
    final physicalToday = math.sin(2 * math.pi * totalDays / 23) * 100;
    final emotionalToday = math.sin(2 * math.pi * totalDays / 28) * 100;
    final intellectualToday = math.sin(2 * math.pi * totalDays / 33) * 100;
    
    // 주간 데이터 계산
    final physicalWeek = <double>[];
    final emotionalWeek = <double>[];
    final intellectualWeek = <double>[];
    
    for (int i = 0; i < 7; i++) {
      final dayOffset = totalDays + i;
      physicalWeek.add(math.sin(2 * math.pi * dayOffset / 23) * 100);
      emotionalWeek.add(math.sin(2 * math.pi * dayOffset / 28) * 100);
      intellectualWeek.add(math.sin(2 * math.pi * dayOffset / 33) * 100);
    }
    
    // 전체 점수 계산
    final averageScore = (physicalToday + emotionalToday + intellectualToday) / 3;
    final overallScore = (averageScore + 100) ~/ 2; // 0-100 점수로 변환
    
    // 상태 메시지 결정
    String statusMessage;
    Color statusColor;
    
    if (overallScore >= 80) {
      statusMessage = '최고의 컨디션이에요!';
      statusColor = const Color(0xFF00C851);
    } else if (overallScore >= 60) {
      statusMessage = '좋은 컨디션입니다';
      statusColor = const Color(0xFF00C896);
    } else if (overallScore >= 40) {
      statusMessage = '평균적인 상태예요';
      statusColor = const Color(0xFFFFB300);
    } else if (overallScore >= 20) {
      statusMessage = '조금 주의가 필요해요';
      statusColor = const Color(0xFFFF9500);
    } else {
      statusMessage = '충분한 휴식이 필요해요';
      statusColor = const Color(0xFFFF5A5F);
    }
    
    return BiorhythmData._(
      birthDate: birthDate,
      today: today,
      totalDays: totalDays,
      physicalToday: physicalToday,
      emotionalToday: emotionalToday,
      intellectualToday: intellectualToday,
      physicalWeek: physicalWeek,
      emotionalWeek: emotionalWeek,
      intellectualWeek: intellectualWeek,
      overallScore: overallScore,
      statusMessage: statusMessage,
      statusColor: statusColor,
    );
  }
  
  // 리듬별 점수 (0-100)
  int get physicalScore => ((physicalToday + 100) / 2).round();
  int get emotionalScore => ((emotionalToday + 100) / 2).round();
  int get intellectualScore => ((intellectualToday + 100) / 2).round();
  
  // 리듬별 상태 텍스트
  String get physicalStatus {
    if (physicalScore >= 75) return '활력 넘치는 상태';
    if (physicalScore >= 50) return '안정적인 체력';
    if (physicalScore >= 25) return '약간 피곤한 상태';
    return '충분한 휴식 필요';
  }
  
  String get emotionalStatus {
    if (emotionalScore >= 75) return '기분이 매우 좋은 날';
    if (emotionalScore >= 50) return '감정이 안정적';
    if (emotionalScore >= 25) return '약간 예민할 수 있음';
    return '감정 관리에 주의';
  }
  
  String get intellectualStatus {
    if (intellectualScore >= 75) return '집중력이 뛰어난 날';
    if (intellectualScore >= 50) return '사고력이 좋음';
    if (intellectualScore >= 25) return '집중하기 어려울 수 있음';
    return '복잡한 일은 피하세요';
  }
}