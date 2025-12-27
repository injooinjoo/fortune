import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/widgets/smart_image.dart';

/// 채팅용 운세 결과 리치 카드
///
/// 이미지 헤더, 점수 원형, 카테고리 섹션, 행운 아이템 표시
class ChatFortuneResultCard extends StatelessWidget {
  final Fortune fortune;
  final String fortuneType;
  final String typeName;
  final bool isBlurred;

  const ChatFortuneResultCard({
    super.key,
    required this.fortune,
    required this.fortuneType,
    required this.typeName,
    this.isBlurred = false,
  });

  /// 오늘의 운세 타입 체크 (설문 기반 아닌 운세)
  bool get _isDailyFortune => fortuneType == 'daily' || fortuneType == 'time';

  /// 연간 운세 타입 체크
  bool get _isYearlyFortune => fortuneType == 'yearly' || fortuneType == 'new-year';

  /// 본문 content를 직접 표시해야 하는 타입 체크
  bool get _shouldShowContent =>
      _isDailyFortune ||
      fortuneType == 'compatibility' ||
      fortuneType == 'blind-date' ||
      fortuneType == 'love' ||
      fortuneType == 'career';

  /// 인사이트 민화 이미지 목록 (날짜별 랜덤 선택)
  static const List<String> _minhwaImages = [
    'assets/images/minhwa/minhwa_overall_tiger.webp',
    'assets/images/minhwa/minhwa_overall_dragon.webp',
    'assets/images/minhwa/minhwa_overall_moon.webp',
    'assets/images/minhwa/minhwa_overall_phoenix.webp',
    'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'assets/images/minhwa/minhwa_overall_turtle.webp',
  ];

  /// 연간 운세 전용 민화 이미지 (새해/풍요 테마)
  static const List<String> _yearlyMinhwaImages = [
    'assets/images/minhwa/minhwa_overall_dragon.webp',
    'assets/images/minhwa/minhwa_overall_phoenix.webp',
    'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'assets/images/minhwa/minhwa_saju_tiger_dragon.webp',
    'assets/images/minhwa/minhwa_saju_fourguardians.webp',
    'assets/images/minhwa/minhwa_money_treasure.webp',
  ];

  /// 오늘 날짜 기반 민화 이미지 선택 (하루 동안 일관성 유지)
  String _getTodayMinhwaImage() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _minhwaImages.length;
    return _minhwaImages[index];
  }

  /// 연간 운세용 민화 이미지 선택 (월별로 다른 이미지)
  String _getYearlyMinhwaImage() {
    final today = DateTime.now();
    final index = today.month % _yearlyMinhwaImages.length;
    return _yearlyMinhwaImages[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      // 수평 마진은 ListView 패딩이 아닌 카드 자체에서 적용
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md, // 화면 가장자리와의 여백
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이미지 헤더
          _buildImageHeader(context),

          // 점수 섹션
          if (fortune.overallScore != null) _buildScoreSection(context),

          // 인사말/총평
          if (fortune.greeting != null || fortune.summary != null)
            _buildSummarySection(context),

          // 본문 content 표시 (daily, compatibility, love, career 등)
          if (_shouldShowContent && fortune.content.isNotEmpty)
            _buildContentSection(context),

          // 카테고리/육각형 점수 표시 (content 표시하지 않는 타입만)
          if (!_shouldShowContent) ...[
            if (fortune.categories != null && fortune.categories!.isNotEmpty)
              _buildCategoriesSection(context),
            if (fortune.hexagonScores != null &&
                fortune.hexagonScores!.isNotEmpty)
              _buildHexagonScoresSection(context),
          ],

          // 추천 사항
          if (fortune.recommendations != null &&
              fortune.recommendations!.isNotEmpty)
            _buildRecommendationsSection(context),

          // 행운 아이템
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty)
            _buildLuckyItemsSection(context),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    // daily/yearly fortune은 민화 이미지 사용, 그 외는 기존 이미지
    final imagePath = _isDailyFortune
        ? _getTodayMinhwaImage()
        : _isYearlyFortune
            ? _getYearlyMinhwaImage()
            : FortuneCardImages.getImagePath(fortuneType);

    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          SmartImage(
            path: imagePath,
            fit: BoxFit.cover,
          ),

          // 반투명 오버레이 (텍스트 가독성용, 색상 그라데이션 제거)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          // 타이틀
          Positioned(
            left: DSSpacing.md,
            right: DSSpacing.md,
            bottom: DSSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDailyFortune ? '오늘의 내 이야기' : typeName,
                  style: typography.headingSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: colors.textPrimary.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (fortune.period != null)
                  Text(
                    _getPeriodLabel(fortune.period!),
                    style: typography.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = fortune.overallScore ?? 0;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        children: [
          // 점수 원형
          _FortuneScoreCircle(
            score: score,
            size: 72,
          ),
          const SizedBox(width: DSSpacing.md),

          // 점수 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '종합 운세',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(score),
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getScoreAdvice(score),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 전체 본문 내용 표시 (오늘의 운세용)
  Widget _buildContentSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Text(
        fortune.content,
        style: typography.bodyMedium.copyWith(
          color: colors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final text = fortune.greeting ?? fortune.summary ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.accentSecondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.accentSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✨', style: typography.bodyLarge),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final categories = fortune.categories!;

    final categoryItems = <Widget>[];
    categories.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final score = value['score'] as int?;
        final description = value['description'] as String?;
        final emoji = _getCategoryEmoji(key);

        categoryItems.add(
          _FortuneCategoryTile(
            title: _getCategoryTitle(key),
            emoji: emoji,
            score: score,
            description: description ?? '',
          ),
        );
      }
    });

    if (categoryItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리별 운세',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...categoryItems,
        ],
      ),
    );
  }

  Widget _buildHexagonScoresSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final scores = fortune.hexagonScores!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세부 운세',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: scores.entries.map((entry) {
              final emoji = _getCategoryEmoji(entry.key);
              final title = _getCategoryTitle(entry.key);
              return _HexagonScoreChip(
                emoji: emoji,
                title: title,
                score: entry.value,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💡', style: typography.bodyLarge),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 추천',
                style: typography.labelLarge.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          ...fortune.recommendations!.take(3).map((rec) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: typography.bodyMedium.copyWith(
                      color: colors.accentSecondary,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      rec,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final items = fortune.luckyItems!;

    final luckyWidgets = <Widget>[];

    if (items['color'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '🎨',
        label: '행운색',
        value: items['color'].toString(),
      ));
    }
    if (items['number'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '🔢',
        label: '행운숫자',
        value: items['number'].toString(),
      ));
    }
    if (items['direction'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '🧭',
        label: '행운방향',
        value: items['direction'].toString(),
      ));
    }
    if (items['time'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '⏰',
        label: '행운시간',
        value: items['time'].toString(),
      ));
    }

    if (luckyWidgets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍀 행운 아이템',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: luckyWidgets,
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    return switch (period) {
      'today' => '오늘의 운세',
      'tomorrow' => '내일의 운세',
      'weekly' => '이번 주 운세',
      'monthly' => '이번 달 운세',
      'yearly' => '올해의 운세',
      _ => period,
    };
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '최고의 하루! 🌟';
    if (score >= 80) return '아주 좋은 운세예요! ✨';
    if (score >= 70) return '좋은 기운이 함께해요';
    if (score >= 60) return '평온한 하루가 될 거예요';
    if (score >= 50) return '조심하면 괜찮아요';
    return '차분하게 보내세요';
  }

  String _getScoreAdvice(int score) {
    if (score >= 80) return '적극적으로 도전해보세요';
    if (score >= 60) return '계획대로 진행하세요';
    return '중요한 결정은 미루세요';
  }

  String _getCategoryEmoji(String key) {
    return switch (key.toLowerCase()) {
      'love' || '연애운' || '연애' => '💕',
      'money' || '금전운' || '재물운' || '재물' => '💰',
      'work' || 'career' || '직업운' || '사업운' || '직업' => '💼',
      'health' || '건강운' || '건강' => '🏥',
      'social' || '대인운' || '인간관계' => '👥',
      'study' || '학업운' || '학업' => '📚',
      '총운' => '⭐',
      _ => '✨',
    };
  }

  String _getCategoryTitle(String key) {
    return switch (key.toLowerCase()) {
      'love' => '연애운',
      'money' => '금전운',
      'work' || 'career' => '직업운',
      'health' => '건강운',
      'social' => '대인운',
      'study' => '학업운',
      _ => key,
    };
  }
}

/// 점수 원형 위젯
class _FortuneScoreCircle extends StatefulWidget {
  final int score;
  final double size;

  const _FortuneScoreCircle({
    required this.score,
    this.size = 72,
  });

  @override
  State<_FortuneScoreCircle> createState() => _FortuneScoreCircleState();
}

class _FortuneScoreCircleState extends State<_FortuneScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final displayScore = (progress * 100).round();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ScoreCirclePainter(
              progress: progress,
              backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
              progressColor: _getScoreColor(widget.score),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayScore',
                    style: typography.headingMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '점',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFF3B82F6); // Blue
    if (score >= 40) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ScoreCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 카테고리 타일 위젯
class _FortuneCategoryTile extends StatelessWidget {
  final String title;
  final String emoji;
  final int? score;
  final String description;

  const _FortuneCategoryTile({
    required this.title,
    required this.emoji,
    this.score,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: typography.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (score != null) ...[
                      const SizedBox(width: DSSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score!).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          '$score점',
                          style: typography.labelSmall.copyWith(
                            color: _getScoreColor(score!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// 육각형 점수 칩
class _HexagonScoreChip extends StatelessWidget {
  final String emoji;
  final String title;
  final int score;

  const _HexagonScoreChip({
    required this.emoji,
    required this.title,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            title,
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: typography.labelMedium.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// 행운 아이템 칩
class _LuckyItemChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _LuckyItemChip({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accentSecondary.withValues(alpha: 0.1),
            colors.accentSecondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accentSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
