import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/in_app_purchase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
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
    _initializeInAppPurchase();
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
      _products = _purchaseService.products;
    });
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '토큰 구매'),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '인앱결제를 사용할 수 없습니다.\\n앱스토어 설정을 확인해주세요.',
            textAlign: TextAlign.center,
            style: TossDesignSystem.body1,
          ),
        ),
      );
    }

    // IAP 상품이 없으면 Mock 데이터로 UI 표시 (스크린샷용)
    final bool useMockData = _products.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentBalance(),
          const SizedBox(height: 24),
          _buildPackageList(useMockData: useMockData),
          const SizedBox(height: 24),
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          _buildRestoreButton(),
          const SizedBox(height: 32),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance() {
    final tokenBalance = ref.watch(tokenBalanceProvider);
    
    if (tokenBalance == null) {
      return const CustomCard(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
                '현재 보유 토큰',
                style: TossDesignSystem.caption.copyWith(
                  color: TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    tokenBalance.hasUnlimitedAccess 
                      ? '무제한' 
                      : '${tokenBalance.remainingTokens}',
                    style: TossDesignSystem.heading2.copyWith(
                      color: TossDesignSystem.tossBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!tokenBalance.hasUnlimitedAccess) ...[ 
                    const SizedBox(width: 4),
                    Text(
                      '개',
                      style: TossDesignSystem.body1.copyWith(
                        color: TossDesignSystem.gray600,
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
            color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideX(begin: -0.1, end: 0);
  }

  Widget _buildPackageList({bool useMockData = false}) {
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
          '토큰 패키지 선택',
          style: TossDesignSystem.heading3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (useMockData) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '미리보기 모드 (App Store 검토 대기 중)',
              style: TossDesignSystem.caption.copyWith(
                color: TossDesignSystem.tossBlue,
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
                HapticUtils.lightImpact();
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
    final isSubscription = productInfo?.isSubscription ?? false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
            ? LinearGradient(
                colors: [
                  TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          border: Border.all(
            color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isSubscription ? Icons.all_inclusive : Icons.toll,
                  size: 28,
                  color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TossDesignSystem.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.gray600,
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
                  style: TossDesignSystem.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray900,
                  ),
                ),
                if (isSubscription) ...[
                  Text(
                    '/월',
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.gray600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구매 안내',
          style: TossDesignSystem.body2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...const [
          '• 토큰은 운세를 볼 때 사용됩니다',
          '• 구매한 토큰은 즉시 계정에 추가됩니다',
          '• 무제한 구독은 매월 자동 갱신됩니다',
          '• 구독은 언제든지 취소할 수 있습니다',
          '• 환불은 앱스토어/구글플레이 정책을 따릅니다'
        ].map((text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            text,
            style: TossDesignSystem.caption.copyWith(
              color: TossDesignSystem.gray600,
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackageIndex == null) return;
    
    setState(() => _isProcessing = true);
    HapticUtils.mediumImpact();
    
    try {
      final product = _products[_selectedPackageIndex!];
      final success = await _purchaseService.purchaseProduct(product.id);
      
      if (!success) {
        throw Exception('구매를 완료할 수 없습니다');
      }

      // 구매 완료 후 토큰 잔액 새로고침
      ref.invalidate(tokenBalanceProvider);
      
      // 결과 페이지로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentResultPage(
              isSuccess: true,
              productName: product.title,
              amount: product.price,
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error('구매 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('실패: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    HapticUtils.lightImpact();
    
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