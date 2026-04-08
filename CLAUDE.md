# Ondo Flutter App - Claude Code 가이드

> 최종 업데이트: 2026.04.06

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
    ├─ flutter analyze + 규칙 검증
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
| `/sc:quality-check` | 품질 검증만 |

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
| `flutter run` 직접 실행 | 로그 확인 불가 | 사용자에게 실행 요청 |
| 일괄 수정 (for, sed -i) | 프로젝트 망가짐 | 한 파일씩 Edit |
| @riverpod 어노테이션 | 프로젝트 패턴 위반 | StateNotifier 사용 |
| 하드코딩 색상/폰트 | 디자인 시스템 위반 | DSColors, context.typography.* |

---

## HARD BLOCK 시스템 (CRITICAL)

**조건 미충족 시 작업 자체를 차단합니다. 이 규칙은 어떤 상황에서도 무시할 수 없습니다.**

### Block 1: RCA 필수 (Root Cause Analysis)

| 트리거 | 에러, 버그, 안됨, 수정, 깨짐, 작동안함 키워드 |
|--------|---------------------------------------------|
| 차단 | RCA 보고서 없이 코드 수정 시도 시 |
| 해제 | WHY + WHERE ELSE + HOW 분석 완료 |

**금지 패턴** (이런 코드 작성 시 즉시 차단):
```dart
// ❌ 빈 catch 블록
catch (e) { }
catch (e) { print(e); }

// ❌ 원인 분석 없이 null 체크만
if (value != null) { ... }
```

**필수 출력 (RCA 보고서)**:
```
🔍 RCA 보고서
├─ 증상: [에러 메시지]
├─ WHY: 왜 발생? → [원인]
├─ WHERE: 어디서? → [파일:라인]
├─ WHERE ELSE: grep 결과 → [동일 패턴 N개 발견]
├─ HOW: 올바른 패턴 → [참조 파일:라인]
└─ 수정 계획: [N개 파일 수정 예정]
```

### Block 2: Discovery 필수 (기존 코드 탐색)

| 트리거 | 모든 코드 생성/추가 작업 |
|--------|------------------------|
| 차단 | 기존 코드 탐색 없이 새 코드 작성 시도 시 |
| 해제 | 유사 코드 검색 + 재사용 결정 완료 |

**필수 검색** (새 코드 작성 전):
```bash
# StateNotifier 생성 시
grep -rn "extends StateNotifier" lib/

# 위젯 생성 시
find lib -name "*widget*.dart"

# 서비스 생성 시
grep -rn "class.*Service" lib/
```

**필수 출력 (Discovery 보고서)**:
```
📂 Discovery 보고서
├─ 목표: [무엇을 만들 것인지]
├─ 검색 결과: [N개 유사 파일 발견]
│   ├─ [파일1.dart] - 재사용 가능 ✅
│   ├─ [파일2.dart] - 패턴 참조
│   └─ [파일3.dart] - 참고만
├─ 재사용 결정:
│   ├─ 재사용: [함수명] from [파일]
│   ├─ 참조: [패턴] from [파일]
│   └─ 새로 작성: [꼭 필요한 부분만]
└─ 중복 방지: [기존 X가 있으므로 새로 만들지 않음]
```

### Block 3: Verify 필수 (검증)

| 트리거 | 모든 수정 작업 완료 시 |
|--------|----------------------|
| 차단 | 검증 미통과 시 "완료" 선언 불가 |
| 해제 | flutter analyze 통과 + 사용자 테스트 확인 |

**필수 검증 순서**:
```bash
1. flutter analyze          # 에러 0 필수
2. dart run build_runner build  # freezed 사용 시
3. dart format .            # 포맷 확인
```

**필수 출력 (Verify 보고서)**:
```
✅ 검증 보고서
├─ flutter analyze: ✅ 0 errors
├─ build_runner: ✅ 성공 (또는 N/A)
├─ dart format: ✅ 통과
├─ 수정된 파일:
│   ├─ [파일1.dart]
│   └─ [파일2.dart]
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
    ├─ flutter analyze 실행
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

### 1. StateNotifier (Riverpod)
```dart
// ✅ StateNotifier 패턴 | ❌ @riverpod 금지
class FortuneNotifier extends StateNotifier<FortuneState> { }
```

### 2. Typography
```dart
// ✅ context.typography.headlineMedium | ❌ 하드코딩 TextStyle 금지
Text('제목', style: context.typography.headlineMedium)
```

### 3. Edge Function
```typescript
// ✅ LLMFactory | ❌ OpenAI/Gemini 직접 호출 금지
const llm = LLMFactory.createFromConfig('fortune-type')
```

### 4. 채팅 상태 (Chat-First)
```dart
// ✅ ChatMessagesNotifier | ❌ 직접 setState 금지
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  void addMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }
}
```

### 5. 추천 칩
```dart
// ✅ FortuneChipGrid | ❌ 하드코딩 칩 금지
FortuneChipGrid(
  chips: dynamicChips,
  onChipTap: (chip) => _handleChipTap(chip),
)
```

---

## 네비게이션 구조 (Chat-First)

| 탭 | 경로 | 역할 |
|----|------|------|
| Home | `/chat` | 통합 채팅 진입점 |
| 인사이트 alias | `/home` | 레거시 별칭, 현재는 `/chat`으로 redirect |
| 탐구 | `/fortune` | 인사이트 카테고리 + Face AI |
| 트렌드 | `/trend` | 트렌드 콘텐츠 |
| 프로필 | `/profile` | 설정 + Premium |

---

## 문서 계층

| Tier | 문서 | 로드 조건 |
|------|------|----------|
| **1 (항상)** | 이 파일 (CLAUDE.md) | 모든 요청 |
| **2 (키워드)** | 01-06, 18 | 개발 관련 키워드 시 |
| **3 (요청)** | 07-26 | 명시적 요청 시만 |

### 문서 참조
| 문서 | 트리거 키워드 |
|------|-------------|
| [01-core-rules](.claude/docs/01-core-rules.md) | 에러, 버그, 금지, 규칙 |
| [02-architecture](.claude/docs/02-architecture.md) | 아키텍처, Feature, 레이어 |
| [03-ui-design-system](.claude/docs/03-ui-design-system.md) | UI, 색상, 폰트, 다크모드 |
| [04-state-management](.claude/docs/04-state-management.md) | Provider, 상태, State |
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
| 2 | Playwright | E2E 자동 QA |
| 3 | Context7 | Flutter/Riverpod 문서 |
| 4 | Sequential | 복잡한 분석 |
| 5 | JIRA | 티켓 관리 |
| 6+ | Figma, GitHub, Brave | 선택적 |

---

## 자동 QA

UI/페이지 수정 완료 시 자동으로 QA 제안:
```
"수정 완료! QA 테스트할까요?" (localhost:3000 실행 중이면)
```

---

## 프로젝트 구조

```
lib/features/character/   # /chat, /character, /friends/new surface 조립층
lib/features/chat/        # 채팅 카드/설문/메시지 보조 레이어
lib/features/fortune/     # 카테고리/도메인 모델/인사이트 보조 레이어
supabase/functions/       # Edge Functions (LLMFactory)
artifacts/sprint/         # Generator-Evaluator 통신 디렉토리
.claude/agents/           # active agents 5개 (generator/evaluator/playwright-qa/character-curator/character-importer)
.claude/skills/           # core 4 + template 4 + utility 5
.claude/docs/             # 상세 문서 (01-26) + supporting refs (fortune-specialist-reference, paper-artboard-map 등)
```

---

## Skill 사용법

### /sc:sprint (Planner 오케스트레이터)
Generator-Evaluator 패턴 스프린트. Contract → Generate → Evaluate → Ship
```
/sc:sprint 펫궁합 기능 추가
/sc:sprint 타로 결과 로딩 버그 수정
/sc:sprint 홈 화면 리디자인
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
| `/sc:quality-check` | 품질 검증 (Evaluator 참조용 규칙) | 직접 |

### 템플릿 스킬 (Generator가 참조)

| Skill | 용도 |
|-------|------|
| `feature-fortune/` | 운세 기능 템플릿 |
| `feature-chat/` | 채팅 기능 템플릿 |
| `feature-ui/` | UI 변경 가이드 |
| `backend-service/` | Edge Function 템플릿 |

### Artifact 통신 (`artifacts/sprint/`)

| 파일 | 작성자 → 독자 | 목적 |
|------|--------------|------|
| contract.md | Planner → Generator, Evaluator | 스코프, 수용 기준, 루브릭 |
| discovery-report.md | Generator → Evaluator | 기존 코드 탐색 결과 |
| rca-report.md | Generator → Evaluator | 근본 원인 분석 |
| build-log.md | Generator → Evaluator | 변경 파일, 결정 사항 |
| eval-report.md | Evaluator → Planner | PASS/FAIL 판정 + 증거 |
