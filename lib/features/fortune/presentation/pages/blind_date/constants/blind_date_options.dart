/// 소개팅 운세 페이지에서 사용하는 상수 옵션들
library;

/// 만남 시간대 옵션
const Map<String, String> meetingTimeOptions = {
  'morning': '아침 (7-11시)',
  'lunch': '점심 (11-14시)',
  'afternoon': '오후 (14-18시)',
  'evening': '저녁 (18-22시)',
  'night': '밤 (22시 이후)',
};

/// 만남 방식 옵션
const Map<String, String> meetingTypeOptions = {
  'coffee': '카페에서 차 한잔',
  'meal': '식사',
  'activity': '액티비티 (볼링, 영화 등)',
  'walk': '산책',
  'online': '온라인 만남',
};

/// 소개 경로 옵션
const Map<String, String> introducerOptions = {
  'friend': '친구',
  'family': '가족',
  'colleague': '직장 동료',
  'app': '데이팅 앱',
  'matchmaker': '결혼정보회사',
  'other': '기타',
};

/// 중요하게 생각하는 것 옵션
const List<String> qualityOptions = [
  '외모',
  '성격',
  '유머감각',
  '경제력',
  '가치관',
  '학력',
  '직업',
  '취미',
  '가족관계',
  '종교',
];

/// 나이 선호도 옵션
const Map<String, String> agePreferenceOptions = {
  'younger': '연하 선호',
  'same': '동갑 선호',
  'older': '연상 선호',
  'flexible': '나이 상관없음',
};

/// 이상적인 첫 데이트 옵션
const Map<String, String> idealDateOptions = {
  'casual': '편안한 대화 (카페, 산책)',
  'fun': '재미있는 활동 (놀이공원, 게임)',
  'cultural': '문화생활 (전시회, 공연)',
  'nature': '자연 속 데이트',
  'food': '맛집 탐방',
};

/// 자신감 수준 옵션
const Map<String, String> confidenceLevelOptions = {
  'very_low': '매우 낮음',
  'low': '낮음',
  'medium': '보통',
  'high': '높음',
  'very_high': '매우 높음',
};

/// 걱정되는 부분 옵션
const List<String> concernOptions = [
  '첫인상',
  '대화 주제',
  '어색한 침묵',
  '외모',
  '매너',
  '상대방의 기대',
  '거절 두려움',
  '과거 경험',
];

/// 대화 플랫폼 옵션
const Map<String, String> chatPlatformOptions = {
  'kakao': '카카오톡',
  'sms': '문자 메시지',
  'instagram': '인스타그램 DM',
  'other': '기타',
};
