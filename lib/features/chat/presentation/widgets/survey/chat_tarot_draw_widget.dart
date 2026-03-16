import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/tarot/tarot_card_catalog.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../character/presentation/utils/tarot_chat_payload_utils.dart';

class ChatTarotDrawWidget extends StatefulWidget {
  final String deckId;
  final String? purpose;
  final String? questionText;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final Random? random;

  const ChatTarotDrawWidget({
    super.key,
    required this.deckId,
    required this.onSubmit,
    this.purpose,
    this.questionText,
    this.random,
  });

  @override
  State<ChatTarotDrawWidget> createState() => _ChatTarotDrawWidgetState();
}

class _ChatTarotDrawWidgetState extends State<ChatTarotDrawWidget> {
  static const int _fanSlotCount = 12;

  late final Random _random;
  late final List<int> _availableSlots;
  final List<int> _usedCardIndices = <int>[];
  final List<TarotCardCatalogEntry> _drawnCards = <TarotCardCatalogEntry>[];
  int? _selectedSlot;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _availableSlots = List<int>.generate(_fanSlotCount, (index) => index);
  }

  int get _requiredCardCount =>
      TarotChatPayloadUtils.resolveCardCount(widget.purpose);

  String get _spreadType =>
      TarotChatPayloadUtils.resolveSpreadType(widget.purpose);

  List<String> get _positionNames =>
      TarotChatPayloadUtils.positionNamesForPurpose(widget.purpose);

  bool get _isComplete => _drawnCards.length >= _requiredCardCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final deck = TarotDeckMetadata.getDeck(widget.deckId);
    final remainingCount =
        (_requiredCardCount - _drawnCards.length).clamp(0, 99);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.xl),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                children: [
                  _StatusPill(label: deck.koreanName),
                  _StatusPill(
                    label: TarotChatPayloadUtils.spreadDisplayName(_spreadType),
                  ),
                  _StatusPill(
                      label: '${_drawnCards.length}/$_requiredCardCount'),
                ],
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                remainingCount == 0
                    ? '카드가 모두 골라졌어요. 리딩을 열고 있어요.'
                    : '펼쳐진 카드 중 한 장을 고르고 아래 버튼으로 확정하세요.',
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              SizedBox(
                height: 164,
                child: _buildCardFan(context, deck),
              ),
              const SizedBox(height: DSSpacing.md),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _drawnCards.length / _requiredCardCount,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          deck.primaryColor,
                          deck.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.full),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_drawnCards.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          Text(
            '뽑은 카드',
            style: context.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _drawnCards.length,
              separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
              itemBuilder: (context, index) {
                final entry = _drawnCards[index];
                return SizedBox(
                  width: 108,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(DSRadius.lg),
                          child: Image.asset(
                            entry.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _CardBack(
                              deck: deck,
                              isHighlighted: false,
                              isUnavailable: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        _positionNames[index],
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        entry.cardNameKr,
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: DSSpacing.md),
        SizedBox(
          width: double.infinity,
          child: DSButton.primary(
            key: const ValueKey('tarot-draw-confirm'),
            text: _isComplete
                ? '리딩 준비 중'
                : _selectedSlot == null
                    ? '먼저 한 장을 고르세요'
                    : '${_drawnCards.length + 1}번째 카드 확정',
            size: DSButtonSize.medium,
            onPressed: (_selectedSlot == null || _isComplete || _isSubmitting)
                ? null
                : _confirmDraw,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFan(BuildContext context, TarotDeck deck) {
    final colors = context.colors;
    final availableSlots = _availableSlots.toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotCount = availableSlots.length;
        final cardWidth = min(84.0, constraints.maxWidth / 3.6);
        final usableWidth = max(constraints.maxWidth - cardWidth, 0.0);
        final step = slotCount <= 1 ? 0.0 : usableWidth / (slotCount - 1);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DSRadius.xl),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.backgroundSecondary.withValues(alpha: 0.32),
                      colors.backgroundSecondary.withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),
            for (var i = 0; i < slotCount; i++)
              Positioned(
                left: i * step,
                top: _selectedSlot == availableSlots[i] ? 4 : 18,
                child: Transform.rotate(
                  angle: lerpDouble(
                      -0.48, 0.48, slotCount <= 1 ? 0.5 : i / (slotCount - 1))!,
                  child: GestureDetector(
                    key: ValueKey('tarot-slot-${availableSlots[i]}'),
                    onTap: _isComplete
                        ? null
                        : () {
                            setState(() {
                              _selectedSlot = availableSlots[i];
                            });
                          },
                    child: _CardBack(
                      deck: deck,
                      isHighlighted: _selectedSlot == availableSlots[i],
                      isUnavailable: false,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDraw() async {
    if (_selectedSlot == null || _isSubmitting || _isComplete) {
      return;
    }

    final remainingIndices = TarotCardCatalog.orderedIndices
        .where((index) => !_usedCardIndices.contains(index))
        .toList(growable: false);
    if (remainingIndices.isEmpty) {
      return;
    }

    final drawnIndex =
        remainingIndices[_random.nextInt(remainingIndices.length)];
    final card = TarotCardCatalog.fromIndex(
      drawnIndex,
      deckId: widget.deckId,
    );

    setState(() {
      _availableSlots.remove(_selectedSlot);
      _selectedSlot = null;
      _usedCardIndices.add(drawnIndex);
      _drawnCards.add(card);
    });

    if (_isComplete) {
      setState(() {
        _isSubmitting = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted) {
        return;
      }

      widget.onSubmit(
        TarotChatPayloadUtils.buildSelectionPayload(
          deckId: widget.deckId,
          purpose: widget.purpose,
          questionText: widget.questionText,
          selectedCardIndices: _usedCardIndices,
        ),
      );
    }
  }
}

class _CardBack extends StatelessWidget {
  final TarotDeck deck;
  final bool isHighlighted;
  final bool isUnavailable;

  const _CardBack({
    required this.deck,
    required this.isHighlighted,
    required this.isUnavailable,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 82,
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            deck.primaryColor.withValues(alpha: isUnavailable ? 0.4 : 0.95),
            deck.secondaryColor.withValues(alpha: isUnavailable ? 0.4 : 0.95),
          ],
        ),
        border: Border.all(
          color: isHighlighted
              ? colors.textPrimary.withValues(alpha: 0.16)
              : colors.border.withValues(alpha: 0.32),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                deck.primaryColor.withValues(alpha: isHighlighted ? 0.2 : 0.1),
            blurRadius: isHighlighted ? 18 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  border: Border.all(
                    color: colors.surface.withValues(alpha: 0.32),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.auto_awesome,
              color: colors.surface,
              size: 24,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Text(
                deck.code,
                style: context.labelSmall.copyWith(
                  color: colors.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.full),
      ),
      child: Text(
        label,
        style: context.labelSmall.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
