# RN Fortune Edge Rollout Matrix

Date: 2026-04-08
Target: `apps/mobile-rn`

## Status Buckets

- `edge-ready`: RN survey/profile data로 edge function 호출 가능
- `edge-ready (profile birthDate)`: 프로필 생년월일이 있어야 edge 호출 가능
- `photo-required`: 사진 입력 UI가 필요해서 이번 배치에서 edge 연결 보류
- `local-only`: edge function 자체가 없거나 현재 로컬 카드 전용
- `edge-unavailable`: contract 또는 function gap으로 임시 보류

## Character Matrix

| Character | Fortune Types | Current Status |
| --- | --- | --- |
| 하늘 | `daily`, `daily-calendar`, `new-year` | `edge-ready` |
| 하늘 | `fortune-cookie` | `local-only` |
| 무현 도사 | `traditional-saju`, `blood-type`, `naming` | `edge-ready` |
| 무현 도사 | `face-reading` | `photo-required` |
| 스텔라 | `zodiac`, `zodiac-animal`, `constellation`, `birthstone` | `edge-ready (profile birthDate)` |
| Dr. 마인드 | `mbti` | `edge-ready (profile birthDate)` |
| Dr. 마인드 | `personality-dna`, `talent`, `past-life`, `decision` | `edge-ready` |
| Dr. 마인드 | `coaching`, `daily-review`, `weekly-review`, `chat-insight` | `local-only` |
| 로제 | `love`, `compatibility`, `blind-date`, `ex-lover`, `avoid-people`, `celebrity`, `yearly-encounter` | `edge-ready` |
| 제임스 김 | `career`, `wealth`, `exam` | `edge-ready` |
| 럭키 | `lucky-items` | `edge-ready` |
| 럭키 | `lotto` | `edge-unavailable` |
| 럭키 | `ootd-evaluation` | `photo-required` |
| 마르코 | `health`, `match-insight`, `game-enhance`, `exercise` | `edge-ready` |
| 마르코 | `breathing` | `local-only` |
| 리나 | `moving` | `edge-ready` |
| 루나 | `tarot`, `dream`, `biorhythm`, `family`, `pet-compatibility`, `talisman`, `wish` | `edge-ready` |

## This Batch

- Expanded RN survey definitions to cover `moving`, `celebrity`, `pet-compatibility`, `match-insight`, `decision`
- Enriched request-body mapping for `health`, `personality-dna`, `wealth`, `talent`, `moving`, `celebrity`, `pet-compatibility`, `match-insight`, `decision`
- Added runtime truthfulness guards so `face-reading`, `ootd-evaluation`, `lotto` no longer pretend to be edge-backed
- Reduced result-card truncation and widened readable text limits for long edge payloads

## Next Batch

- RN photo attachment flow for `face-reading`, `ootd-evaluation`
- Decide whether `fortune-cookie`, `breathing`, `coaching`, `daily-review`, `weekly-review`, `chat-insight` stay local or get new edge functions
