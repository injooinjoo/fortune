# Fortune Flutter App - Claude Code 개발 가이드

## 🧠 자동 활성화 시스템 (CRITICAL - 모든 요청에 적용)

**모든 사용자 요청을 분석하여 적절한 Agent 페르소나를 채택하고, 필요한 Skill을 자동 실행합니다.**

### Agent 자동 활성화 규칙

사용자 요청을 분석하여 해당 Agent의 전문성과 원칙을 적용합니다:

| 트리거 키워드 | 활성화 Agent | 적용 내용 |
|--------------|-------------|----------|
| "아키텍처", "구조", "레이어", "Feature 추가" | `flutter-architect` | Clean Architecture 원칙, 레이어 분리, 의존성 규칙 |
| "Provider", "상태", "State", "Notifier" | `riverpod-specialist` | StateNotifier 패턴, @riverpod 금지, copyWith |
| "모델", "Freezed", "DTO", "Entity" | `freezed-generator` | @freezed 패턴, @JsonKey, @Default |
| "UI", "위젯", "화면", "디자인", "색상", "폰트" | `toss-design-guardian` | TossDesignSystem, TypographyUnified, 다크모드 |
| "운세", "Fortune", "블러", "프리미엄", "토큰" | `fortune-domain-expert` | 6단계 프로세스, UnifiedFortuneService, 블러 시스템 |
| "테스트", "Test", "검증", "커버리지" | `testing-architect` | Widget/Provider 테스트 패턴, Mock |
| "에러", "버그", "오류", "안돼", "크래시" | `error-resolver` | 근본원인 분석, 전체 검색, 패턴 적용 |
| "위젯", "Widget", "홈화면", "즐겨찾기 위젯" | `widget-specialist` | iOS WidgetKit, Android AppWidget, home_widget, App Group |

**복합 요청 시**: 여러 Agent의 전문성을 조합하여 적용

### Skill 자동 실행 규칙

사용자 요청에 따라 해당 Skill의 템플릿과 체크리스트를 자동 적용합니다:

| 트리거 패턴 | 자동 실행 Skill | 동작 |
|------------|----------------|------|
| "모델 만들어", "DTO 생성", "Entity 추가" | `/sc:freezed-model` | Freezed 모델 템플릿 생성, build_runner 안내 |
| "Provider 만들어", "상태관리 추가", "Notifier 생성" | `/sc:state-notifier` | StateNotifier + State 클래스 템플릿 생성 |
| "운세 페이지 만들어", "Fortune 화면 추가" | `/sc:fortune-page` | 운세 페이지 표준 템플릿 (블러, 프리미엄 포함) |
| "Edge Function 만들어", "API 함수 추가" | `/sc:edge-function` | LLMFactory 기반 Edge Function 템플릿 |
| "아키텍처 검사", "구조 확인", "규칙 검증" | `/sc:validate-arch` | 레이어 의존성, 금지 패턴 검사 |
| "테스트 만들어", "테스트 코드 생성" | `/sc:generate-test` | Widget/Provider 테스트 템플릿 |
| "품질 검사", "커밋 전 확인", "빌드 검증" | `/sc:quality-gate` | analyze + format + test + arch 검증 |
| "에러 분석", "버그 원인", "왜 안돼" | `/sc:analyze-error` | 근본원인 분석 프로세스 실행 |
| "위젯 만들어", "컴포넌트 추가", "UI 생성" | `/sc:toss-widget` | Toss 스타일 위젯 템플릿 |
| "라우트 추가", "페이지 연결", "네비게이션" | `/sc:go-route` | GoRouter 라우트 추가 |

### 자동 활성화 프로세스

```
사용자 요청 수신
    ↓
1️⃣ 키워드 분석 → Agent 페르소나 채택
    ↓
2️⃣ 작업 유형 판단 → Skill 템플릿 적용
    ↓
3️⃣ 관련 docs/ 문서 참조 → 상세 규칙 확인
    ↓
4️⃣ 작업 실행 (Agent 원칙 + Skill 템플릿 준수)
    ↓
5️⃣ 체크리스트 검증 → 완료
```

### 예시

**사용자**: "유저 프로필 모델 만들어줘"
```
→ Agent: freezed-generator 활성화
→ Skill: /sc:freezed-model 실행
→ 참조: 02-architecture.md (Domain 모델 위치)
→ 출력: @freezed UserProfile 모델 + build_runner 명령어
```

**사용자**: "일일운세 페이지에서 에러나"
```
→ Agent: error-resolver + fortune-domain-expert 활성화
→ Skill: /sc:analyze-error 실행
→ 참조: 01-core-rules.md (근본원인 분석), 05-fortune-system.md
→ 출력: 에러 원인 분석 + 동일 패턴 검색 + 수정 방안
```

---

## 📚 문서 구조

모든 상세 규칙은 `.claude/docs/` 폴더에서 관리됩니다.

| 문서 | 내용 | 핵심 키워드 |
|------|------|-------------|
| [01-core-rules.md](.claude/docs/01-core-rules.md) | 핵심 개발 규칙 | Flutter 실행 금지, 일괄수정 금지, 근본원인 분석 |
| [02-architecture.md](.claude/docs/02-architecture.md) | Clean Architecture | Feature Slice, 레이어 규칙, 의존성 |
| [03-ui-design-system.md](.claude/docs/03-ui-design-system.md) | UI 디자인 시스템 | TossDesignSystem, TypographyUnified, 다크모드 |
| [04-state-management.md](.claude/docs/04-state-management.md) | 상태관리 | StateNotifier, Riverpod, copyWith |
| [05-fortune-system.md](.claude/docs/05-fortune-system.md) | 운세 시스템 | 6단계 프로세스, 블러, 프리미엄 |
| [06-llm-module.md](.claude/docs/06-llm-module.md) | LLM 모듈 | LLMFactory, PromptManager, Edge Function |
| [07-jira-workflow.md](.claude/docs/07-jira-workflow.md) | JIRA 워크플로우 | 티켓 생성, Git 커밋 |
| [08-agents-skills.md](.claude/docs/08-agents-skills.md) | Agents & Skills | 7 Agents, 10 Skills |
| [10-widget-system.md](.claude/docs/10-widget-system.md) | 홈 화면 위젯 | iOS/Android 위젯, 즐겨찾기 롤링, App Group |

---

## 🚫 절대 금지 사항 (CRITICAL)

### 1. Flutter 직접 실행 금지
```bash
# ❌ 금지
flutter run

# ✅ 올바른 방법
# "Flutter를 실행해서 테스트해주세요" 요청
```

### 2. 일괄 수정 금지
```bash
# ❌ 금지
for file in files: ...  # Python 일괄 처리
sed -i ...              # Shell 일괄 치환

# ✅ 올바른 방법
# 한 파일씩 Edit 도구로 수정
```

### 3. JIRA 없이 작업 금지
```bash
# ❌ 금지
# 바로 코드 수정 시작

# ✅ 올바른 방법
./scripts/parse_ux_request.sh  # 먼저 JIRA 생성
# 코드 수정
./scripts/git_jira_commit.sh "내용" "KAN-XX" "done"
```

---

## 🎯 핵심 패턴 요약

### 상태관리 (Riverpod)

```dart
// ✅ StateNotifier 패턴 사용
class FortuneNotifier extends StateNotifier<FortuneState> {
  FortuneNotifier() : super(const FortuneState());
}

// ❌ @riverpod 어노테이션 금지
@riverpod  // WRONG!
class FortuneNotifier extends _$FortuneNotifier { }
```

### UI 스타일

```dart
// ✅ TypographyUnified 사용
Text('제목', style: context.heading1)

// ❌ TossDesignSystem 폰트 금지
Text('제목', style: TossDesignSystem.heading1)  // WRONG!

// ✅ 다크모드 대응
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight
```

### 블러 처리

```dart
// ✅ UnifiedBlurWrapper 사용
UnifiedBlurWrapper(
  isBlurred: fortuneResult.isBlurred,
  sectionKey: 'advice',
  child: content,
)

// ❌ ImageFilter.blur 직접 사용 금지
```

### LLM 호출 (Edge Function)

```typescript
// ✅ LLMFactory 사용
const llm = LLMFactory.createFromConfig('fortune-type')
const response = await llm.generate(messages, { jsonMode: true })

// ❌ OpenAI/Gemini API 직접 호출 금지
fetch('https://api.openai.com/...')  // WRONG!
```

---

## 🤖 Agents (가상 개발팀)

| Agent | 역할 |
|-------|------|
| `flutter-architect` | Clean Architecture 설계 |
| `riverpod-specialist` | 상태관리 전문 |
| `freezed-generator` | 모델 생성 |
| `toss-design-guardian` | UI/UX 표준 수호 |
| `fortune-domain-expert` | 운세 도메인 |
| `testing-architect` | 테스트 설계 |
| `error-resolver` | 버그 헌터 |

---

## ⚡ Skills (커스텀 커맨드)

| 커맨드 | 용도 |
|--------|------|
| `/sc:freezed-model` | Freezed 모델 생성 |
| `/sc:state-notifier` | StateNotifier 생성 |
| `/sc:fortune-page` | 운세 페이지 생성 |
| `/sc:edge-function` | Edge Function 생성 |
| `/sc:validate-arch` | 아키텍처 검증 |
| `/sc:generate-test` | 테스트 코드 생성 |
| `/sc:quality-gate` | 품질 게이트 실행 |
| `/sc:analyze-error` | 에러 근본원인 분석 |
| `/sc:toss-widget` | Toss 스타일 위젯 생성 |
| `/sc:go-route` | GoRouter 라우트 추가 |

---

## 📱 배포 명령어

```bash
# 실제 디바이스 릴리즈 배포
flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_release_logs.txt
```

---

## 📁 프로젝트 구조

```
lib/
├── core/           # 공유 인프라 (widgets, services, theme)
├── features/       # Feature Slice 모듈
│   └── fortune/    # 운세 기능
│       ├── data/
│       ├── domain/
│       └── presentation/
├── routes/         # GoRouter 네비게이션
└── main.dart

supabase/
└── functions/      # Edge Functions
    ├── _shared/    # 공유 모듈 (llm, prompts)
    └── fortune-*/  # 운세별 함수
```

---

## 🔍 상세 문서 바로가기

- **에러 발생 시**: [01-core-rules.md](.claude/docs/01-core-rules.md) → 근본원인 분석
- **새 Feature 추가 시**: [02-architecture.md](.claude/docs/02-architecture.md) → Feature Slice 구조
- **UI 개발 시**: [03-ui-design-system.md](.claude/docs/03-ui-design-system.md) → TossDesignSystem
- **Provider 작성 시**: [04-state-management.md](.claude/docs/04-state-management.md) → StateNotifier
- **운세 페이지 작성 시**: [05-fortune-system.md](.claude/docs/05-fortune-system.md) → 6단계 프로세스
- **Edge Function 작성 시**: [06-llm-module.md](.claude/docs/06-llm-module.md) → LLMFactory
- **작업 시작 전**: [07-jira-workflow.md](.claude/docs/07-jira-workflow.md) → JIRA 먼저!
- **Agent/Skill 사용 시**: [08-agents-skills.md](.claude/docs/08-agents-skills.md) → 레퍼런스

---

## 📖 기타 문서

프로젝트 전체 문서는 `docs/` 폴더 참조:
- [docs/README.md](docs/README.md) - 문서 색인

