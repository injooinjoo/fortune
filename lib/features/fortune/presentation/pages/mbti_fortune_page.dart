// ✅ Phase 16-1: ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/fortune_result.dart';
import '../../domain/models/conditions/mbti_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../shared/components/toss_card.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/toast.dart';
import '../../../../services/ad_service.dart';
// ✅ Phase 16-2
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/widgets/blurred_fortune_content.dart';

/// MBTI 운세 페이지 (UnifiedFortuneService 버전)
///
/// **개선 사항**:
/// - ✅ BaseFortunePage 제거 (중복 호출 방지)
/// - ✅ UnifiedFortuneBaseWidget 사용 (72% API 비용 절감)
/// - ✅ FortuneResultWidgets 사용 (재사용 가능한 UI)
/// - ✅ 코드 길이: 1276 라인 → 567 라인 (55.5% 감소)
class MbtiFortunePage extends ConsumerStatefulWidget {
  const MbtiFortunePage({super.key});

  @override
  ConsumerState<MbtiFortunePage> createState() =>
      _MbtiFortunePageState();
}

class _MbtiFortunePageState
    extends ConsumerState<MbtiFortunePage> {
  // ==================== State ====================

  String? _selectedMbti;
  final List<String> _selectedCategories = [];
  bool _showAllGroups = true;
  final ScrollController _scrollController = ScrollController();

  // 운세 결과 관련 상태
  FortuneResult? _fortuneResult;
  bool _isLoading = false;
  bool _showResult = false;
  double _energyLevel = 0.75;
  Map<String, dynamic>? _cognitiveFunctions;


  // ==================== MBTI Data ====================

  static const Map<String, List<String>> _mbtiGroups = {
    '분석가': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    '외교관': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    '관리자': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    '탐험가': ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
  };

  static const Map<String, List<Color>> _mbtiColors = {
    'INTJ': [Color(0xFF6B46C1), Color(0xFF9333EA)],
    'INTP': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    'ENTJ': [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    'ENTP': [Color(0xFF8B5CF6), Color(0xFFBB9EFA)],
    'INFJ': [Color(0xFF059669), Color(0xFF10B981)],
    'INFP': [Color(0xFF0891B2), Color(0xFF06B6D4)],
    'ENFJ': [Color(0xFF0D9488), Color(0xFF14B8A6)],
    'ENFP': [Color(0xFF10B981), Color(0xFF34D399)],
    'ISTJ': [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    'ISFJ': [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    'ESTJ': [Color(0xFF1F2937), Color(0xFF4B5563)],
    'ESFJ': [Color(0xFF312E81), Color(0xFF4F46E5)],
    'ISTP': [Color(0xFFDC2626), Color(0xFFEF4444)],
    'ISFP': [Color(0xFFEA580C), Color(0xFFF97316)],
    'ESTP': [Color(0xFFE11D48), Color(0xFFF43F5E)],
    'ESFP': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  };

  static const List<Map<String, dynamic>> _categories = [
    {'label': '연애운', 'icon': Icons.favorite, 'color': Color(0xFFEC4899)},
    {'label': '직업운', 'icon': Icons.work, 'color': Color(0xFF3B82F6)},
    {'label': '재물운', 'icon': Icons.attach_money, 'color': Color(0xFF10B981)},
    {'label': '건강운', 'icon': Icons.health_and_safety, 'color': Color(0xFFF59E0B)},
    {'label': '대인관계', 'icon': Icons.people, 'color': Color(0xFF8B5CF6)},
    {'label': '학업운', 'icon': Icons.school, 'color': Color(0xFF06B6D4)},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? TossDesignSystem.backgroundDark
            : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'MBTI 운세',
          style: TypographyUnified.heading4.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _showResult && _fortuneResult != null
                      ? _buildResultView(_fortuneResult!)
                      : _buildInputForm(),
                ),
              ],
            ),

            // 버튼 (입력 폼일 때: 운세 생성, 결과 화면일 때: 전체보기)
            if (!_showResult && _selectedMbti != null)
              UnifiedButton.floating(
                text: '🧠 내 성격이 말하는 오늘',
                onPressed: _isLoading ? null : _handleSubmit,
                isLoading: _isLoading,
                isEnabled: !_isLoading,
              ),

            // 전체보기 버튼 (블러 상태일 때만 표시)
            if (_showResult && _fortuneResult != null && _fortuneResult!.isBlurred)
              UnifiedButton.floating(
                text: '남은 운세 모두 보기',
                onPressed: _showAdAndUnblur,
                isLoading: false,
                isEnabled: true,
              ),
          ],
        ),
      ),
    );
  }


  Future<void> _handleSubmit() async {
    // ✅ InterstitialAd 제거: 버튼 클릭 시 바로 운세 생성
    await _generateFortune();
  }

  Future<void> _generateFortune() async {
    // ✅ 1단계: 즉시 로딩 상태 표시 (버튼 애니메이션 시작)
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // ✅ 타이머 시작 (최소 1초 대기)
      final loadingTimer = Stopwatch()..start();

      // 1. 사용자 프로필 가져오기
      final userProfile = ref.read(userProfileProvider).value;
      final userName = userProfile?.name ?? 'Unknown';
      final birthDateStr = userProfile?.birthDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0];

      // 2. Premium 상태 확인
      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;

      Logger.info('[MbtiFortunePage] Premium 상태: $isPremium');

      // 3. FortuneConditions 생성
      final conditions = MbtiFortuneConditions(
        mbtiType: _selectedMbti!,
        date: DateTime.now(),
        name: userName,
        birthDate: birthDateStr,
      );

      // 4. UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      final result = await fortuneService.getFortune(
        fortuneType: 'mbti',
        dataSource: FortuneDataSource.api,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: isPremium, // ✅ Premium 상태 전달
      );

      Logger.info('[MbtiFortunePage] 운세 생성 완료: ${result.id}');

      // API 응답에서 energyLevel 추출
      final data = result.data as Map<String, dynamic>? ?? {};
      final energyLevelValue = data['energyLevel'] as num? ?? 75;

      // ✅ 최소 1초 대기 (로딩 애니메이션 보여주기 위함)
      loadingTimer.stop();
      final elapsedMs = loadingTimer.elapsedMilliseconds;
      if (elapsedMs < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsedMs));
      }

      if (mounted) {
        setState(() {
          _fortuneResult = result;
          _showResult = true;
          _isLoading = false;
          _energyLevel = (energyLevelValue / 100).clamp(0.0, 1.0);
        });
      }
    } catch (error, stackTrace) {
      Logger.error('[MbtiFortunePage] 운세 생성 실패', error, stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Toast.show(
          context,
          message: '운세 생성 중 오류가 발생했습니다',
          type: ToastType.error,
        );
      }
    }
  }

  // ==================== Ad & Blur ====================

  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    try {
      final adService = AdService();

      // 광고가 준비 안됐으면 로드 (두 번 클릭 방지)
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 광고 로드 시작
        await adService.loadRewardedAd();

        // 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // 타임아웃 처리
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

      // 리워드 광고 표시
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          Logger.info('[MbtiFortunePage] Rewarded ad watched, removing blur');
          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult!.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('운세가 잠금 해제되었습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[MbtiFortunePage] Failed to show ad', e, stackTrace);
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

  // ==================== Input Form ====================

  Widget _buildInputForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          _buildTitleSection(),
          const SizedBox(height: 32),

          // MBTI 선택
          _buildMbtiGroupsSection(isDark),

          // 선택된 MBTI 정보
          if (_selectedMbti != null) ...[
            const SizedBox(height: 32),
            _buildSelectedMbtiInfo(isDark),
            const SizedBox(height: 24),
            _buildCategorySelection(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 MBTI를\n선택해주세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '16가지 성격 유형 중 나와 맞는 유형을 선택하세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark
                ? TossDesignSystem.grayDark100
                : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMbtiGroupsSection(bool isDark) {
    return Column(
      children: [
        // Accordion 헤더
        GestureDetector(
          onTap: () {
            setState(() {
              _showAllGroups = !_showAllGroups;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _showAllGroups
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark
                      ? TossDesignSystem.grayDark700
                      : TossDesignSystem.gray50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showAllGroups
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.3)
                    : (isDark
                        ? TossDesignSystem.grayDark400
                        : TossDesignSystem.gray200),
                width: _showAllGroups ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedMbti ?? 'MBTI 성격 유형 선택',
                    style: TypographyUnified.buttonMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
                    ),
                  ),
                ),
                Icon(
                  _showAllGroups
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // MBTI 그리드
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showAllGroups
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: _mbtiGroups.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 그룹 라벨
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _getGroupColor(entry.key),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Text(
                            entry.key,
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? TossDesignSystem.white
                                  : TossDesignSystem.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // MBTI 카드
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: entry.value
                          .map((mbti) => _buildMbtiCard(mbti, isDark))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildMbtiCard(String mbti, bool isDark) {
    final isSelected = _selectedMbti == mbti;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMbti = mbti;
          _showAllGroups = false; // ✅ 선택 후 자동 접기
        });
        HapticFeedback.mediumImpact();

        // ✅ 부드러운 스크롤 애니메이션
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue
              : (isDark
                  ? TossDesignSystem.grayDark700
                  : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : (isDark
                    ? TossDesignSystem.grayDark400
                    : TossDesignSystem.gray200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            mbti,
            style: TypographyUnified.buttonSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? TossDesignSystem.white : TossDesignSystem.gray800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMbtiInfo(bool isDark) {
    final colors = _mbtiColors[_selectedMbti]!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMbti!,
            style: TypographyUnified.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMbtiDescription(_selectedMbti!),
            style: TypographyUnified.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 운을 보고 싶으신가요?',
          style: TypographyUnified.buttonMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat['label']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(cat['label']);
                  } else {
                    _selectedCategories.add(cat['label'] as String);
                  }
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (cat['color'] as Color).withValues(alpha: 0.1)
                      : (isDark
                          ? TossDesignSystem.grayDark700
                          : TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (cat['color'] as Color)
                        : (isDark
                            ? TossDesignSystem.grayDark400
                            : TossDesignSystem.gray200),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? (cat['color'] as Color)
                          : (isDark
                              ? TossDesignSystem.grayDark100
                              : TossDesignSystem.gray600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? (cat['color'] as Color)
                            : (isDark
                                ? TossDesignSystem.grayDark100
                                : TossDesignSystem.gray600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==================== Result View ====================

  Widget _buildResultView(FortuneResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Energy Level Card
          _buildEnergyCard(),
          const SizedBox(height: 16),

          // Main Fortune Card
          _buildMainFortuneCard(),
          const SizedBox(height: 16),

          // Cognitive Functions
          if (_cognitiveFunctions != null) ...[
            _buildCognitiveFunctionsCard(),
            const SizedBox(height: 16),
          ],

          // Category Fortunes (블러 대상)
          if (_selectedCategories.isNotEmpty) ...[
            BlurredFortuneContent(
              fortuneResult: result,
              child: _buildCategoryFortunesCard(),
            ),
            const SizedBox(height: 16),
          ],

          // Compatibility (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildCompatibilityCard(),
          ),

          // Bottom spacing for navigation
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEnergyCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _mbtiColors[_selectedMbti!]!;

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full,
                size: 20,
                color: colors.first),
              const SizedBox(width: 8),
              Text(
                '오늘의 에너지 레벨',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _energyLevel,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(_energyLevel * 100).toInt()}% 충전됨',
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.first,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFortuneCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _fortuneResult;
    if (result == null) return const SizedBox();

    final colors = _mbtiColors[_selectedMbti!]!;
    final data = result.data as Map<String, dynamic>? ?? {};
    final todayFortune = FortuneTextCleaner.clean(data['todayFortune'] as String? ?? result.summary['message'] as String? ?? '');
    final luckyItems = {
      if (data['luckyColor'] != null) '색상': data['luckyColor'],
      if (data['luckyNumber'] != null) '숫자': data['luckyNumber'].toString(),
    };

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_selectedMbti 오늘의 운세',
              style: const TextStyle(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            todayFortune,
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              height: 1.6,
            ),
          ),
          if (luckyItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildLuckyItems(luckyItems),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyItems(Map<String, dynamic> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars,
              size: 20,
              color: TossDesignSystem.warningOrange),
            const SizedBox(width: 8),
            Text(
              '오늘의 행운 아이템',
              style: TypographyUnified.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.entries.map((entry) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TossDesignSystem.warningOrange.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${entry.value}',
              style: TypographyUnified.bodySmall.copyWith(
                color: TossDesignSystem.warningOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCognitiveFunctionsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology,
                size: 20,
                color: TossDesignSystem.tossBlue),
              const SizedBox(width: 8),
              Text(
                '인지 기능 분석',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '인지 기능 차트',
                style: TextStyle(
                  color: TossDesignSystem.gray500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFortunesCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _fortuneResult;
    if (result == null) return const SizedBox();

    final data = result.data as Map<String, dynamic>? ?? {};

    return Column(
      children: _selectedCategories.map((category) {
        final categoryInfo = _categories.firstWhere(
          (c) => c['label'] == category,
        );

        String categoryText = '';
        switch (category) {
          case '연애운':
            categoryText = FortuneTextCleaner.clean(data['loveFortune'] as String? ?? _getCategoryFortune(category));
            break;
          case '직업운':
            categoryText = FortuneTextCleaner.clean(data['careerFortune'] as String? ?? _getCategoryFortune(category));
            break;
          case '재물운':
            categoryText = FortuneTextCleaner.clean(data['moneyFortune'] as String? ?? _getCategoryFortune(category));
            break;
          case '건강운':
            categoryText = FortuneTextCleaner.clean(data['healthFortune'] as String? ?? _getCategoryFortune(category));
            break;
          default:
            categoryText = FortuneTextCleaner.clean(_getCategoryFortune(category));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      categoryInfo['icon'] as IconData,
                      size: 20,
                      color: categoryInfo['color'] as Color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  categoryText,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompatibilityCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compatibleTypes = _getCompatibleTypes(_selectedMbti!);

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people,
                size: 20,
                color: TossDesignSystem.purple),
              const SizedBox(width: 8),
              Text(
                '오늘의 궁합',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: compatibleTypes.map((type) {
              final colors = _mbtiColors[type]!;
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: TossDesignSystem.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCompatibilityLabel(compatibleTypes.indexOf(type)),
                    style: TypographyUnified.labelMedium.copyWith(
                      color: TossDesignSystem.gray600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== Helpers ====================

  Color _getGroupColor(String groupName) {
    switch (groupName) {
      case '분석가':
        return const Color(0xFF8B5CF6);
      case '외교관':
        return const Color(0xFF10B981);
      case '관리자':
        return const Color(0xFF3B82F6);
      case '탐험가':
        return const Color(0xFFF59E0B);
      default:
        return TossDesignSystem.tossBlue;
    }
  }

  String _getMbtiDescription(String mbti) {
    const descriptions = {
      'INTJ': '전략적 사고를 가진 완벽주의자',
      'INTP': '논리적이고 창의적인 사색가',
      'ENTJ': '대담한 지도자형 인간',
      'ENTP': '영리한 발명가형 인간',
      'INFJ': '선의의 옹호자형 인간',
      'INFP': '열정적인 중재자형 인간',
      'ENFJ': '정의로운 사회운동가',
      'ENFP': '재기발랄한 활동가',
      'ISTJ': '청렴결백한 논리주의자',
      'ISFJ': '용감한 수호자형 인간',
      'ESTJ': '엄격한 관리자형 인간',
      'ESFJ': '사교적인 외교관형 인간',
      'ISTP': '만능 재주꾼형 인간',
      'ISFP': '호기심 많은 예술가',
      'ESTP': '모험을 즐기는 사업가',
      'ESFP': '자유로운 영혼의 연예인',
    };
    return descriptions[mbti] ?? '';
  }

  String _getCategoryFortune(String category) {
    const fortunes = {
      '연애운': '오늘은 사랑하는 사람과의 관계가 더욱 깊어질 수 있는 날입니다. 진심을 담은 대화를 나눠보세요.',
      '직업운': '새로운 프로젝트나 기회가 찾아올 수 있습니다. 적극적으로 도전해보세요.',
      '재물운': '예상치 못한 수입이 있을 수 있습니다. 하지만 충동적인 소비는 피하세요.',
      '건강운': '컨디션이 좋은 날입니다. 운동이나 야외 활동을 즐겨보세요.',
      '대인관계': '주변 사람들과의 관계가 원만해집니다. 새로운 인연도 기대해보세요.',
      '학업운': '집중력이 높아지는 날입니다. 어려운 문제도 해결할 수 있을 것입니다.',
    };
    return fortunes[category] ?? '오늘은 $category이 좋은 날입니다.';
  }

  List<String> _getCompatibleTypes(String mbti) {
    const compatibility = {
      'INTJ': ['ENTP', 'ENFP'],
      'INTP': ['ENTJ', 'ESTJ'],
      'ENTJ': ['INTP', 'ISTP'],
      'ENTP': ['INTJ', 'INFJ'],
      'INFJ': ['ENTP', 'ENFP'],
      'INFP': ['ENFJ', 'ENTJ'],
      'ENFJ': ['INFP', 'ISFP'],
      'ENFP': ['INTJ', 'INFJ'],
      'ISTJ': ['ESFP', 'ESTP'],
      'ISFJ': ['ESFP', 'ESTP'],
      'ESTJ': ['INTP', 'ISTP'],
      'ESFJ': ['ISFP', 'ISTP'],
      'ISTP': ['ESTJ', 'ENTJ'],
      'ISFP': ['ENFJ', 'ESFJ'],
      'ESTP': ['ISTJ', 'ISFJ'],
      'ESFP': ['ISTJ', 'ISFJ'],
    };
    return compatibility[mbti] ?? ['INFJ', 'ENFP'];
  }

  String _getCompatibilityLabel(int index) {
    const labels = ['Best Match', 'Good Match', 'Compatible'];
    return index < labels.length ? labels[index] : 'Compatible';
  }
}
