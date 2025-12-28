---
name: "sc:feature-ui"
description: "UI 전용 변경. 레이아웃, 색상, 폰트, 위젯 스타일 수정 시 사용. Presentation 레이어만 변경."
depends_on: ["sc:enforce-discovery"]
auto_call_after: ["sc:enforce-verify"]
---

# UI Feature Builder

UI/디자인 관련 변경만 수행하는 워크플로우 스킬입니다.

---

## ⛔ HARD BLOCK 전제 조건

**이 스킬 실행 전 반드시 `/sc:enforce-discovery`가 완료되어야 합니다.**

```
Discovery 보고서 없이 feature-ui 실행 시:
⛔ 차단: "/sc:enforce-discovery를 먼저 실행해주세요"

필수 확인 사항:
- 유사한 UI 위젯이 이미 있는지 확인
- 공통 위젯(core/widgets/) 확인
- TossDesignSystem 토큰 확인
```

---

## 사용법

```
/sc:feature-ui 일일운세 결과 카드 리디자인
/sc:feature-ui 홈 화면 레이아웃 변경
/sc:feature-ui 다크모드 색상 조정
```

---

## 범위

### 허용
- `lib/features/*/presentation/pages/`
- `lib/features/*/presentation/widgets/`
- `lib/core/widgets/`
- `lib/shared/`

### 금지
- Domain 레이어 수정
- Data 레이어 수정
- 비즈니스 로직 변경

---

## 디자인 시스템 규칙

### 색상 (필수)
```dart
// ✅ 올바른 사용
final isDark = Theme.of(context).brightness == Brightness.dark;
Container(
  color: isDark
    ? TossDesignSystem.backgroundDark
    : TossDesignSystem.backgroundLight,
)

// ❌ 금지
Container(color: Color(0xFF1A1A1A))
Container(color: Colors.blue)
```

### 타이포그래피 (필수)
```dart
// ✅ 올바른 사용
Text('제목', style: context.heading1)
Text('본문', style: context.bodyMedium)

// ❌ 금지
Text('제목', style: TextStyle(fontSize: 24))
Text('본문', style: TossDesignSystem.bodyMedium)
```

### 컴포넌트 (필수)
```dart
// ✅ 블러 처리
UnifiedBlurWrapper(
  isBlurred: result.isBlurred,
  child: content,
)

// ❌ 금지
ImageFilter.blur(sigmaX: 10, sigmaY: 10)
```

### 아이콘 (필수)
```dart
// ✅ iOS 스타일 뒤로가기
Icons.arrow_back_ios

// ❌ Android 스타일 금지
Icons.arrow_back
```

---

## 자동 QA

localhost:3000 실행 중이면 Playwright 자동 테스트:

```
UI 변경 완료!

🧪 자동 QA 실행할까요?
- localhost:3000 감지됨
- 변경된 페이지: /fortune/daily
- 예상 테스트: 렌더링, 다크모드, 반응형

(Y/n)
```

---

## 체크리스트

UI 변경 시 자동 검증:

- [ ] 하드코딩 색상 없음
- [ ] 하드코딩 fontSize 없음
- [ ] isDark 다크모드 대응
- [ ] TossDesignSystem 토큰 사용
- [ ] TypographyUnified 사용
- [ ] UnifiedBlurWrapper 사용 (블러 필요시)

---

## 완료 후 자동 검증

**수정 완료 시 `/sc:enforce-verify`가 자동 호출됩니다.**

```
수정 완료!
    │
    └─ /sc:enforce-verify 자동 호출
        ├─ flutter analyze
        ├─ build_runner
        ├─ quality-guardian
        └─ 사용자 테스트 요청
```

---

## 완료 메시지

```
✅ UI가 업데이트되었습니다!

📁 수정된 파일:
1. lib/features/fortune/presentation/pages/daily_fortune_page.dart
2. lib/features/fortune/presentation/widgets/fortune_result_card.dart

🎨 디자인 시스템 검증: ✅ 통과
🌙 다크모드 대응: ✅ 확인됨
📱 반응형: ✅ 확인됨
```