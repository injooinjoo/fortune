# Fortune Pencil Review Boards

This artifact package accompanies the active Pencil boards for the Fortune repo's current route, schema, and Paper-to-Pencil import work.

## KAN-263 Boards

1. `exports/Gw90a.png` — Overview and legend
2. `exports/Ch1v9.png` — Runtime route map
3. `exports/3fVt0.png` — Contract drift
4. `exports/STRjy.png` — Schema flow
5. `exports/XeglI.png` — Endpoint taxonomy
6. `exports/KXK1V.png` — Review board

## KAN-264 Boards

- `exports/737fD.png` — Canonical runtime import board
- `exports/pdJPQ.png` — Onboarding flow import board
- `exports/TBctN.png` — Chat and premium import board
- `exports/nqs1k.png` — Profile surfaces import board
- `exports/z5idK.png` — Splash import
- `exports/uYBc8.png` — Soft gate import
- `exports/lCbrH.png` — Auth callback import
- `exports/l9r0E.png` — Nickname fallback import

## KAN-266 Boards

- `exports/pdJPQ.png` — Onboarding flow import board
- `exports/TBctN.png` — Chat and premium import board
- `exports/nqs1k.png` — Profile surfaces import board
- `exports/GDQx6.png` — Profile detail import board
- `exports/VQyrC.png` — Account and policy import board
- `exports/flNyX.png` — Extended chat and friends import board

Supporting reports:

- `KAN-263_discovery_report.md`
- `KAN-264_discovery_report.md`
- `KAN-266_discovery_report.md`
- `KAN-264_paper_to_pencil_qa_strategy.md`

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
- Keep the governed Paper contract separate from the live extended Paper file during import.
- Make each Paper-to-Pencil import batch reviewable with persisted PNG exports.
- Keep the governed dark runtime set complete before moving into extended chat, friends, and light-mirror lanes.
