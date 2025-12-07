import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/constants/tarot_metadata.dart';
import '../../../../../core/providers/user_settings_provider.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import '../../widgets/mystical_background.dart';
import '../../providers/tarot_storytelling_provider.dart';
import 'widgets/summary_header.dart';
import 'widgets/card_spread_section.dart';
import 'widgets/loading_indicator.dart';
import 'widgets/summary_card.dart';
import 'widgets/element_balance_section.dart';
import 'widgets/advice_section.dart';
import 'widgets/timeline_section.dart';
import 'widgets/share_section.dart';
import 'widgets/card_detail_modal.dart';

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
    this.question,
  });

  static Future<void> show({
    required BuildContext context,
    required List<int> cards,
    required List<String> interpretations,
    required String spreadType,
    String? question,
  }) {
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

  bool _isLoadingSummary = false;
  Map<String, dynamic>? _summaryData;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

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
          'question': null,
        }).future,
      );

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
    final buffer = _buildShareText();
    await Share.share(buffer.toString());
  }

  StringBuffer _buildShareText() {
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

    return buffer;
  }

  Map<String, dynamic> _getCardInfo(int cardIndex) {
    if (cardIndex < 22) {
      final majorCard = TarotMetadata.majorArcana[cardIndex];
      if (majorCard != null) {
        return {
          'name': majorCard.name,
          'keywords': majorCard.keywords,
          'element': majorCard.element,
        };
      }
    }
    return {'name': 'Unknown Card', 'keywords': [], 'element': 'Unknown'};
  }

  void _showCardDetail(int index) {
    final cardIndex = widget.cards[index];
    final position = TarotHelper.getPositionDescription(widget.spreadType, index);

    CardDetailModal.show(
      context: context,
      cardIndex: cardIndex,
      position: position,
      interpretation: widget.interpretations[index],
    );
  }

  void _copyToClipboard() {
    final buffer = _buildShareText();
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('클립보드에 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAsImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이미지 공유 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ref.watch(userSettingsProvider).fontScale;

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
                      SummaryHeader(
                        fontScale: fontScale,
                        question: widget.question,
                        scaleController: _scaleController,
                      ),
                      const SizedBox(height: 24),
                      CardSpreadSection(
                        fontScale: fontScale,
                        cards: widget.cards,
                        spreadType: widget.spreadType,
                        onCardTap: _showCardDetail,
                      ),
                      const SizedBox(height: 32),
                      if (_isLoadingSummary)
                        const LoadingIndicator()
                      else if (_summaryData != null)
                        _buildSummarySection(fontScale),
                      const SizedBox(height: 24),
                      ShareSection(
                        fontScale: fontScale,
                        onShareMessage: _shareReading,
                        onCopy: _copyToClipboard,
                        onShareImage: _shareAsImage,
                      ),
                      const SizedBox(height: 32),
                      const BottomButtonSpacing(),
                    ],
                  ),
                ),
              ),
              UnifiedButton.floating(
                text: '새로운 리딩 시작하기',
                onPressed: () {
                  context.goNamed('interactive-tarot');
                },
                isEnabled: true,
                icon: Icon(Icons.refresh, color: TossDesignSystem.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(double fontScale) {
    return Column(
      children: [
        SummaryCard(
          fontScale: fontScale,
          summary: _summaryData!['summary'] ?? '해석을 생성할 수 없습니다.',
        ),
        if (_summaryData!['elementBalance'] != null) ...[
          const SizedBox(height: 24),
          ElementBalanceSection(
            fontScale: fontScale,
            elementBalance: _summaryData!['elementBalance'] as Map<String, dynamic>,
            dominantElement: _summaryData!['dominantElement'],
          ),
        ],
        if (_summaryData!['advice'] != null) ...[
          const SizedBox(height: 24),
          AdviceSection(
            fontScale: fontScale,
            advice: _summaryData!['advice'] as List,
          ),
        ],
        if (_summaryData!['timeline'] != null) ...[
          const SizedBox(height: 24),
          TimelineSection(
            fontScale: fontScale,
            timeline: _summaryData!['timeline'],
          ),
        ],
      ],
    );
  }
}

class BottomButtonSpacing extends StatelessWidget {
  const BottomButtonSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 80);
  }
}
