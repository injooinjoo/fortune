# Warnings 처리 완료 요약

`artifacts/ios-review/REPORT.md` WARNING 섹션 대응. Ship blocker가 아니지만 reviewer 질문 가능성 높은 항목.

## ✅ 코드로 처리 완료

| W# | 제목 | 파일 | 요약 |
|----|------|------|------|
| **W1** | 연령 게이트 (Part 1) | `apps/mobile-rn/app/onboarding/birth.tsx` | `MIN_AGE_YEARS=14` 미만 Alert + 차단 |
| **W6** | iPad landscape 차단 | `apps/mobile-rn/app.config.ts` | `UISupportedInterfaceOrientations~ipad` portrait 고정 |
| **W8** | profile-images storage purge | `supabase/functions/delete-account/index.ts` | `purgeUserStorage` 함수 + 계정 삭제 시 호출 |
| **W9** | Push 권한 JIT (Part 1) | `apps/mobile-rn/src/lib/push-notifications.ts` | `promptIfNotGranted` 옵션 추가, 기본 `false` |
| **W10** | Edge runtime 타임아웃 (Part 1) | `apps/mobile-rn/src/features/chat-results/edge-runtime.ts` | `AbortController` + 35s |
| **W11** | 터치 타겟 ≥44pt | `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`, `apps/mobile-rn/src/components/inline-calendar.tsx` | `hitSlop` 4 컴포넌트 |
| **W12** | delete-account CASCADE | `supabase/functions/delete-account/index.ts` | DELETE_TARGETS 5개 테이블 추가 |
| **W14** | 사진 클라우드 전송 고지 | `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` | `SurveyImagePicker` 고지 박스 |
| **W16** | 온보딩 KeyboardAvoiding | `apps/mobile-rn/src/screens/onboarding-screen.tsx` | Screen `keyboardAvoiding` prop |
| **W3** | RLS 경화 | `supabase/migrations/20260423000003_harden_rls_policies.sql` | `USING(true)` → `TO service_role` |

## 📝 Part 2 / 별도 스프린트로 이관 (문서화)

| W# | 남은 작업 | 문서 |
|----|----------|------|
| **W1 Part 2** | 서버측 `maxContentTier` clamp (user age 기반) | `artifacts/sprint-fixes/W1-age-gate/note.md` |
| **W9 Part 2** | 프로필/온보딩에 명시적 "알림 받기" opt-in UI | `artifacts/sprint-fixes/W9-push-jit/contract.md` |
| **W10 Part 2** | 에러 버블 + 재시도 버튼 (`kind: 'error-retry'`) | `artifacts/sprint-fixes/W10-edge-timeout/note.md` |
| **W2** | Privacy/EULA URL → `zpzg.co.kr` 도메인 (인프라) | `artifacts/ios-review-fixes/asc/03-eula-ugc-clauses.md` |
| **W4** | LLMFactory bypass 4건 정리 | `artifacts/sprint-fixes/FU3-llmfactory-bypass/analysis.md` |
| **W5** | expo-iap Privacy Manifest (라이브러리 레벨) | 라이브러리 업데이트 필요 |
| **W7** | 로컬 `.env.local` 시크릿 로테이션 (사용자) | — |
| **W13** | Celebrity 실존 연예인 콘텐츠 정책 | 콘텐츠/법무 결정 |
| **W15** | Sentry "Crash Data — Linked" ASC 답변 | `artifacts/ios-review-fixes/asc/01-app-privacy-answers.md` (이미 Linked=true로 답변) |

## 검증

```
npx tsc --noEmit → 0 errors
```

각 변경은 contract/note 문서와 해당 파일 diff 로 증거 확보.

## 커밋 전략 업데이트

`artifacts/ios-review-fixes/README.md`의 커밋 가이드에 추가할 Warning 그룹:

```bash
# W-Group-A (iOS config)
git add apps/mobile-rn/app.config.ts \
        apps/mobile-rn/src/screens/onboarding-screen.tsx \
        apps/mobile-rn/src/features/chat-surface/chat-surface.tsx \
        apps/mobile-rn/src/components/inline-calendar.tsx
git commit -m "fix(mobile-rn): iPad portrait, keyboard avoid, 44pt touch, photo consent (W6, W11, W14, W16)"

# W-Group-B (backend hardening)
git add supabase/functions/delete-account/index.ts \
        apps/mobile-rn/src/lib/push-notifications.ts \
        apps/mobile-rn/src/features/chat-results/edge-runtime.ts \
        supabase/migrations/20260423000003_harden_rls_policies.sql
git commit -m "fix: push JIT, delete-account full purge, edge timeout, RLS hardening (W8, W9, W10, W12, W3)"

# W-Group-C (age gate)
git add apps/mobile-rn/app/onboarding/birth.tsx
git commit -m "feat(onboarding): enforce minimum age 14 gate (W1)"
```
