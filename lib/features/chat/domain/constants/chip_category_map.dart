// 각 칩의 fortuneType을 카테고리에 매핑
// recommendation_chip.dart의 30개 defaultChips 기준
const Map<String, String> chipToCategoryMap = {
  // ============ lifestyle (일상/시간 기반) ============
  'daily': 'lifestyle',
  'daily-calendar': 'lifestyle',
  'new-year': 'lifestyle',
  'mbti': 'lifestyle',
  'personality-dna': 'lifestyle',
  'ootd-evaluation': 'lifestyle',
  'moving': 'lifestyle',

  // ============ love (연애/관계) ============
  'love': 'love',
  'compatibility': 'love',
  'blind-date': 'love',
  'ex-lover': 'love',
  'avoid-people': 'love',

  // ============ career (직업/재능) ============
  'career': 'career',
  'talent': 'career',
  'exam': 'career',

  // ============ money (재물) ============
  'wealth': 'money',
  'lucky-items': 'money',
  'lotto': 'money',

  // ============ traditional (전통/신비) ============
  'tarot': 'traditional',
  'traditional-saju': 'traditional',
  'face-reading': 'traditional',
  'talisman': 'traditional',
  'past-life': 'traditional',

  // ============ health (건강/웰니스) ============
  'biorhythm': 'health',
  'health': 'health',
  'exercise': 'health',
  'match-insight': 'health',
  'breathing': 'health',

  // ============ interactive (인터랙티브/재미) ============
  'game-enhance': 'interactive',
  'dream': 'interactive',
  'wish': 'interactive',
  'fortune-cookie': 'interactive',
  'celebrity': 'interactive',

  // ============ petFamily (가족/반려동물) ============
  'family': 'petFamily',
  'pet-compatibility': 'petFamily',
  'naming': 'petFamily',

  // ============ coaching (AI 코칭/저널링) ============
  'coaching': 'coaching',
  'decision': 'coaching',
  'daily-review': 'coaching',
  'weekly-review': 'coaching',
  'chat-insight': 'coaching',
  'view-all': 'coaching',
};

/// 칩의 fortuneType으로 카테고리 조회
String getCategoryForChip(String fortuneType) {
  return chipToCategoryMap[fortuneType] ?? 'lifestyle';
}
