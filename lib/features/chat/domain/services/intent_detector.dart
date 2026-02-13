import '../models/fortune_survey_config.dart';

/// 텍스트에서 운세 의도를 감지하는 서비스
class IntentDetector {
  /// 키워드 매핑 (30개 운세 타입)
  static const Map<FortuneSurveyType, List<String>> _keywords = {
    // 기존 6개
    FortuneSurveyType.career: [
      '직업',
      '취업',
      '이직',
      '승진',
      '커리어',
      '회사',
      '일',
      '직장',
      '면접',
      '연봉',
      '월급',
      '업무',
      '프리랜서',
      '창업',
      '사업',
      '퇴사',
      '구직',
      '채용',
      '합격',
      '불합격',
    ],
    FortuneSurveyType.love: [
      '연애',
      '사랑',
      '남자친구',
      '여자친구',
      '남친',
      '여친',
      '짝사랑',
      '고백',
      '데이트',
      '애인',
      '커플',
      '솔로',
      '만남',
    ],
    FortuneSurveyType.talent: [
      '적성',
      '재능',
      '진로',
      '전공',
      '능력',
      '특기',
      '소질',
      '잠재력',
      '강점',
      '약점',
      '성향',
    ],
    FortuneSurveyType.daily: [
      '오늘',
      '내일',
      '이번주',
      '하루',
      '일진',
    ],
    FortuneSurveyType.tarot: [
      '타로',
      '카드',
      '점',
      '운명',
      '점술',
    ],
    FortuneSurveyType.mbti: [
      'MBTI',
      '성격유형',
      'INTJ',
      'INTP',
      'ENTJ',
      'ENTP',
      'INFJ',
      'INFP',
      'ENFJ',
      'ENFP',
      'ISTJ',
      'ISFJ',
      'ESTJ',
      'ESFJ',
      'ISTP',
      'ISFP',
      'ESTP',
      'ESFP',
    ],
    // 시간 기반 (1개)
    FortuneSurveyType.newYear: [
      '새해',
      '신년',
      '설날',
      '연초',
      '정초',
    ],
    // 전통 분석 (2개)
    FortuneSurveyType.traditional: [
      '사주',
      '팔자',
      '명리',
      '음양',
      '오행',
      '천간',
      '지지',
      '일간',
      '용신',
      '기운',
      '운세',
    ],
    FortuneSurveyType.faceReading: [
      '관상',
      '얼굴',
      '이목구비',
      '상',
      '인상',
      'AI관상',
    ],
    // 성격/개성 (2개)
    FortuneSurveyType.personalityDna: [
      '성격',
      'DNA',
      '기질',
      '천성',
      '본성',
      '성격분석',
    ],
    FortuneSurveyType.biorhythm: [
      '바이오리듬',
      '리듬',
      '신체리듬',
      '컨디션',
      '피지컬',
    ],
    // 연애/관계 (4개)
    FortuneSurveyType.compatibility: [
      '궁합',
      '상성',
      '어울',
      '맞',
      '찰떡',
    ],
    FortuneSurveyType.avoidPeople: [
      '경계',
      '조심',
      '피해',
      '주의',
      '위험인물',
    ],
    FortuneSurveyType.exLover: [
      '재회',
      '헤어',
      '이별',
      '전남친',
      '전여친',
      '돌아올',
    ],
    FortuneSurveyType.blindDate: [
      '소개팅',
      '미팅',
      '만남',
      '앱만남',
      '처음만남',
    ],
    // 재물 (1개)
    FortuneSurveyType.money: [
      '재물',
      '돈',
      '금전',
      '부자',
      '재산',
      '자산',
      '투자',
      '수입',
      '소득',
      '월급',
      '용돈',
    ],
    // 라이프스타일 (4개)
    FortuneSurveyType.luckyItems: [
      '행운',
      '럭키',
      '아이템',
      '색깔',
      '숫자',
      '방향',
      '길운',
    ],
    FortuneSurveyType.lotto: [
      '로또',
      '복권',
      '당첨',
      '번호',
      '추첨',
      '행운번호',
    ],
    FortuneSurveyType.wish: [
      '소원',
      '빌',
      '기원',
      '바램',
      '희망',
      '간절',
    ],
    FortuneSurveyType.fortuneCookie: [
      '메시지',
      '조언',
      '한마디',
      '포춘쿠키',
    ],
    // 건강/스포츠 (3개)
    FortuneSurveyType.health: [
      '건강',
      '몸',
      '컨디션',
      '피로',
      '아프',
      '병원',
    ],
    FortuneSurveyType.exercise: [
      '운동',
      '헬스',
      '다이어트',
      '살빼',
      '근력',
      '체력',
      '피트니스',
    ],
    FortuneSurveyType.sportsGame: [
      // 일반
      '스포츠', '경기', '승부', '예측', '인사이트',
      // 한국 종목
      '축구', '야구', '농구', '배구', 'e스포츠', '롤챔스',
      // 한국 리그
      'KBO', 'K리그', 'KBL', 'V리그', 'LCK',
      // 한국 팀
      '두산', 'LG', 'KIA', '삼성', 'NC', 'SSG', 'KT', '한화', '롯데', '키움',
      '전북', '울산', '포항', '서울', '제주', '인천', '광주', '강원', '대전',
      'T1', 'GenG', '한화생명', 'DRX', '농심',
      // 미국 리그
      'MLB', 'NBA', 'NFL', '메이저리그', '슈퍼볼',
      // MLB 팀
      '양키스', '다저스', '레드삭스', '컵스', '애스트로스', '에인절스', '파드리스',
      // NBA 팀
      '레이커스', '워리어스', '셀틱스', '불스', '네츠', '닉스', '히트',
      // NFL 팀
      '치프스', '카우보이스', '패트리어츠', '이글스',
      // 유럽 축구
      'EPL', '프리미어리그', '라리가', '분데스리가', '세리에', '챔피언스리그',
      // EPL 팀
      '토트넘', '손흥민', '맨유', '맨시티', '첼시', '아스날', '리버풀',
      // 라리가
      '레알', '바르셀로나', '바르사', '아틀레티코',
      // 분데스리가
      '바이에른', '뮌헨', '도르트문트',
      // 세리에 A
      '유벤투스', '밀란', '인테르', '나폴리',
      // 기타
      'UFC', '미식축구',
    ],
    // 인터랙티브 (3개)
    FortuneSurveyType.dream: [
      '꿈',
      '해몽',
      '악몽',
      '길몽',
      '흉몽',
      '꿨',
    ],
    FortuneSurveyType.celebrity: [
      '유명인',
      '연예인',
      '아이돌',
      '배우',
      '가수',
      '스타',
    ],
    FortuneSurveyType.pastLife: [
      '전생',
      '과거생',
      '전생탐험',
      '이전생',
      '내전생',
      '전생이',
      '과거삶',
      '전생에',
      '윤회',
      '환생',
    ],
    // 가족/반려동물 (3개)
    FortuneSurveyType.pet: [
      '반려',
      '강아지',
      '고양이',
      '펫',
      '애완',
      '동물',
    ],
    FortuneSurveyType.family: [
      '가족',
      '부모',
      '자녀',
      '아이',
      '엄마',
      '아빠',
      '형제',
    ],
    FortuneSurveyType.naming: [
      '작명',
      '이름',
      '명명',
      '아기이름',
      '태명',
      '성함',
    ],
  };

  /// 텍스트에서 관련 운세 타입들을 감지
  /// 매칭 점수가 높은 순서로 정렬하여 반환
  static List<DetectedIntent> detectIntents(String text) {
    final normalizedText = text.toLowerCase().replaceAll(' ', '');
    final results = <DetectedIntent>[];

    for (final entry in _keywords.entries) {
      final type = entry.key;
      final keywords = entry.value;
      int matchCount = 0;
      final matchedKeywords = <String>[];

      for (final keyword in keywords) {
        if (normalizedText.contains(keyword.toLowerCase())) {
          matchCount++;
          matchedKeywords.add(keyword);
        }
      }

      if (matchCount > 0) {
        results.add(DetectedIntent(
          type: type,
          confidence: _calculateConfidence(matchCount, keywords.length),
          matchedKeywords: matchedKeywords,
        ));
      }
    }

    // 신뢰도 순으로 정렬
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    return results;
  }

  /// 가장 높은 신뢰도의 의도 반환
  static DetectedIntent? detectPrimaryIntent(String text) {
    final intents = detectIntents(text);
    return intents.isNotEmpty ? intents.first : null;
  }

  /// 신뢰도 계산 (0.0 ~ 1.0)
  static double _calculateConfidence(int matchCount, int totalKeywords) {
    // 기본 신뢰도: 매칭 키워드 수 기반
    final baseConfidence = matchCount / totalKeywords;

    // 매칭 수가 많을수록 보너스 (최대 0.3)
    final bonus = (matchCount > 1) ? 0.1 * (matchCount - 1).clamp(0, 3) : 0.0;

    return (baseConfidence + bonus).clamp(0.0, 1.0);
  }

  /// 운세 타입에 대한 추천 메시지 생성
  static String getSuggestionMessage(FortuneSurveyType type) {
    switch (type) {
      // 유틸리티 (추천 대상 아님)
      case FortuneSurveyType.profileCreation:
        return ''; // 프로필 생성은 직접 추천하지 않음
      // 기존 6개
      case FortuneSurveyType.career:
        return '커리어에 대해 궁금하시군요! 커리어 인사이트를 확인해볼까요?';
      case FortuneSurveyType.love:
        return '연애 관련 고민이시네요! 연애 인사이트를 확인해볼까요?';
      case FortuneSurveyType.talent:
        return '적성이 궁금하시군요! 재능 분석을 해드릴까요?';
      case FortuneSurveyType.daily:
        return '오늘의 인사이트를 확인해볼까요?';
      case FortuneSurveyType.tarot:
        return '타로 카드로 리딩을 해드릴까요?';
      case FortuneSurveyType.mbti:
        return 'MBTI 기반 분석을 해드릴까요?';
      // 시간 기반
      case FortuneSurveyType.newYear:
        return '새해 인사이트를 미리 확인해볼까요?';
      case FortuneSurveyType.dailyCalendar:
        return '특정 날짜의 인사이트를 확인해볼까요?';
      // 전통 분석
      case FortuneSurveyType.traditional:
        return '사주팔자로 깊이 있는 분석을 해드릴까요?';
      case FortuneSurveyType.faceReading:
        return 'AI로 관상을 분석해드릴까요?';
      // 성격/개성
      case FortuneSurveyType.personalityDna:
        return '사주로 보는 성격 DNA를 분석해드릴까요?';
      case FortuneSurveyType.biorhythm:
        return '오늘의 바이오리듬을 확인해볼까요?';
      // 연애/관계
      case FortuneSurveyType.compatibility:
        return '궁합을 봐드릴까요?';
      case FortuneSurveyType.avoidPeople:
        return '조심해야 할 인연을 알려드릴까요?';
      case FortuneSurveyType.exLover:
        return '재회 가능성을 분석해드릴까요?';
      case FortuneSurveyType.blindDate:
        return '소개팅 가이드를 확인해볼까요?';
      // 재물
      case FortuneSurveyType.money:
        return '재물 인사이트를 확인해볼까요?';
      // 라이프스타일
      case FortuneSurveyType.luckyItems:
        return '오늘의 행운 아이템을 알려드릴까요?';
      case FortuneSurveyType.lotto:
        return '행운의 로또 번호를 뽑아드릴까요?';
      case FortuneSurveyType.wish:
        return '소원을 빌어보시겠어요?';
      case FortuneSurveyType.fortuneCookie:
        return '오늘의 메시지를 전해드릴까요?';
      // 건강/스포츠
      case FortuneSurveyType.health:
        return '건강 체크를 해드릴까요?';
      case FortuneSurveyType.exercise:
        return '오늘 맞는 운동을 추천해드릴까요?';
      case FortuneSurveyType.sportsGame:
        return '경기 인사이트를 확인해볼까요?';
      // 인터랙티브
      case FortuneSurveyType.dream:
        return '꿈 해몽을 해드릴까요?';
      case FortuneSurveyType.celebrity:
        return '좋아하는 유명인과의 궁합을 볼까요?';
      case FortuneSurveyType.pastLife:
        return '전생을 탐험해볼까요?';
      case FortuneSurveyType.gameEnhance:
        return '오늘의 강화 기운을 확인해볼까요?';
      // 가족/반려동물
      case FortuneSurveyType.pet:
        return '반려동물과의 궁합을 봐드릴까요?';
      case FortuneSurveyType.family:
        return '가족 인사이트를 확인해볼까요?';
      case FortuneSurveyType.naming:
        return '아이 이름을 지어드릴까요?';
      case FortuneSurveyType.babyNickname:
        return '태명을 지어드릴까요?';
      case FortuneSurveyType.ootdEvaluation:
        return '오늘의 코디를 평가해드릴까요?';
      case FortuneSurveyType.talisman:
        return '나만의 부적을 만들어드릴까요?';
      case FortuneSurveyType.exam:
        return '시험 가이드를 확인해볼까요?';
      case FortuneSurveyType.moving:
        return '이사 길일을 알려드릴까요?';
      case FortuneSurveyType.gratitude:
        return '감사일기를 작성해볼까요?';
      case FortuneSurveyType.yearlyEncounter:
        return '올해 만나게 될 인연을 미리 만나볼까요?';
    }
  }
}

/// 감지된 의도
class DetectedIntent {
  final FortuneSurveyType type;
  final double confidence;
  final List<String> matchedKeywords;
  final bool isAiGenerated;

  const DetectedIntent({
    required this.type,
    required this.confidence,
    required this.matchedKeywords,
    this.isAiGenerated = false,
  });

  /// 신뢰도가 충분히 높은지 확인 (0.4 = 여러 키워드 매칭 필요)
  bool get isConfident => confidence >= 0.4;

  @override
  String toString() {
    return 'DetectedIntent(type: $type, confidence: ${(confidence * 100).toStringAsFixed(1)}%, keywords: $matchedKeywords)';
  }
}
