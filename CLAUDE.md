# Fortune Flutter App - Claude Code 가이드

> 최종 업데이트: 2025.01.03

## 자동 라우팅 (NEW)

사용자 요청을 분석하여 자동으로 적절한 Skill과 Agent를 활성화합니다.

| 요청 패턴 | Skill | Agent | MCP |
|-----------|-------|-------|-----|
| 운세/궁합/타로/사주 추가 | `/sc:feature-fortune` | fortune-specialist | Supabase |
| 채팅/추천 칩/메시지 | `/sc:feature-chat` | - | - |
| UI/디자인/색상/레이아웃 | `/sc:feature-ui` | - | Playwright (QA) |
| Edge Function/API | `/sc:backend-service` | - | Supabase |
| 에러/버그/안됨/수정 | `/sc:troubleshoot` | - | Sequential |
| 검증/품질/QA | `/sc:quality-check` | quality-guardian | - |

### Agent 협업
- **feature-orchestrator**: 모든 요청의 진입점, 자동 라우팅
- **fortune-specialist**: 인사이트 도메인 결정 (토큰, 입력 필드)
- **quality-guardian**: 모든 코드 생성 후 품질 검증

**우선순위**: 사용자 명시적 요청 > 프로젝트 규칙 > 글로벌 SuperClaude

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
| 하드코딩 색상/폰트 | 디자인 시스템 위반 | DSColors, context.heading1 |

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

### Block 흐름도

```
사용자 요청
    │
    ├─ 에러/버그 키워드?
    │   └─ ⛔ Block 1: RCA 보고서 필수
    │       └─ 📋 JIRA Bug 이슈 자동 생성
    │       └─ 해제 후 → Block 3으로
    │
    ├─ 코드 생성/추가?
    │   └─ ⛔ Block 2: Discovery 보고서 필수
    │       └─ 📋 JIRA Story/Task 이슈 자동 생성
    │       └─ 해제 후 → Block 3으로
    │
    └─ 수정 완료?
        └─ ⛔ Block 3: Verify 보고서 필수
            └─ 사용자 확인 후 → JIRA 이슈 Done 전환
            └─ 완료 선언 가능
```

### JIRA 연동 (자동)

**모든 Hard Block 작업은 JIRA에 기록됩니다:**

| 단계 | JIRA 액션 |
|------|----------|
| Block 1 (RCA) 시작 | Bug 이슈 생성, RCA 보고서 첨부 |
| Block 2 (Discovery) 시작 | Story/Task 이슈 생성, Discovery 보고서 첨부 |
| Block 3 (Verify) 완료 | 이슈 상태 → Done, Verify 보고서 코멘트 |

---

## 핵심 패턴 (5가지)

### 1. StateNotifier (Riverpod)
```dart
// ✅ StateNotifier 패턴 | ❌ @riverpod 금지
class FortuneNotifier extends StateNotifier<FortuneState> { }
```

### 2. Typography
```dart
// ✅ context.heading1 | ❌ 하드코딩 TextStyle 금지
Text('제목', style: context.heading1)
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
| 인사이트 | `/home` | 일일 인사이트 대시보드 |
| 탐구 | `/fortune` | 인사이트 카테고리 + Face AI |
| 트렌드 | `/trend` | 트렌드 콘텐츠 |
| 프로필 | `/profile` | 설정 + Premium |

---

## 문서 계층

| Tier | 문서 | 로드 조건 |
|------|------|----------|
| **1 (항상)** | 이 파일 (CLAUDE.md) | 모든 요청 |
| **2 (키워드)** | 01-06, 18 | 개발 관련 키워드 시 |
| **3 (요청)** | 07-21 | 명시적 요청 시만 |

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
lib/features/chat/        # 채팅 진입점 (Chat-First)
lib/features/fortune/     # 인사이트 기능 (Clean Architecture)
supabase/functions/       # Edge Functions (LLMFactory)
.claude/agents/           # 3개 Agent (feature-orchestrator, fortune-specialist, quality-guardian)
.claude/skills/           # 6개 Skill (feature-fortune, feature-chat, feature-ui, backend-service, troubleshoot, quality-check)
.claude/docs/             # 상세 문서 (01-21)
```

---

## Skill 사용법

### /sc:feature-fortune
새 인사이트 기능 전체 생성 (Edge Function + 모델 + 서비스 + 페이지 + 라우트)
```
/sc:feature-fortune 펫궁합
```

### /sc:feature-chat
채팅 기능 추가/수정 (추천 칩, 메시지 변환기)
```
/sc:feature-chat 추천 칩에 펫궁합 추가
```

### /sc:feature-ui
UI만 변경 (Presentation 레이어만)
```
/sc:feature-ui 일일 인사이트 결과 카드 리디자인
```

### /sc:backend-service
Edge Function만 생성/수정
```
/sc:backend-service 건강분석 API
```

### /sc:troubleshoot
버그 분석 + 근본 원인 + 일괄 수정
```
/sc:troubleshoot 타로 결과가 안보임
```

### /sc:quality-check
품질 검증 (아키텍처, 디자인 시스템, 앱스토어 규정)
```
/sc:quality-check
```
