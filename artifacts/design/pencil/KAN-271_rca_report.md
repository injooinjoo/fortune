# KAN-271 RCA Report

## 1. Symptom
- Error message:
  - No tool-level error was raised. The defect is a false-completion / visual-fidelity failure.
- Repro steps:
  1. Open the active Pencil file `/Users/jacobmac/Desktop/Dev/fortune/pencil`.
  2. Review the imported fortune boards (`40jKu`, `kLXU2`, `t3m5f`, `3ArjO`) and compare them against the live Paper source file.
  3. Inspect the imported screens directly in Pencil screenshots.
- Observed behavior:
  - The import set is incomplete relative to the Paper source of truth. Full Paper root inventory shows `170` artboards, including dark and light result pages through `F50`, redesign boards, and chat-specific reference surfaces that are not present in Pencil.
  - Light mirror lanes are still missing, and some earlier boards remain live-only rather than persisted/exported.
  - Several imported screens are compressed approximations rather than 1:1 imports.
  - Internal Pencil node names are inconsistent with the actual screen content because cloned bases were not fully renamed after transformation.
- Expected behavior:
  - Every intended Paper page lane should be explicitly tracked as imported or pending.
  - Imported screens should preserve section structure and text wrapping without visual compression or overflow.
  - Pencil node labels and screen names should match the actual imported Paper artboard.

## 2. WHY (Root Cause)
- Direct cause:
  - Completion was judged from board presence and `snapshot_layout(problemsOnly)` results, not from exhaustive Paper-to-Pencil parity review.
- Root cause:
  - The import workflow optimized for batch velocity with clone-first simplification, but it lacked a hard gate for:
    - exhaustive coverage manifest
    - screenshot-level visual review per screen
    - semantic integrity checks after cloning
- Data/control flow:
  - Step 1: Paper screens were grouped into review boards and cloned in batches.
  - Step 2: `snapshot_layout(problemsOnly)` validated structural clipping but did not detect fidelity loss, compressed content, or semantic mismatches.
  - Step 3: Reports/README recorded imported batches, but there was no single manifest proving all intended Paper lanes were covered.

## 3. WHERE
- Primary location:
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/README.md`
- Related call sites / evidence:
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-264_discovery_report.md`
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-265_discovery_report.md`
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-266_discovery_report.md`
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-268_discovery_report.md`
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-269_discovery_report.md`
  - Active Pencil nodes with semantic mismatch:
    - `8j2pE` showing `F14 Personality` content while named `Coaching Import`
    - `SMgJ7` showing `F15 Wealth` content while named `Career Import`
    - `EuFR9` showing `F16 Talent` content while named `Relationship Import`
    - `RmsyG` showing `F19 Game Enhance` content while named `Health Import`
    - `gTmbS` showing `F20 OOTD` content while named `Coaching Import`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "3WD-1|3ZC-1|light-mode mirror lanes|Light" artifacts/design/pencil/KAN-26*.md artifacts/design/pencil/KAN-27*.md`
  - `pencil.get_editor_state(include_schema=true)`
  - `paper.get_basic_info()`
  - `pencil.batch_get()` / `pencil.get_screenshot()` on imported boards and screens
- Findings:
  1. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-265_discovery_report.md` - explicitly recorded pending screens and remaining light-mode mirror lanes.
  2. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-266_discovery_report.md` - marked `VQyrC` and `flNyX` as live-only, confirming persisted coverage was not complete.
  3. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/README.md` - still describes batch boards but not a complete Paper coverage manifest.
  4. `paper.get_tree_summary(root, depth=1)` - exposed the previously untracked scope: `F21` through `F50`, `D01`, `D02`, and `25 - Chat Fortune Card /chat`, plus full light mirrors.
  5. Active Pencil editor - shows only 18 top-level review boards while Paper contains 170 artboards, so “all imported” was not a defensible claim.

## 5. HOW (Correct Pattern)
- Reference implementation:
  - `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-264_paper_to_pencil_qa_strategy.md`
- Before:
```text
Batch board exists
+ snapshot_layout(problemsOnly) clean
= treated as complete
```
- After:
```text
Per-Paper-artboard manifest
+ imported screen screenshot
+ semantic node naming check
+ visual comparison against Paper section order / density
= only then mark as complete
```
- Why this fix is correct:
  - It closes the exact gap that produced the false “done” signal: missing coverage and visual/semantic drift that structural layout checks alone cannot detect.

## 6. Fix Plan
- Files / assets to change:
  1. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/README.md` - replace implied completion language with explicit coverage status.
  2. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-271_rca_report.md` - preserve the defect analysis.
  3. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/pencil/KAN-271_discovery_report.md` - track the Paper root inventory and the real Pencil coverage baseline.
  4. Active Pencil boards - rename mis-cloned screen nodes, build a missing-lane manifest, then re-import/fix offending screens.
  5. Active Pencil board `NPZob` - keep the missing-lane register visible inside Pencil while the remaining imports are still pending.
- Risk assessment:
  - Medium. Pencil edits can be broad, but they are isolated to review artifacts and should not affect app runtime.
- Validation plan:
  - Re-check board screenshots after each corrected screen.
  - Maintain a Paper coverage checklist with imported vs pending lanes.
  - Only report completion after both dark and light target lanes are explicitly accounted for.
