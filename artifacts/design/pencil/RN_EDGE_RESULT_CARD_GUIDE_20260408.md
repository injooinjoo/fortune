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

- 사진이 필요한 운세는 사진 없이 fallback 카드로 대체하지 않는다
- 프로필 생년월일이 필요한 운세는 missing-profile 상태를 먼저 알린다
- edge function이 없는 운세는 다른 운세 카드로 alias하지 않는다

## Batch Note

- 현재 공통 카드 구조는 유지
- 이번 배치의 핵심은 “더 예쁜 새 카드”보다 “실제 edge payload를 정직하게 보여주는 카드”이다
