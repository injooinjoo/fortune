import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/tarot_card_model.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../services/ad_service.dart';
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
                  _buildQuestionHeader(),
                  const SizedBox(height: 32),

                  // 카드 레이아웃
                  _buildCardLayout(),
                  const SizedBox(height: 32),

                  // 전체 해석
                  _buildOverallInterpretation(),
                  const SizedBox(height: 24),

                  // 개별 카드 해석
                  _buildIndividualInterpretations(),
                  const SizedBox(height: 40),

                  // 액션 버튼들
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
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
              const SizedBox(width: 8),
              const Text(
                '질문',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B95A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.result.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191919),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.result.spreadType.displayName} • ${widget.result.cards.length}장',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8B95A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout() {
    switch (widget.result.spreadType) {
      case TarotSpreadType.single:
        return _buildSingleCardLayout();
      case TarotSpreadType.threeCard:
        return _buildThreeCardLayout();
      case TarotSpreadType.relationship:
        return _buildRelationshipLayout();
      case TarotSpreadType.celticCross:
        return _buildCelticCrossLayout();
    }
  }

  Widget _buildSingleCardLayout() {
    final card = widget.result.cards.first;
    return Center(
      child: _buildCardItem(card, 0, large: true),
    );
  }

  Widget _buildThreeCardLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[index], index),
                const SizedBox(height: 8),
                Text(
                  ['과거', '현재', '미래'][index],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B95A1),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRelationshipLayout() {
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
                _buildCardItem(widget.result.cards[0], 0, small: true),
                const SizedBox(height: 4),
                const Text('나', style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1))),
              ],
            ),
          ),
          // 상대의 마음 (오른쪽)
          Positioned(
            right: 0,
            top: 100,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[1], 1, small: true),
                const SizedBox(height: 4),
                const Text('상대', style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1))),
              ],
            ),
          ),
          // 과거 (위)
          Positioned(
            top: 0,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[2], 2, small: true),
                const SizedBox(height: 4),
                const Text('과거', style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1))),
              ],
            ),
          ),
          // 현재 관계 (중앙)
          Positioned(
            top: 150,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[3], 3, small: true),
                const SizedBox(height: 4),
                const Text('현재', style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1))),
              ],
            ),
          ),
          // 미래 (아래)
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                _buildCardItem(widget.result.cards[4], 4, small: true),
                const SizedBox(height: 4),
                const Text('미래', style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelticCrossLayout() {
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
              child: _buildCardItem(widget.result.cards[index], index, small: true),
            ),
            const SizedBox(height: 4),
            Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B95A1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardItem(TarotCard card, int index, {bool large = false, bool small = false}) {
    double width = large ? 180 : (small ? 80 : 100);
    double height = large ? 260 : (small ? 120 : 145);

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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
                    child: Image.asset(
                      card.imagePath,
                      fit: BoxFit.contain, // cover → contain으로 변경
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF8B95A1),
                              size: 30,
                            ),
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.error.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '역방향',
                    style: TextStyle(
                      color: TossDesignSystem.white,
                      fontSize: small ? 9 : 10,
                      fontWeight: FontWeight.w600,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        TossDesignSystem.white.withValues(alpha: 0.0),
                        TossDesignSystem.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    card.cardNameKr,
                    style: TextStyle(
                      color: TossDesignSystem.white,
                      fontSize: large ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallInterpretation() {
    return Container(
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
          color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
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
              const Text(
                '종합 해석',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.result.overallInterpretation,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF191919),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualInterpretations() {
    if (widget.result.spreadType == TarotSpreadType.single) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '개별 카드 해석',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191919),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.result.positionInterpretations.entries.map((entry) {
          final index = widget.result.positionInterpretations.keys.toList().indexOf(entry.key);
          final card = widget.result.cards[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191919),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
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