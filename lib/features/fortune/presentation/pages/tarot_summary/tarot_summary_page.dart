import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/constants/tarot_metadata.dart';
import '../../../../../core/providers/user_settings_provider.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../services/ad_service.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../core/utils/fortune_completion_helper.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../presentation/providers/subscription_provider.dart';
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

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

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

    // ✅ Premium 체크 및 Blur 상태 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final tokenState = ref.read(tokenProvider);
        final isPremium = tokenState.hasUnlimitedAccess ||
            (tokenState.balance?.remainingTokens ?? 0) > 0;

        setState(() {
          _isBlurred = !isPremium;
          _blurredSections = _isBlurred ? ['advice', 'timeline'] : [];
        });

        debugPrint('🔒 [타로요약] isPremium: $isPremium, isBlurred: $_isBlurred');
      }
    });
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
      backgroundColor: DSColors.textPrimary,
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
              // ✅ 블러 상태일 때: 광고 버튼 / 아닐 때: 새로운 리딩 버튼
              if (_isBlurred && !ref.watch(isPremiumProvider))
                UnifiedButton.floating(
                  text: '광고 보고 전체 내용 확인하기',
                  onPressed: _showAdAndUnblur,
                  isEnabled: true,
                )
              else
                UnifiedButton.floating(
                  text: '새로운 리딩 시작하기',
                  onPressed: () {
                    context.goNamed('interactive-tarot');
                  },
                  isEnabled: true,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ RewardedAd 패턴
  Future<void> _showAdAndUnblur() async {
    debugPrint('[타로요약] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[타로요약] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[타로요약] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: DSColors.error,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('[타로요약] ✅ 광고 시청 완료, 블러 해제');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'tarot-summary');
          }

          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[타로요약] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: DSColors.warning,
          ),
        );
      }
    }
  }

  Widget _buildSummarySection(double fontScale) {
    return Column(
      children: [
        // ✅ 무료: 종합 해석
        SummaryCard(
          fontScale: fontScale,
          summary: _summaryData!['summary'] ?? '해석을 생성할 수 없습니다.',
        ),
        // ✅ 무료: 원소 균형
        if (_summaryData!['elementBalance'] != null) ...[
          const SizedBox(height: 24),
          ElementBalanceSection(
            fontScale: fontScale,
            elementBalance: _summaryData!['elementBalance'] as Map<String, dynamic>,
            dominantElement: _summaryData!['dominantElement'],
          ),
        ],
        // ✅ Premium: 조언 섹션 (블러 처리)
        if (_summaryData!['advice'] != null) ...[
          const SizedBox(height: 24),
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'advice',
            child: AdviceSection(
              fontScale: fontScale,
              advice: _summaryData!['advice'] as List,
            ),
          ),
        ],
        // ✅ Premium: 타임라인 섹션 (블러 처리)
        if (_summaryData!['timeline'] != null) ...[
          const SizedBox(height: 24),
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'timeline',
            child: TimelineSection(
              fontScale: fontScale,
              timeline: _summaryData!['timeline'],
            ),
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
