import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 팁 태그 그리드 위젯
///
/// 긴 팁 텍스트를 아이콘 + 짧은 라벨의 컬러 태그로 표시합니다.
/// 인포그래픽에서 텍스트 오버플로우 없이 정보를 규격화하여 보여줍니다.
class TipTagGrid extends StatefulWidget {
  const TipTagGrid({
    super.key,
    required this.tips,
    this.maxVisibleTags = 6,
    this.spacing = DSSpacing.xs,
    this.runSpacing = DSSpacing.xs,
    this.alignment = WrapAlignment.center,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  /// 팁 데이터 목록
  final List<TipTagData> tips;

  /// 최대 표시 태그 수
  final int maxVisibleTags;

  /// 태그 간 가로 간격
  final double spacing;

  /// 태그 간 세로 간격
  final double runSpacing;

  /// 정렬 방식
  final WrapAlignment alignment;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  /// 순차 등장 딜레이
  final Duration staggerDelay;

  @override
  State<TipTagGrid> createState() => _TipTagGridState();
}

class _TipTagGridState extends State<TipTagGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final visibleCount = widget.tips.length.clamp(0, widget.maxVisibleTags);
    _controller = AnimationController(
      duration:
          widget.animationDuration + (widget.staggerDelay * visibleCount),
      vsync: this,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTips = widget.tips.take(widget.maxVisibleTags).toList();

    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      alignment: widget.alignment,
      children: visibleTips.asMap().entries.map((entry) {
        final index = entry.key;
        final tip = entry.value;

        if (!widget.animate) {
          return _TipTag(tip: tip);
        }

        final startTime = index * widget.staggerDelay.inMilliseconds /
            _controller.duration!.inMilliseconds;
        final endTime = startTime +
            widget.animationDuration.inMilliseconds /
                _controller.duration!.inMilliseconds;

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            startTime.clamp(0.0, 1.0),
            endTime.clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: Opacity(
                opacity: animation.value,
                child: child,
              ),
            );
          },
          child: _TipTag(tip: tip),
        );
      }).toList(),
    );
  }
}

/// 개별 팁 태그
class _TipTag extends StatelessWidget {
  const _TipTag({required this.tip});

  final TipTagData tip;

  @override
  Widget build(BuildContext context) {
    final categoryStyle = tip.category.style;
    final color = tip.color ?? categoryStyle.color;
    final icon = tip.icon ?? categoryStyle.icon;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            tip.label,
            style: context.typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 팁 태그 데이터
class TipTagData {
  const TipTagData({
    required this.label,
    required this.category,
    this.icon,
    this.color,
    this.fullText,
  });

  /// 짧은 라벨 (최대 10자 권장)
  final String label;

  /// 카테고리 (아이콘/색상 자동 매핑)
  final TipCategory category;

  /// 커스텀 아이콘 (선택)
  final IconData? icon;

  /// 커스텀 색상 (선택)
  final Color? color;

  /// 원본 긴 텍스트 (선택, 참조용)
  final String? fullText;

  /// 문자열에서 팁 생성 (자동 카테고리 감지)
  factory TipTagData.fromText(String text) {
    return TipTextMapper.mapTip(text);
  }
}

/// 팁 카테고리
enum TipCategory {
  /// 연애/감정 관련
  love,

  /// 직업/협업 관련
  career,

  /// 건강/운동 관련
  health,

  /// 재정/금전 관련
  money,

  /// 시간/타이밍 관련
  timing,

  /// 경고/주의 관련
  warning,

  /// 긍정/행운 관련
  positive,

  /// 행동/실행 관련
  action,

  /// 기타/일반
  general,
}

/// 카테고리별 스타일
extension TipCategoryStyle on TipCategory {
  _CategoryStyle get style {
    switch (this) {
      case TipCategory.love:
        return const _CategoryStyle(
          icon: Icons.favorite_rounded,
          color: DSFortuneColors.categoryLove,
        );
      case TipCategory.career:
        return const _CategoryStyle(
          icon: Icons.work_rounded,
          color: DSFortuneColors.categoryCareer,
        );
      case TipCategory.health:
        return const _CategoryStyle(
          icon: Icons.fitness_center_rounded,
          color: DSFortuneColors.categoryHealth,
        );
      case TipCategory.money:
        return const _CategoryStyle(
          icon: Icons.monetization_on_rounded,
          color: DSFortuneColors.categoryMoney,
        );
      case TipCategory.timing:
        return const _CategoryStyle(
          icon: Icons.schedule_rounded,
          color: DSFortuneColors.mysticalPurple,
        );
      case TipCategory.warning:
        return const _CategoryStyle(
          icon: Icons.warning_rounded,
          color: DSFortuneColors.sealVermilion,
        );
      case TipCategory.positive:
        return const _CategoryStyle(
          icon: Icons.star_rounded,
          color: DSFortuneColors.categoryGratitude,
        );
      case TipCategory.action:
        return const _CategoryStyle(
          icon: Icons.arrow_forward_rounded,
          color: DSFortuneColors.categoryFaceReading,
        );
      case TipCategory.general:
        return const _CategoryStyle(
          icon: Icons.lightbulb_rounded,
          color: DSFortuneColors.celebrityPolitician,
        );
    }
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

/// 팁 텍스트 매퍼
///
/// 긴 팁 텍스트를 짧은 라벨 + 카테고리로 변환합니다.
class TipTextMapper {
  TipTextMapper._();

  /// 긴 텍스트를 TipTagData로 변환
  static TipTagData mapTip(String text) {
    // 미리 정의된 매핑 확인
    final predefined = _predefinedMappings[text];
    if (predefined != null) return predefined;

    // 키워드 기반 카테고리 감지
    final category = _detectCategory(text);
    final label = _extractLabel(text, category);

    return TipTagData(
      label: label,
      category: category,
      fullText: text,
    );
  }

  /// 여러 텍스트를 한번에 변환
  static List<TipTagData> mapTips(List<String> texts) {
    return texts.map(mapTip).toList();
  }

  /// 카테고리 감지
  static TipCategory _detectCategory(String text) {
    final lowerText = text.toLowerCase();

    // 연애/감정
    if (_containsAny(lowerText, ['감정', '사랑', '연애', '마음', '표현', '소통', '대화'])) {
      return TipCategory.love;
    }

    // 직업/협업
    if (_containsAny(lowerText, ['업무', '직장', '협업', '회의', '프로젝트', '일', '커리어'])) {
      return TipCategory.career;
    }

    // 건강/운동
    if (_containsAny(lowerText, ['건강', '운동', '휴식', '수면', '스트레스', '체력', '몸'])) {
      return TipCategory.health;
    }

    // 재정/금전
    if (_containsAny(lowerText, ['돈', '재정', '투자', '지출', '수입', '저축', '금전'])) {
      return TipCategory.money;
    }

    // 시간/타이밍
    if (_containsAny(lowerText, ['오전', '오후', '저녁', '시간', '타이밍', '때', '기다'])) {
      return TipCategory.timing;
    }

    // 경고/주의
    if (_containsAny(lowerText, ['주의', '조심', '피하', '갈등', '구설', '위험', '경계'])) {
      return TipCategory.warning;
    }

    // 행동/실행
    if (_containsAny(lowerText, ['실행', '행동', '결단', '도전', '시작', '결정', '움직'])) {
      return TipCategory.action;
    }

    // 긍정/행운
    if (_containsAny(lowerText, ['행운', '기회', '좋은', '긍정', '성공', '발전', '희망'])) {
      return TipCategory.positive;
    }

    return TipCategory.general;
  }

  /// 라벨 추출
  static String _extractLabel(String text, TipCategory category) {
    // 카테고리별 키워드 매핑
    final keywordMap = _categoryKeywords[category] ?? {};

    for (final entry in keywordMap.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    // 키워드 없으면 첫 8자
    final cleanText = text.replaceAll(RegExp(r'[.,!?~]'), '').trim();
    if (cleanText.length <= 8) return cleanText;
    return '${cleanText.substring(0, 6)}..';
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// 미리 정의된 매핑
  static final Map<String, TipTagData> _predefinedMappings = {
    // 연애/감정
    '감정을 솔직하게 표현하세요': const TipTagData(
        label: '감정표현', category: TipCategory.love),
    '대화로 오해를 풀어보세요': const TipTagData(
        label: '소통강화', category: TipCategory.love),
    '상대방의 이야기를 경청하세요': const TipTagData(
        label: '경청하기', category: TipCategory.love),
    '먼저 연락해보세요': const TipTagData(
        label: '먼저연락', category: TipCategory.love),

    // 직업/협업
    '협업 시 의사소통에 주의하세요': const TipTagData(
        label: '협업주의', category: TipCategory.career),
    '회의 전 충분히 준비하세요': const TipTagData(
        label: '회의준비', category: TipCategory.career),
    '업무 우선순위를 정리하세요': const TipTagData(
        label: '우선순위', category: TipCategory.career),
    '새로운 프로젝트에 도전해보세요': const TipTagData(
        label: '새도전', category: TipCategory.career),

    // 건강/운동
    '오늘은 운동을 추천합니다': const TipTagData(
        label: '운동권장', category: TipCategory.health),
    '충분한 휴식이 필요합니다': const TipTagData(
        label: '휴식필요', category: TipCategory.health),
    '수분 섭취를 늘려보세요': const TipTagData(
        label: '수분섭취', category: TipCategory.health),
    '스트레칭으로 하루를 시작하세요': const TipTagData(
        label: '스트레칭', category: TipCategory.health),

    // 재정/금전
    '지출을 점검해보세요': const TipTagData(
        label: '지출점검', category: TipCategory.money),
    '충동구매를 피하세요': const TipTagData(
        label: '충동구매주의', category: TipCategory.money),
    '저축 계획을 세워보세요': const TipTagData(
        label: '저축계획', category: TipCategory.money),
    '투자는 신중하게 결정하세요': const TipTagData(
        label: '신중투자', category: TipCategory.money),

    // 시간/타이밍
    '중요한 결정은 오후에 하세요': const TipTagData(
        label: '오후결정', category: TipCategory.timing),
    '오전에 중요한 일을 처리하세요': const TipTagData(
        label: '오전집중', category: TipCategory.timing),
    '저녁 시간을 활용하세요': const TipTagData(
        label: '저녁활용', category: TipCategory.timing),
    '서두르지 말고 천천히 진행하세요': const TipTagData(
        label: '천천히', category: TipCategory.timing),

    // 경고/주의
    '구설수에 주의하세요': const TipTagData(
        label: '구설주의', category: TipCategory.warning),
    '갈등 상황을 피하세요': const TipTagData(
        label: '갈등회피', category: TipCategory.warning),
    '과로하지 않도록 주의하세요': const TipTagData(
        label: '과로주의', category: TipCategory.warning),
    '급한 결정은 피하세요': const TipTagData(
        label: '급결정주의', category: TipCategory.warning),

    // 긍정/행운
    '좋은 기회가 올 수 있습니다': const TipTagData(
        label: '기회포착', category: TipCategory.positive),
    '긍정적인 마인드를 유지하세요': const TipTagData(
        label: '긍정마인드', category: TipCategory.positive),
    '오늘은 행운이 따릅니다': const TipTagData(
        label: '행운의날', category: TipCategory.positive),

    // 행동/실행
    '과감하게 도전해보세요': const TipTagData(
        label: '과감도전', category: TipCategory.action),
    '망설이지 말고 실행하세요': const TipTagData(
        label: '즉시실행', category: TipCategory.action),
    '새로운 시도를 두려워하지 마세요': const TipTagData(
        label: '새시도', category: TipCategory.action),
  };

  /// 카테고리별 키워드 → 라벨 매핑
  static final Map<TipCategory, Map<String, String>> _categoryKeywords = {
    TipCategory.love: {
      '감정': '감정표현',
      '표현': '감정표현',
      '소통': '소통강화',
      '대화': '대화하기',
      '경청': '경청하기',
      '연락': '연락하기',
      '사랑': '사랑표현',
      '마음': '마음전달',
    },
    TipCategory.career: {
      '협업': '협업주의',
      '회의': '회의준비',
      '업무': '업무집중',
      '우선순위': '우선순위',
      '프로젝트': '프로젝트',
      '도전': '새도전',
      '커리어': '커리어',
    },
    TipCategory.health: {
      '운동': '운동권장',
      '휴식': '휴식필요',
      '수면': '숙면하기',
      '스트레스': '스트레스관리',
      '건강': '건강관리',
      '체력': '체력관리',
    },
    TipCategory.money: {
      '지출': '지출점검',
      '저축': '저축하기',
      '투자': '투자검토',
      '수입': '수입관리',
      '돈': '금전관리',
    },
    TipCategory.timing: {
      '오전': '오전집중',
      '오후': '오후활용',
      '저녁': '저녁활용',
      '시간': '시간관리',
      '타이밍': '타이밍',
    },
    TipCategory.warning: {
      '주의': '주의필요',
      '조심': '조심하기',
      '피하': '피하기',
      '갈등': '갈등회피',
      '구설': '구설주의',
    },
    TipCategory.positive: {
      '기회': '기회포착',
      '행운': '행운의날',
      '긍정': '긍정마인드',
      '성공': '성공예감',
      '발전': '발전기회',
    },
    TipCategory.action: {
      '실행': '실행하기',
      '도전': '도전하기',
      '결단': '결단하기',
      '시작': '시작하기',
      '행동': '행동하기',
    },
  };
}
