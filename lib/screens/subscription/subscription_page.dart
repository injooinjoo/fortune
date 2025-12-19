import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/theme/obangseok_colors.dart';
import '../../core/theme/typography_unified.dart';
import '../../core/services/fortune_haptic_service.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/constants/in_app_products.dart';
import '../../services/in_app_purchase_service.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/toast.dart';
import '../../presentation/providers/subscription_provider.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  String _selectedPlan = 'free'; // free, monthly, yearly
  bool _isLoading = false;
  final InAppPurchaseService _purchaseService = InAppPurchaseService();

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    await _purchaseService.initialize();
    if (!mounted) return;
    _purchaseService.setContext(context);
    _purchaseService.setCallbacks(
      onPurchaseStarted: () {
        if (mounted) {
          setState(() => _isLoading = true);
        }
      },
      onPurchaseSuccess: (message) {
        if (mounted) {
          setState(() => _isLoading = false);
          // 구독 상태 업데이트
          ref.read(subscriptionProvider.notifier).setActive(true);
          Toast.show(context, message: message, type: ToastType.success);
          Navigator.of(context).pop(); // 구독 완료 후 이전 화면으로
        }
      },
      onPurchaseError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          Toast.show(context, message: error, type: ToastType.error);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppHeader(
        title: '구독 관리',
        showBackButton: true,
        showTokenBalance: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DSSpacing.md),

            // Premium Benefits - 황색(Hwang) 그라데이션으로 복/풍요의 느낌
            Container(
              padding: const EdgeInsets.all(DSSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ObangseokColors.hwangLight,
                    ObangseokColors.hwang,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(DSRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: ObangseokColors.hwang.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Text(
                        '프리미엄운세',
                        style: context.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    '무제한 운세와 프리미엄 기능을 경험하세요',
                    style: context.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.xl),

            // Plan Selection
            Text(
              '구독 플랜 선택',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // Free Plan
            _buildPlanCard(
              id: 'free',
              title: '무료',
              price: '₩0',
              period: '',
              badge: '지금',
            ),

            const SizedBox(height: DSSpacing.md),

            // Monthly Plan
            _buildPlanCard(
              id: 'monthly',
              title: '월간 구독',
              price: '₩2,200',
              period: '/ 월',
              badge: null,
            ),

            const SizedBox(height: DSSpacing.md),

            // Yearly Plan
            _buildPlanCard(
              id: 'yearly',
              title: '연간 구독',
              price: '₩19,000',
              period: '/ 년',
              badge: '28% 절약',
              originalPrice: '₩26,400',
            ),

            const SizedBox(height: DSSpacing.xl),

            // Premium Features
            Text(
              '프리미엄운세 혜택',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.all_inclusive,
                    title: '무제한 운세',
                    subtitle: '모든 운세를 무제한으로 확인',
                  ),
                  _buildFeatureItem(
                    icon: Icons.block,
                    title: '광고 제거',
                    subtitle: '광고 없이 깔끔하게',
                  ),
                  _buildFeatureItem(
                    icon: Icons.star,
                    title: '프리미엄 운세',
                    subtitle: '더 상세한 프리미엄 운세',
                  ),
                  _buildFeatureItem(
                    icon: Icons.priority_high,
                    title: '우선 지원',
                    subtitle: '고객센터 우선 응대',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.xxl),

            // Terms
            Center(
              child: Text(
                '구독은 언제든 해지 가능합니다\n자동 갱신되며 해지 전까지 요금이 청구됩니다',
                textAlign: TextAlign.center,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: DSSpacing.lg),

            // Subscription Management Guide (Apple 심사 필수)
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: colors.accent,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Text(
                        '구독 관리 방법',
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    '구독 취소 및 관리는 Apple ID 설정에서 가능합니다:\n\n'
                    '1. 설정 앱 열기\n'
                    '2. 상단의 [내 이름] 탭\n'
                    '3. [구독] 선택\n'
                    '4. Fortune 앱 선택\n'
                    '5. [구독 취소] 또는 플랜 변경\n\n'
                    '• 구독 기간 종료 최소 24시간 전에 취소해야 다음 결제가 되지 않습니다.\n'
                    '• 무료 체험 기간 중 취소하면 체험 기간 종료와 함께 구독이 해지됩니다.',
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // Restore Purchases Button (Apple 심사 필수)
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _restorePurchases,
                child: Text(
                  '이전 구매 복원',
                  style: context.bodySmall.copyWith(
                    color: colors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100), // FloatingBottomButton 공간 확보
          ],
        ),
          ),

          // Floating Bottom Button
          UnifiedButton.floating(
            text: _isLoading
                ? '처리 중...'
                : _selectedPlan == 'free'
                    ? '무료 플랜 사용 중'
                    : _selectedPlan == 'monthly'
                        ? '월간 구독 시작하기 - ₩2,200/월'
                        : '연간 구독 시작하기 - ₩19,000/년',
            onPressed: _selectedPlan == 'free' || _isLoading ? null : _startSubscription,
            isEnabled: _selectedPlan != 'free' && !_isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String period,
    String? badge,
    String? originalPrice,
  }) {
    final colors = context.colors;
    final isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () {
        ref.read(fortuneHapticServiceProvider).selection();
        setState(() {
          _selectedPlan = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            // 인주색(Inju) - 전통 도장 색상으로 선택 강조
            color: isSelected ? ObangseokColors.inju : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ObangseokColors.inju.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ObangseokColors.inju : colors.border,
                  width: 2,
                ),
                color: isSelected ? ObangseokColors.inju : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: DSSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            // 인주색으로 배지 강조
                            color: ObangseokColors.inju.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: context.labelSmall.copyWith(
                              color: ObangseokColors.inju,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: context.heading3.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        period,
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: DSSpacing.sm),
                        Text(
                          originalPrice,
                          style: context.labelSmall.copyWith(
                            color: colors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : colors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            // 황색 - 프리미엄 혜택 아이콘
            color: ObangseokColors.hwang,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startSubscription() async {
    if (_isLoading) return;

    String productId;
    if (_selectedPlan == 'monthly') {
      productId = InAppProducts.monthlySubscription;
    } else if (_selectedPlan == 'yearly') {
      productId = InAppProducts.yearlySubscription;
    } else {
      return; // free plan selected
    }

    try {
      setState(() => _isLoading = true);
      ref.read(fortuneHapticServiceProvider).jackpot();
      await _purchaseService.purchaseProduct(productId);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Toast.show(context, message: e.toString(), type: ToastType.error);
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);
      await _purchaseService.restorePurchases();
      if (mounted) {
        Toast.show(context, message: '구매 복원을 시작합니다...', type: ToastType.info);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Toast.show(context, message: e.toString(), type: ToastType.error);
      }
    }
  }
}
