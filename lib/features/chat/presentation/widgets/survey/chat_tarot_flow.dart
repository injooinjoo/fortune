import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../fortune/domain/models/tarot_card_model.dart';

/// 채팅 내 타로 플로우 위젯
///
/// 단계:
/// 1. 스프레드 선택 (1/3/5/10장)
/// 2. 카드 선택 (22장 중 N장)
/// 3. 완료 콜백
class ChatTarotFlow extends ConsumerStatefulWidget {
  final void Function(Map<String, dynamic> tarotData) onComplete;
  final String? question;

  const ChatTarotFlow({
    super.key,
    required this.onComplete,
    this.question,
  });

  @override
  ConsumerState<ChatTarotFlow> createState() => _ChatTarotFlowState();
}

class _ChatTarotFlowState extends ConsumerState<ChatTarotFlow> {
  _TarotFlowPhase _phase = _TarotFlowPhase.spreadSelection;
  TarotSpreadType? _selectedSpread;
  final List<int> _selectedCards = [];
  bool _isAnimating = false;

  // 22장의 메이저 아르카나 카드
  static const int totalCards = 22;

  void _selectSpread(TarotSpreadType spread) {
    DSHaptics.light();
    setState(() {
      _selectedSpread = spread;
      _phase = _TarotFlowPhase.cardSelection;
      _selectedCards.clear();
    });
  }

  void _selectCard(int cardIndex) {
    if (_isAnimating) return;
    if (_selectedSpread == null) return;

    final requiredCards = _selectedSpread!.cardCount;

    if (_selectedCards.contains(cardIndex)) {
      // 선택 해제
      DSHaptics.light();
      setState(() {
        _selectedCards.remove(cardIndex);
      });
    } else if (_selectedCards.length < requiredCards) {
      // 카드 선택
      DSHaptics.medium();
      setState(() {
        _selectedCards.add(cardIndex);
      });

      // 모든 카드 선택 완료
      if (_selectedCards.length == requiredCards) {
        _completeSelection();
      }
    }
  }

  void _completeSelection() {
    setState(() {
      _isAnimating = true;
    });

    DSHaptics.success();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      widget.onComplete({
        'spreadType': _selectedSpread!.name,
        'spreadDisplayName': _selectedSpread!.displayName,
        'cardCount': _selectedSpread!.cardCount,
        'selectedCardIndices': _selectedCards,
        'question': widget.question,
        // 기본 덱 사용 (Rider-Waite)
        'deck': 'rider_waite',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _phase == _TarotFlowPhase.spreadSelection
            ? _buildSpreadSelector(colors, typography)
            : _buildCardSelector(colors, typography),
      ),
    );
  }

  Widget _buildSpreadSelector(DSColorScheme colors, DSTypographyScheme typography) {
    return Column(
      key: const ValueKey('spreadSelector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '몇 장의 카드를 뽑으시겠어요?',
          style: typography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.xs,
          runSpacing: DSSpacing.xs,
          children: TarotSpreadType.sortedByDifficulty.map((spread) {
            return _SpreadChip(
              spread: spread,
              onTap: () => _selectSpread(spread),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardSelector(DSColorScheme colors, DSTypographyScheme typography) {
    final requiredCards = _selectedSpread?.cardCount ?? 1;
    final selectedCount = _selectedCards.length;

    return Column(
      key: const ValueKey('cardSelector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 선택 진행 상황
        Row(
          children: [
            Text(
              '카드를 선택하세요',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.accentSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                '$selectedCount / $requiredCards',
                style: typography.labelSmall.copyWith(
                  color: colors.accentSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),

        // 카드 그리드
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalCards,
            itemBuilder: (context, index) {
              final isSelected = _selectedCards.contains(index);
              final selectionOrder = isSelected
                  ? _selectedCards.indexOf(index) + 1
                  : null;

              return Padding(
                padding: const EdgeInsets.only(right: DSSpacing.xs),
                child: _TarotCardItem(
                  index: index,
                  isSelected: isSelected,
                  selectionOrder: selectionOrder,
                  isDisabled: !isSelected && selectedCount >= requiredCards,
                  onTap: () => _selectCard(index),
                ),
              );
            },
          ),
        ),

        // 선택된 카드가 있으면 리셋 버튼 표시
        if (_selectedCards.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          TextButton.icon(
            onPressed: () {
              DSHaptics.light();
              setState(() {
                _selectedCards.clear();
              });
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('다시 선택'),
            style: TextButton.styleFrom(
              foregroundColor: colors.textSecondary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }
}

enum _TarotFlowPhase {
  spreadSelection,
  cardSelection,
}

/// 스프레드 선택 칩
class _SpreadChip extends StatelessWidget {
  final TarotSpreadType spread;
  final VoidCallback onTap;

  const _SpreadChip({
    required this.spread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.full),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${spread.cardCount}장',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: DSSpacing.xxs),
              Text(
                spread.displayName,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 타로 카드 아이템
class _TarotCardItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final int? selectionOrder;
  final bool isDisabled;
  final VoidCallback onTap;

  const _TarotCardItem({
    required this.index,
    required this.isSelected,
    this.selectionOrder,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: isDisabled && !isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? [colors.accentSecondary, colors.accentSecondary.withValues(alpha: 0.8)]
                : [
                    colors.surface,
                    colors.surface.withValues(alpha: 0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.sm),
          border: Border.all(
            color: isSelected
                ? colors.accentSecondary
                : colors.textPrimary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accentSecondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // 카드 뒷면 패턴
            Center(
              child: Icon(
                Icons.auto_awesome,
                color: isSelected
                    ? colors.surface.withValues(alpha: 0.8)
                    : colors.textSecondary.withValues(alpha: 0.3),
                size: 24,
              ),
            ),

            // 선택 순서 표시
            if (isSelected && selectionOrder != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$selectionOrder',
                      style: typography.labelSmall.copyWith(
                        color: colors.accentSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),

            // 비활성화 오버레이
            if (isDisabled && !isSelected)
              Container(
                decoration: BoxDecoration(
                  color: colors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
