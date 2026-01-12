import 'package:flutter/material.dart';

/// 추천 칩 모델
class RecommendationChip {
  final String id;
  final String label;
  final String fortuneType;
  final IconData icon;
  final Color color;

  const RecommendationChip({
    required this.id,
    required this.label,
    required this.fortuneType,
    required this.icon,
    required this.color,
  });
}

/// 기본 추천 칩 목록 (전체 인사이트)
const List<RecommendationChip> defaultChips = [
  // ============ 시간 기반 ============
  RecommendationChip(
    id: 'daily',
    label: '☀️ 오늘의 나',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFF7C3AED),
  ),
  RecommendationChip(
    id: 'dailyCalendar',
    label: '🌸 흐르는 시간',
    fortuneType: 'daily_calendar',
    icon: Icons.calendar_month_outlined,
    color: Color(0xFF6366F1),
  ),
  RecommendationChip(
    id: 'newYear',
    label: '🎊 새해 첫걸음',
    fortuneType: 'newYear',
    icon: Icons.celebration_outlined,
    color: Color(0xFFEF4444),
  ),

  // ============ 연애/관계 ============
  RecommendationChip(
    id: 'love',
    label: '💌 붉은 실',
    fortuneType: 'love',
    icon: Icons.favorite_outline,
    color: Color(0xFFEC4899),
  ),
  RecommendationChip(
    id: 'compatibility',
    label: '🎐 우리의 결',
    fortuneType: 'compatibility',
    icon: Icons.people_outline,
    color: Color(0xFFF43F5E),
  ),
  RecommendationChip(
    id: 'exLover',
    label: '🌙 다시, 안부',
    fortuneType: 'exLover',
    icon: Icons.replay_outlined,
    color: Color(0xFF6B7280),
  ),
  RecommendationChip(
    id: 'yearlyEncounter',
    label: '💕 올해의 인연',
    fortuneType: 'yearlyEncounter',
    icon: Icons.favorite,
    color: Color(0xFFE11D48),
  ),
  RecommendationChip(
    id: 'blindDate',
    label: '🍷 설렘 미리보기',
    fortuneType: 'blindDate',
    icon: Icons.wine_bar_outlined,
    color: Color(0xFFBE185D),
  ),
  RecommendationChip(
    id: 'avoidPeople',
    label: '⚡ 피해야 할 사람',
    fortuneType: 'avoidPeople',
    icon: Icons.warning_amber_outlined,
    color: Color(0xFFDC2626),
  ),

  // ============ 직업/재능 ============
  RecommendationChip(
    id: 'career',
    label: '💼 커리어 점프',
    fortuneType: 'career',
    icon: Icons.work_outline,
    color: Color(0xFF2563EB),
  ),
  RecommendationChip(
    id: 'talent',
    label: '🔎 나의 발견',
    fortuneType: 'talent',
    icon: Icons.lightbulb_outline,
    color: Color(0xFFFFB300),
  ),

  // ============ 재물 ============
  RecommendationChip(
    id: 'money',
    label: '💸 돈길 걷기',
    fortuneType: 'money',
    icon: Icons.attach_money,
    color: Color(0xFF16A34A),
  ),
  RecommendationChip(
    id: 'luckyItems',
    label: '✨ 럭키 포인트',
    fortuneType: 'luckyItems',
    icon: Icons.auto_awesome,
    color: Color(0xFF8B5CF6),
  ),
  RecommendationChip(
    id: 'lotto',
    label: '🎰 럭키 넘버',
    fortuneType: 'lotto',
    icon: Icons.casino_outlined,
    color: Color(0xFFF59E0B),
  ),

  // ============ 전통/신비 ============
  RecommendationChip(
    id: 'tarot',
    label: '🃏 타로 한 장',
    fortuneType: 'tarot',
    icon: Icons.style_outlined,
    color: Color(0xFF9333EA),
  ),
  RecommendationChip(
    id: 'traditional',
    label: '🔮 인생 로그',
    fortuneType: 'traditional',
    icon: Icons.menu_book_outlined,
    color: Color(0xFFEF4444),
  ),
  RecommendationChip(
    id: 'faceReading',
    label: '🪞 얼굴 읽기',
    fortuneType: 'faceReading',
    icon: Icons.face_retouching_natural,
    color: Color(0xFF06B6D4),
  ),
  RecommendationChip(
    id: 'talisman',
    label: '🧧 나만의 부적',
    fortuneType: 'talisman',
    icon: Icons.shield_outlined,
    color: Color(0xFF7C3AED),
  ),
  RecommendationChip(
    id: 'pastLife',
    label: '🎭 전생 탐험',
    fortuneType: 'pastLife',
    icon: Icons.history_edu,
    color: Color(0xFF8B4513),
  ),

  // ============ 성격/개성 ============
  RecommendationChip(
    id: 'personalityDna',
    label: '🧬 성격 DNA',
    fortuneType: 'personalityDna',
    icon: Icons.fingerprint,
    color: Color(0xFF6366F1),
  ),
  RecommendationChip(
    id: 'biorhythm',
    label: '🌊 바이오리듬',
    fortuneType: 'biorhythm',
    icon: Icons.show_chart,
    color: Color(0xFF0891B2),
  ),
  RecommendationChip(
    id: 'mbti',
    label: '🧠 과몰입 주의',
    fortuneType: 'mbti',
    icon: Icons.psychology_outlined,
    color: Color(0xFF8B5CF6),
  ),

  // ============ 건강/스포츠 ============
  RecommendationChip(
    id: 'health',
    label: '🍀 갓생 체크',
    fortuneType: 'health',
    icon: Icons.health_and_safety_outlined,
    color: Color(0xFF10B981),
  ),
  RecommendationChip(
    id: 'exercise',
    label: '👟 오운완',
    fortuneType: 'exercise',
    icon: Icons.fitness_center,
    color: Color(0xFFEA580C),
  ),
  RecommendationChip(
    id: 'sportsGame',
    label: '⚽ 승부 예감',
    fortuneType: 'sportsGame',
    icon: Icons.sports_soccer,
    color: Color(0xFFDC2626),
  ),

  // ============ 인터랙티브 ============
  RecommendationChip(
    id: 'dream',
    label: '☁️ 꿈해몽',
    fortuneType: 'dream',
    icon: Icons.cloud_outlined,
    color: Color(0xFF6366F1),
  ),
  RecommendationChip(
    id: 'wish',
    label: '💫 소원 빌기',
    fortuneType: 'wish',
    icon: Icons.star_outline,
    color: Color(0xFFFF4081),
  ),
  RecommendationChip(
    id: 'fortuneCookie',
    label: '🥠 포춘쿠키',
    fortuneType: 'fortuneCookie',
    icon: Icons.cookie_outlined,
    color: Color(0xFF9333EA),
  ),
  RecommendationChip(
    id: 'celebrity',
    label: '🌟 셀럽 케미',
    fortuneType: 'celebrity',
    icon: Icons.star,
    color: Color(0xFFFF1744),
  ),

  // ============ 가족/반려동물 ============
  RecommendationChip(
    id: 'family',
    label: '🫂 가족 사이',
    fortuneType: 'family',
    icon: Icons.family_restroom,
    color: Color(0xFF3B82F6),
  ),
  RecommendationChip(
    id: 'pet',
    label: '🐕 멍냥궁합',
    fortuneType: 'pet',
    icon: Icons.pets,
    color: Color(0xFFE11D48),
  ),
  RecommendationChip(
    id: 'naming',
    label: '✍️ 작명소',
    fortuneType: 'naming',
    icon: Icons.edit_note,
    color: Color(0xFF8B5CF6),
  ),

  // ============ 스타일/패션 ============
  RecommendationChip(
    id: 'ootdEvaluation',
    label: '👗 OOTD 평가',
    fortuneType: 'ootdEvaluation',
    icon: Icons.checkroom,
    color: Color(0xFF10B981),
  ),

  // ============ 실용/결정 ============
  RecommendationChip(
    id: 'exam',
    label: '🎓 시험 합격',
    fortuneType: 'exam',
    icon: Icons.school_outlined,
    color: Color(0xFF3B82F6),
  ),
  RecommendationChip(
    id: 'moving',
    label: '🏠 이사 명당',
    fortuneType: 'moving',
    icon: Icons.home_outlined,
    color: Color(0xFF059669),
  ),

  // ============ 웰니스 ============
  RecommendationChip(
    id: 'breathing',
    label: '🧘 마음 쉼표',
    fortuneType: 'breathing',
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF26A69A),
  ),
  RecommendationChip(
    id: 'gratitude',
    label: '💝 고마운 하루',
    fortuneType: 'gratitude',
    icon: Icons.favorite_outline,
    color: Color(0xFFFFC107),
  ),
];

/// 추가 추천 칩 (컨텍스트 기반 선택용) - deprecated, defaultChips에 통합됨
const List<RecommendationChip> additionalChips = [];

/// 시작 화면 초기 칩 (4개 표시)
const List<RecommendationChip> initialChips = [
  RecommendationChip(
    id: 'newYear',
    label: '🎊 새해 첫걸음',
    fortuneType: 'newYear',
    icon: Icons.celebration_outlined,
    color: Color(0xFFEF4444),
  ),
  RecommendationChip(
    id: 'daily',
    label: '☀️ 오늘의 나',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFF7C3AED),
  ),
  RecommendationChip(
    id: 'love',
    label: '💌 붉은 실',
    fortuneType: 'love',
    icon: Icons.favorite_outline,
    color: Color(0xFFEC4899),
  ),
  RecommendationChip(
    id: 'viewAll',
    label: '🔮 전체 보기',
    fortuneType: 'viewAll',
    icon: Icons.apps_outlined,
    color: Color(0xFF6366F1),
  ),
];
