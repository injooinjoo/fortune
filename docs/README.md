# Fortune App Documentation

Fortune 앱 개발을 위한 통합 문서 색인입니다.

---

## 📂 문서 구조

모든 프로젝트 문서는 주제별로 분류되어 있습니다. 작업 시작 전 관련 폴더를 확인하세요.

```
docs/
├── getting-started/    # 프로젝트 시작
├── design/            # 디자인 시스템
├── data/              # 데이터 & API
├── native/            # 네이티브 기능
├── testing/           # 테스팅
├── deployment/        # 배포 & 보안
├── development/       # 개발 도구 & 자동화
├── legal/             # 법률 & 정책
└── troubleshooting/   # 문제 해결
```

---

## 🚀 빠른 시작 (getting-started/)

- [프로젝트 개요](getting-started/PROJECT_OVERVIEW.md) - 아키텍처, 기술 스택, 프로젝트 구조
- [개발 환경 설정](getting-started/SETUP_GUIDE.md) - Flutter, Firebase, Supabase 설정

---

## 🎨 디자인 시스템 (design/)

- [TOSS 디자인 시스템](design/TOSS_DESIGN_SYSTEM.md) ⭐️ - TOSS 통합 가이드 (색상, 타이포그래피, 컴포넌트)
- [디자인 시스템](design/DESIGN_SYSTEM.md) - Fortune 디자인 철학 및 컴포넌트
- [UI/UX 마스터 정책](design/UI_UX_MASTER_POLICY.md) - UI/UX 개발 원칙 및 정책
- [UI/UX 확장 로드맵](design/UI_UX_EXPANSION_ROADMAP.md) - 향후 UI/UX 개선 계획
- [위젯 아키텍처](design/WIDGET_ARCHITECTURE_DESIGN.md) - Flutter 위젯 설계 패턴

---

## 💾 데이터 & API (data/)

- [데이터베이스 가이드](data/DATABASE_GUIDE.md) ⭐️ - 통합 DB 문서 (스키마, RLS, Celebrity DB, 마이그레이션)
- [API 사용법](data/API_USAGE.md) - Supabase API 사용 패턴

---

## 📱 네이티브 기능 (native/)

- [네이티브 기능 가이드](native/NATIVE_FEATURES_GUIDE.md) ⭐️ - 통합 네이티브 기능 (홈 위젯, Lock Screen, Dynamic Island 등)
- [워치 앱 가이드](native/WATCH_COMPANION_APPS_GUIDE.md) - Apple Watch 및 Wear OS 앱 개발

---

## 🧪 테스팅 & 최적화 (testing/)

- [테스팅 가이드](testing/TESTING_GUIDE.md) - 테스트 전략 및 실행 방법
- [A/B 테스팅 가이드](testing/AB_TESTING_GUIDE.md) ⭐️ - Firebase A/B Testing 완벽 가이드
- [Resilient Service 가이드](testing/RESILIENT_SERVICE_GUIDE.md) - 안정적인 서비스 패턴

---

## 🚢 배포 & 보안 (deployment/)

- [배포 완벽 가이드](deployment/DEPLOYMENT_COMPLETE_GUIDE.md) ⭐️ - Android/iOS 배포 전체 프로세스
- [앱 스토어 가이드](deployment/APP_STORE_GUIDE.md) ⭐️ - App Store Connect 및 Google Play Console
- [보안 체크리스트](deployment/SECURITY_CHECKLIST.md) - 배포 전 보안 점검

---

## 🛠 개발 도구 & 자동화 (development/)

### JIRA 자동화
- [CLAUDE 자동화 가이드](development/CLAUDE_AUTOMATION.md) ⭐️ - JIRA 자동화 및 워크플로우
- [Git + JIRA 워크플로우](development/GIT_JIRA_WORKFLOW.md) - Git과 JIRA 통합
- [JIRA 설정](development/JIRA_CONFIG.md) - JIRA 프로젝트 설정
- [UX 요청 처리 가이드](development/UX_REQUEST_GUIDE.md) - UX 피드백 자동 처리
- [실시간 에러 모니터링](development/RUNTIME_ERROR_MONITORING.md) ⭐️ - 런타임 에러 자동 JIRA 등록

### MCP & Agent
- [MCP 설정 가이드](development/MCP_SETUP_GUIDE.md) - Model Context Protocol 서버 설정
- [Agent 사양](development/AGENTS.md) - Claude Agent 상세 사양

---

## ⚖️ 법률 & 정책 (legal/)

- [개인정보 처리방침](legal/PRIVACY_POLICY_CONTENT.md) - 앱 개인정보 처리방침 전문

---

## 🛠 문제 해결 (troubleshooting/)

- [406 에러 수정 가이드](troubleshooting/FIX_406_ERROR_GUIDE.md) - HTTP 406 에러 해결 방법

---

## 📋 작업별 문서 찾기

### 프로젝트 시작할 때
→ `getting-started/` 폴더 확인
- PROJECT_OVERVIEW.md (아키텍처 이해)
- SETUP_GUIDE.md (환경 구축)

### UI/디자인 작업할 때
→ `design/` 폴더 확인
- 새 UI 컴포넌트 → TOSS_DESIGN_SYSTEM.md
- 색상/폰트 변경 → TOSS_DESIGN_SYSTEM.md
- 위젯 구조 설계 → WIDGET_ARCHITECTURE_DESIGN.md

### 데이터베이스 작업할 때
→ `data/` 폴더 확인
- 새 테이블 추가 → DATABASE_GUIDE.md
- RLS 정책 설정 → DATABASE_GUIDE.md
- API 호출 패턴 → API_USAGE.md

### 네이티브 기능 개발할 때
→ `native/` 폴더 확인
- 홈 위젯 추가 → NATIVE_FEATURES_GUIDE.md
- iOS 잠금화면 기능 → NATIVE_FEATURES_GUIDE.md
- 워치 앱 개발 → WATCH_COMPANION_APPS_GUIDE.md

### 테스트/최적화 작업할 때
→ `testing/` 폴더 확인
- A/B 테스트 설정 → AB_TESTING_GUIDE.md
- 서비스 안정성 개선 → RESILIENT_SERVICE_GUIDE.md
- 테스트 코드 작성 → TESTING_GUIDE.md

### 배포/출시 준비할 때
→ `deployment/` 폴더 확인
- Android/iOS 배포 → DEPLOYMENT_COMPLETE_GUIDE.md
- 앱스토어 등록 → APP_STORE_GUIDE.md
- 보안 검토 → SECURITY_CHECKLIST.md

### 자동화/워크플로우 설정할 때
→ `development/` 폴더 확인
- JIRA 자동 등록 → CLAUDE_AUTOMATION.md
- Git 커밋 자동화 → GIT_JIRA_WORKFLOW.md
- MCP 서버 설정 → MCP_SETUP_GUIDE.md

---

## 📝 문서 정리 히스토리

### 2025-09-30: 문서 구조 재정비
- **주제별 폴더 분류**: 9개 카테고리로 체계화
- **루트 정리**: 프로젝트 루트 문서 10개 → 2개 (README.md, CLAUDE.md)
- **경로 통일**: 모든 문서를 `docs/` 하위로 이동
- **탐색 개선**: 작업별 문서 찾기 가이드 추가

### 2025-09-30: 통합 문서 생성 ⭐️
아래 문서들은 여러 중복 파일들을 하나로 통합한 최신 버전입니다:

1. **DEPLOYMENT_COMPLETE_GUIDE.md** - 4개 파일 통합 (배포 관련 모든 정보)
2. **TOSS_DESIGN_SYSTEM.md** - 7개 파일 통합 (TOSS 디자인 시스템 완벽 가이드)
3. **AB_TESTING_GUIDE.md** - 3개 파일 통합 (A/B 테스팅 완벽 가이드)
4. **DATABASE_GUIDE.md** - 3개 파일 통합 (DB 스키마, RLS, 마이그레이션)
5. **NATIVE_FEATURES_GUIDE.md** - 3개 파일 통합 (네이티브 기능 통합 가이드)
6. **APP_STORE_GUIDE.md** - 4개 파일 통합 (앱스토어 출시 완벽 가이드)

---

## 프로젝트 루트 문서

프로젝트 루트에는 핵심 진입점 문서만 유지합니다:

- [README.md](../README.md) - 프로젝트 소개 및 시작 방법
- [CLAUDE.md](../CLAUDE.md) - Claude Code 개발 규칙 및 자동화 워크플로우

---

## 기여

문서 개선 제안이 있으시면 JIRA 티켓을 생성하거나 직접 PR을 제출해주세요.

**백업 위치**: `/Users/jacobmac/Desktop/Dev/fortune-docs-backup-20250930/`