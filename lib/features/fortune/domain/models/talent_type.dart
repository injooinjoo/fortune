// 재능 타입 정의
enum TalentType {
  creativityInnovator,    // 창의적 혁신가
  strategicPlanner,       // 전략적 기획자
  analyticalThinker,      // 분석적 사고자
  communicationMaster,    // 소통의 달인
  executionPowerhouse,    // 실행력의 화신
  charismaticLeader,      // 카리스마 리더
  detailMaster,          // 디테일 마스터
  versatileAllrounder,   // 다재다능 올라운더
}

/// 재능 타입 정보 클래스
class TalentTypeInfo {
  final TalentType type;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<String> strengths;
  final List<String> careers;
  final List<String> activities;
  final List<String> actionPlans;

  const TalentTypeInfo({
    required this.type,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.strengths,
    required this.careers,
    required this.activities,
    required this.actionPlans,
  });
}

/// 재능 타입별 정보 제공 클래스
class TalentTypeProvider {
  static const Map<TalentType, TalentTypeInfo> _talentTypes = {
    TalentType.creativityInnovator: TalentTypeInfo(
      type: TalentType.creativityInnovator,
      emoji: '🎨',
      title: '창의적 혁신가',
      subtitle: '독창적 아이디어로 세상을 바꾸는',
      description: '새로운 관점으로 문제를 해결하고 혁신적인 아이디어를 만들어내는 재능이 뛰어납니다. 예술적 감각과 창의적 사고로 기존의 틀을 깨는 것을 좋아합니다.',
      strengths: [
        '독창적 아이디어 발굴',
        '문제 해결을 위한 새로운 관점',
        '예술적 감각과 미적 센스'
      ],
      careers: [
        'UX/UI 디자이너',
        '광고 크리에이티브 디렉터',
        '콘텐츠 기획자',
        '예술가/작가',
        '스타트업 창업자'
      ],
      activities: [
        '디자인 스터디 참여',
        '창작 워크숍 수강',
        '아이디어 해커톤 참여'
      ],
      actionPlans: [
        '매일 30분 스케치하기',
        '새로운 카페에서 아이디어 노트 쓰기',
        '온라인 디자인 강의 하나 시작하기'
      ],
    ),
    
    TalentType.strategicPlanner: TalentTypeInfo(
      type: TalentType.strategicPlanner,
      emoji: '🎯',
      title: '전략적 기획자',
      subtitle: '체계적 계획으로 목표를 달성하는',
      description: '복잡한 문제를 단계별로 분해하고 체계적인 계획을 세우는 능력이 탁월합니다. 장기적 관점에서 전략을 수립하고 실행하는 것을 잘합니다.',
      strengths: [
        '체계적 계획 수립',
        '목표 지향적 사고',
        '효율적 프로세스 설계'
      ],
      careers: [
        '전략 기획자',
        '프로젝트 매니저',
        '경영 컨설턴트',
        '사업 개발자',
        '정책 연구원'
      ],
      activities: [
        '전략 보드게임',
        '사업 계획서 작성 연습',
        '케이스 스터디 분석'
      ],
      actionPlans: [
        '개인 목표를 SMART하게 설정하기',
        '주간 계획표 만들어 실행하기',
        '비즈니스 서적 한 달에 한 권 읽기'
      ],
    ),
    
    TalentType.analyticalThinker: TalentTypeInfo(
      type: TalentType.analyticalThinker,
      emoji: '💡',
      title: '분석적 사고자',
      subtitle: '데이터로 최적의 답을 찾는',
      description: '복잡한 정보를 논리적으로 분석하고 패턴을 찾아내는 능력이 뛰어납니다. 데이터 기반의 의사결정을 통해 문제를 해결하는 것을 선호합니다.',
      strengths: [
        '논리적 사고와 분석',
        '데이터 기반 의사결정',
        '패턴 인식과 예측'
      ],
      careers: [
        '데이터 사이언티스트',
        '비즈니스 애널리스트',
        '연구원',
        '금융 애널리스트',
        'AI 엔지니어'
      ],
      activities: [
        '데이터 분석 프로젝트',
        '통계학 스터디',
        '논리 퍼즐 게임'
      ],
      actionPlans: [
        'Excel 고급 기능 마스터하기',
        '무료 데이터셋으로 분석 연습하기',
        'SQL 기초 강의 수강하기'
      ],
    ),
    
    TalentType.communicationMaster: TalentTypeInfo(
      type: TalentType.communicationMaster,
      emoji: '🤝',
      title: '소통의 달인',
      subtitle: '사람들과 깊이 연결되는',
      description: '다른 사람의 마음을 이해하고 효과적으로 소통하는 능력이 탁월합니다. 팀워크를 만들고 갈등을 해결하는 데 뛰어난 재능을 보입니다.',
      strengths: [
        '공감 능력과 경청',
        '설득과 협상',
        '팀워크 구축'
      ],
      careers: [
        'HR 전문가',
        '마케팅 매니저',
        '영업 전문가',
        '상담사/코치',
        '교육자'
      ],
      activities: [
        '토론 클럽 참여',
        '발표 스킬 연습',
        '네트워킹 이벤트 참석'
      ],
      actionPlans: [
        '주 1회 새로운 사람과 대화하기',
        '토스트마스터즈 클럽 가입하기',
        '능동적 경청 연습하기'
      ],
    ),
    
    TalentType.executionPowerhouse: TalentTypeInfo(
      type: TalentType.executionPowerhouse,
      emoji: '🚀',
      title: '실행력의 화신',
      subtitle: '빠른 실행으로 결과를 만드는',
      description: '아이디어를 빠르게 실행에 옮기고 결과를 만들어내는 능력이 뛰어납니다. 추진력과 속도감으로 프로젝트를 성공적으로 완료합니다.',
      strengths: [
        '빠른 실행력',
        '결과 지향적 마인드',
        '위기 상황 대처'
      ],
      careers: [
        '오퍼레이션 매니저',
        '스타트업 COO',
        '세일즈 매니저',
        '이벤트 기획자',
        '프리랜서'
      ],
      activities: [
        '사이드 프로젝트 진행',
        '단기 챌린지 참여',
        '스피드 네트워킹'
      ],
      actionPlans: [
        '30일 챌린지 하나 시작하기',
        '아이디어를 24시간 내에 실행해보기',
        '매주 작은 성과 하나씩 만들기'
      ],
    ),
    
    TalentType.charismaticLeader: TalentTypeInfo(
      type: TalentType.charismaticLeader,
      emoji: '🌟',
      title: '카리스마 리더',
      subtitle: '팀을 이끌고 영감을 주는',
      description: '다른 사람들에게 영감을 주고 팀을 하나로 만드는 리더십이 뛰어납니다. 비전을 제시하고 사람들을 동기부여하는 능력이 탁월합니다.',
      strengths: [
        '타고난 리더십',
        '비전 제시와 동기부여',
        '카리스마와 영향력'
      ],
      careers: [
        'CEO/임원',
        '팀장/관리자',
        '정치인',
        '강연자',
        '사회적 기업가'
      ],
      activities: [
        '리더십 교육 참여',
        '멘토링 활동',
        '커뮤니티 운영'
      ],
      actionPlans: [
        '소규모 팀 프로젝트 리딩해보기',
        '리더십 도서 월 1권 읽기',
        '후배 멘토링 시작하기'
      ],
    ),
    
    TalentType.detailMaster: TalentTypeInfo(
      type: TalentType.detailMaster,
      emoji: '🔍',
      title: '디테일 마스터',
      subtitle: '완벽한 품질을 추구하는',
      description: '세심한 관찰력과 꼼꼼함으로 완벽한 결과물을 만들어냅니다. 품질 관리와 정확성을 중시하며 실수를 최소화하는 능력이 뛰어납니다.',
      strengths: [
        '세심한 관찰력',
        '품질 관리 능력',
        '정확성과 신뢰성'
      ],
      careers: [
        'QA 전문가',
        '회계사',
        '법무 전문가',
        '편집자',
        '품질 관리자'
      ],
      activities: [
        '세밀화 그리기',
        '퍼즐 맞추기',
        '프로세스 개선 프로젝트'
      ],
      actionPlans: [
        '체크리스트 만들어 활용하기',
        '오류 찾기 연습하기',
        '정리정돈 습관 만들기'
      ],
    ),
    
    TalentType.versatileAllrounder: TalentTypeInfo(
      type: TalentType.versatileAllrounder,
      emoji: '🌈',
      title: '다재다능 올라운더',
      subtitle: '균형잡힌 만능 재능의 소유자',
      description: '여러 분야에서 골고루 뛰어난 능력을 보이는 만능형 인재입니다. 상황에 따라 필요한 역할을 유연하게 소화하며 적응력이 뛰어납니다.',
      strengths: [
        '다방면의 재능',
        '높은 적응력',
        '균형잡힌 사고'
      ],
      careers: [
        '프로덕트 매니저',
        '컨설턴트',
        '저널리스트',
        '교육자',
        '1인 기업가'
      ],
      activities: [
        '다양한 분야 체험',
        '크로스 트레이닝',
        '융합 프로젝트 참여'
      ],
      actionPlans: [
        '새로운 취미 하나씩 도전하기',
        '다른 분야 사람들과 협업하기',
        'T자형 인재 되기 위한 전문성 하나 키우기'
      ],
    ),
  };

  /// 재능 타입 정보 가져오기
  static TalentTypeInfo getInfo(TalentType type) {
    return _talentTypes[type]!;
  }

  /// 모든 재능 타입 목록 가져오기
  static List<TalentTypeInfo> getAllTypes() {
    return _talentTypes.values.toList();
  }

  /// 점수 기반으로 최적의 재능 타입 결정
  static TalentType determineTalentType(Map<String, int> scores) {
    // 가장 높은 점수를 가진 능력들 찾기
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topSkill = sortedEntries.first.key;
    final secondSkill = sortedEntries.length > 1 ? sortedEntries[1].key : '';
    
    // 최고 점수와 두 번째 점수의 차이
    final scoreDiff = sortedEntries.length > 1 
        ? sortedEntries.first.value - sortedEntries[1].value 
        : 100;
    
    // 점수 조합에 따른 타입 결정
    if (topSkill == '창의력') {
      if (secondSkill == '직감력' || scoreDiff > 15) {
        return TalentType.creativityInnovator;
      } else if (secondSkill == '소통력') {
        return TalentType.versatileAllrounder;
      }
      return TalentType.creativityInnovator;
    } else if (topSkill == '분석력') {
      if (secondSkill == '집중력' || scoreDiff > 15) {
        return TalentType.analyticalThinker;
      } else if (secondSkill == '리더십') {
        return TalentType.strategicPlanner;
      }
      return TalentType.analyticalThinker;
    } else if (topSkill == '소통력') {
      if (secondSkill == '리더십') {
        return TalentType.charismaticLeader;
      } else if (scoreDiff > 15) {
        return TalentType.communicationMaster;
      }
      return TalentType.communicationMaster;
    } else if (topSkill == '리더십') {
      if (secondSkill == '소통력') {
        return TalentType.charismaticLeader;
      } else if (secondSkill == '분석력') {
        return TalentType.strategicPlanner;
      }
      return TalentType.charismaticLeader;
    } else if (topSkill == '집중력') {
      if (secondSkill == '분석력') {
        return TalentType.detailMaster;
      } else if (secondSkill == '리더십') {
        return TalentType.executionPowerhouse;
      }
      return TalentType.detailMaster;
    } else if (topSkill == '직감력') {
      if (secondSkill == '창의력') {
        return TalentType.creativityInnovator;
      } else if (secondSkill == '소통력') {
        return TalentType.communicationMaster;
      }
      return TalentType.creativityInnovator;
    }
    
    // 점수 차이가 적으면 올라운더
    if (scoreDiff < 10) {
      return TalentType.versatileAllrounder;
    }
    
    // 기본값
    return TalentType.versatileAllrounder;
  }
}