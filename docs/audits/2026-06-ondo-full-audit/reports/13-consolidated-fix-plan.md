# 온도 앱 전체 테스트 결과 통합 수정 계획

## 1. Executive Verdict
- **App Store:** NO-GO
- **BM / Revenue:** 위험
- **User Trust:** 위험
- **Security / Privacy:** 위험
- **Maintainability:** 유지보수 NO-GO
- **QA Readiness:** NO-GO — 시뮬레이터/실기기 증거가 아직 릴리스 근거가 되지 못함

## 2. 한 줄 결론
지금은 화면 polish보다 **돈/토큰 손실, 개인정보 노출, App Store 리젝, 채팅 답장 누락**을 먼저 막아야 한다. 대대수정은 “P0 차단 → P1 신뢰/성능 → UX/디자인 → 구조분리/검증 자동화” 순서로 진행한다.

## 3. Top 10 Risks
1. 광고 보상 self-attestation POST로 광고를 보지 않아도 토큰 지급 가능.
2. 비동기 poster/image 운세가 토큰 차감 실패 후에도 서버 이미지 생성 비용을 발생시킬 수 있음.
3. 사용자 업로드 손금/포스터 이미지 버킷이 public으로 노출됨.
4. 계정 삭제 함수가 존재하지 않는 `profile-images`만 purge해 실제 민감 Storage가 남을 수 있음.
5. 채팅 토큰 선차감 후 답장/저장 실패 시 환불·복구가 없어 토큰 손실 가능.
6. `character-chat` immediate/scheduled delivery가 canonical 저장 전에 done/delivered/ack 처리될 수 있음.
7. Premium/top-up 로그인 후 returnTo가 유실되어 결제/충전 continuation이 깨짐.
8. AI 캐릭터가 AI임을 부정하도록 강제되어 App Store AI transparency 리젝 위험.
9. App Privacy 문서와 실제 AdMob/rewarded ads 사용 상태가 불일치.
10. 채팅/앱 상태/Edge 함수가 God object화되어 회귀와 성능 병목이 누적됨.

## 4. P0 Blockers

### P0-1. 광고 보상 self-attestation 제거 + SSV 원자화
- 출처: `01-bm-iap-revenue-report.md`, `02-app-store-review-report.md`
- 증거: `grant-ad-reward` POST가 JWT만으로 토큰을 지급하던 경로, 일일 count/잔액/로그가 비원자 쿼리로 분산.
- 영향: 하루 5토큰 abuse, SSV GET + POST 중복 지급, 매출 누수.
- 최소 수정:
  - RN 클라이언트 POST 지급 호출 제거.
  - `grant-ad-reward`는 AdMob SSV GET만 지급 허용.
  - `transaction_id` unique + daily cap + balance + transaction + log를 DB RPC 한 번으로 처리.
  - JWT만 가진 POST curl은 403/405/400으로 거부.
- 검증:
  - POST 직접 호출 거부.
  - 동일 SSV transaction replay는 duplicate 처리.
  - 병렬 10회 지급 시 성공 최대 5회, balance/transaction/log 일치.

### P0-2. Poster/image 운세 큐 생성 전 토큰 reserve/차감
- 출처: `01-bm-iap-revenue-report.md`
- 증거: `startAsyncPosterJob` 후 `soul-consume`; consume 실패 시 pending job cancel 없음. worker는 charge 없이 OpenAI image generation 가능.
- 영향: 무과금 이미지 생성 비용, 결과 무상 제공, BM 붕괴.
- 최소 수정:
  - `start-poster-job` 내부에서 token consume/reserve와 job insert를 서버에서 한 흐름으로 처리.
  - `scheduled_poster_jobs.charge_transaction_id` 또는 `charge_reference_id` 필수화.
  - worker는 charge 없는 pending job을 fail/cancel하고 생성 호출 금지.
  - `generate-poster-guide`는 worker-only/internal secret 또는 JWT user match guard 적용.
- 검증:
  - 토큰 0 유저는 job row 미생성 또는 failed/cancelled.
  - worker 호출 후 OpenAI/generate 로그 없음.
  - 정상 유저는 consume transaction과 job charge id 연결.

### P0-3. 사용자 이미지 Storage private 전환
- 출처: `11-supabase-rls-edge-health-report.md`
- 증거: `palm-reading-images`, `poster-guide-images`, `past-life-portraits`, `talisman-images` public bucket 및 public SELECT policy.
- 영향: 손금/사용자 사진 등 민감 이미지가 public URL로 접근 가능.
- 최소 수정:
  - 사용자 업로드 원본 버킷은 private.
  - 생성 결과 공유 이미지와 원본 업로드를 bucket/path로 분리.
  - 앱은 signed URL 또는 Edge-mediated URL만 사용.
- 검증:
  - anon public URL 401/403.
  - 사용자 A/B 상호 object 접근 불가.
  - 앱 재시작 후 signed URL 재발급으로 결과 이미지 정상 표시.

### P0-4. 계정 삭제 Storage purge manifest 정리
- 출처: `11-supabase-rls-edge-health-report.md`, `02-app-store-review-report.md`
- 증거: `delete-account`가 없는 `profile-images` bucket만 purge하려고 하며 `deno check` 실패 보고.
- 영향: 계정 삭제 실패 또는 민감 Storage 잔존, App Store 리젝.
- 최소 수정:
  - 실제 존재 bucket manifest 기반 purge: `palm-reading-images`, `poster-guide-images`, `past-life-portraits`, `character-audio-messages` 등.
  - 없는 bucket은 warning 처리.
  - purge 결과를 audit response에 포함.
  - `deno check supabase/functions/delete-account/index.ts` 통과.
- 검증:
  - 테스트 사용자 prefix object 생성 → delete-account → 모든 prefix 0건.
  - 앱 계정 삭제 완료/로그아웃 UX 확인.

### P0-5. 채팅 토큰 선차감 후 no-reply 환불/복구
- 출처: `03-chat-runtime-rca-report.md`
- 증거: 모바일이 토큰을 선차감하고 assistant message canonical 저장/화면 표시 실패 시 환불/복구 보장이 약함.
- 영향: 결제성 자산 손실 + 답장 누락 + 사용자 신뢰 하락.
- 최소 수정:
  - `pending_reply_job`에 charge transaction linkage 저장.
  - reply canonical persist 성공 전 job done/delivered 처리 금지.
  - 실패/stuck worker는 refund 또는 retry 상태로 전환.
  - optimistic user message rollback/failed state 명시.
- 검증:
  - fresh unique message → assistant row id/timestamp → 화면 bubble 확인.
  - 실패 주입 시 token refund/failed UI 확인.

## 5. P1 Must Fix

### P1-1. App Store AI/Privacy/ATT 정합성
- 출처: `02-app-store-review-report.md`
- 수정:
  - AI 캐릭터가 “사람”이라고 속이는 프롬프트 제거, AI/가상 캐릭터 transparency 반영.
  - App Privacy/Review Notes/AdMob rewarded ads/ATT 설명 일치.
  - 온디바이스 모델 다운로드는 명시 동의/설정 기반으로 지연.

### P1-2. Premium/top-up auth returnTo 보존
- 출처: `08-ux-button-walker-report.md`
- 수정:
  - email/phone/social auth 모두 pending purchase/top-up intent를 유지.
  - new user onboarding보다 결제 continuation이 우선되도록 라우팅 정책 명확화.

### P1-3. 선톡 알림 preference와 receipt 추적
- 출처: `05-proactive-push-report.md`
- 수정:
  - “캐릭터 메시지” OFF가 `character_proactive`까지 차단.
  - user/character/slot/date unique constraint.
  - Expo ticket뿐 아니라 receipt 조회/영속 로깅.

### P1-4. Fortune/Edge auth manifest 정리
- 출처: `11-supabase-rls-edge-health-report.md`, `07-haneul-fortune-e2e-report.md`
- 수정:
  - 유료/비용성 함수는 `authenticateUser`/JWT user source-of-truth.
  - guest 허용 함수만 quota/rate limit 명시.
  - `constellation`, `lotto`처럼 없는 Edge endpoint resolve 경로 제거 또는 구현.

### P1-5. Chat durable delivery / media reply pipeline
- 출처: `03-chat-runtime-rca-report.md`, `04-chat-ux-conversation-report.md`
- 수정:
  - 첫 send 직후 durable job/batch head upsert.
  - 사진 첨부를 모든 캐릭터에서 remote persistence + multimodal reply pipeline으로 통합.
  - scheduled/immediate/foreground claim 모두 canonical persist 후 delivered/ack.

### P1-6. 성능/구조 병목 1차 제거
- 출처: `10-architecture-duplication-performance-report.md`
- 수정:
  - chat message render memoization/virtualization.
  - 앱 bootstrap에서 전체 캐릭터 대화 캐시 ready 전 로드 금지.
  - progress card per-card polling을 job-level manager로 중앙화.
  - 결제 ProductId/token grants SoT 중복 제거.

### P1-7. iOS local/real-device QA path 복구
- 출처: `12-ios-simulator-real-device-report.md`
- 수정:
  - provisioning profile 설정 문서/스크립트 보완.
  - `pnpm rn:start:native` 즉시 실패 해결.
  - clean install 시 Dev Launcher가 아니라 앱 UX 경로로 판정 가능한 evidence 확보.

## 6. P2 Improvements
- 음성 메시지 progress/seek/loading/expiry UI.
- composer VoiceOver label/hint 한국어화.
- 긴 입력 soft/hard limit과 counter.
- reduced-motion/haptic 정책을 첫 경험/녹음/결과/채팅에 일관 적용.
- raw `Text`, raw color/font, legacy premium/storefront 정리.
- support route/menu, legal URL SoT, notification save success/error UI.
- circular dependency 3건 제거, result type/hero/registry mapping SoT 정리.
- bottom sheet/button/card primitive 통합.

## 7. P3 Polish
- Premium 구독 disclosure 가격/기간/갱신 문구 보강.
- App Store review notes/ATT 설명 보강.
- placeholder/emoji fallback을 premium visual language에 맞춤.
- local build artifact/screenshots scan surface 축소.

## 8. Cross-cutting Root Causes
- **Source of Truth 분산:** 상품/토큰/구독/결과 타입/모델명/라우팅이 여러 파일에 수동 중복.
- **서버 원자성 부족:** 토큰 지급/차감/큐 생성/job 상태 변경이 여러 쿼리/경로로 분리.
- **Client optimistic UI 과신:** 화면 표시와 서버 canonical 저장/응답 job 생성을 동일 성공으로 착각.
- **운영 surface manifest 부족:** Edge verify_jwt, Storage bucket, 정책 URL, legal/privacy 상태가 manifest로 관리되지 않음.
- **God object 누적:** `chat-screen`, `chat-surface`, `character-chat`, `MobileAppStateProvider`가 너무 많은 책임을 소유.
- **실기기 evidence 부재:** 시뮬레이터/빌드/실기기/IAP/push evidence가 릴리스 판정에 부족.

## 9. Fix Order

### Phase 1: 즉시 차단/P0
1. 광고 보상 POST 제거 + SSV/RPC 원자화.
2. poster/image queue billing gate + worker-only generation guard.
3. Storage private 전환 + signed URL flow.
4. delete-account storage purge + deno check.
5. chat charge/job/reply canonical persistence ordering 보정.

### Phase 2: 핵심 기능 안정화/P1
1. Premium/top-up auth returnTo 보존.
2. AI transparency/App Privacy/AdMob review note 정합성.
3. proactive preference/duplicate/receipt 추적.
4. fortune endpoint/auth manifest 정리.
5. chat media reply pipeline durable화.

### Phase 3: 수익/전환/신뢰 개선
1. subscription entitlement를 SKU별로 재정의.
2. restore/missing consumable 처리 UX.
3. premium top-up preview와 price SoT 일치.
4. notification save/loading/success/error UX.

### Phase 4: 디자인/모션/UX Polish
1. voice playback progress/expiry.
2. composer a11y Korean labels + input limit.
3. reduced-motion/haptic/raw token 정리.
4. premium visual/storefront 정리.

### Phase 5: 구조 개선/테스트 강화
1. chat render virtualization/memoization.
2. bootstrap lazy hydration.
3. AppState/Billing provider 분리.
4. circular dependency/result registry/model SoT 정리.
5. iOS simulator + physical device evidence loop 자동화.

## 10. Verification Plan

### Type / Static
- `pnpm --dir apps/mobile-rn exec tsc --noEmit`
- Edge function별 `deno check supabase/functions/<fn>/index.ts`
- mutation/SQL 변경 시 Supabase migration dry-run 또는 linked staging 적용 검증.

### Supabase / DB
- ad reward: POST 거부, SSV replay duplicate, 병렬 지급 cap.
- poster: token 0 user job 미생성/failed, normal user charge id 연결.
- Storage: public URL 401/403, signed URL 정상.
- delete-account: bucket manifest purge evidence.
- chat: job/charge/reply row id/timestamp lineage.

### Simulator
- clean install → auth → premium/top-up returnTo → chat fresh message → media send → fortune result 재열람.
- 긴 대화 성능/scroll, audio playback, reduced motion.

### Real Device
- push foreground/background/terminated tap.
- App Store IAP sandbox/token/restore/interrupted purchase.
- Sign in with Apple, camera/photo, microphone, haptic.
- iPad/manual review evidence.

## 11. Current Working Tree Note
현재 working tree에는 이미 일부 수정 흔적이 있다: 광고 보상 SSV-only 전환, proactive rule/test, local native test scripts, migration 등. 대대수정은 이 dirty tree를 먼저 보존/검토한 뒤 이어가야 한다. 무관한 변경을 되돌리거나 덮어쓰지 않는다.

## 12. Decision
- 지금 App Store 제출 가능한가? **아니오.**
- 지금 유저에게 광범위 배포 가능한가? **아니오. P0/P1 보완 전 위험.**
- 지금 BM상 손실 위험이 있는가? **예. 광고 보상, poster queue, subscription entitlement가 핵심.**
- 지금 가장 먼저 고칠 것은? **광고 보상 SSV-only 원자화와 poster queue billing gate.**

## 13. Open Questions
- 구독 BM의 최종 의도: 모든 운세 무제한인지, 월 토큰 지급인지, 캐릭터 채팅 한정 무제한인지 결정 필요.
- 사용자 업로드 원본 이미지와 생성 결과 이미지의 retention/share 정책 확정 필요.
- `generate-poster-guide`를 외부 직접 호출 API로 유지할지, worker-only 내부 API로 닫을지 결정 필요.
