# iOS App Store 심사 대비 Ship Blocker 수정 - Patch Bundle

작성: 2026-04-23
범위: `artifacts/ios-review/REPORT.md`의 SHIP BLOCKER 11건 전체

## 구성

```
artifacts/ios-review-fixes/
├── README.md                     # 이 파일
├── modified-files.diff           # 수정 파일 18개의 git diff (일부 pre-existing 작업 포함)
└── new-files/                    # 신규 생성 파일 5개 (pre-existing 없음, 그대로 복사 가능)
    ├── apps/mobile-rn/src/
    │   ├── features/chat-surface/message-report-sheet.tsx
    │   └── lib/character-blocks.ts
    └── supabase/
        ├── functions/
        │   ├── _shared/moderation.ts
        │   └── report-message/index.ts
        └── migrations/
            └── 20260423000001_ugc_moderation.sql
```

## 11 Phase 매핑

| Phase | Ship Blocker | 주요 수정 파일 | 상세 |
|-------|-------------|---------------|------|
| P1 | B6 Splash force-welcome 플래그 | `src/screens/splash-screen.tsx` | `FORCE_WELCOME_FOR_DEV` 제거 |
| P2 | B7 리뷰어 화이트리스트 | `src/lib/test-accounts.ts` | `test@zpzg.com` 추가 |
| P3 | B9+C2 Info.plist 버전/중복 URL | `app.config.ts` | scheme 재설계, android.scheme 명시 |
| P4 | B10 Speech 권한 한글화 | `app.config.ts` | `speechRecognitionPermission` 추가 |
| P5 | B8 다크모드 manifest | `app.config.ts` | `userInterfaceStyle: 'dark'` |
| P6 | B11 Privacy Manifest | `app.config.ts` | `ios.privacyManifests` 11 types |
| P7 | B1 iPad Sign-in race | `src/providers/app-bootstrap-provider.tsx` | Linking listener 선부착 + URL dedup |
| P8 | B4 Edge Function body.userId | `_shared/auth.ts`, `fortune-tarot`, `fortune-birthstone`, `widget-cache` | JWT 파생 |
| P9 | B3 Kakao OAuth 탈취 | `functions/kakao-oauth/index.ts` | `/v2/user/me` 재검증 |
| P10 | B5 fortune-health vitals | `functions/fortune-health`, `chat-results/adapter.ts`, `chat-results/types.ts`, `primitives/result-card-frame.tsx` | vitals 제거 + disclaimer |
| P11 | B2 UGC 모더레이션/신고/차단 | **신규** 5 + `character-chat`, `delete-account`, `chat-surface`, `chat-screen`, `character-profile-screen` | Apple 5.2.3 대응 |

---

## 파일별 스코프 분류

### 🟢 신규 파일 (5) — new-files/ 에 그대로 복사
| 파일 | 라인수 | 용도 |
|------|--------|------|
| `supabase/migrations/20260423000001_ugc_moderation.sql` | ~85 | message_reports + character_blocks + moderation_flags 테이블 |
| `supabase/functions/_shared/moderation.ts` | ~175 | OpenAI omni-moderation 래퍼 |
| `supabase/functions/report-message/index.ts` | ~120 | 신고 POST 엔드포인트 |
| `apps/mobile-rn/src/lib/character-blocks.ts` | ~95 | 차단 helper + useBlockedCharacterIds 훅 |
| `apps/mobile-rn/src/features/chat-surface/message-report-sheet.tsx` | ~170 | 신고 모달 |

### 🟢 전체가 내 작업 (diff 100% 내 것) — 전체 적용 OK
| 파일 | Diff 라인 | 설명 |
|------|----------|------|
| `apps/mobile-rn/src/lib/test-accounts.ts` | 1 | P2 |
| `apps/mobile-rn/src/features/chat-results/types.ts` | 7 | P10 disclaimer 필드 |
| `apps/mobile-rn/src/features/chat-results/adapter.ts` | 7 | P10 |
| `supabase/functions/_shared/auth.ts` | 23 | P8 deriveUserIdFromJwt (기존 파일에 함수만 추가) |
| `supabase/functions/fortune-tarot/index.ts` | 10 | P8 |
| `supabase/functions/fortune-birthstone/index.ts` | 9 | P8 |
| `supabase/functions/widget-cache/index.ts` | 22 | P8 JWT 필수화 |
| `supabase/functions/kakao-oauth/index.ts` | 195 | **P9 전면 재작성** |
| `supabase/functions/fortune-health/index.ts` | 49 | P10 vitals 제거 + disclaimer |
| `supabase/functions/character-chat/index.ts` | 49 | P11 moderation hooks |
| `supabase/functions/delete-account/index.ts` | 4 | P11 DELETE_TARGETS |
| `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx` | 95 | P7 |
| `apps/mobile-rn/app.config.ts` | 164 | P3+P4+P5+P6 (이 파일의 pre-existing 변경 없음 — 전부 내 것) |
| `apps/mobile-rn/src/screens/splash-screen.tsx` | 25 | P1 (작은 pre-existing `formatVersionLabel` 추가 섞임 — 라인 기준 구별 가능) |
| `apps/mobile-rn/src/features/fortune-results/primitives/result-card-frame.tsx` | 52 | P10 disclaimer 블록 |
| `apps/mobile-rn/src/screens/character-profile-screen.tsx` | 51 | P11 block 섹션 |

### 🟡 혼재 — pre-existing 대규모 작업 + 내 작은 변경
| 파일 | Diff 라인 | 내 hunk 위치 |
|------|----------|-------------|
| `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` | 195 | (1) import `MessageReportSheet` 1줄, (2) `ChatThreadMessage` 함수를 `reportable` + `Pressable` + `MessageReportSheet` 렌더로 리팩토링 |
| `apps/mobile-rn/src/screens/chat-screen.tsx` | 208 | (1) import `useBlockedCharacterIds`, (2) `firstRunCharacters`를 useMemo + 필터로 래핑 (기존 `const firstRunCharacters = tabCharacters;` 라인 교체) |

---

## 적용 방법

### 옵션 1: 전체 패치 적용 (pre-existing 포함 OK인 경우)
```bash
# dirty tree 주의 — 백업 후 진행
cd /Users/injoo/Desktop/Dev/fortune
git apply --check artifacts/ios-review-fixes/modified-files.diff
git apply artifacts/ios-review-fixes/modified-files.diff

# 신규 파일 복사
cp -r artifacts/ios-review-fixes/new-files/* .
```
**주의**: `modified-files.diff`는 현재 working tree → HEAD 역방향 기록. 이미 local에 적용돼 있으므로 clean HEAD에 rebase 시만 의미.

### 옵션 2: 현재 상태 그대로 유지하고 phase별 커밋
dirty tree가 이미 내 변경 + pre-existing 포함. 아래처럼 phase별로 파일 스테이징:

```bash
# P1
git add apps/mobile-rn/src/screens/splash-screen.tsx
git commit -m "fix(mobile-rn): remove FORCE_WELCOME_FOR_DEV dev flag (P1-B6)"

# P2
git add apps/mobile-rn/src/lib/test-accounts.ts
git commit -m "chore(mobile-rn): whitelist App Review test account (P2-B7)"

# P3+P4+P5+P6 (같은 파일 app.config.ts)
git add apps/mobile-rn/app.config.ts
git commit -m "fix(mobile-rn): iOS Info.plist hygiene — scheme, dark-only, privacy manifest, speech permission (P3-B9, P4-B10, P5-B8, P6-B11)"

# P7
git add apps/mobile-rn/src/providers/app-bootstrap-provider.tsx
git commit -m "fix(mobile-rn): iPad Sign-in cold-start race — listener pre-bootstrap + URL dedup (P7-B1)"

# P8
git add supabase/functions/_shared/auth.ts \
        supabase/functions/fortune-tarot/index.ts \
        supabase/functions/fortune-birthstone/index.ts \
        supabase/functions/widget-cache/index.ts
git commit -m "fix(edge): derive userId from JWT, drop body.userId (P8-B4)"

# P9
git add supabase/functions/kakao-oauth/index.ts
git commit -m "fix(edge): verify Kakao token via /v2/user/me — stop impersonation (P9-B3)"

# P10 (multiple files)
git add supabase/functions/fortune-health/index.ts \
        apps/mobile-rn/src/features/chat-results/adapter.ts \
        apps/mobile-rn/src/features/chat-results/types.ts \
        apps/mobile-rn/src/features/fortune-results/primitives/result-card-frame.tsx
git commit -m "fix: fortune-health strip clinical vitals + add disclaimer UI (P10-B5)"

# P11 (UGC moderation — many files)
git add supabase/migrations/20260423000001_ugc_moderation.sql \
        supabase/functions/_shared/moderation.ts \
        supabase/functions/report-message/index.ts \
        supabase/functions/character-chat/index.ts \
        supabase/functions/delete-account/index.ts \
        apps/mobile-rn/src/lib/character-blocks.ts \
        apps/mobile-rn/src/features/chat-surface/message-report-sheet.tsx \
        apps/mobile-rn/src/features/chat-surface/chat-surface.tsx \
        apps/mobile-rn/src/screens/character-profile-screen.tsx \
        apps/mobile-rn/src/screens/chat-screen.tsx
git commit -m "feat: UGC moderation, message report, character block (P11-B2, Apple 5.2.3)"
```

### 🟡 옵션 2의 혼재 파일 주의
- `chat-surface.tsx` + `chat-screen.tsx` commit은 pre-existing 대규모 리팩토링 작업까지 같이 들어감. 이 작업이 별도 PR로 나가야 한다면 `git add -p` 로 내 hunk만 분리해 커밋하거나, pre-existing 작업을 먼저 별도 커밋한 뒤 내 파일을 덮어써서 내 변경만 커밋.
- 간단한 분리 방법:
  ```bash
  # 혼재 파일 2개를 잠시 stash (내 변경만 살림)
  git stash push apps/mobile-rn/src/features/chat-surface/chat-surface.tsx apps/mobile-rn/src/screens/chat-screen.tsx
  # ... 다른 파일 커밋 ...
  git stash pop
  # 이제 git add -p 로 필요한 hunk만 선택
  git add -p apps/mobile-rn/src/features/chat-surface/chat-surface.tsx
  git add -p apps/mobile-rn/src/screens/chat-screen.tsx
  ```

---

## 상세 리포트 레퍼런스

- `artifacts/ios-review/REPORT.md` — 초기 전체 감사 (SHIP BLOCKER/WARNING/PASS 분류)
- `artifacts/sprint-fixes/P{1..11}-*/contract.md` — phase별 계약 + 수용 기준
- `artifacts/sprint-fixes/P{1..11}-*/review*.md` — 각 phase reviewer 판정

## 검증 완료

- `npx tsc --noEmit` 0 errors (P1~P11 모든 phase 후)
- 각 phase별 전문가 reviewer (code + iOS domain + security) PASS 판정
- 후속 사항: `artifacts/sprint-fixes/P9-B3/followup.md` — FU1~FU4 (별도 스프린트 권장)
