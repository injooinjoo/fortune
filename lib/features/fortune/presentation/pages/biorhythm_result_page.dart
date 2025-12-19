import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../widgets/biorhythm_widgets.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../core/services/fortune_haptic_service.dart';
class BiorhythmResultPage extends ConsumerStatefulWidget {
  final DateTime birthDate;
  final FortuneResult fortuneResult; // API 결과

  const BiorhythmResultPage({
    super.key,
    required this.birthDate,
    required this.fortuneResult,
  });

  @override
  ConsumerState<BiorhythmResultPage> createState() => _BiorhythmResultPageState();
}

class _BiorhythmResultPageState extends ConsumerState<BiorhythmResultPage>
    with TickerProviderStateMixin {

  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  late BiorhythmData _biorhythmData;
  late FortuneResult _fortuneResult;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _biorhythmData = BiorhythmData.fromApiResult(widget.birthDate, widget.fortuneResult);
    _fortuneResult = widget.fortuneResult;
    _fadeController.forward();

    // 바이오리듬 결과 공개 햅틱
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final score = _fortuneResult.score ?? 70;
        ref.read(fortuneHapticServiceProvider).scoreReveal(score);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    ref.read(fortuneHapticServiceProvider).pageSnap();
  }

  // 광고 보고 블러 해제
  Future<void> _showAdAndUnblur() async {
    try {
      final adService = AdService();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        await adService.loadRewardedAd();
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고 로딩에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          Logger.info('[BiorhythmResultPage] Rewarded ad watched, removing blur');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[BiorhythmResultPage] Failed to show ad', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSBiorhythmColors.getHanjiBackground(isDark);
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return Scaffold(
      backgroundColor: hanjiBackground,
      body: Stack(
        children: [
          // Hanji texture background
          Positioned.fill(
            child: CustomPaint(
              painter: _HanjiTexturePainter(isDark: isDark),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Traditional style header
                _buildTraditionalHeader(isDark, textColor),

                // 페이지 인디케이터 (Traditional style)
                _buildTraditionalPageIndicator(isDark),

                // 메인 콘텐츠
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        _buildTodayStatusPage(),
                        _buildWeeklyTrendPage(),
                        _buildPersonalAdvicePage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 광고 보고 전체 보기 버튼 (3번째 페이지 + 블러 상태일 때만, 구독자 제외)
          if (_currentPage == 2 && _fortuneResult.isBlurred && !ref.watch(isPremiumProvider))
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: _buildTraditionalAdButton(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildTraditionalHeader(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 48), // Balance for close button
          Expanded(
            child: Column(
              children: [
                Text(
                  '바이오리듬 분석',
                  style: context.heading3.copyWith(
                    fontFamily: 'GowunBatang',
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: DSBiorhythmColors.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DSBiorhythmColors.goldAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatTraditionalDate(),
                    style: context.labelMedium.copyWith(
                      fontFamily: 'GowunBatang',
                      color: DSBiorhythmColors.goldAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Traditional close button (seal style)
          GestureDetector(
            onTap: () => context.go('/fortune'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DSBiorhythmColors.getInkWashGuide(isDark).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: textColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '閉',
                  style: context.bodyMedium.copyWith(
                    fontFamily: 'GowunBatang',
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTraditionalDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  Widget _buildTraditionalPageIndicator(bool isDark) {
    final textColor = DSBiorhythmColors.getInkBleed(isDark);
    final pageLabels = ['오늘', '주간', '조언'];
    final pageHanja = ['今', '週', '言'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isSelected = _currentPage == index;
          final color = _getPageColor(index, isDark);

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.5)
                      : textColor.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hanja character in seal style
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.8)
                          : textColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        pageHanja[index],
                        style: context.labelMedium.copyWith(
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pageLabels[index],
                    style: context.labelMedium.copyWith(
                      fontFamily: 'GowunBatang',
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? color
                          : textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getPageColor(int index, bool isDark) {
    switch (index) {
      case 0: // 오늘 - Physical (Fire)
        return DSBiorhythmColors.getPhysical(isDark);
      case 1: // 주간 - Emotional (Wood)
        return DSBiorhythmColors.getEmotional(isDark);
      case 2: // 조언 - Intellectual (Water)
        return DSBiorhythmColors.getIntellectual(isDark);
      default:
        return DSBiorhythmColors.getInkBleed(isDark);
    }
  }

  Widget _buildTraditionalAdButton(bool isDark) {
    return GestureDetector(
      onTap: _showAdAndUnblur,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DSBiorhythmColors.getPhysical(isDark),
              DSBiorhythmColors.getEmotional(isDark),
              DSBiorhythmColors.getIntellectual(isDark),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: DSBiorhythmColors.getPhysical(isDark).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '解',
                  style: context.bodySmall.copyWith(
                    fontFamily: 'GowunBatang',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '남은 풀이 모두 보기',
              style: context.bodyMedium.copyWith(
                fontFamily: 'GowunBatang',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatusPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 오늘의 전체 컨디션
          TodayOverallStatusCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 3가지 리듬 상세
          RhythmDetailCards(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 오늘의 추천
          TodayRecommendationCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 주간 전망 헤더
          WeeklyForecastHeader(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 주간 차트
          WeeklyRhythmChart(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 주요 날짜들
          ImportantDatesCard(biorhythmData: _biorhythmData),
          const SizedBox(height: 20),
          
          // 주간 활동 가이드
          WeeklyActivityGuide(biorhythmData: _biorhythmData),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPersonalAdvicePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 개인 맞춤 분석 (블러 처리)
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult.isBlurred,
            blurredSections: ['personal_analysis', 'lifestyle_advice', 'health_tips'],
            sectionKey: 'personal_analysis',
            child: PersonalAnalysisCard(biorhythmData: _biorhythmData),
          ),
          const SizedBox(height: 20),

          // 라이프 스타일 조언 (블러 처리)
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult.isBlurred,
            blurredSections: ['personal_analysis', 'lifestyle_advice', 'health_tips'],
            sectionKey: 'lifestyle_advice',
            child: LifestyleAdviceCard(biorhythmData: _biorhythmData),
          ),
          const SizedBox(height: 20),

          // 건강 관리 팁 (블러 처리)
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult.isBlurred,
            blurredSections: ['personal_analysis', 'lifestyle_advice', 'health_tips'],
            sectionKey: 'health_tips',
            child: HealthTipsCard(biorhythmData: _biorhythmData),
          ),
          const SizedBox(height: 20),

          // 다음 분석 예약
          NextAnalysisCard(),
          const SizedBox(height: 120), // 버튼 공간 확보
        ],
      ),
    );
  }

  // ✅ _buildBlurredCard 제거 - UnifiedBlurWrapper 사용
}

class BiorhythmData {
  final DateTime birthDate;
  final DateTime today;
  final int totalDays;
  
  // 오늘의 리듬 값 (-100 ~ 100)
  final double physicalToday;
  final double emotionalToday;
  final double intellectualToday;
  
  // 주간 데이터 (7일)
  final List<double> physicalWeek;
  final List<double> emotionalWeek;
  final List<double> intellectualWeek;
  
  // 전체 점수
  final int overallScore;
  final String statusMessage;
  final Color statusColor;

  BiorhythmData._({
    required this.birthDate,
    required this.today,
    required this.totalDays,
    required this.physicalToday,
    required this.emotionalToday,
    required this.intellectualToday,
    required this.physicalWeek,
    required this.emotionalWeek,
    required this.intellectualWeek,
    required this.overallScore,
    required this.statusMessage,
    required this.statusColor,
  });

  // API 결과에서 생성
  factory BiorhythmData.fromApiResult(DateTime birthDate, FortuneResult fortuneResult) {
    final data = fortuneResult.data;
    final today = DateTime.now();
    final totalDays = today.difference(birthDate).inDays;

    // API 결과에서 값 추출
    final physical = data['physical'] as Map<String, dynamic>? ?? {};
    final emotional = data['emotional'] as Map<String, dynamic>? ?? {};
    final intellectual = data['intellectual'] as Map<String, dynamic>? ?? {};

    final physicalToday = (physical['value'] as num?)?.toDouble() ?? 0.0;
    final emotionalToday = (emotional['value'] as num?)?.toDouble() ?? 0.0;
    final intellectualToday = (intellectual['value'] as num?)?.toDouble() ?? 0.0;

    // 주간 데이터 계산 (클라이언트에서 직접 계산)
    final physicalWeek = <double>[];
    final emotionalWeek = <double>[];
    final intellectualWeek = <double>[];

    for (int i = 0; i < 7; i++) {
      final dayOffset = totalDays + i;
      physicalWeek.add(math.sin(2 * math.pi * dayOffset / 23) * 100);
      emotionalWeek.add(math.sin(2 * math.pi * dayOffset / 28) * 100);
      intellectualWeek.add(math.sin(2 * math.pi * dayOffset / 33) * 100);
    }

    final overallScore = (data['overall_score'] as num?)?.toInt() ?? 50;
    final statusMessage = data['status_message'] as String? ?? '평균적인 상태예요';

    // 상태 메시지에 따른 색상 결정
    Color statusColor;
    if (overallScore >= 80) {
      statusColor = const Color(0xFF00C851);
    } else if (overallScore >= 60) {
      statusColor = const Color(0xFF00C896);
    } else if (overallScore >= 40) {
      statusColor = const Color(0xFFFFB300);
    } else if (overallScore >= 20) {
      statusColor = const Color(0xFFFF9500);
    } else {
      statusColor = const Color(0xFFFF5A5F);
    }

    return BiorhythmData._(
      birthDate: birthDate,
      today: today,
      totalDays: totalDays,
      physicalToday: physicalToday,
      emotionalToday: emotionalToday,
      intellectualToday: intellectualToday,
      physicalWeek: physicalWeek,
      emotionalWeek: emotionalWeek,
      intellectualWeek: intellectualWeek,
      overallScore: overallScore,
      statusMessage: statusMessage,
      statusColor: statusColor,
    );
  }

  factory BiorhythmData.calculate(DateTime birthDate) {
    final today = DateTime.now();
    final totalDays = today.difference(birthDate).inDays;

    // 바이오리듬 계산 (각각 23일, 28일, 33일 주기)
    final physicalToday = math.sin(2 * math.pi * totalDays / 23) * 100;
    final emotionalToday = math.sin(2 * math.pi * totalDays / 28) * 100;
    final intellectualToday = math.sin(2 * math.pi * totalDays / 33) * 100;

    // 주간 데이터 계산
    final physicalWeek = <double>[];
    final emotionalWeek = <double>[];
    final intellectualWeek = <double>[];

    for (int i = 0; i < 7; i++) {
      final dayOffset = totalDays + i;
      physicalWeek.add(math.sin(2 * math.pi * dayOffset / 23) * 100);
      emotionalWeek.add(math.sin(2 * math.pi * dayOffset / 28) * 100);
      intellectualWeek.add(math.sin(2 * math.pi * dayOffset / 33) * 100);
    }

    // 전체 점수 계산
    final averageScore = (physicalToday + emotionalToday + intellectualToday) / 3;
    final overallScore = (averageScore + 100) ~/ 2; // 0-100 점수로 변환

    // 상태 메시지 결정
    String statusMessage;
    Color statusColor;

    if (overallScore >= 80) {
      statusMessage = '최고의 컨디션이에요!';
      statusColor = const Color(0xFF00C851);
    } else if (overallScore >= 60) {
      statusMessage = '좋은 컨디션입니다';
      statusColor = const Color(0xFF00C896);
    } else if (overallScore >= 40) {
      statusMessage = '평균적인 상태예요';
      statusColor = const Color(0xFFFFB300);
    } else if (overallScore >= 20) {
      statusMessage = '조금 주의가 필요해요';
      statusColor = const Color(0xFFFF9500);
    } else {
      statusMessage = '충분한 휴식이 필요해요';
      statusColor = const Color(0xFFFF5A5F);
    }

    return BiorhythmData._(
      birthDate: birthDate,
      today: today,
      totalDays: totalDays,
      physicalToday: physicalToday,
      emotionalToday: emotionalToday,
      intellectualToday: intellectualToday,
      physicalWeek: physicalWeek,
      emotionalWeek: emotionalWeek,
      intellectualWeek: intellectualWeek,
      overallScore: overallScore,
      statusMessage: statusMessage,
      statusColor: statusColor,
    );
  }
  
  // 리듬별 점수 (0-100)
  int get physicalScore => ((physicalToday + 100) / 2).round();
  int get emotionalScore => ((emotionalToday + 100) / 2).round();
  int get intellectualScore => ((intellectualToday + 100) / 2).round();
  
  // 리듬별 상태 텍스트
  String get physicalStatus {
    if (physicalScore >= 75) return '활력 넘치는 상태';
    if (physicalScore >= 50) return '안정적인 체력';
    if (physicalScore >= 25) return '약간 피곤한 상태';
    return '충분한 휴식 필요';
  }
  
  String get emotionalStatus {
    if (emotionalScore >= 75) return '기분이 매우 좋은 날';
    if (emotionalScore >= 50) return '감정이 안정적';
    if (emotionalScore >= 25) return '약간 예민할 수 있음';
    return '감정 관리에 주의';
  }
  
  String get intellectualStatus {
    if (intellectualScore >= 75) return '집중력이 뛰어난 날';
    if (intellectualScore >= 50) return '사고력이 좋음';
    if (intellectualScore >= 25) return '집중하기 어려울 수 있음';
    return '복잡한 일은 피하세요';
  }
}

/// Hanji paper texture background painter
class _HanjiTexturePainter extends CustomPainter {
  final bool isDark;

  _HanjiTexturePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final textureColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.02);

    // Draw subtle fiber texture
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 6 + random.nextDouble() * 15;
      final angle = random.nextDouble() * math.pi;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + length * math.cos(angle), y + length * math.sin(angle)),
        Paint()
          ..color = textureColor
          ..strokeWidth = 0.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HanjiTexturePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}