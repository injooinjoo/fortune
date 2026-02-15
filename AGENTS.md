# Fortune Repository Rules for Codex (Consolidated)

> Last consolidated: 2026-02-14  
> Consolidated from: `CLAUDE.md`, `.claude/docs/*.md`, `.claude/skills/*/skill.md`

## 0. 목적
- 이 문서는 Claude 쪽 프로젝트 규칙을 Codex 환경에서 실행 가능하도록 통합한 단일 운영 규칙이다.
- 목표는 규칙 누락 최소화, 충돌 시 일관된 판정, 실제 작업 가능성 보장이다.

## 1. 우선순위/충돌 해소
- 규칙 우선순위:
  1. 사용자의 명시적 지시
  2. 시스템/보안 제약
  3. 본 문서
  4. 참조 문서 원문
- 참조 문서 간 충돌 시:
  - 최신 업데이트 문서를 우선 적용한다.
  - 업데이트 일자가 없거나 애매하면 `안전한 쪽(더 보수적인 규칙)`을 우선한다.
- 현재 확인된 대표 충돌:
  - 토큰 정책: `.claude/docs/22-business-model.md`(2026-02-09) 우선.  
    `모든 AI 기능/운세는 토큰 소비`를 기본 정책으로 본다.

## 2. 문서 로딩 규칙
- Tier 1 (항상): `CLAUDE.md`
- Tier 2 (개발 키워드 트리거): `.claude/docs/01~06`, `.claude/docs/18`
- Tier 3 (명시 요청 시): `.claude/docs/07~23`

## 3. 자동 라우팅 규칙 (요청 분류)
- 운세/궁합/타로/사주 기능 추가: `feature-fortune` 흐름
- 채팅/추천칩/메시지: `feature-chat` 흐름
- UI/디자인/색상/레이아웃: `feature-ui` 흐름
- Edge Function/API: `backend-service` 흐름
- 에러/버그/안됨/깨짐/작동안함: `troubleshoot` 흐름
- 검증/품질/QA: `quality-check` 흐름
- 키워드 기반 JIRA 타입:
  - Bug: 버그/에러/오류/안됨/깨짐/이상
  - Story: 추가/새로운/만들어줘/구현
  - Task: 수정/바꿔줘/개선/고쳐줘

## 4. MCP 사용 우선순위
- 1순위 Supabase, 2순위 Playwright, 3순위 Context7, 4순위 Sequential, 5순위 JIRA, 그 외(Figma/GitHub/Brave).
- 특정 MCP가 필요하지만 연결되지 않은 경우:
  - 차단 사실을 명시하고 가능한 로컬 대체 절차로 계속 진행한다.

## 5. 절대 금지 규칙 (Critical)
- `flutter run`을 에이전트가 직접 실행하지 않는다.
  - 사용자에게 실행 요청 후 로그를 받아 분석한다.
- 일괄 수정 금지:
  - `sed -i`, `awk`, `perl`, `grep|xargs`, 루프 기반 다중 파일 덮어쓰기, IDE replace-all in files 금지
  - 파일 단위로 문맥 확인 후 수정
- 상태관리 금지 패턴:
  - `@riverpod`/`riverpod_generator` 금지
  - Provider 외부에서 state 직접 변경 금지
- UI 금지 패턴:
  - 하드코딩 색상/폰트(`Color(0x...)`, raw `fontSize`, `Colors.white/black`) 금지
- LLM/Edge 금지 패턴:
  - OpenAI/Gemini 직접 API 호출 금지
  - 프롬프트 하드코딩 금지
- 에러 처리 금지 패턴:
  - 빈 catch / print-only catch
  - 원인분석 없는 null 회피식 임시처리

## 6. Hard Block 게이트 (반드시 준수)

### Block 1: RCA (버그/에러 수정 전 필수)
- 트리거: 버그/에러/안됨/깨짐/작동안함/수정(버그 맥락)
- 차단 조건:
  - WHY, WHERE ELSE, HOW 미완료
  - RCA 보고서 미출력
- 필수 출력:
  - 증상, WHY(근본 원인), WHERE(파일/라인), WHERE ELSE(전역검색 결과), HOW(정상 패턴 참조), 수정 계획
- 원칙:
  - 증상 가리기 금지, 근본 원인 해결
  - 동일 패턴 전역 검색 필수
- 템플릿:
  - `docs/development/templates/RCA_REPORT_TEMPLATE.md`

### Block 2: Discovery (새 코드 작성 전 필수)
- 트리거: 모든 코드 생성/추가 작업
- 차단 조건:
  - 유사 코드 검색 미수행
  - 재사용/확장/신규 판단 미작성
  - Discovery 보고서 미출력
- Codex 표준 검색(기본 `rg`):
  - State: `rg "extends StateNotifier" lib/`
  - Widget: `rg "class .*Widget" lib/`
  - Service: `rg "class .*Service" lib/`
  - Model: `rg "@freezed" lib/`
  - Provider: `rg "StateNotifierProvider" lib/`
  - Page: `rg --files lib | rg "page.*\\.dart|_page\\.dart"`
- 템플릿:
  - `docs/development/templates/DISCOVERY_REPORT_TEMPLATE.md`

### Block 3: Verify (완료 선언 전 필수)
- 차단 조건:
  - `flutter analyze` 미실행 또는 에러 존재
  - freezed 영향 작업에서 build_runner 미검증
  - 사용자 테스트 확인 전 완료 선언
- 기본 검증 순서:
  1. `flutter analyze`
  2. `dart run build_runner build --delete-conflicting-outputs` (필요시)
  3. `dart format --set-exit-if-changed .`
  4. 범위별 테스트/QA
- 템플릿:
  - `docs/development/templates/VERIFY_REPORT_TEMPLATE.md`

## 7. JIRA 규칙 (Critical)
- 개발 작업 시작 시 JIRA 이슈 생성이 기본이다(FORT 프로젝트).
- 완료 시 Done 전환 + 해결 코멘트 남긴다.
- JIRA MCP 미연결 시:
  - 자동화 불가를 명시하고 코드 작업은 계속 진행한다.
- 금지:
  - JIRA 등록 없이 바로 개발 완료 처리
  - 완료 후 이슈 상태 미정리

## 8. 아키텍처 규칙 (Clean Architecture)
- 의존 방향: `presentation -> domain <- data`
- 금지 의존:
  - `presentation -> data` 직접 참조
  - `domain -> presentation` / `domain -> data`
  - feature 간 직접 참조(공유는 core를 통해)
- Domain은 Flutter 의존 없는 순수 Dart 유지
- Feature 구조: `data/domain/presentation` 분리
- 아키텍처 체크:
  - 새 Feature: 구조 생성, domain model/freezed, repository interface, StateNotifier 적용
  - 코드리뷰: layer violation/cross-feature import 금지 확인

## 9. 네이밍 규칙
- 파일 접미사 금지:
  - `_v2`, `_v3`, `_new`, `_old`, `_enhanced`, `_renewed`
  - Edge Function에서는 `-enhanced`, `-unified`, `-new`, `-v2`, `-test`, `-advanced` 금지
- 예외:
  - `typography_unified.dart` 허용
- 표준 패턴:
  - Page: `{feature}_{subtype}_page.dart`
  - Service: `{domain}_service.dart`
  - Widget: `{name}_widget.dart`
  - Provider: `{domain}_provider.dart`
- Edge Function:
  - 인사이트: `fortune-{type}`
  - 유틸: `{verb}-{target}`
- Edge Function 작업 원칙:
  - 새 함수 생성보다 기존 함수 수정 우선
  - 대규모 변경은 (사용자가 브랜치 작업을 요청한 경우) feature branch 기반으로 관리
  - `EdgeFunctionsEndpoints` 상수/매핑 동기화 필수

## 10. 상태관리 규칙 (Riverpod)
- 표준: 수동 `StateNotifier + StateNotifierProvider`
- 필수:
  - State `copyWith`
  - load/update/reset/clearError 메서드
  - 서비스 Provider 주입
  - loading/error/data 플래그로 상태 처리
- 금지:
  - `@riverpod`
  - Provider 외부 state 직접 수정

## 11. UI/디자인 시스템 규칙
- 색상: `DSColors` / `context.colors` 사용
- 타이포: `context.heading*`, `context.body*`, `context.caption` 등 사용
- 다크모드: 테마/`context.colors` 기반 대응
- AppBar: iOS back (`Icons.arrow_back_ios`) 사용
- blur: `UnifiedBlurWrapper` 우선
- 금지:
  - `Color(0x...)`, raw `fontSize`, `Colors.white/black`
  - 레거시 색상 시스템(DSFortuneColors/ObangseokColors 등)
- 예외:
  - 오행 시각화에 `SajuColors` 허용
- 타이포 정책:
  - 같은 UI 위치는 같은 스타일
  - 시스템 글자크기 존중(0.8x~1.5x)

## 12. 햅틱 규칙
- `FortuneHapticService`를 통한 중앙 제어만 사용
- 사용자 설정(`hapticEnabled`)을 반드시 존중
- 금지:
  - `HapticFeedback` 직접 호출
  - 모든 버튼에 과도한 햅틱
  - 스크롤 중 트리거, debounce 없는 연속 햅틱

## 13. Chat-First 규칙
- 기본 탭/경로:
  - Home `/chat`, 인사이트 `/home`, 탐구 `/fortune`, 트렌드 `/trend`, 프로필 `/profile`
- 채팅 상태:
  - `ChatMessagesNotifier` 중심(StateNotifier)
- 결과 표시:
  - `FortuneResult -> ChatMessage` 변환 후 채팅으로 출력
  - 요약 -> 상세 -> 후속 추천칩 순서
- 추천칩:
  - 동적 큐레이션(`curateChips`) 원칙
  - 하드코딩 칩 금지
- 금지:
  - 채팅에서 직접 페이지 이동 유도

### 채팅 설문(Chat Survey) 설계 규칙
- 질문 톤: 친근한 대화체(문서 정책 기준) 유지
- UI 맥락에서 이모지 활용 허용(가독성 해치지 않는 범위)
- 1질문 1개념 원칙(복합 질문 금지)
- 설문 길이:
  - 최소 0~1 step
  - 표준 2~3 step
  - 상세 4~5 step
  - 최대 6 step 초과 금지
- 필수/선택:
  - 핵심 입력은 `isRequired: true`
  - 선택 입력은 `isRequired: false`
  - 조건부 노출은 `showWhen`
- 기존 페이지 입력 재사용:
  - 중요 입력은 채팅에도 반영
  - 필드가 8개 이상이면 핵심 3~4개로 압축
  - 프로필 보유 정보(생년월일 등) 재수집 금지

## 14. 운세/비즈니스/토큰 규칙
- 최신 정책 기준:
  - 모든 AI 기능/운세는 토큰 소비
  - 구독자는 정기 토큰 지급 모델이며 사용 시에도 토큰 소비
- 기존 운세 최적화 흐름(캐시/DB풀/랜덤/API)은 유지
- 채팅 운세도 동일 토큰 정책 적용
- 토큰 비용/요율은 문서와 코드가 불일치할 수 있으므로:
  - 최종 값은 앱 상수/서버 정책 값을 소스 오브 트루스로 확인 후 적용

## 15. Survey/데이터 플로우 정합성 규칙
- Survey 입력 필드, Edge Function 필수 필드, 결과 페이지 사용 필드는 반드시 정합해야 한다.
- 필수:
  - 필드명/케이스(camel/snake) 매핑 명시
  - required 필드 누락 시 Survey 단계 보완
  - 사용하지 않는 응답 필드는 정리 또는 의도 기록
- 현재 고위험 불일치(문서상):
  - `fortune-talent` required 입력 누락
  - `fortune-blind-date` Survey -> API 전달 누락
  - `fortune-health` required `current_condition` 누락
- 로컬 처리 인사이트(`tarot`, `exercise`, `personalityDna`)는 서버 의존 없이 동작해야 하며 서버 연동 추가 시 명시 검증 필요

## 16. Edge Function + LLM 규칙
- 필수 구성:
  - `LLMFactory.createFromConfig()`
  - `PromptManager` 템플릿
  - `llm.generate(..., { jsonMode: true })`
- 표준 응답 스키마(강제):
  - wrapper: `{ success: true, data: ... }`
  - required fields: `fortuneType`, `score`, `content`, `summary`, `advice`, `timestamp`
- 필드명 통일:
  - `overallScore`, `mainMessage`, `shortSummary` 등 별칭 금지
- Face Reading V2:
  - 친근한 말투(~예요/~해 보세요)
  - 성별 분기 로직 유지
  - 톤 원칙: 위로 우선, 공감 표현, 부드러운 조언, 긍정 마무리
  - App Store 민감 용어 제한(운세/점술/fortune/horoscope 등)

## 17. QA/테스트 규칙
- UI/페이지/라우트/구독/Edge 배포 변경 시 Playwright QA를 실행 또는 최소 제안한다.
- auto-qa 트리거 기준:
  - `*_fortune_page.dart` 변경
  - `presentation/widgets/` 변경
  - `supabase functions deploy` 수행
  - premium 관련 코드 변경
  - 라우팅 변경
- 기본 테스트 스택:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - `flutter test` 또는 `./scripts/run_all_tests.sh ...`
  - 웹 E2E: `npm run test:e2e`
- 자동 QA UX:
  - UI 변경 후 `localhost:3000`이 준비되어 있으면 자동 QA 실행 여부를 먼저 확인한다.
  - 커밋 메시지에 `[skip-qa]`가 명시되면 자동 QA 스킵 가능.

## 18. Skill 의존 체인 규칙 (Codex 적용 방식)
- 원문 Skill 체인:
  - `feature-fortune/chat/ui/backend-service` 전 `enforce-discovery` 필수
  - `troubleshoot` 전 `enforce-rca` 필수
  - 대부분 완료 후 `enforce-verify` 자동
- Codex에서는 slash command를 직접 쓰지 않으므로:
  - 해당 게이트를 내부 절차로 강제 적용한다(RCA/Discovery/Verify 보고).

## 19. 인프라 조건부 규칙

### Universal Links/도메인 작업 시
- 필수 확인:
  - DNS 필수 레코드(A/CNAME)
  - iOS Associated Domains 활성화
  - `apple-app-site-association` 배포
  - Android `assetlinks.json` SHA256 최신화

### On-Demand Asset Delivery 작업 시
- Tier 정책 준수:
  - Tier1만 번들 포함
  - Tier2/3는 스토리지/온디맨드
- `asset_pack_config.dart`, `pubspec.yaml`, 스토리지 경로 정합성 확인

## 20. 보안/설정 규칙
- 비밀값 커밋 금지
- `.env.development`/`.env.production` 기반 `--dart-define-from-file` 사용
- 필요 시 `.gitleaks.toml` 기반 점검

## 21. Codex 실행 규칙 (Repository 특화)
- 파일 검색은 `rg` 우선
- 변경은 최소 범위, 파일 단위 문맥 확인 후 적용
- 브랜치 생성은 명시 요청 시에만 수행한다.
- 개발 변경이 발생하면 커밋/푸시 요청 여부와 무관하게 `git commit` + `git push`를 기본 수행한다.
- `git push` 후 해당 브랜치/커밋의 GitHub Actions 상태 확인을 기본 수행한다.
- 대규모 변경 전 간단 계획 수립, 완료 전 검증 결과를 명시
- UI 전용 작업은 기본적으로 Presentation 범위에서 해결하고, Domain/Data 변경은 명시적 필요가 있을 때만 수행
- Edge 전용 작업은 기본적으로 `supabase/functions`와 `_shared` 범위에서 해결

## 22. 완료 보고 규칙
- 완료 보고에는 최소 아래를 포함:
  1. 수정 파일 목록
  2. 핵심 변경 요약
  3. 실행한 검증(분석/테스트/QA)
  4. 사용자 수동 테스트 시나리오(필요 시)
  5. 미수행/차단 사항(JIRA MCP 미연결 등)
- 6. `git push` 실행 결과 및 GitHub Actions 상태
- 커밋 요청 여부와 무관하게 메시지 형식:
  - `[FORT-XXX] <type>: <summary>`
  - type 예시: `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`

## 25. 고정 개발 완료 게이트(반드시)
- 개발 완료 후 즉시 다음 절차를 수행한다.
  - 사용자 요청 여부와 무관하게 커밋/푸시까지 완료한다.
  - `git push` 실행
  - GitHub Actions의 해당 브랜치/커밋 Workflow 실행 상태 확인
  - 실패 시 원인 파악 후 수정 후 재실행
- 위 항목은 기존 QA/검증( flutter analyze, test, QA ) 완료 후에도 필수로 수행한다.

## 24. 참조 문서 맵
- 핵심: `.claude/docs/01-core-rules.md`
- 아키텍처: `.claude/docs/02-architecture.md`
- UI: `.claude/docs/03-ui-design-system.md`
- 상태관리: `.claude/docs/04-state-management.md`
- 운세 시스템: `.claude/docs/05-fortune-system.md`
- LLM/Edge: `.claude/docs/06-llm-module.md`
- JIRA: `.claude/docs/07-jira-workflow.md`
- Chat-First: `.claude/docs/18-chat-first-architecture.md`
- 데이터플로우: `.claude/docs/20-insight-data-flow-analysis.md`
- 비즈니스 모델: `.claude/docs/22-business-model.md`

## 25. 프로젝트 구조/명령어 기본값
- 구조:
  - 앱 코드: `lib/` (`core/`, `data/`, `features/`, `presentation/`, `main.dart`)
  - 테스트: `test/`, `integration_test/`
  - 웹 E2E: `playwright/`
  - 플랫폼: `android/`, `ios/`, `macos/`, `web/`
  - 자산: `assets/`
- 기본 명령:
  - setup: `flutter pub get`
  - analyze: `flutter analyze`
  - format: `dart format .`
  - test: `flutter test` 또는 `./scripts/run_all_tests.sh ...`
  - e2e: `npm run test:install && npm run test:e2e`
- 코딩 스타일:
  - Effective Dart + `flutter_lints`
  - single quotes, `const` 우선, 로컬 `final` 우선
  - `print` 대신 로거 사용
