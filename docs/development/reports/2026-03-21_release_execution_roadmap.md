# Execution Roadmap - Release Risk Hardening

Date: `2026-03-21`  
Jira: `KAN-155`

## 1. Immediate

### IM-001 Route and doc truth alignment
- Goal:
  - Remove the current disagreement between current-state docs and actual route registration.
- Actions:
  - Decide whether `/profile` remains active.
  - Update docs or router so both say the same thing.
  - Add one automated route inventory assertion.
- Acceptance criteria:
  - Active/inactive route tables match runtime router.
  - QA can trace every active route from docs to code.

### IM-002 Deep-link contract unification
- Goal:
  - Eliminate the split between `/chat` query contract and pending local-storage launch flow.
- Actions:
  - Convert deep links into `buildFortuneChatRoute(...)`.
  - Add tests for deep link -> route -> launch request.
  - Keep temporary compatibility only if a migration requirement is documented.
- Acceptance criteria:
  - One canonical chat-entry path exists for fortune launches.

### IM-003 Fortune Edge response inventory
- Goal:
  - Freeze the current drift before changing implementations.
- Actions:
  - Create a function-by-function conformance matrix for all `fortune-*` endpoints.
  - Mark which ones:
    - already use `success + data`
    - use top-level success only
    - return non-standard payloads
    - bypass shared LLM abstractions
- Acceptance criteria:
  - Every fortune endpoint has an explicit contract status.

### IM-004 CI signal tightening
- Goal:
  - Stop merging with silently tolerated first-party static drift.
- Actions:
  - Separate first-party analyze from vendored package analyze.
  - Make first-party warnings/info baseline-managed or fatal.
  - Convert coverage below threshold from warning-only to a real gate on targeted surfaces.
- Acceptance criteria:
  - CI green state represents first-party quality, not just command completion.

## 2. Next Sprint

### NS-001 Chat-core decomposition
- Goal:
  - Reduce regression blast radius on `/chat`.
- Actions:
  - Split `character_chat_provider.dart` into smaller orchestration units.
  - Move direct data-service dependencies behind use-case providers.
  - Add focused tests for each extracted responsibility.
- Acceptance criteria:
  - Main provider no longer owns unrelated responsibilities such as follow-up scheduling, fortune launch adaptation, and message delivery internals in one file.

### NS-002 Edge schema standardization
- Goal:
  - Make fortune endpoint contracts predictable.
- Actions:
  - Add shared success-envelope helpers.
  - Migrate the non-conforming endpoints first:
    - `fortune-investment`
    - `fortune-match-insight`
    - `fortune-new-year`
    - `fortune-past-life`
    - `fortune-time`
  - Remove legacy alias handling where clients have been updated.
- Acceptance criteria:
  - Standard success payload is enforced for prioritized fortune endpoints.

### NS-003 Design-system debt reduction
- Goal:
  - Stop style drift in live presentation code.
- Actions:
  - Exempt token files explicitly.
  - Migrate the worst live widget offenders first.
  - Add a design-system guard for presentation paths.
- Acceptance criteria:
  - Hardcoded style count drops in live widget files and stops growing in CI.

## 3. Structural

### ST-001 Contract drift automation
- Goal:
  - Catch route/schema drift as part of normal development.
- Actions:
  - Build repository checks for:
    - route inventory drift
    - fortune schema drift
    - design-system drift on presentation paths
- Acceptance criteria:
  - Drift is detected before release review, not during release review.

### ST-002 Repository architecture guardrails
- Goal:
  - Make presentation-to-data violations harder to introduce.
- Actions:
  - Add import-boundary checks for `presentation -> data`.
  - Create allowed-exception lists where current migration requires them.
  - Measure boundary debt over time.
- Acceptance criteria:
  - Architecture debt is visible and trendable, not anecdotal.

### ST-003 Shared LLM platform adoption
- Goal:
  - Remove ad-hoc model/provider integrations from feature functions.
- Actions:
  - Route all supported fortune endpoints through shared LLM modules or documented adapters.
  - Track justified exceptions with owners and deadlines.
- Acceptance criteria:
  - Fortune functions no longer embed unmanaged provider calls in isolated feature code.
