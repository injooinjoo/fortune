# Fortune 앱 햅틱 피드백 정책

## 개요

Fortune 앱의 햅틱 피드백 시스템은 **토스와 듀오링고**의 접근 방식을 참고하여 설계되었습니다.

### 핵심 원칙: 희소성 (Scarcity)

> "듀오링고는 레슨 완료 시에만 강한 햅틱을 사용한다. 나머지 상호작용에서는 햅틱이 거의 없다." - 듀오링고 UX 팀

- **과도한 햅틱은 역효과**: 모든 곳에 햅틱을 넣으면 특별함이 사라짐
- **마법 같은 순간에 집중**: 핵심 보상 순간에만 강한 피드백
- **애니메이션과 동기화**: 시각적 피드백과 햅틱의 타이밍 일치

---

## 4-Tier 햅틱 계층 구조

### Tier 1: 마법적 순간 (Magical Moments)
**가장 희소하게 사용** - 앱에서 가장 특별한 순간

| 순간 | 햅틱 패턴 | 설명 |
|------|----------|------|
| 타로 카드 공개 | `mysticalReveal()` | soft → success → medium (3단계) |
| 운세 결과 블러 해제 | `premiumUnlock()` | soft → light → medium → heavy → success (5단계) |
| 높은 점수 공개 (90+) | `scoreReveal(score)` | heavy → success x2 |
| Top 1% 운세 | `jackpot()` | (heavy + success) x3 반복 |

### Tier 2: 중요 전환 (Important Transitions)
**중요한 상태 변화 시** - 사용자의 의미있는 행동에 반응

| 순간 | 햅틱 패턴 | 설명 |
|------|----------|------|
| 타로 카드 선택 | `cardSelect()` | medium 1회 |
| 운세 분석 시작 | `analysisStart()` | medium 1회 |
| 섹션 완료 | `sectionComplete()` | medium 1회 |
| 날짜/시간 선택 확정 | `dateConfirm()` | medium 1회 |
| 로딩 완료 | `loadingComplete()` | success 1회 |

### Tier 3: 일반 인터랙션 (General Interactions)
**가벼운 피드백** - 터치에 대한 확인 응답

| 순간 | 햅틱 패턴 | 설명 |
|------|----------|------|
| 버튼 탭 | `buttonTap()` | selection 1회 |
| 페이지/스크롤 스냅 | `pageSnap()` | light 1회 |
| 체크박스/라디오 선택 | `selection()` | selection 1회 |

### Tier 4: 무음 (Silent)
**햅틱 없음** - 과도한 피드백 방지

- 일반 스크롤
- 키보드 입력
- 호버/포커스 변경
- 애니메이션 중간
- 아코디언 확장/축소 (완료 시만 피드백)

---

## 로딩 화면 햅틱

### DivineLoadingAnimation
신비로운 로딩 애니메이션의 각 단계에서 햅틱 피드백

```
"신께 소원을 전달하는 중..." → soft()
"우주의 기운을 모으는 중..." → soft()
"운명의 실을 찾는 중..." → soft()
"신의 응답을 받는 중..." → success() (마지막 스텝)
[완료] → success()
```

### EmotionalLoadingChecklist
50개 감성 메시지 롤링 시 각 스텝마다 피드백

```
각 스텝 전환 → soft()
로딩 완료 → success()
```

---

## 운세 유형별 특수 패턴

### 연애 운세: 하트비트 (Heartbeat)
두근두근 심장박동 느낌
```dart
await haptic.loveHeartbeat();
// heavy → medium (100ms 간격)
```

### 투자 운세: 동전 (Coin Drop)
동전 떨어지는 느낌
```dart
await haptic.investmentCoin();
// rigid x3 (80ms 간격)
```

### 궁합 운세: 점수 기반
점수에 따른 차별화된 피드백
```dart
await haptic.compatibilityReveal(score);
// 90+: success → medium
// 70+: success
// 70-: medium
```

### 점수 공개: 등급별 강도
```dart
await haptic.scoreReveal(score);
// 90+: heavy → success x2 (축하)
// 80+: success (기쁨)
// 70+: medium (만족)
// 50+: light (중립)
// 0+: soft (위로 - 부정적 느낌 최소화)
```

---

## 특수 이벤트

### 스트릭 축하
연속 운세 조회 기념

| 일수 | 햅틱 패턴 |
|------|----------|
| 30일+ | `jackpot()` |
| 7일+ | medium → success x2 |
| 3일+ | light → success |

### 첫 운세 경험
```dart
await haptic.firstFortune();
// soft → medium → success (300ms, 200ms 간격)
```

### 에러/경고
```dart
await haptic.error();   // error 패턴
await haptic.warning(); // warning 패턴
```

---

## 사용자 설정

### 햅틱 On/Off 토글
- 위치: 설정 → 앱 설정 → 진동 피드백
- 기본값: 활성화 (true)
- SharedPreferences에 영구 저장

### 코드에서 확인
```dart
// FortuneHapticService 내부에서 자동 체크
bool get isEnabled => _ref.read(userSettingsProvider).hapticEnabled;

// 모든 햅틱 메서드는 isEnabled 자동 확인
Future<void> mysticalReveal() async {
  if (!_canExecute) return; // isEnabled && deviceCanVibrate 체크
  // ...
}
```

---

## 적용 가이드라인

### DO (권장)
- 사용자가 성취감을 느끼는 순간에 강한 햅틱 사용
- 애니메이션 50% 지점에서 공개 햅틱 트리거
- 점수/결과에 따른 차별화된 피드백
- FortuneHapticService 중앙 집중식 사용

### DON'T (금지)
- HapticFeedback/HapticUtils 직접 호출 (사용자 설정 무시됨)
- 모든 버튼에 햅틱 추가
- 스크롤 중 햅틱 트리거
- 연속 햅틱 (debounce 없이)

---

## 기술 구현

### FortuneHapticService 위치
```
lib/core/services/fortune_haptic_service.dart
```

### 사용법
```dart
// ConsumerWidget/ConsumerStatefulWidget에서
final haptic = ref.read(fortuneHapticServiceProvider);
await haptic.mysticalReveal();

// 또는 extension 사용
await ref.haptic.mysticalReveal();
```

### 적용된 위젯
| 위젯 | 햅틱 | 트리거 시점 |
|------|------|------------|
| `DivineLoadingAnimation` | `loadingStep()`, `loadingLastStep()` | 각 스텝 전환 |
| `EmotionalLoadingChecklist` | `loadingStep()`, `loadingComplete()` | 각 스텝 전환, 완료 |
| `FlipCardWidget` | `mysticalReveal()` | 애니메이션 50% |
| `UnifiedBlurWrapper` | `premiumUnlock()` | 블러 해제 시 |

---

## 참고 자료

### 외부 레퍼런스
- [Duolingo UX: The Art of Scarcity in Haptics](https://medium.com/duolingo-design)
- [Toss Design System - Haptic Feedback](https://toss.im/design)
- [Apple Human Interface Guidelines - Haptics](https://developer.apple.com/design/human-interface-guidelines/haptics)

### 내부 문서
- [05-fortune-system.md](05-fortune-system.md) - 운세 시스템 전체 흐름
- [03-ui-design-system.md](03-ui-design-system.md) - UI 디자인 시스템
