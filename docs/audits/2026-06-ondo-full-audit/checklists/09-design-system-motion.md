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

# 9. Design System & Motion Reviewer

## 검토 목표
- 앱이 일관된 디자인 시스템으로 구현되어 있는지 확인한다.
- raw color/font, 중복 컴포넌트, cheap-looking visual asset, 과하거나 어색한 motion을 찾는다.

## 체크리스트

### 1. Typography
- `AppText` 또는 지정 typography 시스템을 사용하는가?
- raw `Text` 남용이 있는가?
- font size/weight/line height가 일관적인가?
- 한국어 가독성이 좋은가?

### 2. Colors
- raw hex color 사용이 많은가?
- theme token 사용이 일관적인가?
- dark mode 대응이 되는가?
- contrast 문제가 있는가?

### 3. Spacing/Layout
- padding/margin이 일관적인가?
- safe area 처리가 적절한가?
- keyboard area와 겹치지 않는가?
- 작은 화면/iPad에서 깨지지 않는가?

### 4. Components / Brand
- 버튼 스타일 중복
- 카드 스타일 중복
- modal/bottom sheet 일관성
- premium/token UI의 신뢰감
- fortune card의 구분성
- 온도 앱 특유의 따뜻함/프리미엄 감성이 있는가?
- code-drawn center art가 싼티 나지 않는가?
- generated asset 품질이 충분한가?
- 아이콘/이미지/일러스트 스타일이 통일되는가?

### 5. Motion/Animation / Haptics
- welcome/onboarding motion
- chat reply effect
- typing/loading
- fortune picker carousel
- result reading player
- reward/token feedback
- animation cleanup
- JS thread 부담
- reduced motion 대응
- 선택/전송/성공/실패 haptic이 적절한가?
