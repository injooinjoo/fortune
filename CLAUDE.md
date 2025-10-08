# Fortune Flutter App - Claude Code 개발 규칙

## 🚫 **FLUTTER 실행 금지 규칙 (CRITICAL)** 🚫

**Claude는 절대로 Flutter를 직접 실행하지 않습니다!**

### ❌ 금지 명령어
```bash
flutter run
flutter run --release
flutter run -d [device-id]
```

### ✅ 올바른 워크플로우
1. **Claude**: 코드 수정 완료 후 "Flutter를 실행해서 테스트해주세요" 요청
2. **사용자**: 직접 `flutter run --release -d 00008140-00120304260B001C` 실행
3. **사용자**: 로그를 Claude에게 전달
4. **Claude**: 로그를 분석하고 문제 해결

**이유**: Claude가 Flutter를 실행하면 로그를 제대로 확인할 수 없어 디버깅이 불가능합니다.

---

## 🤖 **필수 자동화 워크플로우** - 절대 건너뛰지 말 것! 🤖

### 🔴 **JIRA 등록 최우선 원칙 (CRITICAL RULE)**

**모든 개발 작업은 반드시 JIRA 티켓 생성부터 시작합니다!**

```
잘못된 순서 ❌:
사용자: "버튼 색상 바꿔줘"
→ 바로 코드 수정 시작 (WRONG!)

올바른 순서 ✅:
사용자: "버튼 색상 바꿔줘"
→ 1️⃣ JIRA 티켓 생성 (parse_ux_request.sh)
→ 2️⃣ 티켓 번호 확인 (예: KAN-123)
→ 3️⃣ 코드 수정 시작
→ 4️⃣ 완료 후 JIRA 완료 처리 (git_jira_commit.sh)
```

### 📋 **1단계: JIRA 티켓 자동 생성 (필수 선행)**

사용자의 다음 표현을 감지하면 **코드 작업 전에 반드시** `./scripts/parse_ux_request.sh` 실행:

**문제 관련**:
- **버그**: "버그", "에러", "오류", "안돼", "작동안해", "깨져", "이상해"
- **불만**: "문제야", "짜증", "불편해", "답답해"
- **성능**: "느려", "버벅여", "멈춰", "렉", "끊겨"

**개선 관련**:
- **기능**: "~하면 좋겠어", "추가해줘", "만들어줘", "구현해줘"
- **수정**: "바꿔줘", "고쳐줘", "수정해줘", "개선해줘"
- **UX**: "사용하기 어려워", "터치하기 어려워", "보기 힘들어", "불편해"
- **디자인**: "폰트", "색상", "크기", "간격", "레이아웃", "애니메이션", "디자인"

**JIRA 생성 명령어**:
```bash
./scripts/parse_ux_request.sh
```

### 2️⃣ **2단계: 개발 작업 진행**

JIRA 티켓이 생성된 후에만 코드 작업을 시작합니다.

### ✅ **3단계: JIRA 완료 처리 (필수)**

코드 수정 완료 시 **반드시** `./scripts/git_jira_commit.sh "해결내용" "JIRA번호" "done"` 실행

**완료 처리 명령어**:
```bash
./scripts/git_jira_commit.sh "버튼 색상을 TOSS 디자인 시스템으로 변경" "KAN-123" "done"
```

### 📝 **완전한 워크플로우 예시**

```
사용자: "홈 화면이 너무 느려"

Claude Code 동작:
→ 1️⃣ [자동] JIRA 등록 먼저!
   $ ./scripts/parse_ux_request.sh
   ✅ KAN-124 생성됨: "홈 화면 성능 개선"

→ 2️⃣ "JIRA KAN-124가 생성되었습니다. 이제 코드 수정을 시작합니다."

→ 3️⃣ [코드 수정 작업]
   - 홈 화면 로딩 최적화
   - 불필요한 리빌드 제거
   - 이미지 캐싱 추가

→ 4️⃣ [완료 처리]
   $ ./scripts/git_jira_commit.sh "홈 화면 로딩 최적화 완료" "KAN-124" "done"
   ✅ Git 커밋 완료
   ✅ JIRA 완료 처리

→ 5️⃣ "해결 완료! JIRA KAN-124도 완료 처리했습니다."
```

### 🚫 **절대 하지 말아야 할 것**

❌ JIRA 등록 없이 바로 코드 수정
❌ "나중에 JIRA 등록하지" 하고 코드부터 수정
❌ 작은 수정이라고 JIRA 건너뛰기
❌ JIRA 생성했는데 완료 처리 안하기

**모든 작업은 JIRA에 기록되어야 합니다!**

## 🚨 절대 금지 사항 - CRITICAL RULES 🚨

### ❌ 일괄 수정 절대 금지 (NEVER USE BATCH MODIFICATIONS)
**이 규칙을 어기면 프로젝트가 망가집니다!**

1. **Python 스크립트를 사용한 일괄 수정 금지**
   - `for file in files:` 형태의 일괄 처리 스크립트 작성 금지
   - 여러 파일을 한번에 수정하는 Python 스크립트 절대 사용 금지

2. **Shell 스크립트를 사용한 일괄 수정 금지**
   - `sed -i`, `awk`, `perl` 등을 사용한 일괄 치환 금지
   - `for` 루프를 사용한 여러 파일 동시 수정 금지
   - `grep | xargs` 조합으로 여러 파일 수정 금지

3. **정규식 일괄 치환 금지**
   - IDE의 "Replace All in Files" 기능 사용 금지
   - 정규식 패턴으로 여러 파일 동시 수정 금지

### ✅ 올바른 수정 방법 (CORRECT MODIFICATION METHOD)
**반드시 하나씩 수정해야 합니다:**
1. 한 파일씩 열어서 확인
2. 해당 파일의 컨텍스트 이해
3. 필요한 부분만 정확히 수정
4. 수정 후 해당 파일 검증
5. 다음 파일로 이동

### 🔴 위반 시 결과 (CONSEQUENCES OF VIOLATION)
- 프로젝트 전체가 빌드 불가능한 상태가 됨
- 수많은 연쇄 에러 발생
- 복구에 몇 시간 소요
- Git 히스토리 오염

**"일괄수정안할거야. 하나씩해" - 이것이 철칙입니다!**

---

## 🚀 앱 개발 완료 후 필수 작업 (CRITICAL - ALWAYS DO THIS!)

### 📱 **실제 디바이스 자동 배포 (기본값)**

**모든 수정 작업 완료 후 반드시 실제 디바이스에 릴리즈 빌드를 자동으로 배포합니다!**

#### ✅ 표준 배포 명령어 (기본값)
```bash
flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_release_logs.txt
```

**이 명령어가 하는 일**:
- `--release`: 최적화된 릴리즈 빌드 생성 (프로덕션 환경)
- `-d 00008140-00120304260B001C`: 실제 iPhone 디바이스에 설치
- `2>&1 | tee /tmp/flutter_release_logs.txt`: 로그를 파일과 화면에 동시 출력

#### 🔄 개발 중 빠른 테스트 (시뮬레이터)
개발 중에는 시뮬레이터에서 빠르게 테스트할 수 있습니다:

```bash
# 1. 기존 Flutter 프로세스 종료
pkill -f flutter

# 2. 빌드 캐시 정리
flutter clean

# 3. 의존성 재설치
flutter pub get

# 4. 시뮬레이터에서 앱 삭제
xcrun simctl uninstall 1B54EF52-7E41-4040-A236-C169898F5527 com.beyond.fortune

# 5. 앱 새로 빌드 및 실행 (시뮬레이터)
flutter run -d 1B54EF52-7E41-4040-A236-C169898F5527
```

#### 📋 배포 체크리스트

**수정 작업 완료 시 반드시 실행:**
1. ✅ 코드 수정 완료
2. ✅ `flutter analyze` 실행 (에러 없는지 확인)
3. ✅ **실제 디바이스에 릴리즈 빌드 배포** (기본값!)
   ```bash
   flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_release_logs.txt
   ```
4. ✅ 실제 디바이스에서 변경사항 검증
5. ✅ JIRA 완료 처리 (git_jira_commit.sh)

**⚠️ 중요**: Hot Restart나 Hot Reload로는 변경사항이 제대로 반영되지 않을 수 있습니다!

## Flutter 개발 워크플로우

1. **코드 수정 및 개발**
2. **Hot Reload로 빠른 테스트** (`r` 키)
3. **개발 완료 후 Hot Restart로 전체 검증** (`R` 키)
4. **최종 확인 완료**

## 검증 포인트

### 🚀 앱 시작 플로우
- 스플래시 화면 → 로그인 상태 확인 → 적절한 페이지 라우팅
- 로그인 안 된 경우: LandingPage(시작하기 버튼) 표시
- 로그인 된 경우: 프로필 상태에 따라 onboarding 또는 home 이동

### 🔐 인증 플로우
- 소셜 로그인 (Google, Apple, Kakao, Naver)
- 로그인 상태에 따른 UI 변화
- "오늘의 이야기가 완성되었어요!" 화면은 미로그인 사용자만 표시

### 📱 핵심 기능
- 운세 생성 및 표시
- 사용자 프로필 관리
- 온보딩 플로우

## 개발 시 주의사항

- 로그인 상태와 관계없이 모든 플로우가 정상 작동하는지 확인
- 프로필 완성도에 따른 라우팅 로직 검증
- Hot Restart 후 초기 상태에서의 동작 확인

---

## 📚 문서 관리 정책

### 📂 문서 위치 원칙

**모든 프로젝트 문서는 `docs/` 폴더에서 관리합니다.**

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

**루트 레벨 문서는 2개만 유지**:
- `README.md` - 프로젝트 소개 및 진입점
- `CLAUDE.md` - Claude Code 개발 규칙 (이 파일)

---

### 📌 빠른 문서 탐색

**작업 시작 전 항상 [docs/README.md](docs/README.md) 확인!**

#### 주제별 폴더 구조

| 작업 유형 | 폴더 | 주요 문서 |
|----------|------|----------|
| 🚀 **프로젝트 시작** | `docs/getting-started/` | PROJECT_OVERVIEW.md, SETUP_GUIDE.md |
| 🎨 **UI 개발** | `docs/design/` | TOSS_DESIGN_SYSTEM.md ⭐️, WIDGET_ARCHITECTURE_DESIGN.md |
| 💾 **DB 작업** | `docs/data/` | DATABASE_GUIDE.md ⭐️, API_USAGE.md |
| 📱 **네이티브 기능** | `docs/native/` | NATIVE_FEATURES_GUIDE.md ⭐️, WATCH_COMPANION_APPS_GUIDE.md |
| 🧪 **테스트** | `docs/testing/` | AB_TESTING_GUIDE.md ⭐️, TESTING_GUIDE.md |
| 🚢 **배포** | `docs/deployment/` | DEPLOYMENT_COMPLETE_GUIDE.md ⭐️, APP_STORE_GUIDE.md ⭐️, SECURITY_CHECKLIST.md |
| 🛠 **개발 자동화** | `docs/development/` | CLAUDE_AUTOMATION.md ⭐️, GIT_JIRA_WORKFLOW.md, MCP_SETUP_GUIDE.md |
| ⚖️ **법률/정책** | `docs/legal/` | PRIVACY_POLICY_CONTENT.md |
| 🐛 **문제 해결** | `docs/troubleshooting/` | FIX_406_ERROR_GUIDE.md |

**⭐️ 표시**: 여러 문서를 통합한 최신 통합 가이드

---

### 🎯 작업별 문서 찾기 가이드

**프로젝트 시작**:
1. [docs/README.md](docs/README.md) 열기
2. `getting-started/` 폴더로 이동
3. PROJECT_OVERVIEW.md → SETUP_GUIDE.md 순서로 읽기

**UI 컴포넌트 개발**:
1. `docs/design/` 폴더 확인
2. 새 컴포넌트 → TOSS_DESIGN_SYSTEM.md에서 패턴 찾기
3. 위젯 설계 → WIDGET_ARCHITECTURE_DESIGN.md 참고

**데이터베이스 작업**:
1. `docs/data/` 폴더 확인
2. DATABASE_GUIDE.md에서 스키마/RLS/마이그레이션 확인
3. API 호출 → API_USAGE.md 패턴 참고

**배포 준비**:
1. `docs/deployment/` 폴더 확인
2. DEPLOYMENT_COMPLETE_GUIDE.md로 전체 프로세스 파악
3. APP_STORE_GUIDE.md로 스토어 등록
4. SECURITY_CHECKLIST.md로 보안 검증

**JIRA 자동화**:
1. `docs/development/` 폴더 확인
2. CLAUDE_AUTOMATION.md로 워크플로우 이해
3. GIT_JIRA_WORKFLOW.md로 Git 통합 확인

---

### 📝 문서 관리 규칙

#### ✅ DO (해야 할 것)
- 새 문서는 반드시 `docs/` 하위 적절한 폴더에 생성
- docs/README.md에 새 문서 추가 시 색인 업데이트
- 통합 가이드 (⭐️) 우선 참고
- 주제별 폴더 구조 유지

#### ❌ DON'T (하지 말아야 할 것)
- 프로젝트 루트에 새 문서 생성 금지
- 중복 문서 생성 금지 (기존 문서 업데이트)
- 개인 메모나 임시 파일 docs/에 커밋 금지
- 문서 이동 시 링크 업데이트 누락 금지

---

### 🔍 문서 검색 팁

1. **전체 검색**: `docs/README.md`에서 키워드로 Ctrl+F
2. **카테고리 검색**: 작업 유형에 맞는 폴더로 직접 이동
3. **통합 문서 우선**: ⭐️ 표시 문서가 가장 최신이고 완전함
4. **크로스 레퍼런스**: 각 문서 하단의 "관련 문서" 섹션 확인

---

## 🧹 미사용 스크린 자동 정리 시스템

### 📊 시스템 개요

Flutter 프로젝트의 `lib/screens/` 폴더에 있는 화면 파일들을 자동으로 분석하고,
실제로 사용되지 않는 화면을 탐지하여 정리하는 자동화 시스템입니다.

**주요 구성 요소:**
1. **정적 분석 도구** (`tools/screen_analyzer.dart`)
2. **런타임 추적** (`lib/core/utils/route_observer_logger.dart`)
3. **자동 정리 스크립트** (`scripts/cleanup_unused_screens.sh`)
4. **Pre-commit 훅** (`scripts/pre-commit-screen-check.sh`)

---

### 🔍 1. 정적 분석 도구 사용법

**기본 실행:**
```bash
dart run tools/screen_analyzer.dart
```

**JSON 결과 저장:**
```bash
dart run tools/screen_analyzer.dart --output analysis.json
```

**분석 항목:**
- ✅ GoRouter에 등록된 화면 (`route_config.dart`, 서브 라우트 파일)
- ✅ MaterialPageRoute로 동적 생성되는 화면
- ✅ showDialog, showBottomSheet로 사용되는 다이얼로그
- ✅ 다른 화면에서 위젯으로 참조되는 컴포넌트

**출력 예시:**
```
📊 분석 결과:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
총 스크린 클래스: 29개
사용 중인 스크린: 29개
미사용 스크린: 0개
위젯 컴포넌트: 23개

🧩 위젯 컴포넌트 (screens/ → widgets/ 이동 고려):
  - TossNumberPad (lib/screens/onboarding/widgets/toss_number_pad.dart)
  - PaymentConfirmationDialog (lib/screens/payment/payment_confirmation_dialog.dart)
```

---

### 📝 2. 런타임 화면 방문 추적

**자동 활성화:** 디버그 모드에서 자동으로 활성화됩니다.

**방문 기록 확인:**
```bash
cat visited_screens.json
```

**기록 내용:**
```json
{
  "last_updated": "2025-01-06T10:30:00Z",
  "total_screens": 15,
  "total_visits": 142,
  "visits": [
    {
      "screen_name": "HomeScreen",
      "route_name": "/home",
      "first_visit": "2025-01-06T09:00:00Z",
      "last_visit": "2025-01-06T10:25:00Z",
      "visit_count": 45
    }
  ]
}
```

**활용 방법:**
- 실제 사용 패턴 분석
- 정적 분석으로 놓친 화면 발견
- 인기 있는 화면 파악

---

### 🚚 3. 자동 정리 스크립트

**시뮬레이션 (실제 이동 없음):**
```bash
./scripts/cleanup_unused_screens.sh --dry-run
```

**실제 실행 (확인 프롬프트 있음):**
```bash
./scripts/cleanup_unused_screens.sh
```

**자동 실행 (확인 없음):**
```bash
./scripts/cleanup_unused_screens.sh --auto
```

**스크립트 동작:**
1. `screen_analyzer.dart` 실행하여 미사용 화면 탐지
2. 사용자 확인 요청 (--auto가 아닐 때)
3. 백업 브랜치 자동 생성 (`backup/unused-screens-cleanup-YYYYMMDD-HHMMSS`)
4. `lib/screens_unused/` 폴더로 파일 이동 (git mv 사용)
5. `flutter analyze` 실행하여 에러 체크
6. 에러 발생 시 자동 롤백 (`git restore`)
7. 성공 시 커밋 가이드 출력

**안전 장치:**
- ✅ 백업 브랜치 자동 생성
- ✅ git mv로 이동 (히스토리 보존)
- ✅ flutter analyze 자동 검증
- ✅ 에러 시 즉시 롤백

---

### 🎯 4. Pre-commit 훅 (선택사항)

**설치:**
```bash
ln -sf ../../scripts/pre-commit-screen-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**동작:**
- `lib/screens/`에 새 화면 파일 커밋 시 자동 체크
- GoRouter에 라우트 등록 여부 확인
- 경고 메시지 출력 (커밋은 차단하지 않음)

**출력 예시:**
```
🔍 Pre-commit: 새 화면 라우트 등록 체크
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 새로 추가된 스크린 파일:
  ✓ lib/screens/new_feature_screen.dart

⚠️  경고: 다음 화면이 라우트에 등록되지 않았을 수 있습니다
  - NewFeatureScreen (lib/screens/new_feature_screen.dart)

💡 lib/routes/route_config.dart에 GoRoute를 추가하거나,
   위젯 컴포넌트라면 lib/core/widgets/로 이동하세요
```

---

### 💡 권장 워크플로우

**월 1회 정기 정리:**
```bash
# 1. 정적 분석 실행
dart run tools/screen_analyzer.dart

# 2. 분석 결과 검토
cat screen_analysis_result.json

# 3. 시뮬레이션으로 미리보기
./scripts/cleanup_unused_screens.sh --dry-run

# 4. 실제 정리 실행
./scripts/cleanup_unused_screens.sh

# 5. 앱 테스트 후 커밋
./scripts/git_jira_commit.sh "Remove unused screens" "KAN-XX" "done"
```

**새 화면 추가 시:**
1. `lib/screens/`에 화면 파일 작성
2. `lib/routes/route_config.dart`에 라우트 등록
3. Pre-commit 훅이 자동 체크 (설치된 경우)
4. 커밋 전 경고 메시지 확인

---

### 🔧 문제 해결

**"미사용으로 표시되는데 실제로 사용 중"인 경우:**
- MaterialPageRoute, showDialog 등 동적 패턴 사용 여부 확인
- `visited_screens.json`에서 런타임 방문 기록 확인
- 필요시 `screen_analyzer.dart` 패턴 추가

**롤백이 필요한 경우:**
```bash
# 백업 브랜치로 복구
git restore .
git checkout backup/unused-screens-cleanup-YYYYMMDD-HHMMSS
```

**Pre-commit 훅 제거:**
```bash
rm .git/hooks/pre-commit
```

---

이 파일은 Claude Code가 이 프로젝트에서 작업할 때 자동으로 참조하는 개발 규칙입니다.