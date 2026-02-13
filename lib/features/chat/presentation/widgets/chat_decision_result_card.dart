import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';

/// 결정 분석 결과 카드
///
/// 채팅 내에서 의사결정 도움 결과를 명확하고 분석적으로 표시합니다.
/// - 고민 중인 질문
/// - 선택지별 장단점 분석
/// - AI 추천 및 근거
class ChatDecisionResultCard extends ConsumerWidget {
  final String question;
  final List<Map<String, dynamic>> options;
  final String recommendation;
  final DateTime date;

  const ChatDecisionResultCard({
    super.key,
    required this.question,
    required this.options,
    required this.recommendation,
    required this.date,
  });

  // 디자인 색상 → DSColors 기반 (ChatGPT monochrome style)
  static const _creamLight = DSColors.backgroundSecondary;
  static const _creamDark = DSColors.background;
  // 다크모드 배경
  static const _darkBg1 = DSColors.background;
  static const _darkBg2 = DSColors.backgroundSecondary;
  // 액센트 색상 - semantic colors
  static const _purpleAccent = DSColors.accentSecondary;
  static const _blueAccent = Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [_darkBg1, _darkBg2] : [_creamLight, _creamDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? _purpleAccent.withValues(alpha: 0.3)
              : _purpleAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _purpleAccent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 배경 장식
            ..._buildBackgroundDecorations(),

            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  _buildHeader(context)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // 구분선
                  _buildDivider(context),

                  const SizedBox(height: 16),

                  // 질문
                  _buildQuestionSection(context)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 20),

                  // 선택지 분석
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionCard(context, index + 1, option)
                          .animate()
                          .fadeIn(
                              duration: 400.ms,
                              delay:
                                  Duration(milliseconds: 400 + (index * 200)))
                          .slideX(begin: -0.05, end: 0),
                    );
                  }),

                  const SizedBox(height: DSSpacing.sm),

                  // AI 추천
                  _buildRecommendation(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations() {
    final decorations = <Widget>[];

    // 우측 상단 저울 장식
    decorations.add(
      Positioned(
        right: 15,
        top: 15,
        child: const Text(
          '⚖️',
          style: TextStyle(fontSize: 20),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: -0.05, end: 0.05, duration: 2000.ms),
      ),
    );

    // 좌측 하단 전구 장식
    decorations.add(
      Positioned(
        left: 20,
        bottom: 60,
        child: Text(
          '💡',
          style: TextStyle(
            fontSize: 16,
            color: Colors.amber.withValues(alpha: 0.5),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1200.ms)
            .fadeOut(duration: 1200.ms),
      ),
    );

    return decorations;
  }

  Widget _buildHeader(BuildContext context) {
    final typography = context.typography;
    final isDark = context.isDark;
    final formattedDate = DateFormat('M월 d일 HH:mm').format(date);
    final textColor = isDark ? Colors.white : DSColors.textPrimary;

    return Row(
      children: [
        // 이모지
        const Text(
          '🤔',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 날짜 + 타이틀
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '결정 도움',
                style: context.heading4.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                formattedDate,
                style: typography.labelTiny.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // 결정 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _purpleAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.balance_outlined,
            size: 20,
            color: isDark ? _purpleAccent : _blueAccent,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        // 좋아요 + 공유 버튼
        FortuneActionButtons(
          contentId: 'decision_${date.millisecondsSinceEpoch}',
          contentType: 'decision',
          fortuneType: 'decision',
          shareTitle: '결정 분석 - ${DateFormat('M월 d일').format(date)}',
          shareContent: '$question\n\n추천: $recommendation',
          iconSize: 18,
          iconColor: isDark ? _purpleAccent : _blueAccent,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final typography = context.typography;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _purpleAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '🔍',
            style: typography.bodySmall.copyWith(
              color: context.colors.textPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _purpleAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? Colors.white : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: isDark ? 0.05 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _purpleAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('❓', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '고민 중인 질문',
                  style: context.bodySmall.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  question,
                  style: context.bodyMedium.copyWith(
                    color: textColor,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, int index, Map<String, dynamic> option) {
    final typography = context.typography;
    final isDark = context.isDark;
    final textColor = isDark ? Colors.white : DSColors.textPrimary;
    final optionName = option['option'] ?? '선택지 $index';
    final pros = (option['pros'] as List?)?.cast<String>() ?? [];
    final cons = (option['cons'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _purpleAccent.withValues(alpha: isDark ? 0.1 : 0.08),
            _blueAccent.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _purpleAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택지 제목
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _purpleAccent.withValues(alpha: isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '선택 $index',
                  style: typography.labelTiny.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : _purpleAccent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  optionName,
                  style: context.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 장점
          if (pros.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('👍', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pros
                        .map((pro) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $pro',
                                style: context.bodySmall.copyWith(
                                  color: Colors.green.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],

          // 단점
          if (cons.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('👎', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cons
                        .map((con) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $con',
                                style: context.bodySmall.copyWith(
                                  color: Colors.orange.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? Colors.white : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blueAccent.withValues(alpha: isDark ? 0.2 : 0.15),
            _purpleAccent.withValues(alpha: isDark ? 0.15 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _blueAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'AI 추천',
                style: context.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation,
            style: context.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '💭 최종 결정은 당신의 몫이에요. 이 분석이 도움이 되길 바랍니다!',
            style: context.bodySmall.copyWith(
              color: textColor.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
