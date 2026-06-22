# 온도 앱 Deleted Screens

이번 정리에서는 “앱 안 버튼이 없고, 현재 운영 IA에서 의미가 사라진 route/prototype”을 실제로 삭제했다. 법적/계정/결제/온보딩 본류/네이티브 위젯 딥링크는 삭제하지 않았다.

## 실제 삭제한 항목

| 파일/route | 삭제 이유 | 의존성 확인 | 대체 동작/영향 |
|---|---|---|---|
| `apps/mobile-rn/app/home.tsx` (`/home`) | `/chat`으로만 보내던 legacy alias. 앱 UI 진입점 없음 | 앱 코드/계약/스크립트 reference 제거 | direct `/home`은 더 이상 앱 route가 아님 |
| `apps/mobile-rn/app/trend.tsx` (`/trend`) | 운영 탭/화면이 없는 legacy route. 앱 UI 진입점 없음 | 앱 코드/계약 reference 제거 | direct `/trend`은 더 이상 앱 route가 아님 |
| `apps/mobile-rn/app/onboarding/toss-style.tsx` (`/onboarding/toss-style`) | 실제 온보딩 플로우는 `/onboarding/name`부터 순차 진행. legacy redirect만 남아 있었음 | product contract와 design surface config에서 제거 | direct legacy path는 더 이상 앱 route가 아님 |
| `apps/mobile-rn/app/widgets/index.tsx`, `apps/mobile-rn/app/widgets/_layout.tsx` (`/widgets`) | 내부 위젯 쇼케이스/prototype route. production 사용자 플로우에 불필요 | 프로필 메뉴 reference 제거 | iOS 실제 widget deep link `/widget`은 유지 |
| `apps/mobile-rn/src/features/ios-widgets/showcase/*` | `/widgets` showcase 전용 컴포넌트 | `ios-widgets/index.ts` export 제거, 다른 runtime import 없음 | 실제 widget primitives/fortune/story/lock/live-activity 모듈은 유지 |
| `apps/mobile-rn/app/(tabs)/profile/dev-tools.tsx` (`/profile/dev-tools`) | 내부 QA route. 사용자 설정 IA에서 제거 | 프로필 메뉴 reference 제거 | route 자체 제거 |
| `apps/mobile-rn/src/screens/dev-tools-screen.tsx` | `/profile/dev-tools` 전용 screen | 다른 import 없음 | 제거 |
| `apps/mobile-rn/src/lib/dev-factory-reset.ts` | dev-tools screen 전용 helper | 다른 import 없음 | 제거 |
| `apps/mobile-rn/src/components/speaker-button.tsx` | long-press TTS UX 이후 import 없는 inline speaker component | import/reference 없음. 관련 주석만 long-press 기준으로 정리 | TTS hook 자체는 유지 |

## 삭제하지 않은 항목

| 파일/route | 유지 이유 |
|---|---|
| `apps/mobile-rn/app/widget.tsx` (`/widget`) | iOS widget/native deep link handler. UI 버튼이 없는 것이 정상이며 삭제 금지 |
| `apps/mobile-rn/app/fortune.tsx` (`/fortune`) | feature flag와 legacy fortune entry 처리 route. 이번 safe-delete 범위 밖 |
| `/premium`, `/account-deletion`, legal pages | 결제/계정/법적 필수 route라 삭제 금지 |
| `/onboarding/name` 등 실제 온보딩 step routes | 회원가입 완료 후 실제 순차 flow에서 사용 |
| `/friends/new/*` routes | 친구 생성 순차 flow에서 사용 |

## 삭제 후 라우트 수

- route files: 51개 → 45개
- `src/screens/*.tsx`: 21개 → 20개
