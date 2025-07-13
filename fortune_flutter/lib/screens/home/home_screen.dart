import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/fortune.dart';
import '../../domain/entities/user_profile.dart';
import '../../presentation/widgets/daily_fortune_card.dart';
import '../../presentation/widgets/fortune_card.dart';
import '../../presentation/widgets/profile_completion_banner.dart';
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
  UserProfile? userProfileEntity;
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
          if (response != null) {
            // Convert to UserProfile entity
            userProfileEntity = UserProfile(
              id: response['id'] ?? userId,
              email: response['email'] ?? supabase.auth.currentUser?.email ?? '',
              name: response['name'] ?? '',
              birthdate: response['birthdate'] != null 
                  ? DateTime.tryParse(response['birthdate']) 
                  : null,
              birthTime: response['birth_time'],
              isLunar: response['is_lunar'] ?? false,
              gender: response['gender'],
              mbti: response['mbti'],
              bloodType: response['blood_type'],
              zodiacSign: response['zodiac_sign'],
              zodiacAnimal: response['zodiac_animal'],
              onboardingCompleted: response['onboarding_completed'] ?? false,
              isPremium: response['is_premium'] ?? false,
              premiumExpiry: response['premium_expiry'] != null
                  ? DateTime.tryParse(response['premium_expiry'])
                  : null,
              tokenBalance: response['token_balance'] ?? 0,
              preferences: response['preferences'],
              createdAt: response['created_at'] != null 
                  ? DateTime.parse(response['created_at'])
                  : DateTime.now(),
              updatedAt: response['updated_at'] != null
                  ? DateTime.parse(response['updated_at']) 
                  : DateTime.now(),
            );
          }
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
          luckyColor: '#000000',
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
      backgroundColor: Colors.white, // Instagram style clean white
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile completion banner
              const ProfileCompletionBanner(),
              
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
                    
                    // Instagram-style section title
                    Row(
                      children: [
                        Text(
                          '✨ ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '인기 운세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 20),
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
                    
                    // Instagram-style section title
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text(
                          '💕 ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '나를 위한 추천',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 20),
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
        'emoji': '☀️',
        'title': '사주팔자',
        'desc': '정통 사주 풀이',
        'route': '/fortune/saju',
        'gradient': [Color(0xFF000000), Color(0xFF333333)],
      },
      {
        'icon': Icons.camera_alt,
        'emoji': '📸',
        'title': 'AI 관상',
        'desc': '셀카로 보는 운세',
        'route': '/physiognomy',
        'gradient': [Color(0xFF1A1A1A), Color(0xFF4A4A4A)],
      },
      {
        'icon': Icons.auto_awesome,
        'emoji': '✨',
        'title': '프리미엄',
        'desc': '특별한 운세',
        'route': '/premium',
        'gradient': [Color(0xFF2C2C2C), Color(0xFF666666)],
      },
      {
        'icon': Icons.star,
        'emoji': '⭐',
        'title': '전체 운세',
        'desc': '모든 운세 보기',
        'route': '/fortune',
        'gradient': [Color(0xFF4A4A4A), Color(0xFF808080)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return FortuneCard(
          icon: service['icon'] as IconData,
          emoji: service['emoji'] as String?,
          title: service['title'] as String,
          description: service['desc'] as String,
          gradient: service['gradient'] as List<Color>?,
          onTap: () => _navigateToFortune(
            service['route'] as String,
            service['title'] as String,
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
          .slideY(begin: 0.1, end: 0)
          .scale(begin: Offset(0.9, 0.9), end: Offset(1.0, 1.0));
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
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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