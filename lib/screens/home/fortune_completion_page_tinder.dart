import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../presentation/widgets/fortune_infographic_widgets.dart';
import '../../presentation/providers/navigation_visibility_provider.dart';
import '../../presentation/providers/celebrity_saju_provider.dart';

/// 틴더 스타일 카드 기반 운세 완료 페이지
class FortuneCompletionPageTinder extends ConsumerStatefulWidget {
  final fortune_entity.Fortune? fortune;
  final String? userName;
  final UserProfile? userProfile;
  final Map<String, dynamic>? overall;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? sajuInsight;

  const FortuneCompletionPageTinder({
    super.key,
    this.fortune,
    this.userName,
    this.userProfile,
    this.overall,
    this.categories,
    this.sajuInsight,
  });

  @override
  ConsumerState<FortuneCompletionPageTinder> createState() => _FortuneCompletionPageTinderState();
}

class _FortuneCompletionPageTinderState extends ConsumerState<FortuneCompletionPageTinder> {
  late PageController _pageController;
  int _currentPage = 0;

  // totalScore getter - widget.fortune?.overallScore를 반환
  int get totalScore => widget.fortune?.overallScore ?? 75;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);

    // 네비게이션 바 항상 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayUserName = widget.userName ?? widget.userProfile?.name ?? '회원';
    final score = widget.fortune?.overallScore ?? 75;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // PageView (틴더 카드 스타일) - MainShell이 padding 처리하므로 bottom 제거
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: 18,
              itemBuilder: (context, index) {
                return _buildFullSizeCard(
                  context,
                  index,
                  score,
                  isDark,
                  displayUserName,
                );
              },
            ),
          ),

          // 프로그레스 바 (맨 위)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentPage + 1) / 18,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3182F6),
                        Color(0xFF1B64DA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // 고정 헤더 (이름 · 날짜)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayUserName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 풀사이즈 카드 빌더 (스크린샷 스타일)
  Widget _buildFullSizeCard(
    BuildContext context,
    int index,
    int score,
    bool isDark,
    String displayUserName,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: double.infinity,
      margin: EdgeInsets.fromLTRB(20, topPadding + 60, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // 카드 컨텐츠 (스크롤 비활성화 - PageView가 제스처 처리)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                physics: const NeverScrollableScrollPhysics(),
                child: _buildCardContent(
                  context,
                  index,
                  score,
                  isDark,
                  displayUserName,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카드 내용 빌더 (10가지 카드)
  Widget _buildCardContent(
    BuildContext context,
    int index,
    int score,
    bool isDark,
    String displayUserName,
  ) {
    switch (index) {
      case 0: // 📊 총운 카드
        return _buildOverallCard(score, isDark, displayUserName);

      case 1: // 🌤️ 오늘의 날씨 연계 운세 (총운 바로 다음으로 이동)
        return _buildWeatherFortuneCard(isDark);

      case 2: // 📈 5대 영역 레이더
        return _buildRadarCard(score, isDark);

      case 3: // ⏰ 시간대별 조언
        return _buildTimeSlotCard(isDark);

      case 4: // ❤️ 연애운
        return _buildCategoryDetailCard('연애운', 'love', score, isDark);

      case 5: // 💰 금전운
        return _buildCategoryDetailCard('금전운', 'money', score, isDark);

      case 6: // 💼 직장운
        return _buildCategoryDetailCard('직장운', 'work', score, isDark);

      case 7: // 📚 학업운
        return _buildCategoryDetailCard('학업운', 'study', score, isDark);

      case 8: // 🏃 건강운
        return _buildCategoryDetailCard('건강운', 'health', score, isDark);

      case 9: // ✨ 행운 아이템
        return _buildLuckyItemsCard(isDark);

      case 10: // 🎭 유사 사주 연예인
        return _buildCelebrityCard(isDark);

      case 11: // 🔮 사주 인사이트
        return _buildSajuInsightCard(isDark);

      case 12: // 🎯 오늘의 액션 플랜
        return _buildActionPlanCard(isDark);

      case 13: // 🌊 오행 밸런스
        return _buildFiveElementsCard(isDark);

      case 14: // ⏱️ 시간대별 점수 그래프
        return _buildHourlyScoreGraphCard(isDark);

      case 15: // 🐉 띠별 운세
        return _buildZodiacFortuneCard(isDark);

      case 16: // 💫 주간 트렌드
        return _buildWeeklyTrendCard(isDark);

      case 17: // 🎁 공유 카드
        return _buildShareCard(isDark);

      default:
        return const SizedBox.shrink();
    }
  }

  /// 📊 총운 카드 - ChatGPT Pulse 스타일
  Widget _buildOverallCard(int score, bool isDark, String displayUserName) {
    final message = _getMainScoreMessage(score);
    final subtitle = _getMainScoreSubtitle();
    final fullDescription = _getFullFortuneDescription(score);
    final scoreColor = _getPulseScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (작고 명확)
        Text(
          '$displayUserName님의',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘의 총운',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 24),

        // 카드 컨테이너 (Pulse 스타일 - 흰색 배경 + 그림자)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 점수 - 매우 얇은 타이포그래피
              Text(
                '$score',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 88,
                  fontWeight: FontWeight.w100,
                  letterSpacing: -5,
                  height: 1.0,
                ),
              ).animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9), duration: 500.ms, curve: Curves.easeOut),

              const SizedBox(height: 6),

              // 서브텍스트 (미세하게)
              Text(
                'POINTS',
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.35),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ).animate()
                .fadeIn(duration: 500.ms, delay: 150.ms),

              const SizedBox(height: 28),

              // 프로그레스 바 (얇고 심플)
              Stack(
                children: [
                  // 배경 바
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  // 진행 바 (단색)
                  FractionallySizedBox(
                    widthFactor: score / 100,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ).animate()
                      .scaleX(
                        begin: 0,
                        duration: 1000.ms,
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerLeft,
                      ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // 메시지 카드 (사자성어)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scoreColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 300.ms)
          .slideY(begin: 0.06, duration: 500.ms, delay: 300.ms, curve: Curves.easeOut),

        const SizedBox(height: 12),

        // 300자 상세 설명 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            fullDescription,
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: -0.2,
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 400.ms)
          .slideY(begin: 0.06, duration: 500.ms, delay: 400.ms, curve: Curves.easeOut),
      ],
    );
  }

  /// 📈 5대 영역 레이더 카드 - ChatGPT Pulse 스타일
  Widget _buildRadarCard(int score, bool isDark) {
    final radarData = _getRadarChartDataDouble(score);

    // 각 영역의 평균 색상 계산
    final avgScore = radarData.values.reduce((a, b) => a + b) / radarData.length;
    final cardColor = _getPulseScoreColor(avgScore.round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '5대 영역별 운세',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '오늘의 각 분야별 운세를 한눈에',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // 카드 컨테이너 (Pulse 스타일)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 레이더 차트
              SizedBox(
                height: 240,
                child: FortuneInfographicWidgets.buildRadarChart(
                  scores: radarData.map((k, v) => MapEntry(k, v.round())),
                  size: 240,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 20),

              // 영역별 점수 리스트 (심플하게)
              ...radarData.entries.map((entry) {
                final areaColor = _getPulseScoreColor(entry.value.round());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // 영역 이름
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // 프로그레스 바
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            // 배경
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            // 진행
                            FractionallySizedBox(
                              widthFactor: entry.value / 100,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: areaColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ).animate()
                                .scaleX(
                                  begin: 0,
                                  duration: 800.ms,
                                  delay: 200.ms,
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment.centerLeft,
                                ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 점수
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${entry.value.round()}',
                          style: TextStyle(
                            color: areaColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }

  /// ⏰ 시간대별 조언 카드 - ChatGPT Pulse 스타일
  Widget _buildTimeSlotCard(bool isDark) {
    final timeSlots = _getTimeSlotAdvice();

    final now = DateTime.now();
    final currentHour = now.hour;
    String currentTimeSlot = 'morning';
    if (currentHour >= 12 && currentHour < 18) {
      currentTimeSlot = 'afternoon';
    } else if (currentHour >= 18 || currentHour < 6) {
      currentTimeSlot = 'evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '시간대별 조언',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '오늘 하루를 시간대별로 준비하세요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // 오전
        if (timeSlots['morning']!.isNotEmpty)
          _buildTimeSlotItem(
            Icons.wb_sunny_rounded,
            '오전 (6시-12시)',
            timeSlots['morning']!,
            currentTimeSlot == 'morning',
            isDark,
          ),

        if (timeSlots['morning']!.isNotEmpty && timeSlots['afternoon']!.isNotEmpty)
          const SizedBox(height: 12),

        // 오후
        if (timeSlots['afternoon']!.isNotEmpty)
          _buildTimeSlotItem(
            Icons.wb_cloudy_rounded,
            '오후 (12시-18시)',
            timeSlots['afternoon']!,
            currentTimeSlot == 'afternoon',
            isDark,
          ),

        if (timeSlots['afternoon']!.isNotEmpty && timeSlots['evening']!.isNotEmpty)
          const SizedBox(height: 12),

        // 저녁
        if (timeSlots['evening']!.isNotEmpty)
          _buildTimeSlotItem(
            Icons.nightlight_round,
            '저녁 (18시-자정)',
            timeSlots['evening']!,
            currentTimeSlot == 'evening',
            isDark,
          ),
      ],
    );
  }

  Widget _buildTimeSlotItem(
    IconData icon,
    String title,
    String advice,
    bool isActive,
    bool isDark,
  ) {
    final accentColor = const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: accentColor.withOpacity(0.3), width: 1.5)
            : Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 (Pulse 스타일)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? accentColor.withOpacity(0.1)
                  : (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? accentColor.withOpacity(0.2)
                    : (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? accentColor : (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              size: 20,
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
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '지금',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  advice,
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❤️ 카테고리 상세 카드 (연애/금전/직장/학업/건강)
  Widget _buildCategoryDetailCard(String title, String categoryKey, int baseScore, bool isDark) {
    final categoryData = _getCategoryData(categoryKey, baseScore);
    final score = categoryData['score'] as int;
    final advice = categoryData['advice'] as String;
    final emoji = _getCategoryEmoji(categoryKey);
    final scoreColor = _getPulseScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 카드 (Pulse 스타일)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 점수 표시
              Row(
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 48,
                      fontWeight: FontWeight.w200,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '점',
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 프로그레스 바
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: score / 100,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ).animate()
                      .scaleX(begin: 0, duration: 800.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 조언 텍스트
              Text(
                advice,
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }

  /// ✨ 행운 아이템 카드 - ChatGPT Pulse 스타일
  Widget _buildLuckyItemsCard(bool isDark) {
    final luckyItems = _getLuckyItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '오늘의 행운 아이템',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '오늘 행운을 불러올 아이템들',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // 행운 아이템 그리드 (Pulse 스타일) - LayoutBuilder로 정확한 너비 계산
        LayoutBuilder(
          builder: (context, constraints) {
            // 사용 가능한 전체 너비
            final availableWidth = constraints.maxWidth;
            // 2열 그리드: (전체 너비 - 중간 간격) / 2
            final itemWidth = (availableWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: luckyItems.entries.map((entry) {
                return Container(
                  width: itemWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOut);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// 🎭 유사 사주 연예인 카드 - ChatGPT Pulse 스타일
  Widget _buildCelebrityCard(bool isDark) {
    final celebrities = ref.watch(randomCelebritiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '나와 비슷한 사주',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '유명인과의 사주 궁합',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        celebrities.when(
          data: (celebList) {
            if (celebList.isEmpty) {
              return _buildFallbackCelebrityCards(isDark);
            }

            return Column(
              children: celebList.take(3).map((celeb) {
                final random = math.Random();
                final matchScore = 70 + random.nextInt(30);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCelebrityCardItem(
                    name: celeb.name,
                    matchScore: matchScore,
                    description: '사주 오행의 균형이 비슷합니다',
                    isDark: isDark,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildFallbackCelebrityCards(isDark),
        ),
      ],
    );
  }

  Widget _buildCelebrityCardItem({
    required String name,
    required int matchScore,
    required String description,
    required bool isDark,
  }) {
    final scoreColor = _getPulseScoreColor(matchScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아바타 (심플하게)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: scoreColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // 일치도 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: scoreColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$matchScore%',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.05, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildFallbackCelebrityCards(bool isDark) {
    final fallbackCelebrities = [
      {'name': '아이유', 'match': 85, 'description': '창의적이고 감성적인 성향이 비슷합니다'},
      {'name': '박서준', 'match': 78, 'description': '리더십과 추진력이 유사합니다'},
      {'name': '김고은', 'match': 72, 'description': '예술적 감각이 닮았습니다'},
    ];

    return Column(
      children: fallbackCelebrities.map((celeb) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCelebrityCardItem(
            name: celeb['name'] as String,
            matchScore: celeb['match'] as int,
            description: celeb['description'] as String,
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }

  /// 빈 카드
  Widget _buildEmptyCard(String message, bool isDark) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.white60 : Colors.black54,
          fontSize: 16,
        ),
      ),
    );
  }

  // ========== Helper Functions ==========

  String _getMainScoreMessage(int score) {
    final idiom = widget.fortune?.metadata?['categories']?['total']?['advice']?['idiom'];
    if (idiom != null && idiom.toString().isNotEmpty) {
      return idiom.toString();
    }
    return _getScoreIdiom(score);
  }

  String? _getMainScoreSubtitle() {
    final description = widget.fortune?.metadata?['categories']?['total']?['advice']?['description'];
    return description?.toString();
  }

  /// 총운 300자 상세 설명 가져오기
  String _getFullFortuneDescription(int score) {
    // 1. API에서 받은 300자 설명 우선
    final fullDescription = widget.fortune?.metadata?['categories']?['total']?['advice']?['full_description'];
    if (fullDescription != null && fullDescription.toString().isNotEmpty) {
      return fullDescription.toString();
    }

    // 2. 점수 기반 300자 상세 설명 (fallback)
    if (score >= 90) {
      return '오늘은 모든 일이 순조롭게 풀리는 최상의 운세입니다. 평소 계획했던 일들을 추진하기에 더없이 좋은 시기이며, '
          '주변 사람들과의 관계도 원만하게 이어질 것입니다. 특히 새로운 시도나 도전에 있어 긍정적인 결과를 기대할 수 있으니, '
          '자신감을 가지고 적극적으로 행동해 보세요. 금전운도 좋아 예상치 못한 수입이 생길 수 있으며, 건강 상태도 양호합니다. '
          '다만 지나친 자신감은 경계하고, 겸손한 태도를 유지하는 것이 좋습니다.';
    } else if (score >= 80) {
      return '오늘은 전반적으로 좋은 흐름을 타고 있는 운세입니다. 하루 동안 긍정적인 에너지가 가득하며, '
          '작은 노력들이 좋은 결과로 이어질 가능성이 높습니다. 대인관계에서 좋은 소식이 들려올 수 있고, '
          '업무나 학업에서도 안정적인 성과를 거둘 수 있습니다. 새로운 인연을 만날 기회가 있다면 적극적으로 다가가 보세요. '
          '금전적으로는 안정적이나 큰 지출은 피하는 것이 좋으며, 건강 관리에도 신경 쓰면 더욱 좋은 하루가 될 것입니다.';
    } else if (score >= 70) {
      return '오늘은 평온하고 안정적인 하루를 보낼 수 있는 운세입니다. 큰 변화나 특별한 일은 없지만, '
          '일상적인 일들을 차근차근 처리하다 보면 만족스러운 결과를 얻을 수 있습니다. 주변 사람들과의 관계에서 '
          '작은 배려와 관심이 큰 도움이 될 것이며, 자신의 페이스를 유지하며 일을 진행하는 것이 좋습니다. '
          '무리한 욕심을 부리기보다는 현재 가진 것에 감사하고, 차분하게 하루를 보내세요. '
          '건강과 금전 상태 모두 무난한 편이니 안심하고 생활하시면 됩니다.';
    } else if (score >= 60) {
      return '오늘은 약간의 부침이 있을 수 있는 운세입니다. 모든 일이 계획대로 진행되지는 않을 수 있으나, '
          '침착하게 대응한다면 큰 문제없이 하루를 마무리할 수 있습니다. 예상치 못한 변수가 생길 수 있으니 '
          '여유 시간을 두고 일을 처리하는 것이 좋으며, 중요한 결정은 신중하게 내리세요. '
          '대인관계에서 작은 오해가 생길 수 있으니 소통에 각별히 신경 쓰고, 감정적인 대응은 피하는 것이 좋습니다. '
          '건강 관리에 유의하고, 불필요한 지출은 자제하는 것이 현명합니다.';
    } else {
      return '오늘은 다소 어려운 상황이 있을 수 있으나, 이 또한 지나갈 것입니다. 힘든 순간이 있더라도 긍정적인 마음가짐을 유지하고, '
          '주변의 도움을 받는 것을 주저하지 마세요. 모든 어려움은 성장의 기회가 될 수 있으며, '
          '오늘 겪는 시련이 내일의 밑거름이 될 것입니다. 무리한 시도보다는 현재 상황을 안정시키는 데 집중하고, '
          '중요한 결정은 미루는 것이 좋습니다. 휴식을 충분히 취하고 건강 관리에 신경 쓰세요. '
          '가까운 사람들과의 대화가 위로가 될 수 있으니, 혼자 고민하지 말고 마음을 나누어 보세요.';
    }
  }

  String _getScoreIdiom(int score) {
    if (score >= 90) return '금상첨화(錦上添花)';
    if (score >= 80) return '일취월장(日就月將)';
    if (score >= 70) return '안분지족(安分知足)';
    if (score >= 60) return '견토지쟁(犬兎之爭)';
    return '새옹지마(塞翁之馬)';
  }

  /// ChatGPT Pulse 스타일 색상 (채도 낮추고 부드럽게)
  Color _getPulseScoreColor(int score) {
    if (score >= 85) return const Color(0xFF10B981); // 차분한 초록
    if (score >= 70) return const Color(0xFF3B82F6); // 은은한 파랑
    if (score >= 50) return const Color(0xFF8B5CF6); // 부드러운 보라
    if (score >= 30) return const Color(0xFFF59E0B); // 따뜻한 노랑
    return const Color(0xFFEF4444); // 절제된 빨강
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF00D2FF);
    if (score >= 80) return const Color(0xFF0066FF);
    if (score >= 70) return const Color(0xFF7C4DFF);
    if (score >= 60) return const Color(0xFFFF6B35);
    return const Color(0xFFFF4757);
  }

  Map<String, double> _getRadarChartDataDouble(int score) {
    if (widget.fortune?.metadata?['categories'] != null) {
      final categories = widget.fortune!.metadata!['categories'];
      return {
        '연애': (categories['love']?['score'] as num?)?.toDouble() ?? 70.0,
        '금전': (categories['money']?['score'] as num?)?.toDouble() ?? 75.0,
        '직장': (categories['work']?['score'] as num?)?.toDouble() ?? 80.0,
        '학업': (categories['study']?['score'] as num?)?.toDouble() ?? 70.0,
        '건강': (categories['health']?['score'] as num?)?.toDouble() ?? 75.0,
      };
    }
    return {
      '연애': 70.0,
      '금전': 75.0,
      '직장': 80.0,
      '학업': 70.0,
      '건강': 75.0,
    };
  }

  Map<String, String> _getTimeSlotAdvice() {
    // 1. API 데이터 경로 1: daily_predictions
    final dailyPredictions = widget.fortune?.metadata?['daily_predictions'];
    if (dailyPredictions != null &&
        dailyPredictions['morning'] != null &&
        dailyPredictions['morning'].toString().isNotEmpty) {
      return {
        'morning': dailyPredictions['morning']?.toString() ?? '',
        'afternoon': dailyPredictions['afternoon']?.toString() ?? '',
        'evening': dailyPredictions['evening']?.toString() ?? '',
      };
    }

    // 2. API 데이터 경로 2: time_advice
    final timeAdvice = widget.fortune?.metadata?['time_advice'];
    if (timeAdvice != null &&
        timeAdvice['morning'] != null &&
        timeAdvice['morning'].toString().isNotEmpty) {
      return {
        'morning': timeAdvice['morning']?.toString() ?? '',
        'afternoon': timeAdvice['afternoon']?.toString() ?? '',
        'evening': timeAdvice['evening']?.toString() ?? '',
      };
    }

    // 3. API 데이터 경로 3: hourly_advice
    final hourlyAdvice = widget.fortune?.metadata?['hourly_advice'];
    if (hourlyAdvice != null) {
      return {
        'morning': hourlyAdvice['morning']?.toString() ?? '',
        'afternoon': hourlyAdvice['afternoon']?.toString() ?? '',
        'evening': hourlyAdvice['evening']?.toString() ?? '',
      };
    }

    // 4. Fallback: 총운 점수 기반 고정 시간대별 조언
    return _getFallbackTimeSlotAdvice(totalScore);
  }

  /// 점수 기반 시간대별 조언 (고정값, 랜덤 아님!)
  Map<String, String> _getFallbackTimeSlotAdvice(int score) {
    if (score >= 85) {
      return {
        'morning': '아침부터 긍정적인 에너지가 가득합니다. 중요한 미팅이나 업무를 오전에 배치하면 좋은 결과를 얻을 수 있습니다.',
        'afternoon': '오후에는 창의적인 아이디어가 떠오를 수 있습니다. 브레인스토밍이나 기획 업무에 집중하기 좋은 시간입니다.',
        'evening': '저녁에는 주변 사람들과의 교류가 즐거울 것입니다. 소중한 사람들과 시간을 보내며 에너지를 충전하세요.',
      };
    } else if (score >= 70) {
      return {
        'morning': '오전에는 차분하게 하루를 시작하세요. 계획을 세우고 우선순위를 정리하는 시간으로 활용하면 좋습니다.',
        'afternoon': '오후에는 안정적인 흐름이 이어집니다. 루틴 업무를 처리하고 작은 성취감을 쌓아가세요.',
        'evening': '저녁에는 휴식을 취하며 내일을 준비하세요. 가벼운 운동이나 취미 활동으로 마음을 정돈하는 시간이 필요합니다.',
      };
    } else if (score >= 50) {
      return {
        'morning': '오전에는 신중하게 행동하세요. 서두르지 말고 한 걸음씩 차근차근 진행하는 것이 중요합니다.',
        'afternoon': '오후에는 예상치 못한 변수가 있을 수 있습니다. 유연하게 대처하고 플랜 B를 준비해두세요.',
        'evening': '저녁에는 충분한 휴식이 필요합니다. 무리하지 말고 컨디션 관리에 집중하세요.',
      };
    } else {
      return {
        'morning': '오전에는 여유를 가지고 시작하세요. 급하게 서두르지 말고 마음을 안정시키는 것이 중요합니다.',
        'afternoon': '오후에는 중요한 결정을 미루는 것이 좋습니다. 충분한 검토 시간을 가지고 신중하게 판단하세요.',
        'evening': '저녁에는 자신을 돌보는 시간을 가지세요. 명상이나 가벼운 산책으로 마음의 평화를 찾으세요.',
      };
    }
  }

  Map<String, dynamic> _getCategoryData(String categoryKey, int baseScore) {
    if (widget.categories != null && widget.categories![categoryKey] != null) {
      return widget.categories![categoryKey];
    }

    if (widget.fortune?.metadata?['categories']?[categoryKey] != null) {
      return widget.fortune!.metadata!['categories'][categoryKey];
    }

    return _getFallbackCategoryData(categoryKey, baseScore);
  }

  Map<String, dynamic> _getFallbackCategoryData(String categoryKey, int baseScore) {
    // ❌ 랜덤 제거! 고정 점수 사용 (사용자 요청)
    // 카테고리별 점수 오프셋 (deterministic, not random!)
    final scoreOffsets = {
      'love': 0,      // baseScore 그대로
      'money': -3,    // baseScore - 3
      'work': 2,      // baseScore + 2
      'study': -5,    // baseScore - 5
      'health': 1,    // baseScore + 1
    };

    final offset = scoreOffsets[categoryKey] ?? 0;
    final score = (baseScore + offset).clamp(30, 100);

    final adviceMap = {
      'love': '새로운 만남에 열린 마음을 가지세요. 상대방의 감정을 존중하며 진심을 담은 대화를 나누면 좋은 결과가 있을 것입니다. 솔로라면 주변 사람들과의 소소한 만남을 소중히 여기고, 연인이 있다면 감사한 마음을 표현하는 것이 관계를 더욱 깊게 만들어줄 것입니다. 때로는 작은 배려와 관심이 큰 감동을 선물합니다. 상대방의 입장에서 생각하고 이해하려는 노력이 사랑을 키우는 비결입니다.',
      'money': '계획적인 소비가 도움이 될 것입니다. 충동구매를 자제하고 장기적인 재테크 계획을 세워보세요. 특히 오늘은 불필요한 지출을 줄이고 미래를 위한 저축에 집중하는 것이 좋습니다. 작은 돈도 아끼는 습관이 큰 재산을 만드는 첫걸음입니다. 투자를 고민 중이라면 충분한 정보 수집과 전문가 상담 후 신중하게 결정하세요. 단기적인 이익보다는 장기적인 안정성을 우선시하는 것이 현명합니다.',
      'work': '꾸준한 노력이 성과로 이어질 것입니다. 동료들과의 협력을 통해 더 큰 성과를 만들어보세요. 오늘은 팀워크가 특히 중요한 날입니다. 혼자 모든 것을 해내려 하기보다는 동료들의 강점을 활용하고 서로의 부족한 부분을 채워주는 것이 성공의 열쇠입니다. 새로운 아이디어가 있다면 주저하지 말고 제안해보세요. 상사나 동료들이 당신의 열정과 창의성을 높이 평가할 것입니다.',
      'study': '배움에 대한 열정으로 성과를 거둘 수 있습니다. 계획적인 학습과 복습이 실력 향상의 지름길입니다. 오늘은 집중력이 특히 좋은 날이니 어려운 개념을 공부하기에 최적의 시기입니다. 새로운 내용을 배우는 것도 좋지만, 기존에 학습했던 내용을 복습하는 것이 더욱 효과적일 수 있습니다. 혼자 공부하는 것이 막막하다면 스터디 그룹에 참여하거나 선생님께 질문하는 것도 좋은 방법입니다.',
      'health': '규칙적인 생활습관을 유지하세요. 충분한 수면과 적절한 운동으로 건강을 지킬 수 있습니다. 오늘은 특히 수면의 질에 신경 쓰는 것이 좋습니다. 잠들기 전 스마트폰 사용을 줄이고 편안한 환경을 만들어보세요. 가벼운 스트레칭이나 산책으로 몸을 움직이면 혈액순환이 좋아지고 기분도 한결 상쾌해질 것입니다. 물을 충분히 마시고 건강한 식사를 하는 것도 잊지 마세요.',
    };

    return {
      'score': score,
      'advice': adviceMap[categoryKey] ?? '긍정적인 마음가짐으로 하루를 시작하세요.',
    };
  }

  String _getCategoryEmoji(String categoryKey) {
    switch (categoryKey) {
      case 'love':
        return '❤️';
      case 'money':
        return '💰';
      case 'work':
        return '💼';
      case 'study':
        return '📚';
      case 'health':
        return '🏃';
      default:
        return '✨';
    }
  }

  Map<String, String> _getLuckyItems() {
    final luckyItems = widget.fortune?.metadata?['lucky_items'];
    if (luckyItems != null) {
      return {
        '시간': luckyItems['time']?.toString() ?? '오전 10시',
        '색상': luckyItems['color']?.toString() ?? '파란색',
        '숫자': luckyItems['number']?.toString() ?? '7',
        '방향': luckyItems['direction']?.toString() ?? '동쪽',
        '음식': luckyItems['food']?.toString() ?? '과일',
        '아이템': luckyItems['item']?.toString() ?? '시계',
      };
    }

    return {
      '시간': '오전 10시',
      '색상': '파란색',
      '숫자': '7',
      '방향': '동쪽',
      '음식': '과일',
      '아이템': '시계',
    };
  }

  /// 사주 데이터 가져오기 (API 우선)
  Map<String, String?> _getSajuData() {
    // 1. API 경로 1: sajuInsight
    final sajuInsight = widget.fortune?.sajuInsight;
    if (sajuInsight != null && sajuInsight['year_pillar'] != null) {
      return {
        'year_pillar': sajuInsight['year_pillar']?.toString(),
        'month_pillar': sajuInsight['month_pillar']?.toString(),
        'day_pillar': sajuInsight['day_pillar']?.toString(),
        'hour_pillar': sajuInsight['hour_pillar']?.toString(),
      };
    }

    // 2. API 경로 2: metadata.saju
    final metadataSaju = widget.fortune?.metadata?['saju'];
    if (metadataSaju != null && metadataSaju['year_pillar'] != null) {
      return {
        'year_pillar': metadataSaju['year_pillar']?.toString(),
        'month_pillar': metadataSaju['month_pillar']?.toString(),
        'day_pillar': metadataSaju['day_pillar']?.toString(),
        'hour_pillar': metadataSaju['hour_pillar']?.toString(),
      };
    }

    // 3. API 경로 3: metadata.pillars
    final pillars = widget.fortune?.metadata?['pillars'];
    if (pillars != null && pillars['year'] != null) {
      return {
        'year_pillar': pillars['year']?.toString(),
        'month_pillar': pillars['month']?.toString(),
        'day_pillar': pillars['day']?.toString(),
        'hour_pillar': pillars['hour']?.toString(),
      };
    }

    // 4. API 경로 4: fortune.sajuInsight (사주 인사이트에서 사주 정보 찾기)
    final fortuneSajuInsight = widget.fortune?.sajuInsight;
    if (fortuneSajuInsight != null) {
      return {
        'year_pillar': fortuneSajuInsight['year_pillar']?.toString() ?? fortuneSajuInsight['year']?.toString(),
        'month_pillar': fortuneSajuInsight['month_pillar']?.toString() ?? fortuneSajuInsight['month']?.toString(),
        'day_pillar': fortuneSajuInsight['day_pillar']?.toString() ?? fortuneSajuInsight['day']?.toString(),
        'hour_pillar': fortuneSajuInsight['hour_pillar']?.toString() ?? fortuneSajuInsight['hour']?.toString(),
      };
    }

    // 5. Fallback: 생년월일 기반 간단한 추정값 (실제 만세력 계산 아님, 플레이스홀더)
    return {
      'year_pillar': '갑자',
      'month_pillar': '병인',
      'day_pillar': '무진',
      'hour_pillar': '경오',
    };
  }

  // ========== 새로운 카드 빌더 함수들 (8개) ==========

  /// 🌤️ 오늘의 날씨 연계 운세 카드
  Widget _buildWeatherFortuneCard(bool isDark) {
    final weatherData = widget.fortune?.weatherSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 날씨 운세',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '날씨와 함께하는 당신의 하루',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 40),

        // 날씨 정보 카드
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF3B82F6) : const Color(0xFF60A5FA),
                isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherData?['condition']?.toString() ?? '맑음',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weatherData?['temperature']?.toString() ?? '22'}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  weatherData?['fortune_message']?.toString() ??
                  '맑은 날씨처럼 당신의 하루도 밝고 긍정적일 것입니다. 야외 활동이나 새로운 도전을 시작하기 좋은 날입니다.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔮 사주 인사이트 카드
  Widget _buildSajuInsightCard(bool isDark) {
    final sajuData = _getSajuData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주 인사이트',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '당신의 사주가 말하는 오늘',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 32),

        // 사주 기둥 표시
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF7C3AED) : const Color(0xFF9333EA),
                isDark ? const Color(0xFF6D28D9) : const Color(0xFF7C3AED),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSajuPillar('시', sajuData['hour_pillar'] ?? '○○', Colors.white),
                  _buildSajuPillar('일', sajuData['day_pillar'] ?? '○○', Colors.white),
                  _buildSajuPillar('월', sajuData['month_pillar'] ?? '○○', Colors.white),
                  _buildSajuPillar('년', sajuData['year_pillar'] ?? '○○', Colors.white),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sajuData?['insight']?.toString() ??
                  '당신의 사주는 균형잡힌 에너지를 가지고 있습니다. 오늘은 본래의 성향을 잘 활용하면 좋은 결과를 얻을 수 있습니다.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSajuPillar(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 🎯 오늘의 액션 플랜 카드
  Widget _buildActionPlanCard(bool isDark) {
    final actions = _getRealisticActionPlan();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 액션 플랜',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '오늘 꼭 실천할 것들',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 32),

        ...actions.map((action) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildActionItem(
            action['title']!,
            action['description']!,
            action['priority']!,
            isDark,
          ),
        )),
      ],
    );
  }

  /// 현실적인 액션 플랜 생성 (API 우선)
  List<Map<String, String>> _getRealisticActionPlan() {
    // 1. API에서 제공된 액션 플랜 확인
    final apiActions = widget.fortune?.personalActions;
    if (apiActions != null && apiActions.isNotEmpty) {
      return apiActions.take(5).map((action) {
        return {
          'title': action['title']?.toString() ?? '',
          'description': action['description']?.toString() ?? '',
          'priority': action['priority']?.toString() ?? 'medium',
        };
      }).toList();
    }

    // 2. API 경로 2: metadata.action_plan
    final metadataActions = widget.fortune?.metadata?['action_plan'];
    if (metadataActions != null && metadataActions is List && metadataActions.isNotEmpty) {
      return metadataActions.take(5).map((action) {
        return {
          'title': action['title']?.toString() ?? '',
          'description': action['description']?.toString() ?? '',
          'priority': action['priority']?.toString() ?? 'medium',
        };
      }).toList();
    }

    // 3. Fallback: 점수 기반 현실적인 액션 플랜
    return _getScoreBasedActionPlan(totalScore);
  }

  /// 점수 기반 현실적인 액션 플랜
  List<Map<String, String>> _getScoreBasedActionPlan(int score) {
    if (score >= 85) {
      return [
        {
          'title': '🌅 오전: 중요 업무 우선 처리',
          'description': '에너지 최고조 시간, 핵심 업무 + 네트워킹',
          'priority': 'high',
        },
        {
          'title': '🍽 점심: 영양 충전 & 휴식',
          'description': '건강한 식사로 오후 에너지 준비',
          'priority': 'medium',
        },
        {
          'title': '💡 오후: 창의적 마무리',
          'description': '새 아이디어 브레인스토밍 후 가벼운 운동',
          'priority': 'high',
        },
      ];
    } else if (score >= 70) {
      return [
        {
          'title': '📝 오전: 우선순위 정리',
          'description': '꼭 해야 할 일 3가지 노트 정리',
          'priority': 'high',
        },
        {
          'title': '🤝 점심: 동료와 식사',
          'description': '가벼운 대화로 스트레스 환기',
          'priority': 'medium',
        },
        {
          'title': '📊 오후: 집중 업무 + 휴식',
          'description': '2시간 집중 모드 후 10분 스트레칭',
          'priority': 'high',
        },
      ];
    } else if (score >= 50) {
      return [
        {
          'title': '🌤 아침: 긍정 루틴',
          'description': '환기 + 감사 3가지 떠올리기',
          'priority': 'medium',
        },
        {
          'title': '📱 오전: 알림 정리 & 집중',
          'description': 'SNS 일시정지, 필수 연락만',
          'priority': 'high',
        },
        {
          'title': '🎯 오후: 작은 목표 달성',
          'description': '10분 과제부터 시작, 점진적 성취',
          'priority': 'medium',
        },
      ];
    } else {
      return [
        {
          'title': '😌 아침: 스트레스 낮추기',
          'description': '5분 심호흡(4-7-8 호흡법)',
          'priority': 'high',
        },
        {
          'title': '👂 점심: 대화 & 위로',
          'description': '신뢰하는 사람과 고민 나누기',
          'priority': 'medium',
        },
        {
          'title': '🌳 오후: 20분 산책',
          'description': '자연 속 걷기로 생각 비우기',
          'priority': 'high',
        },
      ];
    }
  }

  /// 상세한 오행 데이터 가져오기 (API 우선, 사주 기반 계산 fallback)
  Map<String, dynamic> _getDetailedFiveElementsData() {
    // 1. API에서 제공된 오행 데이터 우선 확인
    final apiElements = widget.fortune?.fiveElements;
    final apiSajuInsight = widget.fortune?.sajuInsight;
    final metadata = widget.fortune?.metadata;

    // 사주 정보 가져오기 (재사용)
    final sajuInfo = _getSajuData();

    // 오행 데이터
    Map<String, int> elementsData;
    String balance;
    String explanation;

    // 2. API 경로 1: fortune.fiveElements
    if (apiElements != null &&
        apiElements['wood'] != null &&
        apiElements['fire'] != null &&
        apiElements['earth'] != null &&
        apiElements['metal'] != null &&
        apiElements['water'] != null) {
      elementsData = {
        '목(木)': (apiElements['wood'] as num).toInt(),
        '화(火)': (apiElements['fire'] as num).toInt(),
        '토(土)': (apiElements['earth'] as num).toInt(),
        '금(金)': (apiElements['metal'] as num).toInt(),
        '수(水)': (apiElements['water'] as num).toInt(),
      };

      // API에서 제공한 균형 설명
      balance = apiElements['balance']?.toString() ?? _calculateBalance(elementsData);
      explanation = apiElements['explanation']?.toString() ?? _generateExplanation(elementsData);
    }
    // 3. API 경로 2: metadata.five_elements
    else if (metadata?['five_elements'] != null) {
      final metaElements = metadata!['five_elements'] as Map<String, dynamic>;
      elementsData = {
        '목(木)': (metaElements['wood'] as num?)?.toInt() ?? 20,
        '화(火)': (metaElements['fire'] as num?)?.toInt() ?? 20,
        '토(土)': (metaElements['earth'] as num?)?.toInt() ?? 20,
        '금(金)': (metaElements['metal'] as num?)?.toInt() ?? 20,
        '수(水)': (metaElements['water'] as num?)?.toInt() ?? 20,
      };

      balance = metaElements['balance']?.toString() ?? _calculateBalance(elementsData);
      explanation = metaElements['explanation']?.toString() ?? _generateExplanation(elementsData);
    }
    // 4. API 경로 3: sajuInsight.five_elements
    else if (apiSajuInsight?['five_elements'] != null) {
      final sajuElements = apiSajuInsight!['five_elements'] as Map<String, dynamic>;
      elementsData = {
        '목(木)': (sajuElements['wood'] as num?)?.toInt() ?? 20,
        '화(火)': (sajuElements['fire'] as num?)?.toInt() ?? 20,
        '토(土)': (sajuElements['earth'] as num?)?.toInt() ?? 20,
        '금(金)': (sajuElements['metal'] as num?)?.toInt() ?? 20,
        '수(水)': (sajuElements['water'] as num?)?.toInt() ?? 20,
      };

      balance = sajuElements['balance']?.toString() ?? _calculateBalance(elementsData);
      explanation = sajuElements['explanation']?.toString() ?? _generateExplanation(elementsData);
    }
    // 5. Fallback: 생년월일 기반 추정 오행 (deterministic!)
    else {
      elementsData = _calculateElementsFromBirthDate();
      balance = _calculateBalance(elementsData);
      explanation = _generateExplanation(elementsData);
    }

    return {
      'elements': elementsData,
      'sajuInfo': sajuInfo,
      'balance': balance,
      'explanation': explanation,
    };
  }

  /// 생년월일 기반 오행 계산 (deterministic, not random!)
  Map<String, int> _calculateElementsFromBirthDate() {
    // 사용자 생년월일 가져오기 (기본값: 1990-01-01)
    final birthDate = DateTime.tryParse(widget.fortune?.metadata?['birth_date']?.toString() ?? '') ?? DateTime(1990, 1, 1);

    // 연도의 끝자리에 따른 주 오행 결정 (천간 기준)
    final yearLastDigit = birthDate.year % 10;
    final mainElement = _getMainElementFromYear(yearLastDigit);

    // 월에 따른 부 오행 (계절성)
    final month = birthDate.month;
    final seasonElement = _getSeasonElement(month);

    // 오행 배분 (deterministic!)
    final Map<String, int> elements = {
      '목(木)': 20,
      '화(火)': 20,
      '토(土)': 20,
      '금(金)': 20,
      '수(水)': 20,
    };

    // 주 오행 +10
    elements[mainElement] = (elements[mainElement] ?? 20) + 10;
    // 계절 오행 +5
    elements[seasonElement] = (elements[seasonElement] ?? 20) + 5;

    // 총합이 100이 되도록 조정
    final total = elements.values.reduce((a, b) => a + b);
    final scale = 100.0 / total;
    elements.updateAll((key, value) => (value * scale).round());

    return elements;
  }

  /// 연도 끝자리로 주 오행 결정 (천간 기준)
  String _getMainElementFromYear(int lastDigit) {
    switch (lastDigit) {
      case 0:
      case 1:
        return '금(金)'; // 경(庚), 신(辛)
      case 2:
      case 3:
        return '수(水)'; // 임(壬), 계(癸)
      case 4:
      case 5:
        return '목(木)'; // 갑(甲), 을(乙)
      case 6:
      case 7:
        return '화(火)'; // 병(丙), 정(丁)
      case 8:
      case 9:
        return '토(土)'; // 무(戊), 기(己)
      default:
        return '목(木)';
    }
  }

  /// 월로 계절 오행 결정
  String _getSeasonElement(int month) {
    if (month >= 2 && month <= 4) {
      return '목(木)'; // 봄
    } else if (month >= 5 && month <= 7) {
      return '화(火)'; // 여름
    } else if (month >= 8 && month <= 10) {
      return '금(金)'; // 가을
    } else {
      return '수(水)'; // 겨울 (11, 12, 1월)
    }
  }

  /// 오행 균형 상태 판단
  String _calculateBalance(Map<String, int> elements) {
    final values = elements.values.toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final difference = max - min;

    // 가장 높은/낮은 오행 찾기
    final maxElement = elements.entries.firstWhere((e) => e.value == max).key;
    final minElement = elements.entries.firstWhere((e) => e.value == min).key;

    if (difference <= 15) {
      return '오행이 전체적으로 균형 잡혀 있습니다. 안정적인 운세를 나타냅니다.';
    } else if (difference <= 25) {
      return '$maxElement이(가) 강하고 $minElement이(가) 약합니다. ${_getElementAdvice(minElement)}을(를) 보강하면 좋습니다.';
    } else {
      return '$maxElement이(가) 매우 강하고 $minElement이(가) 매우 약합니다. 오행 불균형 상태이니 ${_getElementAdvice(minElement)}을(를) 통해 균형을 맞추세요.';
    }
  }

  /// 부족한 오행에 대한 조언
  String _getElementAdvice(String element) {
    switch (element) {
      case '목(木)':
        return '초록색 옷이나 소품, 식물 가까이 하기';
      case '화(火)':
        return '붉은색 계열 아이템, 햇볕 쬐기';
      case '토(土)':
        return '황토색/베이지 색상, 흙과 접촉';
      case '금(金)':
        return '금속 액세서리, 흰색/은색 아이템';
      case '수(水)':
        return '검은색/남색 옷, 물가 산책';
      default:
        return '균형 잡힌 생활';
    }
  }

  /// 오행 균형 상세 설명 생성
  String _generateExplanation(Map<String, int> elements) {
    final values = elements.values.toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final maxElement = elements.entries.firstWhere((e) => e.value == max).key;
    final minElement = elements.entries.firstWhere((e) => e.value == min).key;

    // 가장 강한 오행의 특성
    String strongDescription;
    switch (maxElement) {
      case '목(木)':
        strongDescription = '목기(木氣)가 강하면 성장과 발전의 기운이 왕성합니다. 창의성과 추진력이 뛰어나며 새로운 일을 시작하기 좋습니다.';
        break;
      case '화(火)':
        strongDescription = '화기(火氣)가 강하면 열정과 활력이 넘칩니다. 사교성이 좋고 리더십을 발휘하기 쉬우며 사람들과의 관계가 활발합니다.';
        break;
      case '토(土)':
        strongDescription = '토기(土氣)가 강하면 안정과 신뢰의 기운이 큽니다. 끈기와 인내심이 강하며 든든한 기반을 만드는 데 유리합니다.';
        break;
      case '금(金)':
        strongDescription = '금기(金氣)가 강하면 결단력과 추진력이 뛰어납니다. 원칙과 규율을 중시하며 목표를 향해 매진하는 성향이 강합니다.';
        break;
      case '수(水)':
        strongDescription = '수기(水氣)가 강하면 지혜와 유연성이 돋보입니다. 상황에 잘 적응하고 깊이 있는 사고를 하며 통찰력이 뛰어납니다.';
        break;
      default:
        strongDescription = '';
    }

    // 가장 약한 오행의 보완 방법
    String weakDescription;
    switch (minElement) {
      case '목(木)':
        weakDescription = '목기(木氣)가 부족하면 새로운 시도가 어렵고 성장이 더딜 수 있습니다. 초록색 식물을 가까이 하고 아침 산책으로 기운을 보충하세요.';
        break;
      case '화(火)':
        weakDescription = '화기(火氣)가 부족하면 의욕이 떨어지고 소극적이 될 수 있습니다. 햇볕을 충분히 쬐고 따뜻한 음식으로 양기를 보강하세요.';
        break;
      case '토(土)':
        weakDescription = '토기(土氣)가 부족하면 불안정하고 기반이 약할 수 있습니다. 규칙적인 생활과 황토색 계열 옷으로 안정감을 높이세요.';
        break;
      case '금(金)':
        weakDescription = '금기(金氣)가 부족하면 결단력이 약하고 우유부단할 수 있습니다. 금속 액세서리를 착용하고 호흡 수련으로 기운을 다지세요.';
        break;
      case '수(水)':
        weakDescription = '수기(水氣)가 부족하면 지혜가 부족하고 고집이 세질 수 있습니다. 물을 자주 마시고 검은색 옷으로 수기를 보충하세요.';
        break;
      default:
        weakDescription = '';
    }

    return '$strongDescription\n\n$weakDescription';
  }

  /// 시간대별 운세 데이터 가져오기 (API 우선, deterministic fallback)
  Map<String, dynamic> _getHourlyFortuneData() {
    final timeFortunes = widget.fortune?.timeSpecificFortunes ?? [];

    // 시간대별 점수 데이터 생성
    final List<FlSpot> spots = [];

    if (timeFortunes.isNotEmpty && timeFortunes.length >= 24) {
      // API에서 받은 시간대별 데이터 사용
      for (int i = 0; i < 24; i++) {
        final score = i < timeFortunes.length ? timeFortunes[i].score.toDouble() : 50.0;
        spots.add(FlSpot(i.toDouble(), score));
      }
    } else {
      // Fallback: 총운 점수 기반 deterministic 시간대별 점수 생성
      final baseScore = totalScore;
      for (int i = 0; i < 24; i++) {
        // 시간대별 변화 패턴 (고정, not random!)
        // 새벽(0-5시): 낮음, 오전(6-11시): 상승, 오후(12-17시): 안정, 저녁(18-23시): 하락
        double variation = 0;
        if (i >= 0 && i < 6) {
          variation = -10; // 새벽
        } else if (i >= 6 && i < 12) {
          variation = 5 + (i - 6) * 2; // 오전 상승
        } else if (i >= 12 && i < 18) {
          variation = 10 - (i - 12); // 오후 안정
        } else {
          variation = 5 - (i - 18) * 2; // 저녁 하락
        }

        final hourScore = (baseScore + variation).clamp(30.0, 100.0);
        spots.add(FlSpot(i.toDouble(), hourScore));
      }
    }

    // 베스트/워스트 시간 찾기
    int bestHour = 0;
    int worstHour = 0;
    double bestScore = spots[0].y;
    double worstScore = spots[0].y;

    for (int i = 1; i < spots.length; i++) {
      if (spots[i].y > bestScore) {
        bestScore = spots[i].y;
        bestHour = i;
      }
      if (spots[i].y < worstScore) {
        worstScore = spots[i].y;
        worstHour = i;
      }
    }

    // 시간대별 조언 (베스트, 워스트, 현재 시간 기준 3개만)
    final now = DateTime.now();
    final currentHour = now.hour;
    final Map<int, String> advice = {};

    // 1. 베스트 시간 조언
    advice[bestHour] = _getHourAdvice(bestHour, bestScore.toInt(), true);

    // 2. 워스트 시간 조언
    if (worstHour != bestHour) {
      advice[worstHour] = _getHourAdvice(worstHour, worstScore.toInt(), false);
    }

    // 3. 현재 시간 조언 (베스트나 워스트가 아닌 경우만)
    if (currentHour != bestHour && currentHour != worstHour && currentHour < spots.length) {
      advice[currentHour] = _getHourAdvice(currentHour, spots[currentHour].y.toInt(), null);
    }

    return {
      'spots': spots,
      'bestHour': bestHour,
      'worstHour': worstHour,
      'bestScore': bestScore.toInt(),
      'worstScore': worstScore.toInt(),
      'advice': advice,
    };
  }

  /// 특정 시간대에 대한 조언 생성
  String _getHourAdvice(int hour, int score, bool? isBest) {
    final timeOfDay = _getTimeOfDayLabel(hour);

    if (isBest == true) {
      // 베스트 시간 조언
      if (hour >= 6 && hour < 12) {
        return '오늘의 베스트 타임! 중요한 회의나 업무는 이 시간대에 진행하면 좋은 결과를 얻을 수 있습니다.';
      } else if (hour >= 12 && hour < 18) {
        return '오후의 골든 타임! 창의적인 작업이나 새로운 시도를 하기에 최적의 시간입니다.';
      } else if (hour >= 18 && hour < 24) {
        return '저녁의 행운 시간! 중요한 약속이나 대화는 이 시간에 하면 긍정적인 결과로 이어질 수 있습니다.';
      } else {
        return '이른 시간이지만 운세가 좋습니다. 일찍 일어나 하루를 준비하면 하루 종일 좋은 흐름을 탈 수 있습니다.';
      }
    } else if (isBest == false) {
      // 워스트 시간 조언
      if (hour >= 0 && hour < 6) {
        return '새벽 시간대는 컨디션이 좋지 않을 수 있습니다. 중요한 결정은 피하고 충분한 휴식을 취하세요.';
      } else if (hour >= 6 && hour < 12) {
        return '오전 중 운세가 다소 낮은 시간입니다. 신중한 판단이 필요하며, 급한 일은 오후로 미루는 것이 좋습니다.';
      } else if (hour >= 12 && hour < 18) {
        return '오후 슬럼프 시간입니다. 잠시 휴식을 취하고 에너지를 회복한 후 업무를 재개하세요.';
      } else {
        return '저녁 피로도가 높은 시간입니다. 중요한 약속이나 결정은 내일로 미루고 여유롭게 휴식하세요.';
      }
    } else {
      // 현재 시간 조언
      if (score >= 75) {
        return '${timeOfDay} 운세가 양호합니다. 계획한 일들을 진행하기 좋은 시간이니 적극적으로 행동하세요.';
      } else if (score >= 50) {
        return '${timeOfDay} 무난한 운세입니다. 큰 문제는 없으나 중요한 결정은 신중하게 하는 것이 좋습니다.';
      } else {
        return '${timeOfDay} 다소 주의가 필요한 시간입니다. 여유를 가지고 천천히 진행하며 실수를 줄이도록 노력하세요.';
      }
    }
  }

  /// 시간대 라벨
  String _getTimeOfDayLabel(int hour) {
    if (hour >= 6 && hour < 12) {
      return '오전';
    } else if (hour >= 12 && hour < 18) {
      return '오후';
    } else if (hour >= 18 && hour < 24) {
      return '저녁';
    } else {
      return '새벽';
    }
  }

  Widget _buildActionItem(String title, String description, String priority, bool isDark) {
    Color getPriorityColor() {
      switch (priority) {
        case 'high':
          return const Color(0xFFEF4444);
        case 'medium':
          return const Color(0xFFF59E0B);
        default:
          return const Color(0xFF10B981);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D).withOpacity(0.5) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getPriorityColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: getPriorityColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🌊 오행 밸런스 카드
  Widget _buildFiveElementsCard(bool isDark) {
    final fiveElementsData = _getDetailedFiveElementsData();
    final elementsData = fiveElementsData['elements'] as Map<String, int>;
    final sajuInfo = fiveElementsData['sajuInfo'] as Map<String, String?>;
    final balance = fiveElementsData['balance'] as String;
    final explanation = fiveElementsData['explanation'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오행 밸런스',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '당신의 사주 기반 오행 균형 분석',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 28),

        // 사주 정보 카드 (만세력 스타일)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '📅 사주팔자',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(만세력 기준)',
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPillarItem('년주', sajuInfo['year_pillar']!, isDark),
                  _buildPillarItem('월주', sajuInfo['month_pillar']!, isDark),
                  _buildPillarItem('일주', sajuInfo['day_pillar']!, isDark),
                  _buildPillarItem('시주', sajuInfo['hour_pillar']!, isDark),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // 균형 상태 요약
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF3B82F6) : const Color(0xFF3B82F6)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                balance.contains('균형') ? Icons.check_circle : Icons.info_outline,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  balance,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // 오행 바 차트
        ...elementsData.entries.map((entry) {
          Color getElementColor(String element) {
            if (element.contains('木')) return const Color(0xFF10B981);
            if (element.contains('火')) return const Color(0xFFEF4444);
            if (element.contains('土')) return const Color(0xFFF59E0B);
            if (element.contains('金')) return const Color(0xFF8B5CF6);
            return const Color(0xFF3B82F6);
          }

          String getElementStatus(int value) {
            if (value >= 25) return '과다';
            if (value >= 18) return '충분';
            if (value >= 12) return '보통';
            return '부족';
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: getElementColor(entry.key).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            getElementStatus(entry.value),
                            style: TextStyle(
                              color: getElementColor(entry.key),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value}%',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: entry.value / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            getElementColor(entry.key),
                            getElementColor(entry.key).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 20),

        // 오행 균형 설명
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            explanation,
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
              fontSize: 14,
              height: 1.7,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  /// 사주 주(柱) 아이템 위젯
  Widget _buildPillarItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// ⏱️ 시간대별 점수 그래프 카드
  Widget _buildHourlyScoreGraphCard(bool isDark) {
    final hourlyData = _getHourlyFortuneData();
    final spots = hourlyData['spots'] as List<FlSpot>;
    final bestHour = hourlyData['bestHour'] as int;
    final worstHour = hourlyData['worstHour'] as int;
    final bestScore = hourlyData['bestScore'] as int;
    final worstScore = hourlyData['worstScore'] as int;
    final hourlyAdvice = hourlyData['advice'] as Map<int, String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간대별 운세 그래프',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '하루 24시간 운세 흐름과 추천 시간대',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 16),

        // 베스트/워스트 시간대 요약 (1줄로 축소)
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D).withOpacity(0.5) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_upward, color: const Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '베스트',
                        style: TextStyle(
                          color: const Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${bestHour}시',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              ),
              Row(
                children: [
                  Icon(Icons.arrow_downward, color: const Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '주의',
                        style: TextStyle(
                          color: const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${worstHour}시',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D).withOpacity(0.5) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 6,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}시',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      // 베스트/워스트 시간만 점 표시
                      return spot.x.toInt() == bestHour || spot.x.toInt() == worstHour;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      final isBest = spot.x.toInt() == bestHour;
                      return FlDotCirclePainter(
                        radius: 6,
                        color: isBest ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.3),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  /// 🐉 띠별 운세 카드
  Widget _buildZodiacFortuneCard(bool isDark) {
    final zodiacData = _getZodiacFortuneData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '띠별 운세',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '나와 주변 사람들의 띠 운세',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 32),

        ...zodiacData.map((fortune) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D).withOpacity(0.5) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: fortune['isUser'] == true
                  ? Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.5),
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fortune['emoji'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${fortune['year']}년생',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (fortune['isUser'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '내 띠',
                                    style: TextStyle(
                                      color: const Color(0xFF3B82F6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            fortune['name'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getZodiacScoreColor(fortune['score'] as int).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${fortune['score']}점',
                        style: TextStyle(
                          color: _getZodiacScoreColor(fortune['score'] as int),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  fortune['description'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Color _getZodiacScoreColor(int score) {
    if (score >= 85) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFF3B82F6);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  /// 띠별 운세 데이터 가져오기 (API 우선, 생년 기반 fallback)
  List<Map<String, dynamic>> _getZodiacFortuneData() {
    final birthYearFortunes = widget.fortune?.birthYearFortunes ?? [];

    // 1. API에서 받은 데이터가 있으면 사용
    if (birthYearFortunes.isNotEmpty) {
      return birthYearFortunes.take(3).map((fortune) {
        final zodiacInfo = _getZodiacInfo(fortune.zodiacAnimal);
        return {
          'year': fortune.birthYear,
          'name': fortune.zodiacAnimal,
          'emoji': zodiacInfo['emoji'],
          'description': fortune.description,
          'score': 75, // API에 score가 없으면 기본값
          'isUser': false,
        };
      }).toList();
    }

    // 2. Fallback: 사용자 생년 기반 띠 계산
    final birthDate = DateTime.tryParse(widget.fortune?.metadata?['birth_date']?.toString() ?? '') ?? DateTime(1990, 1, 1);
    final userYear = birthDate.year;
    final userZodiac = _getZodiacFromYear(userYear);
    final zodiacInfo = _getZodiacInfo(userZodiac);

    // 총운 점수 기반 띠별 점수 계산 (deterministic!)
    final baseScore = totalScore;

    // 사용자 띠 + 전후 2개 띠 = 총 3개 표시
    final results = <Map<String, dynamic>>[];

    // 1. 이전 띠 (작년생)
    final prevYear = userYear - 1;
    final prevZodiac = _getZodiacFromYear(prevYear);
    final prevInfo = _getZodiacInfo(prevZodiac);
    results.add({
      'year': prevYear.toString(),
      'name': prevZodiac,
      'emoji': prevInfo['emoji'],
      'description': prevInfo['description'],
      'score': (baseScore - 8).clamp(40, 100),
      'isUser': false,
    });

    // 2. 사용자 띠 (내 띠)
    results.add({
      'year': userYear.toString(),
      'name': userZodiac,
      'emoji': zodiacInfo['emoji'],
      'description': zodiacInfo['description'],
      'score': baseScore,
      'isUser': true,
    });

    // 3. 다음 띠 (내년생)
    final nextYear = userYear + 1;
    final nextZodiac = _getZodiacFromYear(nextYear);
    final nextInfo = _getZodiacInfo(nextZodiac);
    results.add({
      'year': nextYear.toString(),
      'name': nextZodiac,
      'emoji': nextInfo['emoji'],
      'description': nextInfo['description'],
      'score': (baseScore + 5).clamp(40, 100),
      'isUser': false,
    });

    return results;
  }

  /// 연도에서 띠 계산
  String _getZodiacFromYear(int year) {
    const zodiacs = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return zodiacs[year % 12];
  }

  /// 현재 카드의 공유 정보 가져오기
  Map<String, dynamic> _getCurrentCardShareInfo() {
    final score = totalScore;
    final cardTitles = [
      '📊 총운',
      '🌤️ 날씨 운세',
      '📈 5대 영역',
      '⏰ 시간대별 조언',
      '🎯 행운 아이템',
      '📅 사주 인사이트',
      '💼 오늘의 액션 플랜',
      '🌊 오행 밸런스',
      '⏱️ 시간대별 그래프',
      '🐉 띠별 운세',
      '💫 주간 트렌드',
      '🎁 공유하기',
    ];

    // 현재 페이지 인덱스 (공유 카드는 마지막이므로 이전 카드 공유)
    final currentPage = _currentPage.clamp(0, cardTitles.length - 1);

    String title;
    String message;
    Color color;
    int? displayScore;

    switch (currentPage) {
      case 0: // 총운
        title = '오늘의 총운';
        message = _getMainScoreMessage(score);
        color = _getPulseScoreColor(score);
        displayScore = score;
        break;
      case 1: // 날씨
        title = '날씨 연계 운세';
        message = '오늘의 날씨와 어울리는 운세를 확인해보세요';
        color = const Color(0xFF3B82F6);
        displayScore = null;
        break;
      case 2: // 5대 영역
        title = '5대 영역 운세';
        message = '연애, 금전, 직장, 학업, 건강 운세를 한눈에!';
        color = const Color(0xFF8B5CF6);
        displayScore = score;
        break;
      case 3: // 시간대별
        title = '시간대별 조언';
        message = '아침, 오후, 저녁 각 시간대별 운세 조언';
        color = const Color(0xFFF59E0B);
        displayScore = null;
        break;
      case 4: // 행운 아이템
        title = '오늘의 행운 아이템';
        message = '색상, 숫자, 방향, 음식으로 행운을 끌어당기세요';
        color = const Color(0xFF10B981);
        displayScore = null;
        break;
      case 5: // 사주
        title = '사주 인사이트';
        message = '당신의 사주팔자 분석 결과';
        color = const Color(0xFFEF4444);
        displayScore = null;
        break;
      case 6: // 액션 플랜
        title = '오늘의 액션 플랜';
        message = '오늘 해야 할 구체적인 행동 지침';
        color = const Color(0xFF3B82F6);
        displayScore = null;
        break;
      case 7: // 오행
        title = '오행 밸런스';
        message = '사주 기반 오행 균형 분석';
        color = const Color(0xFF8B5CF6);
        displayScore = null;
        break;
      case 8: // 시간대별 그래프
        title = '24시간 운세 그래프';
        message = '하루 시간대별 운세 흐름';
        color = const Color(0xFF10B981);
        displayScore = null;
        break;
      case 9: // 띠별
        title = '띠별 운세';
        message = '나와 주변 사람들의 띠 운세';
        color = const Color(0xFFF59E0B);
        displayScore = null;
        break;
      case 10: // 주간 트렌드
        title = '주간 운세 트렌드';
        message = '이번 주 운세 흐름';
        color = const Color(0xFF10B981);
        displayScore = null;
        break;
      default:
        title = '오늘의 운세';
        message = _getMainScoreMessage(score);
        color = _getPulseScoreColor(score);
        displayScore = score;
    }

    return {
      'title': title,
      'message': message,
      'color': color,
      'score': displayScore,
    };
  }

  /// 현재 카드 공유하기
  void _shareCurrentCard(Map<String, dynamic> cardInfo) {
    final userName = widget.fortune?.metadata?['user_name'] ?? '나';
    final date = DateTime.now().toString().split(' ')[0];

    final shareText = '''
${cardInfo['title']}

$userName의 운세 (${date})
${cardInfo['score'] != null ? '점수: ${cardInfo['score']}점\n' : ''}
${cardInfo['message']}

#운세 #오늘의운세 #Beyond운세
''';

    // share_plus 패키지 사용
    Share.share(shareText);
  }

  /// 주간 운세 점수 가져오기 (생성시점 기준 고정!)
  List<int> _getWeeklyScores() {
    // Fortune 생성 날짜 가져오기
    final createdAt = widget.fortune?.createdAt ?? DateTime.now();
    final baseScore = totalScore;

    // 생성 날짜의 요일 (0=월요일, 6=일요일)
    final createdDayOfWeek = createdAt.weekday - 1; // DateTime.weekday는 1=월요일

    // 각 요일별 점수 (생성 날짜 기준으로 deterministic하게 계산)
    final weeklyScores = <int>[];
    for (int i = 0; i < 7; i++) {
      // 생성일로부터의 일수 차이
      final dayOffset = (i - createdDayOfWeek) % 7;

      // 패턴: 중간 정도 시작 → 주중 상승 → 주말 하락
      int score;
      if (dayOffset == 0) {
        // 생성일
        score = baseScore;
      } else if (dayOffset >= 1 && dayOffset <= 3) {
        // 생성일 이후 1-3일: 상승
        score = baseScore + (dayOffset * 5);
      } else if (dayOffset == 4) {
        // 생성일 이후 4일: 최고점
        score = baseScore + 15;
      } else {
        // 생성일 이후 5-6일: 하락
        score = baseScore + (10 - (dayOffset - 4) * 8);
      }

      weeklyScores.add(score.clamp(40, 100));
    }

    return weeklyScores;
  }

  /// 띠별 정보 (이모지, 설명)
  Map<String, String> _getZodiacInfo(String zodiac) {
    final zodiacMap = {
      '쥐': {
        'emoji': '🐭',
        'description': '오늘은 새로운 기회를 발견할 수 있는 날입니다. 적극적인 자세로 임하면 좋은 결과를 얻을 수 있습니다.',
      },
      '소': {
        'emoji': '🐮',
        'description': '차근차근 진행하는 것이 좋은 하루입니다. 인내심을 가지고 목표를 향해 나아가세요.',
      },
      '호랑이': {
        'emoji': '🐯',
        'description': '용기와 자신감이 빛나는 하루입니다. 도전적인 일에 과감하게 뛰어들어 보세요.',
      },
      '토끼': {
        'emoji': '🐰',
        'description': '주변 사람들과의 관계가 원만한 하루입니다. 소통을 통해 긍정적인 에너지를 얻으세요.',
      },
      '용': {
        'emoji': '🐲',
        'description': '리더십을 발휘하기 좋은 날입니다. 주도적으로 일을 이끌어가면 성공할 수 있습니다.',
      },
      '뱀': {
        'emoji': '🐍',
        'description': '지혜롭게 판단하는 것이 중요한 하루입니다. 신중하게 생각하고 행동하세요.',
      },
      '말': {
        'emoji': '🐴',
        'description': '활기차고 역동적인 하루가 될 것입니다. 에너지를 긍정적인 방향으로 사용하세요.',
      },
      '양': {
        'emoji': '🐑',
        'description': '평화롭고 안정적인 하루입니다. 여유를 가지고 하루를 즐기세요.',
      },
      '원숭이': {
        'emoji': '🐵',
        'description': '창의적인 아이디어가 떠오르는 날입니다. 새로운 관점으로 문제를 바라보세요.',
      },
      '닭': {
        'emoji': '🐔',
        'description': '성실함이 빛을 발하는 하루입니다. 계획한 일을 착실하게 진행하세요.',
      },
      '개': {
        'emoji': '🐶',
        'description': '충실하고 성실한 태도가 인정받는 날입니다. 믿음을 바탕으로 행동하세요.',
      },
      '돼지': {
        'emoji': '🐷',
        'description': '복이 들어오는 하루입니다. 긍정적인 마음가짐으로 하루를 시작하세요.',
      },
    };

    return zodiacMap[zodiac] ?? {
      'emoji': '🌟',
      'description': '오늘은 평안하고 안정적인 하루가 될 것입니다.',
    };
  }

  /// 💫 주간 트렌드 카드
  Widget _buildWeeklyTrendCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주간 운세 트렌드',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '이번 주 당신의 운세 흐름',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF10B981) : const Color(0xFF34D399),
                isDark ? const Color(0xFF059669) : const Color(0xFF10B981),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Text(
                    '상승세',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '이번 주는 전반적으로 상승세를 타고 있습니다. 특히 수요일부터 금요일까지가 가장 좋은 시기입니다. 새로운 도전이나 중요한 결정을 내리기에 최적의 타이밍입니다.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 요일별 간단 정보 (생성시점 기준 고정!)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getWeeklyScores().asMap().entries.map((entry) {
            final index = entry.key;
            final dayScore = entry.value;
            final day = ['월', '화', '수', '목', '금', '토', '일'][index];
            final score = dayScore;
            return Container(
              width: (MediaQuery.of(context).size.width - 120) / 7,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: score >= 80
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(8),
                border: score >= 80
                    ? Border.all(color: const Color(0xFF10B981), width: 1.5)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score',
                    style: TextStyle(
                      color: score >= 80
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white60 : Colors.black54),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🎁 공유 카드
  Widget _buildShareCard(bool isDark) {
    // 현재 보고 있는 카드의 정보 가져오기
    final currentCardInfo = _getCurrentCardShareInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운세 공유하기',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '현재 보고 있는 카드를 공유해보세요',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 32),

        // SNS 스타일 카드
        GestureDetector(
          onTap: () => _shareCurrentCard(currentCardInfo),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentCardInfo['color'].withOpacity(0.8),
                  currentCardInfo['color'],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCardInfo['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateTime.now().toString().split(' ')[0],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (currentCardInfo['score'] != null)
                      Text(
                        '${currentCardInfo['score']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentCardInfo['message'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '공유하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          '💡 Tip: 카드를 탭하면 현재 보고 있는 내용을 공유할 수 있습니다.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

