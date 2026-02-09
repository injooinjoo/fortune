import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/fortune_haptic_service.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/constants/in_app_products.dart';
import '../../services/in_app_purchase_service.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/toast.dart';
import '../../shared/components/purchase_loading_overlay.dart';
import '../../presentation/providers/subscription_provider.dart';
import '../../presentation/providers/token_provider.dart';

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
      onPurchaseSuccess: (message) async {
        if (mounted) {
          setState(() => _isLoading = false);
          // 구독 상태 업데이트 (상세 정보 포함)
          await ref.read(subscriptionProvider.notifier).setActive(
            true,
            plan: _selectedPlan,
            expiresAt: _calculateExpirationDate(_selectedPlan),
            productId: _selectedPlan == 'monthly'
                ? InAppProducts.monthlySubscription
                : InAppProducts.yearlySubscription,
          );
          if (!mounted) return;
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
      onRestoreCompleted: (hasRestoredItems, restoredCount) {
        if (mounted) {
          setState(() => _isLoading = false);
          if (hasRestoredItems) {
            // 구독 상태 갱신
            ref.read(subscriptionProvider.notifier).checkSubscriptionStatus();
            ref.read(tokenProvider.notifier).loadTokenData();
            Toast.show(
              context,
              message: '$restoredCount개의 구매가 복원되었습니다',
              type: ToastType.success,
            );
          } else {
            Toast.show(
              context,
              message: '복원할 구매 내역이 없습니다',
              type: ToastType.info,
            );
          }
        }
      },
    );
  }

  /// 만료일 계산
  DateTime _calculateExpirationDate(String plan) {
    final now = DateTime.now();
    return plan == 'yearly'
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSubscriber = ref.watch(isSubscriptionActiveProvider);
    final subscriptionState = ref.watch(subscriptionProvider);

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

            // 구독자: 프리미엄 상태 카드
            if (isSubscriber) ...[
              _buildActiveSubscriptionCard(subscriptionState),
              const SizedBox(height: DSSpacing.xl),
            ],

            // 비구독자: 프리미엄 소개 배너 + 플랜 선택
            if (!isSubscriber) ...[
              // Premium Benefits - 황색(Hwang) 그라데이션으로 복/풍요의 느낌
              Container(
                padding: const EdgeInsets.all(DSSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSColors.warning.withValues(alpha: 0.8),
                      DSColors.warning,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: DSColors.warning.withValues(alpha: 0.3),
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
                          color: colors.textPrimary,
                          size: 32,
                        ),
                        const SizedBox(width: DSSpacing.md),
                        Text(
                          '프리미엄운세',
                          style: context.heading2.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.md),
                    Text(
                      '무제한 운세와 프리미엄 기능을 경험하세요',
                      style: context.bodySmall.copyWith(
                        color: colors.textPrimary.withValues(alpha: 0.9),
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
            ],

            // 공통: Premium Features
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
                    icon: Icons.all_inclusive,
                    title: '월간 토큰',
                    subtitle: '매월 50개 토큰 지급',
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

            // Subscription Management & Restore Buttons (Apple 심사 필수)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _showSubscriptionManagementGuide(context),
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  label: Text(
                    '구독 관리',
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: colors.border,
                  margin: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
                ),
                TextButton.icon(
                  onPressed: _isLoading ? null : _restorePurchases,
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: colors.accent,
                  ),
                  label: Text(
                    '구매 복원',
                    style: context.bodySmall.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100), // FloatingBottomButton 공간 확보
          ],
        ),
          ),

          // Floating Bottom Button (구독자가 아닌 경우에만 표시)
          if (!isSubscriber)
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

          // 결제 진행 중 로딩 오버레이
          PurchaseLoadingOverlay(
            isVisible: _isLoading,
            message: '결제 처리 중...',
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
            // 선택 강조
            color: isSelected ? DSColors.error : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DSColors.error.withValues(alpha: 0.2),
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
                  color: isSelected ? DSColors.error : colors.border,
                  width: 2,
                ),
                color: isSelected ? DSColors.error : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: colors.surface,
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
                            // 배지 강조
                            color: DSColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: context.labelSmall.copyWith(
                              color: DSColors.error,
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
            // 프리미엄 혜택 아이콘
            color: DSColors.warning,
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

  /// 활성 구독 상태 카드 (구독자용)
  Widget _buildActiveSubscriptionCard(SubscriptionState subscriptionState) {
    final colors = context.colors;
    final planName = subscriptionState.plan == 'yearly' ? '연간 구독' : '월간 구독';
    final remainingDays = subscriptionState.remainingDays;
    final expiresAt = subscriptionState.expiresAt;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.warning.withValues(alpha: 0.8),
            DSColors.warning,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: DSColors.warning.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘 + 타이틀
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: colors.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '프리미엄운세',
                    style: context.heading3.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      planName,
                      style: context.labelSmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 구독 중 뱃지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: DSColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '구독 중',
                      style: context.labelSmall.copyWith(
                        color: DSColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.lg),

          // 구독 정보 박스
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Column(
              children: [
                // 남은 기간
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '남은 기간',
                      style: context.bodySmall.copyWith(
                        color: colors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$remainingDays일',
                      style: context.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                // 구분선
                Divider(
                  color: colors.surface.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: DSSpacing.sm),
                // 다음 결제일
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '다음 결제일',
                      style: context.bodySmall.copyWith(
                        color: colors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      expiresAt != null
                          ? '${expiresAt.year}.${expiresAt.month.toString().padLeft(2, '0')}.${expiresAt.day.toString().padLeft(2, '0')}'
                          : '-',
                      style: context.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: DSSpacing.md),

          // 구독 관리 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSubscriptionManagementGuide(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.textPrimary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
              ),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: Text(
                '구독 관리',
                style: context.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  void _showSubscriptionManagementGuide(BuildContext context) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      barrierColor: DSColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: colors.accent,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '구독 관리 방법',
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.lg),
                Text(
                  '구독 취소 및 관리는 Apple ID 설정에서 가능합니다:\n\n'
                  '1. 설정 앱 열기\n'
                  '2. 상단의 [내 이름] 탭\n'
                  '3. [구독] 선택\n'
                  '4. Fortune 앱 선택\n'
                  '5. [구독 취소] 또는 플랜 변경\n\n'
                  '• 구독 기간 종료 최소 24시간 전에 취소해야 다음 결제가 되지 않습니다.\n'
                  '• 무료 체험 기간 중 취소하면 체험 기간 종료와 함께 구독이 해지됩니다.',
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: DSSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '확인',
                      style: context.bodyMedium.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
