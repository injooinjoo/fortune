import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/tokens/ds_colors.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 조언 태그 위젯
///
/// 긴 조언 텍스트를 핵심 키워드 하나로 표시합니다.
/// 인포그래픽에서 텍스트 오버플로우 없이 조언을 규격화하여 보여줍니다.
class AdviceTag extends StatelessWidget {
  const AdviceTag({
    super.key,
    required this.keyword,
    this.icon,
    this.sentiment = AdviceSentiment.neutral,
    this.size = AdviceTagSize.medium,
    this.showQuotes = true,
    this.animate = true,
  });

  /// 핵심 키워드 (최대 12자 권장)
  final String keyword;

  /// 아이콘 (선택, 기본값은 sentiment에 따라 결정)
  final IconData? icon;

  /// 감정/톤
  final AdviceSentiment sentiment;

  /// 태그 크기
  final AdviceTagSize size;

  /// 따옴표 표시 여부
  final bool showQuotes;

  /// 애니메이션 활성화
  final bool animate;

  /// 긴 텍스트에서 AdviceTag 생성
  factory AdviceTag.fromText(
    String text, {
    AdviceTagSize size = AdviceTagSize.medium,
    bool showQuotes = true,
    bool animate = true,
  }) {
    final mapped = AdviceTextMapper.mapAdvice(text);
    return AdviceTag(
      keyword: mapped.keyword,
      sentiment: mapped.sentiment,
      size: size,
      showQuotes: showQuotes,
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _getDefaultIcon();
    final color = _getSentimentColor(context);

    final padding = switch (size) {
      AdviceTagSize.small => const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xs,
        ),
      AdviceTagSize.medium => const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
      AdviceTagSize.large => const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
    };

    final iconSize = switch (size) {
      AdviceTagSize.small => 14.0,
      AdviceTagSize.medium => 18.0,
      AdviceTagSize.large => 24.0,
    };

    final textStyle = switch (size) {
      AdviceTagSize.small => context.typography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      AdviceTagSize.medium => context.typography.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
      AdviceTagSize.large => context.typography.headingSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        ),
    };

    final displayText = showQuotes ? '"$keyword"' : keyword;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: DSRadius.mdBorder,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            effectiveIcon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: DSSpacing.xs),
          Flexible(
            child: Text(
              displayText,
              style: textStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (!animate) return content;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: content,
    );
  }

  IconData _getDefaultIcon() {
    return switch (sentiment) {
      AdviceSentiment.positive => Icons.auto_awesome_rounded,
      AdviceSentiment.neutral => Icons.lightbulb_rounded,
      AdviceSentiment.caution => Icons.info_rounded,
      AdviceSentiment.warning => Icons.warning_rounded,
    };
  }

  Color _getSentimentColor(BuildContext context) {
    return switch (sentiment) {
      AdviceSentiment.positive => context.colors.success,
      AdviceSentiment.neutral => context.colors.accent,
      AdviceSentiment.caution => DSColors.warning, // Orange - 주의 톤
      AdviceSentiment.warning => context.colors.error,
    };
  }
}

/// 조언 감정/톤
enum AdviceSentiment {
  /// 긍정적 조언
  positive,

  /// 중립적 조언
  neutral,

  /// 주의 필요
  caution,

  /// 경고
  warning,
}

/// 조언 태그 크기
enum AdviceTagSize {
  small,
  medium,
  large,
}

/// 조언 텍스트 매퍼
///
/// 긴 조언 텍스트를 핵심 키워드 + 감정으로 변환합니다.
class AdviceTextMapper {
  AdviceTextMapper._();

  /// 긴 텍스트를 매핑된 데이터로 변환
  static AdviceData mapAdvice(String text) {
    // 미리 정의된 매핑 확인
    final predefined = _predefinedMappings[text];
    if (predefined != null) return predefined;

    // 감정 감지
    final sentiment = _detectSentiment(text);
    final keyword = _extractKeyword(text);

    return AdviceData(
      keyword: keyword,
      sentiment: sentiment,
      fullText: text,
    );
  }

  /// 감정 감지
  static AdviceSentiment _detectSentiment(String text) {
    final lowerText = text.toLowerCase();

    // 경고 키워드
    if (_containsAny(lowerText, ['주의', '경고', '위험', '피하', '조심'])) {
      return AdviceSentiment.warning;
    }

    // 주의 키워드
    if (_containsAny(lowerText, ['신중', '천천히', '기다', '지켜봐'])) {
      return AdviceSentiment.caution;
    }

    // 긍정 키워드
    if (_containsAny(
        lowerText, ['좋은', '행운', '기회', '성공', '발전', '긍정', '도전'])) {
      return AdviceSentiment.positive;
    }

    return AdviceSentiment.neutral;
  }

  /// 키워드 추출
  static String _extractKeyword(String text) {
    // 키워드 매핑 확인
    for (final entry in _keywordMappings.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    // 없으면 첫 핵심 단어 추출 (최대 8자)
    final cleanText = text.replaceAll(RegExp(r'[.,!?~]'), '').trim();
    final words = cleanText.split(' ');

    // 조사/어미 제거 후 가장 의미있는 단어 찾기
    for (final word in words) {
      if (word.length >= 2 && word.length <= 8) {
        // 불용어 제외
        if (!_stopWords.contains(word)) {
          return word;
        }
      }
    }

    // 기본값
    if (cleanText.length <= 10) return cleanText;
    return '${cleanText.substring(0, 8)}..';
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// 미리 정의된 매핑
  static final Map<String, AdviceData> _predefinedMappings = {
    // 긍정
    '유연한 태도로 변화에 대응하면 좋은 기회를 잡을 수 있습니다':
        const AdviceData(keyword: '유연한 태도', sentiment: AdviceSentiment.positive),
    '좋은 인연을 만날 수 있는 날입니다':
        const AdviceData(keyword: '좋은 인연', sentiment: AdviceSentiment.positive),
    '새로운 시작에 좋은 날입니다':
        const AdviceData(keyword: '새로운 시작', sentiment: AdviceSentiment.positive),
    '긍정적인 마인드가 행운을 부릅니다':
        const AdviceData(keyword: '긍정 마인드', sentiment: AdviceSentiment.positive),
    '과감한 도전이 성공으로 이어집니다':
        const AdviceData(keyword: '과감한 도전', sentiment: AdviceSentiment.positive),

    // 중립
    '차분하게 상황을 지켜보세요':
        const AdviceData(keyword: '차분히 관망', sentiment: AdviceSentiment.neutral),
    '현재에 집중하세요':
        const AdviceData(keyword: '현재 집중', sentiment: AdviceSentiment.neutral),
    '균형 잡힌 시각이 필요합니다':
        const AdviceData(keyword: '균형 시각', sentiment: AdviceSentiment.neutral),
    '내면의 목소리에 귀 기울이세요':
        const AdviceData(keyword: '내면 경청', sentiment: AdviceSentiment.neutral),

    // 주의
    '급하게 결정하지 마세요':
        const AdviceData(keyword: '신중한 결정', sentiment: AdviceSentiment.caution),
    '충분히 생각한 후 행동하세요':
        const AdviceData(keyword: '신중 행동', sentiment: AdviceSentiment.caution),
    '시간을 두고 지켜봐야 합니다':
        const AdviceData(keyword: '시간 필요', sentiment: AdviceSentiment.caution),
    '서두르지 마세요':
        const AdviceData(keyword: '천천히', sentiment: AdviceSentiment.caution),

    // 경고
    '과욕은 금물입니다':
        const AdviceData(keyword: '과욕 금물', sentiment: AdviceSentiment.warning),
    '구설수에 주의하세요':
        const AdviceData(keyword: '구설 주의', sentiment: AdviceSentiment.warning),
    '무리한 계획은 피하세요':
        const AdviceData(keyword: '무리 금지', sentiment: AdviceSentiment.warning),
    '갈등 상황을 피하세요':
        const AdviceData(keyword: '갈등 회피', sentiment: AdviceSentiment.warning),
  };

  /// 키워드 매핑
  static final Map<String, String> _keywordMappings = {
    '유연': '유연한 태도',
    '긍정': '긍정 마인드',
    '도전': '과감한 도전',
    '시작': '새로운 시작',
    '집중': '현재 집중',
    '균형': '균형 유지',
    '신중': '신중한 결정',
    '인내': '인내와 기다림',
    '소통': '적극 소통',
    '변화': '변화 수용',
    '기회': '기회 포착',
    '행운': '행운의 날',
    '휴식': '충분한 휴식',
    '노력': '꾸준한 노력',
  };

  /// 불용어
  static const Set<String> _stopWords = {
    '오늘',
    '내일',
    '어제',
    '하세요',
    '합니다',
    '입니다',
    '그리고',
    '하지만',
    '그러나',
    '때문에',
    '그래서',
    '위해서',
    '위해',
    '등',
    '것',
    '수',
    '때',
    '중',
  };
}

/// 조언 데이터
class AdviceData {
  const AdviceData({
    required this.keyword,
    required this.sentiment,
    this.fullText,
  });

  final String keyword;
  final AdviceSentiment sentiment;
  final String? fullText;
}
