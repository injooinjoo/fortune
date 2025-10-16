import 'package:flutter/material.dart';
import '../../../../../shared/components/toss_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../core/constants/tarot_metadata.dart';
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
    super.key,
    required this.selectedCards,
    required this.selectedDeck,
    this.question,
    required this.spreadType,
    this.readingResult,
    this.isLoading = false,
    this.onNewReading,
    this.onShare});

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
    debugPrint('Fortune cached');
    debugPrint('state: ${_flippedCards[index] ?? false}');
    setState(() {
      _flippedCards[index] = !(_flippedCards[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    if (widget.isLoading) {
      return const LoadingStateWidget(
        message: '타로 카드를 해석하고 있습니다...\n당신의 질문에 맞는 답변을 준비 중입니다');
    }

    return AnimatedBuilder(
      animation: _entranceAnimation,
      builder: (context, child) {
        debugPrint('value: ${_entranceAnimation.value}');
        final opacityValue = _entranceAnimation.value;
        debugPrint('Fortune cached');
        if (opacityValue < 0.0 || opacityValue > 1.0) {
          debugPrint('Fortune cached');
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16 * fontScale,
              fontStyle: FontStyle.italic),
            textAlign: TextAlign.center)]]);
  }

  Widget _buildCardsDisplay(ThemeData theme, double fontScale) {
    return SizedBox(
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
    final result = widget.readingResult;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문에 대한 요약 답변
          GlassContainer(
            padding: const EdgeInsets.all(20),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
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
                      '당신의 질문에 대한 답',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18 * fontScale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  result != null && result['overallInterpretation'] != null
                      ? result['overallInterpretation']
                      : _generateDefaultInterpretation(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16 * fontScale,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Individual card interpretations
          Text(
            '카드별 상세 해석',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18 * fontScale,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.selectedCards.length, (index) {
            final interpretation = result != null && result['cardInterpretations'] != null 
                ? result['cardInterpretations'][index]
                : _generateCardInterpretation(widget.selectedCards[index], index);
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
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
          
          // Advice
          if (result != null && result['advice'] != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
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
              child: TossButton(
                text: '새로운 리딩',
                onPressed: widget.onNewReading,
                style: TossButtonStyle.ghost,
                size: TossButtonSize.medium,
                icon: Icon(Icons.refresh),
              ),
            ),
          if (widget.onShare != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: TossButton(
                text: '공유하기',
                onPressed: widget.onShare,
                style: TossButtonStyle.primary,
                size: TossButtonSize.medium,
                icon: Icon(Icons.share),
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

  String _generateDefaultInterpretation() {
    // 선택된 카드의 메타데이터를 기반으로 기본 해석 생성
    if (widget.selectedCards.isEmpty) {
      return '카드를 해석하고 있습니다...';
    }

    final cards = widget.selectedCards.map((index) {
      final cardInfo = TarotMetadata.majorArcana[index % 22]; // Major Arcana만 사용
      return cardInfo;
    }).toList();

    String interpretation = '';
    
    if (widget.spreadType == 'three' && cards.length >= 3) {
      // 3장 스프레드 해석
      interpretation = '''당신의 과거는 ${cards[0]?.name ?? '알 수 없는 카드'}가 나타내듯이, ${cards[0]?.keywords.join(', ') ?? '신비로운 에너지'}와 관련이 있습니다.
      
현재 당신은 ${cards[1]?.name ?? '알 수 없는 카드'}의 영향 하에 있으며, ${cards[1]?.uprightMeaning ?? '중요한 전환점'}을 경험하고 있습니다.

미래에는 ${cards[2]?.name ?? '알 수 없는 카드'}가 암시하듯, ${cards[2]?.advice ?? '새로운 가능성'}이 기다리고 있습니다.''';
    } else if (cards.isNotEmpty) {
      // 단일 카드 또는 기타 스프레드
      final firstCard = cards[0];
      interpretation = '''${firstCard?.name ?? '선택하신 카드'}는 ${firstCard?.keywords.join(', ') ?? '깊은 의미'}를 상징합니다.

${firstCard?.uprightMeaning ?? '이 카드는 당신에게 중요한 메시지를 전달하고 있습니다.'}

${firstCard?.advice ?? '마음을 열고 새로운 가능성을 받아들이세요.'}''';
    }

    if (widget.question != null && widget.question!.isNotEmpty) {
      interpretation = '''당신의 질문 "${widget.question}"에 대한 답변입니다.

$interpretation''';
    }

    return interpretation;
  }

  Map<String, dynamic> _generateCardInterpretation(int cardIndex, int position) {
    final cardInfo = TarotMetadata.majorArcana[cardIndex % 22];
    if (cardInfo == null) {
      return {
        'cardName': '알 수 없는 카드',
        'interpretation': '이 카드의 의미를 해석 중입니다...'
      };
    }

    final positionMeaning = _getPositionLabel(position);
    
    return {
      'cardName': cardInfo.name,
      'keywords': cardInfo.keywords,
      'interpretation': '''$positionMeaning 위치의 ${cardInfo.name}:
      
${cardInfo.uprightMeaning}

이 카드가 전하는 메시지: ${cardInfo.advice}

${cardInfo.story != null ? '\n이야기: ${cardInfo.story!.substring(0, 200)}...' : ''}''',
      'element': cardInfo.element,
      'astrology': cardInfo.astrology,
    };
  }
}