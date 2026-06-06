# 공통 운영 원칙

- 온도 앱 전체 검토의 일부로 이 체크리스트를 사용한다.
- 1차 작업은 **QA/리뷰/증거 수집/수정 제안**이 목적이다.
- 코드 수정은 하지 않는다. 수정은 취합 후 별도 Fix Agent 작업으로 진행한다.
- 모든 발견 항목은 P0/P1/P2/P3로 분류한다.
- 단순 의견이 아니라 증거 기반으로 보고한다.
- 문서와 코드가 다르면 코드/실제 동작을 우선 증거로 삼는다.
- 시뮬레이터 성공을 실기기 성공으로 간주하지 않는다.
- 서버 작업 완료를 유저 화면 성공으로 간주하지 않는다.

## 심각도 기준

- P0: 앱 사용 불가, 결제/토큰 손실, 보안/개인정보 문제, App Store 즉시 리젝 가능
- P1: 핵심 기능 실패, 사용자 신뢰 크게 저하, 주요 전환/매출 손상
- P2: UX 불편, 특정 경로에서 실패, 반복 버그 가능성
- P3: 개선 제안, polish, 미세 최적화

## 보고서 형식

```md
# [역할명] QA Report

## Verdict
- GO / NO-GO / 조건부 GO
- 핵심 리스크 한 줄 요약

## P0
-

## P1
-

## P2
-

## P3
-

## Evidence
- 파일/라인, 로그, DB row, 화면 경로, 재현 단계, 스크린샷 설명

## Recommended Fix Order
1.
2.
3.

## Open Questions
-
-
```

# 6. Fortune Registry & Schema Reviewer

## 검토 목표
- 모든 운세 타입이 모바일 목록, Edge Function, DB, 결과 renderer, schema, 비용 정책에서 일관되는지 확인한다.
- 목록에는 있는데 생성 안 됨, 생성은 되는데 렌더링 안 됨, 결과 재열람이 깨짐 같은 문제를 찾는다.

## 체크리스트

### 1. fortuneType registry
- 모바일 목록의 fortuneType
- Edge Function input fortuneType
- DB 저장값
- result renderer mapping
- result schema mapping
- 문서의 타입 목록

### 2. 타입 누락/불일치
- 목록에는 있는데 생성 불가한 타입
- 생성은 되지만 결과 renderer가 없는 타입
- renderer는 있지만 catalog에 없는 타입
- 캐시는 있지만 재열람 불가한 타입
- 과거 result shape와 현재 renderer가 충돌하는 타입

### 3. 이름/카테고리/표시
- 한국어 표시명
- subtitle
- icon/image
- accessibility label
- 카테고리 분류

### 4. 비용 정책
- fortune type별 token cost
- 무료/프리미엄 구분
- UI 표시 비용과 실제 차감 비용 일치
- 실패/취소/캐시 hit 시 토큰 정책

### 5. 결과 구조 / 호환성
- required fields
- optional fields
- fallback renderer
- null/undefined 방어
- malformed LLM output 방어
- 과거 결과 재열람
- DB migration 적용 여부
- schema version 관리
- prompt version 관리
