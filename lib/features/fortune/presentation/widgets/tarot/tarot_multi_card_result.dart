import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../domain/models/tarot_card_model.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../services/ad_service.dart';
import 'tarot_card_detail_modal.dart';
import '../../../../../core/theme/typography_unified.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 20,
                color: const Color(0xFF7C3AED),
              ),
              SizedBox(width: 8),
              Text(
                '질문',
                style: TypographyUnified.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.result.question,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${widget.result.spreadType.displayName} • ${widget.result.cards.length}장',
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[index], index, isDark),
                SizedBox(height: 8),
                Text(
                  ['과거', '현재', '미래'][index],
                  style: TypographyUnified.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[0], 0, isDark, small: true),
                SizedBox(height: 4),
                Text('나', style: TypographyUnified.labelSmall.copyWith( color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight)),
              ],
            ),
          ),
          // 상대의 마음 (오른쪽)
          Positioned(
            right: 0,
            top: 100,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[1], 1, isDark, small: true),
                SizedBox(height: 4),
                Text('상대', style: TypographyUnified.labelSmall.copyWith( color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight)),
              ],
            ),
          ),
          // 과거 (위)
          Positioned(
            top: 0,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[2], 2, isDark, small: true),
                SizedBox(height: 4),
                Text('과거', style: TypographyUnified.labelSmall.copyWith( color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight)),
              ],
            ),
          ),
          // 현재 관계 (중앙)
          Positioned(
            top: 150,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[3], 3, isDark, small: true),
                SizedBox(height: 4),
                Text('현재', style: TypographyUnified.labelSmall.copyWith( color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight)),
              ],
            ),
          ),
          // 미래 (아래)
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[4], 4, isDark, small: true),
                SizedBox(height: 4),
                Text('미래', style: TypographyUnified.labelSmall.copyWith( color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelticCrossLayout(bool isDark) {
    // 켈틱 크로스는 복잡하므로 그리드로 표시
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.result.cards.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              child: _buildCardItem(widget.result.cards[index], index, isDark, small: true),
            ),
            SizedBox(height: 4),
            Text(
              '${index + 1}',
              style: TypographyUnified.labelTiny.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardItem(TarotCard card, int index, bool isDark, {bool large = false, bool small = false}) {
    double width = large ? 220 : (small ? 90 : 120);
    double height = large ? 320 : (small ? 135 : 180);

    return GestureDetector(
      onTap: () {
        // 카드 상세 모달 열기
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TarotCardDetailModal(card: card),
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
              color: TossDesignSystem.black.withValues(alpha: 0.15),
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
                  Container(
                  color: TossDesignSystem.white,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 0.65, // 타로 카드 비율
                      child: Transform.rotate(
                        angle: card.isReversed ? 3.14159 : 0, // 180도 회전 (π 라디안)
                        child: Builder(
                          builder: (context) {
                            print('[Tarot] 이미지 경로: ${card.imagePath}');
                            print('[Tarot] 카드 이름: ${card.cardNameKr}');
                            print('[Tarot] 덱 타입: ${card.deckType}');
                            return Image.asset(
                              card.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('[Tarot] ❌ 이미지 로드 실패: ${card.imagePath}');
                                print('[Tarot] ❌ 에러: $error');
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFF5F5F5),
                                        const Color(0xFFE0E0E0),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFF7C3AED),
                                          size: large ? 48 : 32,
                                        ),
                                        SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            card.cardNameKr,
                                            style: TypographyUnified.labelMedium.copyWith(
                                              color: Color(0xFF7C3AED),
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
                            );
                          },
                        ),
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
                        color: TossDesignSystem.error,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: TossDesignSystem.error.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '역방향',
                        style: TextStyle(
                          color: TossDesignSystem.white,
                          fontSize: small ? 9 : 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                // 카드 이름 (작은 카드가 아닐 때만)
                if (!small)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(large ? 12 : 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            TossDesignSystem.white.withValues(alpha: 0.0),
                            TossDesignSystem.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                      child: Text(
                        card.cardNameKr,
                        style: TextStyle(
                          color: TossDesignSystem.white,
                          fontSize: large ? 16 : 13,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: TossDesignSystem.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildOverallInterpretation(bool isDark) {
    final container = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withValues(alpha: 0.05),
            const Color(0xFF3B82F6).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : const Color(0xFF7C3AED).withValues(alpha: 0.1),
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
              SizedBox(width: 8),
              Text(
                '종합 해석',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            widget.result.overallInterpretation,
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );

    // ✅ 블러 처리
    return _buildBlurWrapper(
      child: container,
      sectionKey: 'overall_interpretation',
    );
  }

  /// 블러 래퍼 (블러 상태일 때만 블러 효과 적용)
  Widget _buildBlurWrapper({required Widget child, required String sectionKey}) {
    if (!widget.result.isBlurred || !widget.result.blurredSections.contains(sectionKey)) {
      return child;  // 블러 불필요
    }

    // ✅ 블러 처리된 콘텐츠
    return Stack(
      children: [
        // 원본 콘텐츠 (블러 처리)
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        // 반투명 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // 중앙 잠금 아이콘
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualInterpretations(bool isDark) {
    if (widget.result.spreadType == TarotSpreadType.single) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개별 카드 해석',
          style: TypographyUnified.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.result.positionInterpretations.entries.map((entry) {
          final index = widget.result.positionInterpretations.keys.toList().indexOf(entry.key);
          final card = widget.result.cards[index];

          final container = Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
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
                          style: TypographyUnified.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      card.fullName,
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  entry.value,
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w400,
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );

          // ✅ 2번째(card_2), 3번째(card_3) 카드는 블러 처리
          return _buildBlurWrapper(
            child: container,
            sectionKey: 'card_${index + 1}',  // card_1, card_2, card_3, ...
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: '다시 뽑기',
            onPressed: () async {
              await AdService.instance.showInterstitialAdWithCallback(
                onAdCompleted: () async {
                  widget.onRetry();
                },
                onAdFailed: () async {
                  widget.onRetry();
                },
              );
            },
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: '다른 운세 보기',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TossButtonStyle.secondary,
            size: TossButtonSize.large,
          ),
        ),
      ],
    );
  }
}