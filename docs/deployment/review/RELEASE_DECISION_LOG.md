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
| DEC-001 | P0 | Frozen commit SHA captured for current KAN-166 candidate | pending | final `KAN-166` commit SHA will be frozen at push time | release-owner | 2026-03-22 | in_progress |
| DEC-002 | P0 | Apple master checklist P0 items all pass for re-submission | fail | `/docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md` (`APPLE-RUNTIME-001`, `APPLE-IAP-002` pending manual evidence) | release-owner | 2026-03-22 | blocked |
| DEC-003 | P1 | Apple master checklist P1 items all pass for re-submission | fail | `/docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md` (`APPLE-RUNTIME-002`, `APPLE-RUNTIME-003` pending manual evidence) | release-owner | 2026-03-22 | open |
| DEC-004 | P0 | iOS evidence checklist has no open P0/P1 | fail | `/docs/deployment/review/IOS_REVIEW_EVIDENCE.md` (`IOS-RUNTIME-002`, `IOS-IAP-001~003`, `IOS-RUNTIME-003~004` pending manual evidence) | ios-owner | 2026-03-22 | open |
| DEC-005 | P0 | Android / Play release checklist has no open P0/P1 | fail | `/docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md` (`PLAY-001~003` pending) | android-owner | TBD | open |
| DEC-006 | P0 | Local verification for current hardening batch passed | pass | `flutter analyze --no-fatal-infos`, `dart format --set-exit-if-changed .`, `flutter test`, `flutter build ios --release --no-codesign` on 2026-03-22 | engineering | 2026-03-22 | done |
| DEC-007 | P0 | Manual scenario evidence uploaded for required Apple review cases | pending | iPhone clean install / IAP / iPad / NAT64 recordings and logs | qa-owner | TBD | open |
| DEC-008 | P0 | Risk approver explicitly signs off final store submission decision | pending | approver name + timestamp | release-manager | TBD | open |

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

### Entry 2026-03-22-KAN-166
- release_candidate: `apple-review-hardening-followup`
- jira_issue: `KAN-166`
- frozen_commit_sha: `pending final KAN-166 commit`
- created_at: `2026-03-22`
- evaluator: `Codex`
- p0_open_count: `>=3`
- p1_open_count: `>=2`
- unresolved_issue_keys: `KAN-166`
- unresolved_check_ids: `APPLE-RUNTIME-001`, `APPLE-IAP-002`, `APPLE-RUNTIME-002`, `APPLE-RUNTIME-003`, `PLAY-001`, `PLAY-002`, `PLAY-003`
- decision: `NO-GO`
- reason_summary: `Apple code/policy/metadata blockers are closed, but App Review re-submission still requires real-device evidence for the 2026-03-21 rejection path, IAP success/cancel/restore, iPad review path, and optional NAT64/IPv6 validation. Cross-platform release also remains blocked by Play console tasks.`
- risk_approver: `TBD`
- approved_at: `TBD`
