import '../models/life_category.dart';

/// 대분류 → 추천 운세 칩 ID 매핑
///
/// 각 인생 컨설팅 대분류에 해당하는 운세 기능들을 매핑합니다.
/// SmartChipRecommender에서 사용자의 관심 범주에 맞는 칩을 우선 추천할 때 사용됩니다.
const Map<LifeCategory, List<String>> lifeCategoryFortuneMap = {
  // ============ 연애/관계 ============
  // 사랑, 인연, 관계에 관한 운세들
  LifeCategory.loveRelationship: [
    'love', // 붉은 실 - 연애운
    'compatibility', // 우리의 결 - 궁합
    'yearly-encounter', // 올해의 인연
    'blind-date', // 설렘 미리보기 - 소개팅/블라인드데이트
    'ex-lover', // 다시, 안부 - 전 연인
    'avoid-people', // 피해야 할 사람
    'family', // 가족 사이
    'pet-compatibility', // 멍냥궁합
    'tarot', // 타로 한 장
    'past-life', // 전생 탐험
    'decision', // 결정 도움 (관계 관련 고민)
  ],

  // ============ 돈/재정 ============
  // 재물, 투자, 사업에 관한 운세들
  LifeCategory.moneyFinance: [
    'wealth', // 돈길 걷기 - 재물운
    'lucky-items', // 럭키 포인트
    'lotto', // 럭키 넘버
    'career', // 커리어 점프 (수입 관련)
    'tarot', // 타로 한 장
    'daily', // 오늘의 나 (일일 재물운)
    'moving', // 이사 명당 (부동산)
    'decision', // 결정 도움 (재정 관련 고민)
    'coaching', // 코칭 세션
  ],

  // ============ 커리어/학업 ============
  // 직장, 진로, 학업에 관한 운세들
  LifeCategory.careerStudy: [
    'career', // 커리어 점프
    'talent', // 나의 발견 - 재능
    'exam', // 시험 합격
    'tarot', // 타로 한 장
    'decision', // 결정 도움 (진로 관련)
    'coaching', // 코칭 세션
    'personality-dna', // 성격 DNA
    'daily', // 오늘의 나
    'daily-review', // 하루 정리
    'weekly-review', // 주간 돌아보기
  ],

  // ============ 건강/웰빙 ============
  // 건강, 마음관리, 생활습관에 관한 운세들
  LifeCategory.healthWellness: [
    'health', // 갓생 체크
    'biorhythm', // 바이오리듬
    'exercise', // 오운완
    'breathing', // 마음 쉼표
    'daily-review', // 하루 정리
    'weekly-review', // 주간 돌아보기
    'coaching', // 코칭 세션
    'daily', // 오늘의 나
    'tarot', // 타로 한 장
  ],
};

/// 각 대분류의 기본(우선) 추천 칩 (3개)
///
/// 해당 카테고리 선택 직후 가장 먼저 보여줄 칩들입니다.
const Map<LifeCategory, List<String>> lifeCategoryPrimaryChips = {
  LifeCategory.loveRelationship: ['love', 'compatibility', 'tarot'],
  LifeCategory.moneyFinance: ['wealth', 'lucky-items', 'career'],
  LifeCategory.careerStudy: ['career', 'exam', 'coaching'],
  LifeCategory.healthWellness: ['health', 'breathing', 'coaching'],
};

/// 세부 고민별 추천 칩 ID 매핑 (선택적)
///
/// 더 정밀한 추천을 위해 세부 고민 ID에 따른 추천 칩을 정의합니다.
const Map<String, List<String>> subConcernFortuneMap = {
  // ============ 연애/관계 세부 ============
  'currently_dating': ['compatibility', 'love', 'tarot', 'daily-review'],
  'seeking_new_love': ['yearly-encounter', 'blind-date', 'love', 'tarot'],
  'breakup_reunion': ['ex-lover', 'tarot', 'coaching', 'past-life'],
  'marriage_longterm': ['compatibility', 'family', 'tarot', 'decision'],
  'family_relations': ['family', 'compatibility', 'coaching', 'breathing'],

  // ============ 돈/재정 세부 ============
  'investment': ['wealth', 'lucky-items', 'tarot', 'decision'],
  'job_income': ['career', 'wealth', 'talent', 'coaching'],
  'saving_spending': ['wealth', 'daily', 'coaching', 'decision'],
  'business': ['wealth', 'career', 'tarot', 'decision'],
  'debt_crisis': ['wealth', 'coaching', 'tarot', 'breathing'],

  // ============ 커리어/학업 세부 ============
  'job_change': ['career', 'talent', 'decision', 'coaching'],
  'promotion': ['career', 'daily', 'tarot', 'coaching'],
  'exam_certification': ['exam', 'daily', 'coaching', 'breathing'],
  'career_path': ['talent', 'personality-dna', 'coaching', 'decision'],
  'workplace_relations': [
    'compatibility',
    'coaching',
    'breathing',
    'daily-review'
  ],

  // ============ 건강/웰빙 세부 ============
  'physical_health': ['health', 'exercise', 'biorhythm', 'daily'],
  'mental_stress': ['breathing', 'coaching', 'daily-review', 'tarot'],
  'diet_exercise': ['exercise', 'health', 'biorhythm', 'coaching'],
  'sleep_rest': ['biorhythm', 'breathing', 'health', 'daily-review'],
  'lifestyle': ['daily', 'health', 'weekly-review', 'coaching'],
};

/// 세부 고민에 대한 기본 추천 칩 가져오기
///
/// [subConcernId]가 없거나 매핑이 없으면 [lifeCategoryPrimaryChips]에서 가져옵니다.
List<String> getRecommendedChipsForSubConcern(
  String? subConcernId,
  LifeCategory? category,
) {
  // 세부 고민 ID가 있고 매핑이 존재하면 해당 칩 반환
  if (subConcernId != null && subConcernFortuneMap.containsKey(subConcernId)) {
    return subConcernFortuneMap[subConcernId]!;
  }

  // 대분류가 있으면 기본 칩 반환
  if (category != null && lifeCategoryPrimaryChips.containsKey(category)) {
    return lifeCategoryPrimaryChips[category]!;
  }

  // 둘 다 없으면 기본 칩
  return ['daily', 'coaching', 'tarot'];
}

/// 대분류에 속하는 모든 칩 ID 가져오기
List<String> getAllChipsForCategory(LifeCategory? category) {
  if (category == null) return [];
  return lifeCategoryFortuneMap[category] ?? [];
}
