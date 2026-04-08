# RN Fortune Edge Rollout Matrix

Date: 2026-04-09
Target: `apps/mobile-rn`

## Status Buckets

- `edge-ready`: RN survey/profile data로 edge function 호출 가능
- `edge-ready (profile birthDate)`: 프로필 생년월일이 있어야 edge 호출 가능
- `edge-ready (photo survey)`: RN 설문의 `photo` 답변을 base64로 받아 edge request body에 실어 호출 가능
- `local-only`: edge function 자체가 없거나 현재 로컬 카드 전용
- `edge-unavailable`: contract 또는 function gap으로 임시 보류

## Character Matrix

| Character  | Fortune Types                                                                              | Current Status                   |
| ---------- | ------------------------------------------------------------------------------------------ | -------------------------------- |
| 하늘       | `daily`                                                                                    | `edge-ready`                     |
| 하늘       | `daily-calendar`, `new-year`                                                               | `edge-ready (profile birthDate)` |
| 하늘       | `fortune-cookie`                                                                           | `local-only`                     |
| 무현 도사  | `traditional-saju`, `blood-type`                                                           | `edge-ready`                     |
| 무현 도사  | `naming`                                                                                   | `edge-ready (profile birthDate)` |
| 무현 도사  | `face-reading`                                                                             | `edge-ready (photo survey)`      |
| 스텔라     | `zodiac`, `zodiac-animal`, `constellation`, `birthstone`                                   | `edge-ready (profile birthDate)` |
| Dr. 마인드 | `mbti`                                                                                     | `edge-ready (profile birthDate)` |
| Dr. 마인드 | `personality-dna`, `talent`, `decision`                                                    | `edge-ready`                     |
| Dr. 마인드 | `past-life`                                                                                | `edge-ready (profile birthDate)` |
| Dr. 마인드 | `coaching`, `daily-review`, `weekly-review`, `chat-insight`                                | `local-only`                     |
| 로제       | `love`                                                                                     | `edge-ready (profile birthDate)` |
| 로제       | `compatibility`                                                                            | `edge-ready (profile birthDate)` |
| 로제       | `blind-date`, `ex-lover`, `avoid-people`, `celebrity`, `yearly-encounter`                  | `edge-ready`                     |
| 제임스 김  | `career`, `wealth`, `exam`                                                                 | `edge-ready`                     |
| 럭키       | `lucky-items`                                                                              | `edge-ready (profile birthDate)` |
| 럭키       | `lotto`                                                                                    | `edge-unavailable`               |
| 럭키       | `ootd-evaluation`                                                                          | `edge-ready (photo survey)`      |
| 마르코     | `health`, `match-insight`, `game-enhance`, `exercise`                                      | `edge-ready`                     |
| 마르코     | `breathing`                                                                                | `local-only`                     |
| 리나       | `moving`                                                                                   | `edge-ready`                     |
| 루나       | `biorhythm`                                                                                | `edge-ready (profile birthDate)` |
| 루나       | `tarot`, `dream`, `family`, `pet-compatibility`, `talisman`, `wish`                        | `edge-ready`                     |

## This Batch

- Added a single RN preflight for all edge-backed fortunes:
  1. 로그인 세션 확인
  2. `fortune_results` 기반 개인 동일 요청 재사용 확인
  3. 토큰 가용성 확인 및 차감
  4. edge function 호출
  5. 성공 결과를 `fortune_results`에 다시 저장
  6. 실패 시 토큰 환불 + 가짜 fallback 카드 대신 안내 메시지 노출
- Expanded RN survey definitions to cover `moving`, `celebrity`, `pet-compatibility`, `match-insight`, `decision`
- Enriched request-body mapping for `health`, `personality-dna`, `wealth`, `talent`, `moving`, `celebrity`, `pet-compatibility`, `match-insight`, `decision`
- Added survey-scoped photo input for `face-reading` and `ootd-evaluation`
- Expanded request-body alignment for `daily-calendar`, `new-year`, `love`, `ex-lover`, `health`, `wealth`, `talent`, `exercise`
- Preserved completed survey answers across signup/login so post-auth replay can resume with the same inputs
- Stabilized personal-cache fingerprinting so display name changes do not invalidate identical-fortune reuse
- Added refund reference tracking so token refunds can be tied back to the original consumption record
- Wired `face-reading`: `photo -> image/imageBase64 + analysis_source=upload + userAgeGroup + useV2 -> /fortune-face-reading`
- Wired `ootd-evaluation`: `photo + tpo (+ lookNote) -> imageBase64/image -> /fortune-ootd`
- Kept truthfulness guards so `lotto` no longer pretends to be edge-backed
- Reduced result-card truncation and widened readable text limits for long edge payloads
- Added richer RN card consumption for `zodiac`, `zodiac-animal`, `constellation`, `birthstone`, `biorhythm`, `game-enhance`
- Added shared `score rail` / `추천-주의 pair` rendering path for edge payloads with strong numeric or paired-action structure
- Added long `luckyItems` fallback from pills to bullet list when the payload is phrase-heavy
- Added structured adapter consumption for `compatibility`, `blind-date`, and `family` so their edge-native sections render with less generic flattening

## Next Batch

- Generic composer photo attachment flow outside survey context
- Decide whether `fortune-cookie`, `breathing`, `coaching`, `daily-review`, `weekly-review`, `chat-insight` stay local or get new edge functions
- Expand persisted reuse policy from current default window to fortune-type-specific TTL rules if product wants finer granularity
- Audit `soul-refund` production deployment and verify refund idempotency against live token transaction rows
