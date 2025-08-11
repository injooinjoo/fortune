import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/payment/stripe_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/token_service.dart';
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
  final StripeService _stripeService = StripeService();
  final AuthService _authService = AuthService();
  final TokenService _tokenService = TokenService();
  
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
      color: AppColors.primary),
    TokenPackage(
      id: 'token_50',
      name: '스탠다드',
      tokens: 50,
      price: 4500,
      originalPrice: 5000,
      badge: '10% 할인',
      color: AppColors.secondary),
    TokenPackage(
      id: 'token_100',
      name: '프리미엄',
      tokens: 100,
      price: 8000,
      originalPrice: 10000,
      badge: '20% 할인',
      color: AppColors.accent),
    TokenPackage(
      id: 'subscription_monthly',
      name: '무제한 이용권',
      tokens: -1, // 무제한
      price: 2500,
      originalPrice: null,
      badge: '추천',
      color: AppColors.gradient1,
      isSubscription: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
    final tokenBalance = ref.watch(tokenBalanceProvider);
    final currentTokens = tokenBalance?.remainingTokens ?? 0;
    
    return CustomCard(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
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
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fortune cached $3',
                  style: AppTextStyles.headlineLarge.copyWith(
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

  Widget _buildPackageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '토큰 패키지 선택',
          style: AppTextStyles.headlineMedium,
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
            color: isSelected ? package.color : AppColors.surface,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? package.color.withOpacity(0.1) 
              : AppColors.surface,
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
                    color: isSelected ? package.color : AppColors.textSecondary,
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
                          style: AppTextStyles.bodyLarge.copyWith(
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
                              style: AppTextStyles.caption.copyWith(
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
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
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
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '₩${_formatPrice(package.price)}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? package.color : AppColors.textPrimary,
                    ),
                  ),
                  if (package.isSubscription)
                    Text(
                      '/월',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
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
              colors: [AppColors.primary, AppColors.secondary],
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
          style: AppTextStyles.bodyLarge.copyWith(
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '모든 결제는 안전하게 암호화되어 처리됩니다.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
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
      // Stripe 초기화
      await _stripeService.initialize();
      
      // 사용자 정보 가져오기
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      PaymentResult result;
      
      if (package.isSubscription) {
        // 구독 처리
        result = await _stripeService.processSubscription(
          priceId: package.id,
          customerEmail: user.email,
          metadata: {
            'userId': user.id,
            'packageId': package.id,
          },
        );
      } else {
        // 일반 결제 처리
        result = await _stripeService.processPayment(
          amount: package.price,
          currency: 'krw',
          customerEmail: user.email,
          metadata: {
            'userId': user.id,
            'packageId': package.id,
            'tokens': package.tokens,
          },
        );
      }

      if (result.success) {
        // 성공 시 토큰 추가 (서버에서 웹훅으로 처리하는 것이 더 안전함,
        if (!package.isSubscription) {
          await _tokenService.addTokens(package.tokens);
        }
        
        HapticUtils.success();
        _showSuccessDialog(package);
      } else {
        HapticUtils.error();
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Logger.error('결제 처리 오류', error: e);
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
          errorCode: errorCode,
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