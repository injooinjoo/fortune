import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';
import '../models/fortune_result.dart';
import '../services/unified_fortune_service.dart';
import '../utils/logger.dart';
import '../../shared/components/toast.dart';
import '../theme/toss_design_system.dart';
import '../../services/ad_service.dart';
import '../theme/typography_unified.dart';
import '../utils/haptic_utils.dart';
import '../constants/soul_rates.dart';
import '../../presentation/providers/providers.dart';
import '../../shared/components/token_insufficient_modal.dart';

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

  /// 에러 메시지
  String? _errorMessage;

  /// 생성된 운세 결과
  FortuneResult? _fortuneResult;

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

  /// 운세 생성 실행
  Future<void> _handleSubmit() async {
    Logger.info('[UnifiedFortuneBaseWidget] 운세 생성 시작: ${widget.fortuneType}');

    // 1. 프리미엄/영혼 체크
    final tokenState = ref.read(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);
    final isPremium = tokenState.hasUnlimitedAccess;

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

    // 2. 로딩 다이얼로그 표시
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.cardBackgroundDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: TossDesignSystem.tossBlue,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '운세를 생성하는 중...',
                    style: TypographyUnified.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? TossDesignSystem.textPrimaryDark
                          : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 3. 광고 표시
    try {
      await AdService.instance.showInterstitialAdWithCallback(
        onAdCompleted: () async {
          await _generateFortune();
        },
        onAdFailed: () async {
          await _generateFortune();
        },
      );
    } catch (e) {
      Logger.error('[UnifiedFortuneBaseWidget] 광고 표시 실패', e);
      await _generateFortune();
    }
  }

  /// 실제 운세 생성 로직
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

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

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
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        setState(() {
          _errorMessage = error.toString();
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
      _errorMessage = null;
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
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _showResult && _fortuneResult != null
              ? widget.resultBuilder(context, _fortuneResult!)
              : widget.inputBuilder(context, _handleSubmit),
    );
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
