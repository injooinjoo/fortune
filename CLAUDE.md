# Ondo RN App - Claude Code 가이드

> 최종 업데이트: 2026.04.18

## 스프린트 워크플로우 (Generator-Evaluator 패턴)

**모든 개발 작업은 `/sc:sprint`로 시작합니다.** Planner → Generator → Evaluator → Ship

Anthropic "Harness Design for Long-Running Apps" 원칙 적용: 코드 작성자와 평가자를 분리하여 품질 향상.

### 핵심 철학
- **Boil the Lake**: 끝까지 완수. 엣지 케이스, 에러 경로 모두 커버
- **Search Before Building**: 만들기 전에 찾기. 기존 코드 재사용 최대화
- **Bisect Commits**: 하나의 논리적 변경 = 하나의 커밋
- **Generator-Evaluator 분리**: 코드 작성자 ≠ 코드 평가자 (fresh context)
- **Sprint Contract**: 파일 기반 명시적 완료 기준 (`artifacts/sprint/current/contract.md`)

### 워크플로우 아키텍처

```
사용자 요청
    │
    v
[PLANNER] (sc:sprint, 메인 컨텍스트)
    ├─ THINK: 분석 + Hard Block 판단
    ├─ CONTRACT: contract.md 작성 + 사용자 확인
    │
    v
[GENERATOR] (Agent subagent, fresh context)
    ├─ contract.md 기반 구현
    ├─ Discovery/RCA 보고서 (필요시)
    └─ build-log.md 작성
    │
    v
[EVALUATOR] (Agent subagent, fresh context)
    ├─ contract.md + build-log.md 기반 평가
    ├─ npx tsc --noEmit + 규칙 검증
    └─ eval-report.md 작성 (PASS/FAIL)
    │
    v
[PLANNER 복귀]
    ├─ FAIL → Generator 재실행 (최대 3회)
    ├─ PASS → 사용자 테스트 → SHIP
    └─ 3회 FAIL → 사용자 에스컬레이션
```

| 진입점 | 용도 |
|--------|------|
| `/sc:sprint` | 3+ 파일 변경, 기능 추가, 버그 수정 |
| `/sc:quick-fix` | 1-2 파일 단순 수정 (3-agent 세레모니 생략) |

**우선순위**: 사용자 명시적 요청 > 프로젝트 규칙 > 글로벌 SuperClaude

### Figma 기본 워크플로우
- 디자인 수정 요청은 기본적으로 Figma MCP부터 시작합니다.
- Figma URL, file key, node-id, 선택 가능한 Figma 문맥이 있으면 디자인 컨텍스트/변수/에셋을 먼저 조회합니다.
- 코드 반영 후 같은 Figma 문맥이 있으면 Code Connect 매핑도 함께 조회 또는 갱신하여 피그마-코드 동기화를 유지합니다.
- Figma 문맥이 없거나 MCP 연결이 불가하면 차단 사실을 먼저 알리고 로컬 수정은 진행할 수 있지만, 완료 보고에 미동기화 상태를 남깁니다.

---

## JIRA 자동 워크플로우 (CRITICAL)

**모든 개발 요청은 JIRA 등록부터 시작합니다!**

### 시작 시 (자동)
```
사용자 요청 감지 시:
1. jira_post로 이슈 생성 (FORT 프로젝트)
2. 이슈 번호 알림: "📋 FORT-XXX 생성됨"
3. 작업 시작
```

### 완료 시 (자동)
```
작업 완료 시:
1. jira_post로 상태 전환 (Done)
2. 해결 내용 코멘트 추가
3. 완료 알림: "✅ FORT-XXX 종료됨"
```

### 이슈 타입 자동 판단
| 키워드 | 이슈 타입 |
|--------|----------|
| 버그, 에러, 안됨, 깨짐 | Bug |
| 추가, 만들어줘, 새로운 | Story |
| 수정, 바꿔, 개선 | Task |

---

## 절대 금지 (CRITICAL)

| 금지 | 이유 | 대안 |
|------|------|------|
| `expo start` / `eas build` 직접 실행 | 로그 확인 불가, 대화형 프롬프트 | 사용자에게 실행 요청 |
| 일괄 수정 (for, sed -i) | 프로젝트 망가짐 | 한 파일씩 Edit |
| `any` 타입 남발 | 타입 안전성 파괴 | 정확한 타입 정의 or `unknown` |
| 하드코딩 색상/폰트 | 디자인 시스템 위반 | `fortuneTheme.colors.*`, `AppText variant` |
| OpenAI/Gemini 직접 호출 (Edge Function) | LLMFactory 패턴 위반 | `LLMFactory.createFromConfig(...)` |

---

## HARD BLOCK 시스템 (CRITICAL)

**조건 미충족 시 작업 자체를 차단합니다. 이 규칙은 어떤 상황에서도 무시할 수 없습니다.**

### Block 1: RCA 필수 (Root Cause Analysis)

| 트리거 | 에러, 버그, 안됨, 수정, 깨짐, 작동안함 키워드 |
|--------|---------------------------------------------|
| 차단 | RCA 보고서 없이 코드 수정 시도 시 |
| 해제 | WHY + WHERE ELSE + HOW 분석 완료 |

**금지 패턴** (이런 코드 작성 시 즉시 차단):
```ts
// ❌ 빈 catch 블록
try { ... } catch (e) { }
try { ... } catch (e) { console.log(e) }

// ❌ 원인 분석 없이 null/undefined 가드만
if (value != null) { ... }
```

**필수 출력 (RCA 보고서)**:
```
🔍 RCA 보고서
├─ 증상: [에러 메시지]
├─ WHY: 왜 발생? → [원인]
├─ WHERE: 어디서? → [파일:라인]
├─ WHERE ELSE: 탐색 결과 → [동일 패턴 N개 발견]
├─ HOW: 올바른 패턴 → [참조 파일:라인]
└─ 수정 계획: [N개 파일 수정 예정]
```

### Block 2: Discovery 필수 (기존 코드 탐색)

| 트리거 | 모든 코드 생성/추가 작업 |
|--------|------------------------|
| 차단 | 기존 코드 탐색 없이 새 코드 작성 시도 시 |
| 해제 | 유사 코드 검색 + 재사용 결정 완료 |

**필수 검색** (새 코드 작성 전, Grep tool 사용):
```
# Provider/Context 생성 시
pattern: "createContext|useContext"   path: apps/mobile-rn/src/providers

# 컴포넌트 생성 시
glob: apps/mobile-rn/src/components/**/*.tsx

# 채팅 메시지 타입 추가 시
pattern: "ChatShell.*Message"         path: apps/mobile-rn/src/lib/chat-shell.ts

# Edge Function 추가 시
glob: supabase/functions/**/index.ts
```

**필수 출력 (Discovery 보고서)**:
```
📂 Discovery 보고서
├─ 목표: [무엇을 만들 것인지]
├─ 검색 결과: [N개 유사 파일 발견]
│   ├─ [파일1.tsx] - 재사용 가능 ✅
│   ├─ [파일2.ts]  - 패턴 참조
│   └─ [파일3.tsx] - 참고만
├─ 재사용 결정:
│   ├─ 재사용: [함수/컴포넌트] from [파일]
│   ├─ 참조: [패턴] from [파일]
│   └─ 새로 작성: [꼭 필요한 부분만]
└─ 중복 방지: [기존 X가 있으므로 새로 만들지 않음]
```

### Block 3: Verify 필수 (검증)

| 트리거 | 모든 수정 작업 완료 시 |
|--------|----------------------|
| 차단 | 검증 미통과 시 "완료" 선언 불가 |
| 해제 | `npx tsc --noEmit` 통과 + 사용자 테스트 확인 |

**필수 검증 순서**:
```bash
# apps/mobile-rn 기준
1. npx tsc --noEmit              # TypeScript 에러 0 필수
2. npx expo lint                 # ESLint (설정돼 있을 때)
3. (Edge Function 수정 시) cd supabase/functions && deno check ./<fn>/index.ts
```

**필수 출력 (Verify 보고서)**:
```
✅ 검증 보고서
├─ tsc --noEmit: ✅ 0 errors
├─ expo lint: ✅ 통과 (또는 N/A)
├─ deno check: ✅ 통과 (또는 N/A)
├─ 수정된 파일:
│   ├─ [파일1.tsx]
│   └─ [파일2.ts]
└─ 🧪 테스트 요청:
    "아래 시나리오로 테스트해주세요:
    1. [단계1]
    2. [단계2]
    예상 결과: [결과]"

⏳ 사용자 테스트 결과 대기 중...
```

**완료 선언은 사용자가 "테스트 완료", "동작함", "확인" 응답 후에만 가능**

### Hard Block 시행 방식

Hard Block은 Sprint Contract + Evaluator를 통해 시행됩니다:

```
Planner (CONTRACT 단계)
    ├─ 에러/버그 → contract에 "RCA required: yes" 명시
    ├─ 새 코드 → contract에 "Discovery required: yes" 명시
    └─ 수용 기준 + Quality Gate 명시

Generator (GENERATE 단계)
    ├─ RCA required → rca-report.md 작성 후 코드 수정
    └─ Discovery required → discovery-report.md 작성 후 코드 생성

Evaluator (EVALUATE 단계)
    ├─ 보고서 존재 + 실질성 검증
    ├─ npx tsc --noEmit 실행
    ├─ 프로젝트 규칙 검증
    └─ FAIL이면 Generator 재실행

보고서는 artifacts/sprint/current/에 저장됩니다.
```

### JIRA 연동 (자동)

| 단계 | JIRA 액션 |
|------|----------|
| CONTRACT 단계 | 이슈 생성 (Bug/Story/Task) |
| SHIP 단계 | 이슈 상태 → Done, 해결 내용 코멘트 |

---

## 핵심 패턴 (5가지)

### 1. 상태 관리 (React Context + Hooks)
RN 앱 전역 상태는 `apps/mobile-rn/src/providers/*-provider.tsx`에서 `createContext` + 커스텀 훅 조합으로 노출됩니다. 별도 전역 스토어(Redux/Zustand) 도입 금지.
```tsx
// ✅ Provider + useXxx 훅 패턴 | ❌ 새 전역 스토어 도입 금지
// apps/mobile-rn/src/providers/mobile-app-state-provider.tsx
const MobileAppStateContext = createContext<MobileAppStateContextValue | null>(null);
export function useMobileAppState() {
  const ctx = useContext(MobileAppStateContext);
  if (!ctx) throw new Error('MobileAppStateProvider missing');
  return ctx;
}
```

### 2. Typography / 색상 (AppText + fortuneTheme)
모든 텍스트는 `AppText` 컴포넌트를 통해 렌더링하고, 색상은 `fortuneTheme.colors.*`를 씁니다.
```tsx
// ✅ AppText + variant | ❌ <Text style={{ fontSize: 18, color: '#fff' }}> 금지
import { AppText } from '@/components/app-text';
import { fortuneTheme } from '@/lib/theme';

<AppText variant="headlineMedium" color={fortuneTheme.colors.textPrimary}>
  제목
</AppText>
```

### 3. Edge Function (LLMFactory)
Supabase Edge Function에서 LLM 호출은 반드시 `LLMFactory`를 경유합니다.
```typescript
// ✅ LLMFactory | ❌ OpenAI/Gemini 직접 호출 금지
const llm = LLMFactory.createFromConfig('fortune-type')
const result = await llm.generate({ prompt, maxTokens: 2000 })
```

### 4. 채팅 상태 (chat-shell discriminated union)
채팅 메시지는 `apps/mobile-rn/src/lib/chat-shell.ts`의 `ChatShellMessage` 유니언 타입으로만 추가합니다. 새 카드 종류는 `kind` 리터럴을 추가하고 `chat-surface.tsx`에서 분기 렌더.
```ts
// ✅ discriminated union 확장 | ❌ ad-hoc message shape 금지
export type ChatShellMessage =
  | ChatShellTextMessage
  | ChatShellEmbeddedResultMessage
  | ChatShellFortuneCookieMessage
  | ChatShellSajuPreviewMessage
  | ChatShellImageMessage;
```

### 5. 결과 카드 레지스트리 (fortune-results/registry)
새 운세 결과 화면은 `apps/mobile-rn/src/features/fortune-results/registry.tsx`에 등록하고, 채팅 임베드용 매핑은 `mapping.ts`에서 `resolveResultKindFromFortuneType`로 연결합니다. 화면은 `screens/*.tsx`에 추가.

---

## 네비게이션 구조 (Chat-First)

| 탭 | 경로 | 역할 |
|----|------|------|
| Home | `/chat` | 통합 채팅 진입점 |
| 인사이트 alias | `/home` | 레거시 별칭, 현재는 `/chat`으로 redirect |
| 탐구 | `/fortune` | 인사이트 카테고리 + Face AI |
| 트렌드 | `/trend` | 트렌드 콘텐츠 |
| 프로필 | `/profile` | 설정 + Premium |

라우팅은 `expo-router` 기반 (`apps/mobile-rn/app/(tabs)/`).

---

## 문서 계층

| Tier | 문서 | 로드 조건 |
|------|------|----------|
| **1 (항상)** | 이 파일 (CLAUDE.md) | 모든 요청 |
| **2 (키워드)** | 01-03, 05-06, 18 | 개발 관련 키워드 시 |
| **3 (요청)** | 07-26 | 명시적 요청 시만 |

### 문서 참조
| 문서 | 트리거 키워드 |
|------|-------------|
| [01-core-rules](.claude/docs/01-core-rules.md) | 에러, 버그, 금지, 규칙 |
| [02-architecture](.claude/docs/02-architecture.md) | 아키텍처, Feature, 레이어 |
| [03-ui-design-system](.claude/docs/03-ui-design-system.md) | UI, 색상, 폰트, 다크모드 |
| [05-fortune-system](.claude/docs/05-fortune-system.md) | 인사이트, Fortune, 토큰 |
| [06-llm-module](.claude/docs/06-llm-module.md) | Edge Function, LLM, API |
| [18-chat-first-architecture](.claude/docs/18-chat-first-architecture.md) | 채팅, chat, 대화, 추천 칩, Home |
| [24-page-layout-reference](.claude/docs/24-page-layout-reference.md) | 페이지, 레이아웃, 라우팅, 화면 |
| [25-fortune-result-schemas](.claude/docs/25-fortune-result-schemas.md) | 스키마, 결과, 응답, JSON, 필드 |
| [26-widget-component-catalog](.claude/docs/26-widget-component-catalog.md) | 위젯, 컴포넌트, 카드, 서베이 |

---

## MCP 서버 (우선순위)

| 순위 | MCP | 역할 |
|------|-----|------|
| 1 | Supabase | Edge Function, DB |
| 2 | iOS Simulator / Playwright | E2E 자동 QA |
| 3 | Context7 | React Native / Expo / expo-router 문서 |
| 4 | Sequential | 복잡한 분석 |
| 5 | JIRA | 티켓 관리 |
| 6 | Pencil | 공식 디자인 툴 (.pen 파일) |
| 7+ | Figma, GitHub, Brave | 선택적 |

---

## 자동 QA

UI/페이지 수정 완료 시 자동으로 QA 제안:
```
"수정 완료! iOS 시뮬레이터에서 QA 테스트할까요?"
```
주요 경로: iOS Simulator MCP (`mcp__ios-simulator__*`) 또는 Expo Dev Client.

---

## 프로젝트 구조

```
apps/mobile-rn/                        # Expo SDK 54 / RN 0.81 / TypeScript
  app/(tabs)/                          # expo-router 라우트 (chat/fortune/trend/profile)
  src/components/                      # 공용 컴포넌트 (app-text, screen, chip, ...)
  src/features/
    chat-surface/                      # 통합 채팅 화면 조립
    chat-survey/                       # 인라인 서베이/위젯 (tarot-draw 등)
    chat-results/                      # 임베디드 결과 카드 어댑터
    fortune-results/                   # 결과 화면 레지스트리 + screens/*
    fortune-cookie/                    # 포춘쿠키 / 사주 프리뷰 카드
  src/providers/                       # React Context providers
                                       # (mobile-app-state, social-auth, friend-creation, app-bootstrap)
  src/lib/                             # 도메인 로직 (chat-shell, theme, supabase, ...)

packages/
  product-contracts/                   # FortuneTypeId, ProductId 등 TS 컨트랙트
  design-tokens/                       # fortuneTheme 소스 (createFortuneTheme)

supabase/functions/                    # Edge Functions (Deno, LLMFactory)
artifacts/sprint/                      # Generator-Evaluator 통신 디렉토리
.claude/agents/                        # generator / evaluator / playwright-qa
.claude/skills/                        # backend-service + /sc:* 코어 스킬
.claude/docs/                          # 상세 문서 (01-26) + 참조 자료
```

---

## Skill 사용법

### /sc:sprint (Planner 오케스트레이터)
Generator-Evaluator 패턴 스프린트. Contract → Generate → Evaluate → Ship
```
/sc:sprint 펫궁합 결과 화면 추가
/sc:sprint 타로 결과 로딩 버그 수정
/sc:sprint 홈 채팅 리디자인
```

### /sc:quick-fix (경량 워크플로우)
1-2 파일 단순 수정. Generator-Evaluator 세레모니 생략.
```
/sc:quick-fix 버튼 색상 변경
/sc:quick-fix 오타 수정
```

### 스킬 목록

| Skill | 역할 | 호출 방식 |
|-------|------|----------|
| `/sc:sprint` | Planner 오케스트레이터 (Contract → Generate → Evaluate → Ship) | 직접 |
| `/sc:generate` | Generator subagent 실행 | sprint에서 자동 / 직접 가능 |
| `/sc:evaluate` | Evaluator subagent 실행 | sprint에서 자동 / 직접 가능 |
| `/sc:quick-fix` | 1-2 파일 단순 수정 | 직접 |
| `backend-service` | Edge Function 전용 생성/수정 (RN 변경 없이 Supabase만 건드릴 때) | 직접 |

### Artifact 통신 (`artifacts/sprint/`)

| 파일 | 작성자 → 독자 | 목적 |
|------|--------------|------|
| contract.md | Planner → Generator, Evaluator | 스코프, 수용 기준, 루브릭 |
| discovery-report.md | Generator → Evaluator | 기존 코드 탐색 결과 |
| rca-report.md | Generator → Evaluator | 근본 원인 분석 |
| build-log.md | Generator → Evaluator | 변경 파일, 결정 사항 |
| eval-report.md | Evaluator → Planner | PASS/FAIL 판정 + 증거 |
