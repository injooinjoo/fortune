# Agents & Skills 레퍼런스

> 최종 업데이트: 2025.01.03

## 개요

Fortune App 개발에 최적화된 7개의 Agent(전문가 페르소나)와 10개의 Skill(커스텀 슬래시 커맨드)을 정의합니다.

## 통계

| 항목 | 수치 |
|------|------|
| Agents | 7개 |
| Skills | 10개 |
| Managed Skills | 6개 (프로젝트 레벨) |
| User Skills | 4개 (사용자 레벨) |

---

## Agents (전문가 페르소나)

### 가상 개발팀 구성

| Agent | 역할 | 전문 영역 |
|-------|------|----------|
| **flutter-architect** | Clean Architecture 설계자 | 레이어 분리, DI, 의존성 규칙 |
| **riverpod-specialist** | 상태관리 전문가 | StateNotifier, Provider 패턴 |
| **freezed-generator** | 모델 생성 전문가 | Freezed, JsonSerializable |
| **toss-design-guardian** | UI/UX 표준 수호자 | TossDesignSystem, 다크모드 |
| **fortune-domain-expert** | 운세 도메인 전문가 | 비용 최적화, 블러 시스템 |
| **testing-architect** | 테스트 설계자 | 단위/통합/E2E 테스트 |
| **error-resolver** | 버그 헌터 | 근본원인 분석, 에러 패턴 |

---

### Agent 상세

#### flutter-architect

**역할**: Clean Architecture 설계자

**전문 영역**:
- Feature Slice 구조 설계
- 레이어 간 의존성 관리
- Domain → Data → Presentation 분리
- Repository 패턴 구현

**검증 항목**:
- [ ] Presentation → Data 직접 참조 금지
- [ ] Feature 간 직접 참조 금지
- [ ] Domain 레이어 순수 Dart 유지
- [ ] 모든 모델 @freezed 사용

**관련 문서**: [02-architecture.md](02-architecture.md)

---

#### riverpod-specialist

**역할**: 상태관리 전문가

**전문 영역**:
- StateNotifier + State 클래스 패턴
- copyWith 메서드 구현
- Provider 의존성 주입
- 비동기 상태 처리

**금지 패턴**:
- ❌ `@riverpod` 어노테이션 사용
- ❌ `riverpod_generator` 사용
- ❌ Provider 외부에서 State 직접 수정

**관련 문서**: [04-state-management.md](04-state-management.md)

---

#### freezed-generator

**역할**: 모델 생성 전문가

**전문 영역**:
- @freezed 모델 생성
- @JsonKey 매핑
- @Default 기본값 설정
- factory 생성자 패턴

**표준 템플릿**:
```dart
@freezed
class FortuneResult with _$FortuneResult {
  const factory FortuneResult({
    required String id,
    @JsonKey(name: 'overall_score') required int overallScore,
    @Default(false) bool isBlurred,
  }) = _FortuneResult;

  factory FortuneResult.fromJson(Map<String, dynamic> json) =>
      _$FortuneResultFromJson(json);
}
```

---

#### toss-design-guardian

**역할**: UI/UX 표준 수호자

**전문 영역**:
- TossDesignSystem 색상 토큰
- TypographyUnified 폰트 시스템
- 다크모드 대응 패턴
- UnifiedBlurWrapper 블러 처리

**검증 항목**:
- [ ] 하드코딩 색상 금지 → TossDesignSystem 사용
- [ ] 하드코딩 fontSize 금지 → TypographyUnified 사용
- [ ] isDark 조건문으로 다크모드 대응
- [ ] AppBar에 Icons.arrow_back_ios 사용

**관련 문서**: [03-ui-design-system.md](03-ui-design-system.md)

---

#### fortune-domain-expert

**역할**: 운세 도메인 전문가

**전문 영역**:
- 6단계 운세 조회 프로세스
- 72% API 비용 절감 로직
- 프리미엄/일반 사용자 분기
- 블러 해제 광고 시스템

**핵심 지식**:
- 개인 캐시 → DB 풀 → 30% 랜덤 → API 호출
- UnifiedFortuneService 사용
- 토큰 소비율 (Simple:1, Medium:2, Complex:3, Premium:5)

**관련 문서**: [05-fortune-system.md](05-fortune-system.md)

---

#### testing-architect

**역할**: 테스트 설계자

**전문 영역**:
- Widget 테스트 작성
- Provider 모킹
- 통합 테스트 설계
- 테스트 커버리지 관리

**테스트 패턴**:
```dart
testWidgets('renders correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fortuneProvider.overrideWith((ref) => MockFortuneNotifier()),
      ],
      child: MaterialApp(home: FortunePage()),
    ),
  );

  expect(find.byType(FortunePage), findsOneWidget);
});
```

---

#### error-resolver

**역할**: 버그 헌터

**전문 영역**:
- 근본 원인 분석 (Root Cause Analysis)
- 에러 패턴 전체 검색
- 올바른 패턴 적용
- 일관된 수정

**분석 프로세스**:
1. 왜 에러가 발생했는지 추적
2. 동일 패턴 전체 코드베이스 검색
3. 올바르게 처리된 곳 찾기
4. 근본 원인 해결 (증상만 치료 금지)

**관련 문서**: [01-core-rules.md](01-core-rules.md)

---

## Skills (커스텀 슬래시 커맨드)

### 커맨드 목록

| 커맨드 | 용도 | Agent 연계 |
|--------|------|-----------|
| `/sc:freezed-model` | Freezed 모델 생성 | freezed-generator |
| `/sc:state-notifier` | StateNotifier 생성 | riverpod-specialist |
| `/sc:fortune-page` | 운세 페이지 생성 | fortune-domain-expert |
| `/sc:edge-function` | Edge Function 생성 | fortune-domain-expert |
| `/sc:validate-arch` | 아키텍처 검증 | flutter-architect |
| `/sc:generate-test` | 테스트 코드 생성 | testing-architect |
| `/sc:quality-gate` | 품질 게이트 실행 | flutter-architect |
| `/sc:analyze-error` | 에러 근본원인 분석 | error-resolver |
| `/sc:toss-widget` | Toss 스타일 위젯 생성 | toss-design-guardian |
| `/sc:go-route` | GoRouter 라우트 생성 | flutter-architect |

---

### Skill 상세

#### /sc:freezed-model

**용도**: Freezed 모델 파일 생성

**입력**: 모델 이름, 필드 정의

**출력**:
- `lib/features/{feature}/domain/models/{model}.dart`
- `lib/features/{feature}/domain/models/{model}.freezed.dart`
- `lib/features/{feature}/domain/models/{model}.g.dart`

**실행 후**: `dart run build_runner build --delete-conflicting-outputs`

---

#### /sc:state-notifier

**용도**: StateNotifier + State 클래스 생성

**입력**: Provider 이름, State 필드

**출력**: `lib/features/{feature}/presentation/providers/{name}_provider.dart`

**포함 내용**:
- State 클래스 (copyWith 포함)
- StateNotifier 클래스 (load, update, reset, clearError)
- StateNotifierProvider 정의

---

#### /sc:fortune-page

**용도**: 운세 페이지 표준 템플릿 생성

**입력**: 운세 유형, 입력 필드 정의

**출력**: `lib/features/fortune/presentation/pages/{type}_fortune_page.dart`

**포함 내용**:
- UnifiedFortuneBaseWidget 사용
- 프리미엄 확인 로직
- 블러 처리 시스템
- 토큰 소비 로직

---

#### /sc:edge-function

**용도**: Supabase Edge Function 생성

**입력**: 운세 유형, 프롬프트 정의

**출력**:
- `supabase/functions/fortune-{type}/index.ts`
- `supabase/functions/_shared/prompts/templates/{type}.ts`

**포함 내용**:
- LLMFactory 사용
- PromptManager 연동
- 표준 CORS 처리
- 에러 핸들링

---

#### /sc:validate-arch

**용도**: 아키텍처 규칙 검증

**검증 항목**:
- Presentation → Data 직접 참조
- Feature 간 직접 참조
- @riverpod 어노테이션 사용 여부
- 하드코딩된 색상/폰트

**출력**: 위반 사항 리포트

---

#### /sc:generate-test

**용도**: 테스트 코드 자동 생성

**입력**: 테스트 대상 파일

**출력**: `test/{path}/{name}_test.dart`

**테스트 유형**:
- Widget 테스트
- Provider 테스트
- Service 테스트

---

#### /sc:quality-gate

**용도**: 코드 품질 게이트 실행

**실행 항목**:
1. `flutter analyze`
2. `dart format --set-exit-if-changed .`
3. `flutter test`
4. 아키텍처 검증 (`/sc:validate-arch`)

**통과 조건**: 모든 항목 에러 없음

---

#### /sc:analyze-error

**용도**: 에러 근본원인 분석

**입력**: 에러 로그 또는 스택트레이스

**분석 단계**:
1. 에러 발생 위치 추적
2. 동일 패턴 전체 검색
3. 올바른 패턴 제시
4. 수정 방안 제안

---

#### /sc:toss-widget

**용도**: Toss 디자인 스타일 위젯 생성

**입력**: 위젯 유형 (card, button, input, etc.)

**출력**: `lib/core/widgets/{name}.dart`

**포함 내용**:
- TossDesignSystem 색상
- TypographyUnified 폰트
- 다크모드 대응
- 접근성 고려

---

#### /sc:go-route

**용도**: GoRouter 라우트 추가

**입력**: 라우트 경로, 페이지 클래스

**수정 파일**: `lib/routes/route_config.dart`

**포함 내용**:
- GoRoute 정의
- 파라미터 처리
- 리다이렉트 로직 (필요시)

---

## 파일 위치

### Agents

```
.claude/agents/
├── flutter-architect.md
├── riverpod-specialist.md
├── freezed-generator.md
├── toss-design-guardian.md
├── fortune-domain-expert.md
├── testing-architect.md
└── error-resolver.md
```

### Skills

```
.claude/commands/
├── sc-freezed-model.md
├── sc-state-notifier.md
├── sc-fortune-page.md
├── sc-edge-function.md
├── sc-validate-arch.md
├── sc-generate-test.md
├── sc-quality-gate.md
├── sc-analyze-error.md
├── sc-toss-widget.md
└── sc-go-route.md
```

---

## 관련 문서

- [01-core-rules.md](01-core-rules.md) - 핵심 개발 규칙
- [02-architecture.md](02-architecture.md) - 아키텍처 가이드
- [03-ui-design-system.md](03-ui-design-system.md) - UI 디자인 시스템
- [04-state-management.md](04-state-management.md) - 상태관리 가이드

