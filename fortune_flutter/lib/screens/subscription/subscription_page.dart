import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/bottom_navigation_bar.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../shared/glassmorphism/glass_effects.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../shared/components/toast.dart';
import '../../domain/entities/token.dart';

// Subscription State
class SubscriptionState {
  final String status; // 'active', 'canceled', 'past_due', 'free'
  final String plan; // 'free', 'basic', 'premium', 'enterprise'
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final int monthlyTokens;
  final int usedTokens;
  final DateTime? nextBillingDate;
  final double? amount;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.status = 'free',
    this.plan = 'free',
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.monthlyTokens = 10, // Free tier gets 10 tokens
    this.usedTokens = 0,
    this.nextBillingDate,
    this.amount,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    String? status,
    String? plan,
    DateTime? currentPeriodEnd,
    bool? cancelAtPeriodEnd,
    int? monthlyTokens,
    int? usedTokens,
    DateTime? nextBillingDate,
    double? amount,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      monthlyTokens: monthlyTokens ?? this.monthlyTokens,
      usedTokens: usedTokens ?? this.usedTokens,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get usagePercentage => monthlyTokens > 0 ? (usedTokens / monthlyTokens) * 100 : 0;
}

// Subscription Notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final Ref ref;

  SubscriptionNotifier(this.ref) : super(const SubscriptionState()) {
    loadSubscription();
  }

  Future<void> loadSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get user subscription from token provider
      final tokenState = ref.read(tokenProvider);
      final subscription = tokenState.subscription;

      if (subscription != null) {
        state = state.copyWith(
          status: subscription.status,
          plan: subscription.plan,
          currentPeriodEnd: subscription.endDate,
          monthlyTokens: _getMonthlyTokensForPlan(subscription.plan),
          usedTokens: tokenState.balance?.usedTokens ?? 0,
          nextBillingDate: subscription.endDate,
          amount: subscription.price,
          isLoading: false,
        );
      } else {
        // Free plan
        state = state.copyWith(
          status: 'free',
          plan: 'free',
          monthlyTokens: 10,
          usedTokens: tokenState.balance?.usedTokens ?? 0,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  int _getMonthlyTokensForPlan(String plan) {
    switch (plan) {
      case 'basic':
        return 100;
      case 'premium':
        return 300;
      case 'enterprise':
        return 999999; // Unlimited
      default:
        return 10; // Free tier
    }
  }

  Future<void> upgradePlan(String newPlan) async {
    // TODO: Implement payment flow
    state = state.copyWith(error: '결제 기능은 준비 중입니다');
  }

  Future<void> cancelSubscription() async {
    // TODO: Implement cancellation
    state = state.copyWith(error: '구독 취소 기능은 준비 중입니다');
  }
}

// Provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref);
});

// Subscription Page
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
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
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: const AppHeader(
        title: '구독 관리',
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
        child: subscriptionState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentSubscription(subscriptionState, theme, isDark),
                      const SizedBox(height: 24),
                      _buildPlanComparison(subscriptionState, theme, isDark),
                      const SizedBox(height: 24),
                      _buildSpecialOffer(theme, isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const FortuneBottomNavigationBar(currentIndex: -1),
    );
  }

  Widget _buildCurrentSubscription(SubscriptionState state, ThemeData theme, bool isDark) {
    final planColors = {
      'free': Colors.grey,
      'basic': Colors.blue,
      'premium': Colors.purple,
      'enterprise': Colors.amber,
    };

    final planNames = {
      'free': '무료',
      'basic': '베이직',
      'premium': '프리미엄',
      'enterprise': '엔터프라이즈',
    };

    final planColor = planColors[state.plan] ?? Colors.grey;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(20),
      blur: 20,
      gradient: LinearGradient(
        colors: [
          planColor.withValues(alpha: 0.1),
          planColor.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: planColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: planColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${planNames[state.plan]} 플랜',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (state.status == 'active')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '활성',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (state.cancelAtPeriodEnd) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '취소 예정',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (state.plan != 'free' && state.amount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₩${_formatPrice(state.amount!)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: planColor,
                      ),
                    ),
                    Text(
                      '월',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Token Usage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '월간 토큰 사용량',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${state.usedTokens} / ${state.monthlyTokens == 999999 ? "무제한" : state.monthlyTokens.toString()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.monthlyTokens != 999999)
                LinearProgressIndicator(
                  value: state.usagePercentage / 100,
                  backgroundColor: planColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(planColor),
                  minHeight: 8,
                ),
              if (state.usagePercentage > 80 && state.monthlyTokens != 999999)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '토큰이 얼마 남지 않았습니다. 추가 구매를 고려해보세요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          
          if (state.nextBillingDate != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '다음 결제일: ${_formatDate(state.nextBillingDate!)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Action Buttons
          if (state.plan == 'free')
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(subscriptionProvider.notifier).upgradePlan('basic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '프리미엄으로 업그레이드',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else if (!state.cancelAtPeriodEnd)
            Row(
              children: [
                if (state.plan != 'enterprise')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref.read(subscriptionProvider.notifier)
                          .upgradePlan(state.plan == 'basic' ? 'premium' : 'enterprise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        '${state.plan == 'basic' ? '프리미엄' : '엔터프라이즈'}으로 업그레이드',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (state.plan != 'enterprise') const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => ref.read(subscriptionProvider.notifier).cancelSubscription(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('구독 취소'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlanComparison(SubscriptionState state, ThemeData theme, bool isDark) {
    final plans = [
      {
        'id': 'free',
        'name': '무료',
        'price': 0,
        'tokens': 10,
        'features': [
          '하루 10개 토큰',
          '기본 운세 이용',
          '제한된 운세 종류',
          '광고 표시',
        ],
      },
      {
        'id': 'basic',
        'name': '베이직',
        'price': 9900,
        'tokens': 100,
        'features': [
          '매월 100개 토큰',
          '모든 운세 이용 가능',
          '우선 응답 처리',
          '광고 없음',
        ],
        'badge': '인기',
      },
      {
        'id': 'premium',
        'name': '프리미엄',
        'price': 19900,
        'tokens': 300,
        'features': [
          '매월 300개 토큰',
          '베이직 모든 혜택',
          'VIP 고객 지원',
          '베타 기능 우선 체험',
        ],
      },
      {
        'id': 'enterprise',
        'name': '엔터프라이즈',
        'price': 49900,
        'tokens': 999999,
        'features': [
          '무제한 토큰',
          '프리미엄 모든 혜택',
          '전담 매니저',
          'API 접근 권한',
        ],
        'badge': '최고',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '플랜 비교',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...plans.map((plan) => _buildPlanCard(
          plan: plan,
          isCurrentPlan: state.plan == plan['id'],
          theme: theme,
          isDark: isDark,
        )).toList(),
      ],
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required bool isCurrentPlan,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        blur: 20,
        borderColor: isCurrentPlan
            ? theme.colorScheme.primary.withValues(alpha: 0.5)
            : Colors.transparent,
        borderWidth: isCurrentPlan ? 2 : 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      plan['name'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan['badge'] != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: plan['badge'] == '최고'
                                ? [Colors.amber.shade400, Colors.orange.shade400]
                                : [Colors.blue.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan['badge'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '현재 플랜',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan['price'] == 0
                  ? '무료'
                  : '₩${_formatPrice(plan['price'].toDouble())}/월',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['tokens'] == 999999
                  ? '무제한 토큰'
                  : '매월 ${plan['tokens']}개 토큰',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...List<Widget>.from((plan['features'] as List).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ))),
            if (!isCurrentPlan && plan['id'] != 'free') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(subscriptionProvider.notifier).upgradePlan(plan['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan['badge'] == '최고'
                        ? Colors.amber.shade600
                        : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '선택하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOffer(ThemeData theme, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(20),
      blur: 20,
      gradient: LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.2),
          Colors.blue.withValues(alpha: 0.2),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.blue],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연간 구독 특별 혜택',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '연간 구독 시 2개월 무료! 최대 17% 할인',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}