import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/fortune.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/bottom_navigation_bar.dart';
import '../../shared/components/loading_states.dart';
import '../../shared/components/toast.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../shared/glassmorphism/glass_effects.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class HomeScreenUpdated extends ConsumerStatefulWidget {
  const HomeScreenUpdated({super.key});

  @override
  ConsumerState<HomeScreenUpdated> createState() => _HomeScreenUpdatedState();
}

class _HomeScreenUpdatedState extends ConsumerState<HomeScreenUpdated> {
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
    setState(() {
      recentFortunes = [];
    });
  }

  Future<void> _loadTodaysFortune() async {
    setState(() => isLoadingFortune = true);
    try {
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
    final theme = Theme.of(context);
    final user = ref.watch(userProvider).value;

    return Scaffold(
      appBar: AppHeader(
        title: 'Fortune',
        showBackButton: false,
        showTokenBalance: true,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요, ${user?.userMetadata?['name'] ?? '사용자'}님!',
                    style: theme.textTheme.headlineSmall,
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    '오늘의 운세를 확인해보세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),

            // Today's Fortune Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTodaysFortuneCard(),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '빠른 메뉴',
                style: theme.textTheme.headlineSmall,
              ).animate().fadeIn(delay: 200.ms),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),

            // Main Services
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '운세 서비스',
                style: theme.textTheme.headlineSmall,
              ).animate().fadeIn(delay: 300.ms),
            ),
            const SizedBox(height: 16),
            _buildMainServices(),

            // Recent Fortunes
            if (recentFortunes.isNotEmpty) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Text(
                      '최근에 본 운세',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ),
              const SizedBox(height: 16),
              _buildRecentFortunes(),
            ],

            // Personalized Fortunes
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '나만의 맞춤 운세',
                style: theme.textTheme.headlineSmall,
              ).animate().fadeIn(delay: 500.ms),
            ),
            const SizedBox(height: 16),
            _buildPersonalizedFortunes(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const FortuneBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTodaysFortuneCard() {
    if (isLoadingFortune) {
      return const CardSkeleton(height: 200);
    }

    final fortune = todaysFortune;
    if (fortune == null) {
      return GlassCard(
        onTap: _refreshFortune,
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text('탭하여 운세 불러오기'),
            ],
          ),
        ),
      );
    }

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 운세',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateTime.now().toString().substring(0, 10),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${fortune.score}점',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fortune.summary,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: fortune.keywords.map((keyword) {
              return Chip(
                label: Text(keyword),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/fortune/today'),
              child: const Text('자세히 보기'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.today, 'label': '오늘', 'route': '/fortune/today'},
      {'icon': Icons.event, 'label': '내일', 'route': '/fortune/tomorrow'},
      {'icon': Icons.date_range, 'label': '주간', 'route': '/fortune/weekly'},
      {'icon': Icons.calendar_month, 'label': '월간', 'route': '/fortune/monthly'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassButton(
              onPressed: () => context.push(action['route'] as String),
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(delay: Duration(milliseconds: 200 + (index * 50)))
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildMainServices() {
    final services = [
      {
        'icon': Icons.wb_sunny,
        'title': '사주팔자',
        'desc': '정통 사주 풀이',
        'route': '/fortune/saju',
        'colors': [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      },
      {
        'icon': Icons.camera_alt,
        'title': 'AI 관상',
        'desc': '얼굴로 보는 운세',
        'route': '/physiognomy',
        'colors': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      },
      {
        'icon': Icons.auto_awesome,
        'title': '프리미엄',
        'desc': '만화로 보는 사주',
        'route': '/premium',
        'colors': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      },
      {
        'icon': Icons.apps,
        'title': '전체 운세',
        'desc': '모든 운세 보기',
        'route': '/fortune',
        'colors': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service, index);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final colors = service['colors'] as List<Color>;
    
    return GestureDetector(
      onTap: () => context.push(service['route'] as String),
      child: ShimmerGlass(
        shimmerColor: colors.first,
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.map((c) => c.withOpacity(0.1)).toList(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service['title'] as String,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service['desc'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildRecentFortunes() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recentFortunes.length,
        itemBuilder: (context, index) {
          final fortune = recentFortunes[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassCard(
              width: 200,
              padding: const EdgeInsets.all(16),
              onTap: () => context.push(fortune['route'] as String),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        fortune['icon'] as IconData,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fortune['title'] as String,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    fortune['desc'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fortune['timeAgo'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildPersonalizedFortunes() {
    final fortunes = [
      {
        'icon': Icons.bolt,
        'title': 'MBTI 주간 운세',
        'desc': '성격 유형별 조언',
        'badge': 'NEW',
        'route': '/fortune/mbti',
        'color': const Color(0xFF7C3AED),
      },
      {
        'icon': Icons.star,
        'title': '별자리 월간 운세',
        'desc': '별이 알려주는 흐름',
        'badge': '인기',
        'route': '/fortune/zodiac',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.pets,
        'title': '띠 운세',
        'desc': '12간지로 보는 이달의 운세',
        'badge': '전통',
        'route': '/fortune/zodiac-animal',
        'color': const Color(0xFF10B981),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: fortunes.map((fortune) {
          final index = fortunes.indexOf(fortune);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              onTap: () => context.push(fortune['route'] as String),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (fortune['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      fortune['icon'] as IconData,
                      color: fortune['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              fortune['title'] as String,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (fortune['color'] as Color).withOpacity(0.3),
                                    (fortune['color'] as Color).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                fortune['badge'] as String,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: fortune['color'] as Color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fortune['desc'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(delay: Duration(milliseconds: 500 + (index * 100)))
              .slideX(begin: 0.1, end: 0);
        }).toList(),
      ),
    );
  }

  Future<void> _refreshFortune() async {
    await _loadTodaysFortune();
    Toast.success(context, '운세를 새로고침했습니다');
  }
}