# Fortune Type Canonical Mapping

## Rule
- 모든 코어 운세 타입은 `kebab-case` canonical id를 사용한다.
- 앱/Edge/DB/캐시/문서/l10n에서 동일한 id를 사용한다.
- 레거시 alias(`snake_case`, `camelCase`)는 허용하지 않는다.

## Core Mapping
| Canonical ID | Endpoint | Notes |
|---|---|---|
| `daily` | `/fortune-daily` | |
| `daily-calendar` | `/fortune-time` | |
| `new-year` | `/fortune-new-year` | |
| `traditional-saju` | `/fortune-traditional-saju` | |
| `face-reading` | `/fortune-face-reading` | |
| `mbti` | `/fortune-mbti` | |
| `personality-dna` | `/fortune-mbti` | 정책상 MBTI 엔드포인트 사용 |
| `love` | `/fortune-love` | |
| `compatibility` | `/fortune-compatibility` | |
| `blind-date` | `/fortune-blind-date` | |
| `ex-lover` | `/fortune-ex-lover` | |
| `avoid-people` | `/fortune-avoid-people` | |
| `yearly-encounter` | `/fortune-yearly-encounter` | |
| `career` | `/fortune-career` | |
| `wealth` | `/fortune-wealth` | `money` 대체 |
| `lucky-items` | `/fortune-lucky-items` | |
| `match-insight` | `/fortune-match-insight` | `sportsGame` 대체 |
| `game-enhance` | `/fortune-game-enhance` | |
| `exercise` | `/fortune-exercise` | |
| `dream` | `/fortune-dream` | |
| `tarot` | `/fortune-tarot` | |
| `past-life` | `/fortune-past-life` | |
| `health` | `/fortune-health` | |
| `pet-compatibility` | `/fortune-pet-compatibility` | `pet` 대체 |
| `family` | concern 기반 동적 라우팅 | `family-health`, `family-wealth`, `family-children`, `family-relationship`, `family-change` |
| `naming` | `/fortune-naming` | |
| `baby-nickname` | `/fortune-baby-nickname` | |
| `ootd-evaluation` | `/fortune-ootd` | |
| `exam` | `/fortune-exam` | |
| `moving` | `/fortune-moving` | |
| `celebrity` | `/fortune-celebrity` | |
| `biorhythm` | `/fortune-biorhythm` | |

## Local-only
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

## Hard Cutover
- DB: `20260223000001_normalize_core_fortune_type_ids.sql`로 일괄 정규화.
- Local: `FortuneTypeLocalMigrationService` 1회 실행 (`fortune_type_migration_v1_done=true`).
