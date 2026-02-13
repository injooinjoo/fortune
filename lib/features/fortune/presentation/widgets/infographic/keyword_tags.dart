import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 키워드 태그 위젯
///
/// 꿈 해석, 타로, 성격 분석 등에서 사용되는 키워드 버블/태그입니다.
class KeywordTags extends StatefulWidget {
  const KeywordTags({
    super.key,
    required this.keywords,
    this.spacing = DSSpacing.xs,
    this.alignment = WrapAlignment.center,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.style = KeywordTagStyle.filled,
  });

  /// 키워드 목록
  final List<KeywordData> keywords;

  /// 태그 간 간격
  final double spacing;

  /// 정렬 방식
  final WrapAlignment alignment;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  /// 순차 등장 딜레이
  final Duration staggerDelay;

  /// 태그 스타일
  final KeywordTagStyle style;

  @override
  State<KeywordTags> createState() => _KeywordTagsState();
}

class _KeywordTagsState extends State<KeywordTags>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration +
          (widget.staggerDelay * widget.keywords.length),
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
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      alignment: widget.alignment,
      children: widget.keywords.asMap().entries.map((entry) {
        final index = entry.key;
        final keyword = entry.value;

        if (!widget.animate) {
          return _KeywordTag(
            keyword: keyword,
            style: widget.style,
          );
        }

        final startTime = index *
            widget.staggerDelay.inMilliseconds /
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
          child: _KeywordTag(
            keyword: keyword,
            style: widget.style,
          ),
        );
      }).toList(),
    );
  }
}

/// 개별 키워드 태그
class _KeywordTag extends StatelessWidget {
  const _KeywordTag({
    required this.keyword,
    required this.style,
  });

  final KeywordData keyword;
  final KeywordTagStyle style;

  @override
  Widget build(BuildContext context) {
    final color = keyword.color ?? context.colors.accent;

    switch (style) {
      case KeywordTagStyle.filled:
        return _buildFilledTag(context, color);
      case KeywordTagStyle.outlined:
        return _buildOutlinedTag(context, color);
      case KeywordTagStyle.hashtag:
        return _buildHashtag(context, color);
      case KeywordTagStyle.bubble:
        return _buildBubble(context, color);
    }
  }

  Widget _buildFilledTag(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (keyword.icon != null) ...[
            Icon(
              keyword.icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            keyword.text,
            style: context.typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedTag(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (keyword.icon != null) ...[
            Icon(
              keyword.icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            keyword.text,
            style: context.typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtag(BuildContext context, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '#',
          style: context.typography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          keyword.text,
          style: context.typography.bodySmall.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (keyword.icon != null) ...[
            Icon(
              keyword.icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            keyword.text,
            style: context.typography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 키워드 태그 스타일
enum KeywordTagStyle {
  /// 채워진 배경
  filled,

  /// 테두리만
  outlined,

  /// 해시태그 스타일
  hashtag,

  /// 둥근 버블
  bubble,
}

/// 키워드 데이터
class KeywordData {
  const KeywordData({
    required this.text,
    this.icon,
    this.color,
    this.sentiment,
  });

  /// 키워드 텍스트
  final String text;

  /// 아이콘 (선택)
  final IconData? icon;

  /// 색상 (선택)
  final Color? color;

  /// 감정/의미 분류 (선택)
  final KeywordSentiment? sentiment;

  /// 긍정 키워드 생성
  factory KeywordData.positive(String text, {IconData? icon}) {
    return KeywordData(
      text: text,
      icon: icon,
      sentiment: KeywordSentiment.positive,
    );
  }

  /// 부정 키워드 생성
  factory KeywordData.negative(String text, {IconData? icon}) {
    return KeywordData(
      text: text,
      icon: icon,
      sentiment: KeywordSentiment.negative,
    );
  }

  /// 중립 키워드 생성
  factory KeywordData.neutral(String text, {IconData? icon}) {
    return KeywordData(
      text: text,
      icon: icon,
      sentiment: KeywordSentiment.neutral,
    );
  }
}

/// 키워드 감정/의미 분류
enum KeywordSentiment {
  positive,
  negative,
  neutral,
}

/// 감정 기반 키워드 태그 위젯
class SentimentKeywordTags extends StatelessWidget {
  const SentimentKeywordTags({
    super.key,
    required this.keywords,
    this.spacing = DSSpacing.xs,
    this.alignment = WrapAlignment.center,
  });

  final List<KeywordData> keywords;
  final double spacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: alignment,
      children: keywords.map((keyword) {
        final color = _getSentimentColor(context, keyword.sentiment);
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: DSRadius.smBorder,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (keyword.icon != null) ...[
                Icon(
                  keyword.icon,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                keyword.text,
                style: context.typography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getSentimentColor(BuildContext context, KeywordSentiment? sentiment) {
    switch (sentiment) {
      case KeywordSentiment.positive:
        return context.colors.success;
      case KeywordSentiment.negative:
        return context.colors.error;
      case KeywordSentiment.neutral:
      case null:
        return context.colors.accent;
    }
  }
}

/// 강조 키워드 (큰 텍스트)
class HighlightKeyword extends StatelessWidget {
  const HighlightKeyword({
    super.key,
    required this.text,
    this.subtitle,
    this.icon,
    this.color,
    this.size = HighlightKeywordSize.medium,
  });

  final String text;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final HighlightKeywordSize size;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.accent;

    final textStyle = switch (size) {
      HighlightKeywordSize.small => context.typography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: effectiveColor,
        ),
      HighlightKeywordSize.medium => context.typography.headingSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: effectiveColor,
        ),
      HighlightKeywordSize.large => context.typography.headingMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: effectiveColor,
        ),
    };

    final iconSize = switch (size) {
      HighlightKeywordSize.small => 18.0,
      HighlightKeywordSize.medium => 24.0,
      HighlightKeywordSize.large => 32.0,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: DSRadius.mdBorder,
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: effectiveColor,
                ),
                const SizedBox(width: DSSpacing.xs),
              ],
              Text(text, style: textStyle),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              subtitle!,
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 강조 키워드 크기
enum HighlightKeywordSize {
  small,
  medium,
  large,
}

/// 꿈 해석 키워드 프리셋
class DreamKeywords {
  DreamKeywords._();

  static List<KeywordData> fromSymbols(List<String> symbols) {
    return symbols.map((symbol) => KeywordData(text: symbol)).toList();
  }

  static List<KeywordData> withIcons(Map<String, IconData> symbolsWithIcons) {
    return symbolsWithIcons.entries
        .map((e) => KeywordData(text: e.key, icon: e.value))
        .toList();
  }
}

/// 타로 키워드 프리셋
class TarotKeywords {
  TarotKeywords._();

  static List<KeywordData> fromMeanings(List<String> meanings) {
    return meanings
        .map((meaning) => KeywordData(
              text: meaning,
              icon: Icons.auto_awesome_rounded,
            ))
        .toList();
  }
}
