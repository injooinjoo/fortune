// 카테고리 연관성 맵
// Key: 현재 운세의 카테고리
// Value: 연관 카테고리 (우선순위 순서)
const Map<String, List<String>> categoryAffinity = {
  // 연애/관계 클러스터
  'love': ['love', 'traditional', 'interactive', 'lifestyle'],

  // 직업/재물 클러스터
  'career': ['career', 'money', 'coaching', 'lifestyle'],
  'money': ['money', 'career', 'lifestyle', 'traditional'],

  // 전통/신비 클러스터
  'traditional': ['traditional', 'lifestyle', 'love', 'interactive'],

  // 건강/웰니스 클러스터
  'health': ['health', 'lifestyle', 'coaching', 'interactive'],

  // 라이프스타일/일상 클러스터
  'lifestyle': ['lifestyle', 'coaching', 'interactive', 'love'],

  // 인터랙티브/재미 클러스터
  'interactive': ['interactive', 'coaching', 'lifestyle', 'love'],

  // 가족/반려동물 클러스터
  'petFamily': ['petFamily', 'love', 'lifestyle', 'interactive'],

  // AI 코칭/저널링 클러스터 (새로 추가)
  'coaching': ['coaching', 'lifestyle', 'health', 'career'],
};

/// 현재 카테고리 기준 대상 카테고리의 연관성 점수 반환
/// 같은 카테고리 = 1.0, 이후 0.2씩 감소
double getAffinityScore(String currentCategory, String targetCategory) {
  final affinities = categoryAffinity[currentCategory];
  if (affinities == null) return 0.5; // 기본 중간 점수

  final index = affinities.indexOf(targetCategory);
  if (index == -1) return 0.3; // 연관 목록에 없음

  return 1.0 - (index * 0.2); // 1.0, 0.8, 0.6, 0.4...
}
