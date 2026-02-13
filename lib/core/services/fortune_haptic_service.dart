import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../utils/haptic_utils.dart';
import '../providers/user_settings_provider.dart';

/// Fortune 앱 전용 햅틱 피드백 서비스
///
/// 토스/듀오링고 스타일의 감성적인 햅틱 피드백을 제공합니다.
///
/// ## 핵심 원칙
/// 1. **희소성**: 특별한 순간에만 강한 햅틱 (듀오링고 방식)
/// 2. **동기화**: 애니메이션과 타이밍 일치
/// 3. **차별화**: 운세 유형별 맞춤 패턴
///
/// ## 4-Tier 계층 구조
/// - **Tier 1 (마법적 순간)**: 타로 공개, 결과 공개, 프리미엄 언락
/// - **Tier 2 (중요 전환)**: 카드 선택, 분석 시작, 섹션 완료
/// - **Tier 3 (일반 인터랙션)**: 버튼 탭, 스크롤 스냅
/// - **Tier 4 (무음)**: 일반 스크롤, 키보드 입력
class FortuneHapticService {
  final Ref _ref;
  static bool? _deviceCanVibrate;

  FortuneHapticService(this._ref);

  /// 앱 시작 시 디바이스 진동 지원 여부 캐싱
  static Future<void> initialize() async {
    try {
      _deviceCanVibrate = await Haptics.canVibrate();
    } catch (e) {
      _deviceCanVibrate = false;
    }
  }

  /// 햅틱 활성화 여부 확인
  bool get isEnabled => _ref.read(userSettingsProvider).hapticEnabled;

  /// 햅틱 실행 가능 여부 확인
  bool get _canExecute => isEnabled && (_deviceCanVibrate ?? false);

  // ============================================================
  // TIER 1: 마법적 순간 (희소하게 사용)
  // ============================================================

  /// 타로 카드 공개 - 핵심 마법 순간
  ///
  /// 패턴: 예고 → 공개 → 여운
  /// 타이밍: 애니메이션 50% 지점에서 호출
  Future<void> mysticalReveal() async {
    if (!_canExecute) return;

    await HapticUtils.soft(); // 예고 (0ms)
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticUtils.success(); // 공개 (100ms)
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticUtils.mediumImpact(); // 여운 (150ms)
  }

  /// 점수 기반 결과 공개
  ///
  /// 점수에 따라 햅틱 강도 차별화:
  /// - 90+: 축하 (heavy + success x2)
  /// - 80+: 기쁨 (success)
  /// - 70+: 만족 (medium)
  /// - 50+: 중립 (light)
  /// - 30+: 성찰 (soft)
  /// - 0+: 위로 (soft - 부정적 느낌 최소화)
  Future<void> scoreReveal(int score) async {
    if (!_canExecute) return;

    if (score >= 90) {
      await HapticUtils.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticUtils.success();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticUtils.success();
    } else if (score >= 80) {
      await HapticUtils.success();
    } else if (score >= 70) {
      await HapticUtils.mediumImpact();
    } else if (score >= 50) {
      await HapticUtils.lightImpact();
    } else {
      // 낮은 점수: soft로 부드럽게 (부정적 느낌 최소화)
      await HapticUtils.soft();
    }
  }

  /// 프리미엄 콘텐츠 언락 - 가장 중요한 순간!
  ///
  /// 토큰 사용 후 콘텐츠 공개 시 사용
  /// 패턴: 예고 → 상승 → 클라이막스 → 공개 → 완료
  Future<void> premiumUnlock() async {
    if (!_canExecute) return;

    await HapticUtils.soft(); // Phase 1: 예고 (0ms)
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticUtils.lightImpact(); // Phase 2: 상승 (200ms)
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticUtils.mediumImpact(); // Phase 3: 클라이막스 (350ms)
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticUtils.heavyImpact(); // Phase 4: 공개 (450ms)
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticUtils.success(); // Phase 5: 완료 (500ms)
  }

  /// 궁합 점수 공개
  ///
  /// 90점 이상: 천생연분 (더블 피드백)
  Future<void> compatibilityReveal(int score) async {
    if (!_canExecute) return;

    if (score >= 90) {
      await HapticUtils.success();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticUtils.mediumImpact();
    } else if (score >= 70) {
      await HapticUtils.success();
    } else {
      await HapticUtils.mediumImpact();
    }
  }

  /// 잭팟 (Top 1% 운세)
  ///
  /// 특별한 행운의 순간을 위한 최고 강도 햅틱
  Future<void> jackpot() async {
    if (!_canExecute) return;

    for (int i = 0; i < 3; i++) {
      await HapticUtils.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticUtils.success();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  // ============================================================
  // TIER 2: 중요 전환
  // ============================================================

  /// 타로 카드 선택 확정
  Future<void> cardSelect() async {
    if (!_canExecute) return;
    await HapticUtils.mediumImpact();
  }

  /// 운세 분석 시작 (로딩 진입)
  Future<void> analysisStart() async {
    if (!_canExecute) return;
    await HapticUtils.mediumImpact();
  }

  /// 섹션 완료 (아코디언 등)
  Future<void> sectionComplete() async {
    if (!_canExecute) return;
    await HapticUtils.mediumImpact();
  }

  /// 날짜/시간 선택 확정
  Future<void> dateConfirm() async {
    if (!_canExecute) return;
    await HapticUtils.mediumImpact();
  }

  /// 로딩 완료
  Future<void> loadingComplete() async {
    if (!_canExecute) return;
    await HapticUtils.success();
  }

  // ============================================================
  // TIER 3: 일반 인터랙션
  // ============================================================

  /// 버튼 탭
  Future<void> buttonTap() async {
    if (!_canExecute) return;
    await HapticUtils.selection();
  }

  /// 페이지/스크롤 스냅
  Future<void> pageSnap() async {
    if (!_canExecute) return;
    await HapticUtils.lightImpact();
  }

  /// 일반 선택 (체크박스, 라디오 등)
  Future<void> selection() async {
    if (!_canExecute) return;
    await HapticUtils.selection();
  }

  /// 아코디언 확장 (열기만, 완료는 sectionComplete)
  Future<void> accordionExpand() async {
    // 너무 자주 발생하므로 무음 처리
    // 완료 시에만 sectionComplete() 호출
  }

  // ============================================================
  // 바텀시트/모달 전용
  // ============================================================

  /// 바텀시트 열림
  ///
  /// 시트가 올라올 때 가벼운 피드백
  Future<void> sheetOpen() async {
    if (!_canExecute) return;
    await HapticUtils.lightImpact();
  }

  /// 바텀시트 닫힘
  ///
  /// 시트가 내려갈 때 부드러운 피드백
  Future<void> sheetDismiss() async {
    if (!_canExecute) return;
    await HapticUtils.soft();
  }

  // ============================================================
  // 슬라이더/입력 전용
  // ============================================================

  /// 슬라이더 스냅 포인트
  ///
  /// 슬라이더가 정수 값(1, 2, 3 등)에 스냅될 때
  Future<void> sliderSnap() async {
    if (!_canExecute) return;
    await HapticUtils.selection();
  }

  // ============================================================
  // 로딩 화면 전용
  // ============================================================

  /// 로딩 스텝 변경 (롤링 텍스트)
  ///
  /// "우주의 기운을 모으는 중..." 등 텍스트 변경 시
  Future<void> loadingStep() async {
    if (!_canExecute) return;
    await HapticUtils.soft();
  }

  /// 로딩 마지막 스텝 (완료 직전)
  Future<void> loadingLastStep() async {
    if (!_canExecute) return;
    await HapticUtils.success();
  }

  // ============================================================
  // 운세 테마별 특수 패턴
  // ============================================================

  /// 연애 운세 - 하트비트 패턴
  ///
  /// 두근두근 느낌을 위한 심장박동 패턴
  Future<void> loveHeartbeat() async {
    if (!_canExecute) return;

    await HapticUtils.heavyImpact(); // Thump
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticUtils.mediumImpact(); // Ba-bump
  }

  /// 투자 운세 - 동전 패턴
  ///
  /// 동전 떨어지는 느낌의 트리플 rigid
  Future<void> investmentCoin() async {
    if (!_canExecute) return;

    await HapticUtils.rigid();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticUtils.rigid();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticUtils.rigid();
  }

  /// 궁합 게이지 진행
  ///
  /// 게이지 진행률에 따른 햅틱
  Future<void> gaugeProgress(double percent) async {
    if (!_canExecute) return;

    if (percent == 0.25) {
      await HapticUtils.soft();
    } else if (percent == 0.5) {
      await HapticUtils.lightImpact();
    } else if (percent == 0.75) {
      await HapticUtils.mediumImpact();
    }
    // 100%는 scoreReveal 또는 compatibilityReveal 사용
  }

  // ============================================================
  // 인터랙티브 기능 전용
  // ============================================================

  /// 포춘쿠키 흔들기 패턴
  ///
  /// 쿠키를 탭한 후 흔들리는 애니메이션 동안 사용
  /// 4회 연속 빠른 진동으로 흔들리는 느낌 표현
  Future<void> cookieShake() async {
    if (!_canExecute) return;

    for (int i = 0; i < 4; i++) {
      await HapticUtils.lightImpact();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  /// 긁기/스크래치 패턴
  ///
  /// 복권 긁기, 숨겨진 내용 드러내기 등에 사용
  /// 부드럽고 연속적인 느낌
  Future<void> scratch() async {
    if (!_canExecute) return;
    await HapticUtils.soft();
  }

  /// 스와이프 완료 패턴
  ///
  /// 카드 스와이프, 슬라이드 완료 시 사용
  Future<void> swipeComplete() async {
    if (!_canExecute) return;
    await HapticUtils.lightImpact();
  }

  /// 숫자 키패드 입력
  ///
  /// 생년월일 등 숫자 입력 시 가벼운 피드백
  Future<void> keypadTap() async {
    if (!_canExecute) return;
    await HapticUtils.selection();
  }

  /// 슬롯머신/룰렛 스핀
  ///
  /// 회전하는 요소의 틱 사운드처럼 반복 피드백
  Future<void> spinTick() async {
    if (!_canExecute) return;
    await HapticUtils.soft();
  }

  /// 탭앤홀드 시작
  ///
  /// 길게 누르기 시작 시 피드백
  Future<void> longPressStart() async {
    if (!_canExecute) return;
    await HapticUtils.mediumImpact();
  }

  /// 염주 구슬 회전 틱
  ///
  /// 염주 페이지에서 구슬이 회전할 때마다 호출
  /// 부드러운 틱으로 명상적인 느낌 연출
  Future<void> beadRotateTick() async {
    if (!_canExecute) return;
    await HapticUtils.soft();
  }

  // ============================================================
  // 액션 완료 전용
  // ============================================================

  /// 공유하기 액션
  ///
  /// 공유 버튼 탭 시 액션 인식 피드백
  Future<void> shareAction() async {
    if (!_canExecute) return;
    await HapticUtils.mediumImpact();
  }

  /// 부적 저장 완료 - 시그니처 햅틱!
  ///
  /// 부적이 성공적으로 생성/저장되었을 때
  /// 3단계 축하 패턴: 인식 → 성공 → 완료감
  Future<void> talismanSaved() async {
    if (!_canExecute) return;

    await HapticUtils.mediumImpact(); // 1. 인식 (0ms)
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticUtils.success(); // 2. 성공 (200ms)
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticUtils.heavyImpact(); // 3. 완료감 (300ms)
  }

  /// 검색 완료
  ///
  /// 검색 결과가 로드되었을 때 가벼운 피드백
  Future<void> searchComplete() async {
    if (!_canExecute) return;
    await HapticUtils.lightImpact();
  }

  /// 성공 피드백
  ///
  /// 폼 제출, 저장 완료 등 일반적인 성공 시
  Future<void> successFeedback() async {
    if (!_canExecute) return;
    await HapticUtils.success();
  }

  // ============================================================
  // 특수 이벤트
  // ============================================================

  /// 첫 운세 경험
  Future<void> firstFortune() async {
    if (!_canExecute) return;

    await HapticUtils.soft();
    await Future.delayed(const Duration(milliseconds: 300));
    await HapticUtils.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticUtils.success();
  }

  /// 스트릭 축하 - 시그니처 햅틱!
  ///
  /// 연속 운세 조회 기념
  /// - 30일+: 웅장한 축하 (heavy → success × 2)
  /// - 7일+: 적당한 축하 (medium → success)
  /// - 3일+: 가벼운 인식 (light → success)
  /// - 1일+: 시작 응원 (light)
  Future<void> streak(int days) async {
    if (!_canExecute) return;

    if (days >= 30) {
      // 30일 달성: 웅장한 축하 패턴
      await HapticUtils.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticUtils.success();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticUtils.success();
    } else if (days >= 7) {
      // 7일 달성: 적당한 축하
      await HapticUtils.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticUtils.success();
    } else if (days >= 3) {
      // 3일 달성: 가벼운 인식
      await HapticUtils.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticUtils.success();
    } else if (days >= 1) {
      // 1일 이상: 시작 응원
      await HapticUtils.lightImpact();
    }
  }

  /// 에러 발생
  Future<void> error() async {
    if (!_canExecute) return;
    await HapticUtils.error();
  }

  /// 경고
  Future<void> warning() async {
    if (!_canExecute) return;
    await HapticUtils.warning();
  }
}

/// FortuneHapticService Provider
final fortuneHapticServiceProvider = Provider<FortuneHapticService>((ref) {
  return FortuneHapticService(ref);
});

/// WidgetRef Extension - 쉬운 접근을 위한 확장
extension FortuneHapticRef on WidgetRef {
  FortuneHapticService get haptic => read(fortuneHapticServiceProvider);
}

/// Ref Extension - Provider 내부에서 사용
extension FortuneHapticRefExt on Ref {
  FortuneHapticService get haptic => read(fortuneHapticServiceProvider);
}
