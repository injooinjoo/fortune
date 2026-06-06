# 온도 앱 QA 요청용 복붙 프롬프트

## 개별 QA 쓰레드용

```md
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/checklists/[파일명].md 파일을 읽고, 그 체크리스트 기준으로 온도 앱 QA를 돌려줘.

요구사항:
- 코드 수정은 하지 마.
- 체크리스트 기준으로 관련 코드/문서/설정/UX 경로를 조사해.
- 발견 항목은 P0/P1/P2/P3로 분류해.
- 파일 경로/라인, 로그, DB row, 화면 경로, 재현 단계 같은 증거를 포함해.
- 수정 방향과 검증 방법까지 제안해.
- 결과는 markdown 보고서로 작성해.
```

## 결과 파일까지 지정하는 버전

```md
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/checklists/[파일명].md 파일을 읽고, 그 체크리스트 기준으로 온도 앱 QA를 돌려줘.

결과는 아래 파일에 들어갈 markdown 형태로 작성해줘:
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/reports/[보고서파일명].md

요구사항:
- 코드 수정은 하지 마.
- 체크리스트 기준으로 관련 코드/문서/설정/UX 경로를 조사해.
- 발견 항목은 P0/P1/P2/P3로 분류해.
- 파일 경로/라인, 로그, DB row, 화면 경로, 재현 단계 같은 증거를 포함해.
- 수정 방향과 검증 방법까지 제안해.
- 결과는 markdown 보고서로 작성해.
```

## 취합용

```md
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/checklists/13-consolidation.md 파일을 읽고, 아래 QA 결과들을 하나의 최종 보고서로 취합해줘.

입력 보고서 위치:
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/reports/

요구사항:
- 중복 이슈는 합쳐줘.
- 충돌하는 판단은 증거 기준으로 정리해줘.
- P0/P1/P2/P3를 재분류해줘.
- App Store, BM, User Trust, Revenue, Security, Maintainability 관점의 최종 Verdict를 내려줘.
- P0/P1 우선 Fix Order를 만들어줘.
- Simulator / Real Device / Supabase / App Store Evidence / Regression Test 검증 계획을 분리해줘.
```
