import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// 카테고리별 점수를 가로 막대 차트로 표시하는 위젯
///
/// 사용 예시:
/// ```dart
/// CategoryBarChart(
///   categories: [
///     CategoryScore(name: '연애', score: 82, icon: '❤️'),
///     CategoryScore(name: '재물', score: 65, icon: '💰'),
///     CategoryScore(name: '직장', score: 91, icon: '💼'),
///     CategoryScore(name: '학업', score: 74, icon: '📚'),
///     CategoryScore(name: '건강', score: 78, icon: '💚'),
///   ],
/// )
/// ```
class CategoryBarChart extends StatelessWidget {
  /// 카테고리 점수 목록
  final List<CategoryScore> categories;

  /// 막대 높이 (기본값: 8)
  final double barHeight;

  /// 카테고리 간 간격 (기본값: 12)
  final double spacing;

  /// 점수 표시 여부 (기본값: true)
  final bool showScore;

  /// 아이콘 표시 여부 (기본값: true)
  final bool showIcon;

  /// 애니메이션 적용 여부
  final bool animate;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  /// 최대 점수 (기본값: 100)
  final int maxScore;

  const CategoryBarChart({
    super.key,
    required this.categories,
    this.barHeight = 8,
    this.spacing = 12,
    this.showScore = true,
    this.showIcon = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.maxScore = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return Padding(
          padding: EdgeInsets.only(
              bottom: index < categories.length - 1 ? spacing : 0),
          child: _CategoryBarItem(
            category: category,
            barHeight: barHeight,
            showScore: showScore,
            showIcon: showIcon,
            animate: animate,
            animationDuration: animationDuration,
            animationDelay: Duration(milliseconds: index * 100),
            maxScore: maxScore,
          ),
        );
      }).toList(),
    );
  }
}

/// 개별 카테고리 막대 아이템
class _CategoryBarItem extends StatefulWidget {
  final CategoryScore category;
  final double barHeight;
  final bool showScore;
  final bool showIcon;
  final bool animate;
  final Duration animationDuration;
  final Duration animationDelay;
  final int maxScore;

  const _CategoryBarItem({
    required this.category,
    required this.barHeight,
    required this.showScore,
    required this.showIcon,
    required this.animate,
    required this.animationDuration,
    required this.animationDelay,
    required this.maxScore,
  });

  @override
  State<_CategoryBarItem> createState() => _CategoryBarItemState();
}

class _CategoryBarItemState extends State<_CategoryBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.category.score.toDouble() / widget.maxScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_CategoryBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.score != widget.category.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.category.score.toDouble() / widget.maxScore,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final barColor =
        widget.category.color ?? _getScoreColor(widget.category.score, isDark);
    final bgColor = isDark
        ? DSColors.backgroundSecondaryDark
        : DSColors.backgroundSecondary;

    return Row(
      children: [
        // 아이콘
        if (widget.showIcon) ...[
          SizedBox(
            width: 24,
            child: Text(
              widget.category.icon ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // 라벨
        SizedBox(
          width: 40,
          child: Text(
            widget.category.name,
            style: context.labelMedium.copyWith(
              color:
                  isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 막대 차트
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 배경 바
                  Container(
                    height: widget.barHeight,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(widget.barHeight / 2),
                    ),
                  ),
                  // 진행 바
                  FractionallySizedBox(
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      height: widget.barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius:
                            BorderRadius.circular(widget.barHeight / 2),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 점수
        if (widget.showScore) ...[
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                width: 32,
                child: Text(
                  (_animation.value * widget.maxScore).round().toString(),
                  textAlign: TextAlign.right,
                  style: context.numberSmall.copyWith(
                    color: isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Color _getScoreColor(int score, bool isDark) {
    if (score >= 80) {
      return isDark ? DSColors.successDark : DSColors.success;
    } else if (score >= 60) {
      return isDark ? DSColors.accentTertiaryDark : DSColors.accentTertiary;
    } else if (score >= 40) {
      return isDark ? DSColors.warningDark : DSColors.warning;
    } else {
      return isDark ? DSColors.errorDark : DSColors.error;
    }
  }
}

/// 카테고리 점수 데이터 모델
class CategoryScore {
  /// 카테고리 이름
  final String name;

  /// 점수 (0-100)
  final int score;

  /// 아이콘 (이모지 또는 텍스트)
  final String? icon;

  /// 커스텀 색상 (null이면 점수 기반 자동 색상)
  final Color? color;

  const CategoryScore({
    required this.name,
    required this.score,
    this.icon,
    this.color,
  });

  /// Map에서 생성
  factory CategoryScore.fromMap(Map<String, dynamic> map) {
    return CategoryScore(
      name: map['name'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      icon: map['icon'] as String?,
    );
  }

  /// 운세 카테고리 목록에서 생성
  static List<CategoryScore> fromFortuneCategories(
      Map<String, dynamic> categories) {
    final iconMap = {
      '연애': '❤️',
      '사랑': '❤️',
      'love': '❤️',
      '재물': '💰',
      '돈': '💰',
      'money': '💰',
      'wealth': '💰',
      '직장': '💼',
      '커리어': '💼',
      'career': '💼',
      'work': '💼',
      '학업': '📚',
      '공부': '📚',
      'study': '📚',
      '건강': '💚',
      'health': '💚',
      '가족': '👨‍👩‍👧‍👦',
      'family': '👨‍👩‍👧‍👦',
      '인간관계': '🤝',
      'relationship': '🤝',
    };

    return categories.entries.map((e) {
      final name = e.key;
      final score = e.value is num ? (e.value as num).toInt() : 0;
      final icon = iconMap[name.toLowerCase()] ?? '⭐';
      return CategoryScore(name: name, score: score, icon: icon);
    }).toList();
  }
}
