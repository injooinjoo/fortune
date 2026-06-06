# 온도 앱 전체 QA 체크리스트 인덱스

이 폴더는 온도 앱 전체 검토를 병렬 QA 쓰레드로 돌리기 위한 체크리스트 모음이다.

## 사용법

각 QA 쓰레드에는 아래처럼 요청하면 된다.

```md
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/checklists/01-bm-iap-revenue.md 파일을 읽고, 그 체크리스트 기준으로 온도 앱 QA를 돌려줘.

결과는 markdown 보고서 형태로 작성해줘.
코드 수정은 하지 말고, 증거 수집/문제 분류/수정 제안까지만 해줘.
```

## 체크리스트 파일

1. `01-bm-iap-revenue.md` — BM / IAP / Revenue Security
2. `02-app-store-review.md` — App Store Review Gatekeeper
3. `03-chat-runtime-rca.md` — Chat Runtime RCA
4. `04-chat-ux-conversation.md` — Chat UX & Conversation
5. `05-proactive-push.md` — Proactive Push
6. `06-fortune-registry-schema.md` — Fortune Registry & Schema
7. `07-haneul-fortune-e2e.md` — Haneul Fortune E2E QA
8. `08-ux-button-walker.md` — UX Button Walker
9. `09-design-system-motion.md` — Design System & Motion
10. `10-architecture-duplication-performance.md` — Architecture / Duplication / Performance
11. `11-supabase-rls-edge-health.md` — Supabase / RLS / Edge Health
12. `12-ios-simulator-real-device.md` — iOS Simulator & Real-device Readiness
13. `13-consolidation.md` — Consolidation Reviewer

## 결과 저장 추천 위치

```txt
/Users/injoo/Desktop/Dev/fortune/docs/audits/2026-06-ondo-full-audit/reports/
```

예:

```txt
reports/01-bm-iap-revenue-report.md
reports/02-app-store-review-report.md
...
reports/13-consolidated-report.md
```
