import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../fortune/domain/models/tarot_card_model.dart';

/// 선택된 카드 정보 (풍부한 메타데이터 포함)
class _SelectedCard {
  final int index;
  final String cardName;
  final String cardNameKr;
  final String imagePath;
  bool isReversed;
  final String positionKey;
  final String positionName;
  final String positionDesc;

  _SelectedCard({
    required this.index,
    required this.cardName,
    required this.cardNameKr,
    required this.imagePath,
    this.isReversed = false,
    required this.positionKey,
    required this.positionName,
    required this.positionDesc,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'cardName': cardName,
    'cardNameKr': cardNameKr,
    'imagePath': imagePath,
    'isReversed': isReversed,
    'positionKey': positionKey,
    'positionName': positionName,
    'positionDesc': positionDesc,
  };
}

/// 메이저 아르카나 카드 정보
class _MajorArcanaCard {
  final int index;
  final String name;
  final String nameKr;
  final String fileName;

  const _MajorArcanaCard({
    required this.index,
    required this.name,
    required this.nameKr,
    required this.fileName,
  });

  String get imagePath => 'assets/images/tarot/decks/rider_waite/major/$fileName';
}

/// 22장 메이저 아르카나 카드 데이터
const List<_MajorArcanaCard> _majorArcanaCards = [
  _MajorArcanaCard(index: 0, name: 'The Fool', nameKr: '바보', fileName: '00_fool.jpg'),
  _MajorArcanaCard(index: 1, name: 'The Magician', nameKr: '마법사', fileName: '01_magician.jpg'),
  _MajorArcanaCard(index: 2, name: 'The High Priestess', nameKr: '여사제', fileName: '02_high_priestess.jpg'),
  _MajorArcanaCard(index: 3, name: 'The Empress', nameKr: '여황제', fileName: '03_empress.jpg'),
  _MajorArcanaCard(index: 4, name: 'The Emperor', nameKr: '황제', fileName: '04_emperor.jpg'),
  _MajorArcanaCard(index: 5, name: 'The Hierophant', nameKr: '교황', fileName: '05_hierophant.jpg'),
  _MajorArcanaCard(index: 6, name: 'The Lovers', nameKr: '연인', fileName: '06_lovers.jpg'),
  _MajorArcanaCard(index: 7, name: 'The Chariot', nameKr: '전차', fileName: '07_chariot.jpg'),
  _MajorArcanaCard(index: 8, name: 'Strength', nameKr: '힘', fileName: '08_strength.jpg'),
  _MajorArcanaCard(index: 9, name: 'The Hermit', nameKr: '은둔자', fileName: '09_hermit.jpg'),
  _MajorArcanaCard(index: 10, name: 'Wheel of Fortune', nameKr: '운명의 수레바퀴', fileName: '10_wheel_of_fortune.jpg'),
  _MajorArcanaCard(index: 11, name: 'Justice', nameKr: '정의', fileName: '11_justice.jpg'),
  _MajorArcanaCard(index: 12, name: 'The Hanged Man', nameKr: '매달린 남자', fileName: '12_hanged_man.jpg'),
  _MajorArcanaCard(index: 13, name: 'Death', nameKr: '죽음', fileName: '13_death.jpg'),
  _MajorArcanaCard(index: 14, name: 'Temperance', nameKr: '절제', fileName: '14_temperance.jpg'),
  _MajorArcanaCard(index: 15, name: 'The Devil', nameKr: '악마', fileName: '15_devil.jpg'),
  _MajorArcanaCard(index: 16, name: 'The Tower', nameKr: '탑', fileName: '16_tower.jpg'),
  _MajorArcanaCard(index: 17, name: 'The Star', nameKr: '별', fileName: '17_star.jpg'),
  _MajorArcanaCard(index: 18, name: 'The Moon', nameKr: '달', fileName: '18_moon.jpg'),
  _MajorArcanaCard(index: 19, name: 'The Sun', nameKr: '태양', fileName: '19_sun.jpg'),
  _MajorArcanaCard(index: 20, name: 'Judgement', nameKr: '심판', fileName: '20_judgement.jpg'),
  _MajorArcanaCard(index: 21, name: 'The World', nameKr: '세계', fileName: '21_world.jpg'),
];

/// 채팅 내 타로 플로우 위젯
///
/// 단계:
/// 1. 스프레드 선택 (1/3/5/10장)
/// 2. 카드 선택 (22장 중 N장) - 부채골 스프레드
/// 3. 확인 단계 - 정방향/역방향 토글
/// 4. 완료 콜백
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
  final List<_SelectedCard> _selectedCards = [];
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

    // 이미 선택된 카드인지 확인
    final existingIndex = _selectedCards.indexWhere((c) => c.index == cardIndex);

    if (existingIndex >= 0) {
      // 선택 해제
      DSHaptics.light();
      setState(() {
        _selectedCards.removeAt(existingIndex);
        // 위치 키 재계산
        for (int i = 0; i < _selectedCards.length; i++) {
          final card = _selectedCards[i];
          _selectedCards[i] = _SelectedCard(
            index: card.index,
            cardName: card.cardName,
            cardNameKr: card.cardNameKr,
            imagePath: card.imagePath,
            isReversed: card.isReversed,
            positionKey: _selectedSpread!.getPositionKey(i),
            positionName: _selectedSpread!.getPositionName(i),
            positionDesc: _selectedSpread!.getPositionDescription(i),
          );
        }
      });
    } else if (_selectedCards.length < requiredCards) {
      // 카드 선택
      DSHaptics.medium();
      final cardInfo = _majorArcanaCards[cardIndex];
      final positionIndex = _selectedCards.length;

      setState(() {
        _selectedCards.add(_SelectedCard(
          index: cardIndex,
          cardName: cardInfo.name,
          cardNameKr: cardInfo.nameKr,
          imagePath: cardInfo.imagePath,
          isReversed: false,
          positionKey: _selectedSpread!.getPositionKey(positionIndex),
          positionName: _selectedSpread!.getPositionName(positionIndex),
          positionDesc: _selectedSpread!.getPositionDescription(positionIndex),
        ));
      });

      // 모든 카드 선택 완료 → 확인 단계로
      if (_selectedCards.length == requiredCards) {
        DSHaptics.success();
        setState(() {
          _phase = _TarotFlowPhase.confirmation;
        });
      }
    }
  }

  void _toggleReversed(int index) {
    if (index < 0 || index >= _selectedCards.length) return;
    DSHaptics.light();
    setState(() {
      _selectedCards[index].isReversed = !_selectedCards[index].isReversed;
    });
  }

  void _goBackToCardSelection() {
    DSHaptics.light();
    setState(() {
      _phase = _TarotFlowPhase.cardSelection;
    });
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
        // 새로운 풍부한 데이터 구조
        'selectedCards': _selectedCards.map((c) => c.toJson()).toList(),
        // 레거시 호환을 위한 인덱스 배열
        'selectedCardIndices': _selectedCards.map((c) => c.index).toList(),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      // 배경 추가 - 뒤의 채팅 내용 가리기
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(DSRadius.lg),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_phase) {
          _TarotFlowPhase.spreadSelection => _buildSpreadSelector(colors, typography),
          _TarotFlowPhase.cardSelection => _buildCardSelector(colors, typography),
          _TarotFlowPhase.confirmation => _buildConfirmation(colors, typography),
        },
      ),
    );
  }

  Widget _buildSpreadSelector(DSColorScheme colors, DSTypographyScheme typography) {
    return Column(
      key: const ValueKey('spreadSelector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 덱 정보 헤더
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accentSecondary.withValues(alpha: 0.15),
                  colors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎴', style: typography.bodyMedium),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 타로: Rider-Waite',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.sm),

        // 스택된 실제 타로 카드 이미지
        Center(
          child: SizedBox(
            height: 100,
            width: 140,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(5, (index) {
                // 실제 카드 이미지 사용 (0-4번 카드)
                final cardImages = [
                  'assets/images/tarot/decks/rider_waite/major/00_fool.jpg',
                  'assets/images/tarot/decks/rider_waite/major/01_magician.jpg',
                  'assets/images/tarot/decks/rider_waite/major/02_high_priestess.jpg',
                  'assets/images/tarot/decks/rider_waite/major/03_empress.jpg',
                  'assets/images/tarot/decks/rider_waite/major/04_emperor.jpg',
                ];
                final offset = (index - 2) * 12.0;
                final rotation = (index - 2) * 0.1;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: 55,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colors.surface,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          cardImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // 이미지 로드 실패 시 폴백
                            return Container(
                              color: colors.accentSecondary,
                              child: Icon(
                                Icons.auto_awesome,
                                color: colors.surface.withValues(alpha: 0.6),
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.md),

        // 질문 텍스트
        Text(
          '몇 장의 카드를 뽑으시겠어요?',
          style: typography.bodyLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DSSpacing.md),

        // 스프레드 카드 목록
        Column(
          children: TarotSpreadType.sortedByDifficulty.map((spread) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: _SpreadCard(
                spread: spread,
                onTap: () => _selectSpread(spread),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardSelector(DSColorScheme colors, DSTypographyScheme typography) {
    final requiredCards = _selectedSpread?.cardCount ?? 1;
    final selectedCount = _selectedCards.length;
    final nextPositionIndex = selectedCount;
    final nextPositionName = _selectedSpread != null && nextPositionIndex < requiredCards
        ? _selectedSpread!.getPositionName(nextPositionIndex)
        : null;
    final nextPositionDesc = _selectedSpread != null && nextPositionIndex < requiredCards
        ? _selectedSpread!.getPositionDescription(nextPositionIndex)
        : null;

    return Column(
      key: const ValueKey('cardSelector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 덱 정보 헤더
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.accentSecondary.withValues(alpha: 0.15),
                colors.accent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(DSRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎴', style: typography.bodyMedium),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 타로: Rider-Waite',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.sm),

        // 선택 진행 상황 + 다음 위치 안내
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nextPositionName != null) ...[
                    Text(
                      '${selectedCount + 1}번째 카드: $nextPositionName',
                      style: typography.labelMedium.copyWith(
                        color: colors.accentSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (nextPositionDesc != null)
                      Text(
                        nextPositionDesc,
                        style: typography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ] else
                    Text(
                      '카드를 선택하세요',
                      style: typography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
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
        const SizedBox(height: DSSpacing.md),

        // 부채골 카드 스프레드
        SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildFanSpread(colors, typography, constraints.maxWidth);
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

  /// 확인 단계 - 선택한 카드 미리보기 + 역방향 토글
  Widget _buildConfirmation(DSColorScheme colors, DSTypographyScheme typography) {
    return Column(
      key: const ValueKey('confirmation'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더
        Row(
          children: [
            Icon(Icons.check_circle, color: colors.success, size: 20),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '카드 선택 완료!',
              style: typography.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          '카드를 탭하면 역방향으로 바꿀 수 있어요',
          style: typography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),

        // 선택된 카드 미리보기 (가로 스크롤)
        SizedBox(
          height: 170, // 역방향 표시 포함 높이
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
            itemBuilder: (context, index) {
              final card = _selectedCards[index];
              return _buildConfirmationCard(colors, typography, card, index);
            },
          ),
        ),
        const SizedBox(height: DSSpacing.md),

        // 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _goBackToCardSelection,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  side: BorderSide(color: colors.textSecondary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                ),
                child: const Text('다시 선택'),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _completeSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentSecondary,
                  foregroundColor: colors.surface,
                  padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '해석 보기',
                      style: typography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 확인 단계에서 개별 카드 위젯
  Widget _buildConfirmationCard(
    DSColorScheme colors,
    DSTypographyScheme typography,
    _SelectedCard card,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _toggleReversed(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 위치명
          Text(
            card.positionName,
            style: typography.labelSmall.copyWith(
              color: colors.accentSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          // 카드 이미지
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 70,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: card.isReversed ? colors.error : colors.accentSecondary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (card.isReversed ? colors.error : colors.accentSecondary)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Transform.rotate(
                angle: card.isReversed ? math.pi : 0,
                child: Image.asset(
                  card.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colors.accentSecondary,
                      child: Center(
                        child: Text(
                          card.cardNameKr,
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

          // 카드 이름 + 역방향 표시
          Text(
            card.cardNameKr,
            style: typography.labelSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (card.isReversed)
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
      ),
    );
  }

  /// 부채골 스프레드 빌드
  Widget _buildFanSpread(DSColorScheme colors, DSTypographyScheme typography, double maxWidth) {
    final requiredCards = _selectedSpread?.cardCount ?? 1;
    final selectedCount = _selectedCards.length;
    const cardWidth = 45.0;
    const cardHeight = 68.0;
    const totalAngle = 120.0; // 전체 펼침 각도 (도)
    final centerX = maxWidth / 2;
    const centerY = 200.0; // 부채 중심점 Y (화면 아래쪽)
    const radius = 140.0; // 부채 반지름

    // 선택된 카드 인덱스 목록
    final selectedIndices = _selectedCards.map((c) => c.index).toSet();

    return SizedBox(
      width: maxWidth,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(totalCards, (index) {
          final isSelected = selectedIndices.contains(index);
          final selectionOrder = isSelected
              ? _selectedCards.indexWhere((c) => c.index == index) + 1
              : null;
          final isDisabled = !isSelected && selectedCount >= requiredCards;

          // 각도 계산 (왼쪽에서 오른쪽으로)
          final angleStep = totalAngle / (totalCards - 1);
          final angleDeg = -totalAngle / 2 + angleStep * index;
          final angleRad = angleDeg * math.pi / 180;

          // 위치 계산
          final x = centerX + math.sin(angleRad) * radius - cardWidth / 2;
          final y = centerY - math.cos(angleRad) * radius;

          // 선택된 카드는 위로 튀어나옴
          final yOffset = isSelected ? -25.0 : 0.0;

          return Positioned(
            left: x,
            top: y + yOffset,
            child: GestureDetector(
              onTap: isDisabled && !isSelected ? null : () => _selectCard(index),
              child: Transform.rotate(
                angle: angleRad * 0.6, // 카드 회전
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isSelected
                          ? [colors.accentSecondary, colors.accentSecondary.withValues(alpha: 0.8)]
                          : [
                              colors.surface,
                              colors.surface.withValues(alpha: 0.95),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? colors.accentSecondary
                          : colors.textPrimary.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? colors.accentSecondary.withValues(alpha: 0.4)
                            : colors.textPrimary.withValues(alpha: 0.08),
                        blurRadius: isSelected ? 10 : 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 카드 뒷면 패턴
                      Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: isSelected
                              ? colors.surface.withValues(alpha: 0.9)
                              : colors.textSecondary.withValues(alpha: 0.25),
                          size: 16,
                        ),
                      ),

                      // 선택 순서 표시
                      if (isSelected && selectionOrder != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
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
                                  fontSize: 8,
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

enum _TarotFlowPhase {
  spreadSelection,
  cardSelection,
  confirmation,
}

/// 스프레드 선택 카드 (영어/한글 이름 + 설명 포함)
class _SpreadCard extends StatelessWidget {
  final TarotSpreadType spread;
  final VoidCallback onTap;

  const _SpreadCard({
    required this.spread,
    required this.onTap,
  });

  // 영어 이름 매핑
  String get englishName {
    switch (spread) {
      case TarotSpreadType.single:
        return 'Single Card';
      case TarotSpreadType.threeCard:
        return 'Three Card';
      case TarotSpreadType.relationship:
        return 'Relationship';
      case TarotSpreadType.celticCross:
        return 'Celtic Cross';
    }
  }

  // 간단한 설명
  String get shortDescription {
    switch (spread) {
      case TarotSpreadType.single:
        return '예/아니오, 오늘의 조언';
      case TarotSpreadType.threeCard:
        return '과거 → 현재 → 미래';
      case TarotSpreadType.relationship:
        return '나와 상대방의 마음';
      case TarotSpreadType.celticCross:
        return '깊은 분석과 인생 조언';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // 미니 카드 스택 (카드 수에 맞게)
              SizedBox(
                width: 50,
                height: 45,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(
                    spread.cardCount.clamp(1, 4),
                    (index) {
                      final offset = (index - (spread.cardCount.clamp(1, 4) - 1) / 2) * 6.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: Container(
                          width: 28,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.accentSecondary,
                                colors.accent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: colors.surface,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.textPrimary.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.auto_awesome,
                              color: colors.surface.withValues(alpha: 0.7),
                              size: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.md),

              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카드 수 + 영어 이름
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accentSecondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(DSRadius.xs),
                          ),
                          child: Text(
                            '${spread.cardCount}장',
                            style: typography.labelSmall.copyWith(
                              color: colors.accentSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        Text(
                          englishName,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // 한글 이름
                    Text(
                      spread.displayName,
                      style: typography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 설명
                    Text(
                      shortDescription,
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.chevron_right,
                color: colors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
