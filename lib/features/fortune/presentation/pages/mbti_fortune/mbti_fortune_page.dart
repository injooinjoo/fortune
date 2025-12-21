// ✅ Phase 16-1: ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'package:fortune/features/fortune/domain/models/conditions/mbti_fortune_conditions.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/widgets/unified_button.dart';
import 'package:fortune/core/services/unified_fortune_service.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/core/utils/fortune_completion_helper.dart';
import 'package:fortune/shared/components/toast.dart';
import 'package:fortune/services/ad_service.dart';
import 'package:fortune/core/utils/subscription_snackbar.dart';
// ✅ Phase 16-2
import 'package:fortune/presentation/providers/user_profile_notifier.dart';
import 'package:fortune/presentation/providers/token_provider.dart';
import 'package:fortune/presentation/providers/subscription_provider.dart';
import 'package:fortune/core/widgets/blurred_fortune_content.dart';
import 'package:fortune/core/services/fortune_haptic_service.dart';
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
  bool _showAllGroups = true;
  final ScrollController _scrollController = ScrollController();

  // 운세 결과 관련 상태
  FortuneResult? _fortuneResult;
  bool _isLoading = false;
  bool _showResult = false;

  // GPT 스타일 타이핑 효과 섹션 관리
  int _currentTypingSection = 0;


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
  void initState() {
    super.initState();
    // 프로필에서 MBTI 자동 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile?.mbtiType != null) {
        setState(() {
          _selectedMbti = userProfile!.mbtiType;
          _showAllGroups = false; // 선택됐으니 접기
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: _showResult
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: colors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          'MBTI 운세',
          style: DSTypography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: _showResult
            ? [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colors.textPrimary,
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
                  child: _showResult
                      ? _buildResultView(_fortuneResult)
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

            // 전체보기 버튼 (블러 상태일 때만 표시, 구독자 제외)
            if (_showResult && _fortuneResult != null && _fortuneResult!.isBlurred && !ref.watch(isPremiumProvider))
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
    // ✅ 즉시 결과 화면으로 전환 (스켈레톤 표시)
    setState(() {
      _showResult = true;
      _isLoading = true;
      _fortuneResult = null;
    });
    await _generateFortune();
  }

  Future<void> _generateFortune() async {
    debugPrint('🧠 [MbtiPage] _generateFortune 시작: $_selectedMbti');

    try {
      // ✅ 타이머 시작 (최소 1초 대기)
      final loadingTimer = Stopwatch()..start();

      // 1. 사용자 프로필 가져오기
      final userProfile = ref.read(userProfileProvider).value;
      final userName = userProfile?.name ?? 'Unknown';
      final birthDateStr = userProfile?.birthDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0];
      debugPrint('🧠 [MbtiPage] 프로필: name=$userName, birthDate=$birthDateStr');

      // 2. Premium 상태 확인
      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;
      debugPrint('🧠 [MbtiPage] isPremium: $isPremium');

      Logger.info('[MbtiFortunePage] Premium 상태: $isPremium');

      // 3. FortuneConditions 생성
      final conditions = MbtiFortuneConditions(
        mbtiType: _selectedMbti!,
        date: DateTime.now(),
        name: userName,
        birthDate: birthDateStr,
      );
      debugPrint('🧠 [MbtiPage] Conditions JSON: ${conditions.toJson()}');

      // 4. UnifiedFortuneService 호출
      debugPrint('🧠 [MbtiPage] API 호출 시작...');
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

      debugPrint('🧠 [MbtiPage] API 응답: type=${result.type}, score=${result.score}, isBlurred=${result.isBlurred}');
      debugPrint('🧠 [MbtiPage] data keys: ${result.data.keys.toList()}');
      Logger.info('[MbtiFortunePage] 운세 생성 완료: ${result.id}');

      // ✅ 최소 1초 대기 (로딩 애니메이션 보여주기 위함)
      loadingTimer.stop();
      final elapsedMs = loadingTimer.elapsedMilliseconds;
      if (elapsedMs < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsedMs));
      }

      if (mounted) {
        // ✅ MBTI 운세 결과 공개 시 햅틱 피드백
        final score = result.score ?? 70;
        ref.read(fortuneHapticServiceProvider).scoreReveal(score);
        debugPrint('🧠 [MbtiPage] ✅ 결과 설정: score=$score');

        setState(() {
          _fortuneResult = result;
          _showResult = true;
          _isLoading = false;
          _currentTypingSection = 0; // 타이핑 섹션 리셋
        });
        debugPrint('🧠 [MbtiPage] ✅ 결과 화면 전환 완료');
      }
    } catch (error, stackTrace) {
      debugPrint('🧠 [MbtiPage] ❌ 에러 발생: $error');
      debugPrint('🧠 [MbtiPage] 스택: $stackTrace');
      Logger.error('[MbtiFortunePage] 운세 생성 실패', error, stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Toast.show(
          context,
          message: 'MBTI 운세를 불러올 수 없습니다. 네트워크 연결을 확인해주세요.',
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
        onUserEarnedReward: (ad, reward) async {
          Logger.info('[MbtiFortunePage] Rewarded ad watched, removing blur');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // ✅ 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'mbti');
          }

          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult!.copyWith(
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
          ],
        ],
      ),
    );
  }

  // ==================== Skeleton View ====================

  Widget _buildSkeletonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Energy Card 스켈레톤
          _buildSkeletonCard(height: 120),
          const SizedBox(height: 16),
          // Main Fortune Card 스켈레톤
          _buildSkeletonCard(height: 200),
          const SizedBox(height: 16),
          // Compatibility Card 스켈레톤
          _buildSkeletonCard(height: 150),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    final colors = context.colors;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accent,
          ),
        ),
      ),
    );
  }

  // ==================== Result View ====================

  Widget _buildResultView(FortuneResult? result) {
    // 스켈레톤 로딩 UI
    if (_isLoading || result == null) {
      return _buildSkeletonView();
    }

    final data = result.data as Map<String, dynamic>? ?? {};
    final score = result.score ?? (data['score'] as int?) ?? 50;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 0. 오늘의 점수 카드 (무료)
          _buildScoreCard(score),
          const SizedBox(height: 16),

          // 1. Main Fortune Card - todayFortune (무료)
          MainFortuneCard(
            fortuneResult: result,
            selectedMbti: _selectedMbti!,
            colors: _mbtiColors[_selectedMbti!]!,
            startTyping: _currentTypingSection >= 0,
            onTypingComplete: () {
              if (mounted) setState(() => _currentTypingSection = 1);
            },
          ),
          const SizedBox(height: 16),

          // 3. Category Fortunes - 연애/직장/금전/건강 (프리미엄 - 블러)
          BlurredFortuneContent(
            fortuneResult: result,
            child: MbtiCategoryFortunesCard(
              fortuneResult: result,
              startTyping: _currentTypingSection >= 1,
              onTypingComplete: () {
                if (mounted) setState(() => _currentTypingSection = 2);
              },
            ),
          ),
          const SizedBox(height: 16),

          // 4. Advice Card (프리미엄 - 블러)
          if (data['advice'] != null && (data['advice'] as String).isNotEmpty)
            BlurredFortuneContent(
              fortuneResult: result,
              child: MbtiAdviceCard(
                advice: data['advice'] as String,
                startTyping: _currentTypingSection >= 2,
                onTypingComplete: () {
                  if (mounted) setState(() => _currentTypingSection = 3);
                },
              ),
            ),
          if (data['advice'] != null && (data['advice'] as String).isNotEmpty)
            const SizedBox(height: 16),

          // 5. Cognitive Functions - 강점/도전과제 (프리미엄 - 블러)
          if (data['cognitiveStrengths'] != null || data['challenges'] != null)
            BlurredFortuneContent(
              fortuneResult: result,
              child: CognitiveFunctionsCard(
                strengths: List<String>.from(data['cognitiveStrengths'] ?? []),
                challenges: List<String>.from(data['challenges'] ?? []),
              ),
            ),
          if (data['cognitiveStrengths'] != null || data['challenges'] != null)
            const SizedBox(height: 16),

          // 6. Compatibility Card - 궁합 (프리미엄 - 블러)
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

  /// 오늘의 점수 카드
  Widget _buildScoreCard(int score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _mbtiColors[_selectedMbti!]!;

    // 점수에 따른 등급과 메시지
    String grade;
    String message;
    if (score >= 90) {
      grade = '최고';
      message = '오늘은 당신의 날이에요!';
    } else if (score >= 75) {
      grade = '좋음';
      message = '긍정적인 에너지가 넘쳐요';
    } else if (score >= 50) {
      grade = '보통';
      message = '안정적인 하루가 될 거예요';
    } else if (score >= 25) {
      grade = '주의';
      message = '신중하게 행동하세요';
    } else {
      grade = '휴식';
      message = '오늘은 충전이 필요해요';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withValues(alpha: 0.15),
            colors[1].withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '오늘의 $_selectedMbti 운세',
            style: TextStyle(
              fontSize: FontConfig.labelMedium,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: colors,
                ).createShader(bounds),
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: FontConfig.displayLarge,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '점',
                style: TextStyle(
                  fontSize: FontConfig.heading4,
                  fontWeight: FontWeight.w600,
                  color: colors[0],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors[0].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              grade,
              style: TextStyle(
                fontSize: FontConfig.labelSmall,
                fontWeight: FontWeight.w600,
                color: colors[0],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: FontConfig.labelMedium,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
