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

# 3. Chat Runtime RCA Reviewer

## 추가 원칙
- 채팅 성공 기준은 반드시 “새 unique message → 새 assistant reply → 실제 화면 표시”이다.
- 초기 인사말/과거 답변/서버 job 완료만으로 성공 처리하지 않는다.

## 검토 목표
- “메시지를 보냈는데 답이 안 옴”, “푸시는 왔는데 방에 안 보임”, “리스트와 방 내용이 다름” 같은 문제의 원인을 찾는다.

## 체크리스트

### 1. 유저 메시지 저장
- 전송 직후 로컬 저장 여부
- 서버 저장 여부
- optimistic UI와 실제 DB row 일치 여부
- pending 상태에서 confirmed 상태 전환

### 2. 작업 생성
- pending job 생성 여부
- scheduled reply 생성 여부
- immediate reply 경로 여부
- job id와 message id 연결

### 3. Edge Function
- `character-chat` 호출 성공 여부
- timeout/retry 처리
- LLM 응답 실패 처리
- 오류 로그 추적 가능성
- request id/user id/message id 로그 존재 여부

### 4. DB 상태
- conversation row
- message row
- scheduled reply row
- ack 상태
- delivered 상태
- client_acked_at 상태
- row id/timestamp 추적 가능성

### 5. UI 동기화
- DB에는 답변이 있는데 UI에 안 뜨는 경우가 있는가?
- SQLite/local store에는 있는데 React state에 안 뜨는가?
- 리스트에는 보이는데 방에는 안 보이는가?
- 푸시는 왔는데 방에는 없는가?

### 6. 단일 진실 공급원
- 리스트 preview, 채팅방, 푸시, unread count가 같은 selector/store를 쓰는가?
- `thread[thread.length - 1]` 같은 raw tail read가 있는가?
- local/remote merge 시 중복/누락 가능성이 있는가?
