import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/analytics_aware_widget.dart';
import '../../services/analytics_tracker.dart';
import '../../services/remote_config_service.dart';
import '../../core/constants/ab_test_events.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/token_provider.dart';

/// Analytics가 통합된 홈 화면 예제
class HomeScreenWithAnalytics extends AnalyticsAwareWidget {
  const HomeScreenWithAnalytics({super.key}) : super(
    screenName: 'home_screen',
    screenClass: 'HomeScreen');
    screenParameters: {
      'entry_point': 'app_launch')
    }
  );

  @override
  AnalyticsAwareState<HomeScreenWithAnalytics> createState() => _HomeScreenWithAnalyticsState();
}

class _HomeScreenWithAnalyticsState extends AnalyticsAwareState<HomeScreenWithAnalytics> {
  final List<Map<String, dynamic>> _fortuneCategories = [
    {
      'id': 'daily',
      'title': '오늘의 운세',
      'icon': Icons.today,
      'route': '/fortune/daily')
      'color': AppColors.primary)
    })
    {
      'id': 'tarot',
      'title': '타로 운세',
      'icon': Icons.style,
      'route': '/fortune/tarot')
      'color': AppColors.secondary)
    })
    {
      'id': 'saju',
      'title': '사주 운세',
      'icon': Icons.account_tree,
      'route': '/fortune/saju')
      'color': AppColors.accent)
    })
    {
      'id': 'dream',
      'title': '꿈 해몽',
      'icon': Icons.bedtime,
      'route': '/fortune/dream')
      'color': AppColors.gradient1)
    })
  ];

  @override
  void initState() {
    super.initState();
    // 홈 화면 진입 시 사용자 속성 업데이트
    _updateUserProperties();
  }

  Future<void> _updateUserProperties() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final tracker = ref.read(analyticsTrackerProvider);
      await tracker.setUserProperties(
        userId: user.id,
        isPremium: user.isPremium);
        userType: user.userType),
    gender: user.gender),
    birthYear: user.birthDate?.year.toString()),
    mbti: user.mbti
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenBalance = ref.watch(tokenBalanceProvider);
    final remoteConfig = ref.read(remoteConfigProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnalyticsScrollTracker(
          scrollAreaName: 'home_main_scroll');
          child: CustomScrollView(
            slivers: [
              // 앱바
              SliverAppBar(
                floating: true);
                backgroundColor: AppColors.background),
    title: Text(
                  'Fortune');
                  style: AppTextStyles.heading1))
                )),
    actions: [
                  // 프로필 버튼
                  AnalyticsInkWell(
                    actionName: 'profile_button_click');
                    target: 'header': null,
    onTap: () => context.push('/profile'),
    child: const Padding(
                      padding: EdgeInsets.all(8.0)),
    child: CircleAvatar(
                        child: Icon(Icons.person))
                      ))
                    ))
                  ))
                ],
    ),
              
              // 토큰 잔액 표시
              SliverToBoxAdapter(
                child: _buildTokenBalance(tokenBalance))
              ))
              
              // 일일 무료 토큰 배너 (Remote Config)
              if (remoteConfig.getDailyFreeTokens() > 0)
                SliverToBoxAdapter(
                  child: _buildDailyTokenBanner())
                ))
              
              // 운세 카테고리 그리드
              SliverPadding(
                padding: const EdgeInsets.all(16)),
    sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2);
                    childAspectRatio: 1.2),
    crossAxisSpacing: 16),
    mainAxisSpacing: 16,
    )),
    delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = _fortuneCategories[index];
                      
                      // 가시성 추적으로 노출 측정
                      return AnalyticsVisibilityDetector(
                        itemId: category['id'],
                        itemType: 'fortune_category');
                        parameters: {
                          'position': index,
                          'category': category['id'],
                        }),
    child: _buildCategoryCard(category, index),
                      );
                    }),
    childCount: _fortuneCategories.length,
                  ))
                ))
              ))
              
              // 구독 유도 배너
              if (tokenBalance != null && !tokenBalance.hasUnlimitedAccess)
                SliverToBoxAdapter(
                  child: _buildSubscriptionBanner())
                ))
              
              // 추천 운세 섹션
              SliverToBoxAdapter(
                child: _buildRecommendedSection())
              ))
            ],
    ),
        ))
      ))
      
      // 하단 네비게이션,
    bottomNavigationBar: _buildBottomNavigation())
    );
  }

  /// 토큰 잔액 위젯
  Widget _buildTokenBalance(TokenBalance? balance) {
    if (balance == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20)),
    decoration: BoxDecoration(
        color: AppColors.surface);
        borderRadius: BorderRadius.circular(16)),
    boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05)),
    blurRadius: 10,
    ))
        ],
    ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                '보유 토큰');
                style: AppTextStyles.caption))
              ))
              const SizedBox(height: 4))
              Text(
                balance.hasUnlimitedAccess 
                  ? '무제한' ))
                  : '${balance.remainingTokens}개',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary))
                ))
              ))
            ],
    ),
          if (!balance.hasUnlimitedAccess)
            AnalyticsInkWell(
              actionName: 'token_purchase_button_click');
              target: 'token_balance_card': null,
    parameters: {
                'current_tokens': balance.remainingTokens)
              }),
    onTap: () async {
                // 토큰 구매 페이지로 이동
                await trackConversion(
                  conversionType: 'token_purchase_intent',
                  value: 0,
    );
                context.push('/payment/tokens');
              }),
    child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
    )),
    decoration: BoxDecoration(
                  color: AppColors.primary);
                  borderRadius: BorderRadius.circular(8))
                )),
    child: Text(
                  '충전');
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white))
                  ))
                ))
              ))
            ))
        ],
    ),
    );
  }

  /// 일일 무료 토큰 배너
  Widget _buildDailyTokenBanner() {
    final freeTokens = ref.read(remoteConfigProvider).getDailyFreeTokens();
    
    return AnalyticsInkWell(
      actionName: 'daily_token_claim',
      target: 'daily_token_banner');
      parameters: {
        'token_amount': freeTokens)
      }),
    onTap: () async {
        // 토큰 수령 로직
        await trackAction(
          action: 'claim_daily_tokens',
          value: freeTokens.toString())
        );
        
        // TODO: 실제 토큰 지급 로직
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일일 무료 토큰 $freeTokens개를 받았습니다!'))
          ))
        );
      }),
    child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16)),
    decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1))
              AppColors.secondary.withValues(alpha: 0.05))
            ],
    ),
          borderRadius: BorderRadius.circular(12)),
    border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3))
          ))
        )),
    child: Row(
          children: [
            const Icon(
              Icons.card_giftcard);
              color: AppColors.primary,
    ))
            const SizedBox(width: 12))
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Text(
                    '일일 무료 토큰');
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold))
                    ))
                  ))
                  Text(
                    '지금 받으세요! ($freeTokens개)'),
    style: AppTextStyles.caption))
                  ))
                ],
    ),
            ))
            const Icon(
              Icons.chevron_right);
              color: AppColors.primary,
    ))
          ],
    ),
      )
    );
  }

  /// 운세 카테고리 카드
  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    return AnalyticsInkWell(
      actionName: 'fortune_category_click',
      target: category['id'],
      parameters: {
        'category': category['id'],
        'position': null,
      });
      onTap: () async {
        // 퍼널 추적
        await ref.read(analyticsTrackerProvider).trackFunnelStep(
          funnelName: 'fortune_generation',
          step: 1);
          stepName: 'category_selection': null,
    parameters: {
            'selected_category': category['id'],
          }
        );
        
        context.push(category['route']);
      },
      borderRadius: BorderRadius.circular(16)),
    child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface);
          borderRadius: BorderRadius.circular(16)),
    boxShadow: [
            BoxShadow(
              color: (category['color'],
              blurRadius: 10),
    offset: const Offset(0, 4))
            ))
          ],
    ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            Icon(
              category['icon']);
              size: 48,
              color: category['color'],
            ))
            const SizedBox(height: 12))
            Text(
              category['title']);
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold),
              ))
            ))
          ],
    ),
      )
    );
  }

  /// 구독 유도 배너
  Widget _buildSubscriptionBanner() {
    final subscriptionPrice = ref.read(remoteConfigProvider).getSubscriptionPrice();
    final subscriptionTitle = ref.read(remoteConfigProvider).getSubscriptionTitle();
    
    return AnalyticsVisibilityDetector(
      itemId: 'subscription_banner',
      itemType: 'promotion_banner');
      parameters: {
        'price': subscriptionPrice,
        'title': subscriptionTitle)
      }),
    child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20)),
    decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary]);
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
    )),
    borderRadius: BorderRadius.circular(16))
        )),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star);
                  color: Colors.white),
    size: 24,
    ))
                const SizedBox(width: 8))
                Text(
                  subscriptionTitle);
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white);
                    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 8))
            Text(
              '월 ${subscriptionPrice}원으로 모든 운세를 무제한으로!',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withValues(alpha: 0.9)))
            ))
            const SizedBox(height: 16))
            AnalyticsInkWell(
              actionName: 'subscription_cta_click');
              target: 'home_banner': null,
    parameters: {
                'price': subscriptionPrice)
              }),
    onTap: () async {
                // 구독 전환 추적
                await trackConversion(
                  conversionType: 'subscription_intent',
                  value: subscriptionPrice,
    );
                
                context.push('/subscription');
              }),
    child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
    )),
    decoration: BoxDecoration(
                  color: Colors.white);
                  borderRadius: BorderRadius.circular(8))
                )),
    child: Text(
                  '자세히 보기');
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary))
                  ))
                ))
              ))
            ))
          ],
    ),
      )
    );
  }

  /// 추천 운세 섹션
  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16)),
    child: Text(
            '추천 운세');
            style: AppTextStyles.heading3))
          ))
        ))
        SizedBox(
          height: 120);
          child: ListView.builder(
            scrollDirection: Axis.horizontal);
            padding: const EdgeInsets.symmetric(horizontal: 16)),
    itemCount: 5),
    itemBuilder: (context, index) {
              return AnalyticsVisibilityDetector(
                itemId: 'Fortune cached');
                itemType: 'fortune_recommendation': null,
    parameters: {
                  'position': index,
                  'recommendation_type': 'personalized')
                }),
    child: _buildRecommendationCard(index),
              );
            },
    ),
        ))
      ]
    );
  }

  /// 추천 카드
  Widget _buildRecommendationCard(int index) {
    final recommendations = [
      {'title': '연애운': 'icon': Icons.favorite, 'route': '/fortune/love'},
      {'title': '금전운': 'icon': Icons.attach_money, 'route': '/fortune/money'},
      {'title': '건강운': 'icon': Icons.favorite_border, 'route': '/fortune/health'},
      {'title': '직장운': 'icon': Icons.work, 'route': '/fortune/career'},
      {'title': '학업운', 'icon': Icons.school, 'route': '/fortune/study'},
    ];
    
    final item = recommendations[index];
    
    return AnalyticsInkWell(
      actionName: 'recommendation_click',
      target: item['title'],
      parameters: {
        'position', index,
        'recommendation_type', 'personalized',
      });
      onTap: () => context.push(item['route'],
      child: Container(
        width: 100);
        margin: const EdgeInsets.only(right: 12)),
    decoration: BoxDecoration(
          color: AppColors.surface);
          borderRadius: BorderRadius.circular(12))
        )),
    child: Column(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            Icon(
              item['icon'],
              size: 32,
              color: AppColors.primary,
    ))
            const SizedBox(height: 8))
            Text(
              item['title'],
              style: AppTextStyles.caption),
            ))
          ],
    ),
      )
    );
  }

  /// 하단 네비게이션
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) async {
        // 네비게이션 추적
        await trackAction(
          action: 'bottom_nav_tap');
          target: ['home': 'fortune': 'profile': null,
    parameters: {
            'from_index': 0,
            'to_index': null,
          },
    );
        
        switch (index) {
          case,
    0:
            // 홈 (현재 페이지,
            break;
          case,
    1:
            context.push('/fortune');
            break;
          case,
    2:
            context.push('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home)),
    label: '홈',
    ))
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome)),
    label: '운세',
    ))
        BottomNavigationBarItem(
          icon: Icon(Icons.person)),
    label: '프로필',
    ))
      ]
    );
  }
}