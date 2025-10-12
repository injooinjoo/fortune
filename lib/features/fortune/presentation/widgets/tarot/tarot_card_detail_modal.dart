import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../domain/models/tarot_card_model.dart';

/// 타로 카드 상세 정보를 표시하는 모달
///
/// - 카드 이미지를 크게 표시
/// - 탭하여 카드 뒤집기 가능
/// - X 버튼으로 닫기
/// - 위로 스와이프하여 닫기
class TarotCardDetailModal extends StatefulWidget {
  final TarotCard card;

  const TarotCardDetailModal({
    super.key,
    required this.card,
  });

  @override
  State<TarotCardDetailModal> createState() => _TarotCardDetailModalState();
}

class _TarotCardDetailModalState extends State<TarotCardDetailModal> {
  bool _isFlipped = false;

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더 (X 버튼)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), // 균형 유지
                    Text(
                      widget.card.cardNameKr,
                      style: TossDesignSystem.heading3.copyWith(
                        color: TossDesignSystem.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF4E5968),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 카드 이미지 영역 (탭하여 뒤집기)
              Expanded(
                child: GestureDetector(
                  onTap: _toggleFlip,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotate,
                          child: child,
                          builder: (context, child) {
                            final angle = rotate.value * 3.14159; // π radians
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              alignment: Alignment.center,
                              child: child,
                            );
                          },
                        );
                      },
                      child: _isFlipped
                          ? _buildCardBack()
                          : _buildCardFront(),
                    ),
                  ),
                ),
              ),

              // 카드 정보
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      widget.card.isReversed ? '역방향' : '정방향',
                      style: TossDesignSystem.body1.copyWith(
                        color: widget.card.isReversed
                            ? TossDesignSystem.error
                            : TossDesignSystem.bluePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '탭하여 카드를 뒤집어보세요',
                      style: TossDesignSystem.caption.copyWith(
                        color: const Color(0xFF8B95A1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 카드 앞면 (실제 타로 이미지)
  Widget _buildCardFront() {
    return Container(
      key: const ValueKey('front'),
      constraints: const BoxConstraints(
        maxWidth: 280,
        maxHeight: 480,
      ),
      child: AspectRatio(
        aspectRatio: 0.65,
        child: Transform.rotate(
          angle: widget.card.isReversed ? 3.14159 : 0, // 역방향이면 180도 회전
          child: Image.asset(
            widget.card.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Color(0xFF8B95A1),
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 카드 뒷면 (타로 카드 뒷면 디자인)
  Widget _buildCardBack() {
    return Container(
      key: const ValueKey('back'),
      constraints: const BoxConstraints(
        maxWidth: 280,
        maxHeight: 480,
      ),
      child: AspectRatio(
        aspectRatio: 0.65,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TossDesignSystem.purple.withOpacity(0.8),
                TossDesignSystem.bluePrimary.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 16),
                Text(
                  'TAROT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
