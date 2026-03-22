# ZPZG Apple Guidelines Full Audit

작성일: 2026-03-22  
기준 버전: iOS 앱 심사 대상 `1.0.7`  
기준 문서:
- App Store Review Guidelines: https://developer.apple.com/kr/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

## 1. Overall Verdict

- 현재 ZPZG는 `핵심 채팅 사용 가능`, `계정 삭제 제공`, `푸시 권한 런치 자동 요청 제거`, `ATT 제거`, `Apple 로그인 제공`, `공개 정책 URL 가동`까지는 정리되어 있습니다.
- 다만 `결제 정책 문구`, `메타데이터/인앱 정책 불일치`, `제3자 AI 공개 부족`, `최근 App Review 네트워크 오류 후속 검증`, `Live Activities 선언 대비 실제 사용 증거 부족` 때문에 지금 상태를 `즉시 재제출 가능한 완전 승인 상태`로 보기는 어렵습니다.
- 결론: `NO-GO`. 아래 `Highest-Risk Rejection Candidates`와 `TODO`를 먼저 닫아야 합니다.

## 2. Highest-Risk Rejection Candidates

- [ ] `3.1.1` 토큰형 IAP 만료 금지 위반 가능성: 앱 내 약관이 `구매한 토큰의 유효기간은 구매일로부터 1년`이라고 명시합니다. 근거: `lib/core/constants/in_app_products.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`. TODO: 토큰 만료 문구 제거, 서버/고객지원/스토어 문구 전부 동기화.
- [ ] `2.3.12` 새로운 기능/버전 설명 불일치: release notes가 아직 `버전 1.0.0 (빌드 4) - 테스터 빌드`입니다. 근거: `ios/fastlane/metadata/ko/release_notes.txt`. TODO: 현재 제출 버전 기준 KR/EN release notes 재작성.
- [ ] `2.3.1`, `5.1.1(i)` 메타데이터/정책 불일치: App Store 메타데이터는 `AI 친구`인데, 인앱 정책 페이지는 아직 `Fortune`, `신점 기반 운세`, 시행일 `2025-01-01`로 남아 있습니다. 근거: `ios/fastlane/metadata/ko/description.txt`, `ios/fastlane/metadata/en-US/description.txt`, `lib/features/policy/presentation/pages/privacy_policy_page.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`, `public/privacy.html`, `public/terms.html`. TODO: 인앱 정책 페이지를 공개 정책과 1:1 동기화.
- [ ] `5.1.2(i)` 제3자 AI 공개 부족: 실제 서비스는 Edge Functions에서 Gemini/OpenAI/Anthropic/Grok 계열 LLM을 사용하지만, 공개 개인정보처리방침에는 Supabase/Firebase/App Store/Google Play만 명시되어 있습니다. 근거: `supabase/functions/_shared/llm/factory.ts`, `supabase/functions/_shared/llm/providers/*.ts`, `supabase/functions/character-chat/index.ts`, `public/privacy.html`. TODO: 개인정보처리방침과 동의 문구에 제3자 AI 처리 구조를 반영.
- [ ] `2.1(a)` 앱 완전성: Apple이 2026-03-21에 `Network connection error`로 실제 거절했고, iOS 수동 증빙도 아직 open이 남아 있습니다. 근거: App Review rejection message, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`. TODO: 리뷰 디바이스 동선 기준 실기기 재검증 영상/로그 확보 후 재제출.
- [ ] `2.1(a)`, `2.4.1` 유니버설 링크/딥링크 준비 부족: `apple-app-site-association`는 배포돼 있지만 현재 iOS entitlements에는 `com.apple.developer.associated-domains`가 없습니다. 근거: `https://zpzg.co.kr/.well-known/apple-app-site-association`, `ios/Runner/Runner.entitlements`. TODO: 실제 앱 경험에 유니버설 링크가 필요하다면 entitlement 추가 후 실기기 검증, 필요 없다면 review evidence와 메타데이터에서 기대치를 낮추기.
- [ ] `2.5.16`, `2.5.4` Live Activities/백그라운드 선언 과다 가능성: Live Activity entitlement와 frequent updates는 선언되어 있으나 실제 Dart 호출 경로가 보이지 않습니다. 근거: `ios/Runner/Info.plist`, `ios/Runner/NativePlatformPlugin.swift`, `lib/services/native_platform_service.dart`. TODO: 실제 shipped feature로 쓰지 않으면 entitlement 제거.
- [ ] `1.4.1`, `5.1.1(ix)` 건강/의료 오해 위험: 건강 운세, 건강 문서 분석, 건강 지표 서술이 repo 전반에 남아 있습니다. 공개 메타데이터에는 완화 문구가 있으나 실제 노출 범위를 더 보수적으로 정리해야 합니다. 근거: `supabase/functions/fortune-health/index.ts`, `supabase/functions/fortune-health-document/index.ts`, `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart`, `lib/services/health_data_service.dart`, `public/terms.html`. TODO: 의료 오해 가능 표현과 배포 노출 범위 재점검.

## 3. Audit Basis

- 기존 증거 문서:
  - `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`
  - `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`
  - `docs/deployment/APP_STORE_SUBMISSION_INFO.md`
- iOS 런타임/메타데이터:
  - `ios/Runner/Info.plist`
  - `ios/Runner/PrivacyInfo.xcprivacy`
  - `ios/Runner/Runner.entitlements`
  - `ios/fastlane/Deliverfile`
  - `ios/fastlane/metadata/*`
- 실제 앱 표면 기준:
  - `docs/getting-started/PROJECT_OVERVIEW.md`
  - `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
  - `lib/routes/route_config.dart`
- 공개 정책/지원 페이지:
  - `public/privacy.html`
  - `public/terms.html`
  - `public/support.html`
- 2026-03-22 live URL 확인:
  - `https://zpzg.co.kr/privacy` -> HTTP 200
  - `https://zpzg.co.kr/terms` -> HTTP 200
  - `https://zpzg.co.kr/support` -> HTTP 200
  - `https://zpzg.co.kr/.well-known/apple-app-site-association` -> HTTP 200 / `application/json`

판정 표기:
- `- [x] ~~완료~~`
- `- [ ] 미완료/개선 필요`
- `- [ ] 수동 검증 필요`
- `- [ ] N/A - 사유`

## 4. Full Apple Checklist

### A. 서론 / 제출하기 전에

- [x] ~~PRE-001 리뷰 계정, 연락처, 심사 메모 제공: `ios/fastlane/Deliverfile`와 `ios/fastlane/metadata/review_information/*`에 연락처와 데모 계정이 모두 존재합니다.~~
- [x] ~~PRE-002 공개 정책 URL 가동: Privacy/Terms/Support URL이 200으로 응답합니다. 근거: `public/privacy.html`, `public/terms.html`, `public/support.html`, 2026-03-22 curl 확인.~~
- [ ] PRE-003 제출 전 기기/백엔드 완전성: Apple이 2026-03-21 실제 심사에서 네트워크 오류를 재현했습니다. 근거: rejection message, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`. TODO: 리뷰 동선 기준 실기기 재검증과 재현 불가 증빙 확보.
- [ ] PRE-004 실기기 수동 증빙 미종결: IAP 성공/취소/복원, 캘린더 권한, 유니버설 링크가 아직 open이며 현재 entitlements에도 Associated Domains가 없습니다. 근거: `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`, `ios/Runner/Runner.entitlements`. TODO: open row 전부 pass로 전환하고 유니버설 링크 필요 여부를 코드/메타데이터와 일치시키기.

### 1. 안전성

- [ ] 1.1 부적절한 콘텐츠 전반: 공개 메타데이터는 안전하지만 AI 캐릭터/운세 응답의 유해 발화 차단 기준이 심사 근거 문서에 명시되어 있지 않습니다. 근거: `ios/fastlane/metadata/*`, `supabase/functions/character-chat/index.ts`. TODO: 금칙 주제/민감 응답 가드와 리뷰 메모 보강.
- [ ] 수동 검증 필요 - 1.1.1 차별/악의적 콘텐츠: 공개 페이지에는 직접 증거가 없지만 AI 채팅 출력에 대한 차별/혐오 발화 회피 검증 로그가 없습니다. 근거: `supabase/functions/character-chat/index.ts`. TODO: 금칙 사례 테스트 세트 작성.
- [ ] N/A - 1.1.2 현실적 폭력 묘사: 현재 공개 메타데이터와 핵심 표면에서 폭력 중심 기능 증거는 없습니다.
- [ ] N/A - 1.1.3 무기/위험물 조장: 현재 앱 표면상 관련 기능이 없습니다.
- [ ] 수동 검증 필요 - 1.1.4 성적/포르노/만남 주선: 캐릭터 채팅 성격상 심사자가 성인 대화로 오해할 수 있어 private chat prompt safety 검증이 필요합니다. 근거: `lib/features/character/presentation/pages/character_chat_panel.dart`, `supabase/functions/character-chat/index.ts`.
- [ ] 수동 검증 필요 - 1.1.5 선동적 종교 해설: 운세/사주 문맥이 있어 종교/미신 오해를 최소화하는 톤 점검이 필요합니다. 근거: `public/terms.html`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`.
- [ ] N/A - 1.1.6 속임수/장난 기능: 가짜 위치 추적기, 장난 전화/SMS류 기능은 없습니다.
- [ ] N/A - 1.1.7 시사 비극 악용: 현재 앱 표면상 관련 기능이 없습니다.

- [ ] N/A - 1.2 사용자가 생성한 공개 콘텐츠: 현재 ZPZG는 공개 피드/랜덤 채팅/UGC 마켓플레이스가 아니라 1:1 AI 대화 중심이므로 본 조항 핵심 적용 대상이 아닙니다. 근거: `docs/getting-started/APP_SURFACES_AND_ROUTES.md`.
- [ ] N/A - 1.2.1 크리에이터 콘텐츠: 사용자 제작 미니앱/콘텐츠 마켓 구조가 없습니다.
- [ ] N/A - 1.3 어린이 카테고리: 어린이 카테고리 앱이 아니며 메타데이터도 해당 포지셔닝을 사용하지 않습니다. 근거: `ios/fastlane/metadata/*`, `ios/fastlane/Deliverfile`.

- [ ] 1.4.1 신체적 부상/의료 오해: 공개 설명에는 비의료 고지가 있지만, repo에는 건강 운세와 건강 문서 분석 기능이 남아 있어 의료적 해석으로 오해될 수 있습니다. 근거: `ios/fastlane/metadata/ko/description.txt`, `public/terms.html`, `supabase/functions/fortune-health/index.ts`, `supabase/functions/fortune-health-document/index.ts`, `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart`. TODO: 의료/진단처럼 읽히는 문구 제거 또는 비노출 보장.
- [ ] N/A - 1.4.2 약물 투여 계산기: 해당 기능이 없습니다.
- [ ] N/A - 1.4.3 담배/불법 약물 조장: 해당 기능이 없습니다.
- [ ] N/A - 1.4.4 DUI/무모 운전 조장: 해당 기능이 없습니다.
- [ ] N/A - 1.4.5 신체적 위험 행동 유도: 해당 기능이 없습니다.

- [x] ~~1.5 개발자 정보: 지원 URL과 연락 이메일이 공개 페이지와 App Review metadata에 존재합니다. 근거: `public/support.html`, `ios/fastlane/Deliverfile`, `ios/fastlane/metadata/*/support_url.txt`.~~
- [x] ~~1.6 데이터 보안: ATS는 `NSAllowsArbitraryLoads=false`, 추적은 꺼져 있고 앱 그룹/보안 저장소를 사용합니다. 근거: `ios/Runner/Info.plist`, `ios/Runner/PrivacyInfo.xcprivacy`, `lib/services/account_deletion_service.dart`.~~
- [ ] N/A - 1.7 범죄 행위 신고 앱: 범죄 신고 앱이 아닙니다.

### 2. 성능

- [ ] 2.1(a) 앱 완전성: 최근 App Review 거절 이력이 있고, 수동 체크리스트상 IAP/캘린더/유니버설링크 증빙이 남아 있습니다. 근거: rejection message, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`. TODO: 심사 동선 기준 재검증 후 증빙 첨부.
- [ ] 2.1(b) 앱 내 구입 완전성: 구매 성공/취소/복원은 코드 경로는 있으나 실기기 end-to-end 증빙이 없습니다. 근거: `lib/services/in_app_purchase_service.dart`, `lib/screens/profile/profile_screen.dart`, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`. TODO: 샌드박스/실기기 영상과 로그 확보.
- [x] ~~2.2 베타 테스트 금지: 공개 메타데이터 설명은 정식 사용자용이지만, 테스트성 문구는 release notes에만 남아 있습니다. 바이너리 자체가 베타 앱으로 포지셔닝되지는 않습니다. 근거: `ios/fastlane/metadata/*/description.txt`.~~

- [ ] 2.3 정확한 메타데이터 전반: App Store 메타데이터는 `AI friend` 중심인데 인앱 정책/런타임/공개 페이지에는 여전히 `Fortune`, `운세`, `토큰`, `구독`이 강하게 남아 있습니다. 근거: `ios/fastlane/metadata/*`, `public/privacy.html`, `public/terms.html`, `lib/features/policy/presentation/pages/*.dart`, `docs/getting-started/PROJECT_OVERVIEW.md`. TODO: 스토어 포지셔닝과 실제 앱 표면을 하나로 맞추기.
- [ ] 2.3.1 숨김/비활성/미문서화 기능 금지: Live Activities 선언, Siri shortcut identifier, legacy fortune/premium 문맥이 남아 있으나 현재 active route inventory에는 명확히 설명되지 않습니다. 근거: `ios/Runner/Info.plist`, `lib/services/native_platform_service.dart`, `docs/getting-started/APP_SURFACES_AND_ROUTES.md`. TODO: 미출시 기능 선언 제거 또는 심사 메모에 명시.
- [ ] 2.3.2 IAP 홍보 정확성: 메타데이터는 프리미엄 멤버십을 강조하지만 현재 repo상 명시적 paywall 표면과 가격/혜택 검증 증거가 약합니다. 근거: `ios/fastlane/metadata/*/description.txt`, `lib/core/constants/in_app_products.dart`, `lib/screens/profile/profile_screen.dart`. TODO: 실제 노출 상품 화면과 메타데이터 문구를 대조.
- [ ] 수동 검증 필요 - 2.3.3 스크린샷 정확성: `Snapfile`은 있으나 `ios/fastlane/screenshots` 산출물은 repo에 없습니다. TODO: 제출 스크린샷 세트 최신 여부 확인. 근거: `ios/fastlane/Snapfile`.
- [ ] 수동 검증 필요 - 2.3.4 미리보기 정확성: 저장소에서 현재 App Preview 원본을 확인할 수 없습니다. TODO: App Store Connect 미리보기 영상 점검.
- [x] ~~2.3.5 카테고리 적합성: 현재 메타데이터의 `Lifestyle` + `Entertainment` 조합은 AI companion + lifestyle insights 포지셔닝과 대체로 부합합니다. 근거: `ios/fastlane/Deliverfile`, `ios/fastlane/metadata/*/description.txt`.~~
- [x] ~~2.3.6 연령 등급 질문 정합성: App Store Connect age rating/questionnaire는 2026-03-20 기준 검증 완료 증거가 있습니다. 근거: `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`.~~
- [x] ~~2.3.7 이름/키워드 적합성: 현재 KR/EN 이름·부제목·키워드는 스팸성 키워드 나열 없이 `AI friend` 포지셔닝을 따릅니다. 근거: `ios/fastlane/metadata/ko/name.txt`, `ios/fastlane/metadata/ko/subtitle.txt`, `ios/fastlane/metadata/ko/keywords.txt`, `ios/fastlane/metadata/en-US/*`.~~
- [x] ~~2.3.8 메타데이터의 전체 연령 적합성: 현재 설명/키워드에는 노골적 성인 표현이나 충격적 이미지를 요구하는 문구가 없습니다. 근거: `ios/fastlane/metadata/*/description.txt`, `ios/fastlane/metadata/app_rating_config.json`.~~
- [ ] 수동 검증 필요 - 2.3.9 스크린샷/미리보기 자료 권리: 스토어 시각 자산 원본과 권리 검증 자료가 저장소에 없습니다. TODO: 제출 자산 원본과 권리 보유 여부 확인.
- [x] ~~2.3.10 다른 플랫폼/마켓플레이스 언급 금지: 앱 메타데이터에 외부 앱 마켓플레이스 홍보는 없습니다.~~
- [ ] N/A - 2.3.11 사전 주문 앱: 현재 사전 주문 제출 문맥이 아닙니다.
- [ ] 2.3.12 새로운 기능 설명 최신화: 현재 KR release notes가 `버전 1.0.0 (빌드 4) - 테스터 빌드`로 남아 있어 제출 버전과 맞지 않습니다. 근거: `ios/fastlane/metadata/ko/release_notes.txt`. TODO: 현재 버전 기준으로 KR/EN release notes 재작성.
- [ ] N/A - 2.3.13 앱 내 이벤트: App Store in-app event 제출 증거가 없습니다.

- [ ] 수동 검증 필요 - 2.4.1 iPhone 앱의 iPad 동작: Snapfile과 review notes는 iPad를 고려하지만 현재 실기기/iPad QA 결과가 문서화되어 있지 않습니다. 근거: `ios/fastlane/Snapfile`, `ios/fastlane/Deliverfile`. TODO: iPad UI/로그인/권한/결제 동선 검증.
- [ ] 2.4.2 배터리/열/리소스 사용: 위젯 background refresh + processing + Live Activities frequent updates를 모두 선언했지만 실제 shipped usage justification이 부족합니다. 근거: `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `lib/services/widget_service.dart`. TODO: 사용하지 않는 capability 제거, 남길 것은 리뷰 메모에 이유 명시.
- [ ] N/A - 2.4.3 Apple TV/게임 컨트롤러: tvOS 앱이 아닙니다.
- [x] ~~2.4.4 시스템 설정 변경 강요 금지: Wi-Fi/보안 해제 같은 시스템 설정 변경 요구 증거는 없습니다.~~
- [ ] N/A - 2.4.5 Mac App Store 추가 요구사항: macOS App Store 심사 항목이 아닙니다.

- [x] ~~2.5.1 공개 API 사용: Flutter/Supabase/StoreKit/WidgetKit 등 공개 API 기반이며 private API 사용 증거는 찾지 못했습니다. 근거: `ios/Runner/Info.plist`, `lib/services/in_app_purchase_service.dart`, `lib/services/widget_service.dart`.~~
- [x] ~~2.5.2 번들 독립성/코드 다운로드 금지: 실행 코드를 원격 다운로드해 기능을 바꾸는 구조 증거는 없습니다.~~
- [x] ~~2.5.3 시스템 훼손 코드 금지: 악성코드/푸시 악용/OS 훼손 코드 증거는 없습니다.~~
- [ ] 2.5.4 백그라운드 모드 목적 적합성: `fetch`, `remote-notification`, `processing`을 모두 선언했으므로 실제 필요한 목적과 리뷰 설명을 더 명확히 맞춰야 합니다. 근거: `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `lib/services/notification/fcm_service.dart`. TODO: background mode justification 정리.
- [ ] 수동 검증 필요 - 2.5.5 IPv6 전용 네트워크: 코드에는 iOS 26/IPv6/NAT64 대응 재시도/타임아웃 보강이 있으나 실네트워크 검증 기록이 없습니다. 근거: `lib/services/social_auth/providers/apple_auth_provider.dart`, `lib/services/oauth_in_app_browser_coordinator.dart`. TODO: IPv6-only/NAT64 실기기 테스트.
- [ ] N/A - 2.5.6 대체 브라우저 엔진: 웹 브라우저 엔진 앱이 아닙니다.
- [ ] N/A - 2.5.8 대체 홈 화면 환경: 해당 기능이 없습니다.
- [x] ~~2.5.9 표준 스위치/UI 변경 금지: 볼륨/무음 스위치/기본 UI를 가로채는 기능 증거는 없습니다.~~
- [ ] N/A - 2.5.11 SiriKit/단축어: Info.plist에 user activity types는 있으나 현재 shipped user flow에서 실제 shortcut 사용 경로가 명확하지 않습니다. 필요 시 2.3.1 정리 항목으로 흡수합니다.
- [ ] N/A - 2.5.12 CallKit/SMS 차단: 관련 기능이 없습니다.
- [ ] N/A - 2.5.13 안면 인식 인증: 얼굴 분석은 콘텐츠 기능이지 계정 인증이 아닙니다.
- [ ] 2.5.14 카메라/마이크/화면 입력에 대한 명시적 동의: 카메라/사진/마이크/음성 인식 권한 키는 있고 런타임 요청도 기능 실행 시점 기준이지만, 실기기 timing capture는 아직 미완료입니다. 근거: `ios/Runner/Info.plist`, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `lib/features/chat/presentation/widgets/survey/chat_face_reading_flow.dart`, `lib/services/notification/fcm_service.dart`. TODO: 권한 노출 타이밍 증빙 확보.
- [ ] N/A - 2.5.15 파일 앱 연동: 문서 파일 브라우저 앱이 아닙니다.
- [ ] 2.5.16 위젯/확장/알림 관련성: 홈 위젯은 앱 기능과 관련 있지만, Live Activity는 선언만 있고 실제 호출 경로가 보이지 않습니다. 근거: `lib/services/widget_service.dart`, `lib/presentation/providers/auth_provider.dart`, `lib/services/native_platform_service.dart`, `ios/Runner/NativePlatformPlugin.swift`. TODO: unused Live Activity capability 제거 또는 UI 연결.
- [ ] N/A - 2.5.17 Matter: 관련 기능이 없습니다.
- [x] ~~2.5.18 광고 제약: 현재 앱과 확장에 광고 SDK/광고 UI 증거가 없습니다.~~

### 3. 비즈니스

- [ ] 3.1.1 앱 내 구입 사용: IAP 구조 자체는 갖춰져 있으나, 앱 내 약관의 `토큰 1년 유효기간` 문구가 Apple의 토큰/크레딧 만료 금지와 충돌합니다. 근거: `lib/core/constants/in_app_products.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`. TODO: 만료 문구 제거, 환불/복원 안내도 스토어 정책 기준으로 정리.
- [x] ~~3.1.1 앱 내 구입 복원 메커니즘 존재: 프로필 화면에서 `구매 복원 / Restore Purchases`와 `구독 관리 / Manage Subscriptions` 진입점이 존재합니다. 근거: `lib/screens/profile/profile_screen.dart`, `lib/services/in_app_purchase_service.dart`.~~
- [ ] 3.1.1(a) 외부 결제 유도 금지: 현재 앱 내 외부 결제 CTA 증거는 없지만, 공개/인앱 약관 문구가 서로 달라 환불/결제 정책 해석이 흔들릴 수 있습니다. 근거: `public/terms.html`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`. TODO: 결제 정책 문구 단일화.
- [x] ~~3.1.2(a) 자동 갱신 구독 허용 범위: 구독은 토큰 충전 + 프리미엄 인사이트 접근으로 설명되고 있어 형태상 허용 범위에 들어갑니다. 근거: `lib/core/constants/in_app_products.dart`, `ios/fastlane/metadata/*/description.txt`.~~
- [ ] 수동 검증 필요 - 3.1.2(b) 업그레이드/다운그레이드: Pro/Max 구독의 실제 업/다운그레이드 UX 검증 증거가 없습니다. 근거: `lib/core/constants/in_app_products.dart`. TODO: 샌드박스 구독 변경 동선 검증.
- [ ] 3.1.2(c) 구독 정보 명확성: 메타데이터에는 혜택 요약이 있으나, 현재 repo에서 심사자가 곧바로 확인할 paywall/상품 상세 화면 근거가 부족합니다. 근거: `ios/fastlane/metadata/*/description.txt`, `lib/core/constants/in_app_products.dart`. TODO: 실제 상품 화면과 설명 문구 1:1 대조.
- [x] ~~3.1.3 기타 구입 방식 금지: 현재 앱 내 외부 구매 버튼/웹 결제 유도 코드 증거는 없습니다.~~
- [ ] N/A - 3.1.3(a) 읽기 도구 앱: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.3(b) 멀티 플랫폼 서비스: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.3(c) 기업 서비스: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.3(d) 개인 간 실시간 서비스 결제: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.3(e) 앱 외부 상품/서비스 결제: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.3(f) 무료 독립형 파트너 앱: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.3(g) 광고 관리 앱: 해당 앱이 아닙니다.
- [ ] N/A - 3.1.4 하드웨어 기반 콘텐츠: 해당 모델이 아닙니다.
- [ ] N/A - 3.1.5 암호 화폐: 관련 기능이 없습니다.

- [x] ~~3.2.2(x) 평점/리뷰/타 앱 다운로드 강요 금지: 저장소에서 강제 리뷰 요청이나 기능 해금용 리뷰 유도 코드를 찾지 못했습니다.~~
- [x] ~~3.2 기타 비즈니스 금지사항 전반: 도박/대출/기부/광고노출 조작/위치 임의 제한 기능 증거는 현재 없습니다.~~

### 4. 디자인

- [x] ~~4.1 모방 금지: 현재 앱은 AI 캐릭터 DM + 호기심/운세 전문가 구조로 단순 클론 증거는 없습니다. 근거: `docs/getting-started/PROJECT_OVERVIEW.md`, `docs/getting-started/APP_SURFACES_AND_ROUTES.md`.~~
- [x] ~~4.2 최소 기능: `/chat` 메인 표면, 캐릭터 대화, Face AI, 인사이트, 정책/계정 관리 등으로 최소 기능 미달 앱은 아닙니다.~~
- [x] ~~4.2.2 마케팅 자료/링크 모음 앱 금지: 앱의 핵심은 대화/인사이트 생성 기능이며 링크 모음 앱이 아닙니다.~~
- [x] ~~4.2.3(i) 독립 실행 가능: 다른 앱 설치 없이 핵심 채팅은 게스트 모드로 동작합니다. 근거: `lib/screens/splash_screen.dart`, `lib/services/storage_service.dart`.~~
- [ ] 수동 검증 필요 - 4.2.3(ii) 초기 실행 추가 리소스 다운로드: 현재 출시 번들에서 필수 원격 자산/모델 의존성이 사용자에게 명확히 고지되는지 증거가 없습니다. TODO: 초기 다운로드 requirement 재검토.
- [x] ~~4.2.6 템플릿 앱 금지: 템플릿 생성 앱 증거는 없습니다.~~
- [ ] N/A - 4.2.7 원격 데스크톱: 해당 앱이 아닙니다.

- [ ] 4.3 스팸: Apple이 운세 카테고리를 명시적으로 포화 카테고리로 언급하는데, 현재 앱은 차별화 포인트가 `AI companion + 캐릭터 채팅`이면서도 코드/정책/공개 페이지에는 여전히 `fortune` 잔존이 많습니다. 근거: `docs/getting-started/PROJECT_OVERVIEW.md`, `public/privacy.html`, `public/terms.html`, `lib/features/character/data/fortune_characters.dart`, `lib/services/widget_service.dart`, `ios/Runner/Info.plist`. TODO: 스토어/런타임/정책 포지셔닝 통일.

- [ ] 4.4 확장 프로그램: 위젯은 관련성이 있지만 Live Activity와 Siri shortcut 관련 선언은 실제 shipped UX와의 연결이 약합니다. 근거: `lib/services/widget_service.dart`, `lib/services/native_platform_service.dart`, `ios/Runner/Info.plist`, `ios/Runner/NativePlatformPlugin.swift`. TODO: 쓰지 않는 확장 선언 제거.
- [ ] N/A - 4.4.1 키보드 확장: 해당 기능이 없습니다.
- [ ] N/A - 4.4.2 Safari 확장: 해당 기능이 없습니다.

- [x] ~~4.5.1 Apple 사이트/서비스 스크레이핑 금지: Apple 사이트 스크레이핑이나 순위 생성 기능 증거는 없습니다.~~
- [ ] N/A - 4.5.2 Apple Music: 해당 기능이 없습니다.
- [x] ~~4.5.3 Apple 서비스 남용 금지: Game Center/푸시/Apple 서비스 남용 증거는 없습니다.~~
- [x] ~~4.5.4 푸시 알림: 런치 시 자동 권한 요청을 제거했고, 설정 화면에서만 opt-in하도록 정리되어 있습니다. 근거: `lib/main.dart`, `lib/services/notification/fcm_service.dart`, `lib/features/notification/presentation/pages/notification_settings_page.dart`, `ios/fastlane/metadata/review_information/review_notes.txt`.~~
- [ ] N/A - 4.5.5 Game Center 플레이어 ID: Game Center 기능이 없습니다.
- [x] ~~4.5.6 Apple 이모티콘/메타데이터 사용: Apple 제품 사칭이나 이모티콘 임베드 남용 증거는 없습니다.~~

- [ ] N/A - 4.7 미니앱/스트리밍게임/챗봇 플랫폼: 외부 소프트웨어 마켓플레이스 구조가 아닙니다.
- [x] ~~4.8 로그인 서비스: 기본 계정 인증에 Google 로그인을 제공하면서 Apple 로그인을 동등 옵션으로 제공합니다. 근거: `lib/presentation/widgets/social_login_bottom_sheet.dart`, `ios/Runner/Runner.entitlements`.~~
- [ ] 4.8 메타데이터 정확성 보조 리스크: 메타데이터는 카카오/네이버 로그인 지원을 말하지만, 현재 기본 로그인 바텀시트는 Google/Apple만 노출합니다. 근거: `ios/fastlane/metadata/ko/description.txt`, `lib/presentation/widgets/social_login_bottom_sheet.dart`. TODO: 문구 또는 실제 노출 경로 정리.
- [ ] N/A - 4.9 Apple Pay: Apple Pay 결제 구조가 아닙니다.
- [x] ~~4.10 내장 기능 상품화 금지: 카메라/마이크/푸시 자체를 유료로 파는 구조 증거는 없습니다.~~

### 5. 법적 요구 사항

- [ ] 5.1.1(i) 개인정보처리방침 링크와 내용 최신성: 링크 자체는 존재하지만 인앱 정책 페이지가 공개 정책과 다르고, 시행일과 브랜드가 오래됐습니다. 근거: `ios/fastlane/metadata/*/privacy_url.txt`, `public/privacy.html`, `lib/features/policy/presentation/pages/privacy_policy_page.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`. TODO: 인앱 정책 페이지를 공개 정책과 동일한 최신본으로 교체.
- [x] ~~5.1.1(ii) 데이터 수집 허가: 카메라/사진/마이크/음성/위치 권한은 목적 문자열이 있고 기능 실행 시점 요청 구조입니다. 근거: `ios/Runner/Info.plist`, `lib/features/chat/presentation/widgets/survey/chat_face_reading_flow.dart`, `lib/services/notification/fcm_service.dart`.~~
- [ ] 5.1.1(iii) 데이터 최소화: `NSCalendarsFullAccessUsageDescription` 선언은 현재 설명상 필요한 범위보다 넓어 보입니다. 근거: `ios/Runner/Info.plist`, `public/privacy.html`, `docs/deployment/APP_STORE_SUBMISSION_INFO.md`. TODO: full access 필요성 재평가 또는 축소.
- [x] ~~5.1.1(iv) 접근 강요 금지: 핵심 채팅은 비로그인 게스트 모드로 사용 가능하고, 선택 권한 거부 시 다른 핵심 기능 사용을 막지 않는 방향으로 설계돼 있습니다. 근거: `lib/screens/splash_screen.dart`, `public/privacy.html`.~~
- [x] ~~5.1.1(v) 로그인 비강제 + 인앱 계정 삭제: 비로그인 사용이 가능하고, 로그인 사용자는 앱 내에서 회원 탈퇴를 직접 진행할 수 있습니다. 근거: `lib/screens/splash_screen.dart`, `lib/screens/profile/account_deletion_page.dart`, `lib/services/account_deletion_service.dart`.~~
- [x] ~~5.1.1(v) 소셜 자격 증명 철회 메커니즘: 연결된 소셜 계정을 해제하는 UI가 있습니다. 근거: `lib/presentation/widgets/social_accounts_section.dart`.~~
- [ ] N/A - 5.1.1(vii) SafariViewController 숨김 금지: 해당 방식 사용 증거를 찾지 못했습니다.
- [x] ~~5.1.1(viii) 공개 DB에서 개인정보 수집 금지: 그런 기능 증거는 없습니다.~~
- [ ] 5.1.1(ix) 규제/민감 서비스는 법인 제출 필요: 건강 운세/건강 문서 분석 등 민감 영역 흔적이 남아 있어 실제 배포 노출 범위를 더 보수적으로 정리해야 합니다. 근거: `supabase/functions/fortune-health-document/index.ts`, `supabase/functions/fortune-health/index.ts`, `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart`. TODO: 민감 기능 비노출 보장 또는 법적/제품 포지셔닝 정리.
- [x] ~~5.1.1(x) 기본 연락처 정보 선택성: 이메일 등 계정 정보는 회원가입 시점에만 요구되며 게스트 사용 경로가 존재합니다.~~

- [ ] 5.1.2(i) 데이터 사용/공유 공개: 개인정보처리방침이 실제 제3자 AI 제공자 공유를 설명하지 않습니다. 근거: `public/privacy.html`, `supabase/functions/_shared/llm/factory.ts`, `supabase/functions/_shared/llm/providers/*.ts`. TODO: AI provider disclosure와 동의 구조 정리.
- [x] ~~5.1.2(ii) 목적 외 사용 금지: 현재 공개 정책은 계정/분석/결제/인사이트 제공 목적까지만 설명합니다. 별도 위반 증거는 찾지 못했습니다.~~
- [x] ~~5.1.2(iii) 비밀 프로파일링 금지: ATT/IDFA가 제거되어 있고 추적은 false입니다. 근거: `ios/Runner/PrivacyInfo.xcprivacy`.~~
- [x] ~~5.1.2(iv) 연락처/설치 앱 목록 수집 금지: 연락처 수집 및 앱 목록 수집 기능 증거는 없습니다.~~
- [ ] N/A - 5.1.2(v) 연락처를 통한 타인 접촉: 해당 기능이 없습니다.
- [x] ~~5.1.2(vi) HealthKit/얼굴 매핑 데이터 광고 금지: HealthKit 연동은 비활성화되어 있고, 얼굴/사진 데이터 광고 타기팅 증거는 없습니다. 근거: `lib/services/health_data_service.dart`, `ios/Runner/PrivacyInfo.xcprivacy`.~~
- [ ] N/A - 5.1.2(vii) Apple Pay 데이터 공유: Apple Pay 기능이 없습니다.

- [ ] N/A - 5.1.3 건강/보건 연구: HealthKit/Clinical/ResearchKit 연구 앱은 아니며, 관련 플랫폼 연동은 현재 비활성화 상태입니다. 근거: `lib/services/health_data_service.dart`. 단, 의료 오해 위험은 `1.4.1`, `5.1.1(ix)`에서 별도 관리합니다.
- [ ] N/A - 5.1.4 어린이 개인정보: 어린이 카테고리 앱이 아닙니다.
- [x] ~~5.1.5 위치 서비스: iOS는 `when in use`만 선언하고 공개 정책도 위치 목적을 기능 한정으로 설명합니다. 근거: `ios/Runner/Info.plist`, `public/privacy.html`, `docs/deployment/APP_STORE_SUBMISSION_INFO.md`.~~

- [x] ~~5.2.1 일반 IP: 타사 상표/앱명 도용 증거는 없습니다.~~
- [ ] 수동 검증 필요 - 5.2.2 타사 사이트/서비스 콘텐츠 사용 허가: 소셜 로그인/AI provider/celebrity 관련 자산 사용 범위는 최종 제출 전 라이선스/약관 확인이 필요합니다. 근거: `lib/services/social_auth/providers/*.dart`, `lib/features/fortune/presentation/widgets/face_reading/celebrity_match_carousel.dart`.
- [ ] N/A - 5.2.3 오디오/비디오 다운로드: 관련 기능이 없습니다.
- [x] ~~5.2.4 Apple 추천 오인 금지: Apple이 앱을 보증한다는 표현 증거는 없습니다.~~
- [x] ~~5.2.5 Apple 제품/인터페이스 혼동 금지: App Store/메시지 등 Apple 제품을 사칭하는 UI 증거는 없습니다.~~

- [ ] N/A - 5.3 도박/복권: 해당 기능이 없습니다.
- [ ] N/A - 5.4 VPN: 해당 기능이 없습니다.
- [ ] N/A - 5.5 MDM: 해당 기능이 없습니다.

- [x] ~~5.6.1 App Store 리뷰 요청: 강제 리뷰 유도/보상형 리뷰 요청 코드 증거를 찾지 못했습니다.~~
- [ ] 5.6.2 개발자 신원 정확성: App Store 메타데이터와 공개 지원 채널은 유효하지만, 인앱 정책 페이지의 `Fortune` 레거시 표기가 현재 ZPZG 신원과 맞지 않습니다. 근거: `public/privacy.html`, `public/terms.html`, `lib/features/policy/presentation/pages/*.dart`. TODO: 브랜드 통일.
- [ ] N/A - 5.6.3 둘러보기 사기: 저장소 차원에서 판단할 근거가 없습니다.
- [ ] 5.6.4 앱 품질: 최근 App Review 거절과 open manual blocker가 남아 있어 품질 위험이 완전히 해소됐다고 보기 어렵습니다. 근거: rejection message, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `docs/deployment/review/RELEASE_DECISION_LOG.md`. TODO: open blocker 종료 후 재평가.

## 5. HIG Secondary Check

- [x] ~~HIG-001 권한 요청 시점: 푸시 권한은 런치 시점이 아니라 설정 화면에서만 요청하도록 정리돼 있습니다. 근거: `lib/main.dart`, `lib/services/notification/fcm_service.dart`, `lib/features/notification/presentation/pages/notification_settings_page.dart`.~~
- [ ] HIG-002 권한 최소화: 캘린더는 full access 선언과 실제 용도 설명이 과합니다. 근거: `ios/Runner/Info.plist`, `lib/core/services/unified_calendar_service.dart`, `lib/features/character/presentation/pages/character_chat_panel.dart`. TODO: 최소 권한 원칙으로 재설계.
- [x] ~~HIG-003 로그인 마찰 최소화: 핵심 채팅은 게스트 모드로 시작할 수 있고, 프로필/계정 관리에서만 로그인 필요 상태를 보입니다. 근거: `lib/screens/splash_screen.dart`, `lib/screens/profile/profile_screen.dart`.~~
- [ ] HIG-004 구매 투명성: 구매 관리 진입점은 있으나 현재 paywall/상품 상세/약관 문구가 한 벌로 맞지 않습니다. 근거: `lib/screens/profile/profile_screen.dart`, `lib/core/constants/in_app_products.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`. TODO: 실제 구매 화면과 약관/스토어 문구 정렬.
- [x] ~~HIG-005 알림 UX: 프로모션 토글과 전체 알림 토글이 분리되어 있어 opt-in 관리 UX는 양호합니다. 근거: `lib/features/notification/presentation/pages/notification_settings_page.dart`.~~
- [ ] HIG-006 위젯/Live Activity 적합성: 위젯은 앱 목적과 맞지만 Live Activity는 현재 노출 근거가 부족합니다. 근거: `lib/services/widget_service.dart`, `lib/services/native_platform_service.dart`. TODO: 실제 사용자 가치를 증명하거나 제거.
- [ ] 수동 검증 필요 - HIG-007 접근성/가독성: VoiceOver, Dynamic Type, 색 대비에 대한 별도 검증 문서가 없습니다. TODO: 최소 접근성 QA 추가.

## 6. Prioritized TODO

- [ ] P0. 앱 내 약관의 `토큰 1년 유효기간` 문구를 삭제하고, 토큰형 IAP 만료 금지 정책에 맞춰 서버/고객지원/스토어 문구를 전부 동기화한다.
- [ ] P0. 인앱 `개인정보처리방침` / `이용약관` 페이지를 `public/privacy.html`, `public/terms.html` 기준 최신 ZPZG 정책으로 교체한다.
- [ ] P0. 개인정보처리방침에 제3자 AI 처리 구조(Gemini/OpenAI/Anthropic/Grok 계열 사용 가능성)를 명시하고, 필요한 사용자 고지/동의 문구를 반영한다.
- [ ] P0. Apple이 거절한 네트워크 오류 동선을 리뷰 디바이스 기준으로 재검증하고, 성공 영상/로그를 `IOS_REVIEW_EVIDENCE.md`에 연결한다.
- [ ] P0. IAP 성공/취소/복원 실기기 증빙을 확보해 `IOS-IAP-001~003`, `COM-IAP-001`을 닫는다.
- [ ] P1. `ios/fastlane/metadata/ko/release_notes.txt`와 EN release notes를 현재 제출 버전 기준으로 다시 작성한다.
- [ ] P1. 캘린더 권한을 최소 범위로 재설계하고, 채팅 내 이벤트 조회 시점에서의 권한 요청 흐름을 다시 검증한다.
- [ ] P1. Live Activities를 실제로 쓰지 않으면 `NSSupportsLiveActivities`, `FrequentUpdates`, 관련 native plugin 코드를 정리한다.
- [ ] P1. `AI friend` 메타데이터와 `운세/토큰/구독` 실서비스 포지셔닝을 한 문장 체계로 통일한다.
- [ ] P1. iPad, screenshots, App Preview, IPv6-only 실기기 검증을 보강하고, 유니버설 링크가 필요하다면 `Associated Domains` entitlement까지 복구한다.
- [ ] P2. 건강/의료처럼 읽힐 수 있는 기능과 문구를 별도 검토해 민감 영역 노출을 축소한다.
- [ ] P2. 카카오/네이버 로그인 지원 문구와 실제 로그인 노출 경로를 일치시킨다.
- [ ] P2. 접근성 QA(VoiceOver, Dynamic Type, 대비, 탭 타깃) 최소 증빙을 추가한다.

## 7. 완료본 Checklist

- [x] ~~리뷰 계정, 연락처, 심사 메모, 공개 지원 URL은 준비되어 있다.~~
- [x] ~~Privacy / Terms / Support / AASA live endpoint는 2026-03-22 기준 정상 응답한다.~~
- [x] ~~핵심 채팅은 게스트 모드로 사용 가능해 `로그인 강제` 리스크는 낮다.~~
- [x] ~~앱 내 계정 삭제 경로가 존재한다.~~
- [x] ~~Apple 로그인은 Google 로그인과 동등 옵션으로 제공된다.~~
- [x] ~~푸시 권한은 앱 시작 시 자동 요청하지 않는다.~~
- [x] ~~ATT/IDFA 추적은 제거되어 있다.~~
- [x] ~~구매 복원 / 구독 관리 entry는 프로필에 존재한다.~~
- [x] ~~ASC App Privacy / Age Rating 입력 완료 증거가 있다.~~
- [x] ~~Associated Domains를 비활성화해 유니버설 링크 리스크를 격리했다.~~
- [ ] 토큰 만료 문구를 제거해야 한다.
- [ ] 인앱 정책 페이지를 최신 ZPZG 정책으로 교체해야 한다.
- [ ] 제3자 AI 공유 고지를 개인정보처리방침에 반영해야 한다.
- [ ] Apple이 재현한 네트워크 오류 동선을 실기기에서 다시 닫아야 한다.
- [ ] IAP 성공/취소/복원 실기기 증빙을 닫아야 한다.
- [ ] release notes를 현재 제출 버전에 맞게 갱신해야 한다.
- [ ] 캘린더 권한 최소화와 실기기 timing 검증이 필요하다.
- [ ] 사용하지 않는 Live Activities / frequent updates 선언을 제거해야 한다.
- [ ] 스토어 포지셔닝과 실제 런타임 포지셔닝을 하나로 맞춰야 한다.
- [ ] iPad / screenshots / App Preview / IPv6 / universal links 수동 검증을 완료해야 한다.
