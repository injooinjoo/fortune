/// 각 칩의 fortuneType을 카테고리에 매핑
/// recommendation_chip.dart의 30개 defaultChips 기준
const Map<String, String> chipToCategoryMap = {
  // ============ lifestyle (일상/시간 기반) ============
  'daily': 'lifestyle',
  'daily_calendar': 'lifestyle',
  'newYear': 'lifestyle',
  'mbti': 'lifestyle',
  'personalityDna': 'lifestyle',
  'ootdEvaluation': 'lifestyle',
  'moving': 'lifestyle',

  // ============ love (연애/관계) ============
  'love': 'love',
  'compatibility': 'love',
  'blindDate': 'love',
  'exLover': 'love',
  'avoidPeople': 'love',

  // ============ career (직업/재능) ============
  'career': 'career',
  'talent': 'career',
  'exam': 'career',

  // ============ money (재물) ============
  'money': 'money',
  'luckyItems': 'money',
  'lotto': 'money',

  // ============ traditional (전통/신비) ============
  'tarot': 'traditional',
  'traditional': 'traditional',
  'faceReading': 'traditional',
  'talisman': 'traditional',
  'pastLife': 'traditional',

  // ============ health (건강/웰니스) ============
  'biorhythm': 'health',
  'health': 'health',
  'exercise': 'health',
  'sportsGame': 'health',
  'breathing': 'health',

  // ============ interactive (인터랙티브/재미) ============
  'gameEnhance': 'interactive',
  'dream': 'interactive',
  'wish': 'interactive',
  'fortuneCookie': 'interactive',
  'celebrity': 'interactive',
  'gratitude': 'interactive',

  // ============ petFamily (가족/반려동물) ============
  'family': 'petFamily',
  'pet': 'petFamily',
  'naming': 'petFamily',

  // ============ coaching (AI 코칭/저널링) ============
  'coaching': 'coaching',
  'decision': 'coaching',
  'daily_review': 'coaching',
  'weekly_review': 'coaching',
};

/// 칩의 fortuneType으로 카테고리 조회
String getCategoryForChip(String fortuneType) {
  return chipToCategoryMap[fortuneType] ?? 'lifestyle';
}
