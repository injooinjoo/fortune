# iOS App Store 심사 종합 리뷰 — 온도(Ondo) v1.0.9

작성: 2026-04-23 / 대상 빌드: `com.beyond.fortune` 1.0.9 / 이전 리젝: Guideline 2.1(iPad Sign in with Apple), 3.1.2(subscription metadata)

> 세부 리포트: `01-meta-permissions.md`, `02-privacy-iap.md`, `03-ai-content-safety.md`, `04-security.md`, `05-code-quality.md`, `06-ui-ux.md`

---

## 🔴 SHIP BLOCKER — 지금 제출하면 리젝

재제출 전에 반드시 해결해야 하는 항목. 번호는 수정 권장 순서.

| # | 영역 | 근거 파일 | 내용 |
|---|------|----------|------|
| **B1** | **2.1 Sign-in 재발 위험 (최우선)** | `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:190-382`, `app/_layout.tsx` | iPad Sign in with Apple 콜드스타트 레이스. `Linking.addEventListener('url', …)`가 async `bootstrap()` 체인 뒤(세션 fetch + `getInitialURL` 이후) 등록됨. iPad에서 `WebBrowser.openAuthSessionAsync` 콜백 URL이 리스너 부착 전에 도착하면 **이전과 동일 사유로 다시 리젝**. 수정: `Linking.addEventListener`를 `_layout.tsx` 최상단에서 동기 부착, async 체인과 분리. |
| **B2** | **5.2.3 UGC 모더레이션 0건** | `supabase/functions/character-chat/`, `apps/mobile-rn/src/features/chat-surface/`, `character-profile-screen.tsx` | AI 캐릭터 챗이 있는데 (1) 메시지 **신고 버튼**, (2) 캐릭터 **차단**, (3) 사전 모더레이션 **전혀 없음**. Apple은 이 갭으로 AI 챗 앱을 루틴하게 리젝. 최소 조치: 메시지 long-press → 신고, 캐릭터 프로필 → 차단, `character-chat/index.ts`에서 OpenAI `omni-moderation-latest` 1회 호출, EULA에 24h 테이크다운 조항. |
| **B3** | **보안: Kakao OAuth 계정 탈취** | `supabase/functions/kakao-oauth/index.ts:56-128`, `supabase/config.toml` | Public endpoint (`verify_jwt=false`)에서 request body의 `access_token`/`email`을 **카카오에 검증하지 않고** `auth.admin.createUser`/`generateLink` 호출. 임의 카카오 이메일로 아무 계정이나 로그인 가능. `naver-oauth/index.ts`가 올바른 검증 레퍼런스이니 동일 패턴으로 재작성. |
| **B4** | **보안: 서버가 `body.userId` 신뢰** | `supabase/functions/fortune-tarot/index.ts:419-527`, `widget-cache/index.ts:49` | 유저 스코프 read/write에 request body의 userId 사용 + `'anonymous'` 폴백. JWT에서 `supabase.auth.getUser(token)`로 강제해야 함 (이미 `character-chat/index.ts:1948`, `_shared/auth.ts`에 패턴 있음). |
| **B5** | **5.1.2 AI 의료 조언 (fortune-health)** | `supabase/functions/fortune-health/index.ts:478-514,522-528,569,585-590`, `hero-health.tsx` | Apple Health vitals(혈압/혈당/SpO₂/심박) LLM 컨텍스트 주입 + "다이어트 플랜/운동 강도/예방법" 지시형 출력. 카드 별 disclaimer 없음. 해결: Health vitals 제거, 처방형 문구 → 가이드형, `primitives/result-card-frame.tsx`에 "참고·오락용" disclaimer 상시 표시. |
| **B6** | **Splash 개발 플래그가 프로덕션 On** | `apps/mobile-rn/src/screens/splash-screen.tsx:11-13` | `FORCE_WELCOME_FOR_DEV = true`. 리뷰어가 **매 콜드스타트마다** 7-scene welcome 캐러셀 강제 통과. `false`로 전환 또는 `__DEV__` 가드. |
| **B7** | **리뷰어 이메일 화이트리스트 누락** | `apps/mobile-rn/src/lib/test-accounts.ts:2` | `ink595@g.harvard.edu`만 등록. 이전 리뷰는 `test@zpzg.com` 사용. 리뷰어가 결제/Face 등 test 전용 우회를 못 받음. `test@zpzg.com` 추가. |
| **B8** | **다크모드 manifest 거짓말** | `app.config.ts:93` vs `apps/mobile-rn/src/lib/theme.ts:4` vs `app/_layout.tsx:62` | `userInterfaceStyle:'automatic'` 선언했지만 `createFortuneTheme('dark')` 하드코딩 + `StatusBar style="light"` 하드코딩. `'dark'`로 고정하거나 `useColorScheme()`으로 실제 분기. manifest mismatch는 4.5 위반. |
| **B9** | **Info.plist 버전 드리프트** | `apps/mobile-rn/ios/app/Info.plist:24`, `app.config.ts:89` | `CFBundleShortVersionString=1.0.8` 인데 Expo 설정은 1.0.9. EAS 빌드 시 `expo prebuild --clean` 돌지 않으면 바이너리가 잘못된 버전으로 업로드. |
| **B10** | **Speech Recognition 권한 문자열 영문 기본값** | `Info.plist:64-65` | "Allow $(PRODUCT_NAME) to use speech recognition." — 타 권한은 모두 한국어인데 이것만 기본값. 5.1.1 리젝 단골. `app.config.ts`의 `expo-speech-recognition` 설정에 한국어로 override. |
| **B11** | **Privacy Manifest `NSPrivacyCollectedDataTypes` 비어있음** | `apps/mobile-rn/ios/app/PrivacyInfo.xcprivacy:43-44` | Sentry + (향후 Mixpanel)로 Crash/Diagnostic/Performance 수집 중인데 manifest는 빈 배열. 2024년 이후 Apple이 바이너리 스캔으로 강제. ASC App Privacy 답변과 일치시켜 항목 채우기. |

---

## 🟡 WARNING — 리뷰어가 질문할 가능성 높음

| # | 영역 | 파일 | 내용 |
|---|------|------|------|
| W1 | **연령 게이트 없음 (12+ 등급과 충돌)** | `app/onboarding/birth.tsx:11-38`, `pilot_registry.ts:64-376` | 생년월일 수집하지만 최소 연령 검증 없음. 로맨스 파일럿 10종 + `CONTENT_TIER_GUIDE.t4_intimate` "스킨십 암시" 허용. 서버가 `maxContentTier`를 검증 안 함(`character-chat/index.ts:764-766` 클라이언트 제어). 최소: 14/13+ 하드 게이트 + 서버에서 미성년 tier 차단. |
| W2 | **구독 Privacy/EULA URL이 Supabase 임시 도메인** | `apps/mobile-rn/src/screens/premium-screen.tsx:386-410` | `hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/…` 외부 링크. 이전 3.1.2 리젝의 원인. `zpzg.co.kr/terms`, `zpzg.co.kr/privacy`로 전환 또는 인앱 `/privacy-policy`, `/terms-of-service` 라우트 사용(이미 `profile-screen.tsx:713`에 존재). |
| W3 | **과도한 RLS 정책** | `supabase/migrations/` | `celebrity_master_list`, `talisman_pool`, `widget_fortune_cache`, `popular_regions`, `user_notification_preferences` 에 `USING(true) WITH CHECK(true)`. `service_role` 한정으로 재설정. |
| W4 | **LLMFactory 우회 (CLAUDE.md 위반)** | `fortune-past-life/index.ts:2181`, `fortune-yearly-encounter/index.ts:584,693`, `speech-to-text/index.ts:57`, `generate-talisman/index.ts:230` | `generativelanguage.googleapis.com` 직접 호출 + URL 쿼리에 API 키. `LLMFactory.createFromConfig(...)` 경유로 재작성. |
| W5 | **expo-iap Privacy Manifest 미번들** | `ios/Pods/ExpoIap`, `ios/Pods/openiap` | `PrivacyInfo.xcprivacy` 없음. Apple의 required-reason SDK 스캔에 걸릴 수 있음. 최신 패치/포크로 업그레이드. |
| W6 | **iPad 가로모드 허용, iPhone은 세로만** | `Info.plist:87-93` | 이전 리젝이 iPad 관련. 모든 화면 가로 QA 안 됐다면 iPad도 portrait 잠금. |
| W7 | **서비스 키/JWT 시크릿 로컬 디스크 노출** | `/Users/injoo/Desktop/Dev/fortune/.env.local` | `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET`, `OPENAI_API_KEY`, Upstash 등. `.gitignore` 처리됨 (히스토리 미포함). 로컬 머신 노출이지만 예방 로테이션 권고. |
| W8 | **프로필 이미지 public bucket, 계정 삭제 시 purge 안 됨** | `supabase/migrations/20250929130000_*.sql:13,63-67`, `delete-account/index.ts` | 5.1.1(v) 계정 삭제가 20개 테이블은 지우지만 스토리지 버킷은 비움 안 함. bucket purge hook 추가. |
| W9 | **Push 권한을 콜드스타트에서 요청** | `app-bootstrap-provider.tsx` `registerPushTokenForSignedInUser` | Just-In-Time 요청이 리뷰어 기대값. onboarding 단계에서 "알림 받기" 명시 후 요청. |
| W10 | **Edge runtime 타임아웃/AbortController 없음 + 챗 에러 재시도 UI 없음** | `features/chat-results/edge-runtime.ts`, `chat-surface.tsx` | 오프라인 리뷰어가 무한 스피너만 봄. AbortController + 에러 버블 + retry 버튼 필수. |
| W11 | **터치 타겟 < 44pt 다수** | `chat-surface.tsx:93` HeaderActionButton 36×36, `inline-calendar.tsx:10` CELL_SIZE 36, SelectableChip 36, Composer 아이콘 40 | Apple HIG 위반. 최소 44pt로 상향 또는 hitSlop. |
| W12 | **계정 삭제 테이블 리스트 하드코딩** | `supabase/functions/delete-account/index.ts` | 20개 테이블 나열 방식 → 새 테이블(chat messages, push tokens 등) 누락 위험. `auth.users`에서 `ON DELETE CASCADE` 걸기. |
| W13 | **Celebrity 호환성 — 실존 연예인 사용** | `supabase/migrations/20251128000008_insert_entertainers.sql:83` | 5.2.1/5.6 impersonation 리스크. 파생 콘텐츠가 명예훼손으로 해석되지 않도록 disclaimer + 출력 가드. |
| W14 | **Face/Voice 처리 클라우드 전송 고지 미흡** | `app.config.ts:139-141`, `story-chat-runtime.ts:919-938` | "관상 분석을 위해 사진 접근" 문구는 접근 사유만, 클라우드 업로드/LLM 처리 고지 없음. 업로드 전 confirm 다이얼로그 + 저장 안 함 명시. |
| W15 | **Sentry 크래시 리포트가 user-id와 연결** | `crash-reporting.ts` | Privacy Nutrition Labels에 "Crash Data — Linked" 정확히 반영해야 함. |
| W16 | **온보딩 화면 KeyboardAvoiding 누락** | `onboarding-screen.tsx:323` | `<Screen>` 사용 시 `keyboardAvoiding` prop 빠짐. 이름 TextInput에서 CTA 가림. |

---

## 🟢 PASS — 양호 (증거로 유지)

- **5.1.1(v) 계정 삭제**: 실제 hard delete + row-count 검증 (`supabase/functions/delete-account/index.ts`) — 품질 양호
- **3.1.1 IAP**: expo-iap 네이티브, Restore 버튼, 구독 공시 블록, EULA/개인정보 링크 프리버튼 (`premium-screen.tsx:386-454`)
- **Sign in with Apple**: `signup-screen.tsx` 첫 순위, `usesAppleSignIn:true`, 네이티브 flow (`social-auth.ts:51-134`)
- **Apple Sign-In nonce**: 올바르게 구현 (`social-auth.ts:67-95`)
- **Client anon key만 사용**: SERVICE_ROLE/OPENAI_API_KEY 등 앱 번들에 없음 (`apps/mobile-rn/src/lib/supabase.ts:19`)
- **토큰 SecureStore 저장**: `expo-secure-store` 경유 (`secure-store-storage.ts`), AsyncStorage 사용 안 함
- **ITSAppUsesNonExemptEncryption**: `false` 올바름 (HTTPS만, Apple-exempt)
- **Required-reason API 카테고리**: FileTimestamp/UserDefaults/SystemBootTime/DiskSpace 모두 선언됨
- **Native `AppDelegate.swift:36-52`**: openURL/userActivity → RCTLinkingManager 포워딩 정확
- **TypeScript**: `tsc --noEmit` 0 errors
- **any 남용 없음**: 실제 `as any` 3건만, `@ts-ignore`/`@ts-expect-error` 0건
- **빈 catch 0건**: 43개 catch 전부 라벨 prefix로 로깅
- **First-launch disclaimer 모달**: `onboarding-screen.tsx:150,335-362` + 프로필 재접근 + `/disclaimer` 라우트
- **파일럿 `hardBoundaries`**: 각 페르소나가 "미성년 금지", "노골적 성적 표현 금지" 선언 (`pilot_registry.ts`)
- **Screen 공용 래퍼**: 대부분 화면이 safe-area + iPad 600pt 클램프 통과
- **Naver OAuth**: 토큰을 네이버에 재검증 — 올바른 레퍼런스

---

## 🟠 코드 품질 — Long-term (심사와 무관, 리팩토링)

- 하드코딩 hex 319개 (176개 파일). 상위: `chat-surface.tsx`(26), `batch-a.tsx`(22), `welcome-screen.tsx`(21), `batch-c.tsx`(17), `batch-e.tsx`(15)
- `fontSize:` 리터럴 86개 / `fontWeight:` 60개 (30+ 파일)
- Bare `<Text>` + 인라인 스타일 28개 (`story-chat-animations/*` 집중)
- `console.log` 잔존 13개 — `on-device-llm.ts`(4), `profile-edit-screen.tsx`(4), `chat-results/edge-runtime.ts`(2)
- 거대 파일 StyleSheet 미사용: `batch-e.tsx`(2371줄), `chat-surface.tsx`(2361줄), `batch-c.tsx`(1282), `batch-a.tsx`(1281)
- Top 5 파일만 리팩토링해도 위반 >50% 해소

---

## 📋 재제출 체크리스트 (권장 순서)

**Day 1 — 스템 블로커**
- [ ] B1: `Linking.addEventListener` 동기 최상단 부착 (app/_layout.tsx) + iPad 콜드스타트 테스트
- [ ] B6: `FORCE_WELCOME_FOR_DEV = false`
- [ ] B7: `test@zpzg.com` 테스트 계정 화이트리스트 추가
- [ ] B9: `expo prebuild --clean` + Info.plist 버전 1.0.9 확인
- [ ] B10: 한국어 Speech Recognition 권한 문자열
- [ ] B8: theme/statusBar light-only 고정 또는 `useColorScheme` 분기

**Day 2-3 — 보안/콘텐츠**
- [ ] B3: Kakao OAuth `/v2/user/me` 검증 (naver-oauth 패턴)
- [ ] B4: `body.userId` 전면 제거, JWT 강제
- [ ] B2: 챗 신고 UI + 캐릭터 차단 + OpenAI moderation
- [ ] B5: fortune-health에서 Health vitals 제거 + disclaimer 상시
- [ ] W1: 연령 게이트 + 서버측 `maxContentTier` 검증

**Day 4 — 메타/ASC**
- [ ] B11: Sentry Privacy Manifest 데이터 타입 채우기
- [ ] W2: 법적 URL을 `zpzg.co.kr` 또는 인앱 라우트로
- [ ] W3: RLS policy 재점검
- [ ] W4: LLMFactory 우회 4건 재작성
- [ ] W6: iPad portrait 잠금 (가로 QA 안 됐으면)
- [ ] W7: 로컬 `.env.local` 시크릿 로테이션

**Review Notes 템플릿**
- 테스트 계정: `test@zpzg.com` / `TestPassword123!`
- Apple Sign-In iPad 테스트 경로 명시
- 온디바이스 LLM 4GB 다운로드는 **선택적** 임을 명시 (심사 중 다운로드 불필요)
- Health fortune이 의료 조언이 아님 명시
- 캐릭터 챗 moderation/report 메커니즘 위치 명시

---

## 수치 요약

| 지표 | 값 |
|------|-----|
| SHIP BLOCKER | 11건 |
| WARNING | 16건 |
| PASS / 양호 | 16건 |
| 코드 품질 위반 | 500+ (하드코딩 스타일) |
| TypeScript 에러 | 0 |
| 빈 catch | 0 |
| `any` 캐스트 | 3 |
