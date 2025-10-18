import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toss_button.dart';
// Adjusted const usage for gradient button
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../shared/components/app_header.dart'; // For FontSize enum
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

enum TarotSpreadType {
  
  
  single('single', '일일 카드', 1, 1),
  threeCard('three', '3장 스프레드', 3, 2),
  celticCross('celtic', '켈틱 크로스', 10, 5),
  relationship('relationship', '관계 스프레드', 6, 3),
  decision('decision', '결정 스프레드', 5, 3);
  
  final String value;
  final String displayName;
  final int cardCount;
  final int tokenCost;
  
  const TarotSpreadType(this.value, this.displayName, this.cardCount, this.tokenCost);
  
  
}

class TarotEnhancedPage extends ConsumerStatefulWidget {
  final String? heroTag;
  
  const TarotEnhancedPage({
    super.key,
    this.heroTag});

  @override
  ConsumerState<TarotEnhancedPage> createState() => _TarotEnhancedPageState();
}

class _TarotEnhancedPageState extends ConsumerState<TarotEnhancedPage>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _fadeController;

  TarotSpreadType? _selectedSpread;
  bool _showSpreadSelection = false;  // Start with question input, not spread selection
  bool _showQuestionInput = true;

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this);

    _heroController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _fadeController.dispose();
    super.dispose();
}

  void _selectSpread(TarotSpreadType spread) {
    setState(() {
      _selectedSpread = spread;
      _showSpreadSelection = false;
    });
  }

  void _backToSpreadSelection() {
    setState(() {
      _showSpreadSelection = true;
      _selectedSpread = null;
    });
  }

  void _proceedFromQuestion() {
    setState(() {
      _showQuestionInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const StandardFortuneAppBar(
        title: '타로 리딩',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Mystical background
                  const _MysticalBackground(),
                  
                  // Main content
                  if (_showQuestionInput) _QuestionInputView(
                      heroTag: widget.heroTag,
                      onProceed: _proceedFromQuestion,
                      fontScale: fontScale
                    )
                  else if (_showSpreadSelection) _SpreadSelectionView(
                      heroTag: widget.heroTag,
                      onSpreadSelected: _selectSpread,
                      fontScale: fontScale
                    )
                  else if (_selectedSpread != null) _TarotReadingView(
                      spreadType: _selectedSpread!,
                      onBack: _backToSpreadSelection,
                      fontScale: fontScale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MysticalBackground extends StatelessWidget {
  const _MysticalBackground();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TossDesignSystem.purple.withValues(alpha:0.05),
            TossDesignSystem.tossBlue.withValues(alpha:0.05),
            TossDesignSystem.purple.withValues(alpha:0.05)
          ]
        )
      ),
      child: CustomPaint(
        painter: _MysticalParticlesPainter(),
        child: Container()
      )
    );
  }
}

class _MysticalParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TossDesignSystem.purple.withValues(alpha:0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _QuestionInputView extends ConsumerStatefulWidget {
  final String? heroTag;
  final VoidCallback onProceed;
  final double fontScale;

  const _QuestionInputView({
    required this.onProceed,
    required this.fontScale,
    this.heroTag});

  @override
  ConsumerState<_QuestionInputView> createState() => _QuestionInputViewState();
}

class _QuestionInputViewState extends ConsumerState<_QuestionInputView> {
  final _questionController = TextEditingController();
  
  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _proceed() {
    
    // Navigate to animated tarot flow
    context.push('/interactive/tarot/animated-flow', extra: {
      'question': _questionController.text.isEmpty ? '오늘의 운세를 봐주세요' : _questionController.text,
      'heroTag': 'daily-fortune-${DateTime.now().millisecondsSinceEpoch}'});
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero animated header
          if (widget.heroTag != null)
            Hero(
              tag: widget.heroTag!,
              child: _TarotHeaderCard(fontScale: widget.fontScale)
            )
          else
            _TarotHeaderCard(fontScale: widget.fontScale),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            '무엇이 궁금하신가요?',
            style: context.heading2.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(
            '마음을 가라앉히고 질문에 집중해주세요',
            style: context.buttonMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.7))),
          const SizedBox(height: 32),
          
          // Question input
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
                      size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '당신의 질문',
                      style: context.buttonMedium.copyWith(
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                TextField(
                  controller: _questionController,
                  style: context.buttonMedium,
                  maxLines: 3,
                  autofocus: false,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    hintText: '예: 나의 연애운은 어떨까요?\n예: 이직을 해야 할까요?\n예: 오늘 하루는 어떨까요?',
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(alpha:0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.purple.withValues(alpha:0.3))),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: TossDesignSystem.purple,
                  size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '질문이 없으시다면 오늘의 전반적인 운세를 봐드립니다',
                    style: context.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Start buttons
          Column(
            children: [
              // Animated flow button
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: _proceed,
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.warningOrange.withValues(alpha: 0.8),
                      TossDesignSystem.warningOrange]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20 * widget.fontScale),
                        SizedBox(width: 8),
                        Text(
                          '애니메이션 타로 (신규)',
                          style: context.heading4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Classic flow button
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () {
                    
                    // Navigate directly to card selection with question
                    context.push('/interactive/tarot', extra: {
                      'question': _questionController.text.isEmpty ? '오늘의 운세를 봐주세요' : _questionController.text,
                      'skipSpreadSelection': null,
                    });
                  },
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.purple,
                      TossDesignSystem.tossBlue]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shuffle, size: 20 * widget.fontScale),
                        const SizedBox(width: 8),
                        Text(
                          '클래식 타로',
                          style: context.heading4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpreadSelectionView extends StatelessWidget {
  final String? heroTag;
  final Function(TarotSpreadType) onSpreadSelected;
  final double fontScale;

  const _SpreadSelectionView({
    required this.onSpreadSelected,
    required this.fontScale,
    this.heroTag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero animated header
          if (heroTag != null)
            Hero(
              tag: heroTag!,
              child: _TarotHeaderCard(fontScale: fontScale))
          else
            _TarotHeaderCard(fontScale: fontScale),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            '스프레드를 선택하세요',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              // heading2
              letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(
            '각 스프레드는 다른 통찰력을 제공합니다',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
              )),
          const SizedBox(height: 32),
          
          // Spread options
          ...TarotSpreadType.values.map((spread) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SpreadOptionCard(
              spread: spread,
              onTap: () => onSpreadSelected(spread),
              fontScale: fontScale,
            ),
          )),
        ],
      ),
    );
  }
}

class _TarotHeaderCard extends StatelessWidget {
  final double fontScale;
  
  const _TarotHeaderCard({required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      width: 120,
      height: 120,
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.purple.withValues(alpha:0.3),
          TossDesignSystem.tossBlue.withValues(alpha:0.3)]),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 56,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SpreadOptionCard extends StatelessWidget {
  final TarotSpreadType spread;
  final VoidCallback onTap;
  final double fontScale;

  const _SpreadOptionCard({
    required this.spread,
    required this.onTap,
    required this.fontScale});

  Widget _buildSpreadPreview() {
    switch (spread) {
      case TarotSpreadType.single:
        return _buildSingleCardPreview();
      case TarotSpreadType.threeCard:
        return _buildThreeCardPreview();
      case TarotSpreadType.celticCross:
        return _buildCelticCrossPreview();
      case TarotSpreadType.relationship:
        return _buildRelationshipPreview();
      case TarotSpreadType.decision:
        return _buildDecisionPreview();
}
  }

  Widget _buildSingleCardPreview() {
    return Center(
      child: Container(
        width: 40,
        height: 60,
        decoration: BoxDecoration(
          color: TossDesignSystem.purple.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TossDesignSystem.purple.withValues(alpha:0.5)),
        ),
      ),
    );
  }

  Widget _buildThreeCardPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 30,
          height: 45,
          decoration: BoxDecoration(
            color: TossDesignSystem.purple.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TossDesignSystem.purple.withValues(alpha:0.5)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCelticCrossPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cross pattern
        Positioned(
          child: Container(
            width: 20,
            height: 30,
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: TossDesignSystem.purple.withValues(alpha:0.5)),
            ),
          ),
        ),
        Positioned(
          left: -25,
          child: Container(
            width: 20,
            height: 30,
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: TossDesignSystem.purple.withValues(alpha:0.5)),
            ),
          ),
        ),
        Positioned(
          right: -25,
          child: Container(
            width: 20,
            height: 30,
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: TossDesignSystem.purple.withValues(alpha:0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 38,
          decoration: BoxDecoration(
            color: TossDesignSystem.pinkPrimary.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TossDesignSystem.pinkPrimary.withValues(alpha:0.5)))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.favorite, size: 20, color: TossDesignSystem.pinkPrimary.withValues(alpha:0.5))),
        Container(
          width: 25,
          height: 38,
          decoration: BoxDecoration(
            color: TossDesignSystem.pinkPrimary.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TossDesignSystem.pinkPrimary.withValues(alpha:0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 25,
          height: 38,
          decoration: BoxDecoration(
            color: TossDesignSystem.tossBlue.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TossDesignSystem.tossBlue.withValues(alpha:0.5)))),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 30,
              decoration: BoxDecoration(
                color: TossDesignSystem.successGreen.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: TossDesignSystem.successGreen.withValues(alpha:0.5)))),
            SizedBox(width: 8),
            Container(
              width: 20,
              height: 30,
              decoration: BoxDecoration(
                color: TossDesignSystem.warningOrange.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: TossDesignSystem.warningOrange.withValues(alpha:0.5)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha:0.05),
            theme.colorScheme.secondary.withValues(alpha:0.05)]),
        child: Row(
          children: [
            // Spread preview
            SizedBox(
              width: 100,
              height: 100,
              child: _buildSpreadPreview()),
            const SizedBox(width: 20),
            
            // Spread info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spread.displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '${spread.cardCount}장의 카드',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                      )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.toll,
                        size: 16,
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${spread.tokenCost} 토큰',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          // labelMedium
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha:0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarotReadingView extends ConsumerStatefulWidget {
  final TarotSpreadType spreadType;
  final VoidCallback onBack;
  final double fontScale;

  const _TarotReadingView({
    required this.spreadType,
    required this.onBack,
    required this.fontScale});

  @override
  ConsumerState<_TarotReadingView> createState() => _TarotReadingViewState();
}

class _TarotReadingViewState extends ConsumerState<_TarotReadingView> {
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _startReading() {
    if (widget.spreadType != TarotSpreadType.single && _questionController.text.isEmpty) {
      Toast.show(
        context,
        message: '질문을 입력해주세요',
        type: ToastType.warning);
      return;
    }

    // Navigate to the existing tarot page with spread type parameter
    context.push('/interactive/tarot', extra: {
      'spreadType': widget.spreadType.value,
      'question': null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TossButton(
              text: '스프레드 다시 선택',
              onPressed: widget.onBack,
              style: TossButtonStyle.text,
              size: TossButtonSize.medium,
              icon: Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(height: 16),
          
          // Selected spread info
          GlassContainer(
            padding: const EdgeInsets.all(20),
            gradient: LinearGradient(
              colors: [
                TossDesignSystem.purple.withValues(alpha:0.1),
                TossDesignSystem.tossBlue.withValues(alpha:0.1)]),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  widget.spreadType.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 8),
                Text(
                  _getSpreadDescription(widget.spreadType),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Question input (except for single card)
          if (widget.spreadType != TarotSpreadType.single) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: theme.colorScheme.primary,
                        size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '질문하기',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          ))]),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _questionController,
                    style: context.buttonMedium,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _getQuestionHint(widget.spreadType),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withValues(alpha:0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Start button
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onPressed: _startReading,
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple,
                  TossDesignSystem.tossBlue]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 20 * widget.fontScale),
                    const SizedBox(width: 8),
                    Text(
                      '카드 뽑기',
                      style: TextStyle(
                        // heading4
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getSpreadDescription(TarotSpreadType type) {
    switch (type) {
      case TarotSpreadType.single:
        return '오늘의 에너지와 조언을 위한 빠른 인사이트';
      case TarotSpreadType.threeCard:
        return '과거, 현재, 미래를 통해 상황을 이해합니다';
      case TarotSpreadType.celticCross:
        return '가장 포괄적인 스프레드로 깊은 통찰력을 제공합니다';
      case TarotSpreadType.relationship:
        return '관계의 역학과 잠재력을 탐구합니다';
      case TarotSpreadType.decision:
        return '중요한 선택을 위한 명확한 가이드를 제공합니다';
    }
  }

  String _getQuestionHint(TarotSpreadType type) {
    switch (type) {
      case TarotSpreadType.single:
        return '';
      case TarotSpreadType.threeCard:
        return '예: 현재 진행 중인 프로젝트가 어떻게 될까요?';
      case TarotSpreadType.celticCross:
        return '예: 제 커리어 방향에 대해 깊은 통찰을 얻고 싶습니다';
      case TarotSpreadType.relationship:
        return '예: 우리 관계의 미래는 어떨까요?';
      case TarotSpreadType.decision:
        return '예: 이직을 해야 할까요, 아니면 현재 직장에 남아야 할까요?';
    }
  }
}

// Glass Button with gradient support
class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Gradient? gradient;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (gradient?.colors.first ?? theme.colorScheme.primary).withValues(alpha:0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: TossDesignSystem.white),
            child: IconTheme(
              data: IconThemeData(color: TossDesignSystem.white),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}