import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/obangseok_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/in_app_purchase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/constants/in_app_products.dart';
import '../../../../presentation/providers/token_provider.dart';
import 'payment_result_page.dart';

class TokenPurchasePage extends ConsumerStatefulWidget {
  const TokenPurchasePage({super.key});

  @override
  ConsumerState<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends ConsumerState<TokenPurchasePage> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  
  int? _selectedPackageIndex;
  bool _isProcessing = false;
  bool _isLoading = true;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _setupPurchaseCallbacks();
    _initializeInAppPurchase();
  }

  void _setupPurchaseCallbacks() {
    _purchaseService.setCallbacks(
      onPurchaseCompleted: (productId, productName, tokenAmount) {
        // 실제 결제 완료 시 결과 페이지로 이동
        ref.invalidate(tokenBalanceProvider);
        if (mounted) {
          setState(() => _isProcessing = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentResultPage(
                isSuccess: true,
                productName: productName,
                tokenAmount: tokenAmount,
              ),
            ),
          );
        }
      },
      onPurchaseError: (error) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
      onPurchaseCanceled: () {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      },
    );
  }

  Future<void> _initializeInAppPurchase() async {
    setState(() => _isLoading = true);
    
    try {
      await _purchaseService.initialize();
      await _loadProducts();
    } catch (e) {
      Logger.error('인앱결제 초기화 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제 시스템을 초기화할 수 없습니다')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProducts() async {
    await _purchaseService.loadProducts();
    setState(() {
      // 월간 구독 제외, 복주머니(소모성) 상품만 필터링
      final filteredProducts = _purchaseService.products.where((product) {
        // 월간 구독 제외
        if (product.id == InAppProducts.monthlySubscription) return false;
        // 소모성 상품만 포함
        return InAppProducts.consumableIds.contains(product.id);
      }).toList();

      // 토큰 수 기준 오름차순 정렬 (작은 것부터)
      filteredProducts.sort((a, b) {
        final aInfo = InAppProducts.productDetails[a.id];
        final bInfo = InAppProducts.productDetails[b.id];
        return (aInfo?.tokens ?? 0).compareTo(bInfo?.tokens ?? 0);
      });

      _products = filteredProducts;
    });
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '복주머니 구매'),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!_purchaseService.isAvailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '인앱결제를 사용할 수 없습니다.\\n앱스토어 설정을 확인해주세요.',
            textAlign: TextAlign.center,
            style: DSTypography.bodyLarge.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      );
    }

    // IAP 상품이 없으면 Mock 데이터로 UI 표시 (스크린샷용)
    final bool useMockData = _products.isEmpty;

    return Stack(
      children: [
        // 스크롤 가능한 콘텐츠
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 160), // 하단 버튼 공간 확보
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentBalance(),
              const SizedBox(height: 24),
              _buildPackageList(useMockData: useMockData),
              const SizedBox(height: 32),
              _buildDescription(),
            ],
          ),
        ),
        // Floating 버튼 영역
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildFloatingButtons(),
        ),
      ],
    );
  }

  Widget _buildFloatingButtons() {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPurchaseButton(),
          const SizedBox(height: 12),
          _buildRestoreButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance() {
    final tokenState = ref.watch(tokenProvider);
    final tokenBalance = tokenState.balance;
    final colors = context.colors;

    // 로딩 중이면 로딩 인디케이터
    if (tokenState.isLoading && tokenBalance == null) {
      return const CustomCard(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 에러가 있거나 balance가 null이면 무제한 이용권 확인
    if (tokenBalance == null) {
      // 무제한 구독이 있으면 무제한 표시
      if (tokenState.hasUnlimitedAccess) {
        return CustomCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 보유 복주머니',
                    style: DSTypography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '무제한',
                    style: DSTypography.headingMedium.copyWith(
                      // 황색(Hwang) - 복/풍요를 상징
                      color: ObangseokColors.hwang,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.all_inclusive,
                size: 40,
                color: ObangseokColors.hwang.withValues(alpha: 0.3),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.1, end: 0);
      }

      // 그 외에는 0으로 표시
      return CustomCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 보유 복주머니',
                  style: DSTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '0',
                      style: DSTypography.headingMedium.copyWith(
                        // 황색(Hwang) - 복/풍요를 상징
                        color: ObangseokColors.hwang,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '개',
                      style: DSTypography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.toll,
              size: 40,
              color: ObangseokColors.hwang.withValues(alpha: 0.3),
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.1, end: 0);
    }

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 보유 복주머니',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    tokenBalance.hasUnlimitedAccess
                      ? '무제한'
                      : '${tokenBalance.remainingTokens}',
                    style: DSTypography.headingMedium.copyWith(
                      // 황색(Hwang) - 복/풍요를 상징
                      color: ObangseokColors.hwang,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!tokenBalance.hasUnlimitedAccess) ...[
                    const SizedBox(width: 4),
                    Text(
                      '개',
                      style: DSTypography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Icon(
            tokenBalance.hasUnlimitedAccess
              ? Icons.all_inclusive
              : Icons.toll,
            size: 40,
            color: ObangseokColors.hwang.withValues(alpha: 0.3),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideX(begin: -0.1, end: 0);
  }

  Widget _buildPackageList({bool useMockData = false}) {
    final colors = context.colors;
    // Mock 데이터 사용 시 InAppProducts.productDetails에서 소모성 상품만 가져오기
    final mockProducts = InAppProducts.consumableIds
        .map((id) => InAppProducts.productDetails[id])
        .whereType<ProductInfo>()
        .toList();

    final itemCount = useMockData ? mockProducts.length : _products.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복주머니 패키지 선택',
          style: DSTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        if (useMockData) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '미리보기 모드 (App Store 검토 대기 중)',
              style: DSTypography.labelSmall.copyWith(
                color: colors.accent,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...List.generate(itemCount, (index) {
          final ProductInfo? productInfo;
          final String title;
          final String description;
          final String price;

          if (useMockData) {
            productInfo = mockProducts[index];
            title = productInfo.title;
            description = productInfo.description;
            price = '₩${productInfo.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
          } else {
            final product = _products[index];
            productInfo = InAppProducts.productDetails[product.id];
            title = productInfo?.title ?? product.title;
            description = productInfo?.description ?? product.description;
            price = product.price;
          }

          final isSelected = _selectedPackageIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMockPackageCard(
              title: title,
              description: description,
              price: price,
              productInfo: productInfo,
              isSelected: isSelected,
              onTap: () {
                ref.read(fortuneHapticServiceProvider).selection();
                setState(() {
                  _selectedPackageIndex = index;
                });
              },
            ).animate()
              .fadeIn(duration: 600.ms, delay: (index * 100).ms)
              .slideX(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildMockPackageCard({
    required String title,
    required String description,
    required String price,
    ProductInfo? productInfo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final isSubscription = productInfo?.isSubscription ?? false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // 황색(Hwang) - 복/풍요를 상징하는 전통 색상
          gradient: isSelected
            ? LinearGradient(
                colors: [
                  ObangseokColors.hwang.withValues(alpha: 0.1),
                  ObangseokColors.hwang.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          border: Border.all(
            color: isSelected ? ObangseokColors.hwang : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: ObangseokColors.hwang.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        ),
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                  ? ObangseokColors.hwang.withValues(alpha: 0.1)
                  : colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Center(
                child: Icon(
                  isSubscription ? Icons.all_inclusive : Icons.toll,
                  size: 28,
                  color: isSelected ? ObangseokColors.hwang : colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DSTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: DSTypography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: DSTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    // 황색(Hwang) - 선택 시 풍요를 상징
                    color: isSelected ? ObangseokColors.hwangDark : colors.textPrimary,
                  ),
                ),
                if (isSubscription) ...[
                  Text(
                    '/월',
                    style: DSTypography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final isDisabled = _selectedPackageIndex == null || _isProcessing;

    return UnifiedButton(
      text: _isProcessing ? '처리 중...' : '구매하기',
      onPressed: isDisabled ? null : _handlePurchase,
      isLoading: _isProcessing,
      width: double.infinity,
    );
  }

  Widget _buildRestoreButton() {
    return UnifiedButton(
      text: '구매 복원',
      onPressed: _isProcessing ? null : _handleRestore,
      style: UnifiedButtonStyle.secondary,
      width: double.infinity,
    );
  }

  Widget _buildDescription() {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구매 안내',
          style: DSTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...[
          '• 복주머니는 운세를 볼 때 사용됩니다',
          '• 구매한 복주머니는 즉시 계정에 추가됩니다',
          '• 무제한 구독은 매월 자동 갱신됩니다',
          '• 구독은 언제든지 취소할 수 있습니다',
          '• 환불은 앱스토어/구글플레이 정책을 따릅니다'
        ].map((text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            text,
            style: DSTypography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackageIndex == null) return;

    setState(() => _isProcessing = true);
    ref.read(fortuneHapticServiceProvider).jackpot();

    try {
      final product = _products[_selectedPackageIndex!];
      // 결제 시작 - 실제 완료는 onPurchaseCompleted 콜백에서 처리
      final started = await _purchaseService.purchaseProduct(product.id);

      if (!started) {
        throw Exception('구매를 시작할 수 없습니다');
      }
      // 결제 UI가 표시됨 - 완료/취소/에러는 콜백에서 처리
    } catch (e) {
      Logger.error('구매 시작 실패', e);
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('실패: ${e.toString()}')),
        );
      }
    }
    // finally에서 isProcessing을 false로 설정하지 않음
    // 콜백에서 결제 완료/취소/에러 시 처리
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    ref.read(fortuneHapticServiceProvider).selection();

    try {
      await _purchaseService.restorePurchases();

      // 복원 후 토큰 잔액 새로고침
      ref.invalidate(tokenBalanceProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구매가 복원되었습니다')),
        );
      }
    } catch (e) {
      Logger.error('복원 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구매 복원에 실패했습니다')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}