import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../widgets/mystical_background.dart';

class TarotDeckSelectionPage extends ConsumerStatefulWidget {
  final String? spreadType;
  final String? initialQuestion;

  const TarotDeckSelectionPage({
    Key? key,
    this.spreadType,
    this.initialQuestion}) : super(key: key);

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
    HapticFeedback.lightImpact();
    setState(() {
      _tempSelectedDeckId = deckId;
    });
  }
  
  void _confirmSelection() async {
    if (_tempSelectedDeckId == null) return;
    
    HapticFeedback.mediumImpact();
    
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
          if (widget.initialQuestion != null) 'question': widget.initialQuestion!});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    
    final currentDeckId = ref.watch(selectedTarotDeckProvider);
    final experienceLevel = ref.watch(tarotExperienceLevelProvider);
    final recommendedDecks = ref.watch(recommendedDecksProvider);
    final deckStats = ref.watch(tarotDeckStatsProvider);
    final mostUsedDeckId = ref.read(tarotDeckStatsProvider.notifier).getMostUsedDeck();

    return Scaffold(
      backgroundColor: Colors.black,
      body: MysticalBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  AppHeader(
                    title: '타로 덱 선택',
                    showBackButton: true,
                    backgroundColor: Colors.transparent),
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
                                color: Colors.white.withOpacity(0.9)),
                              const SizedBox(height: 16),
                              Text(
                                '당신에게 맞는 타로 덱을 선택하세요',
                                style: TextStyle(
                                  fontSize: 24 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                                textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                '각 덱은 고유한 특성과 에너지를 가지고 있습니다',
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  color: Colors.white70),
                                textAlign: TextAlign.center)])),
                        const SizedBox(height: 32),

                        // 경험 레벨 선택
                        _buildExperienceLevelSection(theme, fontScale),
                        const SizedBox(height: 24),

                        // 추천 덱 섹션
                        if (recommendedDecks.isNotEmpty) ...[
                          _buildSectionTitle('추천 덱', fontScale),
                          const SizedBox(height: 16),
                          _buildDeckGrid(
                            recommendedDecks,
                            currentDeckId,
                            mostUsedDeckId,
                            fontScale),
                          const SizedBox(height: 32)],

                        // 모든 덱 섹션
                        _buildSectionTitle('모든 타로 덱', fontScale),
                        const SizedBox(height: 16),
                        _buildDeckGrid(
                          TarotDeckMetadata.getAllDecks(),
                          currentDeckId,
                          mostUsedDeckId,
                          fontScale)]))))]),
              // Floating Action Button
              if (_tempSelectedDeckId != null) Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton.extended(
                    onPressed: _confirmSelection,
                    backgroundColor: const Color(0xFF9333EA),
                    label: Text(
                      '선택 완료',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                    icon: const Icon(Icons.check, color: Colors.white))))]))));
  }

  Widget _buildSectionTitle(String title, double fontScale) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9333EA),
                const Color(0xFF7C3AED)]),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.white))]);
  }

  Widget _buildExperienceLevelSection(ThemeData theme, double fontScale) {
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
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TarotDifficulty.values.map((level) {
              final isSelected = level == experienceLevel;
              return ChoiceChip(
                label: Text(
                  level.displayName,
                  style: TextStyle(fontSize: 14 * fontScale)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(tarotExperienceLevelProvider.notifier).setExperienceLevel(level);
                  }
                },
                selectedColor: level.color.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.1));
            }).toList())]));
}

  Widget _buildDeckGrid(
    List<TarotDeck> decks,
    String currentDeckId,
    String? mostUsedDeckId,
    double fontScale) {
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
          fontScale: fontScale);
      });
  }

  Widget _buildDeckCard(
    TarotDeck deck,
    {
    required bool isSelected,
    required bool isMostUsed,
    required double fontScale}
  ) {
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
                    deck.primaryColor.withOpacity(0.2),
                    deck.secondaryColor.withOpacity(0.2)]),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF9333EA)
                      : Colors.white.withOpacity(0.2),
                  width: isSelected ? 2 : 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 덱 프리뷰 이미지
                    Expanded(
                      child: Center(
                        child: _buildDeckPreview(deck))),
                    const SizedBox(height: 12),
                    
                    // 덱 이름
                    Text(
                      deck.koreanName,
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    
                    // 아티스트와 연도
                    Text(
                      '${deck.artist} (${deck.year})',
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    
                    // 난이도와 스타일
                    Row(
                      children: [
                        _buildTag(
                          deck.difficulty.displayName,
                          deck.difficulty.color,
                          fontScale),
                        const SizedBox(width: 8),
                        _buildTag(
                          deck.style.displayName,
                          deck.primaryColor,
                          fontScale)])])),
              
              // 선택됨 표시
              if (isSelected) Positioned(
                top: 8,
                right: 8,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9333EA),
                      shape: BoxShape.circle),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16))),
              
              // 가장 많이 사용한 덱 표시
              if (isMostUsed && !isSelected) Positioned(
                top: 8,
                right: 8,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '자주 사용',
                      style: TextStyle(
                        fontSize: 10 * fontScale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))))]);
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
            child: _buildPreviewCard(deck, 2))] else ...[
          _buildPreviewCard(deck, 0)]]);
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          cardPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: deck.primaryColor.withOpacity(0.3),
              child: Center(
                child: Icon(
                  Icons.style,
                  color: Colors.white.withOpacity(0.5),
                  size: 30)));
          })));
  }

  Widget _buildTag(String text, Color color, double fontScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10 * fontScale,
          color: Colors.white,
          fontWeight: FontWeight.w500)));
  }
}