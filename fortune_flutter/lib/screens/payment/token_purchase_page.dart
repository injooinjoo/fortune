import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/bottom_navigation_bar.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../shared/glassmorphism/glass_effects.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/payment_provider.dart';
import '../../domain/entities/token.dart';
import '../../shared/components/toast.dart';
import 'payment_confirmation_dialog.dart';
import '../../services/payment_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/haptic_utils.dart';

class TokenPurchasePage extends ConsumerStatefulWidget {
  const TokenPurchasePage({Key? key}) : super(key: key);

  @override
  ConsumerState<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends ConsumerState<TokenPurchasePage> 
    with SingleTickerProviderStateMixin {
  String? _selectedPackageId;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize payment service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentServiceProvider).initialize().catchError((e) {
        Logger.error('Failed to initialize payment service', e);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokenState = ref.watch(tokenProvider);
    final tokenBalance = tokenState.balance?.remainingTokens ?? 0;

    // Mock token packages if not loaded from API
    // Use predefined packages from payment provider
    final packages = ref.watch(tokenPackagesProvider);

    return Scaffold(
      appBar: const AppHeader(
        title: '토큰 구매',
        showShareButton: false,
        showFontSizeSelector: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: isDark
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    Colors.amber.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Current Balance
              _buildCurrentBalance(tokenBalance, isDark),
              
              // History Link
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () => context.push('/payment/history'),
                  icon: Icon(
                    Icons.history_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    '토큰 사용 내역 보기',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Package List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    final isSelected = _selectedPackageId == package.id;
                    
                    return _buildPackageCard(
                      package: package,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          _selectedPackageId = package.id;
                        });
                      },
                    );
                  },
                ),
              ),
              
              // Purchase Button
              _buildPurchaseButton(packages, isDark),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FortuneBottomNavigationBar(currentIndex: -1),
    );
  }

  Widget _buildCurrentBalance(int balance, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        blur: 20,
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.amber.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 보유 토큰',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$balance 토큰',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
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

  Widget _buildPackageCard({
    required TokenPackage package,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final discountPercent = package.originalPrice != null
        ? ((1 - package.price / package.originalPrice!) * 100).round()
        : 0;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        HapticUtils.selection();
        onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Stack(
                children: [
                  // Card
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(20),
                    blur: 20,
                    borderColor: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : Colors.transparent,
                    borderWidth: isSelected ? 2 : 0,
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ]
                          : [
                              theme.colorScheme.surface.withOpacity(0.5),
                              theme.colorScheme.surface.withOpacity(0.3),
                            ],
                    ),
                    child: Row(
                      children: [
                        // Token Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${package.tokens}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Package Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    package.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (package.bonusTokens != null && 
                                      package.bonusTokens! > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '+${package.bonusTokens} 보너스',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (package.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  package.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (package.originalPrice != null) ...[
                              Text(
                                '₩${_formatPrice(package.originalPrice!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              '₩${_formatPrice(package.price)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Badge
                  if (package.badge != null)
                    Positioned(
                      top: -4,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: package.isPopular
                                ? [Colors.red.shade400, Colors.pink.shade400]
                                : [Colors.blue.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (package.isPopular
                                      ? Colors.red
                                      : Colors.blue)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          package.badge!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Discount Badge
                  if (discountPercent > 0)
                    Positioned(
                      top: 40,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$discountPercent%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchaseButton(List<TokenPackage> packages, bool isDark) {
    final theme = Theme.of(context);
    final selectedPackage = packages.firstWhere(
      (p) => p.id == _selectedPackageId,
      orElse: () => packages.first,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Selected Package Summary
            if (_selectedPackageId != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${selectedPackage.name} 선택됨',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '₩${_formatPrice(selectedPackage.price)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Purchase Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedPackageId != null && !ref.watch(paymentStateProvider).isProcessing
                    ? () {
                        HapticUtils.mediumImpact();
                        _handlePurchase(selectedPackage);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: ref.watch(paymentStateProvider).isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _selectedPackageId != null
                          ? '구매하기'
                          : '패키지를 선택해주세요',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(TokenPackage package) async {
    // Import the confirmation dialog
    final confirmed = await PaymentConfirmationDialog.show(
      context: context,
      package: package,
      onConfirm: (paymentMethod) async {
        try {
          // Show loading toast
          if (paymentMethod == 'card') {
            Toast.info(context, 'Stripe 결제를 처리 중입니다...');
          } else if (paymentMethod == 'tosspay') {
            Toast.info(context, 'TossPay 결제를 처리 중입니다...');
          }
          
          // Get payment provider
          final paymentProvider = paymentMethod == 'card' 
            ? PaymentProvider.stripe 
            : PaymentProvider.tossPay;
          
          // Process payment through payment provider
          final paymentResult = await ref.read(paymentStateProvider.notifier).processPayment(
            provider: paymentProvider,
            amount: package.price.toInt(),
            tokenAmount: package.tokens + (package.bonusTokens ?? 0),
            context: context,
          );
          
          if (paymentResult.success) {
            Logger.info('Payment successful: ${paymentResult.paymentId}');
            return true;
          } else {
            Toast.error(context, paymentResult.errorMessage ?? '결제 처리 중 오류가 발생했습니다.');
            return false;
          }
        } catch (e) {
          Logger.error('Payment processing error', e);
          Toast.error(context, '결제 처리 중 오류가 발생했습니다.');
          return false;
        }
      },
    );
    
    // Check if payment was successful
    final paymentState = ref.read(paymentStateProvider);
    if (paymentState.lastResult?.success == true && mounted) {
      Toast.success(context, '${package.name} 구매가 완료되었습니다! 🎉');
      
      // Show success animation
      _showPurchaseSuccessDialog(package);
      
      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  void _showPurchaseSuccessDialog(TokenPackage package) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '구매 완료!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${package.tokens + (package.bonusTokens ?? 0)} 토큰이 추가되었습니다',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

}