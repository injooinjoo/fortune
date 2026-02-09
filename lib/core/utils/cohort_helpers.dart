import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'zodiac_calculator.dart';

/// Cohort 기반 운세 최적화를 위한 헬퍼 함수 모음
/// API 비용 90% 절감을 위한 cohort 분류 로직
class CohortHelpers {
  CohortHelpers._();

  // ==================== 나잇대 (Age Group) ====================

  /// 나이 → 나잇대 변환
  static String getAgeGroup(int age) {
    if (age < 20) return '10대';
    if (age < 30) return '20대';
    if (age < 40) return '30대';
    if (age < 50) return '40대';
    return '50대+';
  }

  /// 생년월일 → 나잇대 변환
  static String getAgeGroupFromBirthDate(DateTime birthDate) {
    final age = _calculateAge(birthDate);
    return getAgeGroup(age);
  }

  static int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ==================== 띠 (Zodiac) ====================

  /// 생년 → 띠 이름 반환
  static String getZodiacName(int year) {
    return ZodiacCalculator.getZodiac(year)['name']!;
  }

  /// 생년월일 → 띠 이름 반환
  static String getZodiacFromBirthDate(DateTime birthDate) {
    return getZodiacName(birthDate.year);
  }

  /// 모든 띠 목록
  static const List<String> allZodiacs = [
    '쥐',
    '소',
    '호랑이',
    '토끼',
    '용',
    '뱀',
    '말',
    '양',
    '원숭이',
    '닭',
    '개',
    '돼지'
  ];

  // ==================== 오행 (Five Elements) ====================

  /// 10천간 목록
  static const List<String> tianGan = [
    '甲', '乙', // 목(木)
    '丙', '丁', // 화(火)
    '戊', '己', // 토(土)
    '庚', '辛', // 금(金)
    '壬', '癸', // 수(水)
  ];

  /// 천간 → 오행 매핑
  static const Map<String, String> ganToElement = {
    '甲': '목',
    '乙': '목',
    '丙': '화',
    '丁': '화',
    '戊': '토',
    '己': '토',
    '庚': '금',
    '辛': '금',
    '壬': '수',
    '癸': '수',
  };

  /// 모든 오행 목록
  static const List<String> allElements = ['목', '화', '토', '금', '수'];

  /// 생년 → 천간 계산
  static String getTianGan(int year) {
    // 1984년이 甲子년 기준
    final index = (year - 4) % 10;
    return tianGan[index];
  }

  /// 생년 → 오행 계산
  static String getElement(int year) {
    final gan = getTianGan(year);
    return ganToElement[gan]!;
  }

  /// 생년월일 → 오행 계산
  static String getElementFromBirthDate(DateTime birthDate) {
    return getElement(birthDate.year);
  }

  /// 일간(日干) → 오행 (사주용)
  static String getDayMasterElement(String dayMaster) {
    return ganToElement[dayMaster] ?? '토';
  }

  // ==================== 시간대 (Period) ====================

  /// 현재 시간 → 시간대 변환
  static String getPeriod([DateTime? dateTime]) {
    final hour = (dateTime ?? DateTime.now()).hour;
    if (hour >= 0 && hour < 6) return '새벽';
    if (hour >= 6 && hour < 12) return '아침';
    if (hour >= 12 && hour < 17) return '오후';
    if (hour >= 17 && hour < 21) return '저녁';
    return '밤';
  }

  /// 모든 시간대 목록
  static const List<String> allPeriods = ['새벽', '아침', '오후', '저녁', '밤'];

  // ==================== 계절 (Season) ====================

  /// 현재 날짜 → 계절 변환
  static String getSeason([DateTime? dateTime]) {
    final month = (dateTime ?? DateTime.now()).month;
    if (month >= 3 && month <= 5) return '봄';
    if (month >= 6 && month <= 8) return '여름';
    if (month >= 9 && month <= 11) return '가을';
    return '겨울';
  }

  /// 모든 계절 목록
  static const List<String> allSeasons = ['봄', '여름', '가을', '겨울'];

  // ==================== 분류 함수 ====================

  /// 산업 분류
  static String classifyIndustry(String? industry) {
    if (industry == null || industry.isEmpty) return '기타';

    final lower = industry.toLowerCase();

    if (RegExp(r'it|개발|소프트웨어|테크|프로그래머|엔지니어|데이터').hasMatch(lower)) {
      return 'IT';
    }
    if (RegExp(r'금융|은행|보험|증권|투자|펀드').hasMatch(lower)) return '금융';
    if (RegExp(r'의료|병원|의사|간호|약|헬스케어').hasMatch(lower)) return '의료';
    if (RegExp(r'교육|학교|선생|교수|강사|학원').hasMatch(lower)) return '교육';
    if (RegExp(r'서비스|판매|영업|마케팅|고객').hasMatch(lower)) return '서비스';
    if (RegExp(r'제조|공장|생산|품질').hasMatch(lower)) return '제조';
    if (RegExp(r'예술|디자인|음악|미술|창작|영상').hasMatch(lower)) return '예술';
    if (RegExp(r'공공|공무원|정부|행정').hasMatch(lower)) return '공공';
    if (RegExp(r'스타트업|창업|벤처').hasMatch(lower)) return '스타트업';

    return '기타';
  }

  /// 질문 카테고리 분류 (사주용)
  static String classifyQuestionCategory(String question) {
    if (RegExp(r'연애|사랑|결혼|이성|짝|소개팅|애인|남친|여친').hasMatch(question)) {
      return '연애';
    }
    if (RegExp(r'취업|직장|일|커리어|승진|이직|면접|회사').hasMatch(question)) {
      return '취업';
    }
    if (RegExp(r'건강|아프|병|몸|다이어트|운동').hasMatch(question)) return '건강';
    if (RegExp(r'돈|재물|투자|금전|복권|수입|월급').hasMatch(question)) return '금전';
    return '대인'; // 기본값
  }

  /// 꿈 카테고리 분류 (해몽용)
  static String classifyDreamCategory(String dreamContent) {
    final lower = dreamContent.toLowerCase();

    if (RegExp(r'날다|하늘|비행|새|떠오르다|날개').hasMatch(lower)) return '날기';
    if (RegExp(r'떨어지다|추락|절벽|높은곳|낙하').hasMatch(lower)) return '떨어짐';
    if (RegExp(r'쫓기다|도망|쫓아오다|따라오다|추격').hasMatch(lower)) return '추격';
    if (RegExp(r'시험|테스트|문제|답안|학교|합격').hasMatch(lower)) return '시험';
    if (RegExp(r'늦다|지각|놓치다|기차|비행기|버스').hasMatch(lower)) return '늦음';
    if (RegExp(r'죽다|장례|시체|묘지|관|상여').hasMatch(lower)) return '죽음';
    if (RegExp(r'돈|지갑|금|보물|복권|주식|현금').hasMatch(lower)) return '돈';
    if (RegExp(r'개|고양이|뱀|호랑이|동물|새|물고기|곤충').hasMatch(lower)) return '동물';
    if (RegExp(r'바다|강|호수|수영|익사|물|비|홍수').hasMatch(lower)) return '물';
    return '사람'; // 기본값 (가족, 친구, 연인, 낯선사람, 유명인)
  }

  /// 꿈 감정 분류
  static String classifyDreamEmotion(String dreamContent) {
    final lower = dreamContent.toLowerCase();

    if (RegExp(r'무섭|두렵|공포|겁|악몽').hasMatch(lower)) return '공포';
    if (RegExp(r'불안|걱정|초조|긴장').hasMatch(lower)) return '불안';
    if (RegExp(r'기쁘|행복|좋|즐거|웃').hasMatch(lower)) return '기쁨';
    if (RegExp(r'슬프|울|눈물|아프').hasMatch(lower)) return '슬픔';
    return '중립'; // 기본값
  }

  /// 재능 영역 분류
  static String classifyTalentArea(List<String> interests) {
    final combined = interests.join(' ').toLowerCase();

    if (RegExp(r'미술|음악|글|디자인|예술|창작|연기').hasMatch(combined)) return '예술';
    if (RegExp(r'코딩|개발|기술|it|프로그래밍|엔지니어').hasMatch(combined)) return '기술';
    if (RegExp(r'리더|경영|관리|조직|통솔').hasMatch(combined)) return '리더십';
    if (RegExp(r'분석|데이터|연구|통계|수학').hasMatch(combined)) return '분석';
    if (RegExp(r'창의|아이디어|기획|발명').hasMatch(combined)) return '창의';
    if (RegExp(r'사회|봉사|교육|상담|커뮤니케이션').hasMatch(combined)) return '사회';
    if (RegExp(r'실무|사무|회계|행정').hasMatch(combined)) return '실무';
    return '학문'; // 기본값
  }

  /// 투자 성향 분류
  static String classifyRiskTolerance(String? tolerance) {
    if (tolerance == null) return '중립';

    final lower = tolerance.toLowerCase();
    if (RegExp(r'보수|안전|안정|저위험').hasMatch(lower)) return '보수적';
    if (RegExp(r'공격|적극|고위험|고수익').hasMatch(lower)) return '공격적';
    return '중립';
  }

  /// 감정 상태 분류 (전연인용)
  static String classifyEmotionState(String? emotion) {
    if (emotion == null) return '혼란';

    final lower = emotion.toLowerCase();
    if (RegExp(r'미련|아쉬|그립|잊지').hasMatch(lower)) return '미련';
    if (RegExp(r'화|분노|짜증|배신|싫').hasMatch(lower)) return '분노';
    if (RegExp(r'무덤덤|상관|괜찮|지남').hasMatch(lower)) return '무덤덤';
    if (RegExp(r'그리움|보고싶|생각나|추억').hasMatch(lower)) return '그리움';
    return '혼란';
  }

  /// 연락 경과 시간 분류 (전연인용)
  static String classifyTimeElapsed(DateTime? breakupDate) {
    if (breakupDate == null) return '1년이상';

    final now = DateTime.now();
    final months = (now.year - breakupDate.year) * 12 +
        (now.month - breakupDate.month);

    if (months < 1) return '1개월내';
    if (months < 6) return '1-6개월';
    if (months < 12) return '6-12개월';
    return '1년이상';
  }

  /// 연락 상태 분류 (전연인용)
  static String classifyContactStatus(String? status) {
    if (status == null) return '연락끊김';

    final lower = status.toLowerCase();
    if (RegExp(r'연락|대화|카톡|문자|통화').hasMatch(lower)) return '연락중';
    if (RegExp(r'차단|블락|삭제').hasMatch(lower)) return '차단';
    return '연락끊김';
  }

  /// 소개팅 목표 분류
  static String classifyDateGoal(String? goal) {
    if (goal == null) return '진지한만남';

    final lower = goal.toLowerCase();
    if (RegExp(r'가볍|캐주얼|재미|만남만').hasMatch(lower)) return '가벼운만남';
    if (RegExp(r'친구|알아가|천천|먼저').hasMatch(lower)) return '친구먼저';
    return '진지한만남';
  }

  /// 성별쌍 분류 (궁합용)
  static String classifyGenderPair(String gender1, String gender2) {
    final g1 = gender1.toLowerCase();
    final g2 = gender2.toLowerCase();

    final isMale1 = g1 == '남' || g1 == '남성' || g1 == 'male';
    final isMale2 = g2 == '남' || g2 == '남성' || g2 == 'male';

    if (isMale1 && !isMale2) return '남녀';
    if (!isMale1 && isMale2) return '남녀';
    if (isMale1 && isMale2) return '남남';
    return '여여';
  }

  // ==================== Cohort Hash 생성 ====================

  /// Cohort 데이터 → SHA-256 해시
  /// Note: Edge Function과 동일한 알고리즘 사용 (Web Crypto API는 MD5 미지원)
  static String generateCohortHash(Map<String, String> cohortData) {
    // 키 정렬 후 직렬화
    final sortedKeys = cohortData.keys.toList()..sort();
    final normalized = sortedKeys.map((k) => '$k:${cohortData[k]}').join('|');

    // SHA-256 해시 생성
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cohort 추출 (운세 타입별)
  static Map<String, String> extractCohort({
    required String fortuneType,
    required Map<String, dynamic> input,
  }) {
    switch (fortuneType) {
      case 'daily':
        return _extractDailyCohort(input);
      case 'love':
        return _extractLoveCohort(input);
      case 'compatibility':
        return _extractCompatibilityCohort(input);
      case 'career':
        return _extractCareerCohort(input);
      case 'health':
        return _extractHealthCohort(input);
      case 'traditional-saju':
        return _extractSajuCohort(input);
      case 'dream':
        return _extractDreamCohort(input);
      case 'face-reading':
        return _extractFaceReadingCohort(input);
      case 'mbti':
        return _extractMbtiCohort(input);
      case 'lucky-items':
        return _extractLuckyItemsCohort(input);
      case 'talent':
        return _extractTalentCohort(input);
      case 'investment':
        return _extractInvestmentCohort(input);
      case 'ex-lover':
        return _extractExLoverCohort(input);
      case 'blind-date':
        return _extractBlindDateCohort(input);
      default:
        return {};
    }
  }

  static Map<String, String> _extractDailyCohort(Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    return {
      'period': getPeriod(),
      'zodiac': getZodiacFromBirthDate(birthDate),
      'element': getElementFromBirthDate(birthDate),
    };
  }

  static Map<String, String> _extractLoveCohort(Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    return {
      'ageGroup': getAgeGroup(age),
      'gender': input['gender'] as String? ?? '기타',
      'relationshipStatus': input['relationshipStatus'] as String? ?? '솔로',
      'zodiac': getZodiacFromBirthDate(birthDate),
    };
  }

  static Map<String, String> _extractCompatibilityCohort(
      Map<String, dynamic> input) {
    final birthDate1 = _parseBirthDate(input['person1_birth_date']);
    final birthDate2 = _parseBirthDate(input['person2_birth_date']);
    final gender1 = input['person1_gender'] as String? ?? '남';
    final gender2 = input['person2_gender'] as String? ?? '여';
    return {
      'zodiac1': getZodiacFromBirthDate(birthDate1),
      'zodiac2': getZodiacFromBirthDate(birthDate2),
      'genderPair': classifyGenderPair(gender1, gender2),
    };
  }

  static Map<String, String> _extractCareerCohort(Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    return {
      'ageGroup': getAgeGroup(age),
      'gender': input['gender'] as String? ?? '기타',
      'industry': classifyIndustry(input['industry'] as String?),
    };
  }

  static Map<String, String> _extractHealthCohort(Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    return {
      'ageGroup': getAgeGroup(age),
      'gender': input['gender'] as String? ?? '기타',
      'season': getSeason(),
      'element': getElementFromBirthDate(birthDate),
    };
  }

  static Map<String, String> _extractSajuCohort(Map<String, dynamic> input) {
    final question = input['question'] as String? ?? '';
    final sajuData = input['sajuData'] as Map<String, dynamic>?;

    String dayMaster = '甲';
    String elementBalance = '토과다';

    if (sajuData != null) {
      dayMaster = sajuData['dayPillar']?['gan'] as String? ?? '甲';
      // 오행 균형 계산 (간단 버전)
      final elements = _countElements(sajuData);
      elementBalance = _findDominantElement(elements);
    }

    return {
      'dayMaster': dayMaster,
      'elementBalance': elementBalance,
      'questionCategory': classifyQuestionCategory(question),
    };
  }

  static Map<String, String> _extractDreamCohort(Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final dreamContent = input['dream_content'] as String? ?? '';
    return {
      'dreamCategory': classifyDreamCategory(dreamContent),
      'emotion': classifyDreamEmotion(dreamContent),
      'zodiac': getZodiacFromBirthDate(birthDate),
    };
  }

  static Map<String, String> _extractFaceReadingCohort(
      Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    return {
      'faceShape': input['faceShape'] as String? ?? '타원형',
      'gender': input['gender'] as String? ?? '기타',
      'ageGroup': getAgeGroup(age),
    };
  }

  static Map<String, String> _extractMbtiCohort(Map<String, dynamic> input) {
    return {
      'mbti': (input['mbti'] as String? ?? 'INFP').toUpperCase(),
    };
  }

  static Map<String, String> _extractLuckyItemsCohort(
      Map<String, dynamic> input) {
    return {
      'category': input['category'] as String? ?? 'work',
    };
  }

  static Map<String, String> _extractTalentCohort(Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    final interests = (input['interests'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return {
      'ageGroup': getAgeGroup(age),
      'gender': input['gender'] as String? ?? '기타',
      'talentArea': classifyTalentArea(interests),
    };
  }

  static Map<String, String> _extractInvestmentCohort(
      Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    return {
      'ageGroup': getAgeGroup(age),
      'riskTolerance':
          classifyRiskTolerance(input['riskTolerance'] as String?),
      'element': getElementFromBirthDate(birthDate),
    };
  }

  static Map<String, String> _extractExLoverCohort(Map<String, dynamic> input) {
    final breakupDateStr = input['breakupDate'] as String?;
    final breakupDate =
        breakupDateStr != null ? DateTime.tryParse(breakupDateStr) : null;
    return {
      'emotionState': classifyEmotionState(input['emotion'] as String?),
      'timeElapsed': classifyTimeElapsed(breakupDate),
      'contactStatus': classifyContactStatus(input['contactStatus'] as String?),
    };
  }

  static Map<String, String> _extractBlindDateCohort(
      Map<String, dynamic> input) {
    final birthDate = _parseBirthDate(input['birthDate']);
    final age = input['age'] as int? ?? _calculateAge(birthDate);
    return {
      'ageGroup': getAgeGroup(age),
      'gender': input['gender'] as String? ?? '기타',
      'dateGoal': classifyDateGoal(input['dateGoal'] as String?),
    };
  }

  // ==================== 내부 헬퍼 ====================

  static DateTime _parseBirthDate(dynamic birthDate) {
    if (birthDate is DateTime) return birthDate;
    if (birthDate is String) {
      return DateTime.tryParse(birthDate) ?? DateTime(2000, 1, 1);
    }
    return DateTime(2000, 1, 1);
  }

  static Map<String, int> _countElements(Map<String, dynamic> sajuData) {
    final counts = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};

    final pillars = ['yearPillar', 'monthPillar', 'dayPillar', 'timePillar'];
    for (final pillar in pillars) {
      final p = sajuData[pillar] as Map<String, dynamic>?;
      if (p != null) {
        final gan = p['gan'] as String?;
        if (gan != null && ganToElement.containsKey(gan)) {
          counts[ganToElement[gan]!] = (counts[ganToElement[gan]!] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  static String _findDominantElement(Map<String, int> counts) {
    String dominant = '토';
    int maxCount = 0;

    counts.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = element;
      }
    });

    return '$dominant과다';
  }
}
