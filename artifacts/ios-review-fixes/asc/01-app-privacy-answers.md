# App Store Connect — "App Privacy" 답변 시트

`app.config.ts`의 `ios.privacyManifests`와 **1:1 일치**시켜야 합니다. 불일치 시 5.1.1 리젝.

참조: `artifacts/sprint-fixes/P6-B11/mapping.md`

---

## Tracking

| 질문 | 답변 |
|------|------|
| Is tracking enabled in your app? | **No** |
| Are tracking domains declared? | **No** |

근거: ATT 프롬프트 없음, cross-app/website linkage 없음. Mixpanel SDK 미설치 (env 플레이스홀더만 존재). Sentry는 자체 user-id 관리, 광고식별자 미사용.

---

## Data Types Collected

**총 11개 category, 모두 `Linked to You = Yes`, `Used for Tracking = No`.**

### Contact Info
- [x] **Email Address**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**
  - 수집 이유: Supabase auth (Apple/Google/Kakao/Email 로그인)

- [x] **Name**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**, **Product Personalization**
  - 수집 이유: 사주/운세 개인화 (닉네임 표시, 결과 카드 개인화)

- [ ] Phone Number — **No**
- [ ] Physical Address — **No**
- [ ] Other Contact Info — **No**

### Identifiers
- [x] **User ID**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**
  - 수집 이유: Supabase user.id (세션, 권한, 토큰 잔액)

- [x] **Device ID**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**, **Analytics**
  - 수집 이유: Expo push token + Sentry installation id

### Diagnostics
- [x] **Crash Data**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**
  - 수집 이유: Sentry crash reports (`Sentry.setUser({id})` 호출)

- [x] **Performance Data**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **Analytics**
  - 수집 이유: Sentry performance tracing

- [x] **Other Diagnostic Data**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**, **Analytics**
  - 수집 이유: Sentry breadcrumbs, session replay fragments

### User Content
- [x] **Photos or Videos**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**
  - 수집 이유: 관상 분석 시 사용자가 촬영/선택한 얼굴 사진 → Gemini 전송 (서버 저장 안 함, 요청 메모리만 경유)

- [x] **Audio Data**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**
  - 수집 이유: 음성 입력(Speech-to-Text) 원문 오디오 → 변환 edge function

- [x] **Other User Content**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**, **Product Personalization**
  - 수집 이유: AI 캐릭터 챗 대화 내용, 생년월일/생시/생지 (사주), 서베이 답변

### Purchases
- [x] **Purchase History**
  - Linked to You: **Yes**
  - Used for Tracking: **No**
  - Purposes: **App Functionality**
  - 수집 이유: expo-iap 구독 상태 (프리미엄/토큰)

---

## ❌ 수집 안 하는 것 (명시적 No 선택)

- [ ] Health & Fitness → **No** (P10-B5로 의료 vitals 제거됨. 걸음/수면은 "Other User Content" 범주에 들어가지만, Apple Health API 직접 읽지 않으므로 답변에는 No)
  - **주의**: 만약 향후 HealthKit 연동 재도입 시 이 답변 Yes로 변경 + `NSPrivacyCollectedDataTypeHealth` 추가 필수
- [ ] Financial Info → No
- [ ] Location (Precise/Coarse) → No
- [ ] Sensitive Info → No (생년월일은 Apple 분류상 Sensitive 아님)
- [ ] Contacts → No
- [ ] Emails or Text Messages → No (채팅은 AI 대화로 User Content에 속함)
- [ ] Browsing History → No
- [ ] Search History → No
- [ ] Gameplay Content → No
- [ ] Customer Support → No
- [ ] Advertising Data → No
- [ ] Other Data Types → No

---

## 검증 체크리스트 (제출 전)

- [ ] ASC App Privacy 페이지 열기
- [ ] 위 11개 카테고리 1:1 체크 후 각 linked/tracking/purposes 세팅
- [ ] `app.config.ts` `ios.privacyManifests.NSPrivacyCollectedDataTypes` 배열 11개 항목과 일치
- [ ] Apple `PrivacyInfo.xcprivacy`가 빌드 산출물에 포함되는지 확인 (EAS build 로그 "Copying PrivacyInfo.xcprivacy" 라인)
- [ ] 변경 저장 후 "Publish" 버튼 클릭 (단순 저장은 다음 빌드에 미반영)

## 불일치 사례 (과거 리젝 트리거)

- ASC에서 "No location collected" 인데 앱 바이너리 스캔이 Location API 호출 감지 → 리젝
- ASC는 "Email collected"인데 Privacy Manifest는 비어있음 → 리젝
- Purpose에 "Third-Party Advertising" 있는데 ATT 프롬프트 미구현 → 리젝 (이 앱은 광고 미사용이라 해당 없음)
