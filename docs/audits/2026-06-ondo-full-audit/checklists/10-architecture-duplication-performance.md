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

# 10. Architecture / Duplication / Performance Reviewer

## 검토 목표
- 장기적으로 앱을 안전하게 수정하기 어렵게 만드는 구조적 문제를 찾는다.
- 중복 상수/중복 mapping/중복 business rule/source-of-truth 분산을 찾는다.
- 모바일 체감 성능과 렌더링 병목을 찾는다.

## 체크리스트

### 1. Architecture
- UI/state/network/domain/persistence/billing 책임이 섞여 있는가?
- 거대한 screen/component가 있는가?
- circular dependency가 있는가?
- import direction이 깨지는가?
- hook/service 책임이 과도한가?

### 2. Source of Truth
- route names 중복
- product ids 중복
- storage keys 중복
- fortune type ids 중복
- token costs 중복
- model names 중복
- chat latest-message logic 중복

### 3. Mapping Duplication
- mobile catalog
- Edge Function handler
- result renderer
- DB migration
- docs
- product contracts
- billing policies

### 4. UI Duplication
- button
- card
- modal
- bottom sheet
- loading state
- error state

### 5. Performance
- 초기 로딩 병목
- chat list/message list re-render
- fortune card list re-render
- inline object/function 과다
- broad context update
- selector 미사용
- 큰 이미지/asset
- polling/retry 과다
- SQLite/SecureStore/AsyncStorage 병목

### 6. Bundle/Build Surface
- generated/design/artifact 폴더가 active app scan/build에 포함되는가?
- 불필요 asset이 번들에 포함되는가?
- native build에 영향을 주는 파일이 정리되어 있는가?
