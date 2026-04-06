# KAN-264 Discovery Report

## Scope

- Jira: `KAN-264`
- Source of truth: `Paper` live file `Fortune / iPhone`
- Paper file key: `01KMJD3WXNSR5HKNY18HHHKHH2`
- Live inventory observed through MCP: `170` artboards, `9405` nodes
- Repo-governed Paper contract: `26` artboards
  - `19` canonical mobile surfaces
  - `7` catalog/governance boards

## Key Drift

- Live Paper has expanded well beyond the governed repo contract.
- Canonical route surfaces still exist, but several names and semantics have drifted.
- High-signal drift examples:
  - `8B-0` is now a signup / soft-gate composition.
  - `E3-0` is a dedicated `Auth Callback /auth/callback` family board.
  - `8C-0` is a nickname fallback state, not a full onboarding page.
  - Live Paper includes extended chat, friends, fortune result, and light-mode mirror lanes that are not part of the `26`-board governed contract.

## Import Lanes

1. `Catalog / governance`
   - `M9-1`, `10X-1`, `10Y-1`, `10Z-1`, `110-1`, `111-1`, `112-1`
2. `Canonical runtime`
   - `8A-0`, `8B-0`, `E3-0`, `8C-0`, `9P-0`, `E4-0`, `E5-0`, `9Q-0`, `9R-0`, `E6-0`, `9S-0`, `4TR-1`, `EB-0`, `EC-0`, `3TB-1`, `ED-0`, `E9-0`, `E7-0`, `E8-0`
3. `Extended chat / friends`
4. `Light mirrors`
5. `Fortune result base`
6. `Fortune result light / outlier`

## Import Strategy

- Use `Paper JSX -> layout AST -> Pencil batch_design -> screenshot QA`.
- Keep import geometry exact on first pass.
- Tokenization and refactoring happen only after the imported page matches the Paper screenshot baseline.
- Batch by route family and structural complexity, not by arbitrary page count.

## Batch 001

The first persisted import batch focused on canonical runtime pages with high review value.

- `8A-0` `01 - Splash /splash`
- `8B-0` `02 - Entry Hero / Soft Gate`
- `E3-0` `03 - Auth Callback /auth/callback`
- `8C-0` `11 - Onboarding Nickname /onboarding`

## Persisted Outputs

- Board export: `artifacts/design/pencil/exports/737fD.png`
- Page exports:
  - `artifacts/design/pencil/exports/z5idK.png`
  - `artifacts/design/pencil/exports/uYBc8.png`
  - `artifacts/design/pencil/exports/lCbrH.png`
  - `artifacts/design/pencil/exports/l9r0E.png`

## QA Notes

- Baseline verification used Paper screenshots plus Pencil screenshots.
- The imported pages visually align with the source compositions.
- Remaining `snapshot_layout(problemsOnly)` flags are limited to intentionally cropped decorative background rings on:
  - `8B-0`
  - `E3-0`
