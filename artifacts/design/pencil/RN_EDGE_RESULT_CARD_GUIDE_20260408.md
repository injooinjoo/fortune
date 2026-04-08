# RN Edge Result Card Guide

Date: 2026-04-08
Target: `apps/mobile-rn`

## Goal

모든 RN 운세 결과를 하나의 공통 카드 골격으로 받되, `하늘 > 오늘 운세`처럼 edge payload 중심으로 읽히게 정리한다.

## Recommended Card Order

1. 헤더: `eyebrow`, `title`, `subtitle`, `score`
2. 요약: 한 문단으로 시작
3. 핵심 시각화
   - `daily`: metric grid + timeline
   - others: metric grid
4. 분야별 읽기: `detailSections`
5. 핵심 포인트: bullet list
6. 추천 액션 / 주의 포인트
7. 행운 포인트: keyword pills
8. 마무리 한 줄: `specialTip`

## Readability Rules

- 요약/본문은 가능한 한 원문을 더 길게 보여주고, 절단은 마지막 수단으로만 사용
- markdown `**`, 링크 문법, 번호 목록은 카드에서 제거
- slang는 edge 또는 adapter에서 일반어로 치환
- metric 값은 1줄 강제 축약보다 줄바꿈 허용을 우선

## Runtime Truthfulness

- edge-backed 운세는 `login -> persisted reuse -> token -> edge -> persist` 순서를 먼저 통과한다
- 같은 요청이 재사용 조건에 맞으면 edge를 다시 호출하지 않고 DB의 직전 결과를 카드로 복원한다
- edge 호출 실패 시 로컬 하드코딩 카드로 조용히 대체하지 않고 실패 안내를 보여준다
- 사진이 필요한 운세는 survey-scoped photo input을 거쳐서만 edge 호출한다
- 프로필 생년월일이 필요한 운세는 missing-profile 상태를 먼저 알린다
- edge function이 없는 운세는 다른 운세 카드로 alias하지 않는다
- `face-reading`과 `ootd-evaluation`은 공통 카드 시스템을 쓰되, `survey photo answer`가 없으면 edge 호출하지 않는다
- 사진 기반 운세는 `generic composer attachment`가 아니라 `survey-scoped photo input`을 source of truth로 삼는다
- 사진 기반 결과 카드는 사진 미리보기보다 edge가 반환한 분석 텍스트와 점수 시각화를 우선한다

## Batch Note

- 현재 공통 카드 구조는 유지
- 이번 배치의 핵심은 “더 예쁜 새 카드”보다 “실제 edge payload를 정직하게 보여주는 카드”이다
