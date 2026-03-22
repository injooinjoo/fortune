# ZPZG Apple Guidelines Full Audit

작성일: 2026-03-22  
기준 버전: iOS 앱 심사 대상 `1.0.7`  
기준 문서:
- App Store Review Guidelines: https://developer.apple.com/kr/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

## 1. Overall Verdict

- 현재 저장소 기준 verdict는 `GO (코드/정책/메타데이터)`입니다.
- 2026년 3월 21일 App Review rejection 이후 문제였던 `토큰 만료 문구`, `정책/메타데이터 불일치`, `제3자 AI 공개 부족`, `건강/의료 오해 위험`, `Live Activities/레거시 iOS 선언 과다`, `캘린더 권한 과다`는 현재 repo 기준으로 정리되었습니다.
- 남은 항목은 `실기기 증빙 패키지`뿐입니다. 즉, 현재 blocker는 코드가 아니라 `iPhone clean install 재현 확인`, `IAP success/cancel/restore recording`, `iPad / IPv6 확인`입니다.

## 2. Highest-Risk Rejection Candidates

- [ ] `2.1(a)` 2026년 3월 21일 Apple이 재현한 `Network connection error` 동선을 실제 iPhone에서 clean install 기준으로 다시 닫아야 합니다. 근거: App Review rejection message, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`.
- [ ] `2.1(b)`, `3.1.1` IAP success / cancel / restore의 on-device 증빙이 아직 없습니다. 근거: `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`.
- [ ] `2.4.1`, `2.5.5` iPad review path와 IPv6/NAT64 점검은 코드가 아니라 실기기 검증으로만 닫힙니다. 근거: `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`.

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
  - `lib/core/navigation/fortune_chat_route.dart`
  - `lib/features/chat/domain/models/recommendation_chip.dart`
- 공개 정책/지원 페이지:
  - `public/privacy.html`
  - `public/terms.html`
  - `public/support.html`

판정 표기:
- `- [x] ~~완료~~`
- `- [ ] 미완료/개선 필요`
- `- [ ] 수동 검증 필요`
- `- [ ] N/A - 사유`

## 4. Full Apple Checklist

### A. 서론 / 제출하기 전에

- [x] ~~PRE-001 리뷰 계정, 연락처, 심사 메모 제공: `ios/fastlane/Deliverfile`, `ios/fastlane/metadata/review_information/*`에 review 계정과 리뷰 노트가 존재합니다.~~
- [x] ~~PRE-002 공개 정책 URL 가동: `https://zpzg.co.kr/privacy`, `https://zpzg.co.kr/terms`, `https://zpzg.co.kr/support`가 2026년 3월 22일 기준 정상 응답합니다.~~
- [ ] PRE-003 제출 전 기기/백엔드 완전성: 2026년 3월 21일 rejection path를 clean install 기준으로 다시 닫는 실기기 로그가 아직 없습니다. TODO: iPhone recording + app logs 첨부.
- [ ] PRE-004 수동 증빙 패키지: IAP success/cancel/restore, iPad review path, IPv6/NAT64 확인이 아직 남아 있습니다. TODO: `IOS_REVIEW_EVIDENCE.md` open row 종료.

### 1. 안전성

- [x] ~~1.1 부적절한 콘텐츠 전반: 현재 스토어 메타데이터와 review notes 기준으로 직접적인 폭력/혐오/성인물/불법 조장 표면은 없습니다. AI 채팅은 entertainment/wellbeing framing으로 제출됩니다.~~
- [x] ~~1.1.1 차별/악의적 콘텐츠: current review path 기준 직접 위반 증거가 없습니다.~~
- [ ] N/A - 1.1.2 현실적 폭력 묘사: 해당 기능이 없습니다.
- [ ] N/A - 1.1.3 무기/위험물 조장: 해당 기능이 없습니다.
- [x] ~~1.1.4 성적/포르노/만남 주선: 현재 메타데이터/정책/핵심 리뷰 동선 기준 직접 위반 증거가 없습니다.~~
- [x] ~~1.1.5 선동적 종교 해설: 서비스는 종교 앱이 아니며, 정책상 entertainment/lifestyle reference로 정리되어 있습니다.~~
- [ ] N/A - 1.1.6 속임수/장난 기능: 가짜 추적기/장난 전화/SMS 기능이 없습니다.
- [ ] N/A - 1.1.7 시사 비극 악용: 해당 기능이 없습니다.
- [ ] N/A - 1.2 UGC/소셜 피드: 공개 피드형 UGC 앱이 아니므로 핵심 적용 대상이 아닙니다.
- [ ] N/A - 1.2.1 크리에이터 콘텐츠: 사용자 제작 미니앱/콘텐츠 마켓 구조가 없습니다.
- [ ] N/A - 1.3 어린이 카테고리: 어린이 카테고리 앱이 아닙니다.
- [x] ~~1.4.1 신체적 부상/의료 오해: 건강 표면을 `웰니스 체크`로 축소했고, 건강 direct entry/chip, calendar direct entry, 의료형 카피를 review surface에서 제거했습니다. 하단 disclaimer도 `medical advice 아님`으로 강화했습니다. 근거: `lib/features/chat/domain/models/recommendation_chip.dart`, `lib/features/character/data/fortune_characters.dart`, `lib/features/character/presentation/providers/character_chat_provider.dart`, `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart`, `lib/features/character/presentation/widgets/fortune_bodies/_fortune_body_shared.dart`, `public/terms.html`.~~
- [ ] N/A - 1.4.2 약물 투여 계산기: 해당 기능이 없습니다.
- [ ] N/A - 1.4.3 담배/불법 약물 조장: 해당 기능이 없습니다.
- [ ] N/A - 1.4.4 DUI/무모 운전 조장: 해당 기능이 없습니다.
- [ ] N/A - 1.4.5 신체적 위험 행동 유도: 해당 기능이 없습니다.
- [x] ~~1.5 개발자 정보: 공개 지원 페이지와 review metadata에 연락처가 존재합니다.~~
- [x] ~~1.6 데이터 보안: ATS, privacy manifest, app group, account deletion 흐름이 정리되어 있습니다.~~
- [ ] N/A - 1.7 범죄 행위 신고 앱: 해당 앱이 아닙니다.

### 2. 성능

- [ ] 2.1(a) 앱 완전성: 2026년 3월 21일 rejection path의 clean-install iPhone 재검증이 남아 있습니다. TODO: iPhone recording + logs 첨부.
- [ ] 2.1(b) IAP 완전성: success / cancel / restore의 실기기 E2E 증빙이 남아 있습니다. TODO: `IOS-IAP-001~003` 종료.
- [x] ~~2.2 베타 테스트 금지: 현재 description / review notes는 정식 사용자용 포지셔닝입니다.~~
- [x] ~~2.3 메타데이터 정확성 전반: App Store description, public policy, in-app policy, release notes를 현재 ZPZG positioning으로 동기화했습니다.~~
- [x] ~~2.3.1 숨김/미문서화 기능 금지: current submission scope에서 calendar permission, quick actions, user activities, Live Activities, BGTask refresh, Siri shortcut 경로를 제거했습니다. 근거: `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner/NativePlatformPlugin.swift`, `lib/services/native_platform_service.dart`, `ios/fastlane/metadata/review_information/review_notes.txt`.~~
- [ ] 수동 검증 필요 - 2.3.2 IAP 홍보 정확성: 실제 purchase screen 캡처와 metadata 문구 최종 대조는 실기기 패키지에 포함해야 합니다.
- [ ] 수동 검증 필요 - 2.3.3 스크린샷 정확성: App Store Connect 제출 스크린샷 최신 여부 최종 확인 필요.
- [ ] 수동 검증 필요 - 2.3.4 App Preview 정확성: 현재 제출 영상이 최신 동선과 일치하는지 ASC에서 확인 필요.
- [x] ~~2.3.5 카테고리 적합성: `Lifestyle` + `Entertainment` 포지셔닝이 AI chat + lifestyle insights와 일치합니다.~~
- [x] ~~2.3.6 연령 등급 질문 정합성: ASC age rating / questionnaire 확인 기록이 있습니다.~~
- [x] ~~2.3.7 이름/키워드 적합성: 스팸성 키워드 나열 없이 현재 positioning에 맞춰져 있습니다.~~
- [x] ~~2.3.8 전체 연령 적합 메타데이터: 메타데이터에 직접적인 성인/충격 이미지 요구가 없습니다.~~
- [ ] 수동 검증 필요 - 2.3.9 스크린샷/미리보기 자료 권리: 제출 자산 원본/권리 최종 확인 필요.
- [x] ~~2.3.10 다른 플랫폼/마켓플레이스 언급 금지: 현재 메타데이터에 위반 표현이 없습니다.~~
- [ ] N/A - 2.3.11 사전 주문 앱: 현재 사전 주문 제출이 아닙니다.
- [x] ~~2.3.12 새로운 기능 설명 최신화: KR/EN release notes가 현재 제출 기준으로 정리되었습니다.~~
- [ ] N/A - 2.3.13 앱 내 이벤트: 현재 제출 범위에 없음.
- [ ] 수동 검증 필요 - 2.4.1 iPad 동작: `/chat`, login, policy, purchase entry를 iPad에서 다시 확인해야 합니다.
- [x] ~~2.4.2 배터리/리소스 사용: background mode를 `remote-notification`만 남기고 BGTask/Live Activity 선언을 제거해 과다 선언을 해소했습니다.~~
- [ ] N/A - 2.4.3 Apple TV/게임 컨트롤러: tvOS 앱이 아닙니다.
- [x] ~~2.4.4 시스템 설정 변경 강요 금지: Wi-Fi/보안 비활성화 요구 같은 흐름이 없습니다.~~
- [ ] N/A - 2.4.5 Mac App Store 항목: 현재 범위가 아닙니다.
- [x] ~~2.5.1 공개 API 사용: private API 사용 증거가 없습니다.~~
- [x] ~~2.5.2 번들 독립성/코드 다운로드 금지: 실행 코드 다운로드 구조 증거가 없습니다.~~
- [x] ~~2.5.3 시스템 훼손 금지: 악성코드/OS 훼손 기능 증거가 없습니다.~~
- [x] ~~2.5.4 백그라운드 모드 목적 적합성: current build는 `remote-notification`만 유지하고 review notes도 그 흐름에 맞춰졌습니다.~~
- [ ] 수동 검증 필요 - 2.5.5 IPv6-only/NAT64: 코드 보강은 반영됐지만 실네트워크 기록은 아직 없습니다.
- [ ] N/A - 2.5.6 대체 브라우저 엔진: 해당 앱이 아닙니다.
- [ ] N/A - 2.5.8 대체 홈 화면 환경: 해당 기능이 없습니다.
- [x] ~~2.5.9 표준 스위치/UI 변경 금지: 기본 시스템 스위치를 가로채는 기능이 없습니다.~~
- [ ] N/A - 2.5.11 SiriKit/단축어: 이번 제출 범위에서 제거되었습니다.
- [ ] N/A - 2.5.12 CallKit/SMS 차단: 해당 기능이 없습니다.
- [ ] N/A - 2.5.13 안면 인식 인증: 얼굴 분석은 계정 인증 기능이 아닙니다.
- [x] ~~2.5.14 카메라/마이크/화면 입력 동의: 카메라/사진/마이크/음성 인식은 목적 문자열과 기능 실행 시점 요청 구조로 정리돼 있습니다. calendar permission은 submission scope에서 제거됐습니다.~~
- [ ] N/A - 2.5.15 파일 앱 연동: 문서 브라우저 앱이 아닙니다.
- [x] ~~2.5.16 위젯/확장/알림 관련성: 위젯은 앱 기능과 연관되고, Live Activity/shortcut/legacy extension scope는 이번 제출에서 제거했습니다.~~
- [ ] N/A - 2.5.17 Matter: 해당 기능이 없습니다.
- [x] ~~2.5.18 광고 제약: 광고 SDK/광고 UI 증거가 없습니다.~~

### 3. 비즈니스

- [x] ~~3.1.1 앱 내 구입 사용: 토큰 만료 문구를 제거했고 restore entry도 존재합니다. 근거: `lib/core/constants/in_app_products.dart`, `public/terms.html`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`, `lib/screens/profile/profile_screen.dart`.~~
- [x] ~~3.1.1(a) 외부 결제 유도 금지: 앱 내 외부 결제 CTA 증거가 없습니다.~~
- [x] ~~3.1.2(a) 자동 갱신 구독 허용 범위: membership 설명은 토큰 + premium insight 접근으로 정리되어 있습니다.~~
- [ ] 수동 검증 필요 - 3.1.2(b) 업그레이드/다운그레이드: 구독 전환/복원은 IAP 실기기 패키지로 최종 확인 필요.
- [ ] 수동 검증 필요 - 3.1.2(c) 구독 정보 명확성: 최종 purchase screen 캡처와 metadata 문구 대조 필요.
- [x] ~~3.1.3 기타 구입 방식 금지: external purchase flow 증거가 없습니다.~~
- [ ] N/A - 3.1.3(a)~3.1.5: 읽기 도구/기업 서비스/암호화폐/하드웨어 기반 결제 등은 현재 앱 범위가 아닙니다.
- [x] ~~3.2.2(x) 리뷰/타앱 다운로드 강요 금지: 강제 리뷰/타앱 설치 유도 코드 증거가 없습니다.~~
- [x] ~~3.2 기타 금지사항 전반: 도박/대출/광고 조작/임의 지역 제한 기능 증거가 없습니다.~~

### 4. 디자인

- [x] ~~4.1 모방 금지: current product는 AI character DM + curiosity insight 구조로 단순 클론 증거가 없습니다.~~
- [x] ~~4.2 최소 기능: `/chat`, character chat, Face AI, policy/account surfaces로 최소 기능 미달 앱이 아닙니다.~~
- [x] ~~4.2.2 마케팅 자료/링크 모음 앱 금지: 핵심은 생성형 대화/인사이트 기능입니다.~~
- [x] ~~4.2.3(i) 독립 실행 가능: 게스트 모드로 핵심 채팅 사용이 가능합니다.~~
- [x] ~~4.2.3(ii) 초기 실행 추가 리소스 다운로드 강제: 현재 review path 기준 필수 사전 다운로드를 사용자에게 강제하는 증거가 없습니다.~~
- [x] ~~4.2.6 템플릿 앱 금지: 템플릿 생성 앱 증거가 없습니다.~~
- [ ] N/A - 4.2.7 원격 데스크톱: 해당 앱이 아닙니다.
- [x] ~~4.3 스팸: review surface를 `AI chat + lifestyle insights`로 정리했고, saturated `fortune/health/calendar` direct entry를 current submission path에서 축소했습니다. 근거: `ios/fastlane/metadata/*/description.txt`, `docs/getting-started/APP_SURFACES_AND_ROUTES.md`, `lib/features/chat/domain/models/recommendation_chip.dart`, `lib/core/navigation/fortune_chat_route.dart`.~~
- [x] ~~4.4 확장 프로그램: 위젯은 유지하되 Live Activity / Siri / Quick Action / user activity 선언을 submission scope에서 제거했습니다.~~
- [ ] N/A - 4.4.1 키보드 확장: 해당 기능이 없습니다.
- [ ] N/A - 4.4.2 Safari 확장: 해당 기능이 없습니다.
- [x] ~~4.5.1 Apple 사이트/서비스 스크레이핑 금지: 위반 증거가 없습니다.~~
- [ ] N/A - 4.5.2 Apple Music: 해당 기능이 없습니다.
- [x] ~~4.5.3 Apple 서비스 남용 금지: Game Center/푸시/Apple 서비스 남용 증거가 없습니다.~~
- [x] ~~4.5.4 푸시 알림: 앱 시작 시 자동 권한 요청이 없고 settings/test path에서만 요청합니다.~~
- [ ] N/A - 4.5.5 Game Center: 해당 기능이 없습니다.
- [x] ~~4.5.6 Apple 제품 사칭/이모티콘 남용: 위반 증거가 없습니다.~~
- [ ] N/A - 4.7 미니앱/스트리밍게임/챗봇 플랫폼: 외부 소프트웨어 마켓 구조가 아닙니다.
- [x] ~~4.8 로그인 서비스: metadata와 runtime 모두 Google / Apple sign-in 기준으로 맞춰져 있습니다.~~
- [ ] N/A - 4.9 Apple Pay: Apple Pay 앱이 아닙니다.
- [x] ~~4.10 내장 기능 상품화 금지: 카메라/마이크/푸시 자체를 유료 판매하지 않습니다.~~

### 5. 법적 요구 사항

- [x] ~~5.1.1(i) 개인정보처리방침 최신성: public/in-app privacy & terms가 2026년 3월 22일 기준 최신본으로 맞춰져 있습니다.~~
- [x] ~~5.1.1(ii) 데이터 수집 허가: 카메라/사진/마이크/음성/위치 권한은 기능 실행 시점 기준입니다.~~
- [x] ~~5.1.1(iii) 데이터 최소화: calendar permission을 iOS 제출 범위에서 제거해 과다 권한 이슈를 정리했습니다.~~
- [x] ~~5.1.1(iv) 접근 강요 금지: 게스트 사용 경로가 존재합니다.~~
- [x] ~~5.1.1(v) 로그인 비강제 + 인앱 계정 삭제: 비로그인 사용 가능, in-app deletion 제공.~~
- [x] ~~5.1.1(viii) 공개 DB 개인정보 수집 금지: 관련 기능 증거가 없습니다.~~
- [x] ~~5.1.1(ix) 민감 서비스/법인 제출: current review surface를 의료형 서비스가 아니라 wellbeing/lifestyle reference로 축소했습니다. health platform integration은 비활성 상태이고, public-facing copy는 `웰니스 체크`로 정리했습니다.~~
- [x] ~~5.1.1(x) 기본 연락처 정보 선택성: 게스트 사용 경로가 존재합니다.~~
- [x] ~~5.1.2(i) 데이터 사용/공유 공개: privacy policy에 Supabase, Firebase, App Store/Play, AI model providers disclosure를 반영했습니다.~~
- [x] ~~5.1.2(ii) 목적 외 사용 금지: 현재 공개 정책 기준 목적 범위가 제한되어 있습니다.~~
- [x] ~~5.1.2(iii) 비밀 프로파일링 금지: ATT/IDFA 제거 상태입니다.~~
- [x] ~~5.1.2(iv) 연락처/설치 앱 목록 수집 금지: 관련 기능이 없습니다.~~
- [ ] N/A - 5.1.2(v) 연락처를 통한 타인 접촉: 해당 기능이 없습니다.
- [x] ~~5.1.2(vi) HealthKit/얼굴 데이터 광고 금지: 건강 플랫폼 연동은 비활성화되어 있고 광고 타깃팅 증거가 없습니다.~~
- [ ] N/A - 5.1.2(vii) Apple Pay 데이터 공유: 해당 기능이 없습니다.
- [ ] N/A - 5.1.3 건강/보건 연구: ResearchKit/Clinical Health/HealthKit 연구 앱이 아닙니다.
- [ ] N/A - 5.1.4 어린이 개인정보: 어린이 카테고리 앱이 아닙니다.
- [x] ~~5.1.5 위치 서비스: when-in-use만 선언하고 용도도 그 범위로 제한했습니다.~~
- [x] ~~5.2.1 일반 IP: 직접적인 IP 위반 증거가 없습니다.~~
- [ ] 수동 검증 필요 - 5.2.2 타사 서비스 약관/자산 권리: 제출 직전 celebrity / social login / third-party provider asset 권리 최종 확인 필요.
- [ ] N/A - 5.2.3 오디오/비디오 다운로드: 해당 기능이 없습니다.
- [x] ~~5.2.4 Apple 추천 오인 금지: Apple 보증을 암시하는 표현이 없습니다.~~
- [x] ~~5.2.5 Apple 제품/인터페이스 혼동 금지: Apple UI 사칭 증거가 없습니다.~~
- [ ] N/A - 5.3 도박/복권: 해당 기능이 없습니다.
- [ ] N/A - 5.4 VPN: 해당 기능이 없습니다.
- [ ] N/A - 5.5 MDM: 해당 기능이 없습니다.
- [x] ~~5.6.1 App Store 리뷰 요청: 강제/보상형 리뷰 유도 증거가 없습니다.~~
- [x] ~~5.6.2 개발자 신원 정확성: public support, metadata, in-app policy가 모두 ZPZG 브랜드 기준으로 맞춰졌습니다.~~
- [ ] N/A - 5.6.3 둘러보기 사기: 저장소 차원에서 판단 근거가 없습니다.
- [x] ~~5.6.4 앱 품질: repo-side blocker는 정리되었고, 남은 위험은 실기기 evidence handoff뿐입니다.~~

## 5. HIG Secondary Check

- [x] ~~HIG-001 권한 요청 시점: 푸시 권한은 설정 경로에서만 요청합니다.~~
- [x] ~~HIG-002 권한 최소화: calendar permission을 제거해 iOS 최소 권한 원칙으로 맞췄습니다.~~
- [x] ~~HIG-003 로그인 마찰 최소화: 게스트 모드와 Apple/Google 동등 옵션을 제공합니다.~~
- [ ] 수동 검증 필요 - HIG-004 구매 투명성: final purchase screen capture로 가격/혜택/restore flow 최종 확인 필요.
- [x] ~~HIG-005 알림 UX: opt-in 관리 경로가 분리되어 있습니다.~~
- [x] ~~HIG-006 위젯/확장 적합성: 위젯은 유지하고 Live Activity 등 비핵심 선언은 제거했습니다.~~
- [ ] 수동 검증 필요 - HIG-007 접근성/가독성: iPad / Dynamic Type / VoiceOver 최소 점검은 최종 수동 패키지에 포함하는 편이 안전합니다.

## 6. Prioritized TODO

- [ ] P0. iPhone clean install 기준으로 2026년 3월 21일 rejection path를 다시 수행하고, `Network connection error` 미재현 recording + logs를 남긴다.
- [ ] P0. IAP success / cancel / restore recording을 확보해 `IOS-IAP-001~003`, `APPLE-IAP-002`를 닫는다.
- [ ] P1. iPad에서 `/chat` / login / policy / purchase entry를 확인해 `IOS-RUNTIME-003`, `APPLE-RUNTIME-002`를 닫는다.
- [ ] P1. NAT64 / IPv6-only 테스트 네트워크가 가능하면 `IOS-RUNTIME-004`, `APPLE-RUNTIME-003`를 닫는다.
- [ ] P1. App Store Connect screenshots / App Preview / final rights check를 제출 직전 한 번 더 확인한다.

## 7. 완료본 Checklist

- [x] ~~토큰 만료 문구를 제거했다.~~
- [x] ~~인앱 정책 페이지와 공개 정책 페이지를 최신 ZPZG 정책으로 동기화했다.~~
- [x] ~~제3자 AI 제공자 공개를 privacy policy에 반영했다.~~
- [x] ~~건강/의료형 표면을 `웰니스 체크` 기준으로 축소했다.~~
- [x] ~~건강/캘린더 direct entry와 추천 surface를 축소했다.~~
- [x] ~~calendar permission을 iOS 제출 범위에서 제거했다.~~
- [x] ~~Quick Actions / NSUserActivityTypes / Siri shortcut / Live Activity / BGTask 선언을 제출 범위에서 제거했다.~~
- [x] ~~background mode를 `remote-notification`만 남기도록 최소화했다.~~
- [x] ~~App Store description / release notes / review notes를 현재 포지셔닝에 맞췄다.~~
- [x] ~~Associated Domains를 비활성화한 상태로 review scope를 명확히 했다.~~
- [x] ~~Apple 로그인과 Google 로그인이 동등 옵션으로 제공되는 상태를 유지했다.~~
- [x] ~~게스트 모드와 in-app account deletion 경로를 유지했다.~~
- [ ] iPhone clean install recording을 남겨야 한다.
- [ ] IAP success / cancel / restore recording을 남겨야 한다.
- [ ] iPad review path 확인을 남겨야 한다.
- [ ] NAT64 / IPv6-only 확인이 가능하면 추가해야 한다.
