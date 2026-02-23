# Fortune 데이터 흐름 문서 (Canonical ID 기준)

## 목적
- 코어 운세 타입은 앱/Edge/DB/캐시/문서에서 모두 `kebab-case` canonical id를 사용한다.
- legacy alias(`camelCase`, `snake_case`)는 코어 런타임 경로에서 사용하지 않는다.

---

## 전체 아키텍처

```
사용자 요청 (칩 탭)
      │
      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter 클라이언트                            │
├─────────────────────────────────────────────────────────────────┤
│  1. CacheService.getCachedFortune()  ← 캐시 확인                 │
│  2. FortuneApiDecisionService.shouldCallApi()  ← API 결정        │
│     ├─ true  → Edge Function 호출                               │
│     └─ false → getSimilarFortune() (fortune_history DB 검색)     │
│  3. fortuneType은 canonical id만 사용                            │
└─────────────────────────────────────────────────────────────────┘
      │
      ▼ (API 호출 시)
┌─────────────────────────────────────────────────────────────────┐
│                    Edge Function (서버)                          │
├─────────────────────────────────────────────────────────────────┤
│  1. Cohort 추출 (나잇대, 띠, 오행 등)                             │
│  2. get_random_cohort_result RPC 호출                            │
│     ├─ Pool 있음 → 개인화 후 반환                                │
│     └─ Pool 없음 → LLM 호출 → Pool에 저장 → 반환                  │
│  3. 응답 wrapper의 fortuneType도 canonical id만 반환              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. 타입/엔드포인트 단일 규칙

### 코어 canonical 매핑 (요약)
| Canonical ID | Endpoint |
|---|---|
| `daily` | `/fortune-daily` |
| `daily-calendar` | `/fortune-time` |
| `new-year` | `/fortune-new-year` |
| `traditional-saju` | `/fortune-traditional-saju` |
| `face-reading` | `/fortune-face-reading` |
| `mbti` | `/fortune-mbti` |
| `personality-dna` | `/fortune-mbti` |
| `love` | `/fortune-love` |
| `compatibility` | `/fortune-compatibility` |
| `blind-date` | `/fortune-blind-date` |
| `ex-lover` | `/fortune-ex-lover` |
| `avoid-people` | `/fortune-avoid-people` |
| `yearly-encounter` | `/fortune-yearly-encounter` |
| `career` | `/fortune-career` |
| `wealth` | `/fortune-wealth` |
| `lucky-items` | `/fortune-lucky-items` |
| `match-insight` | `/fortune-match-insight` |
| `game-enhance` | `/fortune-game-enhance` |
| `exercise` | `/fortune-exercise` |
| `dream` | `/fortune-dream` |
| `tarot` | `/fortune-tarot` |
| `past-life` | `/fortune-past-life` |
| `health` | `/fortune-health` |
| `pet-compatibility` | `/fortune-pet-compatibility` |
| `family` | concern 기반 `family-*` 동적 라우팅 |
| `naming` | `/fortune-naming` |
| `baby-nickname` | `/fortune-baby-nickname` |
| `ootd-evaluation` | `/fortune-ootd` |
| `exam` | `/fortune-exam` |
| `moving` | `/fortune-moving` |
| `celebrity` | `/fortune-celebrity` |
| `biorhythm` | `/fortune-biorhythm` |

### 로컬 전용 canonical 타입
- `fortune-cookie`
- `wish`
- `gratitude`
- `breathing`
- `daily-review`
- `weekly-review`
- `chat-insight`
- `coaching`
- `decision`
- `view-all`
- `profile-creation`

---

## 2. API 호출 결정 로직

### 항상 API 호출 타입 (canonical)
```dart
const alwaysCallApiTypes = [
  'wish',
  'dream',
  'face-reading',
  'ex-lover',
  'blind-date',
];
```

### 참고
- `daily-calendar`, `new-year`, `yearly-encounter`, `game-enhance`, `baby-nickname`는 canonical id로만 처리한다.
- `money`는 `wealth`, `sportsGame`은 `match-insight`로 고정한다.

---

## 3. Cohort Pool 시스템

### Cohort Pool 사용 Edge Functions (예시)
- `fortune-daily`, `fortune-love`, `fortune-compatibility`, `fortune-tarot`
- `fortune-career`, `fortune-health`, `fortune-dream`, `fortune-wealth`
- `fortune-ex-lover`, `fortune-blind-date`, `fortune-avoid-people`
- `fortune-exam`, `fortune-moving`, `fortune-pet-compatibility`
- `fortune-new-year`, `fortune-lucky-items`, `fortune-face-reading`
- `fortune-traditional-saju`
- `fortune-family-relationship`, `fortune-family-change`, `fortune-family-children`
- `fortune-family-health`, `fortune-family-wealth`

### 핵심 원칙
- cohort key/DB 저장의 `fortune_type`도 canonical id를 사용한다.
- 코어 경로에서 alias 분기(`new_year`, `ex_lover`, `yearlyEncounter`)를 두지 않는다.

---

## 4. 칩/설문/응답 정합성

### 단일 레지스트리 원칙
- `FortuneTypeRegistry`에서 `id`, `labelKey`, `endpoint`, `isLocalOnly`, `resolveApiType`를 단일 관리한다.
- `FortuneSurveyType` enum은 유지하되 문자열 노출은 `canonicalId` 확장을 사용한다.

### 정합 체크 포인트
1. 추천 칩 `id/fortuneType`는 canonical id만 사용
2. 설문 완료 후 API 호출 타입도 canonical id 기반
3. Edge 응답 `fortuneType`과 DB 저장값이 동일
4. 캐시 key, history 필터, 문서 표기도 동일

---

## 5. 마이그레이션 정책

### DB 마이그레이션
- `supabase/migrations/20260223000001_normalize_core_fortune_type_ids.sql`
- 대상 컬럼의 legacy 값을 canonical로 일괄 정규화
- `user_statistics.fortune_type_count` JSONB key rename + merge 수행

### 로컬 1회 마이그레이션
- `FortuneTypeLocalMigrationService`로 SharedPreferences 내 fortuneType 문자열 정규화
- 플래그: `fortune_type_migration_v1_done=true`

---

## 6. 이미지/특수 처리 타입

### 이미지 생성
| 타입 | Edge Function | 비고 |
|---|---|---|
| `yearly-encounter` | `fortune-yearly-encounter` | 생성형 결과 |
| `past-life` | `fortune-past-life` | 이미지 Pool 재사용 정책 적용 |

### 이미지 분석
| 타입 | Edge Function |
|---|---|
| `face-reading` | `fortune-face-reading` |
| `ootd-evaluation` | `fortune-ootd` |

### 클라이언트 특수 처리
| 타입 | 처리 방식 |
|---|---|
| `fortune-cookie` | 애니메이션 후 로컬 메시지 |
| `breathing` | 명상 화면 이동 |
| `view-all` | 전체 칩 목록 표시 |

---

## 7. 관련 문서
- `docs/development/FORTUNE_TYPE_CANONICAL_MAPPING.md`
- `.claude/docs/09-edge-function-conventions.md`
