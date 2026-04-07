# KAN-263 Discovery Report

## Goal

Create a reviewable Pencil deliverable that visualizes the current route truth and schema/data-flow truth for the Fortune repository.

## Sources Searched

- `lib/routes/route_config.dart`
- `lib/routes/character_routes.dart`
- `lib/routes/routes/auth_routes.dart`
- `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
- `packages/product-contracts/src/routes.ts`
- `.claude/docs/05-fortune-system.md`
- `.claude/docs/25-fortune-result-schemas.md`
- `packages/product-contracts/src/fortunes.ts`
- `packages/product-contracts/src/fortune-result-normalizer.ts`
- `lib/core/navigation/fortune_chat_route.dart`
- `lib/services/deep_link_service.dart`

## Reuse / Reference Decision

- Reuse route grouping from `packages/product-contracts/src/routes.ts` where it still matches runtime.
- Prefer runtime truth from `lib/routes/*.dart` and `docs/getting-started/APP_SURFACES_AND_ROUTES.md` when contract and runtime differ.
- Reuse the common fortune envelope and normalization rules from `packages/product-contracts/src/fortune-result-normalizer.ts`.
- Reference fortune buckets and endpoint resolution rules from `packages/product-contracts/src/fortunes.ts`.

## Route Truth Summary

### Live runtime routes

- Core shell: `/chat`
- Auth/bootstrap: `/splash`, `/signup`, `/auth/callback`
- Onboarding: `/onboarding`, `/onboarding/toss-style`
- Commerce/account: `/premium`, `/account-deletion`
- Profile tree: `/profile`, `/profile/edit`, `/profile/saju-summary`, `/profile/relationships`, `/profile/notifications`
- Legal: `/privacy-policy`, `/terms-of-service`
- Character support: `/character/:id`
- Friend creation flow: `/friends/new/basic`, `/friends/new/persona`, `/friends/new/story`, `/friends/new/review`, `/friends/new/creating`

### Redirect-only routes

- `/` -> `/chat`
- `/home` -> `/chat`

### Contract-only drift

- `/fortune`
- `/trend`

## Surface Truth Summary

- `/chat` is the only live primary product surface.
- `/chat` contains two internal experience modes:
  - General chat
  - Curiosity (fortune-expert + survey/result flow)
- Deep links with `fortuneType` resolve into `/chat`, not `/fortune`.

## Schema Truth Summary

### Common envelope

```ts
type FortuneEnvelope<T> = {
  success: true;
  data: T;
  error?: string;
}
```

### Normalized top-level result fields

- `fortuneType`
- `score`
- `content`
- `summary`
- `advice`
- `timestamp`

### Endpoint resolution rules

- Standard types resolve directly to an Edge Function endpoint.
- `family` resolves through `resolveFamilyApiType(...)` and expands to one of:
  - `family-health`
  - `family-wealth`
  - `family-children`
  - `family-relationship`
  - `family-change`
- Some types reuse another API type through `apiType`.
- Some types are `isLocalOnly: true` and do not hit a remote endpoint.

### Complexity hotspots worth showing

- Contract has 48 fortune type specs, including 11 local-only flows.
- Runtime response payloads vary widely by fortune type.
- `normalizeFortuneResult(...)` acts as the compatibility layer that flattens payload drift into a stable chat/result shape.

## Diagram Decision

Build the Pencil deliverable as multiple artboards:

1. Runtime route map
2. `/chat` internal surface and deep-link entry
3. Contract vs runtime drift board
4. Fortune schema spine and normalizer
5. Endpoint resolution and fortune type buckets
6. Review notes / hotspots

## Clutter To Avoid

- Do not enumerate all 44 fortune schema payloads in full.
- Do not present inactive contract routes as if they are live runtime routes.
- Do not mix user-facing surfaces and technical normalization layers on the same board unless the relationship is explicit.
