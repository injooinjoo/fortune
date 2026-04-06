# Fortune Pencil Review Board

Jira: `KAN-263`

This artifact package accompanies the active Pencil board for the Fortune repo's current route and schema truth.

## Boards

1. `exports/Gw90a.png` — Overview and legend
2. `exports/Ch1v9.png` — Runtime route map
3. `exports/3fVt0.png` — Contract drift
4. `exports/STRjy.png` — Schema flow
5. `exports/XeglI.png` — Endpoint taxonomy
6. `exports/KXK1V.png` — Review board

## Source Inputs

- `lib/routes/route_config.dart`
- `lib/routes/routes/auth_routes.dart`
- `lib/routes/character_routes.dart`
- `packages/product-contracts/src/routes.ts`
- `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
- `packages/product-contracts/src/fortunes.ts`
- `packages/product-contracts/src/fortune-result-normalizer.ts`
- `.claude/docs/05-fortune-system.md`
- `.claude/docs/25-fortune-result-schemas.md`

## Review Intent

- Make the live `/chat`-centric route truth obvious.
- Expose contract-only routes such as `/fortune` and `/trend`.
- Show how fortune types, endpoint resolution, and normalization differ from a naive 1:1 mental model.
- Give reviewers concrete decisions instead of passive documentation.
