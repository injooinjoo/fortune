# Ondo Documentation

문서를 읽을 때는 먼저 이 저장소가 `current-state`, `system reference`, `future-state/legacy` 문서를 함께 가지고 있다는 점을 전제로 봐야 합니다.

제품 표면과 라우트 설명의 source of truth는 [getting-started/APP_SURFACES_AND_ROUTES.md](getting-started/APP_SURFACES_AND_ROUTES.md)입니다.

## 문서 분류

### 1. Current-state 문서

지금 코드와 1:1로 맞아야 하는 문서입니다.

- [현재 페이지/라우트 기준 문서](getting-started/APP_SURFACES_AND_ROUTES.md)
- [프로젝트 개요](getting-started/PROJECT_OVERVIEW.md)
- [아키텍처 문서](APP_ARCHITECTURE.md)
- [루트 README](../README.md)

이 문서들은 현재 구현을 `일반 채팅 | 호기심` 구조와 `/chat` 중심 라우트로 설명합니다.

### 2. System reference 문서

현재 제품 표면이 아니라 시스템, 도메인, 운영 지식을 설명하는 문서입니다.

- `data/`: 데이터베이스, Edge Function, LLM, API 사용 패턴
- `testing/`: 테스트 전략과 품질 검증
- `deployment/`: 앱스토어, 배포, 보안, 출시 운영
- `native/`: 위젯, 워치 앱, 플랫폼 기능
- `development/`: 자동화, JIRA, MCP, 작업 규칙
- `features/`: 기능 기획 및 명세
- `legal/`: 개인정보처리방침, 이용약관
- `troubleshooting/`: 문제 해결 가이드

### 3. Future-state / legacy 문서

현재 구현의 source of truth는 아니지만, 과거안이나 목표안을 보존하는 문서입니다.

- [../.claude/docs/18-chat-first-architecture.md](../.claude/docs/18-chat-first-architecture.md)
- [../.claude/docs/17-face-reading-system.md](../.claude/docs/17-face-reading-system.md)

이 문서들은 5탭 구조나 별도 `/fortune`, `/trend`, `/profile` 같은 미래형 IA를 포함할 수 있습니다.

## 빠른 시작

### 현재 제품 표면을 이해할 때
- [현재 페이지/라우트 기준 문서](getting-started/APP_SURFACES_AND_ROUTES.md)
- [프로젝트 개요](getting-started/PROJECT_OVERVIEW.md)
- [아키텍처 문서](APP_ARCHITECTURE.md)

### 개발 환경을 준비할 때
- [설정 가이드](getting-started/SETUP_GUIDE.md)

### 시스템 레퍼런스가 필요할 때
- [데이터베이스 가이드](data/DATABASE_GUIDE.md)
- [LLM 모듈 가이드](data/LLM_MODULE_GUIDE.md)
- [테스팅 가이드](testing/TESTING_GUIDE.md)
- [앱 스토어 가이드](deployment/APP_STORE_GUIDE.md)
- [MCP 설정 가이드](development/MCP_SETUP_GUIDE.md)

## 문서 해석 규칙

### current-state 우선순위
문서 충돌 시 아래 순서로 판단합니다.

1. `lib/routes/route_config.dart`
2. `lib/routes/routes/auth_routes.dart`
3. `lib/routes/character_routes.dart`
4. [getting-started/APP_SURFACES_AND_ROUTES.md](getting-started/APP_SURFACES_AND_ROUTES.md)
5. 나머지 문서

### 용어 규칙
- 사용자-facing 제품 용어: `일반 채팅`, `호기심`
- 내부 구현 용어: `story`, `fortune`
- 내부 용어는 코드 설명에서만 사용하고 제품 소개 문서에서는 직접 쓰지 않습니다.

## 폴더 구조

```text
docs/
├── getting-started/      # current-state 개요와 환경 설정
├── design/               # 디자인 시스템 및 Paper 운영
├── data/                 # 데이터, Edge Function, LLM
├── native/               # 플랫폼 기능
├── testing/              # 테스트와 품질
├── deployment/           # 배포, 보안, 스토어 운영
├── development/          # 자동화, 작업 규칙, 도구
├── features/             # 기능 기획
├── legal/                # 법률 문서
└── troubleshooting/      # 문제 해결
```
