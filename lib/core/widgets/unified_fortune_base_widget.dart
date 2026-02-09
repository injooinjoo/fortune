import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';
import '../models/fortune_result.dart';
import '../services/unified_fortune_service.dart';
import '../utils/logger.dart';
import '../../shared/components/toast.dart';
import '../design_system/design_system.dart';
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

  /// 운세 생성 실행 (토큰 소비 → 운세 생성 → 결과 표시)
  Future<void> _handleSubmit() async {
    Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 시작: ${widget.fortuneType}');

    final tokenNotifier = ref.read(tokenProvider.notifier);
    final requiredTokens = SoulRates.getTokenCost(widget.fortuneType);

    // 1. 토큰 확인
    if (!tokenNotifier.canAccessFortune(widget.fortuneType)) {
      Logger.warning('[UnifiedFortuneBaseWidget] 토큰 부족');
      HapticUtils.warning();
      await TokenInsufficientModal.show(
        context: context,
        requiredTokens: requiredTokens,
        fortuneType: widget.fortuneType,
      );
      return;
    }

    // 2. 토큰 소비 후 운세 생성
    try {
      // 2-0. 토큰 소비
      final consumed = await tokenNotifier.consumeTokens(fortuneType: widget.fortuneType);
      if (!consumed) {
        Logger.warning('[UnifiedFortuneBaseWidget] 토큰 소비 실패');
        // 토큰 부족 모달 표시
        if (mounted) {
          await TokenInsufficientModal.show(
            context: context,
            requiredTokens: requiredTokens,
            fortuneType: widget.fortuneType,
          );
        }
        return;
      }

      // 2-1. 결과 화면으로 전환 (스켈레톤 표시)
      setState(() {
        _showResult = true;
        _isLoading = true;
        _fortuneResult = null;
      });
      Logger.info('[UnifiedFortuneBaseWidget] 📱 결과 화면으로 전환 (로딩 스켈레톤 표시)');

      // 2-2. 운세 생성 (토큰 소비 완료, 바로 결과 표시)
      await _generateFortune();
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

  /// 운세 생성 (토큰 소비 완료 후 호출)
  Future<void> _generateFortune() async {
    try {
      Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 시작');

      // 1. FortuneConditions 생성
      final conditions = await widget.conditionsBuilder();

      // 2. UnifiedFortuneService 호출
      final result = await _fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        dataSource: widget.dataSource,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: true, // 토큰 소비 완료 = 프리미엄 접근
      );

      Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 완료: ${result.id}');

      if (!mounted) return;

      // 결과 즉시 표시
      setState(() {
        _fortuneResult = result;
        _showResult = true;
        _isLoading = false;
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
      child: const Column(
        children: [
          // 헤더 스켈레톤
          DSSkeleton(height: 140),
          SizedBox(height: DSSpacing.md),
          // 컨텐츠 스켈레톤
          DSSkeleton(height: 180),
          SizedBox(height: DSSpacing.md),
          DSSkeleton(height: 160),
          SizedBox(height: DSSpacing.md),
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

    // resultBuilder 호출
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
