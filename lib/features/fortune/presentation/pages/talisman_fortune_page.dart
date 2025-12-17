import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../talisman/domain/models/talisman_wish.dart';
import '../../../talisman/presentation/widgets/talisman_wish_selector.dart';
import '../../../talisman/presentation/widgets/talisman_wish_input.dart';
import '../../../talisman/presentation/widgets/talisman_loading_skeleton.dart';
import '../../../talisman/presentation/widgets/talisman_result_card.dart';
import '../../../talisman/presentation/providers/talisman_provider.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../talisman/presentation/widgets/talisman_premium_bottom_sheet.dart';
import '../../../../services/ad_service.dart';
import '../../../../presentation/providers/token_provider.dart';

class TalismanFortunePage extends ConsumerStatefulWidget {
  const TalismanFortunePage({super.key});

  @override
  ConsumerState<TalismanFortunePage> createState() => _TalismanFortunePageState();
}

class _TalismanFortunePageState extends ConsumerState<TalismanFortunePage> {
  TalismanCategory? _selectedCategory;
  String? _selectedWish;

  // Floating button state
  bool _isValid = false;
  bool _isGeneratingAI = false;
  final _wishInputKey = GlobalKey<TalismanWishInputState>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authStateProvider).value;
    final userId = authState?.session?.user.id;

    final talismanState = ref.watch(talismanGenerationProvider(userId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // 결과 페이지에서 백버튼 → 처음으로, 그 외 → 나가기
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: colors.textPrimary,
          onPressed: () {
            if (talismanState.step == TalismanGenerationStep.result) {
              // 결과 페이지에서 백버튼 → 처음으로 돌아가기
              ref.read(talismanGenerationProvider(userId).notifier).reset();
              setState(() {
                _selectedCategory = null;
                _selectedWish = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          '부적',
          style: DSTypography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        // 결과 페이지면 오른쪽 X 버튼
        actions: talismanState.step == TalismanGenerationStep.result
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: colors.textPrimary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
      ),
      body: _buildContent(context, ref, talismanState, userId, colors),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, TalismanGenerationState state, String? userId, DSColorScheme colors) {
    if (state.error != null) {
      return _buildErrorState(context, ref, state.error!, userId, colors);
    }

    switch (state.step) {
      case TalismanGenerationStep.categorySelection:
        return _buildCategorySelection(context, ref, userId);
      case TalismanGenerationStep.wishInput:
        return _buildWishInput(context, ref);
      case TalismanGenerationStep.generation:
        return _buildGenerationAnimation(context, ref);
      case TalismanGenerationStep.result:
        return _buildResult(context, ref, state.design!);
    }
  }

  Widget _buildCategorySelection(BuildContext context, WidgetRef ref, String? userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: TalismanWishSelector(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          ref.read(talismanGenerationProvider(userId).notifier).selectCategory(category);
        },
      ),
    );
  }

  Widget _buildWishInput(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 버튼 높이(58) + 상단 패딩(16) + 하단 Safe Area + 여유 공간
    final scrollBottomPadding = 58 + 16 + bottomPadding + 20;

    // Stack이 화면 전체를 채우도록 SizedBox.expand 사용
    return SizedBox.expand(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, scrollBottomPadding),
            child: TalismanWishInput(
              key: _wishInputKey,
              selectedCategory: _selectedCategory!,
              onWishSubmitted: (wish) async {
                final authState = ref.read(authStateProvider).value;
                final userId = authState?.session?.user.id;

                if (userId == null) {
                  _showLoginRequiredDialog(context);
                  return;
                }

                // 소원 저장 (광고 시청 후 사용)
                setState(() {
                  _selectedWish = wish;
                });

                // 항상 결제 필수 (광고 시청 또는 복주머니 결제)
                if (!mounted || !context.mounted) return;
                await _showPremiumBottomSheet(context);
                // generateTalisman은 결제 성공 후 _handleTokenOption 또는 _handleWatchAd에서 호출됨
              },
              onAIWishSubmitted: (wish, isAIGenerated, imageUrl) async {
                final authState = ref.read(authStateProvider).value;
                final userId = authState?.session?.user.id;

                if (userId == null) {
                  _showLoginRequiredDialog(context);
                  return;
                }

                // AI 생성은 제한 체크 없이 바로 진행
                setState(() {
                  _selectedWish = wish;
                });
                ref.read(talismanGenerationProvider(userId).notifier).generateTalisman(
                  category: _selectedCategory!,
                  specificWish: wish,
                  aiImageUrl: imageUrl, // AI 생성 이미지 URL 전달
                );
              },
              onValidationChanged: (isValid, isLoading) {
                setState(() {
                  _isValid = isValid;
                  _isGeneratingAI = isLoading;
                });
              },
            ),
          ),
          // 다른 페이지와 동일한 위치의 floating button
          UnifiedButton.floating(
            text: _isGeneratingAI ? 'AI가 부적을 만들고 있어요...' : '🎨 AI 맞춤 부적 만들기',
            onPressed: _isValid && !_isGeneratingAI
                ? () {
                    _wishInputKey.currentState?.handleAISubmit();
                  }
                : null,
            isLoading: _isGeneratingAI,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationAnimation(BuildContext context, WidgetRef ref) {
    return TalismanLoadingSkeleton(
      category: _selectedCategory!,
      wishText: _selectedWish ?? "소원을 이루어보세요",
    );
  }

  Widget _buildResult(BuildContext context, WidgetRef ref, design) {
    return TalismanResultCard(
      talismanDesign: design,
      onSave: () {
        // TODO: 부적 저장 로직
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('부적이 저장되었습니다!')),
        );
      },
      onShare: () {
        // TODO: 공유 로직
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유 기능은 준비 중입니다')),
        );
      },
      onSetWallpaper: () {
        // TODO: 배경화면 설정 로직
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('배경화면 설정 기능은 준비 중입니다')),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, String? userId, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: DSColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            '오류가 발생했습니다',
            style: DSTypography.headingSmall.copyWith(
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: DSTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: UnifiedButton(
              text: '다시 시도',
              onPressed: () {
                ref.read(talismanGenerationProvider(userId).notifier).reset();
                setState(() {
                  _selectedCategory = null;
                  _selectedWish = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPremiumBottomSheet(BuildContext context) async {
    // ✅ 토큰 잔액 및 프리미엄 상태 확인
    final tokenState = ref.read(tokenProvider);
    final currentTokens = tokenState.balance?.remainingTokens ?? 0;
    final isPremium = tokenState.hasUnlimitedAccess;

    await TalismanPremiumBottomSheet.show(
      context,
      currentTokens: currentTokens,
      isPremium: isPremium,
      onWatchAd: () async {
        Navigator.of(context).pop();
        await _handleWatchAd();
      },
      onTokenPaid: () async {
        Navigator.of(context).pop();
        await _handleTokenOption();
      },
      onSubscribe: () async {
        Navigator.of(context).pop();
        await _handleSubscription();
      },
      onOneTimePurchase: () async {
        Navigator.of(context).pop();
        await _handleOneTimePurchase();
      },
    );
  }

  Future<void> _handleSubscription() async {
    try {
      // TODO: 실제 구독 처리 로직
      // final purchaseService = InAppPurchaseService();
      // await purchaseService.purchaseSubscription('premium_monthly');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('구독 기능은 준비 중입니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구독 처리 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _handleOneTimePurchase() async {
    try {
      // TODO: 실제 일회성 구매 처리 로직
      // final purchaseService = InAppPurchaseService();
      // await purchaseService.purchaseOneTime('premium_talisman');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('구매 기능은 준비 중입니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구매 처리 중 오류가 발생했습니다: $e')),
      );
    }
  }

  /// ✅ 토큰 결제 처리 (복채 3개 차감)
  Future<void> _handleTokenOption() async {
    try {
      final authState = ref.read(authStateProvider).value;
      final userId = authState?.session?.user.id;

      if (userId == null) {
        _showLoginRequiredDialog(context);
        return;
      }

      // 토큰 차감
      final success = await ref.read(tokenProvider.notifier).consumeTokens(
        fortuneType: 'talisman',
        amount: TalismanPremiumBottomSheet.requiredTokens,
      );

      if (!mounted) return;

      if (success) {
        // 토큰 차감 성공 → 부적 생성 진행
        if (_selectedCategory != null && _selectedWish != null) {
          ref.read(talismanGenerationProvider(userId).notifier).generateTalisman(
            category: _selectedCategory!,
            specificWish: _selectedWish!,
          );
        }
      } else {
        // 토큰 부족 또는 오류
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복채가 부족합니다. 광고를 시청하거나 복채를 충전해주세요.')),
        );
      }
    } catch (e) {
      debugPrint('[TalismanFortunePage] 토큰 차감 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰 차감 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _handleWatchAd() async {
    try {
      final adService = AdService();

      // 광고 준비 확인
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        await adService.loadRewardedAd();

        // 광고 로딩 대기
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

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

      // 광고 표시
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('[TalismanFortunePage] 광고 보상 획득, 부적 생성 진행');

          if (mounted) {
            // 광고 시청 완료 후 부적 생성 진행
            final authState = ref.read(authStateProvider).value;
            final userId = authState?.session?.user.id;

            if (userId != null && _selectedCategory != null && _selectedWish != null) {
              ref.read(talismanGenerationProvider(userId).notifier).generateTalisman(
                category: _selectedCategory!,
                specificWish: _selectedWish!,
              );
            }
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[TalismanFortunePage] 광고 표시 실패: $e\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('광고 표시 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인이 필요합니다'),
        content: const Text('부적을 생성하려면 로그인이 필요합니다.'),
        actions: [
          UnifiedButton(
            text: '취소',
            onPressed: () => Navigator.of(context).pop(),
            style: UnifiedButtonStyle.text,
            size: UnifiedButtonSize.medium,
          ),
          UnifiedButton(
            text: '로그인',
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 로그인 페이지로 이동
            },
            style: UnifiedButtonStyle.text,
            size: UnifiedButtonSize.medium,
          ),
        ],
      ),
    );
  }
}