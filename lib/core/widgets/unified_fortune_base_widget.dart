import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';
import '../models/fortune_result.dart';
import '../services/unified_fortune_service.dart';
import '../services/debug_premium_service.dart';
import '../utils/logger.dart';
import '../../shared/components/toast.dart';
import '../design_system/design_system.dart';
import '../../presentation/widgets/ads/interstitial_ad_helper.dart';
import '../utils/haptic_utils.dart';
import '../constants/soul_rates.dart';
import '../errors/exceptions.dart';
import '../../data/services/token_api_service.dart';
import '../../presentation/providers/providers.dart';
import '../../shared/components/token_insufficient_modal.dart';
import '../../services/screenshot_detection_service.dart';

/// UnifiedFortuneService를 사용하는 표준 운세 위젯
///
/// BaseFortunePage를 대체하는 새로운 표준 위젯으로,
/// UnifiedFortuneService의 6단계 최적화 프로세스를 자동으로 적용합니다.
///
/// **사용 예시**:
/// ```dart
/// class MbtiFortunePage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return UnifiedFortuneBaseWidget(
///       fortuneType: 'mbti',
///       title: 'MBTI 운세',
///       description: '당신의 MBTI 유형에 맞는 오늘의 운세',
///       inputBuilder: (context, onSubmit) => _buildMbtiInput(onSubmit),
///       conditionsBuilder: () async => MbtiFortuneConditions(...),
///       resultBuilder: (context, result) => _buildMbtiResult(result),
///     );
///   }
/// }
/// ```
///
/// **주요 기능**:
/// - ✅ 자동 로딩/에러 상태 관리
/// - ✅ UnifiedFortuneService 자동 호출
/// - ✅ 72% API 비용 절감 (최적화 시스템 자동 적용)
/// - ✅ 개인 캐시 + DB 풀 + 30% 랜덤 최적화
/// - ✅ fortune_history 자동 저장
class UnifiedFortuneBaseWidget extends ConsumerStatefulWidget {
  /// 운세 타입 (예: 'mbti', 'tarot', 'moving')
  final String fortuneType;

  /// 페이지 제목
  final String title;

  /// 페이지 설명
  final String description;

  /// 입력 폼 빌더
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `onSubmit`: 사용자가 "운세 보기" 버튼을 눌렀을 때 호출할 콜백
  ///
  /// **예시**:
  /// ```dart
  /// inputBuilder: (context, onSubmit) => Column(
  ///   children: [
  ///     TextField(...),
  ///     ElevatedButton(
  ///       onPressed: onSubmit,
  ///       child: Text('운세 보기'),
  ///     ),
  ///   ],
  /// )
  /// ```
  final Widget Function(BuildContext context, VoidCallback onSubmit) inputBuilder;

  /// FortuneConditions 생성 함수
  ///
  /// UnifiedFortuneService의 최적화 시스템을 활성화하기 위한 조건 객체를 반환합니다.
  ///
  /// **예시**:
  /// ```dart
  /// conditionsBuilder: () async {
  ///   final profile = await getProfile();
  ///   return MbtiFortuneConditions(
  ///     mbtiType: profile.mbti,
  ///     birthDate: profile.birthDate,
  ///   );
  /// }
  /// ```
  final Future<FortuneConditions> Function() conditionsBuilder;

  /// 운세 결과 빌더
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `result`: 생성된 운세 결과 (FortuneResult)
  ///
  /// **예시**:
  /// ```dart
  /// resultBuilder: (context, result) => Column(
  ///   children: [
  ///     Text(result.title),
  ///     Text(result.data['content']),
  ///   ],
  /// )
  /// ```
  final Widget Function(BuildContext context, FortuneResult result) resultBuilder;

  /// 데이터 소스 (기본값: API)
  final FortuneDataSource dataSource;

  /// 최적화 시스템 활성화 여부 (기본값: true)
  final bool enableOptimization;

  /// AppBar 표시 여부 (기본값: true)
  final bool showAppBar;

  /// AppBar 배경색 (기본값: 다크모드 자동 대응)
  final Color? appBarBackgroundColor;

  const UnifiedFortuneBaseWidget({
    super.key,
    required this.fortuneType,
    required this.title,
    required this.description,
    required this.inputBuilder,
    required this.conditionsBuilder,
    required this.resultBuilder,
    this.dataSource = FortuneDataSource.api,
    this.enableOptimization = true,
    this.showAppBar = true,
    this.appBarBackgroundColor,
  });

  @override
  ConsumerState<UnifiedFortuneBaseWidget> createState() =>
      _UnifiedFortuneBaseWidgetState();
}

class _UnifiedFortuneBaseWidgetState
    extends ConsumerState<UnifiedFortuneBaseWidget> {
  /// 현재 상태: 입력 중 or 결과 표시
  bool _showResult = false;

  /// 로딩 상태 (API 호출 중)
  bool _isLoading = false;

  /// 생성된 운세 결과
  FortuneResult? _fortuneResult;

  /// UnifiedFortuneService 인스턴스
  late final UnifiedFortuneService _fortuneService;

  /// ScreenshotDetectionService 인스턴스
  late final ScreenshotDetectionService _screenshotService;

  @override
  void initState() {
    super.initState();
    _fortuneService = UnifiedFortuneService(
      Supabase.instance.client,
      tokenService: ref.read(tokenApiServiceProvider),
      enableOptimization: widget.enableOptimization,
      enableTokenValidation: true,
    );
    _screenshotService = ref.read(screenshotDetectionServiceProvider);
    _initScreenshotDetection();
  }

  /// 스크린샷 감지 초기화
  Future<void> _initScreenshotDetection() async {
    await _screenshotService.initialize();
    _screenshotService.onScreenshotDialogRequested = (ctx) {
      if (_showResult && _fortuneResult != null) {
        _showShareDialog();
      }
    };
  }

  /// 공유 다이얼로그 표시
  void _showShareDialog() {
    if (!mounted || _fortuneResult == null) return;

    final content = _fortuneResult!.data['content']?.toString() ??
        _fortuneResult!.data['summary']?.toString() ??
        '';

    _screenshotService.showScreenshotSharingDialog(
      context: context,
      fortuneType: widget.fortuneType,
      fortuneTitle: widget.title,
      fortuneContent: content,
    );
  }

  @override
  void dispose() {
    _screenshotService.dispose();
    super.dispose();
  }

  /// 운세 생성 실행 (신규 플로우: 블러 결과 즉시 표시 → 광고 → 블러 해제)
  Future<void> _handleSubmit() async {
    Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 시작: ${widget.fortuneType}');

    // 1. 프리미엄/영혼 체크
    final tokenState = ref.read(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);

    // 디버그 모드에서 프리미엄 오버라이드 확인
    final premiumOverride = await DebugPremiumService.getOverrideValue();
    if (!mounted) return;
    final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

    if (premiumOverride != null) {
      Logger.debug('[UnifiedFortuneBaseWidget] 디버그 프리미엄 오버라이드 활성화: $premiumOverride');
    }

    // 프리미엄 운세인 경우 영혼 확인
    if (!isPremium && SoulRates.isPremiumFortune(widget.fortuneType)) {
      final canAccess = tokenNotifier.canAccessFortune(widget.fortuneType);
      final requiredSouls = -SoulRates.getSoulAmount(widget.fortuneType);

      Logger.debug('[UnifiedFortuneBaseWidget] 영혼 체크', {
        'fortuneType': widget.fortuneType,
        'requiredSouls': requiredSouls,
        'canAccess': canAccess,
      });

      if (!canAccess) {
        Logger.warning('[UnifiedFortuneBaseWidget] 영혼 부족');
        HapticUtils.warning();
        await TokenInsufficientModal.show(
          context: context,
          requiredTokens: requiredSouls,
          fortuneType: widget.fortuneType,
        );
        return;
      }
    }

    // 2. 신규 플로우: 즉시 결과 화면 전환 → 스켈레톤 → 운세 생성 → 블러 상태 표시 → 광고 → 블러 해제
    try {
      // 2-0. 즉시 결과 화면으로 전환 (스켈레톤 표시)
      setState(() {
        _showResult = true;
        _isLoading = true;
        _fortuneResult = null;
      });
      Logger.info('[UnifiedFortuneBaseWidget] 📱 결과 화면으로 전환 (로딩 스켈레톤 표시)');

      // 2-1. 운세 생성 (블러 상태)
      await _generateFortuneBlurred(isPremium: isPremium);

      // 2-2~2-3. Premium/Frequency 체크 및 광고 표시 (Helper가 처리)
      await InterstitialAdHelper.showInterstitialAdWithCallback(
        ref,
        onAdCompleted: () async {
          Logger.info('[UnifiedFortuneBaseWidget] 광고 시청 완료 또는 생략 - 블러 해제');
          await _unlockBlurredContent();
        },
        onAdFailed: () async {
          Logger.info('[UnifiedFortuneBaseWidget] 광고 표시 실패 - 블러 유지 (사용자가 다시 시도하도록)');
          // ❌ 자동으로 블러 해제하지 않음!
          // 사용자가 FloatingBottomButton을 다시 눌러서 재시도하도록 유도
        },
      );
      // ✅ 광고가 준비 안 됐으면 블러 유지 (AdService에서 콜백 호출 안함)
      // FloatingBottomButton을 통해 사용자가 직접 블러 해제하도록 유도
    } catch (e) {
      Logger.error('[UnifiedFortuneBaseWidget] 운세 생성 실패', e);
      // ❌ 에러 발생 시 로딩 해제하고 입력 화면으로 복귀
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_fortuneResult == null) {
            _showResult = false; // 운세가 없으면 입력 화면으로 복귀
          }
        });
      }
    }
  }

  /// 블러 상태로 운세 생성 (신규)
  Future<void> _generateFortuneBlurred({required bool isPremium}) async {
    try {
      Logger.info('[UnifiedFortuneBaseWidget] 블러 상태 운세 생성 시작');

      // 1. FortuneConditions 생성
      final conditions = await widget.conditionsBuilder();

      // 2. UnifiedFortuneService 호출 (블러 처리 활성화)
      final result = await _fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        dataSource: widget.dataSource,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: isPremium,
        onBlurredResult: (blurredResult) async {
          // 블러 상태 결과를 즉시 UI에 표시
          Logger.info('[UnifiedFortuneBaseWidget] 📥 onBlurredResult 콜백 호출됨');
          Logger.info('[UnifiedFortuneBaseWidget] mounted: $mounted, isBlurred: ${blurredResult.isBlurred}');

          // ✅ 1초 대기 (로딩 애니메이션 보여주기)
          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            setState(() {
              _fortuneResult = blurredResult;
              _showResult = true;
              _isLoading = false; // 로딩 완료
            });
            Logger.info('[UnifiedFortuneBaseWidget] 🔒 블러 상태 결과 표시 완료 (_showResult: $_showResult, _isLoading: false)');
          } else {
            Logger.warning('[UnifiedFortuneBaseWidget] ⚠️ mounted=false - setState 스킵됨');
          }
        },
      );

      Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 완료: ${result.id}');

      if (!mounted) return;

      // Premium 사용자는 블러 없이 즉시 표시
      setState(() {
        _fortuneResult = result;
        _showResult = true;
        _isLoading = false; // 로딩 완료
      });

      HapticUtils.success();
    } on InsufficientTokensException catch (e) {
      // 토큰 부족 예외 → 모달 표시
      Logger.warning('[UnifiedFortuneBaseWidget] 토큰 부족: ${e.fortuneType}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        HapticUtils.error();

        // 토큰 부족 모달 표시
        await TokenInsufficientModal.show(
          context: context,
          requiredTokens: e.required ?? 1,
          fortuneType: e.fortuneType ?? widget.fortuneType,
        );
      }
    } catch (error, stackTrace) {
      Logger.error(
        '[UnifiedFortuneBaseWidget] 운세 생성 실패: ${widget.fortuneType}',
        error,
        stackTrace,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        HapticUtils.error();
        Toast.show(
          context,
          message: '운세 생성에 실패했습니다: $error',
          type: ToastType.error,
        );
      }
    }
  }

  /// 블러 해제 (광고 시청 후)
  Future<void> _unlockBlurredContent() async {
    Logger.info('[UnifiedFortuneBaseWidget] 🔓 블러 해제 시작');

    if (!mounted) return;

    setState(() {
      if (_fortuneResult != null) {
        _fortuneResult = _fortuneResult!.copyWith(
          isBlurred: false,
          blurredSections: [],
        );
      }
    });

    HapticUtils.success();
    Logger.info('[UnifiedFortuneBaseWidget] ✅ 블러 해제 완료');
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: widget.appBarBackgroundColor ?? colors.background,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: widget.appBarBackgroundColor ?? colors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: _showResult ? null : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: colors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.title,
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              centerTitle: true,
              actions: _showResult ? [
                // 공유 버튼 (LinkedIn/TikTok 스타일)
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: colors.textPrimary,
                  ),
                  onPressed: _showShareDialog,
                  tooltip: '공유하기',
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colors.textPrimary,
                  ),
                  onPressed: () => context.go('/fortune'),
                ),
              ] : null,
            )
          : null,
      body: _showResult
          ? (_isLoading || _fortuneResult == null
              ? _buildLoadingSkeleton(context)
              : _buildResultWithBlur(context))
          : widget.inputBuilder(context, _handleSubmit),
    );
  }

  /// 로딩 스켈레톤 빌드
  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg).copyWith(bottom: 100),
      child: Column(
        children: [
          // 헤더 스켈레톤
          DSSkeleton(height: 140),
          const SizedBox(height: DSSpacing.md),
          // 컨텐츠 스켈레톤
          DSSkeleton(height: 180),
          const SizedBox(height: DSSpacing.md),
          DSSkeleton(height: 160),
          const SizedBox(height: DSSpacing.md),
          DSSkeleton(height: 140),
        ],
      ),
    );
  }

  /// 블러 처리된 결과 빌드
  Widget _buildResultWithBlur(BuildContext context) {
    if (_fortuneResult == null) {
      return const Center(child: Text('결과가 없습니다.'));
    }

    // ✅ BlurredFortuneContent 제거 - 각 페이지에서 _buildBlurWrapper로 개별 섹션 블러 처리
    // 블러 상태든 아니든 그냥 resultBuilder 호출
    return widget.resultBuilder(context, _fortuneResult!);
  }
}

/// Provider: UnifiedFortuneService 싱글톤
///
/// **사용 예시**:
/// ```dart
/// final service = ref.read(unifiedFortuneServiceProvider);
/// ```
final unifiedFortuneServiceProvider = Provider<UnifiedFortuneService>((ref) {
  return UnifiedFortuneService(
    Supabase.instance.client,
    enableOptimization: true,
  );
});

// Note: _ShimmerSkeletonCard removed - now using DSSkeleton from design_system
