import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/theme/typography_unified.dart';
import '../../../core/services/fortune_haptic_service.dart';
import '../../../core/services/page_turn_sound_service.dart';
import '../../../core/utils/fortune_text_cleaner.dart';
import '../../../domain/entities/fortune.dart' as fortune_entity;
import '../../../domain/entities/user_profile.dart';
import '../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../presentation/providers/location_provider.dart';
import '../../../services/weather_service.dart';

// 분리된 위젯들
import 'widgets/overall_card.dart';
import 'widgets/radar_card.dart';
import 'widgets/time_slot_card.dart';
import 'widgets/category_detail_card.dart';
import 'widgets/lucky_items_card.dart';
import 'widgets/saju_insight_card.dart';
import 'widgets/action_plan_card.dart';
import 'widgets/five_elements_card.dart';
import 'widgets/hourly_score_graph_card.dart';
import 'widgets/zodiac_fortune_card.dart';
import 'widgets/weekly_trend_card.dart';
import 'widgets/share_card.dart';
import 'widgets/celebrity_card.dart';
import 'utils/fortune_swipe_helpers.dart';

/// 세로 스와이프 카드 기반 운세 완료 페이지
class FortuneSwipePage extends ConsumerStatefulWidget {
  final fortune_entity.Fortune? fortune;
  final String? userName;
  final UserProfile? userProfile;
  final Map<String, dynamic>? overall;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? sajuInsight;
  final WeatherInfo? currentWeather;

  const FortuneSwipePage({
    super.key,
    this.fortune,
    this.userName,
    this.userProfile,
    this.overall,
    this.categories,
    this.sajuInsight,
    this.currentWeather,
  });

  @override
  ConsumerState<FortuneSwipePage> createState() => _FortuneSwipePageState();
}

class _FortuneSwipePageState extends ConsumerState<FortuneSwipePage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _initialHapticTriggered = false;

  int get totalScore => widget.fortune?.overallScore ?? 75;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).show();

        // 첫 페이지 로드 시 점수 공개 햅틱
        if (!_initialHapticTriggered) {
          _initialHapticTriggered = true;
          ref.read(fortuneHapticServiceProvider).scoreReveal(totalScore);
        }
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
      setState(() => _currentPage = page);
      // 페이지 스냅 시 햅틱 피드백 + 효과음
      ref.read(fortuneHapticServiceProvider).pageSnap();
      ref.read(pageTurnSoundServiceProvider).playPageTurn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String displayUserName = widget.userName ?? widget.userProfile?.name ?? '';
    if (displayUserName.isEmpty) {
      final user = Supabase.instance.client.auth.currentUser;
      displayUserName = user?.userMetadata?['name'] as String? ??
                       user?.userMetadata?['full_name'] as String? ?? '회원';
    }

    final score = widget.fortune?.overallScore ?? 75;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 한지 텍스처 배경
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.08 : 0.15,
                child: Image.asset(
                  'assets/images/hanji_texture.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
            // PageView
            Positioned.fill(
              top: 0,
              bottom: 0,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: 17,
                itemBuilder: (context, index) {
                  return _buildFullSizeCard(context, index, score, isDark, displayUserName, colors);
                },
              ),
            ),

            // 프로그레스 바
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentPage + 1) / 17,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3182F6), Color(0xFF1B64DA)]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // 고정 헤더
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: _buildHeader(context, displayUserName, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String displayUserName, DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            displayUserName,
            style: context.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  // 실제 GPS 위치일 때만 표시 (권한 거부 시 숨김)
                  final cityName = ref.displayableCityName;
                  if (cityName != null) {
                    return Row(
                      children: [
                        Text(
                          cityName,
                          style: context.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Text(
                '${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}',
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.currentWeather != null) ...[
                const SizedBox(width: 12),
                Text(
                  FortuneSwipeHelpers.getWeatherEmoji(widget.currentWeather!.condition),
                  style: context.labelMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.currentWeather!.temperature.round()}°',
                  style: context.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullSizeCard(BuildContext context, int index, int score, bool isDark, String displayUserName, DSColorScheme colors) {
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          // U06: ShareCard 등 긴 콘텐츠 스크롤 허용
          physics: const ClampingScrollPhysics(),
          child: _buildCardContent(context, index, score, isDark, displayUserName),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, int index, int score, bool isDark, String displayUserName) {
    switch (index) {
      case 0:
        return OverallCard(
          score: score,
          isDark: isDark,
          message: _getMainScoreMessage(score),
          subtitle: _getMainScoreSubtitle(),
          fullDescription: _getFullFortuneDescription(score),
        );
      case 1:
        return RadarCard(radarData: _getRadarChartDataDouble(score), isDark: isDark);
      case 2:
        return TimeSlotCard(timeSlots: _getTimeSlotAdvice(), isDark: isDark);
      case 3:
        return _buildCategoryCard('연애운', 'love', score, isDark);
      case 4:
        return _buildCategoryCard('금전운', 'money', score, isDark);
      case 5:
        return _buildCategoryCard('직장운', 'work', score, isDark);
      case 6:
        return _buildCategoryCard('학업운', 'study', score, isDark);
      case 7:
        return _buildCategoryCard('건강운', 'health', score, isDark);
      case 8:
        return LuckyItemsCard(luckyItems: _getLuckyItems(), isDark: isDark);
      case 9:
        return CelebrityCard(isDark: isDark);
      case 10:
        return SajuInsightCard(sajuData: _getSajuData(), isDark: isDark);
      case 11:
        return ActionPlanCard(actions: _getRealisticActionPlan(), isDark: isDark);
      case 12:
        final elementsData = _getDetailedFiveElementsData();
        return FiveElementsCard(
          elements: elementsData['elements'] as Map<String, int>,
          sajuInfo: elementsData['sajuInfo'] as Map<String, String?>,
          balance: elementsData['balance'] as String,
          explanation: elementsData['explanation'] as String,
          isDark: isDark,
        );
      case 13:
        final hourlyData = _getHourlyFortuneData();
        return HourlyScoreGraphCard(
          spots: hourlyData['spots'] as List<FlSpot>,
          bestHour: hourlyData['bestHour'] as int,
          worstHour: hourlyData['worstHour'] as int,
          isDark: isDark,
        );
      case 14:
        return ZodiacFortuneCard(zodiacFortunes: _getZodiacFortuneData(), isDark: isDark);
      case 15:
        return WeeklyTrendCard(weeklyScores: _getWeeklyScores(), isDark: isDark);
      case 16:
        return ShareCard(
          score: score,
          message: _getMainScoreMessage(score),
          isDark: isDark,
          categoryScores: _getCategoryScoresMap(),
          luckyItems: _getLuckyItems(),
          fiveElements: _getFiveElementsScoresMap(),
          userName: displayUserName,
          date: DateTime.now(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryCard(String title, String categoryKey, int baseScore, bool isDark) {
    final categoryData = _getCategoryData(categoryKey, baseScore);
    return CategoryDetailCard(
      title: title,
      categoryKey: categoryKey,
      score: categoryData['score'] as int,
      advice: FortuneTextCleaner.clean(categoryData['advice'] as String),
      isDark: isDark,
    );
  }

  // ========== Data Computation Methods ==========

  String _getMainScoreMessage(int score) {
    final idiom = widget.fortune?.metadata?['categories']?['total']?['advice']?['idiom'];
    if (idiom != null && idiom.toString().isNotEmpty) return idiom.toString();
    return FortuneSwipeHelpers.getScoreIdiom(score);
  }

  String? _getMainScoreSubtitle() {
    final description = widget.fortune?.metadata?['categories']?['total']?['advice']?['description'];
    if (description == null) return null;
    return FortuneTextCleaner.clean(description.toString());
  }

  String _getFullFortuneDescription(int score) {
    final fullDescription = widget.fortune?.metadata?['categories']?['total']?['advice']?['full_description'];
    if (fullDescription != null && fullDescription.toString().isNotEmpty) {
      return FortuneTextCleaner.clean(fullDescription.toString());
    }
    return FortuneSwipeHelpers.getFullFortuneDescription(score);
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
    return {'연애': 70.0, '금전': 75.0, '직장': 80.0, '학업': 70.0, '건강': 75.0};
  }

  Map<String, String> _getTimeSlotAdvice() {
    final dailyPredictions = widget.fortune?.metadata?['daily_predictions'];
    if (dailyPredictions != null && dailyPredictions['morning'] != null) {
      return {
        'morning': FortuneTextCleaner.clean(dailyPredictions['morning']?.toString() ?? ''),
        'afternoon': FortuneTextCleaner.clean(dailyPredictions['afternoon']?.toString() ?? ''),
        'evening': FortuneTextCleaner.clean(dailyPredictions['evening']?.toString() ?? ''),
      };
    }
    return FortuneSwipeHelpers.getFallbackTimeSlotAdvice(totalScore);
  }

  Map<String, dynamic> _getCategoryData(String categoryKey, int baseScore) {
    if (widget.categories != null && widget.categories![categoryKey] != null) {
      return widget.categories![categoryKey];
    }
    if (widget.fortune?.metadata?['categories']?[categoryKey] != null) {
      return widget.fortune!.metadata!['categories'][categoryKey];
    }
    return FortuneSwipeHelpers.getFallbackCategoryData(categoryKey, baseScore);
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
    return {'시간': '오전 10시', '색상': '파란색', '숫자': '7', '방향': '동쪽', '음식': '과일', '아이템': '시계'};
  }

  /// 카테고리별 점수 Map<String, int> 반환 (공유 카드용)
  Map<String, int> _getCategoryScoresMap() {
    if (widget.fortune?.metadata?['categories'] != null) {
      final categories = widget.fortune!.metadata!['categories'];
      return {
        'love': (categories['love']?['score'] as num?)?.toInt() ?? 70,
        'money': (categories['money']?['score'] as num?)?.toInt() ?? 75,
        'work': (categories['work']?['score'] as num?)?.toInt() ?? 80,
        'study': (categories['study']?['score'] as num?)?.toInt() ?? 70,
        'health': (categories['health']?['score'] as num?)?.toInt() ?? 75,
      };
    }
    return {'love': 70, 'money': 75, 'work': 80, 'study': 70, 'health': 75};
  }

  /// 오행 점수 Map<String, int> 반환 (공유 카드용)
  Map<String, int> _getFiveElementsScoresMap() {
    final apiElements = widget.fortune?.fiveElements;
    if (apiElements != null && apiElements['wood'] != null) {
      return {
        'wood': (apiElements['wood'] as num).toInt(),
        'fire': (apiElements['fire'] as num).toInt(),
        'earth': (apiElements['earth'] as num).toInt(),
        'metal': (apiElements['metal'] as num).toInt(),
        'water': (apiElements['water'] as num).toInt(),
      };
    }
    return {'wood': 20, 'fire': 15, 'earth': 25, 'metal': 20, 'water': 20};
  }

  Map<String, String?> _getSajuData() {
    final sajuInsight = widget.fortune?.sajuInsight;
    if (sajuInsight != null && sajuInsight['year_pillar'] != null) {
      return {
        'year_pillar': sajuInsight['year_pillar']?.toString(),
        'month_pillar': sajuInsight['month_pillar']?.toString(),
        'day_pillar': sajuInsight['day_pillar']?.toString(),
        'hour_pillar': sajuInsight['hour_pillar']?.toString(),
        'insight': sajuInsight['insight']?.toString(),
      };
    }
    return {'year_pillar': '갑자', 'month_pillar': '병인', 'day_pillar': '무진', 'hour_pillar': '경오'};
  }

  List<Map<String, String>> _getRealisticActionPlan() {
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
    return FortuneSwipeHelpers.getScoreBasedActionPlan(totalScore);
  }

  Map<String, dynamic> _getDetailedFiveElementsData() {
    final sajuInfo = _getSajuData();
    final apiElements = widget.fortune?.fiveElements;

    if (apiElements != null && apiElements['wood'] != null) {
      final elementsData = {
        '목(木)': (apiElements['wood'] as num).toInt(),
        '화(火)': (apiElements['fire'] as num).toInt(),
        '토(土)': (apiElements['earth'] as num).toInt(),
        '금(金)': (apiElements['metal'] as num).toInt(),
        '수(水)': (apiElements['water'] as num).toInt(),
      };
      return {
        'elements': elementsData,
        'sajuInfo': sajuInfo,
        'balance': apiElements['balance']?.toString() ?? FortuneSwipeHelpers.calculateBalance(elementsData),
        'explanation': apiElements['explanation']?.toString() ?? FortuneSwipeHelpers.generateElementExplanation(elementsData),
      };
    }

    final birthDate = DateTime.tryParse(widget.fortune?.metadata?['birth_date']?.toString() ?? '');
    final elementsData = FortuneSwipeHelpers.calculateElementsFromBirthDate(birthDate);
    return {
      'elements': elementsData,
      'sajuInfo': sajuInfo,
      'balance': FortuneSwipeHelpers.calculateBalance(elementsData),
      'explanation': FortuneSwipeHelpers.generateElementExplanation(elementsData),
    };
  }

  Map<String, dynamic> _getHourlyFortuneData() {
    final timeFortunes = widget.fortune?.timeSpecificFortunes ?? [];
    final List<FlSpot> spots = [];

    if (timeFortunes.isNotEmpty && timeFortunes.length >= 24) {
      for (int i = 0; i < 24; i++) {
        final score = i < timeFortunes.length ? timeFortunes[i].score.toDouble() : 50.0;
        spots.add(FlSpot(i.toDouble(), score));
      }
    } else {
      final baseScore = totalScore;
      for (int i = 0; i < 24; i++) {
        double variation = 0;
        if (i >= 0 && i < 6) {
          variation = -10;
        } else if (i >= 6 && i < 12) {
          variation = 5 + (i - 6) * 2;
        } else if (i >= 12 && i < 18) {
          variation = 10 - (i - 12);
        } else {
          variation = 5 - (i - 18) * 2;
        }
        spots.add(FlSpot(i.toDouble(), (baseScore + variation).clamp(30.0, 100.0)));
      }
    }

    double bestScore = spots.isNotEmpty ? spots[0].y : 50.0;
    double worstScore = spots.isNotEmpty ? spots[0].y : 50.0;
    int bestHour = 0, worstHour = 0;

    for (int i = 1; i < spots.length; i++) {
      if (spots[i].y > bestScore) { bestScore = spots[i].y; bestHour = i; }
      if (spots[i].y < worstScore) { worstScore = spots[i].y; worstHour = i; }
    }

    return {'spots': spots, 'bestHour': bestHour, 'worstHour': worstHour};
  }

  List<Map<String, dynamic>> _getZodiacFortuneData() {
    final userBirthDate = widget.userProfile?.birthdate;
    final birthYearFortunes = widget.fortune?.birthYearFortunes ?? [];

    if (birthYearFortunes.isNotEmpty && userBirthDate != null) {
      final userYear = userBirthDate.year;
      final userZodiac = FortuneSwipeHelpers.getZodiacFromYear(userYear);

      return birthYearFortunes.take(3).map((fortune) {
        final zodiacInfo = FortuneSwipeHelpers.getZodiacInfo(fortune.zodiacAnimal);
        return {
          'year': fortune.birthYear,
          'name': fortune.zodiacAnimal,
          'emoji': zodiacInfo['emoji'],
          'description': fortune.description,
          'score': 75,
          'isUser': fortune.birthYear == userYear.toString() || fortune.zodiacAnimal == userZodiac,
        };
      }).toList();
    }

    final birthDate = userBirthDate ?? DateTime(1990, 1, 1);
    final userYear = birthDate.year;
    final userZodiac = FortuneSwipeHelpers.getZodiacFromYear(userYear);
    final zodiacInfo = FortuneSwipeHelpers.getZodiacInfo(userZodiac);
    final baseScore = totalScore;

    return [
      {
        'year': (userYear - 1).toString(),
        'name': FortuneSwipeHelpers.getZodiacFromYear(userYear - 1),
        'emoji': FortuneSwipeHelpers.getZodiacInfo(FortuneSwipeHelpers.getZodiacFromYear(userYear - 1))['emoji'],
        'description': FortuneSwipeHelpers.getZodiacInfo(FortuneSwipeHelpers.getZodiacFromYear(userYear - 1))['description'],
        'score': (baseScore - 8).clamp(40, 100),
        'isUser': false,
      },
      {
        'year': userYear.toString(),
        'name': userZodiac,
        'emoji': zodiacInfo['emoji'],
        'description': zodiacInfo['description'],
        'score': baseScore,
        'isUser': true,
      },
      {
        'year': (userYear + 1).toString(),
        'name': FortuneSwipeHelpers.getZodiacFromYear(userYear + 1),
        'emoji': FortuneSwipeHelpers.getZodiacInfo(FortuneSwipeHelpers.getZodiacFromYear(userYear + 1))['emoji'],
        'description': FortuneSwipeHelpers.getZodiacInfo(FortuneSwipeHelpers.getZodiacFromYear(userYear + 1))['description'],
        'score': (baseScore + 5).clamp(40, 100),
        'isUser': false,
      },
    ];
  }

  List<int> _getWeeklyScores() {
    final baseScore = totalScore;
    return [
      (baseScore - 5).clamp(40, 100),
      (baseScore - 2).clamp(40, 100),
      (baseScore + 8).clamp(40, 100),
      (baseScore + 10).clamp(40, 100),
      (baseScore + 5).clamp(40, 100),
      (baseScore + 3).clamp(40, 100),
      baseScore.clamp(40, 100),
    ];
  }
}
