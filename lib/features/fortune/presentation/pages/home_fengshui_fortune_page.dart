import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../widgets/home_fengshui_input_unified.dart';
import '../../domain/models/conditions/home_fengshui_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';

/// 집 풍수 진단 페이지 (UnifiedFortuneBaseWidget 사용)
class HomeFengshuiFortunePage extends ConsumerStatefulWidget {
  const HomeFengshuiFortunePage({super.key});

  @override
  ConsumerState<HomeFengshuiFortunePage> createState() => _HomeFengshuiFortunePageState();
}

class _HomeFengshuiFortunePageState extends ConsumerState<HomeFengshuiFortunePage> {
  String? _address;
  String? _homeType;
  int? _floor;
  String? _doorDirection;

  // Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // GPT 스타일 타이핑 효과
  int _currentTypingSection = 0;

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'home-fengshui',
      title: '집 풍수',
      description: '우리 집의 풍수 기운을 진단해드립니다',
      dataSource: FortuneDataSource.api,
      // 입력 UI
      inputBuilder: (context, onComplete) {
        return HomeFengshuiInputUnified(
          onComplete: (address, homeType, floor, doorDirection) {
            setState(() {
              _address = address;
              _homeType = homeType;
              _floor = floor;
              _doorDirection = doorDirection;
            });
            onComplete();
          },
        );
      },

      // 조건 객체 생성
      conditionsBuilder: () async {
        return HomeFengshuiFortuneConditions(
          address: _address ?? '',
          homeType: _homeType ?? '',
          floor: _floor ?? 1,
          doorDirection: _doorDirection ?? '',
        );
      },

      // 결과 표시 UI
      resultBuilder: (context, result) {
        // result.isBlurred 동기화
        if (_isBlurred != result.isBlurred || _blurredSections.length != result.blurredSections.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections = List<String>.from(result.blurredSections);
                _currentTypingSection = 0;
              });
            }
          });
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final data = result.data;

        // API에서 받은 데이터 추출
        final title = FortuneTextCleaner.clean(data['title'] as String? ?? '집 풍수 진단');
        final overallAnalysis = FortuneTextCleaner.cleanNullable(data['overall_analysis'] as String?);
        final score = result.score ?? 50;

        // 배산임수 분석
        final baesanImsu = data['baesan_imsu'] as Map<String, dynamic>?;
        final mountainPresence = FortuneTextCleaner.cleanNullable(baesanImsu?['mountain_presence'] as String?);
        final waterPresence = FortuneTextCleaner.cleanNullable(baesanImsu?['water_presence'] as String?);
        final roadImpact = FortuneTextCleaner.cleanNullable(baesanImsu?['road_impact'] as String?);
        final terrainScore = baesanImsu?['terrain_score'] as int? ?? 70;
        final terrainAnalysis = FortuneTextCleaner.cleanNullable(baesanImsu?['terrain_analysis'] as String?);

        // 양택풍수 분석
        final yangtaek = data['yangtaek_analysis'] as Map<String, dynamic>?;
        final homeDirection = FortuneTextCleaner.cleanNullable(yangtaek?['home_direction'] as String?);
        final doorDirection = FortuneTextCleaner.cleanNullable(yangtaek?['door_direction'] as String?);
        final compatibility = yangtaek?['compatibility'] as int? ?? 70;
        final directionAnalysis = FortuneTextCleaner.cleanNullable(yangtaek?['direction_analysis'] as String?);

        // 내부 공간 배치
        final interior = data['interior_layout'] as Map<String, dynamic>?;

        // 기운 흐름
        final energyFlow = data['energy_flow'] as Map<String, dynamic>?;
        final qiCirculation = FortuneTextCleaner.cleanNullable(energyFlow?['qi_circulation'] as String?);
        final brightAreas = (energyFlow?['bright_areas'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final darkAreas = (energyFlow?['dark_areas'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
        final suggestions = (energyFlow?['suggestions'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];

        // 결함 및 해결책
        final defects = data['defects_and_solutions'] as Map<String, dynamic>?;
        final majorDefects = (defects?['major_defects'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        final minorDefects = (defects?['minor_defects'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

        // 행운 요소
        final luckyElements = data['lucky_elements'] as Map<String, dynamic>?;
        final luckyColors = (luckyElements?['colors'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        final luckyPlants = (luckyElements?['plants'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        final luckyItems = (luckyElements?['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

        // 계절별 조언
        final seasonal = data['seasonal_advice'] as Map<String, dynamic>?;

        // 요약
        final summaryData = data['summary'] as Map<String, dynamic>?;
        final summaryKeyword = summaryData?['one_line'] as String? ?? '';

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, _isBlurred ? 140 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    title,
                    style: TypographyUnified.heading2.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 운세 점수 카드 (공개)
                  _buildScoreCard(score, summaryKeyword, isDark),
                  const SizedBox(height: 20),

                  // 전반적인 분석 (공개)
                  if (overallAnalysis.isNotEmpty)
                    _buildSectionCard(
                      title: '전반적인 분석',
                      icon: Icons.analytics_outlined,
                      content: overallAnalysis,
                      isDark: isDark,
                      sectionIndex: 0,
                      onTypingComplete: () {
                        if (mounted) setState(() => _currentTypingSection = 1);
                      },
                    ),
                  const SizedBox(height: 16),

                  // 배산임수 분석 (블러)
                  if (baesanImsu != null)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'baesan_imsu',
                      child: _buildBaesanImsuCard(
                        mountainPresence: mountainPresence,
                        waterPresence: waterPresence,
                        roadImpact: roadImpact,
                        terrainScore: terrainScore,
                        terrainAnalysis: terrainAnalysis,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 양택풍수 분석 (블러)
                  if (yangtaek != null)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'yangtaek_analysis',
                      child: _buildYangtaekCard(
                        homeDirection: homeDirection,
                        doorDirection: doorDirection,
                        compatibility: compatibility,
                        directionAnalysis: directionAnalysis,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 내부 공간 배치 (블러)
                  if (interior != null)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'interior_layout',
                      child: _buildInteriorLayoutCard(interior, isDark),
                    ),
                  const SizedBox(height: 16),

                  // 기운 흐름 (블러)
                  if (energyFlow != null)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'energy_flow',
                      child: _buildEnergyFlowCard(
                        qiCirculation: qiCirculation,
                        brightAreas: brightAreas,
                        darkAreas: darkAreas,
                        suggestions: suggestions,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 결함 및 해결책 (블러)
                  if (defects != null && (majorDefects.isNotEmpty || minorDefects.isNotEmpty))
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'defects_and_solutions',
                      child: _buildDefectsCard(
                        majorDefects: majorDefects,
                        minorDefects: minorDefects,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 행운 요소 (블러)
                  if (luckyElements != null)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'lucky_elements',
                      child: _buildLuckyElementsCard(
                        colors: luckyColors,
                        plants: luckyPlants,
                        items: luckyItems,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 계절별 조언 (블러)
                  if (seasonal != null)
                    UnifiedBlurWrapper(
                      isBlurred: _isBlurred,
                      blurredSections: _blurredSections,
                      sectionKey: 'seasonal_advice',
                      child: _buildSeasonalAdviceCard(seasonal, isDark),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // FloatingBottomButton (블러 상태일 때만)
            if (_isBlurred)
              UnifiedButton.floating(
                text: '광고 보고 전체 내용 확인하기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
              ),
          ],
        );
      },
    );
  }

  /// 광고 보고 블러 제거
  Future<void> _showAdAndUnblur() async {
    try {
      final adService = AdService();

      if (!adService.isRewardedAdReady) {
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, rewardItem) {
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('집 풍수 진단이 잠금 해제되었습니다!')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
      }
    }
  }

  /// 운세 점수 카드
  Widget _buildScoreCard(int score, String keyword, bool isDark) {
    Color scoreColor;
    String scoreText;
    if (score >= 80) {
      scoreColor = TossDesignSystem.successGreen;
      scoreText = '매우 좋음';
    } else if (score >= 60) {
      scoreColor = TossDesignSystem.tossBlue;
      scoreText = '좋음';
    } else if (score >= 40) {
      scoreColor = TossDesignSystem.warningYellow;
      scoreText = '보통';
    } else {
      scoreColor = TossDesignSystem.errorRed;
      scoreText = '주의 필요';
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        colors: [
          scoreColor.withValues(alpha: 0.1),
          scoreColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TypographyUnified.displayLarge.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  '/100',
                  style: TypographyUnified.heading3.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              scoreText,
              style: TypographyUnified.bodySmall.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (keyword.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              keyword,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 섹션 카드 (타이핑 효과 포함)
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    required bool isDark,
    required int sectionIndex,
    VoidCallback? onTypingComplete,
  }) {
    final shouldAnimate = sectionIndex == _currentTypingSection;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TossDesignSystem.tossBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GptStyleTypingText(
            text: content,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              height: 1.6,
            ),
            startTyping: shouldAnimate,
            onComplete: onTypingComplete,
          ),
        ],
      ),
    );
  }

  /// 배산임수 분석 카드
  Widget _buildBaesanImsuCard({
    required String mountainPresence,
    required String waterPresence,
    required String roadImpact,
    required int terrainScore,
    required String terrainAnalysis,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.landscape, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '배산임수 분석',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '지형점수 $terrainScore점',
                  style: TypographyUnified.labelSmall.copyWith(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 산의 기운 (후현무)
          _buildBaesanImsuItem(
            icon: '⛰️',
            title: '산의 기운 (후현무)',
            content: mountainPresence,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // 물의 기운 (전주작)
          _buildBaesanImsuItem(
            icon: '🌊',
            title: '물의 기운 (전주작)',
            content: waterPresence,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // 도로의 영향
          _buildBaesanImsuItem(
            icon: '🛤️',
            title: '도로의 영향',
            content: roadImpact,
            isDark: isDark,
          ),
          if (terrainAnalysis.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              terrainAnalysis,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBaesanImsuItem({
    required String icon,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TypographyUnified.labelMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 양택풍수 분석 카드
  Widget _buildYangtaekCard({
    required String homeDirection,
    required String doorDirection,
    required int compatibility,
    required String directionAnalysis,
    required bool isDark,
  }) {
    Color compatColor;
    if (compatibility >= 80) {
      compatColor = TossDesignSystem.successGreen;
    } else if (compatibility >= 60) {
      compatColor = TossDesignSystem.tossBlue;
    } else if (compatibility >= 40) {
      compatColor = TossDesignSystem.warningYellow;
    } else {
      compatColor = TossDesignSystem.errorRed;
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '양택풍수 분석',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: compatColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '궁합도 $compatibility점',
                  style: TypographyUnified.labelSmall.copyWith(
                    color: compatColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 집의 좌향
          Row(
            children: [
              Expanded(
                child: _buildDirectionItem(
                  title: '집의 좌향',
                  value: homeDirection,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDirectionItem(
                  title: '대문 방향',
                  value: doorDirection,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (directionAnalysis.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              directionAnalysis,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDirectionItem({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TypographyUnified.labelSmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TypographyUnified.heading4.copyWith(
              color: const Color(0xFF8B7355),
            ),
          ),
        ],
      ),
    );
  }

  /// 내부 공간 배치 카드
  Widget _buildInteriorLayoutCard(Map<String, dynamic> interior, bool isDark) {
    final spaces = [
      {'key': 'entrance', 'icon': '🚪', 'title': '현관'},
      {'key': 'living_room', 'icon': '🛋️', 'title': '거실'},
      {'key': 'bedroom', 'icon': '🛏️', 'title': '침실'},
      {'key': 'kitchen', 'icon': '🍳', 'title': '부엌'},
      {'key': 'bathroom', 'icon': '🚿', 'title': '화장실'},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_work, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '내부 공간 배치',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...spaces.map((space) {
            final spaceData = interior[space['key']] as Map<String, dynamic>?;
            if (spaceData == null) return const SizedBox.shrink();

            final status = FortuneTextCleaner.cleanNullable(spaceData['status'] as String?);
            final advice = FortuneTextCleaner.cleanNullable(spaceData['advice'] as String?);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSpaceItem(
                icon: space['icon'] as String,
                title: space['title'] as String,
                status: status,
                advice: advice,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpaceItem({
    required String icon,
    required String title,
    required String status,
    required String advice,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TypographyUnified.labelMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TypographyUnified.labelSmall.copyWith(
                      color: TossDesignSystem.tossBlue,
                    ),
                  ),
                ),
            ],
          ),
          if (advice.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              advice,
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 기운 흐름 카드
  Widget _buildEnergyFlowCard({
    required String qiCirculation,
    required List<String> brightAreas,
    required List<String> darkAreas,
    required List<String> suggestions,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '기운 흐름',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (qiCirculation.isNotEmpty) ...[
            Text(
              qiCirculation,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (brightAreas.isNotEmpty) ...[
            _buildEnergySection(
              icon: '☀️',
              title: '밝은 기운 (길한 곳)',
              items: brightAreas,
              color: TossDesignSystem.successGreen,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          if (darkAreas.isNotEmpty) ...[
            _buildEnergySection(
              icon: '🌑',
              title: '어두운 기운 (주의할 곳)',
              items: darkAreas,
              color: TossDesignSystem.warningYellow,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          if (suggestions.isNotEmpty) ...[
            _buildEnergySection(
              icon: '💡',
              title: '기운 개선 방법',
              items: suggestions,
              color: TossDesignSystem.tossBlue,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnergySection({
    required String icon,
    required String title,
    required List<String> items,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TypographyUnified.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color)),
                Expanded(
                  child: Text(
                    item,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// 결함 및 해결책 카드
  Widget _buildDefectsCard({
    required List<Map<String, dynamic>> majorDefects,
    required List<Map<String, dynamic>> minorDefects,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '결함 및 해결책',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (majorDefects.isNotEmpty) ...[
            Text(
              '🚨 주요 결함',
              style: TypographyUnified.labelMedium.copyWith(
                color: TossDesignSystem.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...majorDefects.map((defect) => _buildDefectItem(defect, true, isDark)),
            const SizedBox(height: 16),
          ],
          if (minorDefects.isNotEmpty) ...[
            Text(
              '⚠️ 경미한 결함',
              style: TypographyUnified.labelMedium.copyWith(
                color: TossDesignSystem.warningYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...minorDefects.map((defect) => _buildDefectItem(defect, false, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildDefectItem(Map<String, dynamic> defect, bool isMajor, bool isDark) {
    final issue = FortuneTextCleaner.cleanNullable(defect['issue'] as String?);
    final solution = FortuneTextCleaner.cleanNullable(defect['solution'] as String?);
    final color = isMajor ? TossDesignSystem.errorRed : TossDesignSystem.warningYellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (issue.isNotEmpty)
            Text(
              issue,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (solution.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: TossDesignSystem.successGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    solution,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: TossDesignSystem.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 행운 요소 카드
  Widget _buildLuckyElementsCard({
    required List<Map<String, dynamic>> colors,
    required List<Map<String, dynamic>> plants,
    required List<Map<String, dynamic>> items,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '행운 요소',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (colors.isNotEmpty) ...[
            _buildLuckyCategory(
              icon: '🎨',
              title: '행운의 색상',
              items: colors,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          if (plants.isNotEmpty) ...[
            _buildLuckyCategory(
              icon: '🌿',
              title: '행운의 식물',
              items: plants,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          if (items.isNotEmpty) ...[
            _buildLuckyCategory(
              icon: '🎁',
              title: '행운의 물건',
              items: items,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyCategory({
    required String icon,
    required String title,
    required List<Map<String, dynamic>> items,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TypographyUnified.labelMedium.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final name = FortuneTextCleaner.cleanNullable(item['name'] as String?);
            final reason = FortuneTextCleaner.cleanNullable(item['reason'] as String?);
            return Tooltip(
              message: reason,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? TossDesignSystem.gray700 : TossDesignSystem.gray200,
                  ),
                ),
                child: Text(
                  name,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 계절별 조언 카드
  Widget _buildSeasonalAdviceCard(Map<String, dynamic> seasonal, bool isDark) {
    final seasons = [
      {'key': 'spring', 'icon': '🌸', 'title': '봄'},
      {'key': 'summer', 'icon': '☀️', 'title': '여름'},
      {'key': 'autumn', 'icon': '🍂', 'title': '가을'},
      {'key': 'winter', 'icon': '❄️', 'title': '겨울'},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF8B7355), size: 24),
              const SizedBox(width: 8),
              Text(
                '계절별 조언',
                style: TypographyUnified.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final season = seasons[index];
              final advice = FortuneTextCleaner.cleanNullable(seasonal[season['key']] as String?);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(season['icon'] as String, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 4),
                        Text(
                          season['title'] as String,
                          style: TypographyUnified.labelMedium.copyWith(
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        advice,
                        style: TypographyUnified.bodySmall.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
