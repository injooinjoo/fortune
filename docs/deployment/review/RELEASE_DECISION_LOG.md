# Release Decision Log (Store Submission)

## 1. Decision Rule
- Final decision is binary: `GO` or `NO-GO`.
- Mandatory policy:
  - If any `P0` is `fail` or `pending` -> `NO-GO`
  - If any `P1` is `fail` or `pending` -> `NO-GO`

## 2. Fixed Fields
Use the same fixed fields for decision-gate checks:
- `check_id`
- `severity(P0/P1/P2)`
- `result(pass/fail/pending)`
- `evidence(path|url|screenshot)`
- `owner`
- `due_date`
- `status(open/in_progress/done/blocked)`

## 3. Decision Gate Checklist
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| DEC-001 | P0 | Frozen commit SHA captured for this candidate | pass | `c3f9a953ea6295498605cb18211ac63185ecb582` | release-owner | 2026-02-16 | done |
| DEC-002 | P0 | Master checklist P0 items all pass | fail | `/docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md` (`COM-IAP-001` pending) | release-owner | 2026-03-20 | blocked |
| DEC-003 | P1 | Master checklist P1 items all pass | fail | Open P1 items remain in iOS/Android evidence (`IOS-PERM-005`, `IOS-LINK-003`, `AND-PERM-002`, `AND-DATA-002~003` 등) | release-owner | 2026-03-20 | open |
| DEC-004 | P0 | iOS evidence checklist has no open P0/P1 | fail | `/docs/deployment/review/IOS_REVIEW_EVIDENCE.md` (`IOS-IAP-001~003`, `IOS-PERM-005`, `IOS-LINK-003` pending) | ios-owner | 2026-03-20 | open |
| DEC-005 | P0 | Android evidence checklist has no open P0/P1 | fail | `/docs/deployment/review/ANDROID_REVIEW_EVIDENCE.md` (`AND-IAP-001`, `AND-LINK-004`, `AND-STAB-003`, `TC-AND-*` pending) | android-owner | TBD | open |
| DEC-006 | P0 | Manual scenario evidence uploaded for required test cases | pending | QA artifact index | qa-owner | TBD | open |
| DEC-007 | P0 | Risk approver explicitly signs off decision | pending | approver name + timestamp | release-manager | TBD | open |

## 4. Decision Entry Template
Copy this section for each release candidate.

### Candidate
- release_candidate:
- jira_issue:
- frozen_commit_sha:
- created_at:
- evaluator:

### Gate Summary
- p0_open_count:
- p1_open_count:
- p2_open_count:
- unresolved_issue_keys:
- unresolved_check_ids:

### Decision
- decision: `GO` / `NO-GO`
- reason_summary:
- risk_approver:
- approved_at:

### Evidence Index
- master_checklist:
- ios_evidence:
- android_evidence:
- qa_artifacts:
- build_logs:
- store_console_screenshots:

## 5. Decision History

### Entry 2026-02-16-BASELINE
- release_candidate: `first-launch-baseline`
- jira_issue: `KAN-18`
- frozen_commit_sha: `TBD`
- created_at: `2026-02-16`
- evaluator: `Codex`
- p0_open_count: `>=3`
- p1_open_count: `>=3`
- unresolved_issue_keys: `KAN-18`
- unresolved_check_ids: `COM-AUTO-001`, `COM-AUTO-004`, `TC-COMMON-003`, `RISK-001`, `RISK-002`, `AND-IAP-002`
- decision: `NO-GO`
- reason_summary: `P0/P1 blockers remain open (analyze/regression failures, Android Google purchase verification TODO, metadata fallback mismatch).`
- risk_approver: `TBD`
- approved_at: `TBD`

### Entry 2026-03-20-KAN-153
- release_candidate: `ios-review-hardening`
- jira_issue: `KAN-153`
- frozen_commit_sha: `f1919ee50ead03bd1d7c7c2f3aeaf0ca25e2c6b7`
- created_at: `2026-03-20`
- evaluator: `Codex`
- p0_open_count: `4`
- p1_open_count: `>=7`
- unresolved_issue_keys: `KAN-153`
- unresolved_check_ids: `COM-IAP-001`, `COM-LINK-001`, `COM-PLAY-001`, `COM-PLAY-002`, `IOS-IAP-001`, `IOS-IAP-002`, `IOS-IAP-003`, `IOS-PERM-005`, `IOS-LINK-003`
- decision: `NO-GO`
- reason_summary: `App Store Connect privacy/support/age-rating metadata and review notes are now aligned, but real-device IAP evidence, calendar/universal-link validation, and Google Play console declarations remain open.`
- risk_approver: `TBD`
- approved_at: `TBD`
