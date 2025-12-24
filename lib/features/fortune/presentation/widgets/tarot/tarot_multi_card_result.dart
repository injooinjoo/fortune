import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/tarot_card_model.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import 'tarot_card_detail_modal.dart';

class TarotMultiCardResult extends ConsumerStatefulWidget {
  final TarotSpreadResult result;
  final VoidCallback onRetry;

  const TarotMultiCardResult({
    super.key,
    required this.result,
    required this.onRetry,
  });

  @override
  ConsumerState<TarotMultiCardResult> createState() => _TarotMultiCardResultState();
}

class _TarotMultiCardResultState extends ConsumerState<TarotMultiCardResult>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // GPT 스타일 타이핑 효과 섹션 관리
  int _currentTypingSection = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant TarotMultiCardResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    // result가 변경되면 타이핑 섹션 리셋
    if (widget.result != oldWidget.result) {
      setState(() => _currentTypingSection = 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 질문 헤더
                  _buildQuestionHeader(isDark),
                  const SizedBox(height: 32),

                  // 카드 레이아웃
                  _buildCardLayout(isDark),
                  const SizedBox(height: 32),

                  // 전체 해석
                  _buildOverallInterpretation(isDark),
                  const SizedBox(height: 24),

                  // 개별 카드 해석
                  _buildIndividualInterpretations(isDark),

                  // ✅ 하단 버튼들 제거 (다시뽑기, 다른운세보기)
                  const SizedBox(height: 100),  // FloatingBottomButton 공간 확보
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader(bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                size: 20,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              Text(
                '질문',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.result.question,
            style: typography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.result.spreadType.displayName} • ${widget.result.cards.length}장',
            style: typography.bodySmall.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout(bool isDark) {
    switch (widget.result.spreadType) {
      case TarotSpreadType.single:
        return _buildSingleCardLayout(isDark);
      case TarotSpreadType.threeCard:
        return _buildThreeCardLayout(isDark);
      case TarotSpreadType.relationship:
        return _buildRelationshipLayout(isDark);
      case TarotSpreadType.celticCross:
        return _buildCelticCrossLayout(isDark);
    }
  }

  Widget _buildSingleCardLayout(bool isDark) {
    final card = widget.result.cards.first;
    return Center(
      child: _buildCardItem(card, 0, isDark, large: true),
    );
  }

  Widget _buildThreeCardLayout(bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[index], index, isDark),
                const SizedBox(height: 8),
                Text(
                  ['과거', '현재', '미래'][index],
                  style: typography.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRelationshipLayout(bool isDark) {
    return SizedBox(
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 나의 마음 (왼쪽)
          Positioned(
            left: 0,
            top: 100,
            child: Builder(builder: (context) {
              final colors = context.colors;
              final typography = context.typography;
              return Column(
                children: [
                  _buildCardItem(widget.result.cards[0], 0, isDark, small: true),
                  const SizedBox(height: 4),
                  Text('나', style: typography.labelSmall.copyWith(color: colors.textSecondary)),
                ],
              );
            }),
          ),
          // 상대의 마음 (오른쪽)
          Positioned(
            right: 0,
            top: 100,
            child: Builder(builder: (context) {
              final colors = context.colors;
              final typography = context.typography;
              return Column(
                children: [
                  _buildCardItem(widget.result.cards[1], 1, isDark, small: true),
                  const SizedBox(height: 4),
                  Text('상대', style: typography.labelSmall.copyWith(color: colors.textSecondary)),
                ],
              );
            }),
          ),
          // 과거 (위)
          Positioned(
            top: 0,
            child: Builder(builder: (context) {
              final colors = context.colors;
              final typography = context.typography;
              return Column(
                children: [
                  _buildCardItem(widget.result.cards[2], 2, isDark, small: true),
                  const SizedBox(height: 4),
                  Text('과거', style: typography.labelSmall.copyWith(color: colors.textSecondary)),
                ],
              );
            }),
          ),
          // 현재 관계 (중앙)
          Positioned(
            top: 150,
            child: Builder(builder: (context) {
              final colors = context.colors;
              final typography = context.typography;
              return Column(
                children: [
                  _buildCardItem(widget.result.cards[3], 3, isDark, small: true),
                  const SizedBox(height: 4),
                  Text('현재', style: typography.labelSmall.copyWith(color: colors.textSecondary)),
                ],
              );
            }),
          ),
          // 미래 (아래)
          Positioned(
            bottom: 0,
            child: Builder(builder: (context) {
              final colors = context.colors;
              final typography = context.typography;
              return Column(
                children: [
                  _buildCardItem(widget.result.cards[4], 4, isDark, small: true),
                  const SizedBox(height: 4),
                  Text('미래', style: typography.labelSmall.copyWith(color: colors.textSecondary)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCelticCrossLayout(bool isDark) {
    // 켈틱 크로스 위치 이름
    final positionNames = [
      '현재 상황',
      '도전/십자가',
      '먼 과거',
      '최근 과거',
      '가능한 미래',
      '가까운 미래',
      '당신의 접근',
      '외부 영향',
      '희망과 두려움',
      '최종 결과',
    ];

    // 각 카드를 큰 이미지 + 설명과 함께 세로로 스크롤
    return Column(
      children: List.generate(widget.result.cards.length, (index) {
        final card = widget.result.cards[index];
        final positionName = index < positionNames.length ? positionNames[index] : '카드 ${index + 1}';
        final interpretation = widget.result.positionInterpretations.entries.toList();
        final cardInterpretation = index < interpretation.length ? interpretation[index].value : '';

        return _buildLargeCardWithInterpretation(
          card: card,
          index: index,
          positionName: positionName,
          interpretation: cardInterpretation,
          isDark: isDark,
        );
      }),
    );
  }

  /// 큰 카드 이미지 + 해석을 함께 표시하는 위젯
  Widget _buildLargeCardWithInterpretation({
    required TarotCard card,
    required int index,
    required String positionName,
    required String interpretation,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 위치 번호 + 이름
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: context.typography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  positionName,
                  style: context.typography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 큰 카드 이미지
          GestureDetector(
            onTap: () {
              TarotCardDetailModal.show(
                context,
                card: card,
                question: widget.result.question,
                interpretation: {'interpretation': interpretation},
              );
            },
            child: Container(
              width: 240,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // 카드 이미지
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Transform.rotate(
                          angle: card.isReversed ? 3.14159 : 0,
                          child: Image.asset(
                            card.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                      const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: Color(0xFF7C3AED),
                                        size: 64,
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          card.cardNameKr,
                                          style: context.typography.labelLarge.copyWith(
                                            color: const Color(0xFF7C3AED),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // 역방향 표시
                    if (card.isReversed)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: DSColors.error,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: DSColors.error.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '역방향',
                            style: context.typography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 카드 이름 (이미지 아래에 별도 표시)
          Builder(builder: (context) {
            final colors = context.colors;
            final typography = context.typography;
            return Text(
              card.cardNameKr,
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 16),

          // 해석 텍스트
          if (interpretation.isNotEmpty)
            UnifiedBlurWrapper(
              isBlurred: widget.result.isBlurred,
              blurredSections: widget.result.blurredSections,
              sectionKey: 'card_${index + 1}',
              child: Builder(builder: (context) {
                final colors = context.colors;
                final typography = context.typography;
                return Container(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(DSRadius.lg),
                    border: Border.all(
                      color: colors.border,
                    ),
                  ),
                  child: Text(
                    interpretation,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),

          // 구분선
          if (index < widget.result.cards.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.0),
                      const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      const Color(0xFF7C3AED).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardItem(TarotCard card, int index, bool isDark, {bool large = false, bool small = false}) {
    final double width = large ? 220 : (small ? 90 : 120);
    final double height = large ? 320 : (small ? 135 : 180);

    // 카드 해석 데이터 가져오기
    final interpretation = card.positionKey != null
        ? widget.result.positionInterpretations[card.positionKey]
        : null;

    final cardWidget = GestureDetector(
      onTap: () {
        // 카드 상세 모달 열기
        TarotCardDetailModal.show(
          context,
          card: card,
          question: widget.result.question,
          interpretation: interpretation != null
              ? {'interpretation': interpretation}
              : null,
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // 카드 이미지 (역방향일 경우 180도 회전)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(small ? 4 : 6),
                      child: Transform.rotate(
                        angle: card.isReversed ? 3.14159 : 0, // 180도 회전 (π 라디안)
                        child: Image.asset(
                          card.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF5F5F5),
                                    Color(0xFFE0E0E0),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: const Color(0xFF7C3AED),
                                      size: large ? 48 : 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        card.cardNameKr,
                                        style: context.typography.labelMedium.copyWith(
                                          color: const Color(0xFF7C3AED),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // 역방향 표시
                if (card.isReversed)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DSColors.error,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: DSColors.error.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '역방향',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: small ? 9 : 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 카드 이름을 이미지 아래에 별도로 표시 (small이 아닐 때만)
    if (!small) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cardWidget,
          const SizedBox(height: 8),
          SizedBox(
            width: width,
            child: Text(
              card.cardNameKr,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: large ? 15 : 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return cardWidget;
  }

  Widget _buildOverallInterpretation(bool isDark) {
    final colors = context.colors;
    final typography = context.typography;

    final container = Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withValues(alpha: 0.05),
            const Color(0xFF3B82F6).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: isDark ? colors.border : const Color(0xFF7C3AED).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '종합 해석',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GptStyleTypingText(
            text: widget.result.overallInterpretation,
            style: typography.bodySmall.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.6,
            ),
            startTyping: _currentTypingSection >= 0,
            showGhostText: true,
            onComplete: () {
              if (mounted) setState(() => _currentTypingSection = 1);
            },
          ),
        ],
      ),
    );

    // ✅ UnifiedBlurWrapper로 마이그레이션 완료 (2024-12-07)
    return UnifiedBlurWrapper(
      isBlurred: widget.result.isBlurred,
      blurredSections: widget.result.blurredSections,
      sectionKey: 'overall_interpretation',
      child: container,
    );
  }

  // ✅ _buildBlurWrapper 제거됨 - UnifiedBlurWrapper 사용

  Widget _buildIndividualInterpretations(bool isDark) {
    if (widget.result.spreadType == TarotSpreadType.single) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개별 카드 해석',
          style: typography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        ...widget.result.positionInterpretations.entries.map((entry) {
          final index = widget.result.positionInterpretations.keys.toList().indexOf(entry.key);
          final card = widget.result.cards[index];

          final container = Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: colors.border,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: typography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      card.fullName,
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value,
                  style: typography.bodySmall.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );

          // ✅ 2번째(card_2), 3번째(card_3) 카드는 블러 처리
          return UnifiedBlurWrapper(
            isBlurred: widget.result.isBlurred,
            blurredSections: widget.result.blurredSections,
            sectionKey: 'card_${index + 1}',  // card_1, card_2, card_3, ...
            child: container,
          );
        }),
      ],
    );
  }

}