import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OOTD 평가 결과 카드 - 패션 매거진 스타일
///
/// AI가 평가한 OOTD 결과를 비주얼 분석 보고서 형태로 표시합니다.
/// - 점수 + 등급 + 원형 게이지
/// - 해시태그 칩
/// - 6각형 레이더 차트
/// - 스타일 처방전
/// - 셀럽 + 추천 아이템 2열 카드
class ChatOotdResultCard extends ConsumerWidget {
  final Map<String, dynamic> ootdData;
  final bool isBlurred;
  final List<String> blurredSections;

  const ChatOotdResultCard({
    super.key,
    required this.ootdData,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  // 메인 그린 컬러
  static const Color _primaryGreen = Color(0xFF10B981);
  static const Color _lightGreen = Color(0xFF34D399);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          UnifiedBlurWrapper(
            isBlurred: isBlurred,
            blurredSections: blurredSections,
            sectionKey: 'ootd-result',
            fortuneType: 'ootd-evaluation',
            child: Column(
              children: [
                _buildScoreSection(context),
                _buildHashtagSection(context),
                _buildRadarChartSection(context),
                _buildPrescriptionSection(context),
                _buildBottomCardsSection(context),
                const SizedBox(height: DSSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 헤더 섹션 (그린 그라데이션)
  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tpo = ootdData['tpo'] as String? ?? '';

    final tpoLabels = {
      'date': '💕 데이트',
      'interview': '💼 면접',
      'work': '🏢 출근',
      'casual': '☕ 일상',
      'party': '🎉 파티/모임',
      'wedding': '💒 경조사',
      'travel': '✈️ 여행',
      'sports': '🏃 운동',
    };

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [_primaryGreen, const Color(0xFF059669)]
              : [_lightGreen, _primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: const Icon(
              Icons.checkroom,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OOTD 평가 결과',
                  style: context.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'AI Style Analysis',
                  style: context.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (tpo.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
              child: Text(
                tpoLabels[tpo] ?? tpo,
                style: context.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: DSSpacing.xs),
          // 좋아요 + 공유 버튼
          FortuneActionButtons(
            contentId: ootdData['id']?.toString() ?? 'ootd_${DateTime.now().millisecondsSinceEpoch}',
            contentType: 'ootd',
            shareTitle: 'OOTD 평가 결과',
            shareContent: (ootdData['details'] as Map<String, dynamic>?)?['overallComment'] as String? ?? 'AI Style Analysis',
            iconSize: 20,
            iconColor: Colors.white.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }

  /// 점수 섹션 - 좌측 점수/뱃지 + 우측 원형 게이지
  Widget _buildScoreSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final score = (ootdData['score'] as num?)?.toDouble() ?? 0.0;
    final grade = details['overallGrade'] as String? ?? 'C';
    final comment = details['overallComment'] as String? ?? '';

    // 등급별 라벨
    final gradeLabels = {
      'S': 'TREND SETTER',
      'A': 'TOP-TIER',
      'B': 'CHIC STYLE',
      'C': 'RISING STAR',
    };

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 좌측: 점수 + 등급 뱃지들
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 점수 + 등급 뱃지
                    Row(
                      children: [
                        // 점수
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: score.toStringAsFixed(1),
                                style: context.heading1.copyWith(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '/10',
                                style: context.heading3.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        // A 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.sm,
                            vertical: DSSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(DSRadius.sm),
                          ),
                          child: Text(
                            grade,
                            style: context.heading3.copyWith(
                              color: _primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        // TREND SETTER 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.sm,
                            vertical: DSSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: _primaryGreen),
                            borderRadius: BorderRadius.circular(DSRadius.full),
                          ),
                          child: Text(
                            gradeLabels[grade] ?? 'STYLE',
                            style: context.labelSmall.copyWith(
                              color: _primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 우측: 원형 게이지
              _buildCircularGauge(context, score),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 코멘트
          if (comment.isNotEmpty)
            Text(
              comment,
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 원형 게이지 위젯
  Widget _buildCircularGauge(BuildContext context, double score) {
    final normalizedScore = (score / 10.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 64,
      height: 64,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: normalizedScore),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _CircularGaugePainter(
              progress: value,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              progressColor: _primaryGreen,
              strokeWidth: 6,
            ),
          );
        },
      ),
    );
  }

  /// 해시태그 칩 섹션
  Widget _buildHashtagSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final keywords =
        (details['styleKeywords'] as List<dynamic>?)?.cast<String>() ?? [];

    if (keywords.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏷', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '칭찬 포인트',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: keywords.length,
              separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.xs),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _primaryGreen),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Text(
                    '#${keywords[index]}',
                    style: context.bodySmall.copyWith(
                      color: _primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  /// 레이더 차트 섹션 (6각형)
  Widget _buildRadarChartSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final categories = details['categories'] as Map<String, dynamic>? ?? {};

    if (categories.isEmpty) return const SizedBox.shrink();

    // 6개 카테고리 데이터 준비
    final categoryLabels = {
      'colorHarmony': '색상',
      'silhouette': '실루엣',
      'styleConsistency': '스타일',
      'accessories': '악세',
      'tpoFit': 'TPO',
      'trendScore': '트렌드',
    };

    final scores = <String, double>{};
    for (final entry in categoryLabels.entries) {
      final data = categories[entry.key] as Map<String, dynamic>?;
      scores[entry.value] = (data?['score'] as num?)?.toDouble() ?? 7.0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '세부 평가',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _OotdRadarChartPainter(
                  scores: scores,
                  primaryColor: _primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(
          begin: const Offset(0.95, 0.95),
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  /// 스타일 처방전 섹션
  Widget _buildPrescriptionSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final suggestions =
        (details['softSuggestions'] as List<dynamic>?)?.cast<String>() ?? [];

    if (suggestions.isEmpty) return const SizedBox.shrink();

    // 아이콘 매핑 (제안 내용에 따라)
    final icons = ['🧴', '✨', '💍', '👗', '👠'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이렇게 하면 더 완벽해요!',
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            final icon = icons[index % icons.length];

            // 마지막 항목은 하이라이트 박스로 표시
            if (index == suggestions.length - 1 && suggestions.length > 1) {
              return Container(
                margin: const EdgeInsets.only(top: DSSpacing.xs),
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                  border: Border.all(
                    color: _primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: _buildHighlightedText(suggestion, context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: context.bodyMedium.copyWith(
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
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  /// 하이라이트 텍스트 빌더 (+20% 등을 강조)
  List<TextSpan> _buildHighlightedText(String text, BuildContext context) {
    final colors = context.colors;
    final regex = RegExp(r'(\+\d+%[^\s]*)');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: context.bodyMedium.copyWith(color: colors.textPrimary),
        ),
      ];
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: context.bodyMedium.copyWith(color: colors.textPrimary),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: context.bodyMedium.copyWith(
          color: _primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: context.bodyMedium.copyWith(color: colors.textPrimary),
      ));
    }

    return spans;
  }

  /// 하단 2열 카드 섹션 (셀럽 + 추천 아이템)
  Widget _buildBottomCardsSection(BuildContext context) {
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final celebMatch = details['celebrityMatch'] as Map<String, dynamic>?;
    final items = (details['recommendedItems'] as List<dynamic>?) ?? [];

    // 둘 다 없으면 표시 안 함
    if (celebMatch == null && items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셀럽 스타일 매칭 카드
          if (celebMatch != null)
            Expanded(
              child: _buildCelebCard(context, celebMatch),
            ),
          if (celebMatch != null && items.isNotEmpty)
            const SizedBox(width: DSSpacing.sm),
          // 추천 아이템 카드
          if (items.isNotEmpty)
            Expanded(
              child: _buildRecommendCard(context, items.first as Map<String, dynamic>),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  /// 셀럽 스타일 매칭 카드
  Widget _buildCelebCard(BuildContext context, Map<String, dynamic> celebMatch) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = celebMatch['name'] as String? ?? '';
    final similarity = (celebMatch['similarity'] as num?)?.toInt() ?? 0;
    final reason = celebMatch['reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '셀럽 스타일 매칭',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 프로필 원형
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⭐', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '$name의',
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '"${_getStyleConcept(name)}" 무드',
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
          Text(
            '$similarity% 일치',
            style: context.labelSmall.copyWith(
              color: const Color(0xFF8B5CF6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            reason,
            style: context.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 셀럽별 스타일 컨셉 (예시)
  String _getStyleConcept(String name) {
    final concepts = {
      '아이유': 'LILAC',
      '블랙핑크': 'PINK VENOM',
      '방탄소년단': 'DYNAMITE',
      '뉴진스': 'DITTO',
      '에스파': 'NEXT LEVEL',
    };
    for (final entry in concepts.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return 'ICONIC';
  }

  /// 추천 아이템 카드
  Widget _buildRecommendCard(BuildContext context, Map<String, dynamic> item) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emoji = item['emoji'] as String? ?? '👗';
    final itemName = item['item'] as String? ?? '';
    final reason = item['reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👗', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '추천 아이템',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 아이템 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            itemName,
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            reason,
            style: context.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DSSpacing.sm),
          // 스타일링 팁 확인 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Text(
              '스타일링 팁 확인',
              style: context.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 원형 게이지 페인터
class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularGaugePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 진행 원
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12시 방향에서 시작
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularGaugePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// OOTD 전용 6각형 레이더 차트 페인터
class _OotdRadarChartPainter extends CustomPainter {
  final Map<String, double> scores;
  final Color primaryColor;

  _OotdRadarChartPainter({
    required this.scores,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30; // 라벨 공간 확보
    final labels = scores.keys.toList();
    final values = scores.values.toList();
    final count = labels.length;

    if (count == 0) return;

    // 가이드 라인 (회색)
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 3단계 가이드 라인 그리기
    for (int level = 1; level <= 3; level++) {
      final levelRadius = radius * (level / 3);
      final path = Path();
      for (int i = 0; i <= count; i++) {
        final angle = (2 * math.pi / count) * i - math.pi / 2;
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 축 라인
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // 데이터 영역 (반투명 그린)
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < count; i++) {
      final normalizedScore = (values[i] / 10).clamp(0.0, 1.0);
      final angle = (2 * math.pi / count) * i - math.pi / 2;
      final x = center.dx + radius * normalizedScore * math.cos(angle);
      final y = center.dy + radius * normalizedScore * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // 꼭짓점에 별(★) 아이콘과 라벨
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i - math.pi / 2;
      final labelRadius = radius + 20;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      // 별 아이콘
      textPainter.text = TextSpan(
        text: '★',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.withValues(alpha: 0.6),
        ),
      );
      textPainter.layout();

      // 라벨
      textPainter.text = TextSpan(
        text: '★ ${labels[i]}',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_OotdRadarChartPainter oldDelegate) {
    return scores != oldDelegate.scores;
  }
}
