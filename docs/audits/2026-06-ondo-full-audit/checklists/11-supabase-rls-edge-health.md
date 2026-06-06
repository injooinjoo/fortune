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

# 11. Supabase / RLS / Edge Health Reviewer

## 추가 원칙
- Supabase shared module 변경은 importing function 재배포가 필요할 수 있으니 배포 영향까지 확인한다.

## 검토 목표
- 데이터 보안, 사용자별 격리, Edge Function 안정성, shared module 배포 누락, 로그/관측성 문제를 찾는다.

## 체크리스트

### 1. RLS/Auth
- users/profiles RLS
- conversations/messages RLS
- fortune results RLS
- token ledger RLS
- scheduled replies RLS
- proactive messages RLS
- auth uid 검증
- guest/anonymous 처리
- account deletion 처리

### 2. 데이터 격리
- 다른 유저 메시지 접근 가능성
- 다른 유저 fortune result 접근 가능성
- user_id 파라미터 위조 가능성
- service role 오남용 가능성

### 3. Edge Functions
- character-chat
- fortune 관련 functions
- scheduled reply
- claim reply
- purchase verification
- token grant/refund
- proactive messaging
- public/private function 구분
- JWT 필요 여부
- CORS

### 4. Shared Module / 환경변수
- `_shared/llm` 등 shared file 변경 후 importing function 재배포 필요성
- production bundle 반영 여부
- 함수별 배포 상태
- LLM keys, Supabase keys, Apple shared secret/API, model config, preview/high-cost model guard

### 5. Storage / Logs
- avatar, proactive image, audio, generated fortune image
- signed URL expiry
- public/private bucket 정책
- request id, user id, message id, fortune result id, error code, latency, timeout, retry, idempotency key
