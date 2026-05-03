# Ondo RN App - Claude Code 가이드

> 최종 업데이트: 2026.05.03

## 워크플로우 (글로벌 gstack 위임)

이 프로젝트는 솔로 운영입니다. 자체 Generator-Evaluator 파이프라인 대신 글로벌 `~/.claude/skills/`의 검증된 스킬을 위임 사용합니다.

| 상황 | 사용할 스킬 / 도구 |
|------|---------------------|
| 큰 변경 (3+ 파일, 새 기능) | `/autoplan` (CEO/eng/design/devex 4단 리뷰) → 코드 작성 |
| 버그/에러/"안됨"/"깨짐" | `/investigate` (4-phase RCA, Iron Law: no fix without root cause) |
| 1–2 파일 단순 수정 | 직접 편집 + `npx tsc --noEmit` |
| 코드 리뷰 / 머지 직전 | `/review` |
| 브랜치 → PR | `/ship` (CHANGELOG, 버전 범프, 푸시, PR 생성) |
| QA / 동작 확인 | iOS Simulator MCP (`mcp__ios-simulator__*`) 또는 Expo Dev Client |
| 보안/스킴 점검 | `/cso` 또는 `/security-review` |
| Supabase Edge Function 단독 작업 | 프로젝트 `backend-service` 스킬 |

배포는 Stop 훅이 `./scripts/auto-deploy-on-stop.sh`로 OTA를 자동 처리합니다 (네이티브 모듈 추가 시는 EAS build 필요).

### 핵심 철학
- **Search Before Building**: 새로 만들기 전 `Grep`/`Glob`으로 기존 코드 확인.
- **Root Cause First**: 빈 catch / 단순 null 가드로 증상만 가리지 않기.
- **Verify Before Done**: `npx tsc --noEmit` 통과 + 사용자 테스트 확인 후 완료 선언.
- **Bisect Commits**: 하나의 논리적 변경 = 하나의 커밋.

---

## 절대 금지 (CRITICAL)

| 금지 | 이유 | 대안 |
|------|------|------|
| `expo start` / `eas build` 직접 실행 | 로그 확인 불가, 대화형 프롬프트 | 사용자에게 실행 요청 |
| 일괄 수정 (`for`, `sed -i`) | 프로젝트 망가짐 | 한 파일씩 Edit |
| `any` 타입 남발 | 타입 안전성 파괴 | 정확한 타입 정의 또는 `unknown` |
| 하드코딩 색상/폰트 | 디자인 시스템 위반 | `fortuneTheme.colors.*`, `AppText variant` |
| OpenAI/Gemini 직접 호출 (Edge Function) | LLMFactory 패턴 위반 | `LLMFactory.createFromConfig(...)` |
| 빈 catch / 원인 분석 없는 가드 | 버그 은폐 | `/investigate`로 근본 원인 추적 |

---

## 검증 체크리스트

코드를 수정한 뒤 항상 아래 순서로 검증한 후에만 "완료"를 선언합니다.

```bash
# apps/mobile-rn 기준
npx tsc --noEmit                      # TypeScript 0 errors 필수
npx expo lint                         # 설정돼 있을 때
# Edge Function 수정 시
cd supabase/functions && deno check ./<fn>/index.ts
```

UI/페이지 변경 시 추가로 사용자에게 구체적인 테스트 시나리오를 제시하고 응답을 대기합니다 (`feedback_test_instructions` 메모리).

---

## Figma 워크플로우

- 디자인 수정 요청은 Figma MCP부터: `get_design_context` → 코드 반영 → Code Connect 매핑 갱신.
- Figma 컨텍스트가 없으면 차단을 먼저 알리고 로컬 수정만 진행, 미동기화 상태를 보고에 명시.

---

## JIRA 자동 워크플로우

| 단계 | 액션 |
|------|------|
| 작업 시작 | `jira_post`로 FORT 프로젝트에 이슈 생성, 번호 알림 |
| 작업 완료 | 상태 → Done, 해결 내용 코멘트 |

| 키워드 | 이슈 타입 |
|--------|----------|
| 버그, 에러, 안됨, 깨짐 | Bug |
| 추가, 만들어줘, 새로운 | Story |
| 수정, 바꿔, 개선 | Task |

---

## 핵심 패턴 (5가지)

### 1. 상태 관리 (React Context + Hooks)
RN 앱 전역 상태는 `apps/mobile-rn/src/providers/*-provider.tsx`에서 `createContext` + 커스텀 훅 조합으로 노출. 별도 전역 스토어(Redux/Zustand) 도입 금지.
```tsx
const MobileAppStateContext = createContext<MobileAppStateContextValue | null>(null);
export function useMobileAppState() {
  const ctx = useContext(MobileAppStateContext);
  if (!ctx) throw new Error('MobileAppStateProvider missing');
  return ctx;
}
```

### 2. Typography / 색상 (AppText + fortuneTheme)
모든 텍스트는 `AppText`, 색상은 `fortuneTheme.colors.*`.
```tsx
import { AppText } from '@/components/app-text';
import { fortuneTheme } from '@/lib/theme';

<AppText variant="headlineMedium" color={fortuneTheme.colors.textPrimary}>
  제목
</AppText>
```

### 3. Edge Function (LLMFactory)
```typescript
const llm = LLMFactory.createFromConfig('fortune-type')
const result = await llm.generate({ prompt, maxTokens: 2000 })
```

### 4. 채팅 상태 (chat-shell discriminated union)
새 메시지/카드는 `apps/mobile-rn/src/lib/chat-shell.ts`의 `ChatShellMessage` 유니언에 `kind` 리터럴을 추가하고 `chat-surface.tsx`에서 분기 렌더.

### 5. 결과 카드 레지스트리 (fortune-results/registry)
새 운세 결과 화면은 `apps/mobile-rn/src/features/fortune-results/registry.tsx`에 등록, 채팅 임베드는 `mapping.ts`의 `resolveResultKindFromFortuneType`로 연결, 화면은 `screens/*.tsx`에 추가.

---

## 네비게이션 구조 (Chat-First)

| 탭 | 경로 | 역할 |
|----|------|------|
| Home | `/chat` | 통합 채팅 진입점 |
| 인사이트 alias | `/home` | 레거시 별칭, `/chat`으로 redirect |
| 탐구 | `/fortune` | 인사이트 카테고리 + Face AI |
| 트렌드 | `/trend` | 트렌드 콘텐츠 |
| 프로필 | `/profile` | 설정 + Premium |

라우팅은 `expo-router` (`apps/mobile-rn/app/(tabs)/`).

---

## 문서 계층

| Tier | 문서 | 로드 조건 |
|------|------|----------|
| **1 (항상)** | 이 파일 (CLAUDE.md) | 모든 요청 |
| **2 (키워드)** | 01-03, 05-06, 18 | 개발 관련 키워드 시 |
| **3 (요청)** | 07-26 | 명시적 요청 시만 |

| 문서 | 트리거 키워드 |
|------|-------------|
| [01-core-rules](.claude/docs/01-core-rules.md) | 에러, 버그, 금지, 규칙 |
| [02-architecture](.claude/docs/02-architecture.md) | 아키텍처, Feature, 레이어 |
| [03-ui-design-system](.claude/docs/03-ui-design-system.md) | UI, 색상, 폰트, 다크모드 |
| [05-fortune-system](.claude/docs/05-fortune-system.md) | 인사이트, Fortune, 토큰 |
| [06-llm-module](.claude/docs/06-llm-module.md) | Edge Function, LLM, API |
| [18-chat-first-architecture](.claude/docs/18-chat-first-architecture.md) | 채팅, chat, 대화, Home |
| [24-page-layout-reference](.claude/docs/24-page-layout-reference.md) | 페이지, 레이아웃, 라우팅, 화면 |
| [25-fortune-result-schemas](.claude/docs/25-fortune-result-schemas.md) | 스키마, 결과, 응답, JSON, 필드 |
| [26-widget-component-catalog](.claude/docs/26-widget-component-catalog.md) | 위젯, 컴포넌트, 카드, 서베이 |

---

## MCP 서버 (우선순위)

| 순위 | MCP | 역할 |
|------|-----|------|
| 1 | Supabase | Edge Function, DB |
| 2 | iOS Simulator | E2E 자동 QA |
| 3 | Context7 | React Native / Expo / expo-router 문서 |
| 4 | JIRA | 티켓 관리 |
| 5 | Pencil | 공식 디자인 툴 (.pen 파일) |
| 6 | Figma | 디자인 컨텍스트 |

---

## 프로젝트 구조

```
apps/mobile-rn/                        # Expo SDK 54 / RN 0.81 / TypeScript
  app/(tabs)/                          # expo-router 라우트 (chat/fortune/trend/profile)
  src/components/                      # 공용 컴포넌트
  src/features/
    chat-surface/                      # 통합 채팅 화면 조립
    chat-survey/                       # 인라인 서베이/위젯
    chat-results/                      # 임베디드 결과 카드 어댑터
    fortune-results/                   # 결과 화면 레지스트리 + screens/*
    fortune-cookie/                    # 포춘쿠키 / 사주 프리뷰 카드
  src/providers/                       # React Context providers
  src/lib/                             # 도메인 로직 (chat-shell, theme, supabase, ...)

packages/
  product-contracts/                   # FortuneTypeId, ProductId 등 TS 컨트랙트
  design-tokens/                       # fortuneTheme 소스

supabase/functions/                    # Edge Functions (Deno, LLMFactory)
.claude/skills/backend-service/        # Edge Function 생성 스킬
.claude/docs/                          # 상세 문서 (01-26)
```

---

## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
- Save progress, checkpoint, resume → invoke context-save / context-restore
- Code quality, health check → invoke health
- Edge Function only (no RN changes) → invoke backend-service
