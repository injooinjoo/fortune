# 하늘이 운세 54종 E2E QA 진행 리포트 (Hermes)

## 현재 결론
- 정적 매핑: 54종 실행 타입/결과 렌더러 매핑은 기존 검증에서 누락 없음.
- Live Edge smoke: 하네스 구축 완료. 현재 live 기준 54종 최신 결과 통합:
  - PASS: 12종 — 동기 5종, 비동기 포스터 7종.
  - SKIP_LOCAL: 4종 — 앱 로컬 렌더 경로 별도 실기기 확인 필요.
  - BLOCKED_GEMINI_QUOTA: 27종 — Gemini 429 quota 초과로 품질 평가 불가.
  - BLOCKED_AUTH: 4종 — 실제 사용자 JWT 필요.
  - BROKEN_ENDPOINT: 1종 — 배포된 Edge Function 없음.
  - BLOCKED_VALID_USER_ID: 1종 — fortunes.user_id FK 때문에 실제 auth user 필요.
  - FAIL_OTHER: 5종.

## 이번 턴에서 추가 확인한 내용
- async poster 7종은 1x1 PNG fixture 때문에 400/500/timeout처럼 보였음. 실제 크기의 `pencil-profile-export.png`를 base64 fixture로 쓰도록 하네스를 수정한 뒤 7종 모두 200 PASS 확인.
- `palm-reading`은 `/generate-poster-guide` 호출 시 `posterType: "palm-reading"`가 필수였고, 하네스에 누락되어 400이 났음. 수정 후 PASS.
- `love`, `compatibility`, `ex-lover`, `naming`, `talisman` fixture를 Edge Function의 실제 required field에 맞게 보정. 그 결과 `talisman` PASS, 나머지는 payload 오류가 아니라 Gemini 429까지 진입 확인.
- auth 테스트 계정 생성을 시도했지만 현재 로컬 `SUPABASE_SERVICE_ROLE_KEY`가 배포 프로젝트에서 `Invalid API key`로 거절됨. `.env.test` 로그인도 이전에 invalid credentials였음.

## PASS 목록
- 동기/즉시 결과: birthstone, daily, personality-dna, talisman, zodiac
- 비동기 포스터/이미지: beauty-simulation, blind-date-guide, face-reading-guide, hair-style-guide, ootd-guide, palm-reading, past-life-guide

## 남은 Blocker
### P0 Gemini quota
영향 타입: avoid-people, biorhythm, blind-date, career, celebrity, compatibility, daily-calendar, decision, dream, ex-lover, exam, exercise, family, game-enhance, health, love, lucky-items, match-insight, moving, naming, new-year, past-life, pet-compatibility, talent, tarot, wealth, wish

### P0/P1 Auth 또는 실제 user row 필요
- JWT 필요: face-reading, lotto, ootd-evaluation, traditional-saju
- 실제 auth user FK 필요: yearly-encounter
- 조치: 현재 프로젝트의 유효한 테스트 계정 또는 service role key 필요. 이후 `SUPABASE_AUTH_TOKEN`/`TEST_USER_ID`로 재실행.

### P1 Endpoint 누락
- constellation
- 현재 `/fortune-constellation`이 배포되어 있지 않음. alias 또는 신규 Edge Function 배포 필요.

## 기타 실패
- blood-type HTTP 500: {"success":false,"error":"혈액형 운세 생성 중 오류가 발생했습니다."}
- chat-insight HTTP 500: {"success":false,"error":"대화 분석 중 오류가 발생했습니다."}
- coaching HTTP 500: {"success":false,"error":"코칭 분석 중 오류가 발생했습니다."}
- mbti HTTP 500: {"success":false,"error":"MBTI 인사이트 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."}
- zodiac-animal HTTP 500: {"success":false,"error":"띠별 운세 생성 중 오류가 발생했습니다."}

## 로컬-only 경로
breathing, daily-review, fortune-cookie, weekly-review

## 검증 산출물
- 하네스: `scripts/qa/haneul-fortune-edge-smoke.mjs`
- 산출물 디렉터리: `artifacts/qa/haneul-fortune-e2e/`
- 대표 live artifacts:
  - palm-reading: `edge-smoke-2026-05-10T19-41-46-430Z.json`
  - beauty-simulation: `edge-smoke-2026-05-10T19-43-11-936Z.json`
  - hair-style-guide: `edge-smoke-2026-05-10T19-44-35-713Z.json`
  - face-reading-guide: `edge-smoke-2026-05-10T19-46-06-424Z.json`
  - ootd-guide: `edge-smoke-2026-05-10T19-47-25-864Z.json`
  - blind-date-guide: `edge-smoke-2026-05-10T19-48-47-559Z.json`
  - past-life-guide: `edge-smoke-2026-05-10T19-33-47-347Z.json`
  - talisman: `edge-smoke-2026-05-10T19-50-25-922Z.json`
  - love: `edge-smoke-2026-05-10T19-50-25-922Z.json`
  - compatibility: `edge-smoke-2026-05-10T19-50-25-922Z.json`
  - naming: `edge-smoke-2026-05-10T19-50-25-922Z.json`

## 다음 실행 커맨드
```bash
# Gemini quota/auth 해결 후 전체 재실행
SUPABASE_AUTH_TOKEN=<valid_user_jwt> TEST_USER_ID=<valid_auth_user_uuid> npx tsx scripts/qa/haneul-fortune-edge-smoke.mjs --live --include-async --timeout-ms=140000
```
