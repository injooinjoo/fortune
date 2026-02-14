import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../services/in_app_purchase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/constants/in_app_products.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';

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
      onPurchaseCompleted: (productId, productName, tokenAmount) async {
        // 실제 결제 완료 시 토큰 잔액 새로고침 후 결과 페이지로 이동
        Logger.info('========== 💰 결제 완료 콜백 ==========');
        Logger.info('productId: $productId');
        Logger.info('productName: $productName');
        Logger.info('tokenAmount: $tokenAmount');

        // 토큰 잔액 새로고침 (서버에서 다시 가져오기)
        try {
          Logger.info('🔄 토큰 잔액 새로고침 시작...');
          await ref.read(tokenProvider.notifier).refreshBalance();
          // 구독 정보 포함 전체 데이터 새로고침
          await ref.read(tokenProvider.notifier).loadTokenData();
          Logger.info('✅ 토큰 잔액 새로고침 완료');
        } catch (e) {
          Logger.error('❌ 토큰 잔액 새로고침 실패: $e');
        }

        Logger.info('==========================================');

        if (mounted) {
          setState(() => _isProcessing = false);
          context.go('/chat');
        }
      },
      onSubscriptionActivated: (productId, isSubscription) {
        // 구독 활성화 시 상태 업데이트
        Logger.info('========== 🎫 구독 활성화 콜백 ==========');
        Logger.info('productId: $productId');
        Logger.info('isSubscription: $isSubscription');

        if (isSubscription) {
          // 구독 상태 즉시 업데이트
          ref.read(subscriptionProvider.notifier).setActive(true);
          // 토큰 데이터 전체 새로고침 (구독 정보 포함)
          ref.read(tokenProvider.notifier).loadTokenData();
          Logger.info('✅ 구독 상태 활성화 완료');
        }

        Logger.info('==========================================');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('결제 시스템을 초기화할 수 없습니다')));
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
      // 월간 구독 제외, 토큰(소모성) 상품만 필터링
      final filteredProducts = _purchaseService.products.where((product) {
        // 월간 구독 제외
        if (product.id == InAppProducts.proSubscription) return false;
        // 소모성 상품만 포함
        return InAppProducts.consumableIds.contains(product.id);
      }).toList();

      // 토큰 수 기준 오름차순 정렬 (작은 것부터)
      filteredProducts.sort((a, b) {
        final aInfo = InAppProducts.productDetails[a.id];
        final bInfo = InAppProducts.productDetails[b.id];
        return (aInfo?.points ?? 0).compareTo(bInfo?.points ?? 0);
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '인앱결제를 사용할 수 없습니다.\\n앱스토어 설정을 확인해주세요.',
            textAlign: TextAlign.center,
            style: context.bodyLarge.copyWith(
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
      decoration: BoxDecoration(
        // 배경과 구분되는 그라디언트 적용
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.background.withValues(alpha: 0),
            colors.background.withValues(alpha: 0.9),
            colors.background,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: _buildPurchaseButton(),
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
      if (tokenState.hasUnlimitedTokens) {
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
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '무제한',
                    style: context.heading2.copyWith(
                      // 황색(Hwang) - 복/풍요를 상징
                      color: DSColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.all_inclusive,
                size: 40,
                color: DSColors.warning.withValues(alpha: 0.3),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
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
                  '현재 보유 토큰',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '0',
                      style: context.heading2.copyWith(
                        // 황색(Hwang) - 복/풍요를 상징
                        color: DSColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '개',
                      style: context.bodyLarge.copyWith(
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
              color: DSColors.warning.withValues(alpha: 0.3),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
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
                style: context.labelSmall.copyWith(
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
                    style: context.heading2.copyWith(
                      // 황색(Hwang) - 복/풍요를 상징
                      color: DSColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!tokenBalance.hasUnlimitedAccess) ...[
                    const SizedBox(width: 4),
                    Text(
                      '개',
                      style: context.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Icon(
            tokenBalance.hasUnlimitedAccess ? Icons.all_inclusive : Icons.toll,
            size: 40,
            color: DSColors.warning.withValues(alpha: 0.3),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
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
          '토큰 패키지 선택',
          style: context.heading3.copyWith(
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
              style: context.labelSmall.copyWith(
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
            price =
                '₩${productInfo.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
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
            )
                .animate()
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
                    DSColors.warning.withValues(alpha: 0.1),
                    DSColors.warning.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isSelected ? DSColors.warning : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DSColors.warning.withValues(alpha: 0.2),
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
                    ? DSColors.warning.withValues(alpha: 0.1)
                    : colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Center(
                child: Icon(
                  isSubscription ? Icons.all_inclusive : Icons.toll,
                  size: 28,
                  color: isSelected ? DSColors.warning : colors.textSecondary,
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
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.labelSmall.copyWith(
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
                  style: context.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    // 황색(Hwang) - 선택 시 풍요를 상징
                    color: isSelected ? DSColors.warning : colors.textPrimary,
                  ),
                ),
                if (isSubscription) ...[
                  Text(
                    '/월',
                    style: context.labelSmall.copyWith(
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
    final colors = context.colors;
    final isDisabled = _selectedPackageIndex == null || _isProcessing;

    // 선택 전에도 눈에 보이도록 명시적인 컨테이너로 감싸기
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        // 비활성화 상태에서도 눈에 보이는 배경
        color: isDisabled ? colors.backgroundTertiary : colors.ctaBackground,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: isDisabled ? Border.all(color: colors.border, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : _handlePurchase,
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: Center(
            child: _isProcessing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                    ),
                  )
                : Text(
                    _selectedPackageIndex == null ? '패키지를 선택해주세요' : '구매하기',
                    style: context.bodyLarge.copyWith(
                      color: isDisabled
                          ? colors.textSecondary
                          : colors.ctaForeground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구매 안내',
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...[
          '• 토큰는 운세를 볼 때 사용됩니다',
          '• 구매한 토큰는 즉시 계정에 추가됩니다',
          '• 무제한 구독은 매월 자동 갱신됩니다',
          '• 구독은 언제든지 취소할 수 있습니다',
          '• 환불은 앱스토어/구글플레이 정책을 따릅니다'
        ].map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                text,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            )),
        const SizedBox(height: 16),
        // 이용약관 및 개인정보처리방침 링크 (App Store 3.1.2 준수)
        Text.rich(
          TextSpan(
            text: '구매 시 ',
            style: context.labelSmall.copyWith(color: colors.textSecondary),
            children: [
              TextSpan(
                text: '이용약관',
                style: context.labelSmall.copyWith(
                  color: colors.accent,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.push('/terms-of-service'),
              ),
              const TextSpan(text: ' 및 '),
              TextSpan(
                text: '개인정보처리방침',
                style: context.labelSmall.copyWith(
                  color: colors.accent,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.push('/privacy-policy'),
              ),
              const TextSpan(text: '에 동의하는 것으로 간주합니다.'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackageIndex == null) return;

    // Mock 모드에서는 구매 불가 안내
    if (_products.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 구매할 수 없습니다. App Store 검토 대기 중입니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

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
}
