import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/infographic/headers/tarot_info_header.dart';
import '../../../../core/constants/tarot/tarot_position_meanings.dart';

/// 채팅용 타로 결과 리치 카드
///
/// 선택된 카드 표시, 각 카드 해석, 종합 해석, 조언
class ChatTarotResultCard extends ConsumerStatefulWidget {
  /// API 응답 데이터
  final Map<String, dynamic> data;

  /// 질문
  final String? question;

  const ChatTarotResultCard({
    super.key,
    required this.data,
    this.question,
  });

  @override
  ConsumerState<ChatTarotResultCard> createState() =>
      _ChatTarotResultCardState();
}

class _ChatTarotResultCardState extends ConsumerState<ChatTarotResultCard>
    with TickerProviderStateMixin {
  bool _isDetailExpanded = true;  // 기본값: 열린 상태

  // 타이핑 섹션 관리
  int _currentTypingSection = 0;

  // 카드 뒤집기 상태 관리
  final Map<int, bool> _cardFlipStates = {}; // true = 뒷면(해석) 보여줌
  final Map<int, AnimationController> _flipControllers = {};

  @override
  void dispose() {
    for (final controller in _flipControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getFlipController(int index) {
    if (!_flipControllers.containsKey(index)) {
      _flipControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    }
    return _flipControllers[index]!;
  }

  void _toggleCardFlip(int index) {
    DSHaptics.light();
    final controller = _getFlipController(index);
    final isCurrentlyFlipped = _cardFlipStates[index] ?? false;

    setState(() {
      _cardFlipStates[index] = !isCurrentlyFlipped;
    });

    if (isCurrentlyFlipped) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  /// 안전하게 setState 호출 (빌드 중 호출 방지)
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(fn);
      }
    });
  }

  Map<String, dynamic> get data => widget.data;
  String? get question => widget.question ?? data['question'] as String?;
  String get spreadType => data['spreadType'] as String? ?? 'single';
  String get spreadName =>
      data['spreadDisplayName'] as String? ??
      data['spreadName'] as String? ??
      '타로 리딩';
  List<dynamic> get cards => data['cards'] as List? ?? [];
  String get overallReading => data['overallReading'] as String? ?? '';
  String get storyTitle => data['storyTitle'] as String? ?? '';
  String get guidance => data['guidance'] as String? ?? '';
  String get advice => data['advice'] as String? ?? '';
  int get energyLevel => data['energyLevel'] as int? ?? 75;
  List<dynamic> get keyThemes => data['keyThemes'] as List? ?? [];
  String get timeFrame => data['timeFrame'] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.flat(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 - 타로 덱 정보 + 스프레드 타입
            _buildHeader(colors, typography),

            // 선택된 카드들 (세로, 뒤집기 가능)
            _buildCardsSection(colors, typography),

            // 종합 해석 (스토리)
            _buildOverallSection(colors, typography),

            // 카드별 상세 해석 (접기/펼치기)
            _buildDetailedSection(colors, typography),

            // 조언 (프리미엄)
            if (advice.isNotEmpty) _buildAdviceSection(colors, typography),

            const SizedBox(height: DSSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DSColorScheme colors, DSTypographyScheme typography) {
    // cards를 List<Map<String, dynamic>>으로 변환
    final cardsList = cards
        .map((c) => c is Map<String, dynamic> ? c : <String, dynamic>{})
        .toList();
    final themesList = keyThemes.map((t) => t.toString()).toList();

    return Stack(
      children: [
        // 인포그래픽 헤더
        TarotInfoHeader(
          spreadName: spreadName,
          question: question,
          cards: cardsList,
          energyLevel: energyLevel,
          keyThemes: themesList,
        ),
        // 액션 버튼 오버레이
        Positioned(
          top: DSSpacing.sm,
          right: DSSpacing.sm,
          child: FortuneActionButtons(
            contentId: data['id']?.toString() ??
                'tarot_${DateTime.now().millisecondsSinceEpoch}',
            contentType: 'tarot',
            fortuneType: 'tarot',
            shareTitle: '타로 리딩 결과',
            shareContent: overallReading,
            iconSize: 20,
            iconColor: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardsSection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        children: List.generate(cards.length, (index) {
          final card = cards[index] as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < cards.length - 1 ? DSSpacing.xl : 0,
            ),
            child: _buildFlippableCard(colors, typography, card, index),
          );
        }),
      ),
    );
  }

  Widget _buildFlippableCard(DSColorScheme colors, DSTypographyScheme typography,
      Map<String, dynamic> card, int index) {
    final cardNameKr = card['cardNameKr'] as String? ?? '카드';
    final imagePath = card['imagePath'] as String? ?? '';
    final isReversed = card['isReversed'] as bool? ?? false;
    final positionName = card['positionName'] as String? ?? '';
    final cardIndex = card['cardIndex'] as int? ?? card['index'] as int? ?? -1;

    // 상세 해석 가져오기 (하드코딩 우선, 없으면 Edge Function 데이터)
    String interpretation = '';
    final parsedSpreadType = TarotPositionMeanings.parseSpreadType(spreadType);
    if (parsedSpreadType != null && cardIndex >= 0) {
      final hardcodedInterpretation = TarotPositionMeanings.getInterpretation(
        cardIndex: cardIndex,
        spreadType: parsedSpreadType,
        positionIndex: index,
        isReversed: isReversed,
      );
      if (hardcodedInterpretation != null && hardcodedInterpretation.isNotEmpty) {
        interpretation = hardcodedInterpretation;
      }
    }
    if (interpretation.isEmpty) {
      interpretation = card['interpretation'] as String? ?? '';
    }

    final controller = _getFlipController(index);
    final isFlipped = _cardFlipStates[index] ?? false;

    return Column(
      children: [
        // 위치명 라벨
        if (positionName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: DSSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.accentSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              positionName,
              style: typography.labelMedium.copyWith(
                color: colors.accentSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // 뒤집기 가능한 카드
        GestureDetector(
          onTap: () => _toggleCardFlip(index),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final angle = controller.value * math.pi;
              final isShowingBack = controller.value >= 0.5;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 280),
                  height: 420,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: DSColors.warning.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: isShowingBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildCardBack(
                              colors,
                              typography,
                              cardNameKr,
                              positionName,
                              interpretation,
                              isReversed,
                            ),
                          )
                        : _buildCardFront(
                            colors,
                            typography,
                            cardNameKr,
                            imagePath,
                            isReversed,
                          ),
                  ),
                ),
              );
            },
          ),
        ),

        // 탭 안내 텍스트
        Padding(
          padding: const EdgeInsets.only(top: DSSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFlipped ? Icons.touch_app : Icons.flip,
                size: 14,
                color: colors.textTertiary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                isFlipped ? '탭하여 카드 보기' : '탭하여 해석 보기',
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // 카드 이름
        Padding(
          padding: const EdgeInsets.only(top: DSSpacing.xs),
          child: Text(
            cardNameKr,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 역방향 표시
        if (isReversed)
          Container(
            margin: const EdgeInsets.only(top: DSSpacing.xs),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '역방향',
              style: typography.labelSmall.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardFront(
    DSColorScheme colors,
    DSTypographyScheme typography,
    String cardNameKr,
    String imagePath,
    bool isReversed,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Transform.rotate(
        angle: isReversed ? math.pi : 0,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.accentSecondary.withValues(alpha: 0.2),
                    colors.accent.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: colors.accentSecondary,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    Text(
                      cardNameKr,
                      style: typography.headingSmall.copyWith(
                        color: colors.accentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardBack(
    DSColorScheme colors,
    DSTypographyScheme typography,
    String cardNameKr,
    String positionName,
    String interpretation,
    bool isReversed,
  ) {
    final goldColor = DSColors.warning;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 카드 뒷면 이미지 배경
        Image.asset(
          'assets/images/fortune/tarot/tarot_card_back_eye.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 폴백: 기존 네이비 배경
            return Container(
              color: colors.backgroundSecondary,
            );
          },
        ),

        // 반투명 오버레이 (텍스트 가독성)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DSColors.background.withValues(alpha: 0.4),
                DSColors.background.withValues(alpha: 0.7),
                DSColors.background.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),

        // 내용
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            children: [
              // 위치명
              if (positionName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DSColors.background.withValues(alpha: 0.3),
                    border: Border.all(color: goldColor, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    positionName,
                    style: typography.labelMedium.copyWith(
                      color: goldColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: DSSpacing.md),
              ],

              // 카드 이름
              Text(
                cardNameKr,
                style: typography.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: DSColors.background.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              if (isReversed) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '(역방향)',
                  style: typography.labelSmall.copyWith(
                    color: goldColor,
                  ),
                ),
              ],

              const SizedBox(height: DSSpacing.lg),

              // 구분선
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      goldColor.withValues(alpha: 0),
                      goldColor,
                      goldColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DSSpacing.lg),

              // 해석 내용
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    interpretation.isNotEmpty
                        ? interpretation
                        : '이 카드의 해석 내용이 여기에 표시됩니다.',
                    style: typography.bodySmall.copyWith(
                      color: Colors.white,
                      height: 1.7,
                      shadows: [
                        Shadow(
                          color: DSColors.background.withValues(alpha: 0.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverallSection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.md, DSSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: colors.accentSecondary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '종합 해석',
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          _currentTypingSection == 0
              ? GptStyleTypingText(
                  text: overallReading,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                  onComplete: () {
                    // 빌드 중 setState 호출 방지
                    _safeSetState(() => _currentTypingSection = 1);
                  },
                )
              : Text(
                  overallReading,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDetailedSection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.md, DSSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (접기/펼치기)
          InkWell(
            onTap: () {
              DSHaptics.light();
              setState(() {
                _isDetailExpanded = !_isDetailExpanded;
              });
            },
            borderRadius: BorderRadius.circular(DSRadius.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.style,
                    size: 18,
                    color: colors.accentSecondary,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '카드별 상세 해석',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isDetailExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // 상세 내용
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isDetailExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetailedInterpretations(colors, typography),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInterpretations(
      DSColorScheme colors, DSTypographyScheme typography) {
    // 스프레드 타입 파싱
    final parsedSpreadType = TarotPositionMeanings.parseSpreadType(spreadType);

    return Column(
      children: List.generate(cards.length, (index) {
        final card = cards[index] as Map<String, dynamic>;
        final cardNameKr = card['cardNameKr'] as String? ?? '카드';
        final positionName = card['positionName'] as String? ?? '';
        final isReversed = card['isReversed'] as bool? ?? false;
        final cardIndex =
            card['cardIndex'] as int? ?? card['index'] as int? ?? -1;

        // 하드코딩된 해석 가져오기
        String interpretation = '';
        if (parsedSpreadType != null && cardIndex >= 0) {
          final hardcodedInterpretation =
              TarotPositionMeanings.getInterpretation(
            cardIndex: cardIndex,
            spreadType: parsedSpreadType,
            positionIndex: index,
            isReversed: isReversed,
          );
          if (hardcodedInterpretation != null &&
              hardcodedInterpretation.isNotEmpty) {
            interpretation = hardcodedInterpretation;
          }
        }

        // 하드코딩 해석이 없으면 Edge Function 데이터 사용
        if (interpretation.isEmpty) {
          interpretation = card['interpretation'] as String? ?? '';
        }

        return Container(
          margin: const EdgeInsets.only(top: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(DSRadius.sm),
            border: Border.all(
              color: (isReversed ? colors.error : colors.accentSecondary)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 위치명
                  if (positionName.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.accentSecondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        positionName,
                        style: typography.labelSmall.copyWith(
                          color: colors.accentSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                  ],
                  Text(
                    cardNameKr,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isReversed) ...[
                    const SizedBox(width: DSSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '역방향',
                        style: typography.labelSmall.copyWith(
                          color: colors.error,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (interpretation.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  interpretation,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAdviceSection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.md, DSSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accentSecondary.withValues(alpha: 0.1),
              colors.accent.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: colors.accentSecondary,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '조언',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            _currentTypingSection >= 1
                ? GptStyleTypingText(
                    text: advice,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                    onComplete: () {},
                  )
                : Text(
                    advice,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
