import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/theme/toss_design_system.dart';

class TrendPage extends ConsumerStatefulWidget {
  const TrendPage({super.key});

  @override
  ConsumerState<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends ConsumerState<TrendPage> {
  // Scroll controller and variables for navigation bar hiding
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;
  
  final List<Map<String, dynamic>> trendItems = [
    {
      'type': 'trend',
      'emoji': '🔥',
      'title': '2025년 띠별 운세',
      'subtitle': '뱀띠가 대박나는 해?',
      'image': 'trend1',
      'likes': 1234,
      'views': '0'},
    {
      'type': 'test',
      'emoji': '💕',
      'title': '연애 성향 테스트',
      'subtitle': '나의 진짜 연애 스타일은?',
      'image': 'test1',
      'likes': 892,
      'views': '0'},
    {
      'type': 'trend',
      'emoji': '🌟',
      'title': 'MBTI별 1월 운세',
      'subtitle': 'ENFP는 이번달 대박!',
      'image': 'trend2',
      'likes': 567,
      'views': '0'},
    {
      'type': 'test',
      'emoji': '🧠',
      'title': '숨겨진 재능 찾기',
      'subtitle': '내 안의 잠재력 발견하기',
      'image': 'test2',
      'likes': 445,
      'views': '0'},
    {
      'type': 'trend',
      'emoji': '💸',
      'title': '혈액형별 금전운',
      'subtitle': 'O형 로또 당첨 확률 UP!',
      'image': 'trend3',
      'likes': 789,
      'views': '0'}];

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller with navigation bar hiding logic
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Ensure navigation bar is visible when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).show();
    });
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final currentScrollPosition = _scrollController.offset;
    const scrollDownThreshold = 5.0; // Reduced for quicker hide
    const scrollUpThreshold = 1.0; // Ultra sensitive - immediately show on any upward scroll
    
    // Always show navigation when at the top
    if (currentScrollPosition <= 10.0) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        print('🔼 Showing nav bar - at top');
        ref.read(navigationVisibilityProvider.notifier).show();
      }
      _lastScrollOffset = currentScrollPosition;
      return;
    }
    
    // Check scroll direction
    final scrollDelta = currentScrollPosition - _lastScrollOffset;
    
    if (scrollDelta > scrollDownThreshold && !_isScrollingDown) {
      // Scrolling down - hide navigation
      _isScrollingDown = true;
      print('🔽 Hiding nav bar - scrolling down');
      ref.read(navigationVisibilityProvider.notifier).hide();
    } else if (scrollDelta < -scrollUpThreshold) {
      // Scrolling up - immediately show navigation (any upward movement)
      if (_isScrollingDown) {
        _isScrollingDown = false;
        print('🔼 Showing nav bar - scrolling up');
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    }
    
    _lastScrollOffset = currentScrollPosition;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the navigation visibility state for debugging
    final navState = ref.watch(navigationVisibilityProvider);
    print('🎯 Navigation state - isVisible: ${navState.isVisible}, isAnimating: ${navState.isAnimating}');
    
    return Scaffold(
      backgroundColor: TossDesignSystem.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1));
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: trendItems.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header section replacing AppBar
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Color(0xFFF58529),
                              Color(0xFFDD2A7B),
                              Color(0xFF8134AF)]).createShader(bounds),
                          child: Text(
                            '트렌드 & 테스트',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: TossDesignSystem.white),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: TossDesignSystem.black.withValues(alpha: 0.87)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              }
              
              final item = trendItems[index - 1]; // -1 because of header
              return _buildTrendCard(item).animate()
                .fadeIn(delay: Duration(milliseconds: 100 * (index - 1)))
                .slideY(begin: 0.1, end: 0);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendCard(Map<String, dynamic> item) {
    final bool isTrend = item['type'] == 'trend';
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to detail page
          if (isTrend) {
            // Go to trend detail
          } else {
            // Go to test page
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isTrend
                ? [Color(0xFFF58529), Color(0xFFDD2A7B)]
                : [Color(0xFF8134AF), Color(0xFF515BD4)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isTrend ? Color(0xFFF58529) : Color(0xFF8134AF))
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6))]),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isTrend ? '트렌드' : '테스트',
                        style: const TextStyle(
                          color: TossDesignSystem.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Emoji and title
                    Row(
                      children: [
                        Text(
                          item['emoji'],
                          style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  color: TossDesignSystem.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'],
                                style: TextStyle(
                                  color: TossDesignSystem.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Stats
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: TossDesignSystem.white,
                          size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${item['likes']}',
                          style: const TextStyle(
                            color: TossDesignSystem.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.visibility,
                          color: TossDesignSystem.white,
                          size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${item['views']}',
                          style: const TextStyle(
                            color: TossDesignSystem.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Decorative elements
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TossDesignSystem.white.withValues(alpha: 0.1)),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TossDesignSystem.white.withValues(alpha: 0.15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}