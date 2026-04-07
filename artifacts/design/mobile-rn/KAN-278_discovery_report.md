# KAN-278 Discovery Report

## Goal

- Align `apps/mobile-rn` route coverage with the documented runtime structure.
- Implement the highest-value missing route targets and button destinations first.
- Use repo docs and Pencil boards as the source of truth for RN route behavior.

## Source Inputs

- `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
- `.claude/docs/paper-artboard-map.md`
- `artifacts/design/paper_sync/mapping.json`
- `artifacts/design/pencil/README.md`
- `artifacts/design/pencil/exports/TBctN.png`
- `artifacts/design/pencil/exports/nqs1k.png`
- `artifacts/design/pencil/exports/xzctJ.png`
- `artifacts/design/pencil/exports/GDQx6.png`

## Searches

- `find apps/mobile-rn/app -maxdepth 4 -type f | sort`
- `rg -n "friends/new|Friend|creating|persona|review|story" apps/mobile-rn packages/product-contracts`
- `rg -n "프로필|premium|friends/new|스토리|운세보기|프로필 보기" apps/mobile-rn/src`
- `sed -n '1,320p' apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `sed -n '1,320p' apps/mobile-rn/src/screens/chat-screen.tsx`
- `sed -n '1,360p' apps/mobile-rn/src/screens/profile-screen.tsx`
- `sed -n '1,220p' apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
- `sed -n '1,220p' apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
- `sed -n '1,320p' lib/features/character/presentation/pages/friend_creation_pages.dart`

## Existing Files Reviewed

### Reusable

1. `apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
   - Real RN screen already exists.
   - Only the route file redirects incorrectly.

2. `apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
   - Real RN screen already exists.
   - Only the route file redirects incorrectly.

3. `apps/mobile-rn/src/screens/route-screen.tsx`
   - Reusable for route inventory placeholders.
   - Not sufficient for the friend builder flow because the docs require a real multi-step sequence.

4. `lib/features/character/presentation/pages/friend_creation_pages.dart`
   - Canonical field grouping and step order for the friend builder.
   - RN should mirror the step breakdown instead of inventing new form structure.

5. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
   - Existing home/list/chat shell primitives.
   - Best insertion point for a new friend entry CTA.

### Redirect Placeholder Routes

1. `apps/mobile-rn/app/friends/new/basic.tsx`
2. `apps/mobile-rn/app/friends/new/persona.tsx`
3. `apps/mobile-rn/app/friends/new/story.tsx`
4. `apps/mobile-rn/app/friends/new/review.tsx`
5. `apps/mobile-rn/app/friends/new/creating.tsx`
6. `apps/mobile-rn/app/(tabs)/profile/relationships.tsx`
7. `apps/mobile-rn/app/(tabs)/profile/saju-summary.tsx`
8. `apps/mobile-rn/app/splash.tsx`

## Missing Button -> Route Coverage

### Chat runtime

- Missing: friend creation entry from `/chat`
  - Doc / Pencil basis: `3Y2-1` (`Chat Friend Picker`) and `3ZB-1` -> `3ZF-1`
  - Target: `/friends/new/basic`

- Missing: dedicated friend entry CTA in the first-run list surface
  - Current UI has character selection and result action routing only.
  - Pencil shows a direct `새 친구 만들기` bridge from chat into the builder flow.

### Profile hub

- Missing: `/profile/saju-summary` menu entry
- Missing: `/profile/relationships` menu entry
- Existing screens already exist but are unreachable from the hub and route files still redirect.

### Friend builder wizard

- Missing real RN screens for:
  - `/friends/new/basic`
  - `/friends/new/persona`
  - `/friends/new/story`
  - `/friends/new/review`
  - `/friends/new/creating`

- Required flow:
  - `basic -> persona -> story -> review -> creating -> /chat`

## Button -> Route Matrix

| Surface | Button / CTA | Target |
|---|---|---|
| `/chat` first-run | `새 친구 만들기` | `/friends/new/basic` |
| `/chat` first-run | character row | internal chat overlay state |
| `/chat` first-run | result action card | `/result/[resultKind]` |
| `/chat` active chat | `프로필 보기` | `/character/:id` |
| `/chat` first-run | recent result reopen | `/result/[resultKind]` |
| `/profile` | `프로필 수정` | `/profile/edit` |
| `/profile` | `사주 요약` | `/profile/saju-summary` |
| `/profile` | `인간관계` | `/profile/relationships` |
| `/profile` | `알림 설정` | `/profile/notifications` |
| `/profile` | `구독 및 토큰` | `/premium` |
| `/profile` | `개인정보처리방침` | `/privacy-policy` |
| `/profile` | `이용약관` | `/terms-of-service` |
| `/profile` | `계정 삭제` | `/account-deletion` |
| `/profile/relationships` | `새 친구 만들기` | `/friends/new/basic` |
| `/friends/new/basic` | `다음` | `/friends/new/persona` |
| `/friends/new/persona` | `이전` | `/friends/new/basic` |
| `/friends/new/persona` | `다음` | `/friends/new/story` |
| `/friends/new/story` | `이전` | `/friends/new/persona` |
| `/friends/new/story` | `다음` | `/friends/new/review` |
| `/friends/new/review` | `이전` | `/friends/new/story` |
| `/friends/new/review` | `대화 시작하기` | `/friends/new/creating` |
| `/friends/new/creating` | `채팅으로 이동` | `/chat` |

## Reuse Decision

### Reuse directly

- `ProfileSajuSummaryScreen`
- `ProfileRelationshipsScreen`
- `Screen`, `Card`, `Chip`, `PrimaryButton`

### Extend

- `ChatFirstRunSurface`
  - Add explicit friend-builder entry CTA.

- `ProfileScreen`
  - Add missing menu rows for `saju-summary` and `relationships`.

### New code required

- RN friend builder draft state and five route-backed screens.
- Route file replacements for the current redirect placeholders.
- A real `/splash` RN surface instead of a redirect.

## Implementation Priority

1. Replace redirect placeholders for `/profile/saju-summary` and `/profile/relationships`.
2. Add missing profile hub buttons that route into those screens.
3. Implement the five-step `/friends/new/*` wizard in RN.
4. Add a visible `/chat` entry CTA that launches the friend builder.
5. Restore `/splash` as an actual route surface that reflects bootstrap state and links into the documented next routes.

## Implementation Result

- `/profile/saju-summary` now mounts `ProfileSajuSummaryScreen`.
- `/profile/relationships` now mounts `ProfileRelationshipsScreen`.
- `/profile` now exposes both submenu buttons.
- `/friends/new/basic|persona|story|review|creating` now mount real RN screens.
- `/chat` first-run surface now exposes `새 친구 만들기`.
- `/splash` now mounts the existing RN splash screen instead of redirecting immediately.

## Duplicate Prevention

- Do not create a second profile detail screen for routes that already have `src/screens/*`.
- Do not invent new friend-builder field groups; mirror the Flutter `friend_creation_pages.dart` structure.
- Do not expand `/fortune` or `/trend`; docs mark them as inactive top-level runtime routes for now.
