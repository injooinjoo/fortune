import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../talisman/domain/models/talisman_wish.dart';
import '../../../talisman/presentation/widgets/talisman_wish_selector.dart';
import '../../../talisman/presentation/widgets/talisman_wish_input.dart';
import '../../../talisman/presentation/widgets/talisman_generation_animation.dart';
import '../../../talisman/presentation/widgets/talisman_result_card.dart';
import '../../../talisman/presentation/providers/talisman_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../talisman/presentation/widgets/talisman_premium_bottom_sheet.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider).value;
    final userId = authState?.session?.user.id;

    final talismanState = ref.watch(talismanGenerationProvider(userId));

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: _buildBackButton(context, ref, talismanState.step, userId, isDark),
        title: Text(
          '부적',
          style: TypographyUnified.heading3.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildContent(context, ref, talismanState, userId, isDark),
    );
  }

  Widget _buildBackButton(BuildContext context, WidgetRef ref, TalismanGenerationStep step, String? userId, bool isDark) {
    VoidCallback onTap;

    if (step == TalismanGenerationStep.result) {
      // 결과 페이지: 홈으로 돌아가기
      onTap = () => Navigator.of(context).pop();
    } else if (step != TalismanGenerationStep.categorySelection) {
      // 중간 단계: 이전 단계로
      onTap = () {
        ref.read(talismanGenerationProvider(userId).notifier).goBack();
      };
    } else {
      // 첫 페이지: 뒤로가기 버튼
      onTap = () => Navigator.of(context).pop();
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
      onPressed: onTap,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, TalismanGenerationState state, String? userId, bool isDark) {
    if (state.error != null) {
      return _buildErrorState(context, ref, state.error!, userId, isDark);
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

                // 하루 제한 체크
                final canCreate = await ref.read(dailyTalismanLimitProvider(userId).future);
                if (!mounted || !context.mounted) return;
                if (canCreate) {
                  // 제한 초과 시 프리미엄 안내
                  await _showPremiumBottomSheet(context);
                  return;
                }

                setState(() {
                  _selectedWish = wish;
                });
                ref.read(talismanGenerationProvider(userId).notifier).generateTalisman(
                  category: _selectedCategory!,
                  specificWish: wish,
                );
              },
              onAIWishSubmitted: (wish, isAIGenerated) async {
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
    return TalismanGenerationAnimation(
      category: _selectedCategory!,
      wishText: _selectedWish ?? "소원을 이루어보세요",
      onCompleted: () {
        // 애니메이션 완료 후 자동으로 결과 화면으로 이동됨
      },
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, String? userId, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TossDesignSystem.errorRed,
          ),
          const SizedBox(height: 24),
          Text(
            '오류가 발생했습니다',
            style: TypographyUnified.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
    await TalismanPremiumBottomSheet.show(
      context,
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