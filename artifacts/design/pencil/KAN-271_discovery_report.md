# KAN-271 Discovery Report

## Scope

- Jira: `KAN-271`
- Source of truth: `Paper` live file `Fortune / iPhone`
- Paper file key: `01KMJD3WXNSR5HKNY18HHHKHH2`
- Pencil target: `/Users/jacobmac/Desktop/Dev/fortune/pencil`
- Goal: replace the false `complete` assumption with an explicit Paper-vs-Pencil coverage inventory, then use that inventory to drive the next Pencil import and repair passes.

## Discovery Commands And MCP Reads

- `paper.get_basic_info()`
- `paper.get_children(root_node_01K4GP58P8JRM8PGBP0586VKYV)`
- `paper.get_tree_summary(root_node_01K4GP58P8JRM8PGBP0586VKYV, depth=1)`
- `pencil.get_editor_state(include_schema=false)`
- `pencil.batch_get()` on the active import boards
- `pencil.get_screenshot()` on active fortune import nodes
- `rg -n "Paper Import|paper import|pencil" artifacts/design/pencil`

## Current Pencil Coverage Confirmed

### Runtime And Catalog Boards

- `737fD` — canonical runtime imports
- `pdJPQ` — onboarding dark runtime imports
- `TBctN` — chat and premium dark runtime imports
- `nqs1k` — profile dark runtime imports
- `GDQx6` — profile detail dark runtime imports
- `zdNyo` — account and policy dark runtime imports
- `pu8Go` — chat returning and friend entry dark runtime imports
- `xzctJ` — friend builder dark runtime imports

### Fortune Boards

- `40jKu` — `F01` through `F06` dark
- `YDnYY` — `F01` through `F06` light
- `kLXU2` — `F07` through `F10` dark
- `t3m5f` — `F11` through `F14` dark
- `3ArjO` — `F15` through `F20` dark
- `NPZob` — explicit gap register derived from the full Paper root inventory
- `p2GZ0` — explicit fortune coverage audit board built from the Paper root inventory
- `Cb3U7` — `F07` through `F10` light
- `1sd5C` — `F11` through `F14` light
- `VWy55` — `F15` through `F20` light

## Confirmed Gaps

The active Pencil file does not currently contain the full Paper fortune catalog.

### Missing Fortune Results

- `F21` through `F50` dark
- `F21` through `F50` light
- `D01` and `D02` redesign reference boards
- `25 - Chat Fortune Card /chat`

### Missing Runtime Light Mirrors

- splash
- signup
- auth callback
- onboarding nickname, birth, interest, handoff, toss
- chat first run, chat returning, chat character, friend picker
- premium
- profile, profile edit, saju summary, relationships, notifications, account deletion, character profile
- privacy policy and terms
- friend basic, persona, story, review, creating

## Paper Evidence For The Gaps

`paper.get_tree_summary(root_node_01K4GP58P8JRM8PGBP0586VKYV, depth=1)` confirmed all of the following still exist in Paper but are not yet represented as their own Pencil imports:

- `F19 - 게임 강화운 (Light)` — `B25-0`
- `F20 - OOTD 코디 (Light)` — `B42-0`
- `F21 - 시험운 /fortune/exam` — `6VU-1`
- `F22 - 궁합 /fortune/compatibility` — `6VV-1`
- `F23 - 소개팅운 /fortune/blind-date` — `6VW-1`
- `F24 - 피해야 할 인연 /fortune/avoid-people` — `6VX-1`
- `F25 - 재회운 /fortune/ex-lover` — `6VY-1`
- `F26 - 연간 만남 /fortune/yearly-encounter` — `6VZ-1`
- `F27 - 의사결정 /fortune/decision` — `6W0-1`
- `F28 - 일일 리뷰 /fortune/daily-review` — `6W1-1`
- `F29` through `F50` dark and light
- `D01 - 오늘의 운세 /fortune/daily (Redesign)` — `8FJ-0`
- `D02 - 오늘의 운세 v2 하단 (Redesign)` — `8KD-0`
- `25 - Chat Fortune Card /chat` — `CD4-0`
- `F19 - 게임 강화운 (Light)` also appears as `H5D-0`
- `F20 - OOTD 코디 (Light)` also appears as `H5E-0`

## Quality Findings On Existing Fortune Imports

- The current `F01` through `F20` dark boards are reviewable, but they represent only a subset of the Paper fortune catalog.
- Their current validation is structural, not exhaustive visual parity.
- Existing exports show clone-first normalization across the fortune family, which is good enough for batch review but not sufficient to claim `full Paper coverage`.
- `F14` Personality and `F20` OOTD received a first fidelity repair pass to remove obvious chip/text compression in the review exports, but the remaining family still needs page-by-page parity work.
- A full `snapshot_layout(problemsOnly)` sweep across all imported dark result screens `F01` through `F20` is now clean after width and wrapping fixes on:
  - `F07` Career
  - `F10` Coaching
  - `F12` Mystical
  - `F14` Personality
  - `F15` Wealth
  - `F16` Talent
  - `F17` Exercise
  - `F18` Tarot
  - `F19` Game Enhance
  - `F20` OOTD
- `F01` through `F20` light now exist as separate Pencil review boards, but they are still theme-converted review lanes, not final page-parity sign-off.

## Decision

- Do not claim `Paper complete` or `fortune complete` from the current Pencil state.
- Treat the current Pencil state as:
  - dark fortune batch coverage through `F20`
  - light fortune coverage through `F20`
  - selected dark runtime boards
- Use the missing inventory above as the next import queue.

## Next Import Queue

1. `F21` through `F28` dark and light
2. `F29` through `F38` dark and light
3. `F39` through `F50` dark and light
4. `D01`, `D02`, and `Chat Fortune Card`
