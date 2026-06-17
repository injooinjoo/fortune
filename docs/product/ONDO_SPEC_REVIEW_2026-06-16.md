# Ondo 앱 스펙 전체 정리 및 축소 검토

> 작성: 2026-06-16 15:49 KST
> 목적: 현재 온도/Ondo 앱의 제품 스펙을 코드·문서·감사 리포트 기준으로 다시 정리하고, 줄이거나 합칠 항목을 결정하기 위한 기준 문서
> 범위: 읽기 전용 조사 기반. 코드/배포 변경 없음. 기존 작업 트리는 시작 시점부터 dirty 상태였음.

## 0. Executive Summary

현재 Ondo는 과거 문서상으로는 “운세/인사이트 플랫폼 + AI 캐릭터 + proactive + 이미지/음성 + IAP/광고 + 온디바이스 LLM + 위젯/워치”까지 넓어져 있지만, 실제 current-state 제품은 이미 아래 구조로 수렴해 있다.

> **Ondo는 `/chat` 중심 AI Chat 앱이며, 핵심 경험은 `일반 채팅`과 `호기심/운세` 2개다.**

따라서 지금은 기능 추가보다 **표면 축소, 문서 SoT 정리, 결제/개인정보/App Store 리스크 제거**가 우선이다.

### 결론

- **유지할 것**: `/chat`, 일반 캐릭터 채팅, 하늘이/호기심 텍스트 운세, 결과 카드/리딩, 프로필, 프리미엄/토큰, 법적/계정 삭제.
- **합칠 것**: 독립 운세 표면 → 하늘이/호기심으로 통합, 결제/충전/복원 → `/premium` 하나로 통합, 온보딩 variant → 단일 최소 온보딩.
- **줄이거나 숨길 것**: 광고 보상, 이미지/포스터형 운세, 온디바이스 LLM 자동 다운로드, 독립 `/fortune`·`/trend`·`/interactive` 계열 표면, custom friend wizard, full proactive messaging, 위젯/워치/iPad-specific 확장.
- **문서 정리 원칙**: current spec / architecture / audit / archive를 분리하고, Flutter·Riverpod·legacy 탭 구조 문서는 current SoT에서 제외한다.

---

## 1. Repo 상태와 전제

시작 시점 `git status --short --branch` 기준:

- 브랜치: `master...origin/master`
- 작업 트리는 이미 dirty 상태.
- 주요 수정/미추적 항목 예:
  - `apps/mobile-rn/src/screens/chat-screen.tsx`
  - `apps/mobile-rn/src/lib/push-notifications.ts`
  - `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx`
  - `apps/mobile-rn/targets/notification-service/NotificationService.swift`
  - `supabase/functions/character-chat/index.ts`
  - `supabase/functions/_shared/notification_push.ts`
  - `supabase/functions/character-chat/photo_reaction_quality.ts` 등

이 문서는 기존 dirty 변경을 수정하지 않고, 읽기 전용 조사 결과만 정리한다.

---

## 2. Current Product Spec

### 2.1 한 줄 정의

**온도는 AI 캐릭터와 DM처럼 대화하고, 하늘이에게 궁금한 운세/호기심을 물어보는 채팅 앱이다.**

### 2.2 핵심 제품 구조

| 층위 | 유지할 current-state |
|---|---|
| 메인 표면 | `/chat` 단일 중심 |
| 핵심 경험 A | 일반 캐릭터와 관계형/세계관형 채팅 |
| 핵심 경험 B | 하늘이/운세 전문가를 통한 호기심·운세 설문과 결과 리딩 |
| 보조 표면 | `/profile`, `/premium`, 법적 문서, 계정 삭제 |
| 과금 | 토큰 기반 사용 + 월 토큰 지급 구독 + IAP 복원 |
| backend | Supabase Auth/DB/Edge Functions, LLM provider abstraction |

### 2.3 실제 기술 스택

현재 운영 앱은 Flutter가 아니라 React Native / Expo-managed 구조다.

근거:

- `apps/mobile-rn/package.json`
  - `main: expo-router/entry`
  - Expo `~54.0.35`
  - React Native `0.81.5`
  - React `19.1.0`
- `apps/mobile-rn/app.config.js`
  - 앱 이름: `온도`
  - slug: `ondo-mobile-rn`
  - bundle/package/scheme: `com.beyond.fortune`
  - runtime/version: `1.0.14`

### 2.4 실제 라우트/표면

#### 앱 시작

- `/` → 실제로 `/splash`로 redirect.
- `/splash` bootstrap gate 결과:
  - auth entry → `/welcome` 또는 `/chat?showList=1`
  - profile flow → `/onboarding`
  - ready → `/chat`

근거:

- `apps/mobile-rn/app/index.tsx`
- `apps/mobile-rn/src/screens/splash-screen.tsx`

#### 메인

- `/chat` → `/(tabs)/chat` → `ChatScreen`
- 실제 탭은 `chat`, `profile` 중심이며 native에서는 tab bar가 숨김 처리됨.

근거:

- `apps/mobile-rn/app/chat.tsx`
- `apps/mobile-rn/app/(tabs)/chat.tsx`
- `apps/mobile-rn/app/(tabs)/_layout.tsx`
- `apps/mobile-rn/src/screens/chat-screen.tsx`

#### redirect/legacy 성격

- `/home` → `/chat`
- `/trend` → `/chat`
- `/fortune` → 기본 `/chat`, feature flag에 따라 하늘이 채팅 intent 보존 redirect

따라서 `/home`, `/trend`, `/fortune`를 독립 제품 표면으로 키우면 current-state와 충돌한다.

#### 보조 표면

- 인증/온보딩: `/welcome`, `/signup`, `/auth/email`, `/auth/phone`, `/onboarding/*`
- 프로필: `/profile`, `/profile/edit`, `/profile/saju-summary`, `/profile/relationships`, `/profile/notifications`
- 결제: `/premium`
- 캐릭터/친구: `/character/[id]`, `/friends/new/*`
- 법적/고지: `/privacy-policy`, `/terms-of-service`, `/eula`, `/disclaimer`, `/business-info`, `/open-source-licenses`, `/account-deletion`
- 위젯/딥링크: `/widget`, `/widgets`

---

## 3. 현재 문서 SoT 판단

### 3.1 Current SoT로 유지할 문서

| 문서 | 판단 | 메모 |
|---|---|---|
| `CLAUDE.md` | 유지 | RN/Expo 기준 최신 운영 규칙. 단, 자동 배포 정책은 skill/프로젝트 최신 기억과 충돌 가능성이 있어 실제 작업 때 재확인 필요. |
| `AGENTS.md` | 유지 | Codex 통합 규칙. 일부 Flutter 잔재가 있어 제품/기술 SoT로는 부적합. |
| `docs/getting-started/APP_SURFACES_AND_ROUTES.md` | 유지+갱신 | `/chat` 중심 제품 방향은 맞음. RN Expo Router 기준 라우트 inventory 갱신 필요. |
| `docs/getting-started/PROJECT_OVERVIEW.md` | 부분 유지+갱신 | 제품 설명은 유효하나 Flutter/Riverpod/`lib/` 경로는 stale. |
| `.claude/docs/22-business-model.md` | 유지 | BM 의도 문서. 가격/토큰은 코드 상수와 대조 필요. |
| `.claude/docs/05-fortune-system.md` | 제한 유지 | 운세 taxonomy/흐름 참고용. 비용표는 legacy 처리. |
| `docs/audits/2026-06-ondo-full-audit/reports/13-consolidated-fix-plan.md` | 유지 | 현재 리스크 backlog 최상위 기준. |
| `docs/audits/2026-06-ondo-full-audit/reports/01-bm-iap-revenue-report.md` | 유지 | 결제/수익 leakage 판단 기준. |
| `docs/audits/2026-06-ondo-full-audit/reports/02-app-store-review-report.md` | 유지 | App Store 제출 리스크 기준. |
| `docs/audits/2026-06-ondo-full-audit/reports/07-haneul-fortune-e2e-report.md` | 유지 | 하늘이/운세 E2E readiness 기준. |
| `docs/audits/2026-06-ondo-full-audit/reports/10-architecture-duplication-performance-report.md` | 유지 | 구조/중복/성능 정리 기준. |
| `docs/audits/2026-06-ondo-full-audit/reports/11-supabase-rls-edge-health-report.md` | 유지 | Storage/RLS/Edge health 기준. |

### 3.2 Legacy/Archive 후보

| 문서 | 처리 | 이유 |
|---|---|---|
| `.claude/docs/18-chat-first-architecture.md` | archive/reference | 문서 자체가 legacy/future-state note. 5탭 구조는 current SoT 아님. |
| `docs/features/CELEBRITY_AVATAR_SYSTEM_PLAN.md` | archive/delete 후보 | Flutter/OpenAI 직접 호출 등 현재 규칙·구조와 충돌. |
| `docs/features/HANEUL_UNIFIED_FORTUNE_PLAN.md` | archive+요약 승격 | 기획 배경은 유효하나 feature flag/atomic token 등 구현 상태 drift. |
| `docs/features/HANEUL_AUDIT_RESULTS.md` | archive evidence | phase-0 evidence로만 유지. current blocker는 2026-06 audit 우선. |
| `docs/features/PROACTIVE_MESSAGING_PLAN.md` | backlog로 격하 | 초기 full plan 범위가 너무 넓고, 현재 P1 안정화 필요. |
| `docs/BUSINESS_OVERVIEW.md` | archive 권장 | 35개 카테고리/대형 플랫폼/무제한 모델 등 current MVP와 충돌. |
| Flutter/Riverpod/GoRouter/`lib/` 기준 getting-started 섹션 | 삭제/갱신 | 실제 앱은 RN/Expo Router. |

---

## 4. 핵심 불일치 목록

| 항목 | 문서/계약 | 실제/최신 판단 | 조치 |
|---|---|---|---|
| Root redirect | 일부 문서/contract는 `/` → `/chat` | 실제 `app/index.tsx`는 `/splash` | route SoT 갱신 |
| 기술 스택 | Flutter/Riverpod/GoRouter 문서 잔존 | RN/Expo Router | 문서 전면 갱신 |
| `/fortune` | 독립 운세 표면처럼 남은 문서 | 실제는 flag 기반 `/chat`/하늘이 redirect | 독립 표면 제거/legacy 처리 |
| `/trend` | 과거 탭/표면 | 실제 `/chat` redirect | 제거/legacy 처리 |
| 토큰 비용 | `.claude/docs/05`의 1/2/3/5 | `.claude/docs/22` 및 `fortune-pricing.ts`의 1/5/12/25/50 | 05 비용표 legacy 처리 |
| 구독 | 일부 문서의 “무제한” 뉘앙스 | current policy는 finite monthly token allowance 지향 | 무제한 문구 삭제 |
| 광고 보상 | 기능 존재/문서 존재 | P0 수익·심사 리스크 | 숨김/제거 또는 SSV-only 완료 후 재도입 |
| 이미지/포스터 운세 | 제품 확장 요소 | billing/storage P0 리스크 | 숨김/보류 |
| 온디바이스 LLM | 기술 가능성 존재 | 자동 다운로드 App Store 리스크 | off/opt-in 후순위 |

---

## 5. Keep / Merge / Cut / Defer

### 5.1 KEEP — 유지

#### K1. `/chat` 단일 메인 표면

- 제품 판단 비용을 줄이고 QA matrix를 줄인다.
- `/home`, `/fortune`, `/trend` 다중 탭 회귀를 막는다.
- App Store evidence도 `/chat` 중심으로 집중 가능하다.

#### K2. 일반 채팅

- 캐릭터와 DM처럼 대화하는 핵심 value.
- 단, AI 캐릭터임을 부정하거나 사람인 척하는 문구는 App Store/사용자 신뢰 관점에서 정리 필요.

#### K3. 하늘이/호기심 텍스트 운세

- Ondo의 차별점.
- 텍스트 기반 설문 → 결과 카드/리딩부터 안정화한다.

#### K4. 프로필/프리미엄/법적 페이지

- 제품 보조 표면으로 필요.
- 단, 프로필을 별도 복잡한 hub로 키우기보다 설정/결제/법무 지원 역할로 제한한다.

### 5.2 MERGE — 합치기

#### M1. 운세 표면 → 하늘이/호기심으로 통합

합칠 대상:

- `/fortune`
- 운세 카탈로그 page
- 개별 운세 CTA
- “내 운세” 결과 모음
- 운세 전문가 캐릭터들

통합안:

- `/chat` 안에서 하늘이가 fortune catalog를 카드/메뉴로 제안.
- 사용자는 채팅형 설문으로 입력.
- 결과는 채팅 메시지 + 카드 + 리딩 화면으로 소비.
- “내 운세”는 프로필 보조 메뉴 또는 하늘이 대화 안에서 재열람.

#### M2. Premium / Top-up / Restore → 결제 센터로 통합

`/premium` 하나에서 아래를 처리한다.

- 현재 토큰 잔액
- 토큰 충전
- 구독 혜택
- 구매 복원
- 미완료 구매 확인
- 결제 문제 도움말

핵심은 UI 문구와 서버 entitlement가 1:1로 맞아야 한다는 점이다.

#### M3. 온보딩 variant → 단일 최소 온보딩

- 현재 step route는 유지하되 사용자-facing 제품 관점에서는 하나의 온보딩만 설명한다.
- `toss-style` 같은 변형은 실험/legacy로 격하.
- 첫 출시 기준 입력은 이름/생년월일/관심사/대화 톤 등 채팅·호기심에 필요한 최소값만.

#### M4. 알림 설정 단순화

초기 설정은 아래 정도로 축소한다.

- 캐릭터 메시지 알림 ON/OFF
- 이벤트/마케팅 알림 ON/OFF

캐릭터별/슬롯별/quiet hours/absence trigger는 후순위.

### 5.3 CUT — 제거/숨김

#### C1. 광고 보상 토큰 지급

MVP/App Store 제출 전에는 제거 또는 완전 비활성화 권장.

이유:

- self-attestation/중복 지급 가능성.
- AdMob/App Privacy/ATT 정합성 비용.
- 수익 보조보다 심사·보안 리스크가 큼.

조건부 재도입 기준:

- SSV-only
- transaction idempotency
- client POST fallback 제거
- App Privacy/ATT/review note 정합성 완료

#### C2. 이미지/포스터형 운세

숨김/보류 권장.

이유:

- 큐 생성 전 토큰 reserve/차감 문제.
- worker 실패 refund/idempotency 문제.
- 사용자 이미지 Storage private/RLS/signed URL durability 리스크.
- 서버 이미지 생성 비용 누수 가능성.

#### C3. 온디바이스 LLM 자동 다운로드

off 권장.

이유:

- 대용량 모델 자동 다운로드는 App Store/데이터/저장공간 리스크.
- core MVP 가치와 직접 연결성이 낮음.
- 추후 “오프라인 모드” 명확한 가치가 생기면 opt-in으로 재검토.

#### C4. 독립 `/fortune`, `/trend`, `/interactive`, `/health-toss`, `/exercise`, `/sports-game` 표면

current 제품 스펙에서 제거/legacy 처리.

이유:

- 실제 active route가 아니거나 `/chat` redirect.
- chat-first 방향과 충돌.
- QA/App Store evidence 비용 증가.

#### C5. 35개 운세/인사이트 플랫폼 문구

current 제품 문서에서 삭제/아카이브.

이유:

- 대형 플랫폼 비전은 현재 MVP와 충돌.
- BM/심사/운영 복잡도를 과하게 키움.
- 실제 안정화 우선순위는 채팅 delivery, billing, privacy.

### 5.4 DEFER — 보류

#### D1. Full proactive messaging

보류 항목:

- 7개 시간대 슬롯
- absence trigger
- 날씨/생일/공휴일 trigger
- 이미지 reveal
- TTS proactive
- 캐릭터별 세밀한 알림 설정
- long-press notification action

유지 가능한 최소 범위:

- 기존 캐릭터 DM push 안정화.
- proactive는 1명/1슬롯 dogfood 파일럿 수준.

#### D2. 사진/음성/멀티모달 채팅 고도화

MVP는 텍스트 중심. 사진/음성은 지원 범위를 제한한다.

보류 이유:

- durable media storage/expiry/restore UX 필요.
- 사진 reply pipeline과 storage privacy가 아직 리스크.
- 음성 progress/seek/보관 UX가 별도 QA matrix를 만든다.

#### D3. 커스텀 친구 생성 wizard

현재 `/friends/new/*` 다단계 flow는 매력적이지만 MVP에서는 과하다.

권장:

- preset 캐릭터 중심.
- 커스텀 친구는 hidden/internal 또는 1-screen simple creation으로 축소.

#### D4. 위젯/워치/iPad-specific 확장

보류.

이유:

- iPhone core path 검증도 아직 충분하지 않음.
- 위젯/워치/iPad는 QA matrix를 크게 늘림.
- iPad 지원을 유지한다면 compatibility QA로만 다룬다.

---

## 6. MVP 스펙 제안

### 6.1 출시 MVP에 포함

1. `/chat`
2. 일반 캐릭터 텍스트 채팅
3. 하늘이/호기심 텍스트 기반 운세
4. 설문형 입력
5. 결과 카드/리딩
6. 토큰 충전/구독/구매 복원
7. 프로필/알림 기본 설정
8. 개인정보처리방침/약관/EULA/계정 삭제
9. push notification 기본 delivery 안정화

### 6.2 출시 MVP에서 제외

1. 보상형 광고
2. 이미지/포스터형 운세
3. 온디바이스 LLM 자동 다운로드
4. full proactive messaging
5. custom friend wizard full flow
6. 위젯/워치/iPad-specific 기능 홍보
7. 35개 운세 전체 전면 노출
8. “모든 것 무제한” 구독 문구

### 6.3 앱 포지셔닝 문구

권장:

> “AI 캐릭터와 대화하고, 하늘이에게 오늘 궁금한 흐름을 물어보는 채팅 앱”

피해야 할 문구:

- “35개 모든 인사이트 무제한”
- “AI가 아닌 실제 사람/친구처럼 답장”
- “광고 보면 무제한 무료”
- “오프라인 AI 자동 지원”
- “모든 운세/이미지/음성 무제한”

---

## 7. 문서 구조 재정리안

현재 문서는 current-state, future-state, legacy, audit가 섞여 있다. 아래처럼 분리하는 것이 좋다.

```text
docs/
  README.md
  product/
    CURRENT_PRODUCT_SPEC.md
    SURFACES_AND_ROUTES.md
    BM_AND_ENTITLEMENTS.md
    APP_STORE_RISK_REGISTER.md
    ROADMAP.md
  architecture/
    CURRENT_ARCHITECTURE.md
    CHAT_RUNTIME.md
    BILLING_AND_TOKENS.md
    STORAGE_AND_PRIVACY.md
  features/
    curiosity/
      HANEUL_SPEC.md
      FORTUNE_CATALOG.md
    chat/
      GENERAL_CHAT_SPEC.md
      MEDIA_MESSAGE_BACKLOG.md
    proactive/
      PROACTIVE_BACKLOG.md
  audits/
    2026-06-ondo-full-audit/
      reports/
      evidence/
  archive/
    legacy-business-overview-2025.md
    old-35-fortune-platform-plan.md
    old-tabs-and-routes.md
```

### 7.1 각 문서 역할

#### `product/CURRENT_PRODUCT_SPEC.md`

- current 제품 정의만 포함.
- `/chat`, 일반 채팅, 호기심/하늘이, 프로필, 프리미엄, 법적 표면.
- proactive full plan, image fortune, on-device LLM, watch/widget 등은 제외.

#### `product/SURFACES_AND_ROUTES.md`

- 실제 `apps/mobile-rn/app/**` 기준 active route inventory.
- redirect-only와 user-facing surface를 분리.
- `packages/product-contracts/src/routes.ts` drift도 같이 추적.

#### `product/BM_AND_ENTITLEMENTS.md`

- 토큰 비용
- 무료 정책
- 구독 월 토큰 지급량
- 광고 사용 여부
- restore 정책
- 서버/RN/product-contract source-of-truth 파일 경로

#### `product/ROADMAP.md`

- Now: chat delivery, billing/token safety, privacy/app store 정합성, 하늘이/호기심 통합
- Next: 내 운세 재열람, media reply 안정화, proactive 1명/1슬롯 파일럿
- Later: custom character, image fortune, widgets/watch, on-device LLM

#### `archive/`

- 과거 대형 플랫폼 문서, Flutter 문서, 5탭 구조 문서, celebrity avatar plan을 이동.
- 각 문서 상단에 “현 current-state 아님” 배너 추가.

---

## 8. 우선순위 실행안

### P0 — 스펙 축소/위험 제거

1. 광고 보상 기능을 제품 스펙에서 제거/숨김으로 결정.
2. 이미지/포스터형 운세를 제출/MVP 스펙에서 제외.
3. 온디바이스 LLM 자동 다운로드 off를 제품 정책으로 명시.
4. 구독 “무제한” 문구 제거, finite monthly token allowance로 통일.
5. `/fortune`, `/trend`, `/interactive` 등 독립 표면을 legacy/redirect-only로 문서화.

### P1 — 문서 SoT 재작성

1. `docs/product/CURRENT_PRODUCT_SPEC.md` 생성.
2. `docs/product/SURFACES_AND_ROUTES.md`를 실제 Expo Router 기준으로 생성/갱신.
3. `docs/product/BM_AND_ENTITLEMENTS.md` 작성.
4. 기존 `PROJECT_OVERVIEW.md`, `APP_SURFACES_AND_ROUTES.md`의 Flutter/Riverpod/`lib/` 잔재 제거.
5. `docs/README.md`에 current/legacy/audit 읽는 순서 명시.

### P2 — 제품 backlog 재분류

1. proactive plan을 `features/proactive/PROACTIVE_BACKLOG.md`로 격하.
2. custom friend wizard를 Next/Later로 이동.
3. media message를 `MEDIA_MESSAGE_BACKLOG.md`로 분리.
4. 35개 운세/인사이트 플랫폼 문서를 archive.

---

## 9. 최종 판단

지금 Ondo가 줄여야 할 것은 기능 자체보다 **제품 표면과 약속의 수**다.

가장 안전한 방향은 다음이다.

1. `/chat`만 메인으로 둔다.
2. 사용자는 “캐릭터와 대화”하거나 “하늘이에게 호기심을 물어본다.”
3. 텍스트 기반 경험부터 완성한다.
4. 토큰/구독/복원/계정삭제/개인정보를 먼저 닫는다.
5. 광고, 이미지, 온디바이스, proactive full system, custom friend, 위젯/워치는 current spec에서 빼고 backlog로 보낸다.

즉, 현재 제품 스펙은 아래 정도로 압축하는 것이 맞다.

> **온도 MVP = `/chat` + 일반 캐릭터 채팅 + 하늘이 호기심 운세 + 토큰/구독 + 프로필/법무.**
