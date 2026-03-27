import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/in_app_products.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
import '../../features/character/presentation/utils/fortune_chat_navigation.dart';
import '../../presentation/providers/user_profile_notifier.dart';
import '../../services/in_app_purchase_service.dart';
import '../../shared/components/purchase_loading_overlay.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  final InAppPurchaseService _iapService = InAppPurchaseService();

  List<ProductDetails> _storeProducts = const [];
  bool _isStoreLoading = true;
  bool _isPurchasing = false;
  String? _storeError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureCallbacks();
      unawaited(_loadStore());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _iapService.setContext(context);
  }

  void _configureCallbacks() {
    _iapService.setContext(context);
    _iapService.setCallbacks(
      onPurchaseStarted: () {
        if (!mounted) return;
        setState(() => _isPurchasing = true);
      },
      onPurchaseSuccess: (message) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
        _showSnackBar(message);
        _refreshAccountState();
      },
      onPurchaseCompleted: (_, __, ___) => _refreshAccountState(),
      onSubscriptionActivated: (_, __) => _refreshAccountState(),
      onPurchaseError: (error) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
        _showSnackBar(error, isError: true);
      },
      onPurchaseCanceled: () {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
      },
      onRestoreCompleted: (hasRestoredItems, restoredCount) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
        final message = hasRestoredItems
            ? '구매 $restoredCount건이 복원되었습니다.'
            : '복원할 구매 항목이 없습니다.';
        _showSnackBar(message);
        if (hasRestoredItems) {
          _refreshAccountState();
        }
      },
    );
  }

  void _refreshAccountState() {
    unawaited(ref.read(userProfileNotifierProvider.notifier).refresh());
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.colors.error : null,
      ),
    );
  }

  Future<void> _loadStore() async {
    if (mounted) {
      setState(() {
        _isStoreLoading = true;
        _storeError = null;
      });
    }

    await _iapService.initialize();
    if (!mounted) return;

    final products = [..._iapService.getProducts()]..sort(
        (a, b) => InAppProducts.displayPriority(a.id).compareTo(
          InAppProducts.displayPriority(b.id),
        ),
      );

    setState(() {
      _storeProducts = products;
      _isStoreLoading = false;
      _storeError = _resolveStoreError(products);
    });
  }

  String? _resolveStoreError(List<ProductDetails> products) {
    if (!_iapService.isAvailable) {
      return '현재 기기에서 인앱 구매를 사용할 수 없습니다.';
    }

    if (products.isEmpty) {
      return '스토어 상품을 불러오지 못했습니다. App Store Connect sandbox 설정을 확인해 주세요.';
    }

    return null;
  }

  List<ProductDetails> _productsFor(List<String> ids) {
    return _storeProducts.where((product) => ids.contains(product.id)).toList();
  }

  Future<void> _purchaseProduct(String productId) async {
    setState(() => _isPurchasing = true);

    try {
      final started = await _iapService.purchaseProduct(productId);
      if (!started && mounted) {
        setState(() => _isPurchasing = false);
        _showSnackBar('구매를 시작하지 못했습니다.', isError: true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPurchasing = false);
      _showSnackBar(error.toString().replaceFirst('Exception: ', ''),
          isError: true);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);

    try {
      await _iapService.restorePurchases();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPurchasing = false);
      _showSnackBar(error.toString().replaceFirst('Exception: ', ''),
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = _productsFor(InAppProducts.subscriptionIds);
    final tokenProducts = _productsFor(InAppProducts.consumableIds);
    final ownedProducts = _productsFor(InAppProducts.nonConsumableIds);

    final body = RefreshIndicator(
      onRefresh: _loadStore,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.md,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        children: [
          const _StoreHeroPanel(),
          const SizedBox(height: DSSpacing.lg),
          if (_storeError != null) ...[
            _StoreStatusPanel(
              title: '스토어 연결 확인 필요',
              description: _storeError!,
              actionLabel: '다시 불러오기',
              onAction: _loadStore,
            ),
            const SizedBox(height: DSSpacing.lg),
          ],
          if (_isStoreLoading) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: DSSpacing.lg),
          ],
          if (subscriptions.isNotEmpty) ...[
            _StoreSection(
              title: '구독',
              subtitle: 'App Review에서 Pro 구독을 바로 확인할 수 있습니다.',
              children: subscriptions
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.md),
                      child: _StoreProductCard(
                        product: product,
                        ctaLabel: '구독하기',
                        isBusy: _isPurchasing,
                        onPressed: () => _purchaseProduct(product.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: DSSpacing.lg),
          ],
          if (tokenProducts.isNotEmpty) ...[
            _StoreSection(
              title: '토큰 상품',
              subtitle: 'Sandbox에서 100 Tokens를 포함한 토큰 패키지를 확인할 수 있습니다.',
              children: tokenProducts
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.md),
                      child: _StoreProductCard(
                        product: product,
                        ctaLabel: '토큰 구매',
                        isBusy: _isPurchasing,
                        onPressed: () => _purchaseProduct(product.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: DSSpacing.lg),
          ],
          if (ownedProducts.isNotEmpty) ...[
            _StoreSection(
              title: '평생 소유 상품',
              subtitle: '복원 가능한 비소모성 콘텐츠입니다.',
              children: ownedProducts
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.md),
                      child: _StoreProductCard(
                        product: product,
                        ctaLabel: '구매하기',
                        isBusy: _isPurchasing,
                        onPressed: () => _purchaseProduct(product.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: DSSpacing.lg),
          ],
          _StoreStatusPanel(
            title: '구매 복원',
            description: '이전에 구매한 구독 또는 비소모성 상품을 복원합니다.',
            actionLabel: '구매 복원',
            onAction: _restorePurchases,
            secondaryLabel: '프리미엄 사주 보기',
            onSecondaryAction: () => openFortuneChat(
              context,
              'premium-saju',
              entrySource: 'premium_store',
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '구독 및 토큰 구매'),
      body: PurchaseLoadingOverlay.wrapWithOverlay(
        isLoading: _isPurchasing,
        loadingMessage: 'App Store 결제를 준비하는 중...',
        child: PaperRuntimeBackground(
          ringAlignment: Alignment.topCenter,
          child: body,
        ),
      ),
    );
  }
}

class _StoreHeroPanel extends StatelessWidget {
  const _StoreHeroPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PaperRuntimePanel(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.xl,
        DSSpacing.lg,
        DSSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.72),
                  ),
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  size: 24,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '스토어',
                      style: context.labelLarge.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Pro 구독과 토큰 상품을 여기서 바로 구매할 수 있어요.',
                      style: context.heading4.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            '리뷰 계정으로 로그인한 뒤 이 화면에서 App Store sandbox 결제 시트를 바로 열 수 있습니다.',
            style: context.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _StoreSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.heading4.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          subtitle,
          style: context.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        ...children,
      ],
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final ProductDetails product;
  final String ctaLabel;
  final bool isBusy;
  final VoidCallback onPressed;

  const _StoreProductCard({
    required this.product,
    required this.ctaLabel,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final productInfo = InAppProducts.productDetails[product.id];
    final badge = _badgeFor(product.id);
    final fallbackDescription = productInfo?.description ?? '상품 설명을 불러오는 중입니다.';
    final description = product.description.trim().isNotEmpty
        ? product.description.trim()
        : fallbackDescription;

    return PaperRuntimePanel(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title.trim(),
                      style: context.heading4.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      description,
                      style: context.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                product.price,
                style: context.heading4.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              if (badge != null)
                DSChip(
                  label: badge,
                  style: DSChipStyle.outlined,
                ),
              DSChip(
                label: _typeLabel(product.id),
                style: DSChipStyle.outlined,
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: PaperRuntimeButton(
              label: ctaLabel,
              expanded: false,
              isLoading: isBusy,
              onPressed: isBusy ? null : onPressed,
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String productId) {
    if (InAppProducts.subscriptionIds.contains(productId)) {
      return '자동 갱신 구독';
    }
    if (InAppProducts.nonConsumableIds.contains(productId)) {
      return '비소모성';
    }
    return '소모성';
  }

  String? _badgeFor(String productId) {
    if (productId == InAppProducts.proSubscription) {
      return 'Review Target';
    }
    if (productId == InAppProducts.tokens100) {
      return '100 Tokens';
    }
    if (productId == InAppProducts.tokens200) {
      return 'Best Value';
    }
    return null;
  }
}

class _StoreStatusPanel extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  const _StoreStatusPanel({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return PaperRuntimePanel(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.heading4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            description,
            style: context.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          Row(
            children: [
              Expanded(
                child: PaperRuntimeButton(
                  label: actionLabel,
                  onPressed: onAction,
                ),
              ),
              if (secondaryLabel != null && onSecondaryAction != null) ...[
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: PaperRuntimeButton(
                    label: secondaryLabel!,
                    variant: PaperRuntimeButtonVariant.secondary,
                    onPressed: onSecondaryAction,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
