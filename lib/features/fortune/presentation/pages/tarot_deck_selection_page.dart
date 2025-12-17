import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../../core/providers/user_settings_provider.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../widgets/mystical_background.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
class TarotDeckSelectionPage extends ConsumerStatefulWidget {
  final String? spreadType;
  final String? initialQuestion;

  const TarotDeckSelectionPage({
    super.key,
    this.spreadType,
    this.initialQuestion,
  });

  @override
  ConsumerState<TarotDeckSelectionPage> createState() => _TarotDeckSelectionPageState();
}

class _TarotDeckSelectionPageState extends ConsumerState<TarotDeckSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _hoveredDeckId;
  String? _tempSelectedDeckId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this);
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectDeck(String deckId) {
    ref.read(fortuneHapticServiceProvider).cardSelect();
    setState(() {
      _tempSelectedDeckId = deckId;
    });
  }
  
  void _confirmSelection() async {
    if (_tempSelectedDeckId == null) return;

    ref.read(fortuneHapticServiceProvider).sectionComplete();
    
    // 덱 선택 저장
    await ref.read(selectedTarotDeckProvider.notifier).selectDeck(_tempSelectedDeckId!);
    
    // 사용 통계 업데이트
    await ref.read(tarotDeckStatsProvider.notifier).incrementUsage(_tempSelectedDeckId!);
    
    // 타로 카드 페이지로 이동
    if (mounted) {
      context.pushReplacementNamed(
        'fortune-tarot',
        queryParameters: {
          if (widget.spreadType != null) 'spreadType': widget.spreadType!,
          if (widget.initialQuestion != null) 'question': widget.initialQuestion!,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final fontScale = ref.watch(userSettingsProvider).fontScale;

    final currentDeckId = ref.watch(selectedTarotDeckProvider);
    final recommendedDecks = ref.watch(recommendedDecksProvider);
    final mostUsedDeckId = ref.read(tarotDeckStatsProvider.notifier).getMostUsedDeck();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const StandardFortuneAppBar(
        title: '타로 카드 선택',
      ),
      body: MysticalBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        // 타이틀 섹션
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.style,
                                size: 60,
                                color: Colors.white.withValues(alpha:0.9),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '당신에게 맞는 타로 카드를 선택하세요',
                                style: DSTypography.headingMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '각 덱은 고유한 특성과 에너지를 가지고 있습니다',
                                style: DSTypography.labelLarge.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 경험 레벨 선택
                        _buildExperienceLevelSection(theme, fontScale, colors),
                        const SizedBox(height: 24),

                        // 추천 덱 섹션
                        if (recommendedDecks.isNotEmpty) ...[
                          _buildSectionTitle('추천 덱', fontScale, colors),
                          const SizedBox(height: 16),
                          _buildDeckGrid(
                            recommendedDecks,
                            currentDeckId,
                            mostUsedDeckId,
                            fontScale,
                            colors),
                          const SizedBox(height: 32),
                        ],

                        // 모든 덱 섹션
                        _buildSectionTitle('모든 타로 카드', fontScale, colors),
                        const SizedBox(height: 16),
                        _buildDeckGrid(
                          TarotDeckMetadata.getAllDecks(),
                          currentDeckId,
                          mostUsedDeckId,
                          fontScale,
                          colors),
                      ],
                    ),
                  ),
                ),
              ),
              ],
              ),
              // FloatingBottomButton
              if (_tempSelectedDeckId != null)
                UnifiedButton.floating(
                  text: '선택 완료',
                  onPressed: _confirmSelection,
                  isLoading: false,
                  isEnabled: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontScale, DSColorScheme colors) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9333EA),
                const Color(0xFF7C3AED),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: DSTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildExperienceLevelSection(ThemeData theme, double fontScale, DSColorScheme colors) {
    final experienceLevel = ref.watch(tarotExperienceLevelProvider);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: theme.colorScheme.primary,
                size: 20),
              const SizedBox(width: 8),
              Text(
                '나의 타로 경험',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TarotDifficulty.values.map((level) {
              final isSelected = level == experienceLevel;
              return ChoiceChip(
                label: Text(
                  level.displayName,
                  style: DSTypography.bodySmall,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(tarotExperienceLevelProvider.notifier).setExperienceLevel(level);
                  }
                },
                selectedColor: level.color.withValues(alpha:0.3),
                backgroundColor: Colors.white.withValues(alpha:0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckGrid(
    List<TarotDeck> decks,
    String currentDeckId,
    String? mostUsedDeckId,
    double fontScale,
    DSColorScheme colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return _buildDeckCard(
          deck,
          isSelected: deck.id == (_tempSelectedDeckId ?? currentDeckId),
          isMostUsed: deck.id == mostUsedDeckId,
          fontScale: fontScale,
          colors: colors,
        );
      },
    );
  }

  Widget _buildDeckCard(
    TarotDeck deck,
    {
    required bool isSelected,
    required bool isMostUsed,
    required double fontScale,
    required DSColorScheme colors,
  }) {
    final isHovered = _hoveredDeckId == deck.id;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredDeckId = deck.id),
      onExit: (_) => setState(() => _hoveredDeckId = null),
      child: GestureDetector(
        onTap: () => _selectDeck(deck.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isHovered ? 1.05 : 1.0),
          child: Stack(
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    deck.primaryColor.withValues(alpha:0.2),
                    deck.secondaryColor.withValues(alpha:0.2)]),
                border: Border.all(
                  color: isSelected
                      ? colors.accent
                      : Colors.white.withValues(alpha:0.2),
                  width: isSelected ? 2 : 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 덱 프리뷰 이미지
                    Expanded(
                      child: Center(
                        child: _buildDeckPreview(deck),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 덱 이름
                    Text(
                      deck.koreanName,
                      style: DSTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),

                    // 아티스트와 연도
                    Text(
                      '${deck.artist} (${deck.year})',
                      style: DSTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    
                    // 난이도와 스타일
                    Row(
                      children: [
                        _buildTag(
                          deck.difficulty.displayName,
                          deck.difficulty.color,
                          fontScale,
                          colors),
                        const SizedBox(width: 8),
                        _buildTag(
                          deck.style.displayName,
                          deck.primaryColor,
                          fontScale,
                          colors),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 선택됨 표시
              if (isSelected) Positioned(
                top: 8,
                right: 8,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                    ),
                ),

              // 가장 많이 사용한 덱 표시
              if (isMostUsed && !isSelected) Positioned(
                top: 8,
                right: 8,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.warning.withValues(alpha:0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '자주 사용',
                      style: DSTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckPreview(TarotDeck deck) {
    // 프리뷰 카드 3장을 팬 모양으로 표시
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (deck.previewCards.length >= 3) ...[
          Transform.rotate(
            angle: -0.2,
            child: _buildPreviewCard(deck, 0)),
          Transform.rotate(
            angle: 0,
            child: _buildPreviewCard(deck, 1)),
          Transform.rotate(
            angle: 0.2,
            child: _buildPreviewCard(deck, 2)),
        ] else ...[
          _buildPreviewCard(deck, 0),
        ],
      ],
    );
  }

  Widget _buildPreviewCard(TarotDeck deck, int index) {
    if (index >= deck.previewCards.length) return const SizedBox();
    
    final cardPath = deck.getCardImagePath('major/${deck.previewCards[index]}.jpg');
    
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 4,
            offset: const Offset(0, 2))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          cardPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: deck.primaryColor.withValues(alpha:0.3),
              child: Center(
                child: Icon(
                  Icons.style,
                  color: Colors.white.withValues(alpha:0.5),
                  size: 30),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, double fontScale, DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha:0.5),
          width: 1)),
      child: Text(
        text,
        style: DSTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500),
      ),
    );
  }
}