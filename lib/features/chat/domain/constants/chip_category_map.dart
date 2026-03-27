import 'package:flutter/material.dart';
import '../../../../core/design_system/theme/ds_extensions.dart';

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

/// 카테고리별 파스텔 배경색 매핑 (Paper 디자인 기준)
///
/// context 기반으로 다크/라이트 모드 대응
/// 사용: `getChipColorForCategory(context, 'love')` → peach pastel
Color getChipColorForCategory(BuildContext context, String category) {
  final colors = context.colors;
  switch (category) {
    case 'love':
    case 'petFamily':
      return colors.chipPeach;
    case 'career':
    case 'money':
      return colors.chipGreen;
    case 'traditional':
    case 'interactive':
      return colors.chipLavender;
    case 'health':
    case 'coaching':
      return colors.chipBlue;
    case 'lifestyle':
    default:
      return colors.chipBlue;
  }
}

/// fortuneType으로 직접 파스텔 칩 색상 조회
Color getChipColorForFortuneType(BuildContext context, String fortuneType) {
  final category = getCategoryForChip(fortuneType);
  return getChipColorForCategory(context, category);
}

/// 칩 텍스트 색상 (파스텔 배경 위의 어두운 텍스트)
Color getChipTextColor(BuildContext context) {
  return context.colors.chipText;
}
