# Discovery Report

## 1. Goal
- Requested change: Port Flutter capabilities to the RN app for fortune optimization, push notifications, interactive tarot UI, home screen widgets, and calendar integration.
- Work type: Service / Widget / Screen / Native integration / Chat survey runtime
- Scope: `apps/mobile-rn/` with Flutter reference files under `lib/` and backend compatibility under `supabase/functions/`.
- Jira: blocked. `mcp__jira__createJiraIssue` failed for both `FORT` and `KAN` with `403 Tenant is restricted: suspended-inactivity`.

## 2. Search Strategy
- Keywords:
  - `fortune_optimization_service`
  - `cohort_fortune_service`
  - `fcm_service`
  - `widget_service`
  - `widget_data_service`
  - `unified_calendar_service`
  - `chat_tarot_draw_widget`
  - `card-draw`
  - `daily-calendar`
- Commands:
  - `rg -n "fortune_optimization_service|cohort_fortune_service|performance_cache_service|fcm_service|device_calendar_service|unified_calendar_service|widget_service|widget_data_service|interactive/tarot|tarot_.*page|chat_tarot_draw_widget|chat_inline_calendar|home_widget|expo-notifications|react-native-widget|notifications" lib apps/mobile-rn -S`
  - `rg --files apps/mobile-rn/src`
  - `sed -n '1,260p' apps/mobile-rn/src/features/chat-results/runtime-orchestrator.ts`
  - `sed -n '1,260p' lib/core/services/fortune_optimization_service.dart`
  - `sed -n '1,260p' lib/services/notification/fcm_service.dart`

## 3. Similar Code Findings
- Reusable:
  1. `apps/mobile-rn/src/features/chat-results/runtime-orchestrator.ts` - existing RN personal-cache and token orchestration for edge-backed fortunes.
  2. `apps/mobile-rn/src/features/chat-results/edge-runtime.ts` - existing RN fortune request normalization and edge invocation path.
  3. `apps/mobile-rn/src/lib/mobile-app-state.ts` - existing RN state contract for profile and notification preferences.
  4. `lib/core/services/fortune_optimization_service.dart` - Flutter 5-stage optimization policy and thresholds.
  5. `lib/services/notification/fcm_service.dart` - Flutter notification settings model and runtime responsibilities.
  6. `lib/features/chat/presentation/widgets/survey/chat_tarot_draw_widget.dart` - Flutter tarot interaction contract and payload shape.
  7. `lib/features/chat/presentation/widgets/survey/chat_inline_calendar.dart` - Flutter inline calendar UX and callback behavior.
  8. `lib/services/widget_data_service.dart` - Flutter widget snapshot/data refresh lifecycle and shared payload structure.
- Reference only:
  1. `apps/mobile-rn/src/features/chat-survey/registry.ts` - RN survey contracts already define `daily-calendar` and `tarot`.
  2. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` - RN rendering path currently treats `card-draw` as generic chips.
  3. `apps/mobile-rn/src/screens/profile-notifications-screen.tsx` - RN settings surface exists but is local-state only.
  4. `apps/mobile-rn/app/_layout.tsx` - best RN bootstrap point for notification listeners and widget sync.
  5. `packages/product-contracts/src/fortunes.ts` - shared fortune type/result contract and endpoint metadata.

## 4. Reuse Decision
- Reuse as-is:
  - RN `runtime-orchestrator.ts` persisted-result flow and token refund logic.
  - RN `edge-runtime.ts` endpoint resolution and payload normalization.
  - RN `mobile-app-state.ts` notification preference storage contract.
- Extend existing code:
  - Promote RN runtime orchestration into a broader fortune runtime service rather than rewriting from scratch.
  - Keep RN survey registry as the contract source, but replace `card-draw` rendering with a tarot-specific UI.
  - Keep RN notification settings screen and wire it to a real `expo-notifications` runtime.
- New code required:
  - `expo-notifications` service layer and response routing.
  - `expo-calendar` adapter and schedule context loading.
  - Tarot deck picker and draw surface under a dedicated RN feature folder.
  - iOS-first widget snapshot service plus Expo widget definition/config.
- Duplicate prevention notes:
  - Do not create a second survey registry.
  - Do not fork result payload contracts outside `chat-results/types.ts`.
  - Do not replicate Flutter widget native code inside RN; keep a JS snapshot contract and iOS-first widget definition.

## 5. Planned Changes
- Files to edit:
  1. `apps/mobile-rn/package.json`
  2. `apps/mobile-rn/app.config.ts`
  3. `apps/mobile-rn/app/_layout.tsx`
  4. `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  5. `apps/mobile-rn/src/screens/profile-notifications-screen.tsx`
  6. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  7. `apps/mobile-rn/src/features/chat-survey/registry.ts`
  8. `apps/mobile-rn/src/features/chat-results/runtime-orchestrator.ts`
  9. `apps/mobile-rn/src/features/chat-results/edge-runtime.ts`
  10. `apps/mobile-rn/src/lib/mobile-app-state.ts`
- Files to create:
  1. `apps/mobile-rn/src/lib/notifications/notification-service.ts`
  2. `apps/mobile-rn/src/lib/calendar/calendar-service.ts`
  3. `apps/mobile-rn/src/lib/widgets/fortune-widget-service.ts`
  4. `apps/mobile-rn/src/features/tarot/tarot-deck-picker.tsx`
  5. `apps/mobile-rn/src/features/tarot/tarot-card-draw.tsx`
  6. `apps/mobile-rn/src/features/tarot/tarot-payload.ts`
  7. `apps/mobile-rn/src/widgets/fortune-home-widget.tsx`

## 6. Validation Plan
- Static checks:
  - `npm run rn:typecheck`
  - `npx expo config --type public`
- Runtime checks:
  - verify notification permission flow and local scheduling code paths compile
  - verify calendar permission/read paths compile
  - verify tarot survey renders deck picker and card draw surface
  - verify widget snapshot service can be imported and widget definition builds at config level
- Test cases:
  1. `tarot` survey: deck pick -> purpose -> question -> card draw -> normalized payload.
  2. `daily-calendar` survey: choose sync/date -> fetch schedule context -> edge payload includes schedule summary.
  3. notifications: settings save -> permission request -> local test notification scheduling.
  4. fortune runtime: existing personal cache path still resolves and non-chat call sites can share it.
