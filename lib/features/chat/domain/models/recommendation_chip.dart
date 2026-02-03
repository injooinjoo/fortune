import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/ds_fortune_colors.dart';

/// 추천 칩 모델
class RecommendationChip {
  final String id;
  final String label;
  final String? subtitle;
  final String fortuneType;
  final IconData icon;
  final Color color;

  const RecommendationChip({
    required this.id,
    required this.label,
    this.subtitle,
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
    label: '오늘의 운세',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: DSFortuneColors.categoryDaily,
  ),
  RecommendationChip(
    id: 'dailyCalendar',
    label: '일진 달력',
    fortuneType: 'daily_calendar',
    icon: Icons.calendar_month_outlined,
    color: DSFortuneColors.categoryDailyCalendar,
  ),
  RecommendationChip(
    id: 'newYear',
    label: '신년 운세',
    fortuneType: 'newYear',
    icon: Icons.celebration_outlined,
    color: DSFortuneColors.categoryNewYear,
  ),

  // ============ 연애/관계 ============
  RecommendationChip(
    id: 'love',
    label: '연애 운세',
    fortuneType: 'love',
    icon: Icons.favorite_outline,
    color: DSFortuneColors.categoryLove,
  ),
  RecommendationChip(
    id: 'compatibility',
    label: '궁합 보기',
    fortuneType: 'compatibility',
    icon: Icons.people_outline,
    color: DSFortuneColors.categoryCompatibility,
  ),
  RecommendationChip(
    id: 'exLover',
    label: '전 애인 운',
    fortuneType: 'exLover',
    icon: Icons.replay_outlined,
    color: DSFortuneColors.categoryExLover,
  ),
  RecommendationChip(
    id: 'yearlyEncounter',
    label: '올해의 인연',
    fortuneType: 'yearlyEncounter',
    icon: Icons.favorite,
    color: DSFortuneColors.categoryYearlyEncounter,
  ),
  RecommendationChip(
    id: 'blindDate',
    label: '소개팅 운',
    fortuneType: 'blindDate',
    icon: Icons.wine_bar_outlined,
    color: DSFortuneColors.categoryBlindDate,
  ),
  RecommendationChip(
    id: 'avoidPeople',
    label: '피해야 할 사람',
    fortuneType: 'avoidPeople',
    icon: Icons.warning_amber_outlined,
    color: DSFortuneColors.categoryAvoidPeople,
  ),

  // ============ 직업/재능 ============
  RecommendationChip(
    id: 'career',
    label: '직장·진로',
    fortuneType: 'career',
    icon: Icons.work_outline,
    color: DSFortuneColors.categoryCareer,
  ),
  RecommendationChip(
    id: 'talent',
    label: '숨은 재능',
    fortuneType: 'talent',
    icon: Icons.lightbulb_outline,
    color: DSFortuneColors.categoryTalent,
  ),

  // ============ 재물 ============
  RecommendationChip(
    id: 'money',
    label: '재물 운세',
    fortuneType: 'money',
    icon: Icons.attach_money,
    color: DSFortuneColors.categoryMoney,
  ),
  RecommendationChip(
    id: 'luckyItems',
    label: '행운 아이템',
    fortuneType: 'luckyItems',
    icon: Icons.auto_awesome,
    color: DSFortuneColors.categoryLuckyItems,
  ),
  RecommendationChip(
    id: 'lotto',
    label: '로또 번호',
    fortuneType: 'lotto',
    icon: Icons.casino_outlined,
    color: DSFortuneColors.categoryLotto,
  ),

  // ============ 전통/신비 ============
  RecommendationChip(
    id: 'tarot',
    label: '타로 한 장',
    fortuneType: 'tarot',
    icon: Icons.style_outlined,
    color: DSFortuneColors.categoryTarot,
  ),
  RecommendationChip(
    id: 'traditional',
    label: '사주 풀이',
    fortuneType: 'traditional',
    icon: Icons.menu_book_outlined,
    color: DSFortuneColors.categoryTraditional,
  ),
  RecommendationChip(
    id: 'faceReading',
    label: '관상 보기',
    fortuneType: 'faceReading',
    icon: Icons.face_retouching_natural,
    color: DSFortuneColors.categoryFaceReading,
  ),
  RecommendationChip(
    id: 'talisman',
    label: '부적 만들기',
    fortuneType: 'talisman',
    icon: Icons.shield_outlined,
    color: DSFortuneColors.categoryTalisman,
  ),
  RecommendationChip(
    id: 'pastLife',
    label: '전생 보기',
    fortuneType: 'pastLife',
    icon: Icons.history_edu,
    color: DSFortuneColors.categoryPastLife,
  ),

  // ============ 성격/개성 ============
  RecommendationChip(
    id: 'personalityDna',
    label: '성격 DNA',
    fortuneType: 'personalityDna',
    icon: Icons.fingerprint,
    color: DSFortuneColors.categoryPersonalityDna,
  ),
  RecommendationChip(
    id: 'biorhythm',
    label: '바이오리듬',
    fortuneType: 'biorhythm',
    icon: Icons.show_chart,
    color: DSFortuneColors.categoryBiorhythm,
  ),
  RecommendationChip(
    id: 'mbti',
    label: 'MBTI 운세',
    fortuneType: 'mbti',
    icon: Icons.psychology_outlined,
    color: DSFortuneColors.categoryMbti,
  ),

  // ============ 건강/스포츠 ============
  RecommendationChip(
    id: 'health',
    label: '건강 운세',
    fortuneType: 'health',
    icon: Icons.health_and_safety_outlined,
    color: DSFortuneColors.categoryHealth,
  ),
  RecommendationChip(
    id: 'exercise',
    label: '운동 운세',
    fortuneType: 'exercise',
    icon: Icons.fitness_center,
    color: DSFortuneColors.categoryExercise,
  ),
  RecommendationChip(
    id: 'sportsGame',
    label: '경기 승부',
    fortuneType: 'sportsGame',
    icon: Icons.sports_soccer,
    color: DSFortuneColors.categorySportsGame,
  ),

  // ============ 인터랙티브 ============
  RecommendationChip(
    id: 'gameEnhance',
    label: '게임 강화운',
    fortuneType: 'gameEnhance',
    icon: Icons.rocket_launch_outlined,
    color: DSFortuneColors.categoryGameEnhance,
  ),
  RecommendationChip(
    id: 'dream',
    label: '꿈해몽',
    fortuneType: 'dream',
    icon: Icons.cloud_outlined,
    color: DSFortuneColors.categoryDream,
  ),
  RecommendationChip(
    id: 'wish',
    label: '소원 빌기',
    fortuneType: 'wish',
    icon: Icons.star_outline,
    color: DSFortuneColors.categoryWish,
  ),
  RecommendationChip(
    id: 'fortuneCookie',
    label: '포춘쿠키',
    fortuneType: 'fortuneCookie',
    icon: Icons.cookie_outlined,
    color: DSFortuneColors.categoryFortuneCookie,
  ),
  RecommendationChip(
    id: 'celebrity',
    label: '닮은 셀럽',
    fortuneType: 'celebrity',
    icon: Icons.star,
    color: DSFortuneColors.categoryCelebrity,
  ),

  // ============ 가족/반려동물 ============
  RecommendationChip(
    id: 'family',
    label: '가족 궁합',
    fortuneType: 'family',
    icon: Icons.family_restroom,
    color: DSFortuneColors.categoryFamily,
  ),
  RecommendationChip(
    id: 'pet',
    label: '펫 궁합',
    fortuneType: 'pet',
    icon: Icons.pets,
    color: DSFortuneColors.categoryPet,
  ),
  RecommendationChip(
    id: 'naming',
    label: '이름 짓기',
    fortuneType: 'naming',
    icon: Icons.edit_note,
    color: DSFortuneColors.categoryNaming,
  ),

  // ============ 스타일/패션 ============
  RecommendationChip(
    id: 'ootdEvaluation',
    label: '코디 점수',
    fortuneType: 'ootdEvaluation',
    icon: Icons.checkroom,
    color: DSFortuneColors.categoryOotd,
  ),

  // ============ 실용/결정 ============
  RecommendationChip(
    id: 'exam',
    label: '시험 운세',
    fortuneType: 'exam',
    icon: Icons.school_outlined,
    color: DSFortuneColors.categoryExam,
  ),
  RecommendationChip(
    id: 'moving',
    label: '이사 운세',
    fortuneType: 'moving',
    icon: Icons.home_outlined,
    color: DSFortuneColors.categoryMoving,
  ),

  // ============ 웰니스 ============
  RecommendationChip(
    id: 'breathing',
    label: '명상 가이드',
    fortuneType: 'breathing',
    icon: Icons.self_improvement_outlined,
    color: DSFortuneColors.categoryBreathing,
  ),
  RecommendationChip(
    id: 'gratitude',
    label: '감사 일기',
    fortuneType: 'gratitude',
    icon: Icons.favorite_outline,
    color: DSFortuneColors.categoryGratitude,
  ),

  // ============ AI 코칭/저널링 ============
  RecommendationChip(
    id: 'coaching',
    label: 'AI 코칭',
    fortuneType: 'coaching',
    icon: Icons.psychology_outlined,
    color: DSFortuneColors.categoryCoaching,
  ),
  RecommendationChip(
    id: 'decision',
    label: '고민 해결',
    fortuneType: 'decision',
    icon: Icons.balance_outlined,
    color: DSFortuneColors.categoryDecision,
  ),
  RecommendationChip(
    id: 'dailyReview',
    label: '하루 정리',
    fortuneType: 'daily_review',
    icon: Icons.edit_note_outlined,
    color: DSFortuneColors.categoryDailyReview,
  ),
  RecommendationChip(
    id: 'weeklyReview',
    label: '주간 리뷰',
    fortuneType: 'weekly_review',
    icon: Icons.calendar_view_week_outlined,
    color: DSFortuneColors.categoryWeeklyReview,
  ),
];

/// 추가 추천 칩 (컨텍스트 기반 선택용) - deprecated, defaultChips에 통합됨
const List<RecommendationChip> additionalChips = [];

/// 시작 화면 초기 칩 (5개 표시) - 카톡 분석 + AI 코칭 중심으로 재배치
const List<RecommendationChip> initialChips = [
  RecommendationChip(
    id: 'chatInsight',
    label: '카톡 대화 분석',
    fortuneType: 'chatInsight',
    icon: Icons.forum_outlined,
    color: DSFortuneColors.categoryChatInsight,
  ),
  RecommendationChip(
    id: 'coaching',
    label: 'AI 코칭',
    fortuneType: 'coaching',
    icon: Icons.psychology_outlined,
    color: DSFortuneColors.categoryCoaching,
  ),
  RecommendationChip(
    id: 'daily',
    label: '오늘의 운세',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: DSFortuneColors.categoryDaily,
  ),
  RecommendationChip(
    id: 'gratitude',
    label: '감사 일기',
    fortuneType: 'gratitude',
    icon: Icons.favorite_outline,
    color: DSFortuneColors.categoryGratitude,
  ),
  RecommendationChip(
    id: 'viewAll',
    label: '전체 보기',
    fortuneType: 'viewAll',
    icon: Icons.apps_outlined,
    color: DSFortuneColors.categoryViewAll,
  ),
];
