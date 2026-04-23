# App Store Connect — Review Notes 원고

제출 시 ASC → 앱 버전 → App Review Information → Notes 에 붙여넣기. 영어+한국어 혼합 (리뷰어 지역에 따라).

## Full Notes (권장)

```
Hello App Review Team,

We addressed the previous rejection items and hardened additional areas for this
submission (build 1.0.9).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Account (reviewer shortcut)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email:    test@zpzg.com
Password: TestPassword123!

This account has a "Factory Reset" affordance in Profile screen (below the
delete-account link) that clears local caches + re-runs onboarding, so you can
validate cold-start flows without reinstalling.

No login is strictly required to browse — a "게스트로 둘러보기" / "Browse as guest"
path is visible on the welcome carousel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Previous Rejection Items — Addressed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

■ Guideline 2.1 — iPad Sign in with Apple
  • Fixed cold-start race: the deep-link URL listener now attaches
    synchronously on AppBootstrapProvider mount, BEFORE the async bootstrap
    chain begins. Previously the listener was set up after `getInitialURL()`
    awaited, which could drop the OAuth callback URL on iPad when Apple's
    native flow falls back to a web-based OAuth session.
  • Implemented idempotent URL-level dedup so even if iOS double-delivers the
    same callback (getInitialURL + 'url' event), the PKCE code is exchanged
    exactly once.
  • File: apps/mobile-rn/src/providers/app-bootstrap-provider.tsx
  • Native URL forwarding confirmed in AppDelegate.swift (openURL +
    userActivity both → RCTLinkingManager → JS 'url' event).

■ Guideline 3.1.2 — Subscription Metadata
  • Paywall displays full auto-renewable subscription disclosure block
    (length, price, auto-renewal terms) BEFORE any purchase button.
  • Terms of Use (EULA) + Privacy Policy links present on the paywall.
  • App Store metadata "Privacy Policy URL" field uses the canonical HTTPS
    domain. App Description includes the EULA URL.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Additional Compliance Hardening (this release)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

■ Guideline 5.2.3 — UGC moderation (AI character chat)
  • Server-side pre-filter: every user message and every AI response runs
    through OpenAI omni-moderation-latest before storage or display. Flagged
    content is replaced with a safe fallback.
  • In-app report: long-press any AI message → 6-category report sheet → the
    report is persisted in `message_reports` table (24-hour review SLA).
  • In-app block: each character's profile screen has a "이 캐릭터 차단하기"
    (Block this character) button. Blocked characters disappear from the
    chat list immediately.
  • EULA updated with conduct rules + 24h takedown commitment.

■ Guideline 5.1.2 — Medical content (fortune-health card)
  • Removed clinical vitals (heart rate, blood pressure, blood glucose, SpO₂)
    from the AI prompt context. Apple Health integration is scoped to
    fitness-tracking data (steps, sleep, weight, workouts, calories).
  • Rewrote JSON schema labels from prescriptive ("증상 원인 / 관리법 /
    예방법") to lifestyle-oriented ("컨디션 / 생활 루틴 / 오늘의 팁").
  • Every health response card displays a persistent disclaimer: "This health
    suggestion is for reference/entertainment purposes only. Not medical
    advice; consult a professional for persistent symptoms."

■ Guideline 5.1.1(v) — Account deletion
  • Unchanged behavior (already compliant): Profile → 계정 삭제 → hard-deletes
    22 tables in a single transaction + calls supabase.auth.admin.deleteUser.
  • This release adds `message_reports` and `character_blocks` tables to the
    deletion target list so UGC moderation data also gets purged.

■ Required Reason APIs + Privacy Manifest
  • apps/mobile-rn/ios/app/PrivacyInfo.xcprivacy declares:
    - NSPrivacyAccessedAPIType: FileTimestamp, UserDefaults, SystemBootTime,
      DiskSpace (with the API-catalog reason codes).
    - NSPrivacyCollectedDataTypes: 11 entries matching the ASC App Privacy
      answers exactly (see mapping in submission artifacts).
  • NSPrivacyTracking: false, no tracking domains.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reviewer Walkthrough (reproducibility)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A. iPad Sign in with Apple (previous reject path)
   1. Install on iPad.
   2. Open the app → proceed through welcome → tap "Sign in with Apple".
   3. Authenticate with your Apple ID.
   4. App returns to home screen ("/chat"). Expected: authenticated state
      persists across cold starts.

B. AI character chat moderation + report + block
   1. Sign in with test@zpzg.com.
   2. Open any character in the chat list.
   3. Send a message → receive an AI response.
   4. LONG-PRESS the AI bubble → "메시지 신고" sheet appears with 6 reason
      chips → select any → "신고하기".
   5. Back out to character profile via the header button → scroll down →
      "안전 도구" card → "이 캐릭터 차단하기" → confirm.
   6. Return to chat list. Expected: the blocked character is no longer
      visible.

C. Account deletion + resign-in
   1. Profile → 계정 삭제 → confirm.
   2. App returns to signup. Relogin with the same account creates a fresh
      profile (no historical rows).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Notes on In-App Purchase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Paid content is limited to the auto-renewable subscription
  "com.beyond.fortune.subscription.max". No external payment steering.
• Restore Purchases is present on the paywall and Profile → "구매 복원".
• Korean legal URLs (zpzg.co.kr) are accessible from both the paywall and
  Profile screen.

Thank you for the thorough review.
```

## Short Notes (백업 — 너무 길다고 하면)

```
Build 1.0.9 addresses:
- 2.1 iPad Sign in with Apple cold-start race (Linking listener attached
  synchronously before bootstrap; URL dedup for duplicate callback delivery)
- 3.1.2 subscription metadata (EULA + Privacy links on paywall; auto-renew
  disclosure)
- 5.2.3 UGC moderation: server-side content filter on AI chat + long-press
  message report + character block from profile screen
- 5.1.2 medical content: removed clinical vitals from health fortune; added
  disclaimer to every health card
- Required Reason APIs + Privacy Manifest fully declared; ASC App Privacy
  answers match manifest 1:1

Test account: test@zpzg.com / TestPassword123!
Reviewer walkthrough in attached notes (expand or ask).
```

---

## 문서 레퍼런스 (실제 ASC에 붙이지 말 것 — 내부용)

- `artifacts/sprint-fixes/P1-B6 ~ P11-B2/contract.md` — 각 변경 근거
- `artifacts/sprint-fixes/P11-B2/review.md` — UGC 구현 리뷰 통과
- `artifacts/ios-review-fixes/asc/01-app-privacy-answers.md` — Privacy 답변 매핑
