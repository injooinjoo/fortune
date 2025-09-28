import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/fortune/domain/models/career_coaching_model.dart';
import '../data/services/fortune_api_service.dart';
import '../core/utils/logger.dart';

/// 커리어 코칭 서비스
/// API와 연동하여 맞춤형 분석 제공
class CareerCoachingService {
  final FortuneApiService _apiService;
  
  CareerCoachingService(this._apiService);

  /// 커리어 분석 및 코칭 결과 생성
  Future<CareerCoachingResult> analyzeAndGenerateCoaching(
    CareerCoachingInput input,
  ) async {
    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Logger.warning('User not authenticated, using mock data');
        return _generateMockResult(input);
      }

      // Prepare API data
      final careerData = {
        'current_role': input.currentRole,
        'experience_level': input.experienceLevel,
        'industry': input.industry ?? '',
        'primary_concern': input.primaryConcern,
        'short_term_goal': input.shortTermGoal,
        'skills_to_improve': input.skillsToImprove,
        'core_value': input.coreValue,
      };

      // Call API
      final fortune = await _apiService.getCareerCoachingFortune(
        userId: user.id,
        careerData: careerData,
      );

      // Convert API response to CareerCoachingResult
      return _convertFortuneToCareerResult(fortune, input);
    } catch (e) {
      Logger.warning('[CareerCoachingService] API 커리어 코칭 데이터 로드 실패 (로컬 분석 사용): $e');
      // Fallback to mock data
      return _generateMockResult(input);
    }
  }

  /// Convert Fortune entity to CareerCoachingResult
  CareerCoachingResult _convertFortuneToCareerResult(dynamic fortune, CareerCoachingInput input) {
    try {
      // Extract data from fortune result
      final data = fortune.result ?? {};
      
      // Parse health score from result
      final healthScore = _parseHealthScore(data, input);
      
      // Parse insights
      final keyInsights = _parseInsights(data, input);
      
      // Parse action plan
      final thirtyDayPlan = _parseActionPlan(data, input);
      
      // Parse growth roadmap
      final growthRoadmap = _parseGrowthRoadmap(data, input);
      
      // Parse recommendations
      final recommendations = _parseRecommendations(data, input);
      
      // Parse market trends
      final marketTrends = _parseMarketTrends(data, input);
      
      // Generate assessment and message
      final overallAssessment = data['overall_assessment'] as String? ?? 
        _generateOverallAssessment(input, healthScore);
      final motivationalMessage = data['motivational_message'] as String? ?? 
        _generateMotivationalMessage(input, healthScore);

      return CareerCoachingResult(
        healthScore: healthScore,
        overallAssessment: overallAssessment,
        keyInsights: keyInsights,
        thirtyDayPlan: thirtyDayPlan,
        growthRoadmap: growthRoadmap,
        recommendations: recommendations,
        marketTrends: marketTrends,
        motivationalMessage: motivationalMessage,
      );
    } catch (e) {
      Logger.warning('[CareerCoachingService] 커리어 코칭 결과 파싱 실패 (기본 분석 사용): $e');
      // Fallback to mock if parsing fails
      return _generateMockResult(input);
    }
  }

  CareerHealthScore _parseHealthScore(Map<String, dynamic> data, CareerCoachingInput input) {
    final scores = data['scores'] as Map<String, dynamic>? ?? {};
    
    final overallScore = (scores['overall'] as num?)?.toInt() ?? 70;
    final growthScore = (scores['growth'] as num?)?.toInt() ?? 75;
    final satisfactionScore = (scores['satisfaction'] as num?)?.toInt() ?? 70;
    final marketScore = (scores['market'] as num?)?.toInt() ?? 65;
    final balanceScore = (scores['balance'] as num?)?.toInt() ?? 60;
    
    String level;
    if (overallScore >= 80) {
      level = 'excellent';
    } else if (overallScore >= 65) {
      level = 'good';
    } else if (overallScore >= 50) {
      level = 'moderate';
    } else {
      level = 'needs-attention';
    }
    
    return CareerHealthScore(
      overallScore: overallScore,
      growthScore: growthScore,
      satisfactionScore: satisfactionScore,
      marketScore: marketScore,
      balanceScore: balanceScore,
      level: level,
    );
  }

  List<CareerInsight> _parseInsights(Map<String, dynamic> data, CareerCoachingInput input) {
    final insightsData = data['insights'] as List<dynamic>? ?? [];
    final insights = <CareerInsight>[];
    
    for (final item in insightsData) {
      if (item is Map<String, dynamic>) {
        insights.add(CareerInsight(
          icon: item['icon'] as String? ?? '💡',
          title: item['title'] as String? ?? '',
          description: item['description'] as String? ?? '',
          impact: item['impact'] as String? ?? 'medium',
          category: item['category'] as String? ?? 'advice',
        ));
      }
    }
    
    // Add default insights if none from API
    if (insights.isEmpty) {
      insights.addAll(_generateKeyInsights(input));
    }
    
    return insights;
  }

  ActionPlan _parseActionPlan(Map<String, dynamic> data, CareerCoachingInput input) {
    final planData = data['action_plan'] as Map<String, dynamic>? ?? {};
    final weeksData = planData['weeks'] as List<dynamic>? ?? [];
    
    final weeks = <WeeklyAction>[];
    for (final weekData in weeksData) {
      if (weekData is Map<String, dynamic>) {
        weeks.add(WeeklyAction(
          weekNumber: (weekData['week_number'] as num?)?.toInt() ?? 1,
          theme: weekData['theme'] as String? ?? '',
          tasks: List<String>.from(weekData['tasks'] ?? []),
          milestone: weekData['milestone'] as String? ?? '',
        ));
      }
    }
    
    // Use generated plan if API doesn't provide one
    if (weeks.isEmpty) {
      return _generate30DayPlan(input);
    }
    
    return ActionPlan(
      weeks: weeks,
      focusArea: planData['focus_area'] as String? ?? '커리어 성장',
      expectedOutcome: planData['expected_outcome'] as String? ?? '목표 달성',
    );
  }

  GrowthRoadmap _parseGrowthRoadmap(Map<String, dynamic> data, CareerCoachingInput input) {
    final roadmapData = data['growth_roadmap'] as Map<String, dynamic>? ?? {};
    
    if (roadmapData.isEmpty) {
      return _generateGrowthRoadmap(input);
    }
    
    return GrowthRoadmap(
      currentStage: roadmapData['current_stage'] as String? ?? '현재 단계',
      nextStage: roadmapData['next_stage'] as String? ?? '다음 단계',
      estimatedMonths: (roadmapData['estimated_months'] as num?)?.toInt() ?? 12,
      requiredSkills: List<String>.from(roadmapData['required_skills'] ?? []),
      keyMilestones: List<String>.from(roadmapData['key_milestones'] ?? []),
      growthStrategy: roadmapData['growth_strategy'] as String? ?? '지속적 성장',
    );
  }

  CareerRecommendations _parseRecommendations(Map<String, dynamic> data, CareerCoachingInput input) {
    final recsData = data['recommendations'] as Map<String, dynamic>? ?? {};
    
    if (recsData.isEmpty) {
      return _generateRecommendations(input);
    }
    
    final skills = <SkillRecommendation>[];
    final skillsData = recsData['skills'] as List<dynamic>? ?? [];
    for (final skillData in skillsData) {
      if (skillData is Map<String, dynamic>) {
        skills.add(SkillRecommendation(
          name: skillData['name'] as String? ?? '',
          priority: skillData['priority'] as String? ?? 'medium',
          reason: skillData['reason'] as String? ?? '',
          learningPath: skillData['learning_path'] as String? ?? '',
        ));
      }
    }
    
    return CareerRecommendations(
      skills: skills.isNotEmpty ? skills : _generateRecommendations(input).skills,
      courses: List<String>.from(recsData['courses'] ?? []),
      books: List<String>.from(recsData['books'] ?? []),
      networkingOpportunities: List<String>.from(recsData['networking'] ?? []),
      sideProjects: List<String>.from(recsData['side_projects'] ?? []),
    );
  }

  MarketTrends _parseMarketTrends(Map<String, dynamic> data, CareerCoachingInput input) {
    final trendsData = data['market_trends'] as Map<String, dynamic>? ?? {};
    
    if (trendsData.isEmpty) {
      return _generateMarketTrends(input);
    }
    
    return MarketTrends(
      industryOutlook: trendsData['industry_outlook'] as String? ?? 'stable',
      emergingOpportunities: List<String>.from(trendsData['emerging_opportunities'] ?? []),
      decliningAreas: List<String>.from(trendsData['declining_areas'] ?? []),
      salaryTrend: trendsData['salary_trend'] as String? ?? '안정적',
      demandLevel: trendsData['demand_level'] as String? ?? 'moderate',
    );
  }

  /// Generate complete mock result
  CareerCoachingResult _generateMockResult(CareerCoachingInput input) {
    // Generate mock results using existing methods
    final healthScore = _generateHealthScore(input);
    final keyInsights = _generateKeyInsights(input);
    final thirtyDayPlan = _generate30DayPlan(input);
    final growthRoadmap = _generateGrowthRoadmap(input);
    final recommendations = _generateRecommendations(input);
    final marketTrends = _generateMarketTrends(input);
    final overallAssessment = _generateOverallAssessment(input, healthScore);
    final motivationalMessage = _generateMotivationalMessage(input, healthScore);

    return CareerCoachingResult(
      healthScore: healthScore,
      overallAssessment: overallAssessment,
      keyInsights: keyInsights,
      thirtyDayPlan: thirtyDayPlan,
      growthRoadmap: growthRoadmap,
      recommendations: recommendations,
      marketTrends: marketTrends,
      motivationalMessage: motivationalMessage,
    );
  }

  /// 커리어 건강도 점수 생성
  CareerHealthScore _generateHealthScore(CareerCoachingInput input) {
    final random = Random();
    
    // 입력에 기반한 점수 계산 (실제로는 AI가 분석)
    int growthScore = 60 + random.nextInt(30);
    int satisfactionScore = 50 + random.nextInt(40);
    int marketScore = 55 + random.nextInt(35);
    int balanceScore = 45 + random.nextInt(45);
    
    // 고민에 따른 점수 조정
    if (input.primaryConcern == 'growth') {
      growthScore = max(30, growthScore - 20);
    } else if (input.primaryConcern == 'balance') {
      balanceScore = max(30, balanceScore - 15);
    } else if (input.primaryConcern == 'compensation') {
      satisfactionScore = max(30, satisfactionScore - 15);
    }
    
    // 목표에 따른 점수 조정
    if (input.shortTermGoal == 'promotion' || input.shortTermGoal == 'skillup') {
      growthScore = min(95, growthScore + 10);
    } else if (input.shortTermGoal == 'stability') {
      balanceScore = min(95, balanceScore + 10);
    }
    
    final overallScore = ((growthScore + satisfactionScore + marketScore + balanceScore) / 4).round();
    
    String level;
    if (overallScore >= 80) {
      level = 'excellent';
    } else if (overallScore >= 65) {
      level = 'good';
    } else if (overallScore >= 50) {
      level = 'moderate';
    } else {
      level = 'needs-attention';
    }
    
    return CareerHealthScore(
      overallScore: overallScore,
      growthScore: growthScore,
      satisfactionScore: satisfactionScore,
      marketScore: marketScore,
      balanceScore: balanceScore,
      level: level,
    );
  }

  /// 핵심 인사이트 생성
  List<CareerInsight> _generateKeyInsights(CareerCoachingInput input) {
    final insights = <CareerInsight>[];
    
    // 고민에 따른 인사이트
    if (input.primaryConcern == 'growth') {
      insights.add(CareerInsight(
        icon: '📈',
        title: '성장 기회 발견',
        description: '현재 포지션에서 정체기를 겪고 있지만, ${input.skillsToImprove.join(", ")} 스킬을 개발하면 새로운 성장 경로가 열릴 것입니다.',
        impact: 'high',
        category: 'opportunity',
      ));
    } else if (input.primaryConcern == 'direction') {
      insights.add(CareerInsight(
        icon: '🧭',
        title: '방향성 재정립 필요',
        description: '커리어 목표를 재정립할 시기입니다. ${input.coreValue}을(를) 중심으로 한 커리어 전략이 필요합니다.',
        impact: 'high',
        category: 'advice',
      ));
    } else if (input.primaryConcern == 'transition') {
      insights.add(CareerInsight(
        icon: '🚀',
        title: '전환 적기 포착',
        description: '현재 시장 상황과 당신의 경력을 고려할 때, 향후 3-6개월이 이직/전직의 최적기입니다.',
        impact: 'high',
        category: 'opportunity',
      ));
    }
    
    // 시장 트렌드 인사이트
    insights.add(CareerInsight(
      icon: '💡',
      title: '떠오르는 스킬 트렌드',
      description: 'AI/자동화 관련 스킬이 모든 산업에서 중요해지고 있습니다. 기본적인 이해라도 갖추면 큰 경쟁력이 됩니다.',
      impact: 'medium',
      category: 'trend',
    ));
    
    // 경고 인사이트
    if (input.currentRole == 'senior' || input.currentRole == 'lead') {
      insights.add(CareerInsight(
        icon: '⚠️',
        title: '리더십 스킬 강화 필요',
        description: '시니어 레벨에서는 기술력뿐만 아니라 리더십과 커뮤니케이션 능력이 중요합니다.',
        impact: 'medium',
        category: 'warning',
      ));
    }
    
    return insights;
  }

  /// 30일 액션 플랜 생성
  ActionPlan _generate30DayPlan(CareerCoachingInput input) {
    final weeks = <WeeklyAction>[];
    
    // 목표에 따른 주간 계획
    if (input.shortTermGoal == 'skillup') {
      weeks.add(WeeklyAction(
        weekNumber: 1,
        theme: '학습 계획 수립',
        tasks: [
          '필요 스킬 우선순위 정하기',
          '온라인 강의 3개 선정하기',
          '일일 학습 시간 확보하기',
        ],
        milestone: '구체적인 학습 로드맵 완성',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 2,
        theme: '기초 다지기',
        tasks: [
          '첫 번째 강의 50% 완료',
          '실습 프로젝트 시작',
          '학습 내용 정리 노트 작성',
        ],
        milestone: '핵심 개념 이해 완료',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 3,
        theme: '실전 적용',
        tasks: [
          '현재 업무에 새 스킬 적용해보기',
          '동료와 학습 내용 공유',
          '피드백 수집 및 개선',
        ],
        milestone: '실무 적용 경험 확보',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 4,
        theme: '성과 정리',
        tasks: [
          '포트폴리오 업데이트',
          '링크드인 프로필 갱신',
          '다음 학습 목표 설정',
        ],
        milestone: '가시적 성과 문서화',
      ));
    } else if (input.shortTermGoal == 'transition') {
      weeks.add(WeeklyAction(
        weekNumber: 1,
        theme: '시장 조사',
        tasks: [
          '목표 회사 리스트 작성',
          '채용 공고 분석',
          '필요 스킬 갭 파악',
        ],
        milestone: '타겟 포지션 명확화',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 2,
        theme: '프로필 강화',
        tasks: [
          '이력서 업데이트',
          '포트폴리오 정리',
          '추천서 요청',
        ],
        milestone: '지원 준비 완료',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 3,
        theme: '네트워킹',
        tasks: [
          '업계 이벤트 참석',
          '링크드인 네트워킹',
          '정보 인터뷰 진행',
        ],
        milestone: '네트워크 확장',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 4,
        theme: '적극 지원',
        tasks: [
          '주 3개 이상 지원',
          '면접 준비 및 연습',
          '피드백 반영 및 개선',
        ],
        milestone: '면접 기회 확보',
      ));
    } else {
      // 기본 플랜
      weeks.add(WeeklyAction(
        weekNumber: 1,
        theme: '현황 분석',
        tasks: [
          '강점과 약점 정리',
          '단기 목표 구체화',
          '필요 리소스 파악',
        ],
        milestone: '자기 이해 심화',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 2,
        theme: '기반 구축',
        tasks: [
          '일일 루틴 개선',
          '생산성 도구 세팅',
          '멘토/코치 찾기',
        ],
        milestone: '성장 기반 마련',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 3,
        theme: '실행 강화',
        tasks: [
          '핵심 프로젝트 추진',
          '성과 측정 지표 설정',
          '중간 점검 및 조정',
        ],
        milestone: '실행력 향상',
      ));
      weeks.add(WeeklyAction(
        weekNumber: 4,
        theme: '성과 창출',
        tasks: [
          '가시적 성과 달성',
          '성과 문서화 및 공유',
          '다음 단계 계획',
        ],
        milestone: '첫 성과 달성',
      ));
    }
    
    String focusArea;
    String expectedOutcome;
    
    if (input.primaryConcern == 'growth') {
      focusArea = '스킬 개발과 전문성 강화';
      expectedOutcome = '새로운 성장 기회 발견 및 경쟁력 향상';
    } else if (input.primaryConcern == 'transition') {
      focusArea = '이직/전직 준비 및 네트워킹';
      expectedOutcome = '새로운 커리어 기회 확보';
    } else if (input.primaryConcern == 'balance') {
      focusArea = '업무 효율화 및 라이프스타일 개선';
      expectedOutcome = '워라벨 개선 및 만족도 향상';
    } else {
      focusArea = '커리어 방향성 재정립';
      expectedOutcome = '명확한 커리어 목표 수립';
    }
    
    return ActionPlan(
      weeks: weeks,
      focusArea: focusArea,
      expectedOutcome: expectedOutcome,
    );
  }

  /// 성장 로드맵 생성
  GrowthRoadmap _generateGrowthRoadmap(CareerCoachingInput input) {
    String currentStage;
    String nextStage;
    int estimatedMonths;
    List<String> requiredSkills;
    List<String> keyMilestones;
    String growthStrategy;
    
    // 현재 역할에 따른 로드맵
    if (input.currentRole == 'junior') {
      currentStage = '주니어 개발자';
      nextStage = '미드레벨 전문가';
      estimatedMonths = 12;
      requiredSkills = ['심화 기술 스킬', '프로젝트 리딩', '문제 해결 능력'];
      keyMilestones = [
        '독립적 프로젝트 수행',
        '주요 기능 설계 및 구현',
        '기술 문서 작성 능력',
      ];
      growthStrategy = '기술 깊이를 늘리고 독립적 문제 해결 능력 강화';
    } else if (input.currentRole == 'mid') {
      currentStage = '미드레벨 전문가';
      nextStage = '시니어 리더';
      estimatedMonths = 18;
      requiredSkills = ['리더십', '아키텍처 설계', '비즈니스 이해'];
      keyMilestones = [
        '팀 리딩 경험',
        '시스템 설계 주도',
        '주니어 멘토링',
      ];
      growthStrategy = '기술 리더십과 비즈니스 임팩트 창출 능력 개발';
    } else if (input.currentRole == 'senior') {
      currentStage = '시니어 전문가';
      nextStage = '테크 리드/매니저';
      estimatedMonths = 24;
      requiredSkills = ['전략적 사고', '조직 관리', '비즈니스 개발'];
      keyMilestones = [
        '다수 팀 협업 주도',
        '기술 전략 수립',
        '조직 문화 개선',
      ];
      growthStrategy = '조직 영향력 확대와 전략적 의사결정 능력 강화';
    } else if (input.currentRole == 'lead') {
      currentStage = '팀 리더';
      nextStage = '시니어 리더십';
      estimatedMonths = 24;
      requiredSkills = ['경영 전략', '변화 관리', '비전 제시'];
      keyMilestones = [
        '부서 목표 달성',
        '인재 육성 성과',
        '혁신 프로젝트 성공',
      ];
      growthStrategy = '조직 전체 관점의 리더십과 비전 실현 능력';
    } else if (input.currentRole == 'freelance') {
      currentStage = '프리랜서';
      nextStage = '전문 컨설턴트/창업가';
      estimatedMonths = 12;
      requiredSkills = ['비즈니스 개발', '브랜딩', '네트워킹'];
      keyMilestones = [
        '고정 클라이언트 확보',
        '수익 안정화',
        '전문 분야 확립',
      ];
      growthStrategy = '전문성 브랜딩과 비즈니스 확장';
    } else {
      currentStage = '준비 단계';
      nextStage = '전문가 진입';
      estimatedMonths = 9;
      requiredSkills = ['기초 역량', '포트폴리오', '네트워킹'];
      keyMilestones = [
        '첫 직무 경험',
        '기초 스킬 습득',
        '네트워크 구축',
      ];
      growthStrategy = '기초 역량 구축과 경험 축적';
    }
    
    // 스킬 개선 목표 반영
    if (input.skillsToImprove.isNotEmpty) {
      requiredSkills.addAll(input.skillsToImprove.take(2));
    }
    
    return GrowthRoadmap(
      currentStage: currentStage,
      nextStage: nextStage,
      estimatedMonths: estimatedMonths,
      requiredSkills: requiredSkills,
      keyMilestones: keyMilestones,
      growthStrategy: growthStrategy,
    );
  }

  /// 추천사항 생성
  CareerRecommendations _generateRecommendations(CareerCoachingInput input) {
    final skills = <SkillRecommendation>[];
    final courses = <String>[];
    final books = <String>[];
    final networkingOpportunities = <String>[];
    final sideProjects = <String>[];
    
    // 스킬 추천
    if (input.skillsToImprove.contains('리더십')) {
      skills.add(SkillRecommendation(
        name: '리더십 & 팀 관리',
        priority: 'high',
        reason: '다음 커리어 단계에 필수적',
        learningPath: 'HBR 리더십 코스 → 실전 적용 → 피드백',
      ));
    }
    
    if (input.skillsToImprove.contains('프로그래밍') || input.skillsToImprove.contains('AI/ML')) {
      skills.add(SkillRecommendation(
        name: 'AI/머신러닝 기초',
        priority: 'critical',
        reason: '모든 산업에서 필수 역량화',
        learningPath: 'Coursera ML 코스 → 프로젝트 → 인증',
      ));
    }
    
    skills.add(SkillRecommendation(
      name: '데이터 분석',
      priority: 'medium',
      reason: '의사결정 개선에 도움',
      learningPath: 'Python/SQL 학습 → 실무 데이터 분석',
    ));
    
    // 강의 추천
    courses.addAll([
      'Google 데이터 분석 전문가 과정',
      'HBR 리더십 에센셜',
      'Coursera 프로젝트 관리 인증',
    ]);
    
    // 도서 추천
    books.addAll([
      '『Good to Great』 - 짐 콜린스',
      '『The Lean Startup』 - 에릭 리스',
      '『Atomic Habits』 - 제임스 클리어',
    ]);
    
    // 네트워킹 기회
    networkingOpportunities.addAll([
      '업계 밋업 및 컨퍼런스 참석',
      '링크드인 업계 그룹 활동',
      '멘토-멘티 프로그램 참여',
    ]);
    
    // 사이드 프로젝트
    if (input.currentRole == 'junior' || input.currentRole == 'mid') {
      sideProjects.addAll([
        '오픈소스 프로젝트 기여',
        '개인 포트폴리오 웹사이트',
        '업계 관련 블로그 운영',
      ]);
    } else {
      sideProjects.addAll([
        '업계 리서치 프로젝트',
        '멘토링 프로그램 운영',
        '전문 분야 온라인 강의 제작',
      ]);
    }
    
    return CareerRecommendations(
      skills: skills,
      courses: courses,
      books: books,
      networkingOpportunities: networkingOpportunities,
      sideProjects: sideProjects,
    );
  }

  /// 시장 트렌드 생성
  MarketTrends _generateMarketTrends(CareerCoachingInput input) {
    
    String industryOutlook;
    List<String> emergingOpportunities;
    List<String> decliningAreas;
    String salaryTrend;
    String demandLevel;
    
    // 산업별 트렌드 (실제로는 실시간 데이터 기반)
    if (input.industry?.contains('IT') ?? false || input.currentRole == 'junior' || input.currentRole == 'mid') {
      industryOutlook = 'positive';
      emergingOpportunities = [
        'AI/ML 엔지니어',
        '클라우드 아키텍트',
        '데이터 사이언티스트',
        'DevOps 엔지니어',
      ];
      decliningAreas = [
        '단순 코딩 업무',
        '레거시 시스템 유지보수',
      ];
      salaryTrend = '연 5-10% 상승 추세';
      demandLevel = 'high';
    } else {
      industryOutlook = 'stable';
      emergingOpportunities = [
        '디지털 전환 전문가',
        '프로젝트 매니저',
        '비즈니스 분석가',
      ];
      decliningAreas = [
        '단순 사무 업무',
        '중간 관리직',
      ];
      salaryTrend = '연 3-5% 상승';
      demandLevel = 'moderate';
    }
    
    return MarketTrends(
      industryOutlook: industryOutlook,
      emergingOpportunities: emergingOpportunities,
      decliningAreas: decliningAreas,
      salaryTrend: salaryTrend,
      demandLevel: demandLevel,
    );
  }

  /// 종합 평가 생성
  String _generateOverallAssessment(CareerCoachingInput input, CareerHealthScore score) {
    if (score.overallScore >= 80) {
      return '당신의 커리어는 매우 건강한 상태입니다. 현재의 성장 모멘텀을 유지하면서 ${input.shortTermGoal == "promotion" ? "승진" : input.shortTermGoal == "skillup" ? "스킬 향상" : "목표 달성"}을 위한 구체적인 실행에 집중하세요.';
    } else if (score.overallScore >= 65) {
      return '커리어가 안정적인 궤도에 있습니다. ${input.primaryConcern == "growth" ? "성장 정체를 극복하기 위한" : input.primaryConcern == "direction" ? "명확한 방향 설정을 위한" : "현재 고민 해결을 위한"} 적극적인 행동이 필요한 시점입니다.';
    } else if (score.overallScore >= 50) {
      return '커리어 전환점에 있습니다. ${input.coreValue == "growth" ? "성장" : input.coreValue == "stability" ? "안정" : input.coreValue}을(를) 중심으로 한 전략적 접근이 필요합니다. 작은 변화부터 시작해보세요.';
    } else {
      return '커리어 재정비가 시급합니다. 현재 상황을 객관적으로 평가하고, 근본적인 변화를 위한 과감한 결단이 필요할 수 있습니다. 전문가의 도움을 받는 것도 고려해보세요.';
    }
  }

  /// 동기부여 메시지 생성
  String _generateMotivationalMessage(CareerCoachingInput input, CareerHealthScore score) {
    final messages = [
      '모든 위대한 커리어는 작은 한 걸음부터 시작됩니다. 오늘의 노력이 내일의 성공을 만듭니다.',
      '변화는 불편하지만 성장의 필수 요소입니다. 지금이 바로 도약할 때입니다.',
      '당신만의 독특한 강점이 있습니다. 그것을 발견하고 키워나가세요.',
      '실패는 성공으로 가는 디딤돌입니다. 두려워하지 말고 도전하세요.',
      '커리어는 마라톤입니다. 꾸준함이 결국 승리로 이끕니다.'
    ];
    
    if (score.overallScore >= 70) {
      return '훌륭한 상태입니다! ${messages[Random().nextInt(messages.length)]}';
    } else {
      return '지금이 변화의 기회입니다. ${messages[Random().nextInt(messages.length)]}';
    }
  }
}

// Provider
final careerCoachingServiceProvider = Provider<CareerCoachingService>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return CareerCoachingService(apiService);
});