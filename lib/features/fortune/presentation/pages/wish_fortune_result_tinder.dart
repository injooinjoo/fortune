import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import '../../domain/models/wish_fortune_result.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 틴더 스타일 소원 빌기 결과 페이지
class WishFortuneResultTinder extends ConsumerStatefulWidget {
  final WishFortuneResult result;
  final String wishText;
  final String category;
  final int urgency;

  const WishFortuneResultTinder({
    super.key,
    required this.result,
    required this.wishText,
    required this.category,
    required this.urgency,
  });

  @override
  ConsumerState<WishFortuneResultTinder> createState() => _WishFortuneResultTinderState();
}

class _WishFortuneResultTinderState extends ConsumerState<WishFortuneResultTinder> {
  late PageController _pageController;
  int _currentPage = 0;

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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 56.0 + bottomPadding;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // PageView (틴더 카드 스타일)
          Positioned.fill(
            bottom: navBarHeight,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildFullSizeCard(context, index, isDark);
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
                widthFactor: (_currentPage + 1) / 10,
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

          // 고정 헤더
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
                    '신의 응답',
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

  /// 풀사이즈 카드 빌더
  Widget _buildFullSizeCard(BuildContext context, int index, bool isDark) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          physics: const NeverScrollableScrollPhysics(),
          child: _buildCardContent(context, index, isDark),
        ),
      ),
    );
  }

  /// 카드 내용 빌더
  Widget _buildCardContent(BuildContext context, int index, bool isDark) {
    switch (index) {
      case 0:
        return _buildOverallCard(isDark);
      case 1:
        return _buildWishAnalysisCard(isDark);
      case 2:
        return _buildRealizationCard(isDark);
      case 3:
        return _buildTimelineCard(isDark);
      case 4:
        return _buildLuckyElementsCard(isDark);
      case 5:
        return _buildWarningsCard(isDark);
      case 6:
        return _buildActionPlanCard(isDark);
      case 7:
        return _buildSpiritualMessageCard(isDark);
      case 8:
        return _buildStatisticsCard(isDark);
      case 9:
        return _buildShareCard(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 1. 총평 카드
  Widget _buildOverallCard(bool isDark) {
    final score = widget.result.overallScore;
    final scoreColor = _getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '신의 응답',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),

        // 점수 카드
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
                .scale(begin: const Offset(0.9, 0.9), duration: 500.ms),
              const SizedBox(height: 6),
              Text(
                'POINTS',
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.35),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 28),
              Stack(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
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
        ),

        const SizedBox(height: 16),

        // 신의 메시지
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
            widget.result.divineMessage,
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: -0.2,
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 300.ms)
          .slideY(begin: 0.06, duration: 500.ms, delay: 300.ms),
      ],
    );
  }

  /// 2. 소원 분석 카드
  Widget _buildWishAnalysisCard(bool isDark) {
    final analysis = widget.result.wishAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소원 분석',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '당신의 소원을 깊이 분석했어요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        // 소원 텍스트
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TossDesignSystem.tossBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: TossDesignSystem.tossBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '당신의 소원',
                    style: TextStyle(
                      color: TossDesignSystem.tossBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.wishText,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '카테고리: ${widget.category}  •  긴급도: ${widget.urgency}/5',
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 키워드
        _buildInfoCard(
          isDark,
          '핵심 키워드',
          Icons.key,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.keywords.map((keyword) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.tossBlue.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: TossDesignSystem.tossBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // 진심도
        _buildInfoCard(
          isDark,
          '진심도',
          Icons.favorite,
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: analysis.sincerityScore / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: TossDesignSystem.errorRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${analysis.sincerityScore}점',
                style: TextStyle(
                  color: TossDesignSystem.errorRed,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3. 실현 가능성 카드
  Widget _buildRealizationCard(bool isDark) {
    final realization = widget.result.realization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실현 가능성',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        // 확률 원형 그래프
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: realization.probability / 100,
                  strokeWidth: 12,
                  backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(realization.probability)),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${realization.probability}%',
                    style: TextStyle(
                      color: _getScoreColor(realization.probability),
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '실현 확률',
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ).animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
        ),

        const SizedBox(height: 32),

        // 실현 조건
        Text(
          '실현을 위한 조건',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...realization.conditions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 4. 타임라인 카드
  Widget _buildTimelineCard(bool isDark) {
    final timeline = widget.result.realization.timeline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '예상 실현 시기',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TossDesignSystem.tossBlue,
                TossDesignSystem.tossBlue.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                timeline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '인내와 노력이 필요합니다',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.9, 0.9), duration: 500.ms),
      ],
    );
  }

  /// 5. 행운 요소 카드
  Widget _buildLuckyElementsCard(bool isDark) {
    final lucky = widget.result.luckyElements;
    final Color luckyColor = _parseColor(lucky.colorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '행운 요소',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '이것들이 행운을 불러올 거예요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        // 행운의 색상
        _buildLuckyItem(
          isDark,
          '행운의 색상',
          Icons.palette,
          lucky.color,
          luckyColor,
        ),
        const SizedBox(height: 12),

        // 행운의 방향
        _buildLuckyItem(
          isDark,
          '행운의 방향',
          Icons.explore,
          lucky.direction,
          TossDesignSystem.tossBlue,
        ),
        const SizedBox(height: 12),

        // 행운의 시간
        _buildLuckyItem(
          isDark,
          '행운의 시간',
          Icons.access_time,
          lucky.time,
          TossDesignSystem.warningOrange,
        ),
      ],
    );
  }

  /// 6. 주의사항 카드
  Widget _buildWarningsCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주의사항',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '이것들은 피하는 게 좋아요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        ...widget.result.warnings.map((warning) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.errorRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: TossDesignSystem.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 7. 액션 플랜 카드
  Widget _buildActionPlanCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '행동 계획',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '이렇게 행동하세요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        ...widget.result.actionPlan.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: TossDesignSystem.successGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: entry.key * 100))
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms),
          );
        }).toList(),
      ],
    );
  }

  /// 8. 영적 메시지 카드
  Widget _buildSpiritualMessageCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '영적 메시지',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                widget.result.spiritualMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.9, 0.9), duration: 600.ms),
      ],
    );
  }

  /// 9. 통계 카드
  Widget _buildStatisticsCard(bool isDark) {
    final stats = widget.result.statistics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '유사 소원 통계',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '다른 사람들의 결과를 참고하세요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        // 유사 소원 수
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
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: TossDesignSystem.tossBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '비슷한 소원',
                      style: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.similarWishes.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 성취율
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
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: TossDesignSystem.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: TossDesignSystem.successGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '평균 성취율',
                      style: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.successRate}%',
                      style: TextStyle(
                        color: TossDesignSystem.successGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 10. 공유 카드
  Widget _buildShareCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.celebration,
          color: TossDesignSystem.tossBlue,
          size: 64,
        ),
        const SizedBox(height: 24),
        Text(
          '소원이 이루어지길\n응원합니다!',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '친구들에게 공유해보세요',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _shareResult(),
            icon: const Icon(Icons.share),
            label: const Text('결과 공유하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TossDesignSystem.tossBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 헬퍼 메서드들
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return TossDesignSystem.tossBlue;
    }
  }

  Widget _buildInfoCard(bool isDark, String title, IconData icon, Widget content) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TossDesignSystem.tossBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildLuckyItem(bool isDark, String title, IconData icon, String value, Color color) {
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareResult() {
    final shareText = '''
🌟 신의 응답을 받았어요!

소원: ${widget.wishText}
점수: ${widget.result.overallScore}점
실현 확률: ${widget.result.realization.probability}%

${widget.result.divineMessage}

#소원빌기 #운세 #포춘
''';

    Share.share(shareText);
  }
}
