import '../../data/models/user_profile.dart';

/// 사용자 프로필 기반 맞춤형 운세 컨텐츠 생성 서비스
class PersonalizedFortuneService {
  
  /// 사용자 나이 계산
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 연령대 그룹 분류
  static String getAgeGroup(int age) {
    if (age < 25) return '20s_early';
    if (age < 30) return '20s_late';
    if (age < 35) return '30s_early';
    if (age < 40) return '30s_late';
    if (age < 45) return '40s_early';
    if (age < 50) return '40s_late';
    if (age < 55) return '50s_early';
    if (age < 60) return '50s_late';
    return '60plus';
  }

  /// 맞춤형 "할 일" 생성
  static List<String> getPersonalizedTodos(UserProfile? profile) {
    if (profile == null) return _getDefaultTodos();
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final todoMap = _getTodoDatabase();
    final key = '${gender}_$ageGroup';
    
    return todoMap[key] ?? _getDefaultTodos();
  }

  /// 맞춤형 "피할 일" 생성
  static List<String> getPersonalizedAvoids(UserProfile? profile) {
    if (profile == null) return _getDefaultAvoids();
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final avoidMap = _getAvoidDatabase();
    final key = '${gender}_$ageGroup';
    
    return avoidMap[key] ?? _getDefaultAvoids();
  }

  /// 맞춤형 조언 생성
  static String getPersonalizedAdvice(UserProfile? profile) {
    if (profile == null) return '차분한 마음으로 계획을 세우면 좋은 결과를 얻을 수 있어요';
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final adviceMap = _getAdviceDatabase();
    final key = '${gender}_$ageGroup';
    
    return adviceMap[key] ?? '차분한 마음으로 계획을 세우면 좋은 결과를 얻을 수 있어요';
  }

  /// 맞춤형 시간대별 활동 생성
  static List<Map<String, dynamic>> getPersonalizedHourlyActivities(UserProfile? profile) {
    if (profile == null) return _getDefaultActivities();
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final activitiesMap = _getActivitiesDatabase();
    final key = '${gender}_$ageGroup';
    
    return activitiesMap[key] ?? _getDefaultActivities();
  }

  /// 맞춤형 인간관계 조언 생성
  static Map<String, String> getPersonalizedRelationships(UserProfile? profile) {
    if (profile == null) return _getDefaultRelationships();
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final relationshipMap = _getRelationshipDatabase();
    final key = '${gender}_$ageGroup';
    
    return relationshipMap[key] ?? _getDefaultRelationships();
  }

  /// 맞춤형 금전운 조언 생성
  static String getPersonalizedMoneyAdvice(UserProfile? profile) {
    if (profile == null) return '신중한 투자 고려\n큰 지출은 피하기\n계획적인 소비';
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final moneyAdviceMap = _getMoneyAdviceDatabase();
    final key = '${gender}_$ageGroup';
    
    return moneyAdviceMap[key] ?? '신중한 투자 고려\n큰 지출은 피하기\n계획적인 소비';
  }

  /// 맞춤형 건강 조언 생성
  static String getPersonalizedHealthAdvice(UserProfile? profile) {
    if (profile == null) return '충분한 수분 섭취\n목과 어깨 스트레칭\n규칙적인 식사';
    
    final age = calculateAge(profile.birthDate!);
    final ageGroup = getAgeGroup(age);
    final gender = profile.gender ?? 'male';
    
    final healthAdviceMap = _getHealthAdviceDatabase();
    final key = '${gender}_$ageGroup';
    
    return healthAdviceMap[key] ?? '충분한 수분 섭취\n목과 어깨 스트레칭\n규칙적인 식사';
  }

  // ==================== 데이터베이스 ====================

  static Map<String, List<String>> _getTodoDatabase() {
    return {
      // 20대 초반 남성
      'male_20s_early': [
        '새로운 기술 스킬 습득하기',
        '선배와의 네트워킹 시간',
        '포트폴리오 업데이트하기',
      ],
      // 20대 후반 남성
      'male_20s_late': [
        '이직 시장 조사하기',
        '자격증 취득 계획 세우기',
        '독립 준비하기',
      ],
      // 30대 초반 남성
      'male_30s_early': [
        '중요한 프로젝트 마무리하기',
        '상사와 커리어 상담하기',
        '투자 포트폴리오 점검하기',
      ],
      // 30대 후반 남성
      'male_30s_late': [
        '리더십 스킬 개발하기',
        '팀원들과의 소통 강화',
        '장기 투자 계획 수립',
      ],
      // 40대 초반 남성
      'male_40s_early': [
        '부하직원 멘토링하기',
        '새로운 비즈니스 기회 탐색',
        '가족과의 시간 늘리기',
      ],
      // 40대 후반 남성
      'male_40s_late': [
        '후진 양성에 집중하기',
        '은퇴 후 준비 시작',
        '건강 관리 우선하기',
      ],
      
      // 20대 초반 여성
      'female_20s_early': [
        '새로운 분야 도전해보기',
        '멘토 찾아 조언 구하기',
        '자기계발 투자하기',
      ],
      // 20대 후반 여성
      'female_20s_late': [
        '커리어 방향 설정하기',
        '전문성 쌓기',
        '인적 네트워크 구축',
      ],
      // 30대 초반 여성
      'female_30s_early': [
        '워라밸 개선 방안 찾기',
        '전문성 업그레이드',
        '장기 비전 수립하기',
      ],
      // 30대 후반 여성
      'female_30s_late': [
        '리더십 포지션 준비',
        '경력 관리 전략 세우기',
        '자기만의 브랜드 구축',
      ],
      // 40대 초반 여성
      'female_40s_early': [
        '새로운 도전 기회 찾기',
        '건강한 라이프스타일 만들기',
        '지식과 경험 공유하기',
      ],
      // 40대 후반 여성
      'female_40s_late': [
        '제2의 인생 설계하기',
        '취미 생활 시작하기',
        '건강 우선 생활패턴',
      ],
    };
  }

  static Map<String, List<String>> _getAvoidDatabase() {
    return {
      // 30대 초반 남성
      'male_30s_early': [
        '충동적인 이직 결정',
        '큰 금액 무리한 투자',
        '술자리에서 속마음 털어놓기',
      ],
      // 30대 후반 남성
      'male_30s_late': [
        '성급한 사업 결정',
        '가족과의 약속 미루기',
        '건강 관리 소홀히 하기',
      ],
      // 20대 후반 여성
      'female_20s_late': [
        '타인과 비교하기',
        '완벽주의에 매몰되기',
        '중요한 결정 미루기',
      ],
      // 30대 초반 여성
      'female_30s_early': [
        '모든 것을 혼자 해결하려 하기',
        '자기 시간 포기하기',
        '감정적인 결정하기',
      ],
      // 기본값
      '_default': [
        '큰 지출 피하기',
        '논쟁하지 않기',
        '급한 결정 금지',
      ],
    };
  }

  static Map<String, String> _getAdviceDatabase() {
    return {
      'male_30s_early': '현재의 노력이 5년 후의 성공을 만들어갑니다. 조급해하지 마세요',
      'male_30s_late': '경험을 바탕으로 한 판단력이 빛을 발할 때입니다',
      'female_30s_early': '당신만의 속도로 나아가는 것이 가장 현명한 선택입니다',
      'female_30s_late': '지혜로운 선택이 새로운 기회의 문을 열어줄 것입니다',
      'male_20s_late': '실패를 두려워하지 말고 도전하세요. 지금이 그 때입니다',
      'female_20s_late': '자신을 믿고 한 걸음씩 나아가면 길이 보일 것입니다',
      '_default': '차분한 마음으로 계획을 세우면 좋은 결과를 얻을 수 있어요',
    };
  }

  static Map<String, List<Map<String, dynamic>>> _getActivitiesDatabase() {
    return {
      'male_30s_early': [
        {'time': '자시 (23-01)', 'score': 75, 'activity': '휴식과 정리'},
        {'time': '축시 (01-03)', 'score': 60, 'activity': '숙면'},
        {'time': '인시 (03-05)', 'score': 65, 'activity': '깊은 잠'},
        {'time': '묘시 (05-07)', 'score': 85, 'activity': '운동이나 조깅'},
        {'time': '진시 (07-09)', 'score': 90, 'activity': '업무 계획 수립'},
        {'time': '사시 (09-11)', 'score': 95, 'activity': '중요한 회의나 결정'},
        {'time': '오시 (11-13)', 'score': 80, 'activity': '동료와 점심'},
        {'time': '미시 (13-15)', 'score': 88, 'activity': '창의적 업무'},
        {'time': '신시 (15-17)', 'score': 82, 'activity': '팀 미팅'},
        {'time': '유시 (17-19)', 'score': 75, 'activity': '하루 마무리'},
        {'time': '술시 (19-21)', 'score': 92, 'activity': '가족 시간'},
        {'time': '해시 (21-23)', 'score': 85, 'activity': '개인 시간'},
      ],
      'female_30s_early': [
        {'time': '자시 (23-01)', 'score': 70, 'activity': '하루 정리'},
        {'time': '축시 (01-03)', 'score': 65, 'activity': '숙면'},
        {'time': '인시 (03-05)', 'score': 70, 'activity': '깊은 휴식'},
        {'time': '묘시 (05-07)', 'score': 80, 'activity': '요가나 명상'},
        {'time': '진시 (07-09)', 'score': 85, 'activity': '업무 시작'},
        {'time': '사시 (09-11)', 'score': 90, 'activity': '집중 업무'},
        {'time': '오시 (11-13)', 'score': 85, 'activity': '네트워킹'},
        {'time': '미시 (13-15)', 'score': 92, 'activity': '창작 활동'},
        {'time': '신시 (15-17)', 'score': 88, 'activity': '협업 시간'},
        {'time': '유시 (17-19)', 'score': 80, 'activity': '업무 마무리'},
        {'time': '술시 (19-21)', 'score': 95, 'activity': '자기계발'},
        {'time': '해시 (21-23)', 'score': 90, 'activity': '힐링 타임'},
      ],
    };
  }

  static Map<String, Map<String, String>> _getRelationshipDatabase() {
    return {
      'male_30s_early': {
        'lucky': '업계 5-10년 선배',
        'careful': '경쟁심 강한 동기',
        'love': '진솔한 대화가 관계를 발전시킴',
      },
      'female_30s_early': {
        'lucky': '같은 분야 멘토',
        'careful': '과도한 조언하는 사람',
        'love': '서로의 꿈을 응원하는 관계',
      },
      'male_20s_late': {
        'lucky': '직장 상사나 멘토',
        'careful': '부정적 에너지 전달하는 친구',
        'love': '새로운 만남에 열린 마음',
      },
      'female_20s_late': {
        'lucky': '같은 관심사를 가진 선배',
        'careful': '비교하고 질투하는 사람',
        'love': '자연스러운 만남이 좋은 결과',
      },
    };
  }

  static Map<String, String> _getMoneyAdviceDatabase() {
    return {
      'male_20s_late': '긴급자금 우선 확보\n소액 투자 경험 쌓기\n신용 관리 철저히',
      'male_30s_early': '부동산 vs 주식 균형\n비상금 6개월치 확보\n장기 투자 시작',
      'male_30s_late': '자녀교육비 준비\n연금저축 늘리기\n안정적 투자 중심',
      'female_20s_late': '자기계발 투자 우선\n적금 통한 목돈 마련\n투자 공부하기',
      'female_30s_early': '경력단절 대비 준비\n안정형 투자 선택\n부업 수입 고려',
      'female_30s_late': '노후 대비 본격화\n건강 관련 비용 준비\n자산 포트폴리오 다각화',
    };
  }

  static Map<String, String> _getHealthAdviceDatabase() {
    return {
      'male_20s_late': '규칙적인 운동 습관\n과음 피하기\n수면 패턴 정착',
      'male_30s_early': '스트레스 관리 중요\n정기 건강검진\n근력 운동 시작',
      'male_30s_late': '성인병 예방 관리\n금연·금주 실천\n유산소+근력 병행',
      'female_20s_late': '생리 주기 관리\n다이어트보다 건강\n비타민 D 보충',
      'female_30s_early': '호르몬 밸런스 관리\n골밀도 신경쓰기\n요가·필라테스 추천',
      'female_30s_late': '갱년기 대비 준비\n칼슘·단백질 충분히\n관절 건강 관리',
    };
  }

  // 기본값들
  static List<String> _getDefaultTodos() {
    return ['새로운 계획 세우기', '중요한 결정하기', '인맥 관리하기'];
  }

  static List<String> _getDefaultAvoids() {
    return ['큰 지출 피하기', '논쟁하지 않기', '급한 결정 금지'];
  }

  static List<Map<String, dynamic>> _getDefaultActivities() {
    return [
      {'time': '자시 (23-01)', 'score': 75, 'activity': '휴식'},
      {'time': '축시 (01-03)', 'score': 60, 'activity': '수면'},
      {'time': '인시 (03-05)', 'score': 65, 'activity': '명상'},
      {'time': '묘시 (05-07)', 'score': 85, 'activity': '운동'},
      {'time': '진시 (07-09)', 'score': 90, 'activity': '업무'},
      {'time': '사시 (09-11)', 'score': 95, 'activity': '결정'},
      {'time': '오시 (11-13)', 'score': 80, 'activity': '식사'},
      {'time': '미시 (13-15)', 'score': 88, 'activity': '창작'},
      {'time': '신시 (15-17)', 'score': 82, 'activity': '미팅'},
      {'time': '유시 (17-19)', 'score': 75, 'activity': '이동'},
      {'time': '술시 (19-21)', 'score': 92, 'activity': '사교'},
      {'time': '해시 (21-23)', 'score': 85, 'activity': '정리'},
    ];
  }

  static Map<String, String> _getDefaultRelationships() {
    return {
      'lucky': '나이가 많은 동료나 선배',
      'careful': '감정적인 성향이 강한 사람',
      'love': '진솔한 대화가 관계를 발전시킴',
    };
  }
}