import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/ds_fortune_colors.dart';

/// 인생 컨설팅 대분류 카테고리
enum LifeCategory {
  /// 연애/관계
  loveRelationship(
    'love_relationship',
    '연애/관계',
    Icons.favorite_rounded,
    DSFortuneColors.categoryLove,
  ),

  /// 돈/재정
  moneyFinance(
    'money_finance',
    '돈/재정',
    Icons.attach_money_rounded,
    DSFortuneColors.categoryMoney,
  ),

  /// 커리어/학업
  careerStudy(
    'career_study',
    '커리어/학업',
    Icons.work_rounded,
    DSFortuneColors.categoryCareer,
  ),

  /// 건강/웰빙
  healthWellness(
    'health_wellness',
    '건강/웰빙',
    Icons.health_and_safety_rounded,
    DSFortuneColors.categoryHealth,
  );

  const LifeCategory(this.value, this.label, this.icon, this.color);

  /// DB 저장용 값
  final String value;

  /// UI 표시용 라벨
  final String label;

  /// 아이콘
  final IconData icon;

  /// 테마 색상
  final Color color;

  /// value로부터 LifeCategory 찾기
  static LifeCategory? fromValue(String? value) {
    if (value == null) return null;
    return LifeCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => LifeCategory.loveRelationship,
    );
  }
}

/// 세부 고민 데이터
class SubConcern {
  final String id;
  final String label;
  final LifeCategory category;

  const SubConcern({
    required this.id,
    required this.label,
    required this.category,
  });
}

/// 카테고리별 세부 고민 목록
const Map<LifeCategory, List<SubConcern>> subConcernsByCategory = {
  LifeCategory.loveRelationship: [
    SubConcern(
      id: 'currently_dating',
      label: '현재 연애중',
      category: LifeCategory.loveRelationship,
    ),
    SubConcern(
      id: 'seeking_new_love',
      label: '새로운 만남',
      category: LifeCategory.loveRelationship,
    ),
    SubConcern(
      id: 'breakup_reunion',
      label: '이별/재회',
      category: LifeCategory.loveRelationship,
    ),
    SubConcern(
      id: 'marriage_longterm',
      label: '결혼/장기관계',
      category: LifeCategory.loveRelationship,
    ),
    SubConcern(
      id: 'family_relations',
      label: '가족관계',
      category: LifeCategory.loveRelationship,
    ),
  ],
  LifeCategory.moneyFinance: [
    SubConcern(
      id: 'investment',
      label: '투자/재테크',
      category: LifeCategory.moneyFinance,
    ),
    SubConcern(
      id: 'job_income',
      label: '취업/수입',
      category: LifeCategory.moneyFinance,
    ),
    SubConcern(
      id: 'saving_spending',
      label: '절약/지출관리',
      category: LifeCategory.moneyFinance,
    ),
    SubConcern(
      id: 'business',
      label: '창업/사업',
      category: LifeCategory.moneyFinance,
    ),
    SubConcern(
      id: 'debt_crisis',
      label: '빚/재정위기',
      category: LifeCategory.moneyFinance,
    ),
  ],
  LifeCategory.careerStudy: [
    SubConcern(
      id: 'job_change',
      label: '이직/전직',
      category: LifeCategory.careerStudy,
    ),
    SubConcern(
      id: 'promotion',
      label: '승진/성장',
      category: LifeCategory.careerStudy,
    ),
    SubConcern(
      id: 'exam_certification',
      label: '시험/자격증',
      category: LifeCategory.careerStudy,
    ),
    SubConcern(
      id: 'career_path',
      label: '진로고민',
      category: LifeCategory.careerStudy,
    ),
    SubConcern(
      id: 'workplace_relations',
      label: '직장관계',
      category: LifeCategory.careerStudy,
    ),
  ],
  LifeCategory.healthWellness: [
    SubConcern(
      id: 'physical_health',
      label: '신체건강',
      category: LifeCategory.healthWellness,
    ),
    SubConcern(
      id: 'mental_stress',
      label: '정신건강/스트레스',
      category: LifeCategory.healthWellness,
    ),
    SubConcern(
      id: 'diet_exercise',
      label: '다이어트/운동',
      category: LifeCategory.healthWellness,
    ),
    SubConcern(
      id: 'sleep_rest',
      label: '수면/휴식',
      category: LifeCategory.healthWellness,
    ),
    SubConcern(
      id: 'lifestyle',
      label: '생활습관',
      category: LifeCategory.healthWellness,
    ),
  ],
};
