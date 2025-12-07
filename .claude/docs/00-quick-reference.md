# Quick Reference - Fortune 개발 가이드

## 자동 활성화 매핑 (한눈에 보기)

| 작업 | MCP | Agent | Skill | 문서 |
|------|-----|-------|-------|------|
| UI/페이지 수정 | Playwright | toss-design-guardian | - | 03 |
| 운세 기능 개발 | Supabase | fortune-domain-expert | /sc:fortune-page | 05 |
| 모델 생성 | - | freezed-generator | /sc:freezed-model | 02 |
| Provider 작성 | Context7 | riverpod-specialist | /sc:state-notifier | 04 |
| Edge Function | Supabase | fortune-domain-expert | /sc:edge-function | 06 |
| 에러 분석 | Sequential | error-resolver | /sc:analyze-error | 01 |
| 테스트 | Playwright | testing-architect | /sc:generate-test | - |
| 아키텍처 | Sequential | flutter-architect | /sc:validate-arch | 02 |
| E2E QA | Playwright | playwright-qa-agent | /sc:auto-qa | 16 |

---

## 절대 금지 (CRITICAL)

```bash
# 1. Flutter 직접 실행 금지
flutter run  # WRONG

# 2. 일괄 수정 금지
for file in files: ...  # WRONG
sed -i ...              # WRONG

# 3. JIRA 없이 작업 금지
# 바로 코드 시작 (WRONG) → ./scripts/parse_ux_request.sh 먼저!
```

---

## 핵심 패턴 4가지

### 1. Riverpod (StateNotifier)
```dart
// CORRECT
class FortuneNotifier extends StateNotifier<FortuneState> {
  FortuneNotifier() : super(const FortuneState());
}

// WRONG - @riverpod 금지!
@riverpod
class FortuneNotifier extends _$FortuneNotifier { }
```

### 2. 폰트 (TypographyUnified)
```dart
// CORRECT
Text('제목', style: context.heading1)

// WRONG - TossDesignSystem 폰트 금지!
Text('제목', style: TossDesignSystem.heading1)
```

### 3. 다크모드 대응
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark
  ? TossDesignSystem.textPrimaryDark
  : TossDesignSystem.textPrimaryLight
```

### 4. LLM 호출 (Edge Function)
```typescript
// CORRECT
const llm = LLMFactory.createFromConfig('fortune-type')
const response = await llm.generate(messages, { jsonMode: true })

// WRONG - 직접 API 호출 금지!
fetch('https://api.openai.com/...')
```

---

## MCP 우선순위

| 순위 | MCP | 역할 |
|------|-----|------|
| 1 | **Supabase** | Edge Function, DB, 마이그레이션 |
| 2 | **Playwright** | E2E 자동 QA, 브라우저 테스트 |
| 3 | **Context7** | Flutter/Riverpod 공식 문서 |
| 4 | **Sequential** | 복잡한 버그 분석, 아키텍처 |
| 5 | **JIRA** | 티켓 생성/관리 |
| 6 | **Figma** | 디자인 토큰 연동 |
| 7 | **GitHub** | PR 자동화 |

---

## 문서 계층

| Tier | 문서 | 로드 시점 |
|------|------|----------|
| **1** | CLAUDE.md | 항상 |
| **2** | 01~06 | 개발 키워드 시 |
| **3** | 07~16 | 명시적 요청 시 |

---

## 빠른 명령어

| 작업 | 명령어/커맨드 |
|------|--------------|
| Freezed 모델 | `/sc:freezed-model` |
| StateNotifier | `/sc:state-notifier` |
| 운세 페이지 | `/sc:fortune-page` |
| Edge Function | `/sc:edge-function` |
| 아키텍처 검증 | `/sc:validate-arch` |
| 테스트 생성 | `/sc:generate-test` |
| 에러 분석 | `/sc:analyze-error` |
| 자동 QA | `/sc:auto-qa` |

---

## 프로젝트 구조

```
lib/
├── core/           # 공유 인프라
├── features/       # Feature Slice 모듈
│   └── fortune/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── routes/         # GoRouter
└── main.dart

supabase/functions/
├── _shared/        # LLMFactory, PromptManager
└── fortune-*/      # 운세별 Edge Function
```

---

## 상세 문서 링크

- 01: 핵심 규칙 (근본원인 분석)
- 02: Clean Architecture
- 03: TossDesignSystem
- 04: Riverpod StateNotifier
- 05: 운세 시스템 (6단계)
- 06: LLM 모듈
- 07: JIRA 워크플로우
- 08: Agents & Skills
- 16: 자동 QA 시스템
