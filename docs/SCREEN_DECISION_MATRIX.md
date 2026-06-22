# 온도 앱 Screen Decision Matrix

| Screen | Path | Current Status | Decision | Reason | Action Taken | Risk |
|---|---|---|---|---|---|---|
| Root redirect | `app/index.tsx` | `/splash` redirect | Keep | 앱 cold-start entry | 변경 없음 | 낮음 |
| Splash gate | `src/screens/splash-screen.tsx` | 게스트가 welcome 없이 `/chat`로 갈 수 있었음 | Fix | 최초 게스트 welcome 확인과 auth-entry가 분리되어야 함 | 비로그인 ready 상태도 welcome-seen 확인 후 `/welcome` 또는 `/chat?showList=1` | 낮음: guest-first 유지 |
| Welcome onboarding | `src/screens/welcome-screen.tsx` | 존재, 완료 후 chat | Keep | first-run brand/welcome surface | 변경 없음 | 낮음 |
| Signup/account connect | `src/screens/signup-screen.tsx` | 실제 진입 가능 | Keep | 계정 연결 핵심 | 변경 없음 | 낮음 |
| Email auth | `src/screens/email-auth-screen.tsx` | 실제 진입 가능 | Keep | 이메일 로그인/가입 | 변경 없음 | 낮음 |
| Phone auth | `src/screens/phone-auth-screen.tsx` | 실제 진입 가능 | Keep | 전화번호 로그인 | 변경 없음 | 낮음 |
| Auth callback | `src/screens/auth-callback-screen.tsx` | `firstRunHandoffSeen`만 보고 routing | Fix | birth/interests 누락 상태가 chat list로 fallthrough 가능 | fresh persisted progress + 3개 required flag 검사 | 중간: auth callback regression은 QA 필요 |
| Chat/message list | `src/screens/chat-screen.tsx` | 실제 진입 가능 | Keep | 핵심 경험 | 변경 없음 | 낮음 |
| Chat alias route | `app/chat.tsx` | `/chat` alias | Merge / Keep | tab route와 중복처럼 보이나 canonical path/deeplink 호환 | 변경 없음 | 삭제 시 external link 위험 |
| Profile hub | `src/screens/profile-screen.tsx` | 실제 설정 hub | Fix / Keep | internal widget/dev/onboarding QA가 production에도 계정 기준 노출 가능 | dev-only menu/QA controls gate 적용, widgets link hide | 낮음: production menu 축소 |
| Profile edit | `src/screens/profile-edit-screen.tsx` | 연결됨 | Keep | 핵심 프로필 수정 | 변경 없음 | 낮음 |
| Notifications | `src/screens/profile-notifications-screen.tsx` | 연결됨 | Keep | 설정 핵심 | final divider만 dev hide 상태에 맞춤 | 낮음 |
| Relationships | `src/screens/profile-relationships-screen.tsx` | 연결됨 | Keep | 캐릭터/인간관계 관리 | 변경 없음 | 낮음 |
| Saju summary | `src/screens/profile-saju-summary-screen.tsx` | 연결됨 | Keep | 개인화/만세력 | 변경 없음 | 낮음 |
| My fortunes | `src/screens/my-fortunes-screen.tsx` | 연결됨 | Keep | 결과 이력 | 변경 없음 | 낮음 |
| Dev tools | `src/screens/dev-tools-screen.tsx`, `app/(tabs)/profile/dev-tools.tsx` | 내부 QA route | Delete | 사용자 설정 IA에서 제거 | route/screen/helper 삭제, profile menu 제거 | 낮음: 운영 사용자 영향 없음 |
| Premium/token | `src/screens/premium-screen.tsx` | 여러 CTA에서 연결 | Keep | 결제/토큰은 삭제 금지 | 변경 없음 | 스토어/native 모듈 상태 QA 필요 |
| Account deletion | `src/screens/account-deletion-screen.tsx` | profile에서 연결 | Keep | 계정/법적 필수 | 변경 없음 | 낮음 |
| Character profile | `src/screens/character-profile-screen.tsx` | 실제 하늘이 프로필 확인됨 | Keep | 캐릭터 관계 핵심 | 변경 없음 | 낮음 |
| Friend picker | `src/screens/friend-picker-screen.tsx` | 관계/FAB 경로 존재 | Keep / Hide 검토 | 출시 정책에 따라 숨김 가능하지만 현재 연결됨 | 변경 없음 | feature readiness QA 필요 |
| Friend creation steps | `src/screens/friend-creation-screen.tsx`, `/friends/new/*` | multi-step route | Keep / Refactor candidate | 같은 파일 공유는 중복 아님. flow state guard 존재 | 변경 없음 | UX 길이/토큰 gating QA 필요 |
| Onboarding name | `app/onboarding/name.tsx` | 존재 | Fix/Keep | signup 후 반드시 접근 가능해야 함 | auth callback routing fix로 연결 강화 | 낮음 |
| Onboarding birth | `app/onboarding/birth.tsx` | 존재 | Keep | 필수 profile data | 변경 없음 | 중간 이탈 resume은 첫 단계 복귀 중심 |
| Onboarding MBTI | `app/onboarding/mbti.tsx` | 존재 | Keep | personalization | 변경 없음 | 낮음 |
| Onboarding relationship | `app/onboarding/relationship.tsx` | 존재 | Keep | personalization | 변경 없음 | 낮음 |
| Onboarding tone | `app/onboarding/tone.tsx` | 존재 | Keep | conversation preference | 변경 없음 | 낮음 |
| Onboarding topics | `app/onboarding/topics.tsx` | 존재 | Fix/Keep | 최종 저장/완료 지점 | remote completion sync 보강 | 낮음 |
| Remote profile onboarding sync | `src/lib/user-profile-remote.ts`, `mobile-app-state-provider.tsx` | remote completed가 `firstRunHandoffSeen`을 채우지 않음 | Fix | 완료 유저가 새 기기/로컬 reset 후 onboarding 반복 가능 | remote completed면 firstRunHandoffSeen true patch | 중간: remote schema 의존 |
| Onboarding toss alias | `app/onboarding/toss-style.tsx` | legacy redirect | Delete | 실제 온보딩은 `/onboarding/name` 순차 flow로 정리 | route/contract/design surface 제거 | old direct link는 route 없음 |
| Fortune legacy route | `app/fortune.tsx` | feature flag redirect | Keep | external/deeplink/legacy route 가능 | 변경 없음 | 삭제 위험 높음 |
| Result detail | `app/result/[resultKind].tsx` | 연결됨 | Keep | saved/result flow | 변경 없음 | 낮음 |
| Widget deep link | `app/widget.tsx` | native/widget route | Keep | app.config/native refs | 변경 없음 | 높음: 삭제 금지 |
| Widgets showcase | `app/widgets/index.tsx` | internal preview/showcase | Delete | 실제 `/widget` deep link와 무관한 prototype | route/layout/showcase components/profile menu 제거 | 낮음 |
| Home alias | `app/home.tsx` | `/chat` redirect, 메뉴 미노출 | Delete | 버튼 없는 legacy alias | route/contract 제거 | old direct link는 route 없음 |
| Trend alias | `app/trend.tsx` | 메뉴 미노출 | Delete | 운영 trend 화면 없음 | route/contract 제거 | old direct link는 route 없음 |
| Legal: privacy | `app/privacy-policy.tsx` | 연결됨 | Keep | 법적 필수 | 변경 없음 | 삭제 금지 |
| Legal: terms | `app/terms-of-service.tsx` | 연결됨 | Keep | 법적 필수 | 변경 없음 | 삭제 금지 |
| Legal: EULA | `app/eula.tsx` | 연결됨 | Keep | App Store/UGC compliance | 변경 없음 | 삭제 금지 |
| Legal: disclaimer | `app/disclaimer.tsx` | 연결됨 | Keep | 운세/AI 고지 | 변경 없음 | 삭제 금지 |
| Legal: business info | `app/business-info.tsx` | footer 연결 | Keep | 사업자 정보 접근성 | 변경 없음 | 삭제 금지 |
| Legal: OSS licenses | `app/open-source-licenses.tsx` | 연결됨 | Keep | OSS notice | 변경 없음 | 삭제 금지 |
| Not found | `app/+not-found.tsx` | fallback | Keep | unknown route UX | 변경 없음 | 낮음 |
| SpeakerButton component | `src/components/speaker-button.tsx` | unused | Delete | long-press TTS UX 이후 import 없음 | component 삭제, TTS 주석 정리 | 낮음 |
| Babel/Expo config/plugin files | `babel.config.js`, `plugins/*` | knip unused 후보 | Keep | Expo convention/static tool false positive 가능 | 변경 없음 | 삭제 시 build/native transform 위험 |

## 집계

- Keep: 34
- Merge: 1
- Delete: 6
- Hide: 0
- Fix: 5
- Owner Confirmation Required: 0

> 중복 카운트는 route/screen 단위 판정을 합친 요약이며, 상세 route 수(51)와 1:1로 일치하지 않는다.
