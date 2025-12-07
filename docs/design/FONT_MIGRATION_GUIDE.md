# 폰트 크기 마이그레이션 가이드

## 📊 현재 상황
- **총 1236개의 하드코딩된 fontSize**
- **167개 파일**에 분산
- **가장 많이 사용되는 크기**: 14 (211회), 16 (208회), 12 (102회), 18 (95회)

## 🎯 마이그레이션 전략

### 1. 크기별 역할 분류 및 매핑

| 기존 크기 | 역할 추정 | TypographyUnified 매핑 | 사용 빈도 |
|----------|----------|----------------------|----------|
| 48pt | 스플래시 대형 제목 | `displayLarge` | 8회 |
| 40pt | 온보딩 헤드라인 | `displayMedium` | 2회 |
| 32pt | 페이지 메인 제목 | `displaySmall` | 15회 |
| 28pt | 큰 섹션 제목 | `heading1` | 31회 |
| 26pt | 중간 섹션 제목 | `heading1` (가장 가까움) | 8회 |
| 24pt | 섹션 제목 | `heading2` | 55회 |
| 22pt | 작은 섹션 제목 | `heading2` (가장 가까움) | 10회 |
| 20pt | 카드 제목 | `heading3` | 43회 |
| 18pt | 작은 제목, 탭 | `heading4` | 95회 |
| 17pt | 큰 본문, 버튼 | `bodyLarge` or `buttonLarge` | 6회 |
| 16pt | 버튼, 중요 텍스트 | `buttonMedium` | 208회 |
| 15pt | 일반 본문 | `bodyMedium` | 30회 |
| 14pt | 기본 본문, 설명 | `bodySmall` | 211회 |
| 13pt | 라벨, 보조 텍스트 | `labelLarge` | 21회 |
| 12pt | 작은 라벨, 캡션 | `labelMedium` | 102회 |
| 11pt | 매우 작은 라벨 | `labelSmall` | 26회 |
| 10pt | 배지, NEW 표시 | `labelTiny` | 24회 |

### 2. 컨텍스트별 매핑 규칙

#### AppBar 제목
- 18pt → `heading4`
- 16pt → `buttonMedium`

#### 페이지 제목 (최상단)
- 32pt → `displaySmall`
- 28pt → `heading1`
- 24pt → `heading2`

#### 섹션 제목 (카드 내부)
- 20pt → `heading3`
- 18pt → `heading4`
- 16pt → `buttonMedium`

#### 버튼 텍스트
- 18pt → `buttonLarge`
- 17pt → `buttonLarge`
- 16pt → `buttonMedium`
- 15pt → `buttonSmall`
- 14pt → `buttonTiny`

#### 본문 텍스트
- 17pt → `bodyLarge` (강조된 본문)
- 16pt → `buttonMedium` (중요 본문)
- 15pt → `bodyMedium` (일반 본문)
- 14pt → `bodySmall` (기본 본문)

#### 보조 텍스트 / 라벨
- 13pt → `labelLarge`
- 12pt → `labelMedium`
- 11pt → `labelSmall`
- 10pt → `labelTiny`

#### 숫자 / 금액 표시
- 40pt+ → `numberXLarge`
- 32pt → `numberLarge`
- 24pt → `numberMedium`
- 18pt → `numberSmall`

### 3. 다크모드 색상 처리

기존:
```dart
Text('제목', style: TextStyle(
  fontSize: 18,
  color: isDark ? Colors.white : Colors.black,
))
```

신규:
```dart
Text('제목', style: TypographyUnified.heading4.copyWith(
  color: isDark
    ? TossDesignSystem.textPrimaryDark
    : TossDesignSystem.textPrimaryLight,
))

// 또는 extension 사용
Text('제목', style: context.heading4.copyWith(
  color: isDark
    ? TossDesignSystem.textPrimaryDark
    : TossDesignSystem.textPrimaryLight,
))
```

### 4. fontWeight 보존

기존 fontWeight는 최대한 보존:
```dart
// 기존
TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

// 신규
TypographyUnified.buttonMedium.copyWith(fontWeight: FontWeight.bold)
```

단, 기본 fontWeight가 적절한 경우 생략 가능:
- heading1~4: 기본 w600~w700
- button: 기본 w600
- body: 기본 w400

### 5. 우선순위

1. **Phase 1 (우선)**: Core components (20개 파일)
   - AppBar, Button, Dialog 등 공통 컴포넌트

2. **Phase 2**: Fortune pages (50개 파일)
   - 가장 많이 사용되는 운세 페이지들

3. **Phase 3**: Widgets (50개 파일)
   - 재사용 위젯들

4. **Phase 4**: 나머지 (47개 파일)
   - Settings, Profile, Admin 등

## 🔧 마이그레이션 스크립트

자동화가 어려운 이유:
- 컨텍스트에 따라 다른 스타일 적용 필요
- 색상, fontWeight 등 다른 속성들도 함께 고려
- 다크모드 처리 방식이 파일마다 다름

따라서 **수동 마이그레이션**이 필요하지만, 일관된 패턴 사용으로 빠르게 진행 가능.

## ✅ 마이그레이션 체크리스트

각 파일 작업 시:
- [ ] fontSize 값 확인
- [ ] 컨텍스트 파악 (제목/본문/라벨)
- [ ] 적절한 TypographyUnified 스타일 선택
- [ ] 색상 처리 (다크모드 대응)
- [ ] fontWeight 보존 여부 결정
- [ ] 빌드 테스트

## 📝 예시

### Before
```dart
Text(
  '타로 카드 선택',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: isDark ? Colors.white : Colors.black,
  ),
)
```

### After
```dart
Text(
  '타로 카드 선택',
  style: TypographyUnified.heading2.copyWith(
    color: isDark
      ? TossDesignSystem.textPrimaryDark
      : TossDesignSystem.textPrimaryLight,
  ),
)
```

또는 더 간단하게:
```dart
Text(
  '타로 카드 선택',
  style: context.typo.heading2.withColor(context),
)
```
