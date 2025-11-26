# 09. Edge Function 네이밍 규칙

## 개요

Supabase Edge Functions의 네이밍 규칙과 개발 가이드라인입니다.
일관된 네이밍을 통해 유지보수성을 높이고 혼란을 방지합니다.

---

## 네이밍 규칙

### 1. 운세 함수: `fortune-{type}`

```bash
# 올바른 예시
fortune-daily
fortune-love
fortune-investment
fortune-mbti

# 잘못된 예시 (금지)
fortune-daily-enhanced    # ❌ 접미사 금지
fortune-love-v2          # ❌ 버전 접미사 금지
fortune-investment-new   # ❌ -new 접미사 금지
fortune-mbti-unified     # ❌ -unified 접미사 금지
```

### 2. 유틸리티 함수: `{동사}-{대상}`

```bash
# 올바른 예시
fetch-tickers
calculate-saju
generate-talisman
analyze-wish

# 잘못된 예시
tickers-fetch    # ❌ 순서가 반대
get-tickers      # ❌ get 대신 fetch 사용
ticker-api       # ❌ 불명확한 동사
```

### 3. 금지된 접미사

| 접미사 | 이유 |
|--------|------|
| `-enhanced` | 기존 함수 수정으로 대체 |
| `-unified` | 통합은 기존 함수에서 처리 |
| `-new` | Git으로 버전 관리 |
| `-v2`, `-v3` | 시맨틱 버저닝은 Git 태그로 |
| `-test` | 테스트 함수는 로컬에서만 |
| `-advanced` | 기능 확장은 기존 함수 수정 |

---

## 개발 원칙

### 1. 새 함수 생성보다 기존 함수 수정 우선

```bash
# ❌ 잘못된 접근
# "투자 운세에 새 기능을 추가해야 하니 fortune-investment-enhanced를 만들자"
supabase functions new fortune-investment-enhanced

# ✅ 올바른 접근
# "기존 fortune-investment를 수정하자"
# 1. feature branch 생성
git checkout -b feature/fortune-investment-ticker-selection

# 2. 기존 함수 수정
# supabase/functions/fortune-investment/index.ts 수정

# 3. 커밋
git commit -m "feat(fortune-investment): Add ticker selection feature"
```

### 2. 대규모 변경 시 Feature Branch 사용

```bash
# 큰 변경이 필요한 경우
git checkout -b feature/fortune-investment-redesign

# 변경 작업 수행
# ...

# PR 생성 및 리뷰 후 머지
git push -u origin feature/fortune-investment-redesign
```

### 3. Breaking Change 시 버전 태그 사용

```bash
# API 호환성이 깨지는 변경 시
git tag v2.0.0-fortune-investment
git push origin v2.0.0-fortune-investment
```

---

## 디렉토리 구조

```
supabase/functions/
├── _shared/                    # 공유 모듈
│   ├── llm/                   # LLM 관련
│   │   ├── llm-factory.ts
│   │   └── prompt-manager.ts
│   ├── utils/                 # 유틸리티
│   └── types/                 # 타입 정의
├── fortune-daily/             # 일일 운세
│   └── index.ts
├── fortune-investment/        # 투자 운세
│   └── index.ts
├── fetch-tickers/             # 티커 조회 API
│   └── index.ts
└── ...
```

---

## Flutter 연동

### EdgeFunctionsEndpoints 사용

```dart
// lib/core/constants/edge_functions_endpoints.dart

// 직접 상수 사용 (권장)
EdgeFunctionsEndpoints.dailyFortune  // '/fortune-daily'
EdgeFunctionsEndpoints.investmentFortune  // '/fortune-investment'

// 동적 조회 (유연한 방식)
EdgeFunctionsEndpoints.getEndpointForType('daily')  // '/fortune-daily'
EdgeFunctionsEndpoints.getEndpointForType('investment')  // '/fortune-investment'
```

### 존재하지 않는 함수 호출 시

`getEndpointForType()`은 매핑되지 않은 타입에 대해 자동으로 `/fortune-{type}` 형식을 반환합니다:

```dart
EdgeFunctionsEndpoints.getEndpointForType('unknown')  // '/fortune-unknown'
```

이 경우 Edge Function이 없으면 404 에러가 발생하며, 앱은 fallback 로직을 실행합니다.

---

## 체크리스트

### 새 Edge Function 추가 시

- [ ] 네이밍 규칙 준수 (`fortune-{type}` 또는 `{동사}-{대상}`)
- [ ] 접미사 없이 명확한 이름 사용
- [ ] `EdgeFunctionsEndpoints`에 상수 추가
- [ ] `getEndpointForType()` 매핑 추가
- [ ] `_shared/` 모듈 활용 (LLMFactory 등)
- [ ] 배포 및 테스트

### 기존 Edge Function 수정 시

- [ ] Feature branch 생성 (큰 변경 시)
- [ ] 기존 함수 직접 수정
- [ ] 하위 호환성 유지
- [ ] Breaking change 시 버전 태그
- [ ] 테스트 및 배포

---

## 현재 Edge Functions 목록 (2024.11.26)

### 운세 함수 (22개)

| 함수명 | 설명 |
|--------|------|
| `fortune-avoid-people` | 기피인물 운세 |
| `fortune-biorhythm` | 바이오리듬 |
| `fortune-blind-date` | 소개팅 운세 |
| `fortune-career` | 직업 운세 |
| `fortune-compatibility` | 궁합 |
| `fortune-daily` | 일일 운세 |
| `fortune-dream` | 꿈 해몽 |
| `fortune-ex-lover` | 전연인 운세 |
| `fortune-face-reading` | 관상 |
| `fortune-family-harmony` | 가족 화합 |
| `fortune-health` | 건강 운세 |
| `fortune-investment` | 투자 운세 |
| `fortune-love` | 연애 운세 |
| `fortune-lucky-items` | 행운 아이템 |
| `fortune-lucky-series` | 행운 시리즈 |
| `fortune-mbti` | MBTI 운세 |
| `fortune-moving` | 이사 운세 |
| `fortune-pet-compatibility` | 반려동물 궁합 |
| `fortune-talent` | 재능 운세 |
| `fortune-time` | 시간별 운세 |
| `fortune-traditional-saju` | 전통 사주 |

### 유틸리티 함수 (10개)

| 함수명 | 설명 |
|--------|------|
| `analyze-wish` | 소원 분석 |
| `calculate-saju` | 사주 계산 |
| `fetch-tickers` | 투자 종목 조회 |
| `generate-fortune-story` | 운세 스토리 생성 |
| `generate-talisman` | 부적 생성 |
| `kakao-oauth` | 카카오 OAuth |
| `mbti-energy-tracker` | MBTI 에너지 추적 |
| `naver-oauth` | 네이버 OAuth |
| `personality-dna` | 성격 DNA |

---

# Fortune 페이지 네이밍 규칙

## 파일명 규칙

### 1. 기본 형식: `*_page.dart`

```dart
// 올바른 예시
mbti_fortune_page.dart
love_fortune_input_page.dart
career_coaching_result_page.dart

// 잘못된 예시 (금지)
mbti_fortune_page_unified.dart    // ❌ 접미사 금지
love_fortune_page_v2.dart         // ❌ 버전 접미사 금지
career_page_enhanced.dart         // ❌ -enhanced 접미사 금지
```

### 2. 금지된 접미사

| 접미사 | 이유 |
|--------|------|
| `_unified` | 기존 파일 수정으로 대체 |
| `_enhanced` | Git으로 버전 관리 |
| `_v2`, `_v3` | Git 태그로 관리 |
| `_renewed` | 기존 파일 수정으로 대체 |
| `_toss` | 스타일은 파일명이 아닌 코드로 |

### 3. 다중 단계 페이지 패턴

```dart
// 입력 → 결과 패턴
talent_fortune_input_page.dart    // 입력 페이지
talent_fortune_results_page.dart  // 결과 페이지

// 단일 페이지 패턴 (권장)
mbti_fortune_page.dart            // 모든 단계 포함
biorhythm_fortune_page.dart       // 모든 단계 포함
```

---

## UI 제목 규칙

### FortuneTypeNames 사용

```dart
// ✅ 권장: FortuneTypeNames에서 가져오기
import 'package:fortune/core/constants/fortune_type_names.dart';

appBar: StandardFortuneAppBar(
  title: FortuneTypeNames.getName('mbti'),  // 'MBTI 운세'
),

// ❌ 비권장: 하드코딩
appBar: StandardFortuneAppBar(
  title: 'MBTI 운세',  // 일관성 깨질 수 있음
),
```

### 제목 소스 우선순위

1. `FortuneTypeNames.getName()` - 최우선
2. `FortuneType.displayName` - 대안
3. 하드코딩 - 최후의 수단 (특수한 경우만)

---

## 라우트 규칙

### 라우트 정의 위치

| 라우트 유형 | 파일 |
|------------|------|
| 메인 탭 라우트 | `route_config.dart` |
| 운세 카테고리 라우트 | `fortune_routes/` 하위 파일 |
| 인터랙티브 라우트 | `interactive_routes.dart` |

### 라우트 네이밍

```dart
// 올바른 예시
path: '/mbti',
name: 'fortune-mbti',

// 잘못된 예시
path: '/mbti-fortune-v2',    // ❌ 버전 접미사
path: '/fortune-mbti-new',   // ❌ new 접미사
```

---

## 현재 상태 (2024.11.26)

### 통계

| 항목 | 수치 |
|------|------|
| 활성 페이지 파일 | 36개 |
| 라우트 정의 파일 | 10개 |
| FortuneTypeNames 항목 | 80+ 개 |

### 향후 개선 사항

1. **접미사 파일 리팩토링**: `_unified`, `_enhanced` 접미사 파일들을 기본 파일로 병합
2. **AppBar 제목 통일**: 모든 페이지에서 `FortuneTypeNames.getName()` 사용
3. **라우트 파일 통합**: 도메인별로 라우트 파일 재구성

---

## 관련 문서

- [02-architecture.md](02-architecture.md) - Clean Architecture 구조
- [06-llm-module.md](06-llm-module.md) - LLM 모듈 및 Edge Function 작성법
