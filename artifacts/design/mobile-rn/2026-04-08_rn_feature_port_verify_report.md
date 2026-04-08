# Verify Report

## 1. Change Summary
- What changed:
  - RN 앱에 푸시 알림 초기화, 알림 설정 저장/권한/테스트 플로우, 타로 인터랙티브 survey footer, 캘린더 컨텍스트 enrichment, 홈 위젯 스냅샷 업데이트, Expo config plugins를 연결했다.
- Why changed:
  - Flutter에 있던 Fortune 최적화/알림/타로/위젯/캘린더 흐름을 RN 런타임으로 옮기기 위한 기반과 핵심 UX를 맞추기 위해서다.
- Affected area:
  - `apps/mobile-rn/` 전반, 특히 `chat`, `notifications`, `calendar`, `widgets`, `app.config.ts`.

## 2. Static Validation
- `flutter analyze`
  - Result: Not run
  - Notes: 이번 작업 범위는 RN 앱(`apps/mobile-rn`)이라 Flutter 앱 루트 분석은 범위 밖으로 두었다.
- `dart format --set-exit-if-changed .`
  - Result: Not run
  - Notes: RN TypeScript 변경이 중심이라 실행하지 않았다.
- `dart run build_runner build --delete-conflicting-outputs`
  - Result: Not run
  - Notes: Freezed/codegen 영향 없음.

## 3. Tests and QA
- Unit/Widget/Integration tests run:
  - Command: `npm run typecheck`
  - Result: Passed
- Expo config validation:
  - Command: `npx expo config --type public`
  - Result: Passed
- Playwright QA (if applicable):
  - Command: Not run
  - Result: RN native flow라 이번 턴에서는 미실행

## 4. Files Changed
1. `apps/mobile-rn/app.config.ts` - Expo notifications/calendar/widgets plugins 추가
2. `apps/mobile-rn/app/_layout.tsx` - notification route bridge 추가
3. `apps/mobile-rn/src/lib/notifications/notification-service.ts` - 권한/토큰/스케줄/딥링크 라우팅 보강
4. `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` - 알림 저장 시 권한/디바이스 등록/리마인더 스케줄 연동
5. `apps/mobile-rn/src/screens/profile-notifications-screen.tsx` - RN 알림 설정 UI/상태 화면 개편
6. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` - 타로 deck picker/card draw footer 연결
7. `apps/mobile-rn/src/screens/chat-screen.tsx` - 타로 structured answer, 캘린더 enrichment, 홈 위젯 업데이트 연결
8. `apps/mobile-rn/src/features/chat-survey/registry.ts` - tarot survey definition 및 객체형 answer label 보강
9. `apps/mobile-rn/src/features/chat-results/edge-runtime.ts` - tarot payload parsing 강화
10. `apps/mobile-rn/src/lib/calendar/calendar-service.ts` - 캘린더 sync context 정리
11. `apps/mobile-rn/src/lib/widgets/fortune-widget-service.ts` - 홈 위젯 snapshot service 사용
12. `apps/mobile-rn/src/widgets/fortune-home-widget.tsx` - Expo widget directive 추가
13. `apps/mobile-rn/src/features/tarot/*` - RN 타로 덱 선택/카드 뽑기 payload/UI 추가

## 5. Risks and Follow-ups
- Known risks:
  - `expo-notifications`, `expo-calendar`, `expo-widgets`는 native rebuild가 필요하다.
  - 일부 RN 핵심 파일은 작업 전부터 큰 변경이 있었기 때문에 이번 커밋은 RN migration 흐름을 함께 포함한다.
- Deferred items:
  - 실제 remote push 발송 QA
  - iOS 홈 위젯 실기기 배치 확인
  - 캘린더 권한 denied 상태 UX 세부 polish

## 6. User Manual Test Request
- Scenario:
  1. RN 앱을 native rebuild 후 실행한다.
  2. 프로필 > 알림 설정에서 권한 요청, 테스트 알림, 리마인더 시간 저장을 확인한다.
  3. 채팅에서 타로를 선택해 덱 선택 -> 질문 입력 -> 카드 뽑기 -> 결과 생성 흐름을 확인한다.
  4. 만세력에서 `일정과 함께 보기` 선택 후 캘린더 권한 허용/거부 각각을 확인한다.
  5. iOS에서 홈 위젯을 추가하고 운세 결과 생성 후 snapshot이 갱신되는지 확인한다.
- Expected result:
  - 알림 권한/테스트 알림/딥링크/타로 카드 뽑기/캘린더 보강/홈 위젯 snapshot이 정상 동작한다.
- Failure signal:
  - 권한 요청 후 상태 미반영, tarot answer가 `[object Object]`로 노출, daily-calendar가 permission denied에서도 일정 sync로 표시, 홈 위젯 미갱신

## 7. Completion Gate
- RN native rebuild 및 수동 실기기 확인이 남아 있다.
