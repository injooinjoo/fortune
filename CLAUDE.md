# Fortune Flutter App - Claude Code 가이드

## 통합 매핑 테이블 (핵심)

모든 요청은 이 테이블을 기준으로 MCP, Agent, Skill, 문서를 자동 활성화합니다.

| 작업 | MCP | Agent | Skill | 문서 |
|------|-----|-------|-------|------|
| UI/페이지 수정 | Playwright | toss-design-guardian | - | 03 |
| 운세 기능 개발 | Supabase | fortune-domain-expert | /sc:fortune-page | 05 |
| 모델 생성 | - | freezed-generator | /sc:freezed-model | 02 |
| Provider 작성 | Context7 | riverpod-specialist | /sc:state-notifier | 04 |
| Edge Function | Supabase | fortune-domain-expert | /sc:edge-function | 06 |
| 버그/에러 분석 | Sequential | error-resolver | /sc:analyze-error | 01 |
| 테스트 작성 | Playwright | testing-architect | /sc:generate-test | - |
| 아키텍처 검토 | Sequential | flutter-architect | /sc:validate-arch | 02 |
| E2E QA | Playwright | playwright-qa-agent | /sc:auto-qa | 13 |
| JIRA 작업 | JIRA | - | - | 07 |
| Figma 연동 | Figma | toss-design-guardian | - | 03 |

**우선순위**: 사용자 명시적 요청 > 프로젝트 규칙 > 글로벌 SuperClaude

---

## 절대 금지 (CRITICAL)

| 금지 | 이유 | 대안 |
|------|------|------|
| `flutter run` 직접 실행 | 로그 확인 불가 | 사용자에게 실행 요청 |
| 일괄 수정 (for, sed -i) | 프로젝트 망가짐 | 한 파일씩 Edit |
| JIRA 없이 작업 | 추적 불가 | `./scripts/parse_ux_request.sh` 먼저 |

---

## 핵심 패턴 (4가지)

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

---

## 문서 계층

| Tier | 문서 | 로드 조건 |
|------|------|----------|
| **1 (항상)** | 이 파일 (CLAUDE.md) | 모든 요청 |
| **2 (키워드)** | 01-06 | 개발 관련 키워드 시 |
| **3 (요청)** | 07-16 (13: 자동QA, 14: API최적화, 15: 사주용어, 16: 타이포) | 명시적 요청 시만 |

### 문서 참조
| 문서 | 트리거 키워드 |
|------|-------------|
| [01-core-rules](.claude/docs/01-core-rules.md) | 에러, 버그, 금지, 규칙 |
| [02-architecture](.claude/docs/02-architecture.md) | 아키텍처, Feature, 레이어 |
| [03-ui-design-system](.claude/docs/03-ui-design-system.md) | UI, 색상, 폰트, 다크모드 |
| [04-state-management](.claude/docs/04-state-management.md) | Provider, 상태, State |
| [05-fortune-system](.claude/docs/05-fortune-system.md) | 운세, Fortune, 토큰 |
| [06-llm-module](.claude/docs/06-llm-module.md) | Edge Function, LLM, API |

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

## 자동 QA (페이지 수정 후)

페이지 수정 완료 시 자동으로 QA 제안:
```
"수정 완료! QA 테스트할까요?" (localhost:3000 실행 중이면)
```

상세: [13-auto-qa-system.md](.claude/docs/13-auto-qa-system.md)

---

## 프로젝트 구조

```
lib/features/fortune/     # 운세 기능 (Clean Architecture)
supabase/functions/       # Edge Functions (LLMFactory)
.claude/agents/           # 8개 Agent
.claude/commands/         # 13개 Skill (/sc:*)
.claude/docs/             # 상세 문서 (01-16)
```

---

## 상세 참조

- Agent/Skill 상세: [08-agents-skills.md](.claude/docs/08-agents-skills.md)
- 전체 문서 색인: [docs/README.md](docs/README.md)
