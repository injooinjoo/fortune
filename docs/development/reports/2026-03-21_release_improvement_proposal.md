# Improvement Proposal - Release Risk Hardening

Date: `2026-03-21`  
Jira: `KAN-155`

## 1. Objective
- Convert the audit findings into changes that reduce release risk without destabilizing the current `/chat`-centered product surface.
- Prefer governance and contract hardening before broad refactors.

## 2. Recommended Decisions

### A. Route and deep-link governance
- Decision:
  - Make `/chat` query parameters the only supported fortune-chat entry contract.
  - Resolve `/profile` status explicitly instead of letting docs and router disagree.
- Why:
  - The current state has two competing entry models:
    - query-driven `/chat?...`
    - `DeepLinkService` storing pending fortune type in local storage
  - That creates release-time ambiguity for QA, docs, and regression tests.
- Proposed changes:
  - Route inventory contract:
    - one source-of-truth table for active/inactive surfaces
    - one automated test that compares documented active routes to actual registered routes
  - Deep-link contract:
    - convert incoming links into `buildFortuneChatRoute(...)`
    - remove or deprecate `pending_deep_link_fortune_type` after compatibility window

### B. Chat-core architecture hardening
- Decision:
  - Reduce presentation-layer ownership of orchestration before adding more `/chat` features.
- Why:
  - The main surface is concentrated in very large provider/page files with direct data-service imports.
  - That raises regression probability even when individual diffs look small.
- Proposed changes:
  - Split `character_chat_provider.dart` into:
    - session state
    - outbound send pipeline
    - fortune launch adapter
    - proactive/follow-up orchestration
  - Introduce domain-facing use-case providers so presentation no longer talks to data services directly.
  - Move static catalog/default-character wiring behind registries or adapters.

### C. Edge function contract standardization
- Decision:
  - Treat fortune response shape as a hard interface, not a per-function convention.
- Why:
  - Success envelopes, alias fields, and provider access patterns still vary.
  - Client code already carries normalization baggage for legacy fields.
- Proposed changes:
  - Shared success response builder in `supabase/functions/_shared`.
  - Fortune schema conformance test that checks:
    - `success: true`
    - `data` wrapper
    - required fields: `fortuneType`, `score`, `content`, `summary`, `advice`, `timestamp`
  - Explicit exception register for non-standard endpoints, if any remain temporarily.
  - Migrate `fortune-yearly-encounter` direct Gemini calls onto the shared LLM path or a documented adapter.

### D. CI and audit signal quality
- Decision:
  - Stop treating first-party warnings as permanent background noise.
- Why:
  - Current CI is permissive enough that quality drift can merge while still appearing green.
  - Third-party vendored warnings are mixed with app warnings.
- Proposed changes:
  - Split analysis into:
    - first-party app/packages
    - vendored third-party code
  - Make first-party analyzer warnings fatal or baseline-managed.
  - Turn critical-surface coverage into a fail gate.
  - Keep optional quality services optional, but do not let app static analysis be advisory.

### E. Design-system enforcement
- Decision:
  - Enforce design-token usage selectively on presentation paths instead of attempting a single massive cleanup.
- Why:
  - The current debt is clustered enough to tackle in batches.
  - Token-definition files and live widgets should not be judged by the same rule.
- Proposed changes:
  - Allow hardcoded values in token definition files only.
  - Add a CI/search rule for presentation paths covering:
    - `Color(0x...)`
    - raw `fontSize:`
    - ad-hoc `TextStyle(`
  - Migrate the highest-traffic live widgets first, especially the `/chat` and fortune presentation surfaces.

## 3. Public Interfaces / Contract Changes To Plan
- Route contract:
  - Canonical deep-link target becomes `/chat` plus explicit query parameters.
- Fortune Edge response contract:
  - Canonical success envelope becomes `{ success: true, data: { ... } }`.
- Testing contract:
  - Route inventory and fortune schema drift should fail automated checks.

These should be implemented as deliberate contract changes with compatibility notes, not as silent refactors.

## 4. Suggested Ownership Split
- App routing and deep links:
  - mobile platform / router owner
- Chat-core decomposition:
  - main-surface owner
- Edge schema standardization:
  - backend / platform owner
- CI hardening:
  - release engineering / repository owner
- Design-system enforcement:
  - design-system owner plus feature maintainers

## 5. Success Criteria
- A release candidate cannot pass CI if first-party route or schema drift is introduced.
- `/chat` entry behavior is documented, tested, and consistent across deep link, share link, and internal navigation paths.
- Fortune Edge functions either conform to one schema or are explicitly tracked as exceptions.
- Design-token violations in presentation code stop growing release over release.
