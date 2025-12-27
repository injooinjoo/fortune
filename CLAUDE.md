# Fortune Flutter App - Claude Code 가이드

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
- **fortune-specialist**: 운세 도메인 결정 (토큰, 블러, 입력 필드)
- **quality-guardian**: 모든 코드 생성 후 품질 검증

**우선순위**: 사용자 명시적 요청 > 프로젝트 규칙 > 글로벌 SuperClaude

---

## 절대 금지 (CRITICAL)

| 금지 | 이유 | 대안 |
|------|------|------|
| `flutter run` 직접 실행 | 로그 확인 불가 | 사용자에게 실행 요청 |
| 일괄 수정 (for, sed -i) | 프로젝트 망가짐 | 한 파일씩 Edit |
| @riverpod 어노테이션 | 프로젝트 패턴 위반 | StateNotifier 사용 |
| 하드코딩 색상/폰트 | 디자인 시스템 위반 | TossDesignSystem, context.heading1 |

---

## 핵심 패턴 (6가지)

### 1. StateNotifier (Riverpod)
```dart
// ✅ StateNotifier 패턴 | ❌ @riverpod 금지
class FortuneNotifier extends StateNotifier<FortuneState> { }
```

### 2. Typography
```dart
// ✅ context.heading1 | ❌ TossDesignSystem.heading1 금지
Text('제목', style: context.heading1)
```

### 3. 블러 처리
```dart
// ✅ UnifiedBlurWrapper | ❌ ImageFilter.blur 금지
UnifiedBlurWrapper(isBlurred: result.isBlurred, child: content)
```

### 4. Edge Function
```typescript
// ✅ LLMFactory | ❌ OpenAI/Gemini 직접 호출 금지
const llm = LLMFactory.createFromConfig('fortune-type')
```

### 5. 채팅 상태 (Chat-First)
```dart
// ✅ ChatMessagesNotifier | ❌ 직접 setState 금지
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  void addMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }
}
```

### 6. 추천 칩
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
| 인사이트 | `/home` | 일일 운세 대시보드 |
| 탐구 | `/fortune` | 운세 카테고리 + Face AI |
| 트렌드 | `/trend` | 트렌드 콘텐츠 |
| 프로필 | `/profile` | 설정 + Premium |

---

## 문서 계층

| Tier | 문서 | 로드 조건 |
|------|------|----------|
| **1 (항상)** | 이 파일 (CLAUDE.md) | 모든 요청 |
| **2 (키워드)** | 01-06, 18 | 개발 관련 키워드 시 |
| **3 (요청)** | 07-17 | 명시적 요청 시만 |

### 문서 참조
| 문서 | 트리거 키워드 |
|------|-------------|
| [01-core-rules](.claude/docs/01-core-rules.md) | 에러, 버그, 금지, 규칙 |
| [02-architecture](.claude/docs/02-architecture.md) | 아키텍처, Feature, 레이어 |
| [03-ui-design-system](.claude/docs/03-ui-design-system.md) | UI, 색상, 폰트, 다크모드 |
| [04-state-management](.claude/docs/04-state-management.md) | Provider, 상태, State |
| [05-fortune-system](.claude/docs/05-fortune-system.md) | 운세, Fortune, 토큰 |
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
lib/features/fortune/     # 운세 기능 (Clean Architecture)
supabase/functions/       # Edge Functions (LLMFactory)
.claude/agents/           # 3개 Agent (feature-orchestrator, fortune-specialist, quality-guardian)
.claude/skills/           # 6개 Skill (feature-fortune, feature-chat, feature-ui, backend-service, troubleshoot, quality-check)
.claude/docs/             # 상세 문서 (01-18)
```

---

## Skill 사용법

### /sc:feature-fortune
새 운세 기능 전체 생성 (Edge Function + 모델 + 서비스 + 페이지 + 라우트)
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
/sc:feature-ui 일일운세 결과 카드 리디자인
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
