# Global Codex Overrides (Fortune)

## Scope
- Apply these rules when cwd is `/Users/jacobmac/Desktop/Dev/fortune`.

## Jira MCP
- Do not claim "JIRA MCP unavailable" unless `mcp__jira__getAccessibleAtlassianResources` fails in the current turn.
- Do not use `list_mcp_resources` emptiness as Jira availability evidence.
- Start development tasks by creating a Jira issue via MCP.
- Project key selection:
  1. `FORT` if visible and creatable
  2. `KAN` as fallback

## Git Push + Actions
- For any code change, run `git commit`, `git push`, then GitHub Actions status checks by default.
- Never skip push/actions with the reason "not requested".
- After push, check workflows with `gh run list --branch <branch> --limit 5` and verify latest run status.

## Reporting
- Include Jira issue key, push result, and workflow status in completion reports.

--- project-doc ---

# Fortune Repository Rules for Codex

> Current runtime: React Native / Expo under `apps/mobile-rn/`.

## 1. Priority
- Follow the user's explicit instruction first.
- Then follow system/security constraints.
- Then follow this file and `CLAUDE.md`.
- If documents conflict, treat `apps/mobile-rn/`, `packages/`, and `supabase/functions/` as runtime truth.

## 2. Jira
- Development work starts with a Jira issue through MCP when the Jira MCP tool is exposed.
- Prefer `FORT`; fallback to `KAN`.
- On completion, transition the issue to Done and add a resolution comment when the MCP tool is available.
- If Jira tooling is not exposed in the current session, record that fact and continue the local work.

## 3. Active Architecture
- Mobile app: `apps/mobile-rn/`
- Routing: `apps/mobile-rn/app/` via `expo-router`
- UI primitives: `apps/mobile-rn/src/components/`
- Feature slices: `apps/mobile-rn/src/features/`
- Runtime logic/client/storage/theme: `apps/mobile-rn/src/lib/`
- Global state: `apps/mobile-rn/src/providers/` with React Context + hooks
- Shared contracts: `packages/product-contracts`, `packages/design-tokens`, `packages/saju-engine`
- Server: `supabase/functions/` and `supabase/migrations/`

## 4. RN Coding Rules
- Use TypeScript with strict types.
- Do not introduce Redux, Zustand, MobX, Jotai, or another global store unless explicitly requested.
- Use `AppText` and `fortuneTheme` for UI text/color styling.
- Keep route files thin; put screen composition in `src/screens/` or feature slices.
- Do not call Supabase Edge Functions directly from arbitrary UI components; use `src/lib/*-remote.ts` or the established feature runtime adapters.
- Use `FortuneHapticService` / existing haptics helpers rather than direct native haptic calls where an app helper exists.

## 5. Forbidden Patterns
- Do not run `expo start`, `npx expo start`, `npx expo run:ios`, or `npx expo run:android` from automation.
- Do not use broad script-based rewrites, shell replace-all commands, or loop-based multi-file edits.
- Do not hardcode UI colors/fonts inside RN components when a token/component exists.
- Do not call OpenAI/Gemini directly from Edge Functions; use the shared LLM factory/prompt modules.
- Do not hide errors with empty catches, print-only catches, or unexplained null guards.
- Do not commit secrets.

## 6. Search Before Changing
- Before adding or replacing code, search for the existing RN pattern first.
- Preferred searches:
  - `rg "createContext" apps/mobile-rn/src`
  - `rg "AppText" apps/mobile-rn/src`
  - `rg "fortuneTheme" apps/mobile-rn/src`
  - `rg "functions.invoke" apps/mobile-rn/src supabase/functions`
  - `rg "ChatShellMessage" apps/mobile-rn/src`
  - `rg "resolveResultKindFromFortuneType" apps/mobile-rn/src packages`
- State the reuse decision: reuse, extend, or create new.

## 7. Bug Fix RCA
- For bug/error work, identify WHY, WHERE, WHERE ELSE, HOW before editing.
- Search for the same pattern globally.
- Fix the root cause, not just the symptom.

## 8. Verification
- Default verification for code changes:
  1. `npm run rn:typecheck`
  2. `npm run rn:test` when shared contracts or fortune pricing/contracts are touched
  3. `pnpm --filter @fortune/mobile-rn lint` when RN UI/app code is touched
  4. targeted Supabase `deno check` when Edge Functions are touched
- UI/page/route changes should include a concrete manual test scenario for the user.
- Do not declare completion until verification results and any blockers are reported.

## 9. Git
- Keep changes scoped to the request.
- Do not revert user changes.
- Commit message format: `[<JIRA-KEY>] <type>: <summary>`.
- If Jira was not created because tooling was not exposed, use `[NO-JIRA]`.
- Push after committing and check the latest GitHub Actions run for the branch.

## 10. Completion Report
- Include changed file groups.
- Summarize the core behavior/config cleanup.
- Include verification results.
- Include Jira issue key or tooling limitation.
- Include push result and GitHub Actions status.
