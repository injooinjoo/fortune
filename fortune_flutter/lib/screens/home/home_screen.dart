import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/fortune.dart';
import '../../presentation/widgets/daily_fortune_card.dart';
import '../../presentation/widgets/fortune_card.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/components/daily_token_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> recentFortunes = [];
  DailyFortune? todaysFortune;
  bool isLoadingFortune = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRecentFortunes();
    _loadTodaysFortune();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        setState(() {
          userProfile = response;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _loadRecentFortunes() async {
    // TODO: Load from local storage
    setState(() {
      recentFortunes = [];
    });
  }

  Future<void> _loadTodaysFortune() async {
    setState(() => isLoadingFortune = true);
    try {
      // TODO: Load from API or cache
      // For now, use mock data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        todaysFortune = const DailyFortune(
          score: 75,
          keywords: ['행운', '기회', '성장'],
          summary: '좋은 하루가 될 것 같습니다. 긍정적인 마음으로 하루를 시작하세요.',
          luckyColor: '#8B5CF6',
          luckyNumber: 7,
          energy: 80,
          mood: '평온함',
          advice: '차분하게 하루를 보내세요',
          caution: '조급하게 서두르지 마세요',
          bestTime: '오후 2시-4시',
          compatibility: '좋은 사람들과 함께',
          elements: FortuneElements(
            love: 75,
            career: 80,
            money: 70,
            health: 85,
          ),
        );
      });
    } catch (e) {
      debugPrint('Error loading fortune: $e');
    } finally {
      setState(() => isLoadingFortune = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // 웹과 동일한 배경색
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 - 웹과 동일한 스타일
              Container(
                color: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fortune',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => context.go('/profile'),
                      icon: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Daily Token Banner
              const DailyTokenBanner(),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 오늘의 운세 카드
                    DailyFortuneCard(
                      fortune: todaysFortune,
                      isLoading: isLoadingFortune,
                      onTap: () => _navigateToFortune('/fortune/daily', '일일 운세'),
                      onRefresh: _refreshFortune,
                    ),
                    const SizedBox(height: 32),
                    
                    // 주요 메뉴
                    Text(
                      '운세 서비스',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    _buildMainServices(context),
                    
                    // 최근에 본 운세
                    if (recentFortunes.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Icon(Icons.history, size: 20, color: context.fortuneTheme.subtitleText),
                          const SizedBox(width: 8),
                          Text(
                            '최근에 본 운세',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                                  ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 16),
                      _buildRecentFortunes(context),
                    ],
                    
                    // 나만의 맞춤 운세
                    const SizedBox(height: 32),
                    Text(
                      '나만의 맞춤 운세',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                    _buildPersonalizedFortunes(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainServices(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fortuneTheme = context.fortuneTheme;
    
    final services = [
      {
        'icon': Icons.wb_sunny,
        'title': '사주팔자',
        'desc': '정통 사주 풀이',
        'route': '/fortune/saju',
        'color': fortuneTheme.scoreFair,
      },
      {
        'icon': Icons.camera_alt,
        'title': 'AI 관상',
        'desc': '얼굴로 보는 운세',
        'route': '/physiognomy',
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.auto_awesome,
        'title': '프리미엄사주',
        'desc': '만화로 보는 사주',
        'route': '/premium',
        'color': colorScheme.tertiary,
      },
      {
        'icon': Icons.star,
        'title': '전체 운세',
        'desc': '모든 운세 보기',
        'route': '/fortune',
        'color': colorScheme.secondary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return FortuneCard(
          icon: service['icon'] as IconData,
          title: service['title'] as String,
          description: service['desc'] as String,
          iconColor: service['color'] as Color,
          onTap: () => _navigateToFortune(
            service['route'] as String,
            service['title'] as String,
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
          .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildRecentFortunes(BuildContext context) {
    return Column(
      children: recentFortunes.map((fortune) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _navigateToFortune(
              fortune['route'] as String,
              fortune['title'] as String,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.fortuneTheme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      fortune['icon'] as IconData,
                      size: 24,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fortune['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fortune['desc'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.fortuneTheme.subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fortune['timeAgo'] as String,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: context.fortuneTheme.subtitleText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalizedFortunes(BuildContext context) {
    final fortunes = [
      {
        'icon': Icons.bolt,
        'title': 'MBTI 주간 운세',
        'desc': '성격 유형별 조언',
        'badge': 'NEW',
        'route': '/fortune/mbti',
      },
      {
        'icon': Icons.star,
        'title': '별자리 월간 운세',
        'desc': '별이 알려주는 흐름',
        'badge': '인기',
        'route': '/fortune/zodiac',
      },
      {
        'icon': Icons.pets,
        'title': '띠 운세',
        'desc': '12간지로 보는 이달의 운세',
        'badge': '전통',
        'route': '/fortune/zodiac-animal',
      },
    ];

    return Column(
      children: fortunes.map((fortune) {
        final index = fortunes.indexOf(fortune);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _navigateToFortune(
              fortune['route'] as String,
              fortune['title'] as String,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.fortuneTheme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      fortune['icon'] as IconData,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              fortune['title'] as String,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                      ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                fortune['badge'] as String,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fortune['desc'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.fortuneTheme.subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: context.fortuneTheme.subtitleText,
                  ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
          .slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  void _navigateToFortune(String route, String title) {
    // TODO: Implement navigation with ad loading for free users
    context.go(route);
  }

  Future<void> _refreshFortune() async {
    await _loadTodaysFortune();
  }
}