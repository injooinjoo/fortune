import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/in_app_products.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
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
  final GlobalKey _plansSectionKey = GlobalKey();

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
      return '스토어 상품을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
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
      _showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    try {
      await _iapService.restorePurchases();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPurchasing = false);
      _showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _scrollToPlans() async {
    final context = _plansSectionKey.currentContext;
    if (context == null) {
      return;
    }

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
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
          const _PremiumHeroCard(),
          const SizedBox(height: DSSpacing.lg),
          const _PremiumFeatureRow(
            icon: Icons.auto_stories_outlined,
            title: '아름다운 일러스트',
            subtitle: '전문 작가의 손길로 그려진 당신만의 이야기',
          ),
          const SizedBox(height: DSSpacing.sm),
          const _PremiumFeatureRow(
            icon: Icons.menu_book_outlined,
            title: '스토리텔링',
            subtitle: '지루하지 않은 재미있는 사주 해석',
          ),
          const SizedBox(height: DSSpacing.sm),
          const _PremiumFeatureRow(
            icon: Icons.star_outline,
            title: '심층 분석',
            subtitle: '더 깊이 있는 인사이트 분석 제공',
          ),
          const SizedBox(height: DSSpacing.xxl),
          PaperRuntimeButton(
            label: '프리미엄 사주 시작하기',
            onPressed: _isStoreLoading ? null : _scrollToPlans,
          ),
          const SizedBox(height: 120),
          Container(
            key: _plansSectionKey,
            child: PaperRuntimeExpandablePanel(
              title: '플랜 및 토큰 옵션',
              subtitle: '구독, 토큰 충전, 프리미엄 콘텐츠, 구매 복원',
              initiallyExpanded: _storeError != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_storeError != null) ...[
                    _ErrorPanel(
                      message: _storeError!,
                      onRetry: _loadStore,
                    ),
                    const SizedBox(height: DSSpacing.lg),
                  ],
                  if (_isStoreLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: DSSpacing.lg),
                  ],
                  if (subscriptions.isNotEmpty) ...[
                    const _SectionHeader(title: '구독 플랜'),
                    const SizedBox(height: DSSpacing.sm),
                    ...subscriptions.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                        child: _SubscriptionTile(
                          product: product,
                          isHighlighted:
                              product.id == InAppProducts.proSubscription,
                          isBusy: _isPurchasing,
                          onPressed: () => _purchaseProduct(product.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                  ],
                  if (tokenProducts.isNotEmpty) ...[
                    const _SectionHeader(title: '토큰 충전'),
                    const SizedBox(height: DSSpacing.sm),
                    PaperRuntimePanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < tokenProducts.length; i++) ...[
                            _TokenRow(
                              product: tokenProducts[i],
                              isBusy: _isPurchasing,
                              onPressed: () =>
                                  _purchaseProduct(tokenProducts[i].id),
                            ),
                            if (i < tokenProducts.length - 1)
                              Divider(
                                height: 1,
                                indent: DSSpacing.lg,
                                endIndent: DSSpacing.lg,
                                color: context.colors.border
                                    .withValues(alpha: 0.5),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                  ],
                  if (ownedProducts.isNotEmpty) ...[
                    const _SectionHeader(title: '프리미엄 콘텐츠'),
                    const SizedBox(height: DSSpacing.sm),
                    ...ownedProducts.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                        child: _LifetimeCard(
                          product: product,
                          isBusy: _isPurchasing,
                          onPressed: () => _purchaseProduct(product.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                  ],
                  Center(
                    child: TextButton(
                      onPressed: _isPurchasing ? null : _restorePurchases,
                      child: Text(
                        '이전 구매 복원',
                        style: context.bodySmall.copyWith(
                          color: context.colors.textTertiary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '프리미엄 인사이트'),
      body: PurchaseLoadingOverlay.wrapWithOverlay(
        isLoading: _isPurchasing,
        loadingMessage: 'App Store 결제를 준비하는 중...',
        child: PaperRuntimeBackground(
          showRings: false,
          ringAlignment: Alignment.topCenter,
          child: body,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Helpers — always prefer local Korean productInfo over store strings
// ═══════════════════════════════════════════════════════════════════════

String _localTitle(ProductDetails product) {
  return InAppProducts.productDetails[product.id]?.title ??
      product.title.trim();
}

String _localDescription(ProductDetails product) {
  final local = InAppProducts.productDetails[product.id]?.description;
  if (local != null && local.isNotEmpty) return local;
  final store = product.description.trim();
  return store.isNotEmpty ? store : '';
}

// ═══════════════════════════════════════════════════════════════════════
//  Hero Panel
// ═══════════════════════════════════════════════════════════════════════

class _PremiumHeroCard extends StatelessWidget {
  const _PremiumHeroCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PaperRuntimePanel(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.xl,
        DSSpacing.xxl,
        DSSpacing.xl,
        DSSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.backgroundSecondary.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.72),
                ),
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 34,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          Center(
            child: Text(
              '프리미엄 사주',
              style: context.heading4.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Center(
            child: Text(
              '만화로 보는 재미있는 사주 풀이',
              style: context.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PremiumFeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.72),
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: context.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Section Header — simple left-aligned label
// ═══════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Text(
        title,
        style: context.heading4.copyWith(
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Subscription Tile — card with inline CTA
// ═══════════════════════════════════════════════════════════════════════

class _SubscriptionTile extends StatelessWidget {
  final ProductDetails product;
  final bool isHighlighted;
  final bool isBusy;
  final VoidCallback onPressed;

  const _SubscriptionTile({
    required this.product,
    required this.isHighlighted,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = InAppProducts.productDetails[product.id];

    return PaperRuntimePanel(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: title + price
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _localTitle(product),
                        style: context.heading4.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (isHighlighted) ...[
                      const SizedBox(width: DSSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.textPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '추천',
                          style: context.labelSmall.copyWith(
                            color: colors.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${product.price}/월',
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.xs),

          // Row 2: description
          Text(
            _localDescription(product),
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),

          // Row 3: benefit chips
          if (info != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              product.id == InAppProducts.maxSubscription
                  ? '모든 기능 무제한 · 자동 갱신'
                  : '자동 갱신 구독',
              style: context.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],

          const SizedBox(height: DSSpacing.md),

          // CTA
          SizedBox(
            width: double.infinity,
            child: PaperRuntimeButton(
              label: '구독하기',
              isLoading: isBusy,
              onPressed: isBusy ? null : onPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Token Row — compact list-item inside a shared panel
// ═══════════════════════════════════════════════════════════════════════

class _TokenRow extends StatelessWidget {
  final ProductDetails product;
  final bool isBusy;
  final VoidCallback onPressed;

  const _TokenRow({
    required this.product,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = InAppProducts.productDetails[product.id];
    final hasBonusChip = info?.bonusPoints != null && info!.bonusPoints! > 0;
    final isBestValue = product.id == InAppProducts.tokens200;

    return InkWell(
      onTap: isBusy ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        child: Row(
          children: [
            // Left: title + bonus
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _localTitle(product),
                        style: context.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: DSSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BEST',
                            style: context.labelSmall.copyWith(
                              color: colors.background,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasBonusChip)
                    Text(
                      '+${info.bonusPoints} 보너스 포함',
                      style: context.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),

            // Right: price + chevron
            Text(
              product.price,
              style: context.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: DSSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Lifetime Card — non-consumable product
// ═══════════════════════════════════════════════════════════════════════

class _LifetimeCard extends StatelessWidget {
  final ProductDetails product;
  final bool isBusy;
  final VoidCallback onPressed;

  const _LifetimeCard({
    required this.product,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PaperRuntimePanel(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _localTitle(product),
                  style: context.heading4.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                product.price,
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            _localDescription(product),
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '한 번 구매 · 평생 이용',
            style: context.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          SizedBox(
            width: double.infinity,
            child: PaperRuntimeButton(
              label: '구매하기',
              isLoading: isBusy,
              onPressed: isBusy ? null : onPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Error Panel
// ═══════════════════════════════════════════════════════════════════════

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return PaperRuntimePanel(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연결 오류',
            style: context.heading4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            message,
            style: context.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          PaperRuntimeButton(
            label: '다시 시도',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
