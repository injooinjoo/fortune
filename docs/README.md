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
├── features/          # 기능 기획 & 명세
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
- [폰트 시스템 가이드](design/FONT_SYSTEM_GUIDE.md) - 통합 폰트 시스템 (마이그레이션 포함)

---

## 💾 데이터 & API (data/)

- [데이터베이스 가이드](data/DATABASE_GUIDE.md) ⭐️ - 통합 DB 문서 (스키마, RLS, Celebrity DB, 마이그레이션)
- [운세 프리미엄 & 광고 시스템](data/FORTUNE_PREMIUM_AD_SYSTEM.md) ⭐️ - 프리미엄/일반 사용자 분기 및 광고 후불제
- [운세 조회 최적화 가이드](data/FORTUNE_OPTIMIZATION_GUIDE.md) - 3단계 캐싱으로 API 비용 72% 절감
- [LLM 모듈 가이드](data/LLM_MODULE_GUIDE.md) ⭐️ - LLM Provider 추상화 (Gemini/OpenAI/Claude)
- [LLM Provider 마이그레이션](data/LLM_PROVIDER_MIGRATION.md) - GPT-5-nano → Gemini 전환 가이드
- [프롬프트 엔지니어링](data/PROMPT_ENGINEERING_GUIDE.md) - 프롬프트 템플릿 관리
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

### 핵심 가이드
- [Android 배포 요약](deployment/ANDROID_DEPLOYMENT_SUMMARY.md) - 안드로이드 배포 체크리스트
- [iOS 런칭 퀵스타트](deployment/IOS_LAUNCH_QUICKSTART.md) - iOS 런칭 핵심 요약
- [앱 스토어 가이드](deployment/APP_STORE_GUIDE.md) ⭐️ - App Store Connect 및 Google Play Console
- [보안 체크리스트](deployment/SECURITY_CHECKLIST.md) - 배포 전 보안 점검

### iOS 설정 & 운영
- [Apple Capabilities 설정](deployment/APPLE_CAPABILITIES_SETUP.md) - iOS 기능 권한 설정
- [Xcode 설정 가이드](../ios/FortuneWatch/XCODE_SETUP_GUIDE.md) - Xcode/Watch 프로젝트 설정

### 앱스토어 에셋 & 제출
- [앱스토어 에셋 가이드](deployment/APP_STORE_ASSETS_GUIDE.md) - 스크린샷, 아이콘 가이드
- [스크린샷 가이드](deployment/SCREENSHOT_GUIDE.md) - 스토어 스크린샷 생성
- [앱스토어 제출 정보](deployment/APP_STORE_SUBMISSION_INFO.md) - 제출 체크리스트
- [앱스토어 제품 디자인](deployment/APP_STORE_PRODUCTS_DESIGN.md) - 인앱 상품 디자인
- [Google Play 제출](deployment/GOOGLE_PLAY_SUBMISSION_GUIDE.md) - 구글 플레이 제출 가이드

### 보안 & 키 관리
- [API 키 로테이션 가이드](deployment/API_KEY_ROTATION_GUIDE.md) - API 키 보안 관리

---

## 🛠 개발 도구 & 자동화 (development/)

### JIRA 자동화
- [CLAUDE 자동화 가이드](development/CLAUDE_AUTOMATION.md) ⭐️ - JIRA 자동화 및 워크플로우
- [Git + JIRA 워크플로우](development/GIT_JIRA_WORKFLOW.md) - Git과 JIRA 통합
- [JIRA 설정](development/JIRA_CONFIG.md) - JIRA 프로젝트 설정
- [UX 요청 처리 가이드](development/UX_REQUEST_GUIDE.md) - UX 피드백 자동 처리

> **Note**: 일부 개발 추적 문서들(ALL_FILES_LIST, DEPENDENCY_TRACE 등)은 `development/_archive/`로 이동되었습니다.

### MCP & Agent
- [MCP 설정 가이드](development/MCP_SETUP_GUIDE.md) - Model Context Protocol 서버 설정

### Fortune API 개발
- [API 개발 체크리스트](development/FORTUNE_API_DEVELOPMENT_CHECKLIST.md) - Fortune API 개발 가이드
- [표준화 가이드](development/FORTUNE_STANDARDIZATION_GUIDE.md) - 운세 기능 표준화
- [상태 매핑](development/FORTUNE_STATUS_MAPPING.md) - 운세 상태 코드 매핑
- [UX 개선](development/FORTUNE_UX_IMPROVEMENTS.md) - 운세 UX 개선 가이드

---

## ✨ 기능 기획 (features/)

- [셀럽 아바타 시스템](features/CELEBRITY_AVATAR_SYSTEM_PLAN.md) - Notion 스타일 아바타 생성 시스템 기획 (구 plan.md)

---

## ⚖️ 법률 & 정책 (legal/)

- [개인정보 처리방침](legal/PRIVACY_POLICY_CONTENT.md) - 앱 개인정보 처리방침 전문
- [서비스 이용약관](legal/TERMS_OF_SERVICE_CONTENT.md) - 서비스 이용약관 전문

---

## 🛠 문제 해결 (troubleshooting/)

- [406 에러 수정 가이드](troubleshooting/FIX_406_ERROR_GUIDE.md) - HTTP 406 에러 해결 방법
- [MBTI 404 에러 수정](troubleshooting/FIX_MBTI_404_GUIDE.md) - MBTI 페이지 404 에러 해결 가이드
- [DB 수정 가이드](troubleshooting/DB_FIX_INSTRUCTIONS.md) - 긴급 DB 수정 절차

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

### 2025-12-22: 2차 문서 정리 (Orphan/중복 해소)
- **Orphan 해소**: 21개 고아 문서를 인덱스에 연결
- **중복 제거**: IOS_LAUNCH_GUIDE, APP_STORE_FINAL_CHECKLIST 등 중복 문서 삭제
- **아카이브**: LUCKY_POUCH_IMAGE_PROMPTS → design/_archive/
- **이동**: APP_STORE_PRODUCTS_DESIGN → deployment/
- **섹션 확장**: deployment, development, legal 섹션 확장

### 2025-12-07: 문서 정리 및 구조화
- **루트 정리**: 루트에 흩어져 있던 `plan.md` 및 가이드 파일들을 관련 폴더로 이동
- **Features 추가**: 기능 기획 문서 전용 `features/` 폴더 신설
- **Troubleshooting 통합**: 에러 수정 가이드들을 `troubleshooting/` 폴더로 통합
- **Deployment/Design 통합**: 관련 문서들을 각 카테고리로 정리

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