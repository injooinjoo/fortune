import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../shared/components/app_header.dart'; // For FontSize enum
import '../../../../presentation/providers/font_size_provider.dart';
import '../providers/tarot_storytelling_provider.dart';
import '../widgets/mystical_background.dart';
import 'package:go_router/go_router.dart';

class TarotSummaryPage extends ConsumerStatefulWidget {
  final List<int> cards;
  final List<String> interpretations;
  final String spreadType;
  final String? question;

  const TarotSummaryPage({
    super.key,
    required this.cards,
    required this.interpretations,
    required this.spreadType,
    this.question});

  static Future<void> show({
    required BuildContext context,
    required List<int> cards,
    required List<String> interpretations,
    required String spreadType,
    String? question}) {
    return context.pushNamed(
      'tarot-summary',
      extra: {
        'cards': cards,
        'interpretations': interpretations,
        'spreadType': spreadType,
        'question': question,
      },
    );
  }

  @override
  ConsumerState<TarotSummaryPage> createState() => _TarotSummaryPageState();
}

class _TarotSummaryPageState extends ConsumerState<TarotSummaryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isLoadingSummary = false;
  Map<String, dynamic>? _summaryData;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _scaleController.forward();
    
    _loadSummary();
}

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
}

  Future<void> _loadSummary() async {
    setState(() {
      _isLoadingSummary = true;
});

    try {
      final summary = await ref.read(
        tarotFullInterpretationProvider({
          'cards': widget.cards,
          'interpretations': widget.interpretations,
          'spreadType': widget.spreadType,
          'question': null}).future);

      setState(() {
        _summaryData = summary;
        _isLoadingSummary = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSummary = false;
      });
    }
  }

  void _shareReading() async {
    final spread = TarotMetadata.spreads[widget.spreadType];
    final buffer = StringBuffer();
    
    buffer.writeln('🔮 타로 리딩 결과 🔮');
    buffer.writeln();
    buffer.writeln('스프레드: ${spread?.name}');
    if (widget.question != null) {
      buffer.writeln('질문: ${widget.question}');
    }
    buffer.writeln();
    
    for (int i = 0; i < widget.cards.length; i++) {
      final cardInfo = _getCardInfo(widget.cards[i]);
      final position = TarotHelper.getPositionDescription(widget.spreadType, i);
      buffer.writeln('${i + 1}. $position: ${cardInfo['name']}');
    }
    
    if (_summaryData != null && _summaryData!['summary'] != null) {
      buffer.writeln();
      buffer.writeln('해석:');
      buffer.writeln(_summaryData!['summary']);
    }
    
    await Share.share(buffer.toString());
  }

  Map<String, dynamic> _getCardInfo(int cardIndex) {
    if (cardIndex < 22) {
      final majorCard = TarotMetadata.majorArcana[cardIndex];
      if (majorCard != null) {
        return {
          'name': majorCard.name,
          'keywords': majorCard.keywords,
          'element': majorCard.element
        };
      }
    }
    return {'name': 'Unknown Card', 'keywords': [], 'element': 'Unknown'};
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Scaffold(
      backgroundColor: TossDesignSystem.black,
      appBar: StandardFortuneAppBar(
        title: '타로 리딩 완료',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReading,
          ),
        ],
      ),
      body: MysticalBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildHeader(fontScale),
                      const SizedBox(height: 24),
                      _buildCardSpread(fontScale),
                      const SizedBox(height: 32),
                      if (_isLoadingSummary) _buildLoadingIndicator()
                      else if (_summaryData != null) _buildSummarySection(fontScale),
                      const SizedBox(height: 24),
                      // Share section
                      _buildShareSection(fontScale),
                      const SizedBox(height: 32),
                      const BottomButtonSpacing(),
                    ],
                  ),
                ),
              ),
              FloatingBottomButton(
                text: '새로운 리딩 시작하기',
                onPressed: () {
                  context.goNamed('interactive-tarot');
                },
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double fontScale) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          // Enhanced mystical icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating aura
                  Transform.rotate(
                    angle: value * 2 * math.pi,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            TossDesignSystem.purple.withValues(alpha: 0),
                            const Color(0xFF9333EA).withValues(alpha: 0.3),
                            TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                            TossDesignSystem.purple.withValues(alpha: 0)
                          ]
                        )
                      )
                    )
                  ),
                  // Center icon
                  Icon(
                    Icons.auto_awesome,
                    size: 60,
                    color: TossDesignSystem.white,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF9333EA),
                        blurRadius: 20,
                      ),
                    ]
                  )
                ]
              );
            }),
          const SizedBox(height: 16),
          Text(
            '리딩이 완료되었습니다',
            style: TextStyle(
              fontSize: 24 * fontScale,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
          ),
          if (widget.question != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.question!,
              style: TextStyle(
                fontSize: 16 * fontScale,
                color: TossDesignSystem.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardSpread(double fontScale) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.purple.withValues(alpha: 0.2),
          TossDesignSystem.bluePrimary.withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        children: [
          Text(
            '카드 스프레드',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildCardGrid(fontScale),
        ],
      ),
    );
  }

  Widget _buildCardGrid(double fontScale) {
    final spreadLayout = TarotMetadata.spreads[widget.spreadType]?.layout;
    
    if (spreadLayout == SpreadLayout.celticCross) {
      return _buildCelticCrossLayout(fontScale);
    } else if (spreadLayout == SpreadLayout.horizontal) {
      return _buildHorizontalLayout(fontScale);
    } else {
      return _buildDefaultLayout(fontScale);
    }
  }

  Widget _buildCelticCrossLayout(double fontScale) {
    // Celtic Cross specific layout
    return SizedBox(
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center cards (0, 1,
          Positioned(
            left: 120,
            top: 150,
            child: _buildMiniCard(0, fontScale)),
          Positioned(
            left: 140,
            top: 130,
            child: Transform.rotate(
              angle: 1.57,
              child: _buildMiniCard(1, fontScale)),
          ),
          // Cross cards (2, 3, 4, 5,
          Positioned(
            left: 120,
            top: 20,
            child: _buildMiniCard(2, fontScale)),
          Positioned(
            left: 120,
            bottom: 20,
            child: _buildMiniCard(3, fontScale)),
          Positioned(
            left: 20,
            top: 150,
            child: _buildMiniCard(4, fontScale)),
          Positioned(
            right: 120,
            top: 150,
            child: _buildMiniCard(5, fontScale)),
          // Staff cards (6, 7, 8, 9,
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildMiniCard(6, fontScale)),
          Positioned(
            right: 20,
            bottom: 120,
            child: _buildMiniCard(7, fontScale)),
          Positioned(
            right: 20,
            top: 120,
            child: _buildMiniCard(8, fontScale)),
          Positioned(
            right: 20,
            top: 20,
            child: _buildMiniCard(9, fontScale),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(double fontScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.cards.length,
        (index) => _buildMiniCard(index, fontScale),
      ),
    );
  }

  Widget _buildDefaultLayout(double fontScale) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(
        widget.cards.length,
        (index) => _buildMiniCard(index, fontScale),
      ),
    );
  }

  Widget _buildMiniCard(int index, double fontScale) {
    if (index >= widget.cards.length) return const SizedBox();

    final cardIndex = widget.cards[index];
    final imagePath = _getCardImagePath(cardIndex);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCardDetail(index);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced card with hover effect
              Hero(
                tag: 'card_$index',
                child: Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: AssetImage('assets/images/tarot/$imagePath'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: TossDesignSystem.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TossDesignSystem.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10 * fontScale,
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: TossDesignSystem.purple,
          ),
          const SizedBox(height: 16),
          Text(
            '전체 해석을 생성하고 있습니다...',
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(double fontScale) {
    return Column(
      children: [
        _buildSummaryCard(fontScale),
        if (_summaryData!['elementBalance'] != null) ...[
          const SizedBox(height: 24),
          _buildElementBalance(fontScale),
        ],
        if (_summaryData!['advice'] != null) ...[
          const SizedBox(height: 24),
          _buildAdviceSection(fontScale),
        ],
        if (_summaryData!['timeline'] != null) ...[
          const SizedBox(height: 24),
          _buildTimelineSection(fontScale),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(double fontScale) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.warningYellow.withValues(alpha: 0.2),
          TossDesignSystem.warningOrange.withValues(alpha: 0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: TossDesignSystem.warningYellow.withValues(alpha: 0.3),
        width: 1,
      ),
      blur: 15,
      child: Column(
        children: [
          // Enhanced icon with glow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  TossDesignSystem.warningYellow.withValues(alpha: 0.3),
                  TossDesignSystem.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.auto_stories,
              size: 48,
              color: TossDesignSystem.warningYellow,
              shadows: [
                Shadow(
                  color: TossDesignSystem.warningYellow,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '전체 해석',
            style: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _summaryData!['summary'] ?? '해석을 생성할 수 없습니다.',
            style: TextStyle(
              fontSize: 16 * fontScale,
              color: TossDesignSystem.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
}

  Widget _buildElementBalance(double fontScale) {
    final elementBalance = _summaryData!['elementBalance'] as Map<String, dynamic>;
    final total = elementBalance.values.fold<int>(0, (sum, count) => sum + (count as int));
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '원소 균형',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
          ),
          const SizedBox(height: 16),
          ...elementBalance.entries.map((entry) {
            final percentage = ((entry.value as int) / total * 100).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    TarotHelper.getElementIcon(entry.key),
                    size: 24,
                    color: TarotHelper.getElementColor(entry.key),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: percentage / 100,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: TarotHelper.getElementColor(entry.key),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      color: TossDesignSystem.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_summaryData!['dominantElement'] != null) ...[
            const SizedBox(height: 12),
            Text(
              '${_summaryData!['dominantElement']} 원소가 우세합니다',
              style: TextStyle(
                fontSize: 14 * fontScale,
                color: TossDesignSystem.purple.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdviceSection(double fontScale) {
    final advice = _summaryData!['advice'] as List;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.successGreen.withValues(alpha: 0.2),
          TossDesignSystem.successGreen.withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb,
            size: 36,
            color: TossDesignSystem.successGreen,
          ),
          const SizedBox(height: 12),
          Text(
            '조언',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
          ),
          const SizedBox(height: 16),
          ...advice.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    color: TossDesignSystem.successGreen,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      color: TossDesignSystem.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(double fontScale) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.tossBlue.withValues(alpha: 0.2),
          TossDesignSystem.tossBlue.withValues(alpha: 0.2),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 36,
            color: TossDesignSystem.tossBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예상 시기',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _summaryData!['timeline'],
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    color: TossDesignSystem.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetail(int index) {
    final cardIndex = widget.cards[index];
    final position = TarotHelper.getPositionDescription(widget.spreadType, index);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: TossDesignSystem.black.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2)
                  )
                )
              ),
              const SizedBox(height: 20),
              Text(
                position,
                style: const TextStyle(
                  fontSize: 16,
                  color: TossDesignSystem.purple,
                  fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/images/tarot/${_getCardImagePath(cardIndex)}'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '해석',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TossDesignSystem.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.interpretations[index],
                style: TextStyle(
                  fontSize: 14,
                  color: TossDesignSystem.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareSection(double fontScale) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF9333EA).withValues(alpha: 0.1),
          const Color(0xFF7C3AED).withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: TossDesignSystem.white.withValues(alpha: 0.1),
        width: 1,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                color: TossDesignSystem.white.withValues(alpha: 0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '친구와 공유하기',
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: TossDesignSystem.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                icon: Icons.message,
                label: '메시지',
                color: const Color(0xFF00C853),
                onTap: _shareReading,
                fontScale: fontScale,
              ),
              _buildShareButton(
                icon: Icons.copy,
                label: '복사',
                color: const Color(0xFF2196F3),
                onTap: () {
                  // Copy to clipboard
                  final spread = TarotMetadata.spreads[widget.spreadType];
                  final buffer = StringBuffer();
                  buffer.writeln('🔮 타로 리딩 결과 🔮');
                  buffer.writeln();
                  buffer.writeln('스프레드: ${spread?.name}');
                  if (widget.question != null) {
                    buffer.writeln('질문: ${widget.question}');
                  }
                  buffer.writeln();
                  for (int i = 0; i < widget.cards.length; i++) {
                    final cardInfo = _getCardInfo(widget.cards[i]);
                    final position = TarotHelper.getPositionDescription(widget.spreadType, i);
                    buffer.writeln('${i + 1}. $position: ${cardInfo['name']}');
                  }
                  if (_summaryData != null && _summaryData!['summary'] != null) {
                    buffer.writeln();
                    buffer.writeln('해석:');
                    buffer.writeln(_summaryData!['summary']);
                  }
                  
                  Clipboard.setData(ClipboardData(text: buffer.toString()));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('클립보드에 복사되었습니다'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                fontScale: fontScale,
              ),
              _buildShareButton(
                icon: Icons.image,
                label: '이미지',
                color: const Color(0xFFFF6F00),
                onTap: () {
                  // TODO: Implement screenshot and share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이미지 공유 기능은 준비 중입니다'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                fontScale: fontScale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double fontScale}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12 * fontScale,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
}

  String _getCardImagePath(int cardIndex) {
    // Use before_tarot deck (actual images available)
    const deckPath = 'decks/before_tarot';
    
    if (cardIndex < 22) {
      // Major Arcana
      final cardNames = [
        'fool', 'magician', 'high_priestess', 'empress', 'emperor', 'hierophant', 'lovers', 'chariot', 'strength', 'hermit',
        'wheel_of_fortune', 'justice', 'hanged_man', 'death', 'temperance', 'devil', 'tower', 'star', 'moon', 'sun', 'judgement', 'world',
      ];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
    } else if (cardIndex < 36) {
      // Wands
      final wandsIndex = cardIndex - 21;
      final cardName = wandsIndex <= 10 ? 'of_wands' : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      final cardName = cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      final cardName = swordsIndex <= 10 ? 'of_swords' : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      final cardName = pentaclesIndex <= 10 ? 'of_pentacles' : _getCourtCardName(pentaclesIndex, 'pentacles');
      return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    }
  }

  String _getCourtCardName(int index, String suit) {
    switch (index) {
      case 11: return 'page_of_$suit';
      case 12: return 'knight_of_$suit';
      case 13: return 'queen_of_$suit';
      case 14: return 'king_of_$suit';
      default: return 'of_$suit';
    }
  }
}