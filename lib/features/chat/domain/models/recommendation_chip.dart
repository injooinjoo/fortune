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

/// 기본 추천 칩 목록 (전체 30개 운세)
const List<RecommendationChip> defaultChips = [
  // ============ 시간 기반 ============
  RecommendationChip(
    id: 'daily',
    label: '오늘 운세',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFF7C3AED),
  ),
  RecommendationChip(
    id: 'dailyCalendar',
    label: '기간별 운세',
    fortuneType: 'daily_calendar',
    icon: Icons.calendar_month_outlined,
    color: Color(0xFF6366F1),
  ),
  RecommendationChip(
    id: 'newYear',
    label: '새해 운세',
    fortuneType: 'newYear',
    icon: Icons.celebration_outlined,
    color: Color(0xFFEF4444),
  ),

  // ============ 연애/관계 ============
  RecommendationChip(
    id: 'love',
    label: '연애운',
    fortuneType: 'love',
    icon: Icons.favorite_outline,
    color: Color(0xFFEC4899),
  ),
  RecommendationChip(
    id: 'compatibility',
    label: '궁합',
    fortuneType: 'compatibility',
    icon: Icons.people_outline,
    color: Color(0xFFF43F5E),
  ),
  RecommendationChip(
    id: 'blindDate',
    label: '소개팅',
    fortuneType: 'blindDate',
    icon: Icons.wine_bar_outlined,
    color: Color(0xFFBE185D),
  ),
  RecommendationChip(
    id: 'exLover',
    label: '재회 운세',
    fortuneType: 'exLover',
    icon: Icons.replay_outlined,
    color: Color(0xFF6B7280),
  ),
  RecommendationChip(
    id: 'avoidPeople',
    label: '경계 대상',
    fortuneType: 'avoidPeople',
    icon: Icons.warning_amber_outlined,
    color: Color(0xFFDC2626),
  ),

  // ============ 직업/재능 ============
  RecommendationChip(
    id: 'career',
    label: '취업/이직',
    fortuneType: 'career',
    icon: Icons.work_outline,
    color: Color(0xFF2563EB),
  ),
  RecommendationChip(
    id: 'talent',
    label: '적성 찾기',
    fortuneType: 'talent',
    icon: Icons.lightbulb_outline,
    color: Color(0xFFFFB300),
  ),

  // ============ 재물 ============
  RecommendationChip(
    id: 'money',
    label: '재물운',
    fortuneType: 'money',
    icon: Icons.attach_money,
    color: Color(0xFF16A34A),
  ),
  RecommendationChip(
    id: 'luckyItems',
    label: '행운 아이템',
    fortuneType: 'luckyItems',
    icon: Icons.auto_awesome,
    color: Color(0xFF8B5CF6),
  ),
  RecommendationChip(
    id: 'lotto',
    label: '로또 번호',
    fortuneType: 'lotto',
    icon: Icons.casino_outlined,
    color: Color(0xFFF59E0B),
  ),

  // ============ 전통/신비 ============
  RecommendationChip(
    id: 'tarot',
    label: '타로',
    fortuneType: 'tarot',
    icon: Icons.style_outlined,
    color: Color(0xFF9333EA),
  ),
  RecommendationChip(
    id: 'traditional',
    label: '사주 분석',
    fortuneType: 'traditional',
    icon: Icons.menu_book_outlined,
    color: Color(0xFFEF4444),
  ),
  RecommendationChip(
    id: 'faceReading',
    label: 'AI 관상',
    fortuneType: 'faceReading',
    icon: Icons.face_retouching_natural,
    color: Color(0xFF06B6D4),
  ),
  RecommendationChip(
    id: 'talisman',
    label: '부적',
    fortuneType: 'talisman',
    icon: Icons.shield_outlined,
    color: Color(0xFF7C3AED),
  ),

  // ============ 성격/개성 ============
  RecommendationChip(
    id: 'mbti',
    label: 'MBTI 운세',
    fortuneType: 'mbti',
    icon: Icons.psychology_outlined,
    color: Color(0xFF8B5CF6),
  ),
  RecommendationChip(
    id: 'personalityDna',
    label: '성격 DNA',
    fortuneType: 'personalityDna',
    icon: Icons.fingerprint,
    color: Color(0xFF6366F1),
  ),
  RecommendationChip(
    id: 'biorhythm',
    label: '바이오리듬',
    fortuneType: 'biorhythm',
    icon: Icons.show_chart,
    color: Color(0xFF0891B2),
  ),

  // ============ 건강/스포츠 ============
  RecommendationChip(
    id: 'health',
    label: '건강운',
    fortuneType: 'health',
    icon: Icons.health_and_safety_outlined,
    color: Color(0xFF10B981),
  ),
  RecommendationChip(
    id: 'exercise',
    label: '운동 추천',
    fortuneType: 'exercise',
    icon: Icons.fitness_center,
    color: Color(0xFFEA580C),
  ),
  RecommendationChip(
    id: 'sportsGame',
    label: '경기 운세',
    fortuneType: 'sportsGame',
    icon: Icons.sports_soccer,
    color: Color(0xFFDC2626),
  ),

  // ============ 인터랙티브 ============
  RecommendationChip(
    id: 'dream',
    label: '꿈해몽',
    fortuneType: 'dream',
    icon: Icons.cloud_outlined,
    color: Color(0xFF6366F1),
  ),
  RecommendationChip(
    id: 'wish',
    label: '소원 빌기',
    fortuneType: 'wish',
    icon: Icons.star_outline,
    color: Color(0xFFFF4081),
  ),
  RecommendationChip(
    id: 'fortuneCookie',
    label: '포춘쿠키',
    fortuneType: 'fortuneCookie',
    icon: Icons.cookie_outlined,
    color: Color(0xFF9333EA),
  ),
  RecommendationChip(
    id: 'celebrity',
    label: '유명인 궁합',
    fortuneType: 'celebrity',
    icon: Icons.star,
    color: Color(0xFFFF1744),
  ),

  // ============ 가족/반려동물 ============
  RecommendationChip(
    id: 'family',
    label: '가족 운세',
    fortuneType: 'family',
    icon: Icons.family_restroom,
    color: Color(0xFF3B82F6),
  ),
  RecommendationChip(
    id: 'pet',
    label: '반려동물 궁합',
    fortuneType: 'pet',
    icon: Icons.pets,
    color: Color(0xFFE11D48),
  ),
  RecommendationChip(
    id: 'naming',
    label: '작명',
    fortuneType: 'naming',
    icon: Icons.edit_note,
    color: Color(0xFF8B5CF6),
  ),

  // ============ 스타일/패션 ============
  RecommendationChip(
    id: 'ootdEvaluation',
    label: 'OOTD 평가',
    fortuneType: 'ootdEvaluation',
    icon: Icons.checkroom,
    color: Color(0xFF10B981),
  ),

  // ============ 실용/결정 ============
  RecommendationChip(
    id: 'exam',
    label: '시험운',
    fortuneType: 'exam',
    icon: Icons.school_outlined,
    color: Color(0xFF3B82F6),
  ),
  RecommendationChip(
    id: 'moving',
    label: '이사/이직',
    fortuneType: 'moving',
    icon: Icons.home_work_outlined,
    color: Color(0xFF059669),
  ),

  // ============ 웰니스 ============
  RecommendationChip(
    id: 'breathing',
    label: '숨쉬기',
    fortuneType: 'breathing',
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF26A69A),
  ),
  RecommendationChip(
    id: 'gratitude',
    label: '감사일기',
    fortuneType: 'gratitude',
    icon: Icons.favorite_outline,
    color: Color(0xFFFFC107),
  ),
];

/// 추가 추천 칩 (컨텍스트 기반 선택용) - deprecated, defaultChips에 통합됨
const List<RecommendationChip> additionalChips = [];
