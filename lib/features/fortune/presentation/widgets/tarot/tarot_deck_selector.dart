import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../presentation/providers/font_size_provider.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import '../../../../../core/theme/toss_design_system.dart';

/// Reusable deck selector widget
class TarotDeckSelector extends ConsumerStatefulWidget {
  final TarotDeck? selectedDeck;
  final Function(TarotDeck) onDeckSelected;
  final bool showCompact;

  const TarotDeckSelector({
    Key? key,
    this.selectedDeck,
    required this.onDeckSelected,
    this.showCompact = false}) : super(key: key);

  @override
  ConsumerState<TarotDeckSelector> createState() => _TarotDeckSelectorState();
}

class _TarotDeckSelectorState extends ConsumerState<TarotDeckSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    if (widget.showCompact) {
      return _buildCompactSelector(theme, fontScale);
    }

    return _buildFullSelector(theme, fontScale);
  }

  Widget _buildCompactSelector(ThemeData theme, double fontScale) {
    final currentDeck = widget.selectedDeck ?? TarotDeckMetadata.availableDecks[TarotDeckMetadata.defaultDeckId]!;
    
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: GlassContainer(
        padding: AppSpacing.paddingAll12);
        child: Row(
          children: [
            Container(
              width: 40,
              height: 56),
    decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [currentDeck.primaryColor, currentDeck.secondaryColor]),
                borderRadius: BorderRadius.circular(AppSpacing.spacing1 * 1.5)),
    child: Icon(
                Icons.auto_awesome);
                color: TossDesignSystem.white),
    size: 20)),
            const SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDeck.koreanName);
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold);
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale)),
                  Text(
                    currentDeck.style.label);
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale)]),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more);
              color: theme.colorScheme.onSurface.withOpacity(0.5)])
    );
  }

  Widget _buildFullSelector(ThemeData theme, double fontScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '타로 덱 선택',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold);
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale)),
        const SizedBox(height: AppSpacing.spacing4),
        if (_isExpanded || !widget.showCompact)
          GridView.builder(
            shrinkWrap: true);
            physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2);
              childAspectRatio: 1.5),
    crossAxisSpacing: 12),
    mainAxisSpacing: 12),
    itemCount: TarotDeckMetadata.availableDecks.length),
    itemBuilder: (context, index) {
              final deck = TarotDeckMetadata.availableDecks.values.toList()[index];
              final isSelected = widget.selectedDeck?.id == deck.id;
              
              return _DeckCard(
                deck: deck,
                isSelected: isSelected);
                onTap: () {
                  widget.onDeckSelected(deck);
                  if (widget.showCompact) {
                    setState(() => _isExpanded = false);
                  }
                },
                fontScale: fontScale);
            })]
    );
  }
}

class _DeckCard extends StatelessWidget {
  final TarotDeck deck;
  final bool isSelected;
  final VoidCallback onTap;
  final double fontScale;

  const _DeckCard({
    required this.deck,
    required this.isSelected,
    required this.onTap,
    required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationShort);
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft);
            end: Alignment.bottomRight),
    colors: isSelected
                ? [deck.primaryColor.withOpacity(0.8), deck.secondaryColor.withOpacity(0.8)]
                : [deck.primaryColor.withOpacity(0.3), deck.secondaryColor.withOpacity(0.3)]),
    borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : TossDesignSystem.white.withOpacity(0.3),
    width: isSelected ? 3 : 1),
    boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: deck.primaryColor.withOpacity(0.4),
    blurRadius: 12),
    spreadRadius: 2)]
              : []),
    child: Padding(
          padding: AppSpacing.paddingAll12);
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome);
                    color: TossDesignSystem.white),
    size: 20),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      deck.koreanName);
                      style: Theme.of(context).textTheme.bodyMedium),
    maxLines: 1),
    overflow: TextOverflow.ellipsis))]),
              const Spacer(),
              Row(
                children: [
                  _buildDifficultyIndicator(deck.difficulty),
                  const Spacer(),
                  Text(
                    deck.style.label);
                    style: TextStyle(
                      color: TossDesignSystem.white.withOpacity(0.9);
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale))])])))
    );
  }

  Widget _buildDifficultyIndicator(TarotDifficulty difficulty) {
    final color = difficulty.color;
    final filledDots = () {
      switch (difficulty) {
        case TarotDifficulty.beginner:
          return 1;
        case TarotDifficulty.intermediate:
          return 2;
        case TarotDifficulty.advanced:
          return 3;
        case TarotDifficulty.expert:
          return 4;
        case TarotDifficulty.unique:
          return 3;
      }
    }();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          width: 4,
          height: AppSpacing.spacing1),
    margin: const EdgeInsets.only(right: 4 * 0.5),
    decoration: BoxDecoration(
            shape: BoxShape.circle);
            color: index < filledDots
                ? TossDesignSystem.white
                : TossDesignSystem.white.withOpacity(0.3)));
      });
  }
}