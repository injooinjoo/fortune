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

# 8. UX Button Walker

## 검토 목표
- 앱 내 모든 주요 화면에서 버튼/링크/CTA가 기대한 대로 동작하는지 확인한다.
- broken route, 무반응 버튼, 중복 탭 문제, 닫기/뒤로가기 상태 손실, 외부 링크 문제를 찾는다.

## 대상 화면
1. Splash
2. Welcome
3. Signup/Login
4. Profile setup
5. Chat list
6. Chat room
7. Character profile
8. Fortune picker
9. Fortune survey
10. Fortune result
11. Premium/token top-up
12. Settings
13. Policy pages
14. Account deletion
15. Notification settings
16. App Store review 관련 support/privacy/terms 링크

## 체크리스트

### 1. 버튼 동작
- 눌리는가?
- 올바른 route로 이동하는가?
- loading state가 있는가?
- disabled state가 명확한가?
- duplicate tap 방지가 있는가?

### 2. Back/Close/Cancel
- 이전 화면/상태가 복원되는가?
- 중간 작업 취소 시 job/token 상태가 안전한가?
- 닫기 후 다시 열면 상태가 이상하지 않은가?

### 3. 링크 / 오류 / 접근성
- 외부 URL이 정상적으로 열리는가?
- broken URL이 없는가?
- Privacy/Terms/Support 링크가 App Store metadata와 일치하는가?
- 네트워크/auth/결제 실패 후 버튼 상태가 복구되는가?
- hit area가 충분한가?
- accessibility label이 있는가?
- 작은 화면에서 버튼이 가려지지 않는가?
- 키보드가 버튼을 가리지 않는가?
