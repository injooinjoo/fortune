# RCA Report Template

이 템플릿은 버그/에러 수정 전 근본 원인 분석 보고서 작성용입니다.

## 1. Symptom
- Error message:
- Repro steps:
- Observed behavior:
- Expected behavior:

## 2. WHY (Root Cause)
- Direct cause:
- Root cause:
- Data/control flow:
  - Step 1:
  - Step 2:
  - Step 3:

## 3. WHERE
- Primary location: `path/to/file.dart:line`
- Related call sites:
  - `path/to/another_file.dart:line`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "pattern1" lib/`
  - `rg "pattern2" lib/`
- Findings:
  1. `path/to/file1.dart:line` - issue / safe
  2. `path/to/file2.dart:line` - issue / safe

## 5. HOW (Correct Pattern)
- Reference implementation: `path/to/reference.dart:line`
- Before:
```dart
// problematic code
```
- After:
```dart
// corrected code
```
- Why this fix is correct:

## 6. Fix Plan
- Files to change:
  1. `path/to/file1.dart` - change summary
  2. `path/to/file2.dart` - change summary
- Risk assessment:
- Validation plan:

