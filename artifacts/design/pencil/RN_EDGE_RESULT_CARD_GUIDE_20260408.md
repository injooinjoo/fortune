# RN Edge Result Card Guide

Date: 2026-04-09
Target: `apps/mobile-rn`

## Goal

모든 RN 운세 결과를 하나의 공통 카드 골격으로 받되, `하늘 > 오늘 운세`처럼 edge payload 중심으로 읽히게 정리한다.

## Recommended Card Order

1. 헤더: `eyebrow`, `title`, `subtitle`, `score`
2. 요약: 한 문단으로 시작
3. 핵심 시각화
   - `daily`: metric grid + timeline
   - score-heavy fortunes: `metric grid + score rail`
4. 분야별 읽기: `detailSections`
5. 핵심 포인트: bullet list
6. 추천 액션 / 주의 포인트
   - 둘 다 있으면 `DoDontPair` 우선
7. 행운 포인트: keyword pills
8. 마무리 한 줄: `specialTip`

## Readability Rules

- 요약/본문은 가능한 한 원문을 더 길게 보여주고, 절단은 마지막 수단으로만 사용
- markdown `**`, 링크 문법, 번호 목록은 카드에서 제거
- slang는 edge 또는 adapter에서 일반어로 치환
- metric 값은 1줄 강제 축약보다 줄바꿈 허용을 우선
- `행운 포인트`가 긴 문장형이면 pill 대신 bullet list로 내린다
- `compatibility`, `face-reading`, `ootd-evaluation`, `game-enhance`, `biorhythm`처럼 수치 비교가 중요한 운세는 `score rail` 우선
- `zodiac-animal`, `constellation`, `birthstone`처럼 상징형 운세는 짧은 요약보다 `detailSections + score rail` 구조를 우선한다
- `blind-date`는 `firstImpressionTips`, `conversationTopics`, `outfitAdvice`, `locationAdvice`, `meetingInfo`를 별도 섹션으로 유지한다
- `family`는 subtype별 `childrenCategories`, `seasonalAdvice`, `familySynergy`, `monthlyFlow`를 generic flatten으로 합치지 말고 섹션 단위로 보여준다

## Runtime Truthfulness

- edge-backed 운세는 `login -> persisted reuse -> token -> edge -> persist` 순서를 먼저 통과한다
- 설문 완료 직후 로그인으로 빠진 경우에는 `fortuneType + answers`를 함께 보존하고, 로그인 뒤 같은 채팅 안으로 결과를 다시 복원한다
- 같은 요청이 재사용 조건에 맞으면 edge를 다시 호출하지 않고 DB의 직전 결과를 카드로 복원한다
- 개인 결과 재사용 fingerprint에서는 사용자 표시 이름만 바뀌어도 새 요청으로 오인하지 않도록 자기 이름 필드는 제외한다
- edge 호출 실패 시 로컬 하드코딩 카드로 조용히 대체하지 않고 실패 안내를 보여준다
- 토큰 환불은 가능하면 원래 소비 reference와 연결해서 중복 환불을 막는다
- 사진이 필요한 운세는 survey-scoped photo input을 거쳐서만 edge 호출한다
- 프로필 생년월일이 필요한 운세는 missing-profile 상태를 먼저 알린다
- edge function이 없는 운세는 다른 운세 카드로 alias하지 않는다
- `face-reading`과 `ootd-evaluation`은 공통 카드 시스템을 쓰되, `survey photo answer`가 없으면 edge 호출하지 않는다
- 사진 기반 운세는 `generic composer attachment`가 아니라 `survey-scoped photo input`을 source of truth로 삼는다
- 사진 기반 결과 카드는 사진 미리보기보다 edge가 반환한 분석 텍스트와 점수 시각화를 우선한다

## Batch Note

- 현재 공통 카드 구조는 유지
- 이번 배치의 핵심은 “더 예쁜 새 카드”보다 “실제 edge payload를 정직하게 보여주는 카드”이다
- 이번 배치부터 `EmbeddedResultCard`가 `scoreRails`, `DoDontPair`, 긴 `luckyItems`의 bullet fallback을 직접 소비한다
- 이번 배치부터 `compatibility`는 `이름/띠/별자리` 숫자축을 score rail로, `blind-date`는 첫인상/대화/룩/장소/만남정보를, `family`는 subtype 공통 구조를 더 직접 소비한다
