import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/payment/in_app_purchase_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/widgets/common/custom_button.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'payment_result_page.dart';

class TokenPurchasePage extends ConsumerStatefulWidget {
  const TokenPurchasePage({super.key});

  @override
  ConsumerState<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends ConsumerState<TokenPurchasePage> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  final AuthService _authService = AuthService();
  
  int? _selectedPackageIndex;
  bool _isProcessing = false;

  // 토큰 패키지 정의
  final List<TokenPackage> _packages = [
    TokenPackage(
      id: 'token_10',
      name: '베이직',
      tokens: 10,
      price: 1000,
      originalPrice: null,
      badge: null,
      color: TossDesignSystem.tossBlue),
    TokenPackage(
      id: 'token_50',
      name: '스탠다드',
      tokens: 50,
      price: 4500,
      originalPrice: 5000,
      badge: '10% 할인',
      color: TossDesignSystem.gray600),
    TokenPackage(
      id: 'token_100',
      name: '프리미엄',
      tokens: 100,
      price: 8000,
      originalPrice: 10000,
      badge: '20% 할인',
      color: Colors.blue),
    TokenPackage(
      id: 'subscription_monthly',
      name: '무제한 이용권',
      tokens: -1, // 무제한
      price: 2500,
      originalPrice: null,
      badge: '추천',
      color: Colors.purple,
      isSubscription: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '영혼 상점'),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentBalance(),
          const SizedBox(height: 24),
          _buildPackageList(),
          const SizedBox(height: 24),
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          _buildPaymentMethods(),
          const SizedBox(height: 16),
          _buildSecurityInfo(),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance() {
    // Token balance from provider
    const currentTokens = 0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                  'Fortune cached: $currentTokens',
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
    );
  }

  Widget _buildPackageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '토큰 패키지 선택',
          style: TossDesignSystem.heading2,
        ),
        const SizedBox(height: 16),
        ...List.generate(_packages.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPackageCard(index),
          );
        }),
      ],
    );
  }

  Widget _buildPackageCard(int index) {
    final package = _packages[index];
    final isSelected = _selectedPackageIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        setState(() {
          _selectedPackageIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? package.color : TossDesignSystem.gray50,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? package.color.withOpacity(0.1) 
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
                    color: isSelected ? package.color : TossDesignSystem.gray600,
                    width: 2,
                  ),
                  color: isSelected ? package.color : Colors.transparent,
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
                          package.name,
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (package.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: package.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              package.badge!,
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
                      package.isSubscription
                          ? '매월 무제한 이용'
                          : '${package.tokens}개 토큰',
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
                  if (package.originalPrice != null)
                    Text(
                      '₩${_formatPrice(package.originalPrice!)}',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.gray600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '₩${_formatPrice(package.price)}',
                    style: TossDesignSystem.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? package.color : TossDesignSystem.gray900,
                    ),
                  ),
                  if (package.isSubscription)
                    Text(
                      '/월',
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
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  Widget _buildPurchaseButton() {
    final isEnabled = _selectedPackageIndex != null && !_isProcessing;
    
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

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '결제 수단',
          style: TossDesignSystem.body1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPaymentMethodIcon(Icons.credit_card, '카드'),
            const SizedBox(width: 12),
            _buildPaymentMethodIcon(Icons.apple, 'Apple'),
            const SizedBox(width: 12),
            _buildPaymentMethodIcon(Icons.g_mobiledata, 'Google'),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TossDesignSystem.gray50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: TossDesignSystem.gray600),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TossDesignSystem.caption,
        ),
      ],
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
              '모든 결제는 안전하게 암호화되어 처리됩니다.',
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
    if (_selectedPackageIndex == null) return;
    
    final package = _packages[_selectedPackageIndex!];
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Payment service initialization
      // await _purchaseService.initialize();
      
      // 사용자 정보 가져오기
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      bool result;
      
      if (package.isSubscription) {
        // 구독 처리
        result = await _purchaseService.purchaseProduct(package.id);
      } else {
        // 일반 결제 처리
        result = await _purchaseService.purchaseProduct(package.id);
      }

      // Handle payment result
      HapticUtils.success();
      _showSuccessDialog(package);
    } catch (e) {
      Logger.error('결제 처리 오류: $e');
      HapticUtils.error();
      _showErrorDialog('결제 처리 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(TokenPackage package) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentResultPage(
          isSuccess: true,
          message: package.isSubscription
              ? '무제한 구독이 시작되었습니다!\n모든 운세를 자유롭게 이용하세요.'
              : '${package.tokens}개의 토큰이 충전되었습니다!',
          tokenAmount: package.isSubscription ? null : package.tokens,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    String errorCode = 'UNKNOWN_ERROR';
    if (message.contains('취소')) {
      errorCode = 'CANCELLED';
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentResultPage(
          isSuccess: false,
          message: message,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// 토큰 패키지 모델
class TokenPackage {
  final String id;
  final String name;
  final int tokens;
  final int price;
  final int? originalPrice;
  final String? badge;
  final Color color;
  final bool isSubscription;

  TokenPackage({
    required this.id,
    required this.name,
    required this.tokens,
    required this.price,
    this.originalPrice,
    this.badge,
    required this.color,
    this.isSubscription = false,
  });
}