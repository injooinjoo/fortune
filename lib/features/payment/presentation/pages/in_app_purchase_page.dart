import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/payment/in_app_purchase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/widgets/common/custom_button.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'payment_result_page.dart';

class InAppPurchasePage extends ConsumerStatefulWidget {
  const InAppPurchasePage({super.key});

  @override
  ConsumerState<InAppPurchasePage> createState() => _InAppPurchasePageState();
}

class _InAppPurchasePageState extends ConsumerState<InAppPurchasePage> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  
  String? _selectedProductId;
  bool _isProcessing = false;
  bool _isLoading = true;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initializePurchase();
  }

  Future<void> _initializePurchase() async {
    try {
      await _purchaseService.initialize();
      await _loadProducts();
    } catch (e) {
      Logger.error('인앱 결제 초기화 실패: $e');
      _showError('결제 시스템을 초기화할 수 없습니다.');
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      await _purchaseService.loadProducts();
      final products = _purchaseService.getProducts();
      
      // 상품을 가격 순으로 정렬
      products.sort((a, b) {
        final priceA = _extractPrice(a.price);
        final priceB = _extractPrice(b.price);
        return priceA.compareTo(priceB);
      });
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('상품 로드 실패: $e');
      setState(() => _isLoading = false);
      _showError('상품 정보를 불러올 수 없습니다.');
    }
  }

  // 가격에서 숫자만 추출
  double _extractPrice(String price) {
    final numbers = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numbers) ?? 0;
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
                  ? _buildLoadingState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('상품 정보를 불러오는 중...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentBalance(),
          const SizedBox(height: 24),
          _buildProductList(),
          const SizedBox(height: 24),
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          _buildRestoreButton(),
          const SizedBox(height: 16),
          _buildSecurityInfo(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: TossDesignSystem.gray600,
          ),
          const SizedBox(height: 16),
          Text(
            '상품을 불러올 수 없습니다',
            style: TossDesignSystem.body1,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadProducts,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance() {
    // final tokenBalance = ref.watch(tokenBalanceProvider);
    final currentTokens = 0; // tokenBalance?.remainingTokens ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TossDesignSystem.tossBlue, TossDesignSystem.gray600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
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
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentTokens}개',
                  style: TossDesignSystem.heading1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '토큰 패키지 선택',
          style: TossDesignSystem.heading2,
        ),
        const SizedBox(height: 16),
        ...List.generate(_products.length, (index) {
          final product = _products[index];
          if (_isSubscription(product.id)) {
            return _buildSubscriptionCard(product, index);
          } else {
            return _buildTokenPackageCard(product, index);
          }
        }),
      ],
    );
  }

  Widget _buildTokenPackageCard(ProductDetails product, int index) {
    final isSelected = _selectedProductId == product.id;
    final tokenAmount = ProductIds.tokenAmounts[product.id] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticUtils.lightImpact();
          setState(() {
            _selectedProductId = product.id;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray50,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected 
                ? TossDesignSystem.tossBlue.withOpacity(0.1) 
                : TossDesignSystem.gray50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 선택 인디케이터
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray600,
                      width: 2,
                    ),
                    color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // 패키지 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product.title,
                            style: TossDesignSystem.body1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_getBadge(product.id) != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.gray600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getBadge(product.id)!,
                                style: TossDesignSystem.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tokenAmount}개',
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 가격
                Text(
                  product.price,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: (index * 100).ms).fadeIn().slideX(),
    );
  }

  Widget _buildSubscriptionCard(ProductDetails product, int index) {
    final isSelected = _selectedProductId == product.id;
    final isMonthly = product.id == ProductIds.monthlySubscription;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticUtils.lightImpact();
          setState(() {
            _selectedProductId = product.id;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray50,
              width: isSelected ? 2 : 1,
            ),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      TossDesignSystem.tossBlue.withOpacity(0.1),
                      TossDesignSystem.gray600.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isSelected ? TossDesignSystem.gray50 : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 선택 인디케이터
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray600,
                      width: 2,
                    ),
                    color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // 구독 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 20,
                            color: TossDesignSystem.tossBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '무제한 구독',
                            style: TossDesignSystem.body1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.tossBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '인기',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '모든 운세 무제한 이용',
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 가격
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray900,
                      ),
                    ),
                    Text(
                      isMonthly ? '/월' : '/년',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: (index * 100).ms).fadeIn().slideX(),
    );
  }

  Widget _buildPurchaseButton() {
    final isEnabled = _selectedProductId != null && !_isProcessing;
    
    return CustomButton(
      onPressed: isEnabled ? _processPurchase : null,
      text: _isProcessing ? '처리 중...' : '구매하기',
      isLoading: _isProcessing,
      gradient: isEnabled
          ? LinearGradient(
              colors: [TossDesignSystem.tossBlue, TossDesignSystem.gray600],
            )
          : null,
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _isProcessing ? null : _restorePurchases,
      child: Text(
        '이전 구매 복원',
        style: TossDesignSystem.body2.copyWith(
          color: TossDesignSystem.tossBlue,
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossDesignSystem.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: TossDesignSystem.infoBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '모든 결제는 Apple/Google을 통해 안전하게 처리됩니다.',
              style: TossDesignSystem.caption.copyWith(
                color: TossDesignSystem.infoBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase() async {
    if (_selectedProductId == null) return;
    
    setState(() => _isProcessing = true);

    try {
      final success = await _purchaseService.purchaseProduct(_selectedProductId!);
      
      if (success) {
        HapticUtils.success();
        _showSuccessResult();
      }
    } catch (e) {
      Logger.error('구매 실패', e);
      HapticUtils.error();
      _showError(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isProcessing = true);

    try {
      await _purchaseService.restorePurchases();
      HapticUtils.success();
      _showSuccess('구매가 복원되었습니다.');
    } catch (e) {
      Logger.error('구매 복원 실패', e);
      HapticUtils.error();
      _showError('구매 복원에 실패했습니다.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String? _getBadge(String productId) {
    switch (productId) {
      case ProductIds.tokens50:
        return '10% 할인';
      case ProductIds.tokens100:
        return '20% 할인';
      case ProductIds.tokens200:
        return '30% 할인';
      default:
        return null;
    }
  }

  bool _isSubscription(String productId) {
    return productId == ProductIds.monthlySubscription;
  }

  void _showSuccessResult() {
    final product = _products.firstWhere((p) => p.id == _selectedProductId);
    final tokenAmount = ProductIds.tokenAmounts[product.id];
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentResultPage(
          isSuccess: true,
          message: _isSubscription(product.id)
              ? '무제한 구독이 시작되었습니다!\n모든 운세를 자유롭게 이용하세요.'
              : '${tokenAmount ?? 0}개의 토큰이 충전되었습니다!',
          tokenAmount: tokenAmount,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TossDesignSystem.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TossDesignSystem.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}