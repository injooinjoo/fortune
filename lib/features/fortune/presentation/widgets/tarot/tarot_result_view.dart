import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../presentation/providers/font_size_provider.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/loading_states.dart';
import '../../../../../shared/components/app_header.dart' show FontSize;
import 'tarot_card_widget.dart';

/// Simplified tarot reading result view
class TarotResultView extends ConsumerStatefulWidget {
  final List<int> selectedCards;
  final TarotDeck selectedDeck;
  final String? question;
  final String spreadType;
  final Map<String, dynamic>? readingResult;
  final bool isLoading;
  final VoidCallback? onNewReading;
  final VoidCallback? onShare;

  const TarotResultView({
    Key? key,
    required this.selectedCards,
    required this.selectedDeck,
    this.question,
    required this.spreadType,
    this.readingResult,
    this.isLoading = false,
    this.onNewReading,
    this.onShare}) : super(key: key);

  @override
  ConsumerState<TarotResultView> createState() => _TarotResultViewState();
}

class _TarotResultViewState extends ConsumerState<TarotResultView>
    with TickerProviderStateMixin {
  final Map<int, bool> _flippedCards = {};
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _flipCard(int index) {
    print('Fortune cached');
    print('state: ${_flippedCards[index] ?? false}');
    setState(() {
      _flippedCards[index] = !(_flippedCards[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[TarotResult] === Build Start ===');
    print('[TarotResult] isLoading: ${widget.isLoading}');
    print('[TarotResult] selectedCards: ${widget.selectedCards}');
    print('[TarotResult] _entranceAnimation.value: ${_entranceAnimation.value}');
    print('[TarotResult] _entranceAnimation.status: ${_entranceAnimation.status}');
    
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    if (widget.isLoading) {
      print('[TarotResult] Showing loading widget');
      return const LoadingStateWidget(
        message: '타로 해석 중...');
    }

    return AnimatedBuilder(
      animation: _entranceAnimation,
      builder: (context, child) {
        print('value: ${_entranceAnimation.value}');
        final opacityValue = _entranceAnimation.value;
        print('Fortune cached');
        if (opacityValue < 0.0 || opacityValue > 1.0) {
          print('Fortune cached');
        }
        return Opacity(
          opacity: opacityValue.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _entranceAnimation.value)),
            child: Column(
              children: [
                // Header
                _buildHeader(theme, fontScale),
                const SizedBox(height: 24),
                
                // Selected cards display
                _buildCardsDisplay(theme, fontScale),
                const SizedBox(height: 32),
                
                // Reading result
                if (widget.readingResult != null)
                  Expanded(
                    child: _buildReadingResult(theme, fontScale)),
                
                // Action buttons
                _buildActionButtons(theme, fontScale)])));
      });
  }

  Widget _buildHeader(ThemeData theme, double fontScale) {
    return Column(
      children: [
        Text(
          '타로 리딩 결과',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24 * fontScale)),
        if (widget.question != null && widget.question!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.question!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16 * fontScale,
              fontStyle: FontStyle.italic),
            textAlign: TextAlign.center)]]);
  }

  Widget _buildCardsDisplay(ThemeData theme, double fontScale) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedCards.length,
        itemBuilder: (context, index) {
          final cardIndex = widget.selectedCards[index];
          final isFlipped = _flippedCards[index] ?? false;
          
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == widget.selectedCards.length - 1 ? 16 : 8),
            child: Column(
              children: [
                TarotCardWidget(
                  cardIndex: cardIndex,
                  deck: widget.selectedDeck,
                  width: 100,
                  height: 150,
                  showFront: isFlipped,
                  onTap: () => _flipCard(index)),
                const SizedBox(height: 8),
                Text(
                  _getPositionLabel(index),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * fontScale,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadingResult(ThemeData theme, double fontScale) {
    final result = widget.readingResult!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall interpretation
          if (result['overallInterpretation'] != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.primary,
                        size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '전체 해석',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * fontScale,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result['overallInterpretation'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16 * fontScale,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Individual card interpretations
          if (result['cardInterpretations'] != null) ...[
            Text(
              '카드별 해석',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18 * fontScale,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.selectedCards.length, (index) {
              final interpretation = result['cardInterpretations'][index];
              if (interpretation == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getPositionLabel(index),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * fontScale,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        interpretation['meaning'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14 * fontScale,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          
          // Advice
          if (result['advice'] != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.secondary,
                        size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * fontScale,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result['advice'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16 * fontScale,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, double fontScale) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (widget.onNewReading != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onNewReading,
                icon: const Icon(Icons.refresh),
                label: Text(
                  '새로운 리딩',
                  style: TextStyle(fontSize: 16 * fontScale),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (widget.onShare != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.onShare,
                icon: const Icon(Icons.share),
                label: Text(
                  '공유하기',
                  style: TextStyle(fontSize: 16 * fontScale),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPositionLabel(int index) {
    switch (widget.spreadType) {
      case 'three':
        return ['과거', '현재', '미래'][index];
      case 'celtic':
        return [
          '현재 상황',
          '도전/십자가',
          '먼 과거',
          '최근 과거',
          '가능한 미래',
          '가까운 미래',
          '당신의 접근',
          '외부 영향',
          '희망과 두려움',
          '최종 결과'
        ][index];
      default:
        return '카드 ${index + 1}';
    }
  }
}