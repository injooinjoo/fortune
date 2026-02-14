# Discovery Report Template

이 템플릿은 새 코드 작성 전 기존 코드 탐색/재사용 판단 기록용입니다.

## 1. Goal
- Requested change:
- Work type: Widget / Provider / Service / Model / Page / Edge Function
- Scope:

## 2. Search Strategy
- Keywords:
- Commands:
  - `rg "extends StateNotifier" lib/`
  - `rg "class .*Widget" lib/`
  - `rg "class .*Service" lib/`
  - `rg "@freezed" lib/`
  - `rg "StateNotifierProvider" lib/`

## 3. Similar Code Findings
- Reusable:
  1. `path/to/file1.dart` - symbol / reason
  2. `path/to/file2.dart` - symbol / reason
- Reference only:
  1. `path/to/file3.dart` - pattern / reason
  2. `path/to/file4.dart` - pattern / reason

## 4. Reuse Decision
- Reuse as-is:
- Extend existing code:
- New code required:
- Duplicate prevention notes:

## 5. Planned Changes
- Files to edit:
  1. `path/to/file1.dart`
  2. `path/to/file2.dart`
- Files to create:
  1. `path/to/new_file.dart`

## 6. Validation Plan
- Static checks:
- Runtime checks:
- Test cases:

