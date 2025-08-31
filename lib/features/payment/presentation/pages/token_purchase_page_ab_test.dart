import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/ab_test_events.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../presentation/widgets/common/custom_button.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../services/payment/in_app_purchase_service.dart';
import '../../../../services/remote_config_service.dart';
import '../../../../services/ab_test_manager.dart';
import 'payment_result_page.dart';

/// A/B 테스트가 적용된 토큰 구매 페이지
class TokenPurchasePageABTest extends ConsumerStatefulWidget {
  const TokenPurchasePageABTest({super.key});

  @override
  ConsumerState<TokenPurchasePageABTest> createState() => _TokenPurchasePageABTestState();
}

class _TokenPurchasePageABTestState extends ConsumerState<TokenPurchasePageABTest> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  
  int? _selectedPackageIndex;
  bool _isProcessing = false;
  bool _isLoading = true;
  List<ProductDetails> _products = [];
  
  late RemoteConfigService _remoteConfig;
  late ABTestManager _abTestManager;
  late String _paymentLayout;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Remote Config와 A/B Test Manager 초기화
    _remoteConfig = ref.read(remoteConfigProvider);
    _abTestManager = ref.read(abTestManagerProvider);
    
    // 결제 레이아웃 가져오기
    _paymentLayout = _remoteConfig.getPaymentUILayout();
    
    // 화면 조회 이벤트 로깅
    await _abTestManager.logScreenView(
      screenName: 'token_purchase_page',
      screenClass: 'TokenPurchasePageABTest',
      additionalParams: {
        'payment_layout': _paymentLayout
      });
    
    // 인앱 결제 초기화
    await _initializeInAppPurchase();
  }

  Future<void> _initializeInAppPurchase() async {
    setState(() => _isLoading = true);
    
    try {
      await _purchaseService.initialize();
      await _loadProducts();
    } catch (e) {
      // 에러 로깅
      await _abTestManager.logError(
        errorType: 'payment_initialization',
        errorMessage: e.toString());
      
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
                : _buildContent())
          ])));
  }

  Widget _buildContent() {
    if (!_purchaseService.isAvailable) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '인앱결제를 사용할 수 없습니다.\n앱스토어 설정을 확인해주세요.',
            textAlign: TextAlign.center,
            style: TossDesignSystem.body1)));
    }

    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '상품을 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TossDesignSystem.body1)));
    }

    // 레이아웃에 따라 다른 UI 렌더링
    switch (_paymentLayout) {
      case 'split':
        return _buildSplitLayout();
      case 'unified':
        return _buildUnifiedLayout();
      default:
        return _buildSplitLayout();
    }
  }

  /// 분리된 레이아웃 (구독과 토큰 구분)
  Widget _buildSplitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentBalance(),
          const SizedBox(height: 24),
          _buildSubscriptionSection(),
          const SizedBox(height: 32),
          _buildTokenSection(),
          const SizedBox(height: 24),
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          _buildRestoreButton(),
          const SizedBox(height: 32),
          _buildDescription()
        ]));
  }

  /// 통합 레이아웃 (모든 옵션 함께)
  Widget _buildUnifiedLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentBalance(),
          const SizedBox(height: 24),
          Text(
            '구매 옵션',
            style: TossDesignSystem.heading3.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAllOptionsUnified(),
          const SizedBox(height: 24),
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          _buildRestoreButton(),
          const SizedBox(height: 32),
          _buildDescription()
        ]));
  }

  /// 현재 토큰 잔액 표시
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
                  color: TossDesignSystem.gray600)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    tokenBalance.hasUnlimitedAccess 
                      ? '무제한'
                      : '${tokenBalance.remainingTokens}',
                    style: TossDesignSystem.heading2.copyWith(
                      color: TossDesignSystem.tossBlue,
                      fontWeight: FontWeight.bold)),
                  if (!tokenBalance.hasUnlimitedAccess) ...[
                    const SizedBox(width: 4),
                    Text(
                      '개',
                      style: TossDesignSystem.body1.copyWith(
                        color: TossDesignSystem.gray600))
                  ]
                ])
            ]),
          Icon(
            tokenBalance.hasUnlimitedAccess 
              ? Icons.all_inclusive 
              : Icons.toll,
            size: 40,
            color: TossDesignSystem.tossBlue.withOpacity(0.3))
        ]))
    .animate()
      .fadeIn(duration: 600.ms)
      .slideX(begin: -0.1, end: 0);
  }

  /// 구독 섹션
  Widget _buildSubscriptionSection() {
    final subscriptionPrice = _remoteConfig.getSubscriptionPrice();
    final subscriptionTitle = _remoteConfig.getSubscriptionTitle();
    final subscriptionDescription = _remoteConfig.getSubscriptionDescription();
    final subscriptionBadge = _remoteConfig.getSubscriptionBadge();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star,
              size: 20,
              color: TossDesignSystem.tossBlue),
            const SizedBox(width: 8),
            Text(
              '구독',
              style: TossDesignSystem.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.tossBlue))
          ]),
        const SizedBox(height: 12),
        _buildSubscriptionCard(
          price: subscriptionPrice,
          title: subscriptionTitle,
          description: subscriptionDescription,
          badge: subscriptionBadge,
          isSelected: false,
          onTap: () {
            HapticUtils.lightImpact();
            _handleSubscriptionSelection();
          })
      ]);
  }

  /// 구독 카드 위젯
  Widget _buildSubscriptionCard({
    required int price,
    required String title,
    required String description,
    required String badge,
    required bool isSelected,
    required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
              ? [
                  TossDesignSystem.tossBlue.withOpacity(0.2),
                  TossDesignSystem.gray600.withOpacity(0.1)
                ]
              : [
                  TossDesignSystem.tossBlue.withOpacity(0.05),
                  TossDesignSystem.gray600.withOpacity(0.02)
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
          border: Border.all(
            color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.tossBlue.withOpacity(0.3),
            width: isSelected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: TossDesignSystem.tossBlue.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
              ]
            : null),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16),
                      const SizedBox(width: 4),
                      Text(
                        badge,
                        style: TossDesignSystem.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold))
                    ])),
                const Spacer(),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Icon(
                      Icons.all_inclusive,
                      size: 24,
                      color: TossDesignSystem.tossBlue)))
              ]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TossDesignSystem.heading2.copyWith(
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              description,
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.gray600)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₩${NumberFormat('#,###').format(price)}',
                  style: TossDesignSystem.heading2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.tossBlue)),
                const SizedBox(width: 4),
                Text(
                  '/월',
                  style: TossDesignSystem.body1.copyWith(
                    color: TossDesignSystem.gray600))
              ])])));
  }

  /// 토큰 섹션
  Widget _buildTokenSection() {
    final tokenProducts = _products.where((p) => 
      !p.id.contains('subscription')).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.toll,
              size: 20,
              color: TossDesignSystem.gray600),
            const SizedBox(width: 8),
            Text(
              '토큰 구매',
              style: TossDesignSystem.heading3.copyWith(
                fontWeight: FontWeight.bold))
          ]),
        const SizedBox(height: 12),
        ...tokenProducts.map((product) {
          final productIndex = _products.indexOf(product);
          final isSelected = _selectedPackageIndex == productIndex;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTokenCard(
              product: product,
              isSelected: isSelected,
              onTap: () {
                HapticUtils.lightImpact();
                setState(() {
                  _selectedPackageIndex = productIndex;
                });
                
                // 토큰 패키지 선택 이벤트
                _abTestManager.logEvent(
                  eventName: ABTestEvents.tokenPackageSelected,
                  parameters: {
                    ABTestEventParams.tokenPackageId: product.id,
                    ABTestEventParams.tokenPrice: product.price
                  });
              }));
        })
      ]);
  }

  /// 토큰 카드 위젯
  Widget _buildTokenCard({
    required ProductDetails product,
    required bool isSelected,
    required VoidCallback onTap}) {
    // Remote Config에서 토큰 패키지 정보 가져오기
    final tokenPackages = _remoteConfig.getTokenPackages();
    final packageInfo = tokenPackages.firstWhere(
      (p) => p['id'] == product.id,
      orElse: () => {});
    
    final bonusRate = _remoteConfig.getTokenBonusRate();
    final isPopular = product.id == _remoteConfig.getPopularTokenPackage();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
            ? LinearGradient(
                colors: [
                  TossDesignSystem.tossBlue.withOpacity(0.1),
                  TossDesignSystem.tossBlue.withOpacity(0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
            : null,
          border: Border.all(
            color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray300,
            width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected 
                  ? TossDesignSystem.tossBlue.withOpacity(0.1)
                  : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Icon(
                  Icons.toll,
                  size: 28,
                  color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray600))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.title,
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold)),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.errorRed,
                            borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            '인기',
                            style: TossDesignSystem.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)))
                      ]
                    ]),
                  if (packageInfo['bonus'] != null && packageInfo['bonus'] > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${packageInfo['bonus']}% 보너스 토큰 포함',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.gray600))
                  ]
                ])),
            Text(
              product.price,
              style: TossDesignSystem.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray900))
          ])));
  }

  /// 통합 레이아웃용 - 모든 옵션 함께
  Widget _buildAllOptionsUnified() {
    final allProducts = _products;
    
    return Column(
      children: allProducts.map((product) {
        final productIndex = _products.indexOf(product);
        final isSelected = _selectedPackageIndex == productIndex;
        final isSubscription = product.id.contains('subscription');
        
        if (isSubscription) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSubscriptionCard(
              price: _remoteConfig.getSubscriptionPrice(),
              title: _remoteConfig.getSubscriptionTitle(),
              description: _remoteConfig.getSubscriptionDescription(),
              badge: _remoteConfig.getSubscriptionBadge(),
              isSelected: isSelected,
              onTap: () => _handleProductSelection(productIndex, product)));
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTokenCard(
              product: product,
              isSelected: isSelected,
              onTap: () => _handleProductSelection(productIndex, product)));
        }
      }).toList());
  }

  /// 구매 버튼
  Widget _buildPurchaseButton() {
    final isDisabled = _selectedPackageIndex == null || _isProcessing;
    
    return CustomButton(
      text: _isProcessing ? '처리 중...' : '구매하기',
      onPressed: isDisabled ? null : _handlePurchase,
      isLoading: _isProcessing,
      width: double.infinity);
  }

  /// 복원 버튼
  Widget _buildRestoreButton() {
    return CustomButton(
      text: '구매 복원',
      onPressed: _isProcessing ? null : _handleRestore,
      variant: ButtonVariant.secondary,
      width: double.infinity);
  }

  /// 설명 텍스트
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구매 안내',
          style: TossDesignSystem.body2.copyWith(
            fontWeight: FontWeight.bold)),
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
              color: TossDesignSystem.gray600))))
      ]);
  }

  /// 상품 선택 처리
  void _handleProductSelection(int index, ProductDetails product) {
    HapticUtils.lightImpact();
    setState(() {
      _selectedPackageIndex = index;
    });
    
    // 선택 이벤트 로깅
    if (product.id.contains('subscription')) {
      _abTestManager.logEvent(
        eventName: ABTestEvents.subscriptionPlanSelected,
        parameters: {
          ABTestEventParams.subscriptionPrice: _remoteConfig.getSubscriptionPrice(),
          ABTestEventParams.subscriptionPlan: 'monthly'
        });
    } else {
      _abTestManager.logEvent(
        eventName: ABTestEvents.tokenPackageSelected,
        parameters: {
          ABTestEventParams.tokenPackageId: product.id,
          ABTestEventParams.tokenPrice: product.price
        });
    }
  }

  /// 구독 선택 처리
  void _handleSubscriptionSelection() {
    // 구독 상품 찾기
    final subscriptionIndex = _products.indexWhere(
      (p) => p.id.contains('subscription'));
    
    if (subscriptionIndex != -1) {
      _handleProductSelection(subscriptionIndex, _products[subscriptionIndex]);
    }
  }

  /// 구매 처리
  Future<void> _handlePurchase() async {
    if (_selectedPackageIndex == null) return;
    
    setState(() => _isProcessing = true);
    HapticUtils.mediumImpact();
    
    final product = _products[_selectedPackageIndex!];
    final isSubscription = product.id.contains('subscription');
    
    // 구매 시작 이벤트
    await _abTestManager.logEvent(
      eventName: isSubscription 
        ? ABTestEvents.subscriptionPurchaseStarted
        : ABTestEvents.tokenPurchaseStarted,
      parameters: {
        'product_id': product.id,
        'price': product.price
      });
    
    try {
      final success = await _purchaseService.purchaseProduct(product.id);
      
      if (!success) {
        throw Exception('구매를 완료할 수 없습니다');
      }
      
      // 구매 성공 이벤트
      await _abTestManager.logConversion(
        conversionType: isSubscription ? 'subscription' : 'token_purchase',
        value: product.price,
        additionalParams: {
          'product_id': product.id
        });
      
      // 토큰 잔액 새로고침
      ref.refresh(tokenBalanceProvider);
      
      // 결과 페이지로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentResultPage(
              isSuccess: true,
              productName: product.title,
              amount: product.price)));
      }
    } catch (e) {
      // 구매 실패 이벤트
      await _abTestManager.logEvent(
        eventName: isSubscription 
          ? ABTestEvents.subscriptionPurchaseFailed
          : ABTestEvents.tokenPurchaseFailed,
        parameters: {
          'product_id': product.id,
          'error': e.toString()
        });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('실패: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 구매 복원 처리
  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    HapticUtils.lightImpact();
    
    try {
      await _purchaseService.restorePurchases();
      
      // 복원 이벤트
      await _abTestManager.logEvent(
        eventName: ABTestEvents.subscriptionRestored);
      
      // 토큰 잔액 새로고침
      ref.refresh(tokenBalanceProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구매가 복원되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구매 복원에 실패했습니다')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}