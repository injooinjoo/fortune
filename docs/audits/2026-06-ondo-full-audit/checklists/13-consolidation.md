# 13. Consolidation Reviewer

## 공통 목표

- 수정하지 말고 리뷰/분석 결과를 취합만 한다.
- 단순 나열이 아니라 실행 가능한 최종 의사결정 보고서로 정리한다.
- 모든 발견 항목은 P0/P1/P2/P3로 재분류한다.
- 중복 발견은 합치고, 충돌하는 판단은 증거 기준으로 정리한다.
- 문서와 코드가 다르면 코드/실제 동작을 우선 증거로 삼는다.
- 시뮬레이터 성공을 실기기 성공으로 간주하지 않는다.
- 서버 작업 완료를 유저 화면 성공으로 간주하지 않는다.
- “고치면 좋음”과 “지금 막는 문제”를 명확히 구분한다.

## 심각도 기준

- P0: 앱 사용 불가, 결제/토큰 손실, 보안/개인정보 문제, App Store 즉시 리젝 가능
- P1: 핵심 기능 실패, 사용자 신뢰 크게 저하, 주요 전환/매출 손상
- P2: UX 불편, 특정 경로에서 실패, 반복 버그 가능성
- P3: 개선 제안, polish, 미세 최적화

## 입력 대상 리뷰어

1. BM / IAP / Revenue Security Reviewer
2. App Store Review Gatekeeper
3. Chat Runtime RCA Reviewer
4. Chat UX & Conversation Reviewer
5. Proactive Push Reviewer
6. Fortune Registry & Schema Reviewer
7. Haneul Fortune E2E QA Reviewer
8. UX Button Walker
9. Design System & Motion Reviewer
10. Architecture / Duplication / Performance Reviewer
11. Supabase / RLS / Edge Health Reviewer
12. iOS Simulator & Real-device Readiness Reviewer

## 최종 보고서 형식

```md
# 온도 앱 전체 검토 최종 보고서

## 1. Executive Verdict
- App Store: GO / NO-GO / 조건부 GO
- BM: 안전 / 위험 / 조건부 안전
- User Trust: 안전 / 위험 / 조건부 안전
- Revenue: 안전 / 위험 / 조건부 안전
- Security: 안전 / 위험 / 조건부 안전
- Maintainability: 안전 / 위험 / 조건부 안전

## 2. 한 줄 결론
-

## 3. Top 10 Risks
1.
2.
3.
4.
5.
6.
7.
8.
9.
10.

## 4. P0 Blockers
각 항목:
- 제목:
- 출처 리뷰어:
- 증거:
- 영향:
- 원인 추정:
- 최소 수정:
- 검증:

## 5. P1 Must Fix
각 항목:
- 제목:
- 출처 리뷰어:
- 증거:
- 영향:
- 원인 추정:
- 최소 수정:
- 검증:

## 6. P2 Improvements
-

## 7. P3 Polish
-

## 8. Cross-cutting Root Causes
- source of truth 분산
- token policy 중복
- chat local/remote sync 불일치
- App Store 문서와 실제 UX 불일치
- Edge Function 배포/관측성 부족
- 디자인 시스템 미준수
- 테스트 사각지대

## 9. Fix Order
### Phase 1: 즉시 차단/P0
1.
2.
3.

### Phase 2: 핵심 기능 안정화/P1
1.
2.
3.

### Phase 3: 수익/전환/신뢰 개선
1.
2.
3.

### Phase 4: 디자인/모션/UX Polish
1.
2.
3.

### Phase 5: 구조 개선/테스트 강화
1.
2.
3.

## 10. Verification Plan
### Simulator
-

### Real Device
-

### Supabase/DB
-

### App Store Review Evidence
-

### Regression Tests
-

## 11. Decision
- 지금 App Store 제출 가능한가?
- 지금 유저에게 배포 가능한가?
- 지금 BM상 손실 위험이 있는가?
- 지금 가장 먼저 고칠 것은 무엇인가?

## 12. Open Questions
-
-
```
