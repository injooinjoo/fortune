# 09. Edge Function 네이밍/타입 규칙 (Canonical Cutover)

## 개요
- Supabase Edge Function 이름은 기존 규칙(`fortune-{type}` / `{verb}-{target}`)을 유지한다.
- 코어 운세 타입 문자열은 `kebab-case` canonical id만 허용한다.
- 코어 범위에서 `camelCase`, `snake_case` alias 분기는 제거한다.

---

## 1. 함수 네이밍 규칙

### 인사이트 함수: `fortune-{type}`
```bash
fortune-daily
fortune-time
fortune-new-year
fortune-ex-lover
fortune-yearly-encounter
```

### 유틸리티 함수: `{verb}-{target}`
```bash
fetch-tickers
calculate-saju
generate-talisman
analyze-wish
```

### 금지 접미사
- `-enhanced`
- `-unified`
- `-new`
- `-v2`, `-v3`
- `-test`
- `-advanced`

---

## 2. 코어 타입 canonical 규칙

### 변환 대상 (대표)
- `ex_lover` -> `ex-lover`
- `new_year` -> `new-year`
- `yearlyEncounter` -> `yearly-encounter`
- `gameEnhance` -> `game-enhance`
- `babyNickname` -> `baby-nickname`
- `daily_calendar` -> `daily-calendar`

### 고정 원칙
- Edge 응답 `fortuneType`는 canonical id만 반환
- DB 저장 `fortune_type`도 canonical id만 저장
- 추천 API(`fortune-recommend`)의 반환 타입도 canonical id만 포함

---

## 3. 레지스트리/엔드포인트 연동

앱 기준 source of truth:
- `lib/core/fortune/fortune_type_registry.dart`
- `lib/core/constants/edge_functions_endpoints.dart`

핵심 예시:
- `daily` -> `/fortune-daily`
- `daily-calendar` -> `/fortune-time`
- `new-year` -> `/fortune-new-year`
- `yearly-encounter` -> `/fortune-yearly-encounter`
- `game-enhance` -> `/fortune-game-enhance`
- `baby-nickname` -> `/fortune-baby-nickname`
- `match-insight` -> `/fortune-match-insight`
- `wealth` -> `/fortune-wealth`

`family`는 UX 엔트리 타입이며 API 호출 시 concern 기반으로 아래 subtype으로 확정한다:
- `family-health`
- `family-wealth`
- `family-children`
- `family-relationship`
- `family-change`

---

## 4. Edge 구현 체크리스트

### 기존 함수 수정 시
- 기존 함수를 직접 수정한다 (신규 `-v2` 함수 생성 금지)
- `_shared` 타입/cohort 모듈과 canonical 타입을 동기화한다
- 응답 wrapper는 `{ success: true, data: ... }`를 유지한다
- `data.fortuneType` 필드는 canonical id를 반환한다

### 추천 함수(`fortune-recommend`)
- 추천 결과 배열의 `fortuneType`은 canonical id만 반환
- 레거시 타입이 입력되면 필터링하거나 canonical 변환 후 반환

---

## 5. 마이그레이션 연계

### DB
- `supabase/migrations/20260223000001_normalize_core_fortune_type_ids.sql`
- 코어 테이블의 `fortune_type` 컬럼을 canonical id로 일괄 정규화

### 로컬
- `FortuneTypeLocalMigrationService`가 SharedPreferences 내 legacy fortuneType을 1회 변환
- 완료 플래그: `fortune_type_migration_v1_done=true`

---

## 6. 운영 원칙
- 새 함수 생성보다 기존 함수 수정 우선
- 대규모 변경은 feature branch 기준으로 관리
- 배포 후 앱/Edge/DB/l10n 문서 표기가 모두 canonical로 정합인지 검증
