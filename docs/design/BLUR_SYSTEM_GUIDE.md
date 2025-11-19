# 블러 시스템 사용 가이드

## 📋 개요

Fortune 앱의 모든 운세 페이지에서 프리미엄/일반 사용자를 구분하기 위한 **통일된 블러 처리 시스템**입니다.

**중앙 관리 위젯**: `lib/core/widgets/unified_blur_wrapper.dart`

---

## 🎯 핵심 원칙

### ✅ DO (해야 할 것)
- 모든 블러 처리는 `UnifiedBlurWrapper` 사용
- 광고 버튼은 `UnifiedAdUnlockButton` 사용
- 섹션 키는 영문 소문자 + 언더스코어 (`advice`, `future_outlook`)

### ❌ DON'T (하지 말아야 할 것)
- `ImageFilter.blur` 직접 사용 금지
- `_buildBlurWrapper` 로컬 메서드 생성 금지
- 커스텀 블러 디자인 구현 금지

---

## 🚀 사용법

### 1. 기본 블러 처리

```dart
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';

// FortuneResult에서 블러 정보 가져오기
final fortuneResult = ...; // UnifiedFortuneService에서 받은 결과

// 블러 적용
UnifiedBlurWrapper(
  isBlurred: fortuneResult.isBlurred,
  blurredSections: fortuneResult.blurredSections,
  sectionKey: 'advice', // 이 섹션의 고유 키
  child: TossCard(
    child: Text('조언 내용...'),
  ),
)
```

### 2. 광고 버튼 표시

```dart
// 블러 상태일 때만 광고 버튼 표시
if (fortuneResult.isBlurred)
  UnifiedAdUnlockButton(
    onPressed: _showAdAndUnblur,
  )
```

### 3. 광고 보기 로직 (표준 구현)

```dart
bool _isShowingAd = false;

Future<void> _showAdAndUnblur() async {
  // 중복 호출 방지
  if (_isShowingAd) return;

  try {
    _isShowingAd = true;
    final adService = AdService();

    await adService.showRewardedAd(
      onRewarded: () {
        // 광고 시청 완료 - 블러 해제
        setState(() {
          _fortuneResult = _fortuneResult.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
          _isShowingAd = false;
        });
      },
      onAdDismissed: () {
        // 광고 닫힘
        _isShowingAd = false;
      },
    );
  } catch (e) {
    Logger.error('[Fortune] Failed to show ad: $e');
    _isShowingAd = false;
  }
}
```

---

## 📐 디자인 표준

### 블러 효과
- **Blur**: `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`
- **그라디언트 오버레이**: 0.3 → 0.8 alpha
- **자물쇠 아이콘**: 40px, 중앙 배치
- **Shimmer 애니메이션**: 2초 주기, 토스 블루 색상

### 광고 버튼
- **위치**: 화면 하단 고정 (TossFloatingProgressButtonPositioned)
- **텍스트**: "🎁 광고 보고 전체 내용 보기"
- **커스터마이징**: `customText` 파라미터로 변경 가능

---

## 🗂️ 섹션 키 네이밍 규칙

### 규칙
- 영문 소문자 사용
- 단어 구분은 언더스코어 (`_`)
- 명확하고 설명적인 이름

### 예시
```dart
// ✅ 올바른 예시
'advice'
'future_outlook'
'luck_items'
'health_tips'
'compatibility_insights'

// ❌ 잘못된 예시
'Advice'           // 대문자 사용
'futureOutlook'    // camelCase
'luck-items'       // 하이픈 사용
'tip1'             // 의미 불명확
```

---

## 📝 운세별 블러 섹션 예시

### 시간별 운세 (Daily Calendar)
```dart
blurredSections: ['advice', 'ai_tips', 'caution']
```

### MBTI 운세
```dart
blurredSections: ['detailed_analysis', 'relationship_tips', 'career_advice']
```

### 연애운
```dart
blurredSections: ['compatibility_insights', 'predictions', 'action_plan', 'warning_area']
```

### 관상
```dart
blurredSections: ['ogwan', 'samjeong', 'sibigung', 'advice', 'full_analysis']
```

### 바이오리듬
```dart
blurredSections: ['personal_analysis', 'lifestyle_advice', 'health_tips']
```

### 건강운
```dart
blurredSections: ['body_part_advice', 'cautions', 'recommended_activities', 'diet_advice', 'exercise_advice', 'health_keywords']
```

---

## 🔧 고급 사용법

### 커스텀 블러 강도

```dart
UnifiedBlurWrapper(
  isBlurred: true,
  blurredSections: ['content'],
  sectionKey: 'content',
  sigmaX: 15.0,  // 기본값: 10.0
  sigmaY: 15.0,  // 기본값: 10.0
  child: MyWidget(),
)
```

### 커스텀 광고 버튼 텍스트

```dart
UnifiedAdUnlockButton(
  onPressed: _showAdAndUnblur,
  customText: '💎 특별한 내용 보기', // 기본값: "🎁 광고 보고 전체 내용 보기"
)
```

---

## 🐛 문제 해결

### Q1. 블러가 적용되지 않아요
**A**: 다음을 확인하세요:
1. `fortuneResult.isBlurred`가 `true`인지
2. `sectionKey`가 `blurredSections`에 포함되어 있는지
3. `UnifiedBlurWrapper` import가 올바른지

```dart
// 디버깅
print('isBlurred: ${fortuneResult.isBlurred}');
print('blurredSections: ${fortuneResult.blurredSections}');
print('current sectionKey: $sectionKey');
```

### Q2. 광고 보고나서 블러가 안 풀려요
**A**: `onRewarded` 콜백에서 `setState`로 상태 업데이트했는지 확인:

```dart
onRewarded: () {
  setState(() {
    _fortuneResult = _fortuneResult.copyWith(
      isBlurred: false,
      blurredSections: [],
    );
  });
},
```

### Q3. 광고 버튼이 두 번 클릭돼요
**A**: `_isShowingAd` 플래그로 중복 호출 방지:

```dart
bool _isShowingAd = false;

Future<void> _showAdAndUnblur() async {
  if (_isShowingAd) return; // 중복 호출 방지
  _isShowingAd = true;

  try {
    // 광고 로직...
  } finally {
    _isShowingAd = false; // 반드시 리셋
  }
}
```

---

## 📚 관련 문서

- **API 가이드**: [FORTUNE_PREMIUM_AD_SYSTEM.md](../data/FORTUNE_PREMIUM_AD_SYSTEM.md)
- **최적화**: [FORTUNE_OPTIMIZATION_GUIDE.md](../data/FORTUNE_OPTIMIZATION_GUIDE.md)
- **디자인 시스템**: [TOSS_DESIGN_SYSTEM.md](TOSS_DESIGN_SYSTEM.md)

---

## 📞 문의

블러 시스템 관련 문제나 제안사항은 CLAUDE.md에 추가하거나 팀에 문의하세요.
