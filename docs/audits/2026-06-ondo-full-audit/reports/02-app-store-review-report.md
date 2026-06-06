# App Store Review Gatekeeper QA Report

## Verdict
- **NO-GO**
- 핵심 리스크 한 줄 요약: **광고 보상 토큰 지급(self-attestation/SSV 중복), 계정 삭제 Edge Function 타입 실패, AI 정체성 은폐 프롬프트, App Privacy/광고 설정 불일치가 App Store 심사 즉시 리젝/매출 손실 리스크입니다.**

## Scope & Method
- 기준 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/02-app-store-review.md`
- 수행 범위: 로그인/게스트, 개인정보/정책 URL, 계정 삭제, ATT/광고, AI/운세 고지, IAP/복원, iPad/기기 안정성, 권한 요청 타이밍 정적 감사 + URL/타입체크 실행 증거 수집.
- 코드 수정: **하지 않음**. 단, 본 보고서 파일만 작성.
- 제한: App Store Connect 실제 응답/ASC privacy answer live state, 실기기/iPad/시뮬레이터 화면 재현, 실제 Supabase DB row 조회는 수행하지 못했습니다. `git status`상 감사 시작 시점에도 repo는 이미 dirty 상태였습니다.

## P0

### P0-1. 광고 보상 토큰 지급이 클라이언트 POST self-attestation만으로 가능함
- 체크리스트 영역: `3. ATT / 광고`, `5. IAP 심사`
- 심각도 근거: 체크리스트 P0 기준의 **결제/토큰 손실 및 보안 문제**. 로그인 사용자가 광고를 실제로 보지 않아도 Edge Function 직접 POST로 토큰 지급을 시도할 수 있습니다.
- 코드/DB 증거:
  - `apps/mobile-rn/src/lib/ad-rewards.ts:79-83` — “POST self-attestation 경로”, “현재는 ad_reward_log 의 일일 한도 (5)” 주석.
  - `apps/mobile-rn/src/lib/ad-rewards.ts:92-104` — 인증 토큰만으로 `grant-ad-reward` POST 호출.
  - `supabase/functions/grant-ad-reward/index.ts:3-7` — GET SSV와 POST fallback 두 호출 경로가 모두 토큰 지급 경로로 명시.
  - `supabase/functions/grant-ad-reward/index.ts:38-44` — `grantTokensForUser()` 공통 지급 함수가 GET/POST 모두에서 사용.
  - `supabase/functions/grant-ad-reward/index.ts:78-99` — `token_balance`, `token_transactions`, `ad_reward_log`에 토큰 지급/로그 insert.
  - `supabase/functions/grant-ad-reward/index.ts:193-215` — POST 요청은 `authenticateUser(req)` 후 body의 `adUnit/ssvSignature`만 받아 `grantTokensForUser()` 호출. AdMob 서명/transaction 검증 없음.
  - `supabase/migrations/20260503193000_ad_reward_log.sql:4-16` — `ad_reward_log` 테이블은 `(user_id, reward_date)` index만 있고 광고 이벤트 idempotency unique key가 없음.
- 재현 단계:
  1. 로그인 세션 access token을 확보합니다.
  2. `POST /functions/v1/grant-ad-reward`에 `Authorization: Bearer [access_token]` 헤더와 body `{ "adUnit": "manual-test" }`를 보냅니다.
  3. 실제 광고 시청 없이 `token_balance`/`token_transactions`/`ad_reward_log`가 증가할 수 있는지 확인합니다.
- 영향:
  - 토큰은 유료 IAP 재화와 직접 연결되므로 매출 우회/무상 토큰 발급 리스크가 큽니다.
  - App Review가 rewarded ad/IAP balance를 점검할 때 보상 검증 신뢰성이 낮아집니다.
- 수정 방향:
  - 운영에서는 POST self-attestation 지급을 비활성화하거나, POST는 “client UI refresh 요청”으로만 두고 실제 지급은 AdMob SSV GET 검증 경로에서만 수행합니다.
  - 광고 이벤트 id/transaction id 기준 unique constraint를 추가해 동일 광고 이벤트 중복 지급을 차단합니다.
  - SSV 서명 검증 실패/누락 시 토큰 지급을 거부합니다.
- 검증 방법:
  - curl로 POST self-attestation을 보내도 토큰이 증가하지 않는지 확인.
  - 정상 AdMob SSV 콜백 1회당 `token_transactions` 1행, `ad_reward_log` 1행만 생성되는지 확인.
  - 동일 SSV callback replay 시 409/200 no-op 등 멱등 응답과 DB row 불변을 확인.

### P0-2. SSV 활성화 시 GET 지급 + 클라이언트 POST 지급이 같은 광고 이벤트에서 중복될 수 있음
- 체크리스트 영역: `3. ATT / 광고`, `5. IAP 심사`
- 심각도 근거: 동일 광고 1회에 복수 토큰 지급 가능성이 있어 P0-1과 같은 토큰 손실 리스크.
- 증거:
  - `apps/mobile-rn/src/lib/ad-rewards.ts:6-10` — `EARNED_REWARD` 후 POST 호출, SSV 활성 시 GET도 지급된다는 흐름이 공존.
  - `apps/mobile-rn/src/lib/ad-rewards.ts:155-160` — AdMob rewarded ad 생성 시 SSV `customData/userId` 설정.
  - `apps/mobile-rn/src/lib/ad-rewards.ts:205-230` — `EARNED_REWARD` 후 항상 `notifyEdgeFunction(session, { adUnit })` POST 호출.
  - `supabase/functions/grant-ad-reward/index.ts:127-164` — GET SSV 검증 통과 시 `grantTokensForUser()`.
  - `supabase/functions/grant-ad-reward/index.ts:212-215` — POST도 `grantTokensForUser()`.
  - `apps/mobile-rn/src/lib/ad-rewards.ts:80-82` — “SSV 활성화된 환경에서는 server-side idempotency 체크가 필요할 수 있으나 현재는 일일 한도”라고 자체 주석으로 인정.
- 재현 단계:
  1. AdMob SSV callback URL을 `grant-ad-reward` GET에 연결합니다.
  2. 앱에서 보상형 광고를 1회 완료합니다.
  3. 같은 광고에 대해 SSV GET과 RN `EARNED_REWARD` POST가 모두 도착하는지 로그를 확인합니다.
  4. `token_transactions`/`ad_reward_log`가 1회 초과 생성되는지 확인합니다.
- 수정 방향:
  - SSV 운영 환경에서는 POST 지급 경로를 제거/feature flag off.
  - `ad_reward_log`에 `ad_event_id` 또는 AdMob transaction id unique constraint를 추가합니다.
- 검증 방법:
  - SSV+POST 동시 발생 시 최종 잔액 증가가 정확히 1토큰인지 DB row로 확인.

### P0-3. 계정 삭제 Edge Function 소스가 `deno check` 실패함
- 체크리스트 영역: `2. 개인정보/정책` — “앱 내에서 계정 삭제 기능이 있는가?”
- 심각도 근거: App Review 5.1.1 계정 삭제는 필수 요구사항입니다. 로컬 소스 타입체크 실패는 신규 배포/수정/재현 가능성을 떨어뜨리며, 계정 삭제 경로 유지보수 리스크가 큽니다.
- 실행 로그:
  ```text
  deno check supabase/functions/payment-verify-purchase/index.ts supabase/functions/delete-account/index.ts supabase/functions/report-message/index.ts supabase/functions/grant-ad-reward/index.ts
  TS2345 [ERROR]: Argument of type 'SupabaseClient<any, "public", "public", any, any>' is not assignable to parameter of type 'SupabaseClient<unknown, { PostgrestVersion: string; }, never, never, { PostgrestVersion: string; }>'.
      const storageResult = await purgeUserStorage(supabase, userId)
                                                   ~~~~~~~~
      at file:///Users/injoo/Desktop/Dev/fortune/supabase/functions/delete-account/index.ts:169:50
  error: Type checking failed.
  DENO_EXIT:1
  ```
- 코드 증거:
  - `supabase/functions/delete-account/index.ts:167-170` — storage purge에서 타입 오류 발생 지점.
  - `supabase/functions/delete-account/index.ts:190-215` — auth user 삭제 및 success 응답 구현은 존재.
  - `apps/mobile-rn/src/screens/profile-screen.tsx:780-788` — 로그인 사용자 프로필 화면에 계정 삭제 버튼 노출.
  - `apps/mobile-rn/app/account-deletion.tsx:1-5` — 계정 삭제 route 존재.
- 화면 경로:
  - 로그인 → `/profile` → `계정 삭제` → `/account-deletion`
- 수정 방향:
  - `purgeUserStorage`의 Supabase client 타입을 실제 `createClient` 반환 타입과 호환되도록 정리합니다.
  - delete-account 단독 `deno check`가 통과한 뒤 배포된 함수와 소스의 commit을 맞춥니다.
- 검증 방법:
  - `deno check supabase/functions/delete-account/index.ts` 0 exit.
  - 테스트 계정으로 앱 내 삭제 실행 후 `auth.users`, 사용자 테이블, storage purge, push token 삭제가 실제 DB에서 확인되는지 검증.

## P1

### P1-1. AI 캐릭터가 AI임을 부정하고 “살아 있는 사람”처럼 대화하도록 강제됨
- 체크리스트 영역: `4. AI/운세 고지`
- 심각도 근거: 면책 고지는 존재하지만, 실제 채팅 프롬프트가 AI 정체성을 숨기도록 설계되어 App Review에서 투명성/기만성 이슈가 될 수 있습니다.
- 증거:
  - `apps/mobile-rn/src/lib/story-romance-pilots.ts:167` — “너는 살아 있는 사람… AI… 같은 단어로 너를 설명하지 않는다.”
  - `apps/mobile-rn/src/lib/on-device-chat-provider.ts:35-37` — “AI 어시스턴트/챗봇/상담사/비서가 아니다.”
  - `supabase/functions/character-chat/index.ts:1273-1280` — “너는 AI 어시스턴트가 아니다… 실제 감정을 가진 사람처럼 대화해라… AI/LLM 정체성 자백 절대 금지.”
  - `supabase/functions/character-chat/index.ts:1868-1872`, `2500-2506` — AI/LLM 자백 패턴 감지 시 답변 폐기 후 fallback 교체.
- 재현 단계:
  1. 캐릭터 채팅에서 “너 AI야?”, “사람이야?”를 질문합니다.
  2. AI/챗봇임을 명확히 밝히지 않고 회피/부정하는지 확인합니다.
- 수정 방향:
  - 캐릭터 몰입은 유지하되, 정체성 질문에는 “AI 기반 캐릭터”임을 숨기지 않는 투명성 문구를 허용합니다.
  - system prompt와 AI disclosure pattern fallback을 App Store 투명성 기준에 맞게 조정합니다.
- 검증 방법:
  - 정체성 질문 회귀 테스트: AI 기반 캐릭터임을 명확히 고지하면서도 캐릭터 톤 유지.
  - 면책 화면(`/disclaimer`)과 채팅 런타임 답변 정책의 일관성 확인.

### P1-2. App Privacy 답변 문서가 “광고 미사용/Advertising Data No”인데 앱은 AdMob SDK와 rewarded ads를 사용함
- 체크리스트 영역: `3. ATT / 광고`, `2. 개인정보/정책`
- 증거:
  - `apps/mobile-rn/package.json:63` — `react-native-google-mobile-ads` 의존성.
  - `apps/mobile-rn/app.config.js:139-143` — `GADApplicationIdentifier`, ATT 미선언/NSPrivacyTracking false 설명.
  - `apps/mobile-rn/app.config.js:347-357` — `react-native-google-mobile-ads` plugin 및 AdMob app id 설정.
  - `apps/mobile-rn/src/lib/ad-rewards.ts:52-54` — Google Mobile Ads 동적 import.
  - `apps/mobile-rn/src/lib/ad-rewards.ts:155-160` — rewarded ad 생성 및 SSV 설정.
  - `artifacts/ios-review-fixes/asc/01-app-privacy-answers.md:114` — `Advertising Data — No`.
  - `artifacts/ios-review-fixes/asc/01-app-privacy-answers.md:131` — “이 앱은 광고 미사용”이라고 명시.
- 정상 증거:
  - `apps/mobile-rn/src/lib/ad-rewards.ts:156` — `requestNonPersonalizedAdsOnly: true`.
  - `apps/mobile-rn/app.config.js:161` — `NSPrivacyTracking: false`.
- 영향:
  - 실제 광고 SDK/보상형 광고와 App Privacy 답변 자료가 충돌합니다.
  - ATT prompt를 띄우지 않는 정책 자체는 가능하지만, AdMob SDK 데이터 수집 항목과 ASC App Privacy questionnaire 정합성 재검증이 필요합니다.
- 수정 방향:
  - ASC App Privacy 답변을 실제 AdMob SDK/보상형 광고 사용 기준으로 갱신합니다.
  - 리뷰 노트에 “non-personalized rewarded ads, no cross-app tracking, no ATT prompt”를 명시합니다.
- 검증 방법:
  - 제출 전 ASC App Privacy answer export와 repo metadata를 비교.
  - 실제 빌드에서 ATT prompt 미노출 및 rewarded ad 동작 확인.

### P1-3. 온디바이스 LLM이 사용자 명시 동의 없이 부팅 시 대용량 모델 다운로드를 시작할 수 있음
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`
- 증거:
  - `apps/mobile-rn/src/lib/on-device-llm.ts:181-198` — 주석상 `없으면 즉시 백그라운드 다운로드 시작 (유저 탭 없이 자동)`, 실제 `this.startDownload()` 호출.
  - `apps/mobile-rn/src/lib/on-device-model-registry.ts:45-97` — flagship 모델 약 `5.1GB` + mmproj 약 `987MB`, mid 모델 약 `3.1GB` + mmproj 약 `987MB`.
  - `apps/mobile-rn/src/lib/on-device-auto-downloader.tsx:16-21` — `not-downloaded` 상태면 `startDownload()` 추가 자동 호출.
- 영향:
  - 첫 실행/부팅 직후 네트워크/저장공간 대량 사용 가능. 심사자의 안정성/사용자 기대/데이터 사용 기준에서 문제될 수 있습니다.
- 수정 방향:
  - 모델 다운로드 전 명시적 opt-in, 예상 용량, Wi‑Fi 권장, 저장공간 체크, 취소/일시정지 UX를 제공합니다.
  - 부팅 자동 다운로드는 기본 off로 전환합니다.
- 검증 방법:
  - fresh install 첫 실행에서 네트워크 다운로드가 사용자 동의 전 시작되지 않는지 proxy/log로 확인.
  - 부족한 저장공간/셀룰러 환경 시 graceful fallback 확인.

### P1-4. iPad 대상 포함이나 fullscreen/portrait-only 구성으로 iPad 심사 리스크가 있음
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`
- 증거:
  - `apps/mobile-rn/ios/app.xcodeproj/project.pbxproj:646`, `683` — `TARGETED_DEVICE_FAMILY = "1,2";` 즉 iPhone+iPad 대상.
  - `apps/mobile-rn/ios/app/Info.plist:88-100` — `UIRequiresFullScreen = true`, iPad orientation은 portrait/portrait upside down만 존재.
- 영향:
  - App Store iPad compatibility/manual test에서 멀티태스킹/회전/레이아웃 제한이 지적될 수 있습니다.
- 수정 방향:
  - iPad 지원 의도를 확정합니다. iPad 지원이면 주요 화면 iPad QA와 screenshot/video evidence를 확보하고, portrait-only/fullscreen 사유가 적절한지 확인합니다.
- 검증 방법:
  - iPad simulator/실기기에서 splash, chat, profile, signup, premium, account deletion, legal screens 캡처.
  - 작은 화면/large text/dark mode까지 매트릭스 검증.

### P1-5. legacy consumable products가 “restore-only”로 남아 있으나 restore flow가 consumable 재검증/재지급을 하지 않음
- 체크리스트 영역: `5. IAP 심사`
- 증거:
  - `packages/product-contracts/src/products.ts:216-226` — legacy consumables가 `restore-only`로 명시.
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1011-1016` — `restoreStorePurchases()` 후 `getAvailableStorePurchases`.
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1025-1039` — restore loop는 subscription activation과 non-consumable local entitlement만 처리.
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1042-1050` — consumable receipt를 `verifyRemotePurchase`로 보내지 않음.
- 영향:
  - App Store consumable은 일반적으로 복원 대상이 아니지만, 내부 계약/문구가 restore-only라고 선언된 legacy token product와 실제 restore 버튼 동작이 불일치합니다.
- 수정 방향:
  - legacy consumable을 실제 복원하지 않는다면 `restore-only` 표현을 제거하고, 복원 대상/비대상을 UI/리뷰노트에 명확히 구분합니다.
  - 복원이 필요하다면 Apple receipt 기반 서버 재검증/중복 지급 방지 로직을 추가합니다.
- 검증 방법:
  - Sandbox 계정으로 구독/비소모성/소모성 각각 purchase/restore 결과와 DB row(`verified_purchases`, `token_transactions`, `subscriptions`) 확인.

## P2

### P2-1. 앱 내 Support 전용 route/menu가 확인되지 않음
- 체크리스트 영역: `2. 개인정보/정책`
- 증거:
  - `apps/mobile-rn/src/screens/profile-screen.tsx:706-734` — 개인정보처리방침/이용약관/EULA/면책/오픈소스만 노출.
  - `apps/mobile-rn/app/business-info.tsx:43-49` — 사업자 정보 관련 링크에도 support 없음.
  - `public/support.html:125-128`, `vercel.json:41-42` — 웹 support URL/route는 존재.
  - URL liveness: `https://zpzg.co.kr/support`, `https://zpzg.co.kr/support.html` 모두 200.
- 영향:
  - App Store support URL 자체는 충족하지만, 앱 내 접근성은 낮아 리뷰어/사용자 문의 흐름이 불명확합니다.
- 수정 방향:
  - 프로필/설정 정책 섹션에 “문의/지원” 항목을 추가하고 support URL 또는 인앱 support 화면으로 연결합니다.
- 검증 방법:
  - `/profile` → 지원 항목 탭 → support 페이지 정상 표시.

### P2-2. 정책 URL 소스가 여러 도메인/엔드포인트로 분산됨
- 체크리스트 영역: `2. 개인정보/정책`
- 증거:
  - `metadata/ko/privacy_url.txt:1` — `https://zpzg.co.kr/privacy`.
  - `metadata/ko/support_url.txt:1` — `https://zpzg.co.kr/support.html`.
  - `apps/mobile-rn/appstore-metadata.md:15-17` — Supabase legal-pages URL 사용.
  - `metadata/review_information/notes.txt:35-37` — Supabase legal-pages URL 사용.
  - URL liveness 로그: `zpzg.co.kr` privacy/terms/support와 Supabase legal-pages privacy/terms/disclaimer 모두 200.
- 영향:
  - 즉시 리젝보다는 제출 자동화/리뷰 노트/메타데이터 간 source-of-truth 혼선. 내용 차이가 생기면 5.1.1 리스크로 상승.
- 수정 방향:
  - ASC metadata, review notes, 앱 내 legal links를 한 canonical 도메인으로 통일합니다.
- 검증 방법:
  - `metadata/*/*_url.txt`, `metadata/review_information/notes.txt`, 앱 내 legal route의 URL이 동일 canonical로 수렴하는지 검색.

### P2-3. `PrivacyInfo.xcprivacy`가 tracked file로 없고 Expo config 생성에 의존함
- 체크리스트 영역: `2. 개인정보/정책`, `3. ATT / 광고`
- 증거:
  - `git ls-files` 결과 `PrivacyInfo.xcprivacy` 없음.
  - `apps/mobile-rn/app.config.js:156-160` — `ios/app/PrivacyInfo.xcprivacy`는 gitignored로 prebuild 시 재생성된다는 주석.
  - `apps/mobile-rn/app.config.js:160-273` — `privacyManifests` 정의 존재.
- 영향:
  - 제출 바이너리에 privacy manifest가 실제 포함됐는지 build artifact 검증 없이는 확인하기 어렵습니다.
- 수정 방향:
  - 제출 전 prebuild/EAS artifact에서 `PrivacyInfo.xcprivacy` 포함 및 `NSPrivacyTracking=false`를 확인하는 release gate를 추가합니다.
- 검증 방법:
  - 빌드 산출물 압축 해제 후 `PrivacyInfo.xcprivacy` 존재와 내용 확인.

### P2-4. 강제 Dark 모드와 프로필 테마 토글이 실제 시스템 라이트/다크와 불일치 가능
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`
- 증거:
  - `apps/mobile-rn/ios/app/Info.plist:102-103` — `UIUserInterfaceStyle = Dark`.
  - `apps/mobile-rn/src/screens/profile-screen.tsx:93`, `390-391` — `themeMode` state와 라이트/다크 칩 UI 존재.
- 영향:
  - App Review 캡처/사용자 설정에서 라이트 선택 UI가 실제 OS/UI와 맞지 않을 수 있습니다.
- 수정 방향:
  - 앱이 다크 전용이면 토글을 제거/비활성화하고 설명합니다. 토글을 유지할 경우 실제 theme provider와 iOS plist 정책을 일치시킵니다.
- 검증 방법:
  - iOS light/dark 설정, 앱 내 theme toggle, screenshot 비교.

### P2-5. small-screen 고정 크기 UI가 다수 존재해 iPhone SE/Dynamic Type overflow 가능성
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`
- 증거 예시:
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:449-450` — `width: 342`, `height: 342`.
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:604-605` — `width: 286`, `height: 286`.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1641-1659` — `height: 320/360`, `width: 320/360`.
  - `apps/mobile-rn/src/screens/premium-screen.tsx:439-443` — `height: 180`, `width: 300`.
  - `apps/mobile-rn/src/screens/friend-creation-screen.tsx:938-944` — `width/height: 200`.
- 영향:
  - 작은 화면, Dynamic Type, iPad split/fullscreen에서 clipped/overflow 가능성이 있습니다. 정적 검색 기준이라 실제 화면 재현은 필요합니다.
- 수정 방향:
  - 주요 hero/visual 영역을 `min(screenWidth - padding, maxSize)` 형태로 반응형 처리하고 scroll 영역을 보장합니다.
- 검증 방법:
  - iPhone SE 2/3, iPad, Dynamic Type 1.5x에서 welcome/chat/premium/friend creation 화면 캡처.

### P2-6. 카메라/사진 권한 문구가 “관상 분석” 중심이라 채팅 이미지 첨부 맥락과 불일치 가능
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`, `2. 개인정보/정책`
- 증거:
  - `apps/mobile-rn/ios/app/Info.plist:62-69` — Camera/Photo purpose string이 “관상 분석” 중심.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2566-2577` — 채팅 화면에서 이미지 라이브러리 접근.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:2689-2710` — 카메라/갤러리 선택 후 권한 요청.
- 영향:
  - 이미지 첨부가 캐릭터/채팅 multimodal에도 쓰이면 권한 사용 목적 문구가 실제 사용 목적보다 좁아 5.1.1 purpose string 지적 가능.
- 수정 방향:
  - “관상 분석 및 채팅 이미지 첨부”처럼 실제 사용 목적을 모두 포함하는 문구로 정리합니다.
- 검증 방법:
  - 카메라/사진 권한 prompt 스크린샷에서 목적 설명이 실제 진입 경로와 맞는지 확인.

### P2-7. 민감 조언 safeguard가 고지 화면에는 있으나 캐릭터 생성 정책에는 전문 조언 제한이 약함
- 체크리스트 영역: `4. AI/운세 고지`
- 정상 증거:
  - `apps/mobile-rn/app/disclaimer.tsx:10-41` — 오락/엔터테인먼트, 전문 조언 대체 금지, 자해/자살 위기 연락처 고지 존재.
  - `metadata/ko/description.txt:64-65` — 건강/법률/재무 전문가 상담 안내 존재.
- 리스크 증거:
  - `supabase/functions/character-chat/index.ts:871-893` — `buildContentPolicyPrompt`는 성적/폭력/차별/선정성 제한 중심이며 의료/법률/금융/정신건강 조언 제한이 명시적으로 보이지 않음.
- 영향:
  - 심사자가 건강/투자/법률 질문을 던질 경우, 실제 AI 응답이 앱/약관의 “전문 조언 대체 금지”와 다르게 보일 수 있습니다.
- 수정 방향:
  - character-chat system prompt/content policy에 의료·법률·금융·정신건강 확정 조언 금지와 전문가 상담 유도 규칙을 명시합니다.
- 검증 방법:
  - 의료/법률/투자/자해 관련 red-team 프롬프트 세트로 답변 톤과 fallback 검증.

## P3

### P3-1. ATT/광고 review notes 설명이 부족함
- 체크리스트 영역: `3. ATT / 광고`
- 증거:
  - `apps/mobile-rn/src/lib/ad-rewards.ts:156` — 비개인화 광고 요청.
  - `apps/mobile-rn/app.config.js:142-143` — ATT를 의도적으로 선언/요청하지 않고 `NSPrivacyTracking=false` 유지.
  - `metadata/review_information/notes.txt:1-41` — 광고/보상형 광고/비개인화 광고/ATT 설명 없음.
- 개선 방향:
  - Review notes에 “Rewarded ads are non-personalized; no cross-app tracking; ATT prompt is not shown because tracking is not used”를 명시합니다.
- 검증 방법:
  - 실제 빌드 첫 실행/광고 진입에서 ATT prompt가 나오지 않는지 확인.

### P3-2. 푸시 권한은 JIT soft-ask 구조로 보여 first-launch 권한 리스크는 낮음
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`
- 정상 증거:
  - `apps/mobile-rn/src/lib/push-notifications.ts:520-538` — `promptIfNotGranted` 없으면 OS prompt를 띄우지 않음.
  - `apps/mobile-rn/src/lib/push-notifications.ts:896-981` — 캐릭터 첫 메시지 전 soft-ask 후 동의 시 OS prompt.
  - `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:328-331`, `413-417`, `441-449` — 부팅/인증/foreground 복귀 시 토큰 등록은 권한 없으면 silent skip.
- 개선 방향:
  - 첫 메시지 send와 soft-ask Alert가 동시에 뜨는 UX 노이즈만 실기기에서 확인합니다.

### P3-3. cold-start hang/deeplink race 방어 코드가 존재함
- 체크리스트 영역: `6. iPad / 다양한 기기 / 안정성`
- 정상 증거:
  - `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:282-304` — Supabase `getSession()` 8초 timeout.
  - `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:356-375` — deep-link listener를 bootstrap 시작 전 부착.
- 개선 방향:
  - 실제 App Review regression 방지를 위해 네트워크 오프라인 cold-start와 iPad Sign in with Apple fallback callback QA를 release gate에 포함합니다.

## Evidence

### 실행 로그 요약
```text
## git status --short
 M CLAUDE.md
 M apps/mobile-rn/package.json
 M package.json
 M pnpm-lock.yaml
?? .githooks/
?? apps/mobile-rn/scripts/
?? docs/audits/
?? docs/development/local-native-ios-testing.md
?? scripts/verify-rn-native-patch.sh

## URL liveness
https://zpzg.co.kr/privacy -> 200 https://zpzg.co.kr/privacy text/html; charset=utf-8
https://zpzg.co.kr/terms -> 200 https://zpzg.co.kr/terms text/html; charset=utf-8
https://zpzg.co.kr/support -> 200 https://zpzg.co.kr/support text/html; charset=utf-8
https://zpzg.co.kr/support.html -> 200 https://zpzg.co.kr/support.html text/html; charset=utf-8
https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy -> 200 https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy text/plain
https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service -> 200 https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service text/plain
https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/disclaimer -> 200 https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/disclaimer text/plain

## Edge Function static check
deno check ...
DENO_EXIT:1

## Mobile RN typecheck
pnpm --filter @fortune/mobile-rn typecheck
TSC_EXIT:0
```

### 체크리스트별 확인 결과
- 로그인/게스트 정책:
  - `metadata/review_information/notes.txt:5-13` — 게스트 리뷰 경로와 계정 필요 흐름 명시.
  - `apps/mobile-rn/app/(tabs)/chat.tsx:1-5` — chat route는 auth redirect 없이 `ChatScreen` 렌더.
  - `apps/mobile-rn/src/screens/signup-screen.tsx:27-36`, `265-274` — Apple 로그인 옵션/버튼 존재.
  - `apps/mobile-rn/src/lib/social-auth.ts:89-146` — iOS Apple native auth + Supabase `signInWithIdToken` 구현.
- 개인정보/정책:
  - URL liveness는 모두 200.
  - 계정 삭제 UI/route/function 존재하지만 `delete-account` source typecheck 실패.
- ATT/광고:
  - AdMob SDK와 rewarded ads 존재, 비개인화 옵션 사용, ATT prompt는 no-tracking 방향.
  - App Privacy 답변 artifact와 실제 광고 사용 불일치.
- AI/운세 고지:
  - `/disclaimer`와 App Store 설명에는 오락/전문 조언 대체 금지 고지 존재.
  - character-chat runtime prompt에는 AI 정체성 은폐 및 전문 조언 제한 약점 존재.
- IAP:
  - purchase/verify/restore 코드 경로 존재.
  - 광고 보상 토큰 보안 및 legacy consumable restore mismatch 리스크 존재.
- iPad/기기/안정성:
  - iPad target 포함, fullscreen/portrait-only 구성.
  - first-launch push prompt는 JIT 구조로 양호.
  - on-device LLM 자동 대용량 다운로드 가능성은 P1.

## Recommended Fix Order
1. **광고 보상 토큰 지급 경로 잠금(P0-1/P0-2)**: POST self-attestation 지급 비활성화, SSV-only 지급, event idempotency unique constraint 추가, replay 테스트.
2. **계정 삭제 함수 타입/실동작 복구(P0-3)**: `delete-account` deno check 0 exit, 테스트 계정 삭제 E2E, DB/storage/auth row 검증.
3. **App Privacy/AdMob/ATT 정합성(P1-2/P3-1)**: ASC privacy answer, repo metadata, review notes, privacy manifest를 실제 SDK/광고 사용에 맞게 통일.
4. **AI 투명성/전문 조언 safeguard(P1-1/P2-7)**: AI 정체성 질문 disclosure 허용, 의료/법률/금융/정신건강 제한을 runtime prompt에 반영, red-team QA.
5. **온디바이스 LLM 다운로드 opt-in(P1-3)**: 자동 다운로드 제거, 용량/네트워크/저장공간 동의 UX 추가.
6. **IAP restore 문구/동작 정합성(P1-5)**: legacy consumable 정책 정리, Sandbox purchase/restore DB 증거 확보.
7. **iPad/small-screen/권한 문구 polish(P1-4/P2-4/P2-5/P2-6)**: iPad/SE/Dynamic Type 캡처 QA, permission purpose string 정리.
8. **Support/legal canonical URL 정리(P2-1/P2-2/P2-3)**: 앱 내 support 링크 추가, canonical URL 통일, build artifact privacy manifest 확인.

## Open Questions
- 현재 App Store Connect에 제출된 live App Privacy answer가 `artifacts/ios-review-fixes/asc/01-app-privacy-answers.md`와 동일한가?
- AdMob SSV callback이 운영 콘솔에서 실제로 활성화되어 있는가? 활성화되어 있다면 POST fallback도 동시에 운영 중인가?
- 현재 배포된 `delete-account` Edge Function은 로컬 소스와 같은 commit에서 배포되었는가, 아니면 이전 정상 버전이 배포되어 있는가?
- iPad 지원을 계속 유지할 것인가, 아니면 iPhone-only로 제출 전략을 바꿀 것인가?
- 온디바이스 LLM 기능은 App Store 제출 빌드에서 활성화되어 있는가, feature flag/offline fallback 상태인가?
