import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/fortune.dart';
import '../../domain/entities/user_profile.dart';
import '../../presentation/widgets/daily_fortune_summary_card.dart';
import '../../presentation/widgets/fortune_card.dart';
import '../../presentation/widgets/profile_completion_banner.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../presentation/providers/fortune_provider.dart';
import '../../presentation/providers/recommendation_provider.dart';
import '../../presentation/screens/ad_loading_screen.dart';
import '../../services/cache_service.dart';
import '../../services/storage_service.dart';
import '../../models/fortune_model.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final supabase = Supabase.instance.client;
  final _cacheService = CacheService();
  final _storageService = StorageService();
  Map<String, dynamic>? userProfile;
  UserProfile? userProfileEntity;
  List<Map<String, dynamic>> recentFortunes = [];
  DailyFortune? todaysFortune;
  Fortune? cachedFortune; // 캐시된 전체 운세 데이터
  bool isLoadingFortune = false;
  bool isRefreshing = false;
  int refreshCount = 0;
  static const int maxRefreshCount = 3;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRecentFortunes();
    _loadRefreshCount();
    
    // Delay fortune loading to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load today's fortune after the widget tree is built
      _loadTodaysFortune();
      
      // Check if user just completed onboarding
      final isFirstTime = Uri.base.queryParameters['firstTime'] == 'true';
      if (isFirstTime) {
        // Show welcome message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('환영합니다! 오늘의 운세를 확인해보세요 ✨'),
            backgroundColor: Colors.green,
            duration: Duration(second,
      s: 3),
          ),
        );
      }
    });
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
              birthdate: response['birth_date'] != null 
                  ? DateTime.tryParse(response['birth_date']) 
                  : null,
              birthTime: response['birth_time'],
              isLunar: response['is_lunar'] ?? false,
              gender: response['gender'],
              mbti: response['mbti'],
              bloodType: response['blood_type'],
              zodiacSign: response['zodiac_sign'],
              zodiacAnimal: response['chinese_zodiac'],
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
    final fortunes = await _storageService.getRecentFortunes();
    setState(() {
      recentFortunes = fortunes;
    });
  }

  Future<void> _loadTodaysFortune() async {
    debugPrint('🔍 [HomeScreen] _loadTodaysFortune: Starting to load today\'s fortune');
    
    try {
      final currentUser = supabase.auth.currentUser;
      final userId = currentUser?.id;
      
      if (userId == null) {
        debugPrint('❌ [HomeScreen] User ID is null - cannot load fortune');
        return;
      }
      
      // 1. 먼저 캐시에서 오늘의 운세 확인
      debugPrint('🔍 [HomeScreen] Checking cache for today\'s fortune...');
      final cachedFortuneData = await _cacheService.getCachedFortune('daily', {'userId': userId});
      
      if (cachedFortuneData != null) {
        debugPrint('✅ [HomeScreen] Found cached fortune! Loading from cache...');
        // 캐시된 데이터로 UI 즉시 업데이트
        final fortuneEntity = cachedFortuneData.toEntity();
        _updateFortuneUI(fortuneEntity);
        cachedFortune = fortuneEntity; // 캐시된 전체 데이터 저장
        
        // 백그라운드에서 새로운 데이터 가져오기 (선택적)
        _refreshFortuneInBackground();
      } else {
        debugPrint('🔍 [HomeScreen] No cached fortune found. Loading from API...');
        setState(() => isLoadingFortune = true);
        await _fetchFortuneFromAPI();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [HomeScreen] Error loading fortune: $e');
      debugPrint('❌ [HomeScreen] Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
            content: Text('운세를 불러오는 중 오류가 발생했습니다: ${e.toString(,
  )}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _updateFortuneUI(Fortune fortune) {
    debugPrint('🔍 [HomeScreen] Updating UI with fortune data');
    
    // Log the actual API response for debugging
    debugPrint('🔍 [HomeScreen] Fortune metadata: ${fortune.metadata}');
    debugPrint('🔍 [HomeScreen] Fortune luckyItems: ${fortune.luckyItems}');
    debugPrint('🔍 [HomeScreen] Fortune overallScore: ${fortune.overallScore}');
    
    final userId = supabase.auth.currentUser?.id;
    final today = DateTime.now();
    
    // Try to extract daily fortune data from metadata or content
    if (fortune.metadata != null && fortune.metadata!.containsKey('dailyFortune')) {
      final dailyData = fortune.metadata!['dailyFortune'] as Map<String, dynamic>;
      final score = dailyData['score'] ?? fortune.overallScore ?? 75;
      
      setState(() {
        todaysFortune = DailyFortune(
          score: score,
          keywords: List<String>.from(dailyData['keywords'] ?? ['행운', '기회', '성장']),
          summary: dailyData['summary'] ?? fortune.content,
          luckyColor: dailyData['luckyColor'] ?? '#FF6B6B',
          luckyNumber: dailyData['luckyNumber'] ?? _generateLuckyNumber(userId, today),
          energy: dailyData['energy'] ?? _getEnergyByScore(score),
          mood: dailyData['mood'] ?? _getMoodByScore(score),
          advice: dailyData['advice'] ?? _getAdviceByScore(score),
          caution: dailyData['caution'] ?? _getCautionByScore(score),
          bestTime: dailyData['bestTime'] ?? _getBestTimeByUser(userId, today),
          compatibility: dailyData['compatibility'] ?? '좋은 사람들과 함께',
          elements: FortuneElements(,
      love: dailyData['elements']?['love'] ?? 75,
            career: dailyData['elements']?['career'] ?? 80,
            money: dailyData['elements']?['money'] ?? 70,
            health: dailyData['elements']?['health'] ?? 85,
          ),
        );
      });
    } else {
      // Fallback: Create a basic DailyFortune from the Fortune content
      setState(() {
        // Get lucky color and ensure it's a hex value
        String luckyColor = fortune.luckyItems?['color'] ?? '#FF6B6B';
        // If it's not a hex color (doesn't start with #), use default
        if (!luckyColor.startsWith('#')) {
          luckyColor = '#FF6B6B'; // Default red color
        }
        
        final score = fortune.overallScore ?? 75;
        
        todaysFortune = DailyFortune(
          score: score,
          keywords: fortune.recommendations ?? ['행운', '기회', '성장'],
          summary: fortune.summary ?? fortune.content,
          luckyColor: luckyColor,
          luckyNumber: fortune.luckyItems?['number'] ?? _generateLuckyNumber(userId, today),
          energy: _getEnergyByScore(score),
          mood: _getMoodByScore(score),
          advice: fortune.description ?? _getAdviceByScore(score),
          caution: _getCautionByScore(score),
          bestTime: _getBestTimeByUser(userId, today),
          compatibility: '좋은 사람들과 함께',
          elements: FortuneElements(,
      love: fortune.scoreBreakdown?['love'] ?? 75,
            career: fortune.scoreBreakdown?['career'] ?? 80,
            money: fortune.scoreBreakdown?['money'] ?? 70,
            health: fortune.scoreBreakdown?['health'] ?? 85,
          ),
        );
      });
    }
  }
  
  Future<void> _loadRefreshCount() async {
    final count = await _storageService.getDailyFortuneRefreshCount();
    setState(() {
      refreshCount = count;
    });
  }
  
  Future<void> _refreshFortune() async {
    if (refreshCount >= maxRefreshCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘의 새로고침 횟수를 모두 사용했습니다. 내일 다시 시도해주세요!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => isRefreshing = true);
    
    try {
      // 캐시를 지우고 새로운 운세를 가져옴
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // 캐시 삭제
        await _cacheService.removeCachedFortune('daily', {'userId': userId});
        
        // 새로운 운세 가져오기
        await _fetchFortuneFromAPI();
        
        // 새로고침 횟수 증가
        await _storageService.incrementDailyFortuneRefreshCount();
        setState(() {
          refreshCount++;
        });
        
        // 성공 메시지
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('새로운 운세를 받았습니다! (남은 횟수: ${maxRefreshCount - refreshCount - 1})'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error refreshing fortune: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('운세를 새로고침하는 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isRefreshing = false);
    }
  }
  
  Future<void> _fetchFortuneFromAPI() async {
    try {
      await Future(() async {
        final dailyFortuneNotifier = ref.read(dailyFortuneProvider.notifier);
        final today = DateTime.now();
        
        dailyFortuneNotifier.setDate(today);
        await dailyFortuneNotifier.loadFortune();
        
        final fortuneState = ref.read(dailyFortuneProvider);
        
        if (fortuneState.fortune != null && !fortuneState.isLoading) {
          debugPrint('🔍 [HomeScreen] Fortune loaded successfully from API');
          final fortune = fortuneState.fortune!;
          cachedFortune = fortune; // 전체 데이터 저장
          _updateFortuneUI(fortune);
          
          // 캐시에 저장
          try {
            final userId = supabase.auth.currentUser?.id;
            if (userId != null) {
              await _cacheService.cacheFortune('daily', {'userId': userId}, FortuneModel.fromEntity(fortune)
              debugPrint('✅ [HomeScreen] Fortune cached successfully');
            }
          } catch (e) {
            debugPrint('❌ [HomeScreen] Failed to cache fortune: $e');
          }
        }
      });
    } finally {
      setState(() => isLoadingFortune = false);
    }
  }
  
  Future<void> _refreshFortuneInBackground() async {
    // 백그라운드에서 새로운 데이터 가져오기 (UI 블로킹 없음)
    try {
      await Future(() async {
        final dailyFortuneNotifier = ref.read(dailyFortuneProvider.notifier);
        final today = DateTime.now();
        
        dailyFortuneNotifier.setDate(today);
        await dailyFortuneNotifier.loadFortune();
        
        final fortuneState = ref.read(dailyFortuneProvider);
        
        if (fortuneState.fortune != null && !fortuneState.isLoading) {
          final fortune = fortuneState.fortune!;
          
          // 새로운 데이터가 캐시된 데이터와 다른 경우만 업데이트
          if (cachedFortune == null || fortune.id != cachedFortune!.id) {
            debugPrint('🔍 [HomeScreen] New fortune data available, updating UI');
            cachedFortune = fortune;
            _updateFortuneUI(fortune);
            
            // 새로운 데이터 캐시
            try {
              final userId = supabase.auth.currentUser?.id;
              if (userId != null) {
                await _cacheService.cacheFortune(
    'daily', {'userId': userId}, FortuneModel.fromEntity(fortune,
  )}
            } catch (e) {
              debugPrint('❌ [HomeScreen] Failed to cache updated fortune: $e');
            }
          }
        }
      });
    } catch (e) {
      debugPrint('❌ [HomeScreen] Background refresh failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.cardBackground, // Light gray background for cards
      body: SafeArea(,
      child: SingleChildScrollView(,
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile completion banner
              const ProfileCompletionBanner(),
              
              // 일일 운세 요약 카드 (환영 메시지 대신) - 전체 너비
              Padding(
                padding: const EdgeInsets.symmetric(horizonta,
      l: 16, vertical: 20),
                child: DailyFortuneSummaryCard(,
      fortune: todaysFortune,
                  isLoading: isLoadingFortune,
                  userName: userProfile?['name'],
                  onTap: () => _navigateToFortune('/fortune/time-based', '시간별 운세'),
                  onRefresh: _refreshFortune,
                  isRefreshing: isRefreshing,
                  refreshCount: refreshCount,
                  maxRefreshCount: maxRefreshCount,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // Instagram-style section title
                    Row(
                      children: [
                        Text(
                          '✨ ',
                          style: TextStyle(fontSiz,
      e: 20),
                        ),
                        Text(
                          '인기 운세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(,
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
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(,
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
                          style: TextStyle(fontSiz,
      e: 20),
                        ),
                        Text(
                          '나를 위한 추천',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(,
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
    final services = [
      {
        'icon': Icons.dashboard_rounded,
        'emoji': '🎯',
        'title': '운세 패키지',
        'desc': '여러 운세 한번에',
        'route': '/fortune/batch',
        'gradient': [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      },
      {
        'icon': Icons.psychology_alt_rounded,
        'emoji': '🤖',
        'title': 'AI 종합 운세',
        'desc': '모든 데이터 분석',
        'route': '/fortune/ai-comprehensive',
        'gradient': [Color(0xFF9C27B0), Color(0xFF673AB7)],
      },
      {
        'icon': Icons.wb_sunny,
        'emoji': '☀️',
        'title': '사주팔자',
        'desc': '정통 사주 풀이',
        'route': '/fortune/saju',
        'gradient': [Color(0xFFEF4444), Color(0xFFEC4899)],
      },
      {
        'icon': Icons.star,
        'emoji': '⭐',
        'title': '전체 운세',
        'desc': '모든 운세 보기',
        'route': '/fortune',
      },
      {
        'icon': Icons.view_carousel_rounded,
        'emoji': '📱',
        'title': '스냅 스크롤 운세',
        'desc': '스와이프로 운세 보기',
        'route': '/demo/snap-scroll',
        'gradient': [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(,
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
          .fadeIn(delay: Duration(millisecond,
      s: 300 + (index * 100)))
          .slideY(begin: 0.1, end: 0)
          .scale(begin: Offset(0.9, 0.9), end: Offset(
    1.0, 1.0,
  )},
    );
  }

  Widget _buildRecentFortunes(BuildContext context) {
    // 아이콘 매핑
    final iconMap = {
      '/fortune/mbti': Icons.psychology,
      '/fortune/zodiac': Icons.star,
      '/fortune/zodiac-animal': Icons.pets,
      '/fortune/chemistry': Icons.favorite,
      '/fortune/saju': Icons.wb_sunny,
      '/fortune/love': Icons.favorite_border,
      '/fortune/wealth': Icons.account_balance_wallet,
      '/fortune/career': Icons.work,
      '/fortune/marriage': Icons.favorite,
      '/fortune/compatibility': Icons.people,
    };
    
    return Column(
      children: recentFortunes.map((fortune) {
        // 시간 차이 계산
        final visitedAt = DateTime.fromMillisecondsSinceEpoch(fortune['visitedAt'] as int);
        final now = DateTime.now();
        final difference = now.difference(visitedAt);
        
        String timeAgo;
        if (difference.inMinutes < 1) {
          timeAgo = '방금 전';
        } else if (difference.inHours < 1) {
          timeAgo = '${difference.inMinutes}분 전';
        } else if (difference.inDays < 1) {
          timeAgo = '${difference.inHours}시간 전';
        } else if (difference.inDays < 7) {
          timeAgo = '${difference.inDays}일 전';
        } else {
          timeAgo = '${(difference.inDays / 7).floor()}주 전';
        }
        
        final path = fortune['path'] as String;
        final title = fortune['title'] as String;
        
        return Container(
          margin: const EdgeInsets.only(botto,
      m: 12),
          child: InkWell(,
      onTap: () => _navigateToFortune(path, title),
            borderRadius: BorderRadius.circular(12),
            child: Container(,
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(colo,
      r: context.fortuneTheme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alph,
      a: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(,
      children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      iconMap[path] ?? Icons.auto_awesome,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFortuneDescription(path),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(,
      horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          timeAgo,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(,
      color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
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
  
  String _getFortuneDescription(String path) {
    final descriptions = {
      '/fortune/mbti': '성격 유형별 조언',
      '/fortune/zodiac': '별이 알려주는 흐름',
      '/fortune/zodiac-animal': '12간지로 보는 운세',
      '/fortune/saju': '정통 사주 풀이',
      '/fortune/love': '사랑과 인연의 흐름',
      '/fortune/wealth': '재물과 투자의 운',
      '/fortune/career': '커리어와 성공의 길',
      '/fortune/marriage': '평생의 동반자 운세',
      '/fortune/compatibility': '둘의 운명적 만남',
      '/fortune/chemistry': '상대방과의 특별한 연결',
    };
    
    return descriptions[path] ?? '운세를 확인해보세요';
  }

  Widget _buildPersonalizedFortunes(BuildContext context) {
    final recommendedFortunesAsync = ref.watch(recommendedFortunesProvider);
    
    return recommendedFortunesAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          // 추천이 없을 경우 기본 운세 표시
          return _buildDefaultFortunes(context);
        }
        
        return Column(
          children: recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final fortune = entry.value;
            
            // 아이콘 매핑
            final iconMap = {
              'mbti': Icons.psychology,
              'zodiac': Icons.star,
              'zodiac-animal': Icons.pets,
              'chemistry': Icons.favorite,
              'lucky-job': Icons.work,
              'new-year': Icons.celebration,
              'saju': Icons.wb_sunny,
              'love': Icons.favorite_border,
              'wealth': Icons.account_balance_wallet,
            };
            
            // 배지 결정
            String badge = '';
            if (fortune.relevanceScore >= 0.9) {
              badge = '추천';
            } else if (fortune.reason.contains('관심')) {
              badge = '관심사';
            } else if (fortune.reason.contains('인기')) {
              badge = '인기';
            } else if (fortune.reason.contains('맞춤')) {
              badge = '맞춤';
            }
            
            return Container(
              margin: const EdgeInsets.only(botto,
      m: 12),
              child: InkWell(,
      onTap: () {
                  // 최근 방문 기록에 추가
                  _storageService.addRecentFortune(fortune.route, fortune.title);
                  _navigateToFortune(fortune.route, fortune.title);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(,
      padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(colo,
      r: context.fortuneTheme.dividerColor),
                  ),
                  child: Row(,
      children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          iconMap[fortune.id] ?? Icons.auto_awesome,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  fortune.title,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),
                                ),
                                if (badge.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(,
      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      badge,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(,
      color: Theme.of(context).colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fortune.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
                            ),
                            if (fortune.reason.isNotEmpty && !fortune.reason.contains('인기')) ...[
                              const SizedBox(height: 4),
                              Text(
                                fortune.reason,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(,
      color: Theme.of(context).colorScheme.primary,
                                  fontSize: 11,
                          ),
                              ),
                            ],
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
              .fadeIn(delay: Duration(millisecond,
      s: 600 + (index * 100)))
              .slideX(begin: 0.1, end: 0);
          }).toList(),
        );
      },
      loading: () => _buildLoadingRecommendations(context),
      error: (error, stack) => _buildDefaultFortunes(context),
    );
  }
  
  Widget _buildLoadingRecommendations(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(botto,
      m: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(colo,
      r: context.fortuneTheme.dividerColor),
        ),
        child: Row(,
      children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1.5.seconds),
            const SizedBox(width: 12),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1.5.seconds, delay: 0.2.seconds),
                  const SizedBox(height: 6),
                  Container(
                    width: 180,
                    height: 12,
                    decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1.5.seconds, delay: 0.4.seconds),
                ],
              ),
            ),
          ],
        ),
      );
  }
  
  Widget _buildDefaultFortunes(BuildContext context) {
    // 기본 추천 운세
    final defaultFortunes = [
      {
        'icon': Icons.schedule_rounded,
        'title': '시간별 운세',
        'desc': '오늘/내일/주간/월간',
        'badge': 'NEW',
        'route': '/fortune/time-based',
      },
      {
        'icon': Icons.work_rounded,
        'title': '커리어 운세',
        'desc': '취업/직업/사업 종합',
        'badge': '인기',
        'route': '/fortune/career',
      },
      {
        'icon': Icons.history_rounded,
        'title': '운세 히스토리',
        'desc': '나의 운세 기록',
        'badge': 'NEW',
        'route': '/fortune/history',
      },
    ];
    
    return Column(
      children: defaultFortunes.asMap().entries.map((entry) {
        final index = entry.key;
        final fortune = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(botto,
      m: 12),
          child: InkWell(,
      onTap: () {
              _storageService.addRecentFortune(
                fortune['route'] as String,
                fortune['title'] as String,
              );
              _navigateToFortune(
                fortune['route'] as String,
                fortune['title'] as String,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(,
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(colo,
      r: context.fortuneTheme.dividerColor),
              ),
              child: Row(,
      children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(,
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
                    child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              fortune['title'] as String,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(,
      horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                fortune['badge'] as String,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(,
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(,
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
          .fadeIn(delay: Duration(millisecond,
      s: 600 + (index * 100)))
          .slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  // Dynamic value generation helpers
  int _generateLuckyNumber(String? userId, DateTime date) {
    // Generate a consistent lucky number based on user ID and date
    final seed = '${userId ?? 'default'}_${date.year}_${date.month}_${date.day}';
    int hash = seed.hashCode.abs();
    // Return a number between 1 and 45 (lottery number range)
    return (hash % 45) + 1;
  }
  
  String _getMoodByScore(int score) {
    if (score >= 90) return '최고의 기분';
    if (score >= 80) return '활기찬';
    if (score >= 70) return '평온함';
    if (score >= 60) return '보통';
    if (score >= 50) return '주의 필요';
    return '조심스러운';
  }
  
  int _getEnergyByScore(int score) {
    // Energy level based on score (50-100 range)
    return 50 + (score * 0.5).round();
  }
  
  String _getBestTimeByUser(String? userId, DateTime date) {
    // Generate consistent time based on user ID
    final seed = '${userId ?? 'default'}_besttime'.hashCode.abs();
    final timeSlot = seed % 8; // 8 time slots throughout the day
    
    switch (timeSlot) {
      case 0: return '오전 6시-8시';
      case 1: return '오전 9시-11시';
      case 2: return '오후 12시-2시';
      case 3: return '오후 2시-4시';
      case 4: return '오후 4시-6시';
      case 5: return '오후 6시-8시';
      case 6: return '오후 8시-10시';
      case 7: return '오후 10시-12시';
      default: return '오후 2시-4시';
    }
  }
  
  String _getAdviceByScore(int score) {
    if (score >= 90) return '오늘은 무엇이든 도전해보세요! 큰 성과가 기대됩니다.';
    if (score >= 80) return '긍정적인 에너지가 넘치는 날입니다. 적극적으로 행동하세요.';
    if (score >= 70) return '안정적인 하루가 될 것입니다. 차분하게 계획을 실행하세요.';
    if (score >= 60) return '평범한 하루지만 작은 행복을 찾아보세요.';
    if (score >= 50) return '신중하게 행동하고 무리하지 마세요.';
    return '오늘은 휴식이 필요한 날입니다. 자신을 돌보세요.';
  }
  
  String _getCautionByScore(int score) {
    if (score >= 90) return '과도한 자신감은 경계하세요.';
    if (score >= 80) return '지나친 낙관은 피하고 현실적으로 판단하세요.';
    if (score >= 70) return '작은 실수가 큰 문제가 될 수 있으니 주의하세요.';
    if (score >= 60) return '감정 기복에 휘둘리지 마세요.';
    if (score >= 50) return '충동적인 결정은 피하고 신중히 생각하세요.';
    return '무리한 도전보다는 안정을 추구하세요.';
  }

  void _navigateToFortune(String route, String title) {
    // 최근 방문 기록에 저장
    _storageService.addRecentFortune(route, title);
    
    // Check if user is premium
    final isPremium = userProfile?['is_premium'] ?? false;
    
    // 오늘의 운세 상세보기인 경우 캐시된 데이터 전달
    Map<String, dynamic>? fortuneParams;
    if (route == '/fortune/time-based' && cachedFortune != null) {
      fortuneParams = {
        'cachedFortune': cachedFortune,
        'todaysFortune': todaysFortune,
      };
    }
    
    if (!isPremium) {
      // Show ad loading screen for free users
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdLoadingScreen(,
      fortuneType: route.split('/').last,
            fortuneTitle: title,
            isPremium: false,
            fortuneRoute: route,
            fortuneParams: fortuneParams,
            fetchData: route == '/fortune/time-based' && cachedFortune != null
                ? null // 캐시가 있으면 API 호출하지 않음
                : null,
            onComplete: () {
              // Navigate to fortune page after ad
              context.go(route);
              // 최근 운세 목록 새로고침
              _loadRecentFortunes();
            },
            onSkip: () {
              // If user skips (premium feature), just go back
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else {
      // Premium users go directly with cached data
      if (fortuneParams != null) {
        context.go(route, extra: fortuneParams);
      } else {
        context.go(route);
      }
      // 최근 운세 목록 새로고침
      _loadRecentFortunes();
    }
  }

}