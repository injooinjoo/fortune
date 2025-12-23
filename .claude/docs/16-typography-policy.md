# 타이포그래피 정책 가이드

## 핵심 원칙

### 1. 같은 위치 = 같은 크기
동일한 UI 위치에는 반드시 동일한 폰트 스타일을 사용합니다.
- 모든 페이지의 AppBar 타이틀은 `heading3`
- 모든 카드의 제목은 `heading4`
- 모든 본문은 `bodyMedium`

### 2. 디바이스 설정 존중
시스템 폰트 크기 설정에 비례하여 조절됩니다.
- 최소 배율: 0.8x
- 최대 배율: 1.5x (레이아웃 깨짐 방지)

### 3. 하드코딩 금지
`fontSize: 숫자` 직접 사용을 금지합니다.
```dart
// ❌ 금지
Text('제목', style: TextStyle(fontSize: 24))

// ✅ 올바른 사용
Text('제목', style: context.heading2)
```

---

## UI 위치별 폰트 매핑

### 페이지 레벨

| 위치 | 스타일 | 기본 크기 | 용도 |
|------|--------|----------|------|
| AppBar 타이틀 | `heading3` | 22pt | 모든 페이지 상단 |
| 페이지 메인 타이틀 | `heading1` | 30pt | 결과 페이지 최상단 제목 |
| 섹션 제목 | `heading2` | 26pt | "종합 운세", "오늘의 조언" 등 |
| 서브섹션 제목 | `heading3` | 22pt | "재물운", "연애운" 등 |
| 카드 내부 타이틀 | `heading4` | 20pt | 카드 안의 작은 제목 |

### 본문 레벨

| 위치 | 스타일 | 기본 크기 | 용도 |
|------|--------|----------|------|
| 운세 본문 (메인) | `bodyLarge` | 19pt | 운세 설명 텍스트 |
| 일반 본문 | `bodyMedium` | 17pt | 부가 설명, 일반 텍스트 |
| 보조 텍스트 | `bodySmall` | 16pt | 힌트, 안내문, 주석 |

### 라벨/버튼 레벨

| 위치 | 스타일 | 기본 크기 | 용도 |
|------|--------|----------|------|
| 주요 CTA 버튼 | `buttonLarge` | 19pt | "운세 보기", "구매하기" |
| 일반 버튼 | `buttonMedium` | 18pt | "다음", "확인" |
| 보조 버튼 | `buttonSmall` | 17pt | "취소", "건너뛰기" |
| 작은 버튼/칩 | `buttonTiny` | 16pt | 필터 칩, 태그 버튼 |
| 입력 힌트 | `labelMedium` | 14pt | TextField hint |
| 태그/배지 | `labelSmall` | 13pt | 카테고리 태그 |
| NEW/HOT 배지 | `labelTiny` | 12pt | 작은 배지 표시 |

### 숫자/금액 전용

| 위치 | 스타일 | 기본 크기 | 용도 |
|------|--------|----------|------|
| 메인 점수 | `numberXLarge` | 42pt | 운세 점수 (85점) |
| 서브 점수 | `numberLarge` | 34pt | 카테고리별 점수 |
| 토큰/금액 | `numberMedium` | 26pt | 보유 토큰 수량 |
| 날짜/시간 | `numberSmall` | 20pt | 2024.01.15 |

### 전통 스타일 (Calligraphy)

| 위치 | 스타일 | 기본 크기 | 용도 |
|------|--------|----------|------|
| 운세 대제목 | `calligraphyDisplay` | 32pt | 홈 카드 메인 제목 |
| 운세 섹션 제목 | `calligraphyTitle` | 24pt | 결과 페이지 섹션 |
| 운세 부제목 | `calligraphySubtitle` | 20pt | 카드 서브타이틀 |
| 운세 본문 | `calligraphyBody` | 17pt | 운세 내용 |
| 격언/인용구 | `calligraphyQuote` | 15pt | 핵심 조언, 격언 |

---

## 페이지 유형별 가이드

### 운세 결과 페이지

```
┌─────────────────────────────────────┐
│  AppBar: heading3 (22pt)            │
├─────────────────────────────────────┤
│                                     │
│  메인 타이틀: heading1 (30pt)        │
│  부제목: bodyMedium (17pt)           │
│                                     │
│  ┌─ 섹션 카드 ─────────────────────┐ │
│  │ 섹션 제목: heading2 (26pt)      │ │
│  │                                 │ │
│  │ 본문: bodyLarge (19pt)          │ │
│  │ 보조 설명: bodyMedium (17pt)    │ │
│  └─────────────────────────────────┘ │
│                                     │
│  CTA 버튼: buttonLarge (19pt)        │
│                                     │
└─────────────────────────────────────┘
```

### 입력 폼 페이지

```
┌─────────────────────────────────────┐
│  AppBar: heading3 (22pt)            │
├─────────────────────────────────────┤
│                                     │
│  안내 문구: bodyLarge (19pt)         │
│                                     │
│  ┌─ 입력 필드 ─────────────────────┐ │
│  │ 라벨: labelLarge (15pt)         │ │
│  │ [입력값: bodyMedium (17pt)    ] │ │
│  │ 힌트: labelMedium (14pt)        │ │
│  └─────────────────────────────────┘ │
│                                     │
│  버튼: buttonMedium (18pt)          │
│                                     │
└─────────────────────────────────────┘
```

### 홈 스와이프 카드

```
┌─────────────────────────────────────┐
│                                     │
│  점수: numberXLarge (42pt)          │
│  단위: labelMedium (14pt)            │
│                                     │
│  카테고리명: heading4 (20pt)         │
│  설명: bodyMedium (17pt)             │
│                                     │
│  서브 점수: numberLarge (34pt)       │
│                                     │
└─────────────────────────────────────┘
```

---

## 사용 방법

### 권장: BuildContext Extension

```dart
// 가장 간단하고 권장되는 방법
Text('제목', style: context.heading2)
Text('본문', style: context.bodyMedium)
Text('숫자', style: context.numberLarge)
```

### 색상 적용

```dart
// 색상 추가
Text(
  '제목',
  style: context.heading2.copyWith(
    color: ObangseokColors.inju,
  ),
)

// 또는 extension 사용
Text(
  '제목',
  style: context.heading2.withColor(context),
)
```

### 디바이스 스케일 적용

FontSizeSystem이 자동으로 디바이스 설정을 반영합니다:
- 사용자가 시스템에서 "큰 텍스트" 설정 시 최대 1.5배까지 확대
- 사용자가 시스템에서 "작은 텍스트" 설정 시 최소 0.8배까지 축소

---

## 하드코딩 마이그레이션 가이드

### 기존 코드 → 새 코드

| 기존 하드코딩 | 변환 대상 |
|--------------|----------|
| `fontSize: 48` | `displayLarge` |
| `fontSize: 40` | `displayMedium` |
| `fontSize: 32` | `displaySmall` |
| `fontSize: 28-30` | `heading1` |
| `fontSize: 24-26` | `heading2` |
| `fontSize: 20-22` | `heading3` |
| `fontSize: 18-19` | `heading4` 또는 `bodyLarge` |
| `fontSize: 16-17` | `bodyMedium` |
| `fontSize: 14-15` | `bodySmall` 또는 `labelLarge` |
| `fontSize: 12-13` | `labelMedium` 또는 `labelSmall` |
| `fontSize: 10-11` | `labelTiny` |

---

## 검증 체크리스트

새 페이지 작성 또는 기존 페이지 수정 시:

- [ ] `fontSize:` 하드코딩 사용하지 않음
- [ ] AppBar 타이틀: `heading3` 사용
- [ ] 페이지 메인 제목: `heading1` 또는 `heading2` 사용
- [ ] 섹션 제목: `heading2` ~ `heading4` 사용
- [ ] 본문: `bodyLarge`, `bodyMedium`, `bodySmall` 중 선택
- [ ] 버튼: `buttonLarge`, `buttonMedium`, `buttonSmall` 중 선택
- [ ] 숫자/점수: `numberXLarge`, `numberLarge`, `numberMedium`, `numberSmall` 중 선택
- [ ] 라벨/태그: `labelLarge`, `labelMedium`, `labelSmall`, `labelTiny` 중 선택

---

## 관련 파일

- `lib/core/theme/font_size_system.dart` - 폰트 크기 상수 및 스케일링
- `lib/core/theme/typography_unified.dart` - TextStyle 정의 및 Extension
- `.claude/docs/03-ui-design-system.md` - UI 디자인 시스템 전체 가이드