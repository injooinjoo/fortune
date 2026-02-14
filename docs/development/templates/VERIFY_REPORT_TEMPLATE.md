# Verify Report Template

이 템플릿은 수정 완료 후 검증 기록 및 사용자 테스트 요청용입니다.

## 1. Change Summary
- What changed:
- Why changed:
- Affected area:

## 2. Static Validation
- `flutter analyze`
  - Result:
  - Notes:
- `dart format --set-exit-if-changed .`
  - Result:
  - Notes:
- `dart run build_runner build --delete-conflicting-outputs` (if applicable)
  - Result:
  - Notes:

## 3. Tests and QA
- Unit/Widget/Integration tests run:
  - Command:
  - Result:
- Playwright QA (if applicable):
  - Command:
  - Result:

## 4. Files Changed
1. `path/to/file1.dart` - summary
2. `path/to/file2.dart` - summary

## 5. Risks and Follow-ups
- Known risks:
- Deferred items:

## 6. User Manual Test Request
- Scenario:
  1. Step 1
  2. Step 2
  3. Step 3
- Expected result:
- Failure signal:

## 7. Completion Gate
- User confirmation required before final completion declaration.

