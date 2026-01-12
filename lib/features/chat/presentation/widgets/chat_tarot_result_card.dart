import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/infographic/headers/tarot_info_header.dart';
import '../../../../core/constants/tarot/tarot_position_meanings.dart';
import '../../../../presentation/providers/token_provider.dart';

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

class _ChatTarotResultCardState extends ConsumerState<ChatTarotResultCard> {
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  bool _isDetailExpanded = true;  // 기본값: 열린 상태
  bool _hasInitializedBlur = false;

  // 타이핑 섹션 관리
  int _currentTypingSection = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ref는 didChangeDependencies에서 안전하게 접근 가능
    if (!_hasInitializedBlur) {
      _hasInitializedBlur = true;
      _initBlurState();
    }
  }

  void _initBlurState() {
    final tokenState = ref.read(tokenProvider);
    // 프리미엄 사용자(무제한 또는 토큰 보유)는 절대 블러 안 함
    final isPremium = tokenState.hasUnlimitedAccess ||
        (tokenState.balance?.remainingTokens ?? 0) > 0;

    // 프리미엄이면 무조건 블러 해제
    if (isPremium) {
      _isBlurred = false;
      _blurredSections = [];
    } else {
      _isBlurred = widget.data['isBlurred'] as bool? ?? true;
      _blurredSections =
          (widget.data['blurredSections'] as List?)?.cast<String>() ??
              ['advice', 'detailedInterpretations'];
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
      child: DSCard.hanji(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 - 타로 덱 정보 + 스프레드 타입
            _buildHeader(colors, typography),

            // 질문 섹션
            if (question != null && question!.isNotEmpty)
              _buildQuestionSection(colors, typography),

            // 선택된 카드들 (가로 스크롤)
            _buildCardsSection(colors, typography),

            // 에너지 점수 + 키 테마
            _buildEnergyScore(colors, typography),

            // 키 테마 (있으면)
            if (keyThemes.isNotEmpty) _buildKeyThemes(colors, typography),

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
            shareTitle: '타로 리딩 결과',
            shareContent: overallReading,
            iconSize: 20,
            iconColor: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.sm, DSSpacing.md, 0),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.help_outline,
            size: 16,
            color: colors.accentSecondary,
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Text(
              question!,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.md),
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
        itemBuilder: (context, index) {
          final card = cards[index] as Map<String, dynamic>;
          return _buildCardItem(colors, typography, card);
        },
      ),
    );
  }

  Widget _buildCardItem(DSColorScheme colors, DSTypographyScheme typography,
      Map<String, dynamic> card) {
    final cardNameKr = card['cardNameKr'] as String? ?? '카드';
    final imagePath = card['imagePath'] as String? ?? '';
    final isReversed = card['isReversed'] as bool? ?? false;
    final positionName = card['positionName'] as String? ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 위치명
        if (positionName.isNotEmpty)
          Text(
            positionName,
            style: typography.labelSmall.copyWith(
              color: colors.accentSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 4),

        // 카드 이미지
        Container(
          width: 65,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isReversed ? colors.error : colors.accentSecondary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isReversed ? colors.error : colors.accentSecondary)
                    .withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Transform.rotate(
              angle: isReversed ? math.pi : 0,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colors.accentSecondary,
                    child: Center(
                      child: Text(
                        cardNameKr,
                        style: typography.labelSmall.copyWith(
                          color: colors.surface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // 카드 이름
        Text(
          cardNameKr,
          style: typography.labelSmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),

        // 역방향 표시
        if (isReversed)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
    );
  }

  Widget _buildEnergyScore(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.md, DSSpacing.md, 0),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            size: 18,
            color: _getEnergyColor(colors),
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            '에너지 점수',
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '$energyLevel점',
            style: typography.bodyMedium.copyWith(
              color: _getEnergyColor(colors),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEnergyColor(DSColorScheme colors) {
    if (energyLevel >= 80) return colors.success;
    if (energyLevel >= 60) return colors.accentSecondary;
    if (energyLevel >= 40) return colors.warning;
    return colors.error;
  }

  Widget _buildKeyThemes(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.sm, DSSpacing.md, 0),
      child: Wrap(
        spacing: DSSpacing.xs,
        runSpacing: DSSpacing.xs,
        children: keyThemes.map((theme) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.accentSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$theme',
              style: typography.labelSmall.copyWith(
                color: colors.accentSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
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
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
        sectionKey: 'detailedInterpretations',
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
                    const SizedBox(width: 4),
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
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
        sectionKey: 'advice',
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
      ),
    );
  }
}
