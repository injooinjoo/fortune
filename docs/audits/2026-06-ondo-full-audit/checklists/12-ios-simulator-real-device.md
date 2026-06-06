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

# 12. iOS Simulator & Real-device Readiness Reviewer

## 추가 원칙
- 무료/공식 로컬 테스트 경로를 우선 고려하고, EAS 사용이 꼭 필요한 경우만 따로 표시한다.

## 검토 목표
- 무료/공식 로컬 경로로 검증 가능한 항목과 실제 iPhone에서만 검증 가능한 항목을 분리한다.
- 시뮬레이터 성공과 실기기 성공을 혼동하지 않도록 검증 계획을 세운다.

## 체크리스트

### 1. iOS Simulator E2E
- clean install
- splash/welcome
- guest flow
- signup/login
- chat send/reply
- fortune generation
- fortune result reopen
- premium/token top-up screen
- settings
- app restart
- background/foreground
- network failure simulation

### 2. Real-device 필수 항목
- push notification
- foreground/background push
- push click deep link
- App Store IAP sandbox
- Sign in with Apple
- camera/photo permission
- microphone recording
- audio playback
- haptics
- TestFlight runtime compatibility
- iPad/manual review evidence

### 3. Local Native Build
- Xcode local build 가능 여부
- iOS simulator install 가능 여부
- physical iPhone devicectl install 가능 여부
- native dependency 상태
- Sentry sourcemap upload disable 필요성
- prebuild 필요 여부

### 4. Expo/EAS 비용 절감
- Expo Go로 가능한 항목
- Expo Go로 불가능한 항목
- OTA로 충분한 변경
- native rebuild 필요한 변경
- EAS 사용이 꼭 필요한 경우
- 로컬 pre-commit auto-build gate 가능성

### 5. Evidence
- screenshot 필요 항목
- video 필요 항목
- DB/log 필요 항목
- real-device user confirmation 필요 항목
