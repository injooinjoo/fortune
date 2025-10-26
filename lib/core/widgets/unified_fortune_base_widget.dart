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
import '../theme/toss_design_system.dart';
import '../../services/ad_service.dart';
import '../utils/haptic_utils.dart';
import '../constants/soul_rates.dart';
import '../../presentation/providers/providers.dart';
import '../../shared/components/token_insufficient_modal.dart';
import 'blurred_fortune_content.dart';

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

  /// 로딩 중 플래그
  bool _isLoading = false;

  /// 생성된 운세 결과
  FortuneResult? _fortuneResult;

  /// 블러 상태 (광고 시청 전)
  bool _isBlurred = false;

  /// UnifiedFortuneService 인스턴스
  late final UnifiedFortuneService _fortuneService;

  @override
  void initState() {
    super.initState();
    _fortuneService = UnifiedFortuneService(
      Supabase.instance.client,
      enableOptimization: widget.enableOptimization,
    );
  }

  /// 운세 생성 실행 (신규 플로우: 블러 결과 즉시 표시 → 광고 → 블러 해제)
  Future<void> _handleSubmit() async {
    Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 시작: ${widget.fortuneType}');

    // 1. 프리미엄/영혼 체크
    final tokenState = ref.read(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);

    // 디버그 모드에서 프리미엄 오버라이드 확인
    final premiumOverride = await DebugPremiumService.getOverrideValue();
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

    // 2. 신규 플로우: 운세 생성 → 블러 상태로 즉시 표시 → 광고 → 블러 해제
    try {
      // 2-1. 운세 생성 (블러 상태)
      await _generateFortuneBlurred(isPremium: isPremium);

      // 2-2. Premium 사용자는 광고 생략하고 즉시 블러 해제
      if (isPremium) {
        Logger.info('[UnifiedFortuneBaseWidget] Premium 사용자 - 광고 생략, 블러 해제');
        await _unlockBlurredContent();
        return;
      }

      // 2-3. 블러된 결과가 표시된 상태에서 광고 표시 시도
      await AdService.instance.showInterstitialAdWithCallback(
        onAdCompleted: () async {
          Logger.info('[UnifiedFortuneBaseWidget] 광고 시청 완료 - 블러 해제');
          await _unlockBlurredContent();
        },
        onAdFailed: () async {
          Logger.info('[UnifiedFortuneBaseWidget] 광고 표시 실패 - 블러 해제');
          await _unlockBlurredContent();
        },
      );
      // ✅ 광고가 준비 안 됐으면 블러 유지 (AdService에서 콜백 호출 안함)
      // FloatingBottomButton을 통해 사용자가 직접 블러 해제하도록 유도
    } catch (e) {
      Logger.error('[UnifiedFortuneBaseWidget] 운세 생성 실패', e);
      // ❌ 에러 발생 시에만 블러 해제
      if (_fortuneResult == null) {
        // 운세 자체가 생성 안 됐으면 에러 표시
        return;
      }
    }
  }

  /// 블러 상태로 운세 생성 (신규)
  Future<void> _generateFortuneBlurred({required bool isPremium}) async {
    try {
      setState(() {
        _isLoading = true;
      });

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
              _isBlurred = blurredResult.isBlurred;
              _showResult = true;
              _isLoading = false;
            });
            Logger.info('[UnifiedFortuneBaseWidget] 🔒 블러 상태 결과 표시 완료 (_showResult: $_showResult)');
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
        _isBlurred = result.isBlurred;
        _showResult = true;
        _isLoading = false;
      });

      HapticUtils.success();
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
        _isBlurred = false;
      }
    });

    HapticUtils.success();
    Logger.info('[UnifiedFortuneBaseWidget] ✅ 블러 해제 완료');
  }

  /// 실제 운세 생성 로직 (레거시 - 기존 호환성 유지)
  Future<void> _generateFortune() async {
    try {
      Logger.info('[UnifiedFortuneBaseWidget] API 호출 시작');

      // 1. FortuneConditions 생성
      final conditions = await widget.conditionsBuilder();

      // 2. UnifiedFortuneService 호출 (6단계 최적화 자동 적용)
      final result = await _fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        dataSource: widget.dataSource,
        inputConditions: conditions.toJson(),
        conditions: conditions,
      );

      Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 완료: ${result.id}');

      if (!mounted) return;

      setState(() {
        _fortuneResult = result;
        _showResult = true;
        _isLoading = false;
      });

      HapticUtils.success();
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
          message: '운세 생성 중 오류가 발생했습니다',
          type: ToastType.error,
        );
      }
    }
  }

  /// 다시 입력하기 (결과 화면에서 입력 화면으로 돌아가기)
  void _handleReset() {
    setState(() {
      _showResult = false;
      _fortuneResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: widget.appBarBackgroundColor ??
          (isDark
              ? TossDesignSystem.backgroundDark
              : TossDesignSystem.backgroundLight),
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: widget.appBarBackgroundColor ??
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight),
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: _showResult ? null : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.title,
                style: TextStyle(
                  color: isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: _showResult ? [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => context.go('/fortune'),
                ),
              ] : null,
            )
          : null,
      body: _showResult && _fortuneResult != null
          ? _buildResultWithBlur(context)
          : widget.inputBuilder(context, _handleSubmit),
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
