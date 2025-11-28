import 'package:flutter/material.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../core/constants/tarot_metadata.dart';
import '../../../../../core/providers/user_settings_provider.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/loading_states.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/theme/toss_design_system.dart';
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
    setState(() {
      _flippedCards[index] = !(_flippedCards[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontScale = ref.watch(userSettingsProvider).fontScale;

    if (widget.isLoading) {
      return const LoadingStateWidget(
        message: '타로 카드를 해석하고 있습니다...\n당신의 질문에 맞는 답변을 준비 중입니다');
    }

    return AnimatedBuilder(
      animation: _entranceAnimation,
      builder: (context, child) {
        final opacityValue = _entranceAnimation.value;
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
          style: context.heading2.copyWith(
            fontWeight: FontWeight.bold)),
        if (widget.question != null && widget.question!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.question!,
            style: context.buttonMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
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
                      style: context.heading4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  result != null && result['overallInterpretation'] != null
                      ? result['overallInterpretation']
                      : _generateDefaultInterpretation(),
                  style: context.buttonMedium.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Individual card interpretations - 스토리텔링 스타일
          Row(
            children: [
              Icon(Icons.auto_stories, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                '카드별 상세 해석',
                style: context.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.selectedCards.length, (index) {
            final cardIndex = widget.selectedCards[index];
            final interpretation = result != null && result['cardInterpretations'] != null
                ? result['cardInterpretations'][index]
                : _generateCardInterpretation(cardIndex, index);
            if (interpretation == null) return const SizedBox.shrink();

            final cardInfo = TarotMetadata.majorArcana[cardIndex % 22];
            final imagePath = TarotHelper.getMajorArcanaImagePath(widget.selectedDeck.id, cardIndex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카드 헤더: 이미지 + 카드 이름 + 위치
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카드 이미지 미니 썸네일
                        Container(
                          width: 60,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: TossDesignSystem.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        widget.selectedDeck.primaryColor.withValues(alpha: 0.3),
                                        widget.selectedDeck.secondaryColor.withValues(alpha: 0.3),
                                      ],
                                    ),
                                  ),
                                  child: Icon(Icons.auto_awesome, color: widget.selectedDeck.primaryColor),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 카드 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 순서 배지 + 위치
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getPositionLabel(index),
                                      style: context.labelMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 카드 이름
                              Text(
                                cardInfo?.name ?? 'Card ${cardIndex + 1}',
                                style: context.heading4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // 키워드
                              if (cardInfo?.keywords.isNotEmpty ?? false) ...[
                                const SizedBox(height: 4),
                                Text(
                                  cardInfo!.keywords.join(' • '),
                                  style: context.labelSmall.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 구분선
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 해석 내용 - 스토리텔링 포맷
                    Text(
                      interpretation['interpretation'] ?? interpretation['meaning'] ?? '',
                      style: context.bodyMedium.copyWith(
                        height: 1.8,
                        letterSpacing: 0.2,
                      ),
                    ),
                    // 추가 인사이트 (원소, 점성술)
                    if (cardInfo != null) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (cardInfo.element.isNotEmpty)
                            _buildInfoChip(
                              icon: TarotHelper.getElementIcon(cardInfo.element),
                              label: cardInfo.element,
                              color: TarotHelper.getElementColor(cardInfo.element),
                            ),
                          if (cardInfo.astrology != null && cardInfo.astrology!.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.stars,
                              label: cardInfo.astrology!,
                              color: theme.colorScheme.secondary,
                            ),
                        ],
                      ),
                    ],
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
                        style: context.heading4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result['advice'],
                    style: context.buttonMedium.copyWith(
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
              child: UnifiedButton(
                text: '새로운 리딩',
                onPressed: widget.onNewReading,
                style: UnifiedButtonStyle.ghost,
                size: UnifiedButtonSize.medium,
                icon: Icon(Icons.refresh),
              ),
            ),
          if (widget.onShare != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: UnifiedButton(
                text: '공유하기',
                onPressed: widget.onShare,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.medium,
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
        'interpretation': '이 카드의 의미를 해석 중입니다...',
      };
    }

    final positionMeaning = _getPositionLabel(position);

    // 스토리텔링 스타일의 해석 생성
    final buffer = StringBuffer();

    // 위치별 맥락 설명
    buffer.writeln('$positionMeaning의 자리에 ${cardInfo.name}가 나타났습니다.');
    buffer.writeln();

    // 카드의 핵심 의미
    buffer.writeln('✨ 이 카드가 전하는 의미');
    buffer.writeln(cardInfo.uprightMeaning);
    buffer.writeln();

    // 상황별 조언
    buffer.writeln('💫 당신을 위한 메시지');
    buffer.writeln(cardInfo.advice);

    // 스토리가 있으면 일부 추가
    if (cardInfo.story != null && cardInfo.story!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('📖 카드의 이야기');
      final storyPreview = cardInfo.story!.length > 150
          ? '${cardInfo.story!.substring(0, 150)}...'
          : cardInfo.story!;
      buffer.writeln(storyPreview);
    }

    return {
      'cardName': cardInfo.name,
      'keywords': cardInfo.keywords,
      'interpretation': buffer.toString(),
      'element': cardInfo.element,
      'astrology': cardInfo.astrology,
    };
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}