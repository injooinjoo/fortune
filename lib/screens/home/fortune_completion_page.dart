import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../presentation/widgets/hexagon_chart.dart';
import '../../presentation/widgets/element_balance_chart.dart';
import '../../presentation/widgets/fortune_infographic_widgets.dart';
import '../../presentation/providers/fortune_history_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/providers/navigation_visibility_provider.dart';
import '../../core/theme/app_colors.dart';

/// 운세 스토리 완료 후 표시되는 화면
class FortuneCompletionPage extends ConsumerStatefulWidget {
  final fortune_entity.Fortune? fortune;
  final VoidCallback? onReplay;
  final String? userName;
  final UserProfile? userProfile;
  final Map<String, dynamic>? sajuAnalysis;
  // Additional comprehensive data fields
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? weatherSummary;
  final Map<String, dynamic>? overall;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? sajuInsight;
  final List<Map<String, dynamic>>? personalActions;
  final Map<String, dynamic>? notification;
  final Map<String, dynamic>? shareCard;

  const FortuneCompletionPage({
    super.key,
    this.fortune,
    this.onReplay,
    this.userName,
    this.userProfile,
    this.sajuAnalysis,
    this.meta,
    this.weatherSummary,
    this.overall,
    this.categories,
    this.sajuInsight,
    this.personalActions,
    this.notification,
    this.shareCard,
  });

  @override
  ConsumerState<FortuneCompletionPage> createState() => _FortuneCompletionPageState();
}

class _FortuneCompletionPageState extends ConsumerState<FortuneCompletionPage> {
  late ScrollController _scrollController;
  double _lastScrollPosition = 0.0;
  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleScroll() {
    final currentScrollPosition = _scrollController.position.pixels;
    const scrollDownThreshold = 10.0; // Minimum scroll down distance
    const scrollUpThreshold = 3.0; // Ultra sensitive scroll up detection
    
    // Always show navigation when at the top
    if (currentScrollPosition <= 10.0) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        ref.read(navigationVisibilityProvider.notifier).show();
      }
      _lastScrollPosition = currentScrollPosition;
      return;
    }
    
    if (currentScrollPosition > _lastScrollPosition + scrollDownThreshold && !_isScrollingDown) {
      // Scrolling down - hide navigation
      _isScrollingDown = true;
      ref.read(navigationVisibilityProvider.notifier).hide();
    } else if (currentScrollPosition < _lastScrollPosition - scrollUpThreshold && _isScrollingDown) {
      // Scrolling up - show navigation (very sensitive)
      _isScrollingDown = false;
      ref.read(navigationVisibilityProvider.notifier).show();
    }
    
    _lastScrollPosition = currentScrollPosition;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure navigation is visible when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use comprehensive data if available, fallback to fortune data
    final score = widget.overall?['score'] ?? widget.fortune?.overallScore ?? 75;
    final displayUserName = widget.userName ?? widget.userProfile?.name ?? '회원';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Load fortune history for statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fortuneHistoryProvider.notifier).loadHistory();
      
      // 네비게이션 바 표시 확인
      ref.read(navigationVisibilityProvider.notifier).show();
    });
    
    // Extract keywords from fortune data
    final keywords = _extractKeywords(widget.fortune);
    final keywordWeights = _calculateKeywordWeights(keywords);
    final hourlyScores = _generateHourlyScores(widget.fortune);
    final fortuneHistory = ref.watch(fortuneHistoryProvider);
    final userStats = _calculateUserStats(widget.fortune, fortuneHistory);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6), // 토스 배경색
      extendBodyBehindAppBar: true,
      body: Container(
        color: const Color(0xFFF2F4F6), // 토스 배경색
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).padding.top + 40,
                bottom: 100,
              ),
              child: Column(
                children: [
                  // Header
                  Text(
                    '$displayUserName님의 오늘 운세',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms),
                  
                  const SizedBox(height: 24),

                  // 인사말과 설명 (Edge Function의 greeting + description)
                  if (widget.fortune?.metadata?['greeting'] != null || widget.fortune?.metadata?['description'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.fortune?.metadata?['greeting'] != null) ...[
                            Text(
                              widget.fortune!.metadata!['greeting'],
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (widget.fortune?.metadata?['description'] != null) ...[
                            Text(
                              widget.fortune!.metadata!['description'],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut),
                    const SizedBox(height: 32),
                  ],

                  const SizedBox(height: 16),

                  // Weather Fortune Integration
                  if (widget.weatherSummary != null) ...[
                    FortuneInfographicWidgets.buildWeatherFortune(
                      widget.weatherSummary,
                      score,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 토스 스타일 메인 점수 (노란 원형)
                  FortuneInfographicWidgets.buildTossStyleMainScore(
                    score: score,
                    message: widget.overall?['summary'] ?? _getScoreMessage(score),
                    size: 180,
                  ),
                  
                  const SizedBox(height: 40),

                  // 일별 운세 곡선 그래프
                  FortuneInfographicWidgets.buildTossStyleWeeklyChart(
                    dailyScores: widget.fortune?.metadata?['daily_predictions'] != null
                        ? [
                            widget.fortune!.metadata!['daily_predictions']['before_yesterday'] ?? 75,
                            widget.fortune!.metadata!['daily_predictions']['yesterday'] ?? 82,
                            score,
                            widget.fortune!.metadata!['daily_predictions']['tomorrow'] ?? 88,
                            widget.fortune!.metadata!['daily_predictions']['after_tomorrow'] ?? 79,
                          ]
                        : [75, 82, score, 88, 79], // fallback values
                    todayIndex: 2,
                    height: 120,
                  ),
                  
                  const SizedBox(height: 32),

                  // 5각형 레이더 차트
                  if (widget.categories != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          // 토스 스타일 5각형 레이더 차트
                          FortuneInfographicWidgets.buildTossStyleRadarChart(
                            categories: {
                              '총운': widget.categories!['total']?['score'] ?? score,
                              '재물운': widget.categories!['money']?['score'] ?? 75,
                              '연애운': widget.categories!['love']?['score'] ?? 78,
                              '건강운': widget.categories!['health']?['score'] ?? 82,
                              '학업운': widget.categories!['work']?['score'] ?? 80,
                            },
                            size: 220,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Text(
                            '5대 영역별 운세',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FortuneInfographicWidgets.buildCategoryCards(widget.categories, isDarkMode: isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // 운세 요약 섹션 (띠/별자리/MBTI 기준)
                  FortuneInfographicWidgets.buildTossStyleFortuneSummary(
                    fortuneSummary: widget.fortune?.metadata?['fortuneSummary'],
                    userZodiacAnimal: widget.userProfile?.zodiacAnimal,
                    userZodiacSign: widget.userProfile?.zodiacSign,
                    userMBTI: widget.userProfile?.mbti,
                  ),
                  
                  const SizedBox(height: 32),

                  // 오늘의 조언 섹션 (Edge Function의 advice)
                  if (widget.fortune?.metadata?['advice'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '오늘의 조언',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.fortune!.metadata!['advice'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 250.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut),
                    const SizedBox(height: 24),
                  ],

                  // 주의사항 섹션 (Edge Function의 caution)
                  if (widget.fortune?.metadata?['caution'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_outlined,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '주의할 점',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.fortune!.metadata!['caution'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF92400E),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 350.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut),
                    const SizedBox(height: 24),
                  ],

                  // 특별 팁 섹션 (Edge Function의 special_tip)
                  if (widget.fortune?.metadata?['special_tip'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                            const Color(0xFF3B82F6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF8B5CF6), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF8B5CF6),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '특별 팁',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.fortune!.metadata!['special_tip'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B21A8),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 450.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut),
                    const SizedBox(height: 32),
                  ],
                  
                  // 토스 스타일 행운의 요소들 (Edge Function의 sajuInsight 및 동적 데이터 사용)
                  FortuneInfographicWidgets.buildTossStyleLuckyTags(
                    luckyColor: widget.fortune?.metadata?['sajuInsight']?['lucky_color'] ?? widget.sajuInsight?['lucky_color'] ?? '보라색',
                    luckyFood: widget.fortune?.metadata?['sajuInsight']?['lucky_food'] ?? widget.sajuInsight?['lucky_food'] ?? '매운탕',
                    luckyNumbers: (widget.fortune?.metadata?['lucky_numbers'] as List?)?.cast<String>() ?? ['3', '12'],
                    luckyDirection: widget.fortune?.metadata?['sajuInsight']?['luck_direction'] ?? widget.sajuInsight?['luck_direction'] ?? '남서쪽',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 행운의 코디 섹션 (동적 데이터 사용)
                  if (widget.fortune?.metadata?['lucky_outfit'] != null) ...[
                    FortuneInfographicWidgets.buildTossStyleLuckyOutfit(
                      title: widget.fortune!.metadata!['lucky_outfit']['title'] ?? '행운의 코디',
                      description: widget.fortune!.metadata!['lucky_outfit']['description'] ?? '기쁨과 성공을 이끄는 코디',
                      items: (widget.fortune!.metadata!['lucky_outfit']['items'] as List?)?.cast<String>() ?? [
                        '행운의 스타일로 하루를 시작하세요.',
                        '자신감 있는 색상과 스타일을 선택해보세요.',
                        '편안하면서도 매력적인 룩을 완성하세요.',
                        '오늘의 특별한 코디로 행운을 불러오세요!',
                      ],
                    ),
                  ] else ...[
                    // 폴백 - 기존 하드코딩 데이터
                    FortuneInfographicWidgets.buildTossStyleLuckyOutfit(
                      title: '행운의 코디',
                      description: '기쁨과 성공을 이끄는 코디',
                      items: [
                        '기쁨과 성공을 위한다면, 보라색 서즈와 골드 액세서리를 매치해보세요.',
                        '보라색은 고급스러움과 신비감을 주고, 골드 액세서리는 스타일에 우아함과 성취감을 더해줍니다.',
                        '보라색 서즈는 강한 인상을 남기며, 골드 액세서리는 성공적인 이미지를 강화합니다.',
                        '보라색 서즈와 골드 액세서리로 오늘, 기쁨과 성공을 이끄는 스타일을 완성해보세요!',
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),

                  // 사주 기반 행운 요소 (기존 유지)
                  if (widget.sajuInsight != null) ...[
                    FortuneInfographicWidgets.buildSajuLuckyItems(widget.sajuInsight, isDarkMode: isDark),
                    const SizedBox(height: 32),
                  ],
                  
                  // 육각형 레이더 차트 (종합 데이터가 없을 때 또는 백업용)
                  if (widget.categories == null && widget.fortune?.scoreBreakdown != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark 
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : const Color(0xFF3B82F6).withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.radar_rounded,
                                  color: isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '카테고리별 운세',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FortuneInfographicWidgets.buildRadarChart(
                            scores: {
                              '연애': widget.fortune!.scoreBreakdown!['love'] ?? 75,
                              '직장': widget.fortune!.scoreBreakdown!['career'] ?? 75,
                              '금전': widget.fortune!.scoreBreakdown!['money'] ?? 75,
                              '건강': widget.fortune!.scoreBreakdown!['health'] ?? 75,
                              '대인': widget.fortune!.scoreBreakdown!['relationship'] ?? 75,
                              '행운': widget.fortune!.scoreBreakdown!['luck'] ?? 75,
                            },
                            size: 200,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // 개인 맞춤 추천 활동
                  if (widget.personalActions != null && widget.personalActions!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark 
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 추천 활동',
                            style: TextStyle(
                              color: isDark 
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FortuneInfographicWidgets.buildActionChecklist(widget.personalActions, isDarkMode: isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // 공유용 카드
                  if (widget.shareCard != null) ...[
                    FortuneInfographicWidgets.buildShareableCard(widget.shareCard),
                    const SizedBox(height: 32),
                  ],
                  
                  // 24시간 타임라인 차트
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark 
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : const Color(0xFF3B82F6).withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6)).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.schedule_rounded,
                                color: isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '24시간 운세 흐름',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FortuneInfographicWidgets.buildTimelineChart(
                          hourlyScores: hourlyScores,
                          currentHour: DateTime.now().hour,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // AI 인사이트 카드 (동적 데이터 사용)
                  FortuneInfographicWidgets.buildAIInsightsCard(
                    insight: widget.fortune?.metadata?['ai_insight'] ?? _generateAIInsight(widget.fortune),
                    tips: (widget.fortune?.metadata?['ai_tips'] as List?)?.cast<String>() ?? _generateTips(widget.fortune),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Lucky Items Grid (사주 데이터가 없을 때)
                  if (widget.sajuInsight == null && widget.fortune?.luckyItems != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark 
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : const Color(0xFF3B82F6).withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.stars_rounded,
                                  color: isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '오늘의 행운 아이템',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FortuneInfographicWidgets.buildLuckyItemsGrid(
                            luckyItems: Map<String, String>.from(
                              widget.fortune!.luckyItems!.map((key, value) => 
                                MapEntry(key, value.toString())
                              )
                            ),
                            itemSize: 100,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Mini Statistics Dashboard
                  FortuneInfographicWidgets.buildMiniStatsDashboard(
                    stats: userStats,
                    context: context,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 오늘의 키워드 (항상 표시)
                  if (keywords.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark 
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? const Color(0xFF6366F1).withOpacity(0.05)
                              : const Color(0xFF3B82F6).withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.tag_rounded,
                                  color: isDark ? const Color(0xFF6366F1) : const Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '오늘의 키워드',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FortuneInfographicWidgets.buildKeywordCloud(
                            keywords: keywords,
                            importance: keywordWeights,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // 태어난 날 유명인 (동적 데이터 사용)
                  if (widget.fortune?.metadata?['celebrities_same_day'] != null) ...[
                    Builder(
                      builder: (context) {
                        final birthDate = widget.userProfile?.birthdate;
                        final month = birthDate?.month ?? 8;
                        final day = birthDate?.day ?? 18;
                        final celebrities = (widget.fortune!.metadata!['celebrities_same_day'] as List?)
                            ?.map((e) => (e as Map<String, dynamic>).cast<String, String>())
                            .toList() ?? <Map<String, String>>[];
                        
                        return FortuneInfographicWidgets.buildTossStyleCelebrityList(
                          title: '${month}월 ${day}일 태어난 유명인',
                          subtitle: '',
                          celebrities: celebrities,
                        );
                      },
                    ),
                  ] else ...[
                    // 폴백 - 기존 하드코딩 데이터
                    FortuneInfographicWidgets.buildTossStyleCelebrityList(
                      title: '8월 18일 태어난 유명인',
                      subtitle: '',
                      celebrities: [
                        {
                          'year': '1999',
                          'name': '주이 (모모랜드)',
                          'description': '대한민국의 가수',
                        },
                        {
                          'year': '1993',
                          'name': '정은지(에이핑크)',
                          'description': '대한민국의 가수',
                        },
                        {
                          'year': '1988',
                          'name': '지드래곤(빅뱅)',
                          'description': '대한민국의 가수',
                        },
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // 비슷한 사주의 연예인 (동적 데이터 사용)
                  if (widget.fortune?.metadata?['celebrities_similar_saju'] != null) ...[
                    FortuneInfographicWidgets.buildTossStyleCelebrityList(
                      title: '비슷한 사주의 연예인',
                      subtitle: '',
                      celebrities: (widget.fortune!.metadata!['celebrities_similar_saju'] as List?)
                          ?.map((e) => (e as Map<String, dynamic>).cast<String, String>())
                          .toList() ?? <Map<String, String>>[],
                    ),
                  ] else ...[
                    // 폴백 - 기존 하드코딩 데이터
                    FortuneInfographicWidgets.buildTossStyleCelebrityList(
                      title: '비슷한 사주의 연예인',
                      subtitle: '',
                      celebrities: [
                        {
                          'year': '',
                          'name': '박찬석',
                          'description': '대한민국의 정치인',
                        },
                        {
                          'year': '',
                          'name': '누리 사헌',
                          'description': '터키의 축구 선수',
                        },
                        {
                          'year': '',
                          'name': '펠리페 카이세도',
                          'description': '에콰도르의 축구 선수',
                        },
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // 사용자 년생 운세 (동적 데이터 사용)
                  if (widget.userProfile?.birthdate != null) ...[
                    Builder(
                      builder: (context) {
                        final birthYear = widget.userProfile!.birthdate!.year;
                        final birthYearSuffix = '${birthYear.toString().substring(2)}년생';
                        
                        // Edge Function에서 제공하는 년생별 운세 데이터 사용
                        final ageFortuneData = widget.fortune?.metadata?['age_fortune'] ?? _getAgeFortuneData(birthYear);
                        
                        return SizedBox(
                          width: double.infinity,
                          child: FortuneInfographicWidgets.buildTossStyleAgeFortuneCard(
                            ageGroup: birthYearSuffix,
                            title: ageFortuneData['title'] ?? '노력한 만큼의 성과를 올릴 수가 있다',
                            description: ageFortuneData['description'] ?? '하는 만큼 부가 쌓이는 때입니다. 책을 읽으며 지식을 쌓아도 좋겠습니다.',
                            zodiacAnimal: widget.userProfile?.zodiacAnimal ?? '용',
                          ),
                        );
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // 공유 섹션 (동적 카운트 사용)
                  FortuneInfographicWidgets.buildTossStyleShareSection(
                    shareCount: widget.fortune?.metadata?['share_count']?.toString() ?? '2,753,170',
                    onShare: () {
                      // TODO: 공유 기능 구현
                    },
                    onSave: () {
                      // TODO: 저장 기능 구현  
                    },
                    onReview: () {
                      // TODO: 다시보기 기능 구현
                      if (widget.onReplay != null) {
                        widget.onReplay!();
                      }
                    },
                    onOtherFortune: () {
                      // TODO: 다른 운세 보기 구현
                      context.go('/');
                    },
                  ),
                  
                  // Radar Chart for categories (fallback for legacy data)
                  if (widget.categories == null && widget.fortune?.scoreBreakdown != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark 
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '카테고리별 운세',
                            style: TextStyle(
                              color: isDark 
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FortuneInfographicWidgets.buildRadarChart(
                            scores: {
                              '연애': widget.fortune!.scoreBreakdown!['love'] ?? 75,
                              '직장': widget.fortune!.scoreBreakdown!['career'] ?? 75,
                              '금전': widget.fortune!.scoreBreakdown!['money'] ?? 75,
                              '건강': widget.fortune!.scoreBreakdown!['health'] ?? 75,
                              '대인': widget.fortune!.scoreBreakdown!['relationship'] ?? 75,
                              '행운': widget.fortune!.scoreBreakdown!['luck'] ?? 75,
                            },
                            size: 180,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // 오행 균형 차트
                  if (widget.sajuAnalysis != null && widget.sajuAnalysis!['오행'] != null) ...[
                    _buildElementBalance(widget.sajuAnalysis!['오행'] as Map<String, dynamic>),
                    const SizedBox(height: 32),
                  ],
                  
                  // 사주 정보 카드
                  if (widget.sajuAnalysis != null) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300, // 최대 높이 제한
                      ),
                      child: SingleChildScrollView(
                        child: _buildSajuInfoCard(context, widget.sajuAnalysis!),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStarRating(int score) {
    final stars = (score / 20).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        ).animate()
          .fadeIn(duration: 200.ms, delay: Duration(milliseconds: 300 + (index * 50)))
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1));
      }),
    );
  }
  
  String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 날! 무엇이든 도전하세요';
    if (score >= 80) return '행운이 가득한 하루입니다';
    if (score >= 70) return '안정적이고 평온한 하루';
    if (score >= 60) return '차분하게 보내면 좋은 날';
    return '조심스럽게 행동하세요';
  }
  
  Widget _buildHexagonChart(Map<String, dynamic> scoreBreakdown) {
    // 육각형 차트용 데이터 준비 (6개 항목)
    final hexagonData = <String, int>{
      '연애': scoreBreakdown['love'] ?? 75,
      '직장': scoreBreakdown['career'] ?? 75,
      '금전': scoreBreakdown['money'] ?? 75,
      '건강': scoreBreakdown['health'] ?? 75,
      '대인': scoreBreakdown['relationship'] ?? 75,
      '행운': scoreBreakdown['luck'] ?? 75,
    };
    
    return Column(
      children: [
        Text(
          '오늘의 운세 분석',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: HexagonChart(
            scores: hexagonData,
            size: 180,
            primaryColor: Colors.cyan,
            showValues: true,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ],
    );
  }
  
  Widget _buildElementBalance(Map<String, dynamic> elements) {
    // 오행 데이터를 0~1 범위로 정규화
    final total = elements.values.fold<num>(0, (sum, value) => sum + (value as num));
    final normalizedElements = <String, double>{};
    
    elements.forEach((key, value) {
      normalizedElements[key] = total > 0 ? (value as num) / total : 0.2;
    });
    
    return Column(
      children: [
        Text(
          '오행 균형',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElementBalanceChart(
            elements: normalizedElements,
            size: 180,
            showPercentage: true,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 250.ms)
          .slideY(begin: 0.1, end: 0),
      ],
    );
  }
  
  Widget _buildSajuInfoCard(BuildContext context, Map<String, dynamic> saju) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '사주팔자',
                style: TextStyle(
                  color: isDark 
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (saju['간지'] != null)
            _buildSajuItem(context, '간지', saju['간지'].toString()),
          if (saju['천간'] != null)
            _buildSajuItem(context, '천간', saju['천간'].toString()),
          if (saju['지지'] != null)
            _buildSajuItem(context, '지지', saju['지지'].toString()),
          if (saju['부족한오행'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '부족한 오행: ${saju['부족한오행']}',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (saju['보충방법'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      saju['보충방법'].toString(),
                      style: TextStyle(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 350.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildSajuItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.black.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLuckyItems(Map<String, dynamic> luckyItems) {
    final items = <Widget>[];
    
    if (luckyItems['color'] != null) {
      items.add(_buildLuckyItem('색상', luckyItems['color'], Icons.palette));
    }
    if (luckyItems['number'] != null) {
      items.add(_buildLuckyItem('숫자', luckyItems['number'].toString(), Icons.looks_one));
    }
    if (luckyItems['time'] != null) {
      items.add(_buildLuckyItem('시간', luckyItems['time'], Icons.access_time));
    }
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '오늘의 행운',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 350.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildLuckyItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFortuneMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF1a1a2e)
            : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '다른 운세 보기',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(context, '연애운', Icons.favorite, '/fortune/love'),
            _buildMenuItem(context, '직장운', Icons.work, '/fortune/career'),
            _buildMenuItem(context, '금전운', Icons.attach_money, '/fortune/wealth'),
            _buildMenuItem(context, '건강운', Icons.favorite_border, '/fortune/health'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isDark 
          ? Colors.white.withValues(alpha: 0.8)
          : Colors.black.withValues(alpha: 0.7)
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        color: isDark 
          ? Colors.white.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3), 
        size: 16
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  /// Extract keywords from fortune data
  List<String> _extractKeywords(fortune_entity.Fortune? fortune) {
    if (fortune == null) return ['행운', '성공', '기회'];
    
    final keywords = <String>[];
    
    // Extract from content (main fortune text)
    if (fortune.content != null && fortune.content!.isNotEmpty) {
      final fortuneKeywords = [
        '행운', '성공', '기회', '발전', '성취', '만남', '도전', '성장', '번영', '희망',
        '사랑', '연애', '건강', '직업', '금전', '재물', '가족', '친구', '여행', '학업',
        '창조', '예술', '소통', '협력', '리더십', '변화', '안정', '평화', '조화', '균형'
      ];
      
      final content = fortune.content!;
      for (final keyword in fortuneKeywords) {
        if (content.contains(keyword)) {
          keywords.add(keyword);
        }
      }
    }
    
    // Extract from description
    if (fortune.description != null && fortune.description!.isNotEmpty) {
      final positiveKeywords = ['긍정', '신뢰', '진실', '용기', '지혜', '인내', '배려', '감사'];
      final description = fortune.description!;
      
      for (final keyword in positiveKeywords) {
        if (description.contains(keyword)) {
          keywords.add(keyword);
        }
      }
    }
    
    // Extract from recommendations
    if (fortune.recommendations != null) {
      for (final rec in fortune.recommendations!) {
        if (rec.contains('적극')) keywords.add('적극성');
        if (rec.contains('신중')) keywords.add('신중함');
        if (rec.contains('소통')) keywords.add('소통');
        if (rec.contains('건강')) keywords.add('건강관리');
        if (rec.contains('투자')) keywords.add('투자');
        if (rec.contains('관계')) keywords.add('인간관계');
        if (rec.contains('휴식')) keywords.add('휴식');
        if (rec.contains('계획')) keywords.add('계획성');
      }
    }
    
    // Add score-based keywords
    final score = fortune.overallScore ?? 75;
    if (score >= 90) {
      keywords.addAll(['최고운', '대길', '번영']);
    } else if (score >= 80) {
      keywords.addAll(['좋은운', '발전', '성공']);
    } else if (score >= 70) {
      keywords.addAll(['안정', '평온', '균형']);
    } else if (score >= 60) {
      keywords.addAll(['신중', '조심', '준비']);
    } else {
      keywords.addAll(['인내', '극복', '변화']);
    }
    
    // Add category-based keywords from score breakdown
    final scoreBreakdown = fortune.scoreBreakdown ?? {};
    scoreBreakdown.forEach((category, score) {
      if (score is int && score >= 80) {
        switch (category) {
          case 'love':
            keywords.add('연애운');
            break;
          case 'career':
            keywords.add('직업운');
            break;
          case 'money':
            keywords.add('금전운');
            break;
          case 'health':
            keywords.add('건강운');
            break;
          case 'relationship':
            keywords.add('대인운');
            break;
          case 'luck':
            keywords.add('행운');
            break;
        }
      }
    });
    
    // Remove duplicates and return top 6
    final uniqueKeywords = keywords.toSet().toList();
    return uniqueKeywords.take(6).toList();
  }

  /// Calculate keyword importance weights
  List<double> _calculateKeywordWeights(List<String> keywords) {
    return keywords.asMap().entries.map((entry) {
      final index = entry.key;
      final keyword = entry.value;
      
      // Higher weight for first keywords and specific important ones
      double baseWeight = 1.0 - (index * 0.15);
      
      // Boost weight for specific keywords
      if (['행운', '성공', '최고운', '대길'].contains(keyword)) {
        baseWeight += 0.2;
      }
      
      return (baseWeight).clamp(0.3, 1.0);
    }).toList();
  }

  /// Generate hourly scores based on fortune data
  List<int> _generateHourlyScores(fortune_entity.Fortune? fortune) {
    if (fortune == null) {
      return List.generate(24, (i) => 50 + (i % 3) * 15);
    }
    
    final baseScore = fortune.overallScore ?? 75;
    final scoreBreakdown = fortune.scoreBreakdown ?? {};
    final scores = <int>[];
    
    for (int hour = 0; hour < 24; hour++) {
      int hourScore = baseScore;
      
      // 시간대별 기본 패턴
      if (hour >= 6 && hour <= 9) {
        // 아침 시간 - 건강운과 연관
        final healthBonus = (scoreBreakdown['health'] ?? 75) > 75 ? 8 : -2;
        hourScore += 5 + healthBonus;
      } else if (hour >= 10 && hour <= 12) {
        // 오전 업무 시간 - 직업운과 연관
        final careerBonus = (scoreBreakdown['career'] ?? 75) > 75 ? 10 : 0;
        hourScore += 8 + careerBonus;
      } else if (hour >= 13 && hour <= 17) {
        // 오후 업무 시간 - 직업운과 금전운 연관
        final careerBonus = (scoreBreakdown['career'] ?? 75) > 75 ? 5 : -3;
        final moneyBonus = (scoreBreakdown['money'] ?? 75) > 80 ? 5 : 0;
        hourScore += 3 + careerBonus + moneyBonus;
      } else if (hour >= 18 && hour <= 21) {
        // 저녁 사교 시간 - 대인운과 연애운 연관
        final relationshipBonus = (scoreBreakdown['relationship'] ?? 75) > 75 ? 7 : 0;
        final loveBonus = (scoreBreakdown['love'] ?? 75) > 80 ? 8 : 2;
        hourScore += 5 + relationshipBonus + loveBonus;
      } else if (hour >= 22 || hour <= 5) {
        // 밤/새벽 휴식 시간 - 전반적으로 낮음
        hourScore -= 8;
        if (hour >= 0 && hour <= 2) {
          hourScore -= 5; // 자정 이후 더 낮음
        }
      }
      
      // 행운 점수에 따른 전체적인 조정
      final luckScore = scoreBreakdown['luck'] ?? 75;
      if (luckScore > 85) {
        hourScore += 5;
      } else if (luckScore < 60) {
        hourScore -= 3;
      }
      
      // 전체 점수에 따른 변동폭 조정
      final variation = math.Random(hour + baseScore).nextInt(8) - 4;
      hourScore += variation;
      
      // 현재 시간 주변에서 더 정확한 예측 (±2시간)
      final currentHour = DateTime.now().hour;
      final hourDiff = (hour - currentHour).abs();
      if (hourDiff <= 2) {
        // 현재 시간 근처는 더 안정적
        hourScore = (hourScore * 0.7 + baseScore * 0.3).round();
      }
      
      scores.add(hourScore.clamp(20, 100));
    }
    
    return scores;
  }

  /// Calculate user statistics using actual user data
  Map<String, dynamic> _calculateUserStats(fortune_entity.Fortune? fortune, AsyncValue<List<dynamic>> historyAsync) {
    final currentScore = fortune?.overallScore ?? 75;
    
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return {
            'streak': 1,
            'average': currentScore,
            'highest': currentScore,
          };
        }
        
        return {
          'streak': _calculateStreakFromHistory(history),
          'average': _calculateAverageFromHistory(history, currentScore),
          'highest': _calculateHighestFromHistory(history, currentScore),
        };
      },
      loading: () => {
        'streak': 1,
        'average': currentScore,
        'highest': currentScore,
      },
      error: (_, __) => {
        'streak': 1,
        'average': currentScore,
        'highest': currentScore,
      },
    );
  }

  /// Calculate consecutive days of fortune reading
  int _calculateStreakFromHistory(List<dynamic> history) {
    if (history.isEmpty) return 1;
    
    // Sort by creation date (newest first)
    final sortedHistory = List.from(history)
      ..sort((a, b) => DateTime.parse(b.createdAt.toString())
          .compareTo(DateTime.parse(a.createdAt.toString())));
    
    int streak = 1; // Today counts as 1
    final today = DateTime.now();
    
    for (int i = 0; i < sortedHistory.length; i++) {
      final historyDate = DateTime.parse(sortedHistory[i].createdAt.toString());
      final expectedDate = today.subtract(Duration(days: i + 1));
      
      // Check if this entry is from the expected consecutive day
      if (historyDate.year == expectedDate.year &&
          historyDate.month == expectedDate.month &&
          historyDate.day == expectedDate.day) {
        streak++;
      } else {
        break; // Streak is broken
      }
    }
    
    return math.min(streak, 30); // Cap at 30 days
  }

  /// Calculate average score from history
  int _calculateAverageFromHistory(List<dynamic> history, int currentScore) {
    if (history.isEmpty) return currentScore;
    
    final scores = <int>[];
    scores.add(currentScore); // Include today's score
    
    for (final item in history) {
      final summary = item.summary as Map<String, dynamic>?;
      if (summary != null && summary['overall_score'] != null) {
        final score = summary['overall_score'];
        if (score is int) {
          scores.add(score);
        } else if (score is double) {
          scores.add(score.round());
        } else if (score is String) {
          final parsed = int.tryParse(score);
          if (parsed != null) scores.add(parsed);
        }
      }
    }
    
    if (scores.isEmpty) return currentScore;
    
    final sum = scores.reduce((a, b) => a + b);
    return (sum / scores.length).round();
  }

  /// Calculate highest score from history
  int _calculateHighestFromHistory(List<dynamic> history, int currentScore) {
    int highest = currentScore;
    
    for (final item in history) {
      final summary = item.summary as Map<String, dynamic>?;
      if (summary != null && summary['overall_score'] != null) {
        final score = summary['overall_score'];
        int scoreValue = currentScore;
        
        if (score is int) {
          scoreValue = score;
        } else if (score is double) {
          scoreValue = score.round();
        } else if (score is String) {
          scoreValue = int.tryParse(score) ?? currentScore;
        }
        
        highest = math.max(highest, scoreValue);
      }
    }
    
    return highest;
  }

  /// Generate AI insight based on fortune data
  String _generateAIInsight(fortune_entity.Fortune? fortune) {
    if (fortune == null) {
      return '오늘은 새로운 시작을 위한 좋은 날입니다. 긍정적인 마음으로 하루를 시작해보세요.';
    }
    
    final score = fortune.overallScore ?? 75;
    final scoreBreakdown = fortune.scoreBreakdown ?? {};
    
    if (score >= 90) {
      return '오늘은 정말 특별한 날입니다! 모든 일이 순조롭게 풀릴 것이니 적극적으로 도전해보세요.';
    } else if (score >= 80) {
      final highCategory = _getHighestCategory(scoreBreakdown);
      return '오늘은 특히 $highCategory 방면에서 좋은 기운이 흐르고 있습니다. 이 기회를 놓치지 마세요.';
    } else if (score >= 70) {
      return '안정적이고 평온한 하루가 될 것입니다. 꾸준히 노력한다면 좋은 결과를 얻을 수 있어요.';
    } else if (score >= 60) {
      return '신중하게 행동한다면 무난한 하루를 보낼 수 있습니다. 급하지 않은 결정은 미뤄두세요.';
    } else {
      return '조금 어려운 시기이지만 인내심을 갖고 차근차근 해나간다면 분명 좋은 결과가 있을 것입니다.';
    }
  }

  /// Generate tips based on fortune data
  List<String> _generateTips(fortune_entity.Fortune? fortune) {
    if (fortune == null) {
      return [
        '긍정적인 마음가짐을 유지하세요',
        '새로운 기회에 열린 자세를 가지세요',
        '건강한 생활습관을 실천하세요',
      ];
    }
    
    final tips = <String>[];
    final score = fortune.overallScore ?? 75;
    final scoreBreakdown = fortune.scoreBreakdown ?? {};
    
    // Score-based tips
    if (score >= 80) {
      tips.add('오전 시간대에 중요한 결정을 내리세요');
      tips.add('새로운 사람들과의 만남을 소중히 하세요');
    } else if (score >= 60) {
      tips.add('무리하지 말고 차근차근 진행하세요');
      tips.add('주변 사람들의 조언에 귀 기울이세요');
    } else {
      tips.add('휴식을 취하며 재충전의 시간을 가지세요');
      tips.add('작은 성취에도 감사하는 마음을 가지세요');
    }
    
    // Category-based tips
    final lowCategory = _getLowestCategory(scoreBreakdown);
    if (lowCategory.isNotEmpty) {
      switch (lowCategory) {
        case '건강':
          tips.add('충분한 수면과 휴식을 취하세요');
          break;
        case '금전':
          tips.add('불필요한 지출을 줄이고 저축에 신경쓰세요');
          break;
        case '연애':
          tips.add('상대방의 마음을 헤아리는 시간을 가지세요');
          break;
        case '직장':
          tips.add('업무에 집중하고 동료들과 원활한 소통을 하세요');
          break;
      }
    }
    
    return tips.take(3).toList();
  }

  String _getHighestCategory(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) return '전반적인';
    
    var maxScore = 0;
    var maxCategory = '전반적인';
    
    breakdown.forEach((key, value) {
      if (value is int && value > maxScore) {
        maxScore = value;
        maxCategory = _translateCategory(key);
      }
    });
    
    return maxCategory;
  }

  String _getLowestCategory(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) return '';
    
    var minScore = 100;
    var minCategory = '';
    
    breakdown.forEach((key, value) {
      if (value is int && value < minScore) {
        minScore = value;
        minCategory = _translateCategory(key);
      }
    });
    
    return minCategory;
  }

  String _translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'love': return '연애';
      case 'career': return '직장';
      case 'money': return '금전';
      case 'health': return '건강';
      case 'relationship': return '대인관계';
      case 'luck': return '행운';
      default: return category;
    }
  }

  /// 년생별 운세 데이터 가져오기
  Map<String, String> _getAgeFortuneData(int birthYear) {
    // 년생별로 다른 운세 제공 (기본 데이터)
    final yearLastTwoDigits = birthYear % 100;
    
    if (yearLastTwoDigits >= 80 && yearLastTwoDigits <= 89) {
      return {
        'title': '노력한 만큼의 성과를 올릴 수가 있다',
        'description': '하는 만큼 부가 쌓이는 때입니다. 책을 읽으며 지식을 쌓아도 좋겠습니다. 언젠가 하고 싶었던 일의 기회도 생길 수 있습니다 좋은 성과로 주변 평판도 오를 것입니다.',
      };
    } else if (yearLastTwoDigits >= 90 && yearLastTwoDigits <= 99) {
      return {
        'title': '안정적인 발전이 기대되는 시기',
        'description': '차근차근 계획을 세워 나아가면 좋은 결과를 얻을 수 있습니다. 주변의 조언에 귀 기울이며 신중하게 행동하세요.',
      };
    } else if (yearLastTwoDigits >= 0 && yearLastTwoDigits <= 9) {
      return {
        'title': '욕심이 커지는 것에 주의해라',
        'description': '욕심이 앞서면 구설수에 오를 수 있는 날입니다. 당신을 지켜보는 눈이 많습니다. 욕심으로 가식적인 모습을 보일 수 있었습니다. 상대방에게 거북할 수 있으니 주의를 기울이세요.',
      };
    } else {
      return {
        'title': '새로운 시작을 위한 준비의 시간',
        'description': '변화의 바람이 불고 있습니다. 새로운 도전을 위해 마음의 준비를 하고 기회를 놓치지 마세요.',
      };
    }
  }
}