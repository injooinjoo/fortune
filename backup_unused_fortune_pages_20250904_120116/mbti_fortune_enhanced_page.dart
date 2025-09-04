import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'base_fortune_page.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../services/mbti_fortune_enhanced_service.dart';
import '../widgets/mbti_grid_selector.dart';
import '../widgets/mbti_energy_gauge.dart';
import '../widgets/cognitive_function_weather.dart';
import '../widgets/mbti_synergy_card.dart';
import '../widgets/mbti_quest_card.dart';
import '../widgets/fortune_loading_skeleton.dart';

class MbtiFortuneEnhancedPage extends StatefulWidget {
  const MbtiFortuneEnhancedPage({super.key});

  @override
  State<MbtiFortuneEnhancedPage> createState() => _MbtiFortuneEnhancedPageState();
}

class _MbtiFortuneEnhancedPageState extends State<MbtiFortuneEnhancedPage> 
    with SingleTickerProviderStateMixin {
  String? _selectedMbti;
  bool _isLoading = false;
  Map<String, dynamic>? _mbtiEnergyData;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserMbti();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadUserMbti() {
    // Try to load user's MBTI from profile
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final userProfile = await Consumer(
          builder: (context, ref, _) {
            return ref.read(userProvider).value;
          }
        );
        
        if (userProfile != null && userProfile.mbti != null) {
          setState(() {
            _selectedMbti = userProfile.mbti;
          });
          _loadMbtiEnergyData();
        }
      } catch (e) {
        Logger.debug('Could not load user MBTI: $e');
      }
    });
  }
  
  Future<void> _loadMbtiEnergyData() async {
    if (_selectedMbti == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = await MbtiFortuneEnhancedService.getMbtiEnergyData(
        mbtiType: _selectedMbti!,
        userId: null, // Will be filled from auth
      );
      
      setState(() {
        _mbtiEnergyData = data;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Failed to load MBTI energy data', e);
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'MBTI 에너지 트래커',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TossDesignSystem.purple.withOpacity(0.3),
                      TossDesignSystem.tossBlue.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      if (_selectedMbti != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _selectedMbti!,
                            style: TossDesignSystem.heading1.copyWith(
                              color: TossDesignSystem.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack)
                          .shimmer(delay: 1000.ms, duration: 1500.ms),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // MBTI Selector if not selected
                  if (_selectedMbti == null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.psychology,
                            size: 60,
                            color: TossDesignSystem.purple,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'MBTI를 선택해주세요',
                            style: TossDesignSystem.heading3.copyWith(
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '당신의 MBTI 유형에 맞는 에너지 분석을 제공합니다',
                            style: TossDesignSystem.body3.copyWith(
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          MbtiGridSelector(
                            selectedMbti: _selectedMbti,
                            onMbtiSelected: (mbti) {
                              setState(() {
                                _selectedMbti = mbti;
                              });
                              _loadMbtiEnergyData();
                            },
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                  ]
                  // Show content if MBTI is selected
                  else if (_isLoading) ...[
                    const FortuneLoadingSkeleton(
                      itemCount: 4,
                      showHeader: true,
                      loadingMessage: 'MBTI 에너지를 분석하고 있어요...',
                    ),
                  ]
                  else if (_mbtiEnergyData != null) ...[
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: TossDesignSystem.tossBlue,
                        unselectedLabelColor: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        indicatorColor: TossDesignSystem.tossBlue,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(text: '에너지'),
                          Tab(text: '날씨'),
                          Tab(text: '시너지'),
                          Tab(text: '퀘스트'),
                        ],
                      ),
                    ),
                    
                    // Tab Content
                    SizedBox(
                      height: 600,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Energy Tab
                          SingleChildScrollView(
                            child: MbtiEnergyGauge(
                              energyLevels: _mbtiEnergyData!['energyLevels'] ?? {},
                              isDark: isDark,
                            ),
                          ),
                          
                          // Weather Tab
                          SingleChildScrollView(
                            child: CognitiveFunctionWeather(
                              cognitiveWeather: _mbtiEnergyData!['cognitiveWeather'] ?? {},
                              isDark: isDark,
                            ),
                          ),
                          
                          // Synergy Tab
                          SingleChildScrollView(
                            child: MbtiSynergyCard(
                              synergyMap: _mbtiEnergyData!['synergyMap'] ?? {},
                              isDark: isDark,
                            ),
                          ),
                          
                          // Quest Tab
                          SingleChildScrollView(
                            child: MbtiQuestCard(
                              dailyQuests: _mbtiEnergyData!['dailyQuests'] ?? [],
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Time-based Advice
                    if (_mbtiEnergyData!['timeBasedAdvice'] != null) ...[
                      const SizedBox(height: 16),
                      _buildTimeAdviceCard(isDark),
                    ],
                    
                    // Mood Insights
                    if (_mbtiEnergyData!['moodInsights'] != null) ...[
                      const SizedBox(height: 16),
                      _buildMoodInsightsCard(isDark),
                    ],
                    
                    // Change MBTI Button
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMbti = null;
                          _mbtiEnergyData = null;
                        });
                      },
                      child: Text(
                        '다른 MBTI 선택하기',
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.tossBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeAdviceCard(bool isDark) {
    final timeAdvice = _mbtiEnergyData!['timeBasedAdvice'];
    final now = DateTime.now();
    String currentPeriod;
    
    if (now.hour < 12) {
      currentPeriod = 'morning';
    } else if (now.hour < 18) {
      currentPeriod = 'afternoon';
    } else if (now.hour < 22) {
      currentPeriod = 'evening';
    } else {
      currentPeriod = 'night';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: TossDesignSystem.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '시간대별 조언',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            timeAdvice['currentAdvice'] ?? '',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeIndicator('아침', timeAdvice['morning'] ?? 50, currentPeriod == 'morning', isDark),
              _buildTimeIndicator('오후', timeAdvice['afternoon'] ?? 50, currentPeriod == 'afternoon', isDark),
              _buildTimeIndicator('저녁', timeAdvice['evening'] ?? 50, currentPeriod == 'evening', isDark),
              _buildTimeIndicator('밤', timeAdvice['night'] ?? 50, currentPeriod == 'night', isDark),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildTimeIndicator(String label, int value, bool isCurrent, bool isDark) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isCurrent 
              ? TossDesignSystem.orange.withOpacity(0.1)
              : (isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50),
            borderRadius: BorderRadius.circular(12),
            border: isCurrent 
              ? Border.all(color: TossDesignSystem.orange, width: 2)
              : null,
          ),
          child: Center(
            child: Text(
              '$value%',
              style: TossDesignSystem.body2.copyWith(
                color: isCurrent 
                  ? TossDesignSystem.orange
                  : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TossDesignSystem.caption.copyWith(
            color: isCurrent 
              ? TossDesignSystem.orange
              : (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600),
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMoodInsightsCard(bool isDark) {
    final moodInsights = _mbtiEnergyData!['moodInsights'];
    final stressSignals = moodInsights['stressSignals'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mood,
                color: TossDesignSystem.purple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '기분 인사이트',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stressSignals.isNotEmpty) ...[
            Text(
              '주의할 스트레스 신호',
              style: TossDesignSystem.body3.copyWith(
                color: TossDesignSystem.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...stressSignals.map((signal) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 16,
                    color: TossDesignSystem.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    signal.toString(),
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }
}