import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/extensions/l10n_extension.dart';

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

  /// l10n으로 변환된 칩 라벨 반환 (fallback: label 필드)
  String getLocalizedLabel(BuildContext context) {
    return _chipLabelMap(context)[id] ?? label;
  }

  /// l10n으로 변환된 칩 subtitle 반환
  String? getLocalizedSubtitle(BuildContext context) {
    return subtitle;
  }

  /// id → l10n 라벨 매핑
  static Map<String, String> _chipLabelMap(BuildContext context) {
    final l10n = context.l10n;
    return {
      // 시간 기반
      'daily': l10n.fortuneDaily,
      'daily-calendar': l10n.fortuneDailyCalendar,
      'new-year': l10n.fortuneNewYear,
      // 연애/관계
      'love': l10n.fortuneLove,
      'compatibility': l10n.fortuneCompatibility,
      'ex-lover': l10n.fortuneExLover,
      'yearly-encounter': l10n.fortuneYearlyEncounter,
      'blind-date': l10n.fortuneBlindDate,
      'avoid-people': l10n.fortuneAvoidPeople,
      // 직업/재능
      'career': l10n.fortuneCareer,
      'talent': l10n.fortuneTalent,
      // 재물
      'wealth': l10n.fortuneWealth,
      'lucky-items': l10n.fortuneLuckyItems,
      'lotto': l10n.fortuneLuckyLottery,
      // 전통/신비
      'tarot': l10n.fortuneTarot,
      'traditional-saju': l10n.fortuneTraditional,
      'face-reading': l10n.fortuneFaceReading,
      'talisman': l10n.fortuneTalisman,
      'past-life': l10n.fortunePastLife,
      // 성격/개성
      'personality-dna': l10n.fortunePersonalityDna,
      'biorhythm': l10n.fortuneBiorhythm,
      'mbti': l10n.fortuneMbti,
      // 건강/스포츠
      'health': l10n.fortuneHealth,
      'exercise': l10n.fortuneExercise,
      'match-insight': l10n.fortuneSportsGame,
      // 인터랙티브
      'game-enhance': l10n.fortuneGameEnhance,
      'dream': l10n.fortuneDream,
      'wish': l10n.fortuneWish,
      'fortune-cookie': l10n.fortuneFortuneCookie,
      'celebrity': l10n.fortuneCelebrity,
      // 가족/반려동물
      'family': l10n.fortuneFamily,
      'pet-compatibility': l10n.fortunePet,
      'naming': l10n.fortuneNaming,
      'baby-nickname': l10n.fortuneBabyNickname,
      // 스타일
      'ootd-evaluation': l10n.fortuneOotdEvaluation,
      // 실용/결정
      'exam': l10n.fortuneLuckyExam,
      'moving': l10n.fortuneMoving,
      // 웰니스
      'breathing': l10n.fortuneBreathing,
      'gratitude': l10n.fortuneGratitude,
      // AI 코칭/저널링
      'coaching': l10n.fortuneCoaching,
      'decision': l10n.fortuneDecisionHelper,
      'daily-review': l10n.fortuneDailyReview,
      'weekly-review': l10n.fortuneWeeklyReview,
      // 초기 칩
      'chat-insight': l10n.fortuneChatInsight,
      'view-all': l10n.chipViewAll,
    };
  }
}

/// 기본 추천 칩 목록 (전체 인사이트)
const List<RecommendationChip> defaultChips = [
  // ============ 시간 기반 ============
  RecommendationChip(
    id: 'daily',
    label: '오늘의 운세',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'daily-calendar',
    label: '일진 달력',
    fortuneType: 'daily-calendar',
    icon: Icons.calendar_month_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'new-year',
    label: '신년 운세',
    fortuneType: 'new-year',
    icon: Icons.celebration_outlined,
    color: DSColors.accentSecondary,
  ),

  // ============ 연애/관계 ============
  RecommendationChip(
    id: 'love',
    label: '연애 운세',
    fortuneType: 'love',
    icon: Icons.favorite_outline,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'compatibility',
    label: '궁합 보기',
    fortuneType: 'compatibility',
    icon: Icons.people_outline,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'ex-lover',
    label: '전 애인 운',
    fortuneType: 'ex-lover',
    icon: Icons.replay_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'yearly-encounter',
    label: '올해의 인연',
    fortuneType: 'yearly-encounter',
    icon: Icons.favorite,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'blind-date',
    label: '소개팅 운',
    fortuneType: 'blind-date',
    icon: Icons.wine_bar_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'avoid-people',
    label: '피해야 할 사람',
    fortuneType: 'avoid-people',
    icon: Icons.warning_amber_outlined,
    color: DSColors.accentSecondary,
  ),

  // ============ 직업/재능 ============
  RecommendationChip(
    id: 'career',
    label: '직장·진로',
    fortuneType: 'career',
    icon: Icons.work_outline,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'talent',
    label: '숨은 재능',
    fortuneType: 'talent',
    icon: Icons.lightbulb_outline,
    color: DSColors.accentSecondary,
  ),

  // ============ 재물 ============
  RecommendationChip(
    id: 'wealth',
    label: '재물 운세',
    fortuneType: 'wealth',
    icon: Icons.attach_money,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'lucky-items',
    label: '행운 아이템',
    fortuneType: 'lucky-items',
    icon: Icons.auto_awesome,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'lotto',
    label: '로또 번호',
    fortuneType: 'lotto',
    icon: Icons.casino_outlined,
    color: DSColors.accentSecondary,
  ),

  // ============ 전통/신비 ============
  RecommendationChip(
    id: 'tarot',
    label: '타로 한 장',
    fortuneType: 'tarot',
    icon: Icons.style_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'traditional-saju',
    label: '사주 풀이',
    fortuneType: 'traditional-saju',
    icon: Icons.menu_book_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'face-reading',
    label: '관상 보기',
    fortuneType: 'face-reading',
    icon: Icons.face_retouching_natural,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'talisman',
    label: '부적 만들기',
    fortuneType: 'talisman',
    icon: Icons.shield_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'past-life',
    label: '전생 보기',
    fortuneType: 'past-life',
    icon: Icons.history_edu,
    color: DSColors.accentSecondary,
  ),

  // ============ 성격/개성 ============
  RecommendationChip(
    id: 'personality-dna',
    label: '성격 DNA',
    fortuneType: 'personality-dna',
    icon: Icons.fingerprint,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'biorhythm',
    label: '바이오리듬',
    fortuneType: 'biorhythm',
    icon: Icons.show_chart,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'mbti',
    label: 'MBTI 운세',
    fortuneType: 'mbti',
    icon: Icons.psychology_outlined,
    color: DSColors.accentSecondary,
  ),

  // ============ 건강/스포츠 ============
  RecommendationChip(
    id: 'health',
    label: '건강 운세',
    fortuneType: 'health',
    icon: Icons.health_and_safety_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'exercise',
    label: '운동 운세',
    fortuneType: 'exercise',
    icon: Icons.fitness_center,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'match-insight',
    label: '경기 승부',
    fortuneType: 'match-insight',
    icon: Icons.sports_soccer,
    color: DSColors.accentSecondary,
  ),

  // ============ 인터랙티브 ============
  RecommendationChip(
    id: 'game-enhance',
    label: '게임 강화운',
    fortuneType: 'game-enhance',
    icon: Icons.rocket_launch_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'dream',
    label: '꿈해몽',
    fortuneType: 'dream',
    icon: Icons.cloud_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'wish',
    label: '소원 빌기',
    fortuneType: 'wish',
    icon: Icons.star_outline,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'fortune-cookie',
    label: '포춘쿠키',
    fortuneType: 'fortune-cookie',
    icon: Icons.cookie_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'celebrity',
    label: '닮은 셀럽',
    fortuneType: 'celebrity',
    icon: Icons.star,
    color: DSColors.accentSecondary,
  ),

  // ============ 가족/반려동물 ============
  RecommendationChip(
    id: 'family',
    label: '가족 궁합',
    fortuneType: 'family',
    icon: Icons.family_restroom,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'pet-compatibility',
    label: '펫 궁합',
    fortuneType: 'pet-compatibility',
    icon: Icons.pets,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'naming',
    label: '이름 짓기',
    fortuneType: 'naming',
    icon: Icons.edit_note,
    color: DSColors.accentSecondary,
  ),

  // ============ 스타일/패션 ============
  RecommendationChip(
    id: 'ootd-evaluation',
    label: '코디 점수',
    fortuneType: 'ootd-evaluation',
    icon: Icons.checkroom,
    color: DSColors.accentSecondary,
  ),

  // ============ 실용/결정 ============
  RecommendationChip(
    id: 'exam',
    label: '시험 운세',
    fortuneType: 'exam',
    icon: Icons.school_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'moving',
    label: '이사 운세',
    fortuneType: 'moving',
    icon: Icons.home_outlined,
    color: DSColors.accentSecondary,
  ),

  // ============ 웰니스 ============
  RecommendationChip(
    id: 'breathing',
    label: '명상 가이드',
    fortuneType: 'breathing',
    icon: Icons.self_improvement_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'gratitude',
    label: '감사 일기',
    fortuneType: 'gratitude',
    icon: Icons.favorite_outline,
    color: DSColors.accentSecondary,
  ),

  // ============ AI 코칭/저널링 ============
  RecommendationChip(
    id: 'coaching',
    label: 'AI 코칭',
    fortuneType: 'coaching',
    icon: Icons.psychology_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'decision',
    label: '고민 해결',
    fortuneType: 'decision',
    icon: Icons.balance_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'daily-review',
    label: '하루 정리',
    fortuneType: 'daily-review',
    icon: Icons.edit_note_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'weekly-review',
    label: '주간 리뷰',
    fortuneType: 'weekly-review',
    icon: Icons.calendar_view_week_outlined,
    color: DSColors.accentSecondary,
  ),
];

/// 추가 추천 칩 (컨텍스트 기반 선택용) - deprecated, defaultChips에 통합됨
const List<RecommendationChip> additionalChips = [];

/// 시작 화면 초기 칩 (5개 표시) - 카톡 분석 + AI 코칭 중심으로 재배치
const List<RecommendationChip> initialChips = [
  RecommendationChip(
    id: 'chat-insight',
    label: '카톡 대화 분석',
    fortuneType: 'chat-insight',
    icon: Icons.forum_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'coaching',
    label: 'AI 코칭',
    fortuneType: 'coaching',
    icon: Icons.psychology_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'daily',
    label: '오늘의 운세',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'gratitude',
    label: '감사 일기',
    fortuneType: 'gratitude',
    icon: Icons.favorite_outline,
    color: DSColors.accentSecondary,
  ),
  RecommendationChip(
    id: 'view-all',
    label: '전체 보기',
    fortuneType: 'view-all',
    icon: Icons.apps_outlined,
    color: DSColors.accentSecondary,
  ),
];
