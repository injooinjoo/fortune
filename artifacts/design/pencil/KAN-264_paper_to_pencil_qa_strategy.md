# KAN-264 Paper-to-Pencil Migration QA Strategy

## Scope

- Live Paper source: `Fortune` / `iPhone` page (`01K4GP58P8JRM8PGBP0586VKYV`)
- Live Paper inventory observed via MCP: `170` artboards
- Repo-side governed Paper contract: `26` artboards
  - `19` mobile surfaces
  - `7` catalog/governance boards
- Migration should run in two tracks:
  - `Track A`: governed canonical pages from `paper/catalog_inventory.json`
  - `Track B`: extended variants, light-mode alternates, result boards, archive/reference boards not yet in the governed contract

`Track A` is a zero-drift lane. `Track B` may import reference material, but it may not silently replace a governed route surface.

## 1. Review Dimensions

| Dimension | What is reviewed | Primary owner | Pass rule |
| --- | --- | --- | --- |
| Source fidelity | Root artboard size, visual hierarchy, color/typography intent, major spacing blocks | Import reviewer | Imported page matches Paper frame size exactly and preserves major section ordering |
| Structural completeness | Named sections, repeated groups, image/SVG presence, text blocks | Structural reviewer | No required section missing; repeated groups and assets preserved |
| Route semantics | `route`, `internal_state`, `design_only`, `catalog_section` labeling | Contract reviewer | Imported label matches `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md` or is explicitly marked as extended reference |
| Layout robustness | Clipping, overflow, off-canvas nodes, broken long-scroll content | Layout reviewer | No clipping/overflow problems in Pencil snapshots or layout checks |
| Traceability | Source node id, Paper title, batch id, reviewer decision, evidence links | QA gatekeeper | Every page has a complete artifact bundle and decision record |
| Drift governance | Canonical-vs-live differences and exception handling | Lead reviewer | Any non-canonical import is tagged as `variant/reference/archive` and linked to a canonical base when possible |

## 2. Measurable Acceptance Criteria Per Imported Page

Every imported page must satisfy the baseline criteria below.

| Area | Measurement | Acceptance target |
| --- | --- | --- |
| Root frame fidelity | Imported Pencil artboard width and height vs Paper artboard width and height | Exact match |
| Page naming | Pencil artboard name follows migration label format | Exact match |
| Top-level section retention | Count and order of direct semantic sections from Paper vs Pencil | Exact match for `Track A`; documented delta only for `Track B` |
| Headings and CTAs | Visible headings, tabs, chips, and CTA strings | 100% exact text match |
| Long-form content | Section heading count and paragraph-group count | Exact match for policy/reference screens |
| Asset retention | Count of image/SVG/icon-bearing groups | Exact match |
| Repeated content groups | Card/list/group count for repeated sections | Exact match for governed pages; if virtualized or intentionally collapsed, exception note required |
| Visual fit | Nodes extending outside artboard or reported as clipped | Zero |
| Route label correctness | Runtime kind and route/internal-state mapping | 100% exact match |
| Evidence completeness | Required screenshots and manifests stored | 100% complete |

Use this naming format for imported Pencil artboards:

- `[route] 01 - Splash :: /splash`
- `[internal_state] 09 - Character Chat :: /chat?openCharacterChat=true&characterId=:id`
- `[design_only] 04 - Nickname Fallback :: none`
- `[catalog_section] Paper Catalog · 10 Entry / Auth / Onboarding`
- `[extended_reference] <Paper title> :: variant_of:<canonical-base-or-none>`

Additional acceptance rules by page type:

| Page type | Extra rule |
| --- | --- |
| `route` | Route path must match the canonical mapping doc exactly |
| `internal_state` | Parent route and state expression must both be present in the label |
| `design_only` | Must not be counted as runtime coverage |
| `catalog_section` | Must not be mislabeled as a runnable route |
| `extended_reference` | Must declare whether it is `variant`, `archive`, `result`, or `component-reference` |

## 3. Batch Size Recommendations

Do not batch by arbitrary page count alone. Batch by structural complexity and route criticality.

| Batch tier | Typical pages | Batch size | Stop condition |
| --- | --- | --- | --- |
| Small | splash, auth fallback, simple static leaf pages | `4-6` pages | Stop if any page needs manual structural repair |
| Medium | onboarding steps, premium, profile hubs, settings screens | `3-4` pages | Stop if one page fails section retention or route labeling |
| Heavy | chat list, chat overlay, dense dashboards, result pages with repeated cards | `1-2` pages | Stop after first clipping or repeated-group loss |
| Long-scroll / catalog | policy pages, governance boards, component catalogs | `1` page | Review before importing the next board |

Recommended migration order:

1. `Track A` route pages in route-family batches
2. `Track A` internal-state pages
3. `Track A` catalog/governance boards
4. `Track B` variants grouped under the same canonical base

Hard batching rules:

- Never mix governed canonical pages and extended reference pages in the same review batch.
- Never mix `route` pages and `catalog_section` boards in the same review batch.
- If a batch contains a long-scroll page, cap the batch at that single page.
- After any failed batch, the next retry batch should contain only the corrected page(s).

## 4. Detecting Clipping, Structural Loss, and Mislabeled Routes

### Clipping

Use both structural and visual checks:

1. Capture the Paper source screenshot with `mcp__paper__get_screenshot`.
2. After import, run `mcp__pencil__snapshot_layout` on the imported node set with `problemsOnly: true`.
3. Capture the Pencil result with `mcp__pencil__get_screenshot`.
4. Flag the page if:
   - any node is reported as clipped or overflowing
   - any visible content extends outside the artboard bounds
   - long-scroll content height is shorter than the Paper source content grouping

### Structural loss

Create a source manifest before import and compare it with the Pencil result after import.

Paper-side source manifest:

- root artboard id and title
- width and height
- direct-child section names and count from `mcp__paper__get_tree_summary`
- text-bearing section labels
- asset-bearing groups from `mcp__paper__get_jsx`

Pencil-side target manifest:

- imported artboard id and title
- width and height
- direct-child structure from `mcp__pencil__batch_get`
- layout rectangles from `mcp__pencil__snapshot_layout`
- target screenshot from `mcp__pencil__get_screenshot`

Flag structural loss when any of the following occurs:

- a named Paper section is missing in Pencil
- direct-child section count differs on a governed page
- asset-bearing group count drops
- critical text labels disappear or merge into unlabeled blocks
- repeated groups shrink without an approved exception note

### Mislabeled routes

Use `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md` as the canonical route manifest for `Track A`.

Detection rule:

1. Build a per-page expected mapping from the Paper node id.
2. Compare the imported Pencil artboard label to the expected `runtime kind + route/state`.
3. Reject the page when:
   - a `design_only` page is labeled as a route
   - a `catalog_section` board is labeled as a route
   - a governed `route` page is missing its runtime path
   - an `internal_state` page omits the parent route or the state expression
   - an extended page claims a governed route without a canonical mapping update

## 5. Evidence To Store In Artifacts

Store evidence per batch and per page so later reviewers can decide without reopening Paper first.

Recommended artifact layout:

```text
artifacts/design/pencil/migration/
  batch-001/
    batch_manifest.json
    review_summary.md
    page-01-splash/
      source_paper.png
      target_pencil.png
      paper_tree.txt
      paper_jsx.tsx
      pencil_structure.json
      route_manifest.json
      layout_problems.json
      review_checklist.md
      decision.json
```

Required evidence per imported page:

- `source_paper.png`: source screenshot from Paper
- `target_pencil.png`: imported result screenshot from Pencil
- `paper_tree.txt`: source tree summary used for section counting
- `paper_jsx.tsx`: source JSX snapshot used for structural recovery
- `pencil_structure.json`: imported Pencil structure snapshot
- `route_manifest.json`: expected vs actual runtime-kind/route label
- `layout_problems.json`: result of Pencil layout inspection, even when empty
- `review_checklist.md`: pass/fail against the acceptance criteria
- `decision.json`: reviewer, timestamp, batch id, disposition, exception notes

Required evidence per batch:

- `batch_manifest.json`: batch id, route family, page list, import order, commit sha
- `review_summary.md`: defects found, corrected pages, unresolved risks

## Recommended QA Operating Model

- `Inventory lane`: groups pages into governed and extended lanes before import
- `Import lane`: performs the Paper-to-Pencil transfer in bounded batches
- `Structural lane`: checks tree/section preservation and asset retention
- `Contract lane`: checks route semantics and naming
- `Gate lane`: blocks promotion unless artifact completeness and acceptance criteria both pass

This is the minimum bar for a large migration where the source-of-truth file has already drifted beyond the governed repo contract.
