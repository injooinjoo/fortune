import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../widgets/tarot/tarot_question_selector.dart';
import '../../widgets/tarot/tarot_spread_selector.dart';
import '../../widgets/tarot/tarot_multi_card_result.dart';
import '../../../domain/models/tarot_card_model.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../services/ad_service.dart';
import 'widgets/widgets.dart';

class TarotPage extends ConsumerStatefulWidget {
  const TarotPage({super.key});

  @override
  ConsumerState<TarotPage> createState() => _TarotPageState();
}

class _TarotPageState extends ConsumerState<TarotPage>
    with TickerProviderStateMixin {
  TarotFlowState _currentState = TarotFlowState.deckSelection; // 덱 선택부터 시작
  String? _selectedQuestion;
  String? _customQuestion;
  TarotSpreadType? _selectedSpread;
  TarotSpreadResult? _tarotResult;
  TarotDeckType _selectedDeck = TarotDeckType.riderWaite; // 선택 가능하게 변경

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 초기 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    // 페이지 나갈 때 네비게이션 바 다시 표시 - dispose에서 ref 사용 금지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 네비게이션 바 표시는 다른 곳에서 처리하거나 제거
    });

    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Navigation bar is automatically hidden by Scaffold structure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // No need to hide navigation bar explicitly
      }
    });

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _buildCurrentStateWidget(),
            ),
            // 🃏 덱 선택 화면에서 "덱 선택 완료" 버튼
            if (_currentState == TarotFlowState.deckSelection)
              UnifiedButton.floating(
                text: '덱 선택 완료',
                onPressed: () {
                  setState(() {
                    _currentState = TarotFlowState.questioning;
                  });
                },
                isLoading: false,
                isEnabled: true,
              ),
            // ✅ FloatingBottomButton - 타로 결과 화면에서 블러 상태일 때만 표시
            if (_currentState == TarotFlowState.result && _tarotResult != null && _tarotResult!.isBlurred)
              UnifiedButton.floating(
                text: '남은 운세 모두 보기',
                onPressed: _showAdAndUnblur,
                isLoading: false,
                isEnabled: true,
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: _currentState != TarotFlowState.result
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
              onPressed: () {
                // 질문 화면에서 뒤로가면 덱 선택으로
                if (_currentState == TarotFlowState.questioning) {
                  setState(() {
                    _currentState = TarotFlowState.deckSelection;
                  });
                } else if (_currentState == TarotFlowState.spreadSelection) {
                  setState(() {
                    _currentState = TarotFlowState.questioning;
                  });
                } else {
                  context.pop();
                }
              },
            )
          : null,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
      ),
      title: Text(
        '타로 카드',
        style: TextStyle(
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: _currentState == TarotFlowState.result
          ? [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
                onPressed: () => context.go('/fortune'),
              ),
            ]
          : null,
    );
  }

  Widget _buildCurrentStateWidget() {
    switch (_currentState) {
      case TarotFlowState.deckSelection:
        return DeckSelectionScreen(
          key: const ValueKey('deck-selection'),
          selectedDeck: _selectedDeck,
          onDeckSelected: (deck) {
            setState(() {
              _selectedDeck = deck;
            });
          },
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
        );
      case TarotFlowState.initial:
        return InitialScreen(
          key: const ValueKey('initial'),
          onStart: () {
            setState(() {
              _currentState = TarotFlowState.questioning;
            });
          },
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
        );
      case TarotFlowState.questioning:
        return TarotQuestionSelector(
          key: const ValueKey('tarot-question-selector'),
          onQuestionSelected: (question) {
            debugPrint('🟢 Parent received question: $question');
            if (mounted) {
              setState(() {
                _selectedQuestion = question;
                _customQuestion = null;
                debugPrint('🟢 State updated - selectedQuestion: $_selectedQuestion');
              });
            }
          },
          onCustomQuestionChanged: (question) {
            if (mounted) {
              setState(() {
                _customQuestion = question;
                _selectedQuestion = null;
              });
            }
          },
          onStartReading: () {
            // 질문 선택 후 스프레드 선택으로 이동
            setState(() {
              _currentState = TarotFlowState.spreadSelection;
            });
          },
          selectedQuestion: _selectedQuestion,
          customQuestion: _customQuestion,
        );
      case TarotFlowState.spreadSelection:
        final question = _selectedQuestion ?? _customQuestion ?? '일반 운세';
        return TarotSpreadSelector(
          key: const ValueKey('spread-selection'),
          question: question,
          onSpreadSelected: _handleSpreadSelected,
        );
      case TarotFlowState.loading:
        return const LoadingScreen(key: ValueKey('loading'));
      case TarotFlowState.result:
        return _tarotResult != null
            ? TarotMultiCardResult(
                key: const ValueKey('result'),
                result: _tarotResult!,
                onRetry: () {
                  setState(() {
                    _currentState = TarotFlowState.questioning;
                    _tarotResult = null;
                    _selectedSpread = null;
                    _selectedQuestion = null;
                    _customQuestion = null;
                  });
                },
              )
            : const SizedBox();
    }
  }

  Future<void> _handleSpreadSelected(TarotSpreadType spread) async {
    setState(() {
      _selectedSpread = spread;
    });

    // ✅ InterstitialAd 제거: 바로 타로 운세 생성
    final result = await _generateTarotResultAsync();
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _tarotResult = result;
        _currentState = TarotFlowState.result;
      });
    } else {
      // API 실패 시 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('타로 운세를 생성하는 데 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _currentState = TarotFlowState.spreadSelection;
      });
    }
  }

  // 광고와 병렬로 실행할 API 호출 (Future 반환)
  Future<TarotSpreadResult?> _generateTarotResultAsync() async {
    if (_selectedSpread == null) return null;

    try {
      final question = _selectedQuestion ?? _customQuestion ?? '일반 운세';

      // input_conditions 구성
      final inputConditions = {
        'spread_type': _selectedSpread!.name,
        'deck_type': _selectedDeck.name,
        'question': question,
      };

      Logger.info('[TarotPage] 타로 운세 생성 시작: $inputConditions');

      // ✅ Premium 상태 확인
      // ⚠️ 타로 테스트용: Debug Premium 무시, 실제 토큰만 체크
      final tokenState = ref.read(tokenProvider);
      final realPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      final isPremium = realPremium; // Debug Premium 무시

      Logger.info('[TarotPage] Premium 상태: $isPremium (real: $realPremium)');

      // ✅ inputConditions에 isPremium 추가
      final inputConditionsWithPremium = {
        ...inputConditions,
        'isPremium': isPremium,
      };

      // UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);
      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'tarot',
        dataSource: FortuneDataSource.local,
        inputConditions: inputConditionsWithPremium,
      );

      Logger.info('[TarotPage] 타로 운세 생성 완료: ${fortuneResult.score}점');

      // fortuneResult.data에서 TarotSpreadResult로 변환
      final tarotData = fortuneResult.data;
      final cardsData = tarotData['cards'] as List;

      // TarotCard 리스트 재구성
      final cards = cardsData.map((cardJson) {
        return TarotCard(
          deckType: _parseDeckType(cardJson['deck_type'] as String),
          category: _parseCardCategory(cardJson['category'] as String),
          number: cardJson['number'] as int,
          cardName: cardJson['card_name'] as String,
          cardNameKr: cardJson['card_name_kr'] as String,
          isReversed: cardJson['is_reversed'] as bool,
          positionKey: cardJson['position_key'] as String?,
        );
      }).toList();

      // 뽑힌 카드 로깅
      Logger.info('[TarotPage] 🎴 뽑힌 카드 (총 ${cards.length}장):');
      for (int i = 0; i < cards.length; i++) {
        final card = cards[i];
        final direction = card.isReversed ? '역방향' : '정방향';
        Logger.info('  ${i + 1}. ${card.cardNameKr} ($direction)');
      }

      // ✅ 블러 처리 로직
      final isBlurred = !isPremium;
      final blurredSections = isBlurred
          ? ['card_2', 'card_3', 'overall_interpretation'] // 2번째, 3번째 카드 + 전체 해석
          : <String>[];

      Logger.info('[TarotPage] isBlurred: $isBlurred, blurredSections: $blurredSections');

      // TarotSpreadResult 재구성
      return TarotSpreadResult(
        spreadType: _selectedSpread!,
        cards: cards,
        question: question,
        timestamp: DateTime.parse(tarotData['timestamp'] as String),
        overallInterpretation: tarotData['overall_interpretation'] as String,
        positionInterpretations: Map<String, String>.from(
          tarotData['position_interpretations'] as Map,
        ),
        isBlurred: isBlurred, // ✅ 블러 상태
        blurredSections: blurredSections, // ✅ 블러 섹션
      );
    } catch (error, stackTrace) {
      Logger.error('[TarotPage] 타로 운세 생성 실패', error, stackTrace);
      return null;
    }
  }

  // ✅ 광고 시청 후 블러 해제 메서드
  Future<void> _showAdAndUnblur() async {
    if (_tarotResult == null) return;

    Logger.info('[TarotPage] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService();

      // 광고가 준비 안됐으면 로드 (두 번 클릭 방지)
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 광고 로드 시작
        await adService.loadRewardedAd();

        // 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // 타임아웃 처리
        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고 로드에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      // 2. 광고 표시
      Logger.info('[TarotPage] 광고 표시 시작');
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          Logger.info('[TarotPage] 광고 보상 획득, 블러 해제');

          // ✅ 블러 해제 - copyWith로 isBlurred를 false로 변경
          if (mounted) {
            setState(() {
              _tarotResult = _tarotResult!.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('타로 운세가 잠금 해제되었습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[TarotPage] 광고 표시 실패', e, stackTrace);

      // 에러 발생 시에도 블러 해제 (사용자 경험 우선)
      if (_tarotResult != null && mounted) {
        setState(() {
          _tarotResult = _tarotResult!.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시에 실패했지만 운세를 확인할 수 있습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Helper methods for parsing
  TarotDeckType _parseDeckType(String deckTypeStr) {
    switch (deckTypeStr.toLowerCase()) {
      case 'riderwaite':
      case 'before_tarot':
        return TarotDeckType.riderWaite;
      case 'marseille':
      case 'ancient_italian':
        return TarotDeckType.ancientItalian;
      case 'thoth':
        return TarotDeckType.thoth;
      case 'after_tarot':
        return TarotDeckType.afterTarot;
      case 'golden_dawn_cicero':
        return TarotDeckType.goldenDawnCicero;
      case 'golden_dawn_wang':
        return TarotDeckType.goldenDawnWang;
      case 'grand_etteilla':
        return TarotDeckType.grandEtteilla;
      default:
        return TarotDeckType.riderWaite;
    }
  }

  CardCategory _parseCardCategory(String categoryStr) {
    switch (categoryStr.toLowerCase()) {
      case 'major':
        return CardCategory.major;
      case 'cups':
        return CardCategory.cups;
      case 'wands':
        return CardCategory.wands;
      case 'swords':
        return CardCategory.swords;
      case 'pentacles':
        return CardCategory.pentacles;
      default:
        return CardCategory.major;
    }
  }
}
