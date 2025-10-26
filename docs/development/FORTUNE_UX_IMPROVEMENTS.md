# 운세 페이지 UX 개선 가이드

## 📋 개요

이 문서는 `daily_calendar_fortune_page.dart`에서 구현한 3가지 UX 개선사항을 다른 운세 페이지에도 동일하게 적용하기 위한 가이드입니다.

---

## 🎯 개선사항 요약

### 1. 광고 보기 버튼 - 한 번 클릭으로 처리
- **문제**: 광고 버튼을 두 번 눌러야 광고가 표시됨
- **해결**: 광고 로딩 완료 대기 로직 추가

### 2. "프리미엄 전용" 가짜 데이터 제거
- **문제**: 광고를 봐도 "🔒 프리미엄 결제 후 확인 가능합니다" 텍스트 표시
- **해결**: 서버는 항상 실제 데이터 생성, 블러는 클라이언트 UI만 처리

### 3. 로딩 페이지 제거 + 버튼 로딩 애니메이션
- **문제**: "운세 보기" 버튼 클릭 시 흰색 로딩 페이지로 전환
- **해결**: 입력 폼 유지 + 버튼에 점 3개 로딩 애니메이션

---

## 📝 상세 수정 가이드

### 1️⃣ 광고 로딩 대기 로직 추가

#### 파일: `lib/features/fortune/presentation/pages/[운세타입]_page.dart`

#### 수정 위치: 광고 로드 함수 (`_showAdAndUnblur` 또는 유사 함수)

#### Before (❌ 문제 코드)
```dart
Future<void> _showAdAndUnblur() async {
  final adService = ref.read(adServiceProvider);

  // 광고 로드
  await adService.loadRewardedAd();

  // ❌ 즉시 광고 표시 시도 (로딩 안 끝났을 수 있음!)
  await adService.showRewardedAd(
    onUserEarnedReward: (ad, reward) {
      // 블러 해제 로직
    },
  );
}
```

#### After (✅ 해결 코드)
```dart
Future<void> _showAdAndUnblur() async {
  debugPrint('');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  debugPrint('🎬 [광고] 블러 해제 프로세스 시작');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final adService = ref.read(adServiceProvider);

  debugPrint('');
  debugPrint('1️⃣ 광고 로딩 시작...');
  await adService.loadRewardedAd();

  // ✅ 광고 로딩 완료 대기 (최대 5초)
  int waitCount = 0;
  while (!adService.isRewardedAdReady && waitCount < 10) {
    await Future.delayed(const Duration(milliseconds: 500));
    waitCount++;
    debugPrint('   ⏳ 광고 로딩 대기 중... (${waitCount * 500}ms)');
  }

  if (!adService.isRewardedAdReady) {
    debugPrint('   ❌ 광고 로딩 실패 - 타임아웃');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('광고를 불러오지 못했습니다. 다시 시도해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return;
  }

  debugPrint('   ✅ 광고 로딩 완료!');
  debugPrint('');
  debugPrint('2️⃣ 광고 표시 시작...');

  await adService.showRewardedAd(
    onAdDismissedFullScreenContent: (ad) {
      debugPrint('   → 광고 닫힘 (보상 없음)');
      ad.dispose();
    },
    onUserEarnedReward: (ad, reward) {
      debugPrint('');
      debugPrint('3️⃣ 광고 시청 완료!');
      debugPrint('   - reward.type: ${reward.type}');
      debugPrint('   - reward.amount: ${reward.amount}');

      // 블러 해제 로직 (아래 2번 참고)
    },
  );
}
```

---

### 2️⃣ "프리미엄 전용" 가짜 데이터 제거

#### A. 서버 수정 (Edge Function)

#### 파일: `supabase/functions/fortune-[타입]/index.ts`

#### 수정 위치: 운세 데이터 생성 부분

#### Before (❌ 문제 코드)
```typescript
// 프리미엄 여부에 따라 조건부 데이터 생성
const isBlurred = !isPremium
const blurredSections = isBlurred
  ? ['categories', 'advice', 'caution', ...]
  : []

const fortune = {
  // ❌ 프리미엄 아니면 가짜 데이터
  advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : generateDynamicAdvice(),
  caution: isBlurred ? '🔒 프리미엄 전용' : generateDynamicCaution(),
  special_tip: isBlurred ? '🔒 프리미엄 전용' : generateDynamicSpecialTip(),
  // ...
}
```

#### After (✅ 해결 코드)
```typescript
// ✅ 서버는 항상 실제 데이터 생성, 블러는 클라이언트에서만 처리
const isBlurred = !isPremium
const blurredSections = isBlurred
  ? ['categories', 'advice', 'caution', ...]
  : []

const fortune = {
  // ✅ 항상 실제 데이터 생성 (블러는 클라이언트 UI 참고용)
  advice: generateDynamicAdvice(),
  caution: generateDynamicCaution(),
  special_tip: generateDynamicSpecialTip(),
  // ...

  // 블러 상태만 전달 (클라이언트 UI 참고용)
  isBlurred,
  blurredSections
}
```

#### 배포 명령어
```bash
supabase functions deploy fortune-[타입]
```

---

#### B. 클라이언트 수정 (Flutter)

#### 파일: `lib/features/fortune/presentation/pages/[운세타입]_page.dart`

#### 수정 위치: 광고 시청 완료 콜백 (`onUserEarnedReward`)

#### Before (❌ 문제 코드)
```dart
onUserEarnedReward: (ad, reward) async {
  debugPrint('광고 시청 완료!');

  // ❌ API 재호출 (isPremium: true로 변경해서 다시 요청)
  final fortuneService = UnifiedFortuneService(Supabase.instance.client);
  final newResult = await fortuneService.getFortune(
    fortuneType: 'daily_calendar',
    dataSource: FortuneDataSource.api,
    inputConditions: inputConditions,
    conditions: conditions,
    isPremium: true,  // ❌ 프리미엄으로 다시 요청!
  );

  if (mounted) {
    setState(() {
      _fortuneResult = newResult;
    });
  }
}
```

#### After (✅ 해결 코드)
```dart
onUserEarnedReward: (ad, reward) {
  debugPrint('');
  debugPrint('3️⃣ 광고 시청 완료!');
  debugPrint('   - reward.type: ${reward.type}');
  debugPrint('   - reward.amount: ${reward.amount}');

  // ✅ 광고 시청 완료 시 블러만 해제 (데이터는 이미 실제 내용)
  if (mounted) {
    debugPrint('   → 블러 해제 중...');

    setState(() {
      _fortuneResult = _fortuneResult!.copyWith(
        isBlurred: false,
        blurredSections: [],
      );
    });

    debugPrint('   ✅ 블러 해제 완료!');
    debugPrint('      - 새 상태: isBlurred=false');
    debugPrint('      - 새 상태: blurredSections=[]');

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('운세가 잠금 해제되었습니다!')),
    );

    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('✅ [광고] 블러 해제 프로세스 완료!');
    debugPrint('   → 사용자는 이제 전체 운세 내용을 볼 수 있습니다');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('');
  } else {
    debugPrint('   ⚠️ Widget이 이미 dispose됨. 블러 해제 취소.');
  }
}
```

---

### 3️⃣ 로딩 페이지 제거 + 버튼 로딩 애니메이션

#### A. 로딩 Scaffold 제거

#### 파일: `lib/features/fortune/presentation/pages/[운세타입]_page.dart`

#### 수정 위치: `build()` 메서드

#### Before (❌ 문제 코드)
```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // ❌ 로딩 중일 때 별도 로딩 페이지 표시
  if (_isLoading) {
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  // 운세 결과가 있으면 결과 화면 표시
  if (_fortuneResult != null) {
    return Scaffold(
      // 결과 화면...
    );
  }

  // 입력 폼
  return Scaffold(
    // 입력 폼...
  );
}
```

#### After (✅ 해결 코드)
```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // 🔍 디버그 로깅: build() 호출 시점과 상태 체크
  debugPrint('');
  debugPrint('🔍 [BUILD] [운세타입]_page.dart build() 호출됨');
  debugPrint('   - _fortuneResult: ${_fortuneResult != null ? "있음" : "없음"}');
  debugPrint('   - _isLoading: $_isLoading');
  debugPrint('   - 표시할 화면: ${_fortuneResult != null && !_isLoading ? "결과 화면" : "입력 폼"}');
  debugPrint('');

  // ✅ 운세 결과가 있고 로딩 중이 아닐 때만 결과 화면 표시
  if (_fortuneResult != null && !_isLoading) {
    debugPrint('📄 [BUILD] → 결과 화면(Scaffold) 렌더링 시작');
    return Scaffold(
      // 결과 화면...
    );
  }

  // ✅ 로딩 중일 때는 입력 폼을 계속 표시 (버튼에 로딩 애니메이션)
  // 로딩 페이지 제거 - 버튼 자체에서 로딩 표시

  // 에러 발생
  if (_error != null) {
    return Scaffold(
      // 에러 화면...
    );
  }

  // ✅ 기본 입력 폼 (로딩 중에도 이 화면 유지)
  return Scaffold(
    // 입력 폼...
  );
}
```

---

#### B. 운세 생성 함수 최적화

#### 파일: `lib/features/fortune/presentation/pages/[운세타입]_page.dart`

#### 수정 위치: `_generateFortune()` 메서드

#### Before (❌ 문제 코드)
```dart
Future<void> _generateFortune() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    // API 호출
    final fortuneResult = await fortuneService.getFortune(...);

    // ❌ 즉시 setState (버튼 로딩 애니메이션 볼 시간 없음)
    if (mounted) {
      setState(() {
        _fortuneResult = fortuneResult;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

#### After (✅ 해결 코드)
```dart
Future<void> _generateFortune() async {
  // ✅ 1단계: 즉시 로딩 상태 표시 (버튼 애니메이션 시작)
  if (mounted) {
    setState(() {
      _isLoading = true;
      _error = null;
    });
  }

  try {
    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔮 [운세타입] 운세 생성 프로세스 시작');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // 1️⃣ 프리미엄 상태 확인
    final tokenState = ref.read(tokenProvider);
    final premiumOverride = await DebugPremiumService.getOverrideValue();
    final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

    debugPrint('');
    debugPrint('1️⃣ 프리미엄 상태 확인');
    debugPrint('   - 최종 isPremium: $isPremium');

    // UnifiedFortuneService 사용
    final fortuneService = UnifiedFortuneService(Supabase.instance.client);

    // 조건 객체 생성
    final conditions = /* 운세별 조건 */;
    final inputConditions = /* 입력 조건 */;

    debugPrint('');
    debugPrint('2️⃣ UnifiedFortuneService.getFortune() 호출');
    debugPrint('   - fortuneType: [운세타입]');
    debugPrint('   - isPremium: $isPremium');
    debugPrint('   → API 호출 시작...');

    // ✅ 2단계: 타이머 시작 (최소 1초 보장)
    final startTime = DateTime.now();

    final fortuneResult = await fortuneService.getFortune(
      fortuneType: '[운세타입]',
      dataSource: FortuneDataSource.api,
      inputConditions: inputConditions,
      conditions: conditions,
      isPremium: isPremium,
    );

    debugPrint('');
    debugPrint('3️⃣ 운세 생성 완료');
    debugPrint('   - fortuneResult.isBlurred: ${fortuneResult.isBlurred}');

    // ✅ 3단계: 무조건 최소 1초 대기 (API가 빨라도 버튼 애니메이션 보장)
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remainingTime = 1000 - elapsed;

    if (remainingTime > 0) {
      debugPrint('');
      debugPrint('⏳ 버튼 로딩 애니메이션 표시 중... (${remainingTime}ms 추가 대기)');
      await Future.delayed(Duration(milliseconds: remainingTime));
    } else {
      debugPrint('');
      debugPrint('✅ API 호출 완료 (${elapsed}ms) - 즉시 결과 표시');
    }

    if (mounted) {
      setState(() {
        _fortuneResult = fortuneResult;
        _isLoading = false;
      });

      debugPrint('');
      debugPrint('4️⃣ UI 상태 업데이트 완료');

      // 히스토리 저장
      await _saveToHistory(fortuneResult);

      // 통계 업데이트
      await _updateStatistics();

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ [운세타입] 운세 생성 프로세스 완료!');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('');
    }
  } catch (e) {
    debugPrint('');
    debugPrint('❌ [운세타입] 운세 생성 실패!');
    debugPrint('   에러: $e');
    debugPrint('');

    if (mounted) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

---

#### C. 버튼에 로딩 상태 연결

#### 파일: `lib/features/fortune/presentation/pages/[운세타입]_page.dart`

#### 수정 위치: 버튼 위젯 (보통 `_buildFloatingButton()` 메서드 또는 마지막 step의 버튼)

#### Before (❌ 문제 코드)
```dart
return TossFloatingProgressButtonPositioned(
  text: buttonText,
  currentStep: _currentStep + 1,
  totalSteps: 3,
  onPressed: onPressed,
  isEnabled: canProceed,
  showProgress: true,
  isVisible: true,
  // ❌ isLoading 파라미터 없음!
);
```

#### After (✅ 해결 코드)
```dart
return TossFloatingProgressButtonPositioned(
  text: buttonText,
  currentStep: _currentStep + 1,
  totalSteps: 3,
  onPressed: onPressed,
  isEnabled: canProceed,
  showProgress: true,
  isVisible: true,
  isLoading: _isLoading, // ✅ 로딩 상태 연결!
);
```

---

#### D. 점 3개 로딩 애니메이션 (이미 구현됨)

**파일**: `lib/shared/components/toss_floating_progress_button.dart`

이 파일은 **이미 수정 완료**되어 있으므로 다른 운세 페이지에서는 **수정 불필요**합니다!

```dart
// Lines 212-275에 _ThreeDotsLoadingIndicator 위젯 구현됨
// Line 163에서 CircularProgressIndicator → _ThreeDotsLoadingIndicator로 변경됨
```

---

## 📋 체크리스트 (다른 운세 페이지 적용 시)

### Flutter 클라이언트 수정

- [ ] **광고 로딩 대기 로직 추가**
  - [ ] `_showAdAndUnblur()` 함수에 `while` 루프 추가
  - [ ] 타임아웃 처리 (최대 5초)
  - [ ] 에러 메시지 표시

- [ ] **광고 시청 콜백 수정**
  - [ ] `onUserEarnedReward`에서 API 재호출 제거
  - [ ] `_fortuneResult.copyWith(isBlurred: false)` 패턴 적용

- [ ] **로딩 페이지 제거**
  - [ ] `build()` 메서드에서 `if (_isLoading)` Scaffold 제거 또는 주석 처리
  - [ ] 결과 화면 조건에 `&& !_isLoading` 추가

- [ ] **로딩 순서 최적화**
  - [ ] `_generateFortune()` 시작 시 즉시 `setState(_isLoading: true)`
  - [ ] API 호출 전 타이머 시작 (`final startTime = DateTime.now()`)
  - [ ] API 호출 후 최소 1초 대기 로직 추가
  - [ ] setState로 `_fortuneResult`와 `_isLoading: false` 동시 설정

- [ ] **버튼 로딩 연결**
  - [ ] `TossFloatingProgressButtonPositioned`에 `isLoading: _isLoading` 추가

### Edge Function 수정

- [ ] **서버 항상 실제 데이터 생성**
  - [ ] `fortune-[타입]/index.ts` 파일 수정
  - [ ] 조건부 가짜 데이터 생성 제거 (`isBlurred ? '🔒 프리미엄 전용' : ...`)
  - [ ] 항상 실제 함수 호출 (`generateDynamicAdvice()` 등)
  - [ ] `supabase functions deploy fortune-[타입]` 배포

---

## 🎯 적용 대상 운세 페이지 목록

다음 페이지들에 동일한 패턴을 적용해야 합니다:

### UnifiedFortuneService 기반 페이지 (우선 적용)
1. `mbti_fortune_page.dart` - MBTI 운세
2. `face_reading_fortune_page.dart` - 관상 운세
3. `tarot_renewed_page.dart` - 타로 운세
4. `compatibility_page.dart` - 궁합 운세
5. `moving_fortune_toss_page.dart` - 이사운
6. `talent_fortune_input_page.dart` - 재능 발견

### BaseFortunePage 기반 페이지 (리팩토링 후 적용)
7. `career_future_fortune_page.dart` - 직업 미래
8. `career_seeker_fortune_page.dart` - 구직자 운세
9. `celebrity_fortune_page_v2.dart` - 유명인 운세
10. `destiny_fortune_page.dart` - 운명 운세
11. `employment_fortune_page.dart` - 취업 운세
12. `lucky_investment_fortune_page.dart` - 투자 운세
13. `lucky_outfit_fortune_page.dart` - 행운 아이템
14. `lucky_series_fortune_page.dart` - 행운 시리즈
15. `lucky_stock_fortune_page.dart` - 주식 운세
16. `palmistry_fortune_page.dart` - 손금 운세
17. `saju_page.dart` - 사주 운세
18. `tojeong_fortune_page.dart` - 토정비결
19. 기타 운세 페이지들...

---

## 💡 참고 파일

**완벽하게 구현된 레퍼런스**:
- `lib/features/fortune/presentation/pages/daily_calendar_fortune_page.dart`
- `lib/shared/components/toss_floating_progress_button.dart` (점 3개 애니메이션)

**서버 레퍼런스**:
- `supabase/functions/fortune-daily/index.ts` (lines 1199-1237)

---

## 🚨 주의사항

1. **운세 타입별 조건 (`conditions`) 확인**
   - 각 운세마다 `DailyFortuneConditions`, `TarotFortuneConditions` 등 다름
   - 올바른 조건 객체 사용 필수!

2. **Edge Function 이름 확인**
   - `fortune-daily`, `fortune-mbti`, `fortune-tarot` 등
   - 배포 시 올바른 함수 이름 사용

3. **기존 로직 보존**
   - 히스토리 저장, 통계 업데이트 로직은 그대로 유지
   - 광고 관련 로직만 수정

4. **디버그 로그 유지**
   - 모든 `debugPrint` 로그는 개발 시 문제 파악에 중요
   - 프로덕션 빌드에서 자동으로 제거됨

---

## ✅ 테스트 체크리스트

각 운세 페이지 수정 후 다음 항목을 테스트하세요:

### 일반 사용자 (프리미엄 아님)
- [ ] 운세 생성 시 블러 적용됨
- [ ] "남은 운세 모두 보기" 버튼 표시됨
- [ ] **버튼 한 번 클릭으로 광고 표시** (두 번 클릭 불필요!)
- [ ] 광고 시청 완료 시 블러 해제됨
- [ ] 블러 해제 후 **실제 운세 내용** 표시 (프리미엄 전용 메시지 ❌)

### 프리미엄 사용자
- [ ] 운세 생성 시 블러 없이 즉시 전체 내용 표시
- [ ] "남은 운세 모두 보기" 버튼 표시 안 됨

### 로딩 UX
- [ ] "운세 보기" 버튼 클릭 시 **흰색 로딩 페이지 안 나타남**
- [ ] 버튼 안에 **점 3개 로딩 애니메이션** 표시됨
- [ ] 입력 폼 화면이 유지됨 (화면 전환 없음)
- [ ] 최소 1초 후 결과 화면으로 전환

### 엣지 케이스
- [ ] 광고 로딩 실패 시 에러 메시지 표시
- [ ] 네트워크 에러 시 적절한 에러 처리
- [ ] API 호출 실패 시 에러 화면 표시

---

## 📚 관련 문서

- [FORTUNE_OPTIMIZATION_GUIDE.md](../data/FORTUNE_OPTIMIZATION_GUIDE.md) - 운세 조회 최적화 시스템
- [LLM_MODULE_GUIDE.md](../data/LLM_MODULE_GUIDE.md) - LLM 모듈 사용 가이드
- [TOSS_DESIGN_SYSTEM.md](../design/TOSS_DESIGN_SYSTEM.md) - 디자인 시스템
- [CLAUDE_AUTOMATION.md](./CLAUDE_AUTOMATION.md) - JIRA 자동화 워크플로우

---

**작성일**: 2025-10-26
**기준 구현**: `daily_calendar_fortune_page.dart`
**작성자**: Claude Code

