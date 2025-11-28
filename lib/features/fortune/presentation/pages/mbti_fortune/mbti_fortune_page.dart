// ✅ Phase 16-1: ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/features/fortune/domain/models/conditions/mbti_fortune_conditions.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/widgets/unified_button.dart';
import 'package:fortune/core/services/unified_fortune_service.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/shared/components/toast.dart';
import 'package:fortune/services/ad_service.dart';
// ✅ Phase 16-2
import 'package:fortune/presentation/providers/user_profile_notifier.dart';
import 'package:fortune/presentation/providers/token_provider.dart';
import 'package:fortune/core/widgets/blurred_fortune_content.dart';
import 'widgets/widgets.dart';

/// MBTI 운세 페이지 (UnifiedFortuneService 버전)
///
/// **개선 사항**:
/// - ✅ BaseFortunePage 제거 (중복 호출 방지)
/// - ✅ UnifiedFortuneBaseWidget 사용 (72% API 비용 절감)
/// - ✅ FortuneResultWidgets 사용 (재사용 가능한 UI)
/// - ✅ 코드 길이: 1276 라인 → 567 라인 (55.5% 감소)
/// - ✅ 모듈화: widgets/ 디렉토리로 분리
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
        automaticallyImplyLeading: false,
        leading: _showResult
            ? null
            : IconButton(
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
        actions: _showResult
            ? [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
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
          const MbtiTitleSection(),
          const SizedBox(height: 32),

          // MBTI 선택
          MbtiGroupsSection(
            showAllGroups: _showAllGroups,
            selectedMbti: _selectedMbti,
            onToggle: () {
              setState(() {
                _showAllGroups = !_showAllGroups;
              });
            },
            onMbtiSelected: (mbti) {
              setState(() {
                _selectedMbti = mbti;
                _showAllGroups = false; // ✅ 선택 후 자동 접기
              });
            },
            scrollController: _scrollController,
          ),

          // 선택된 MBTI 정보
          if (_selectedMbti != null) ...[
            const SizedBox(height: 32),
            SelectedMbtiInfo(
              selectedMbti: _selectedMbti!,
              colors: _mbtiColors[_selectedMbti!]!,
            ),
            const SizedBox(height: 24),
            CategorySelection(
              selectedCategories: _selectedCategories,
              onCategoryToggle: (category) {
                setState(() {
                  if (_selectedCategories.contains(category)) {
                    _selectedCategories.remove(category);
                  } else {
                    _selectedCategories.add(category);
                  }
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  // ==================== Result View ====================

  Widget _buildResultView(FortuneResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Energy Level Card
          EnergyCard(
            energyLevel: _energyLevel,
            colors: _mbtiColors[_selectedMbti!]!,
          ),
          const SizedBox(height: 16),

          // Main Fortune Card
          MainFortuneCard(
            fortuneResult: result,
            selectedMbti: _selectedMbti!,
            colors: _mbtiColors[_selectedMbti!]!,
          ),
          const SizedBox(height: 16),

          // Cognitive Functions
          if (_cognitiveFunctions != null) ...[
            const CognitiveFunctionsCard(),
            const SizedBox(height: 16),
          ],

          // Category Fortunes (블러 대상)
          if (_selectedCategories.isNotEmpty) ...[
            BlurredFortuneContent(
              fortuneResult: result,
              child: CategoryFortunesCard(
                fortuneResult: result,
                selectedCategories: _selectedCategories,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Compatibility (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: CompatibilityCard(
              selectedMbti: _selectedMbti!,
              mbtiColors: _mbtiColors,
            ),
          ),

          // Bottom spacing for navigation
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
