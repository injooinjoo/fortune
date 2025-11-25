# JIRA & Git 워크플로우 가이드

## 개요

Fortune App의 모든 개발 작업은 **JIRA 티켓 생성부터 시작**합니다.

---

## JIRA 등록 최우선 원칙

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

---

## 워크플로우 3단계

### 1단계: JIRA 티켓 자동 생성 (필수 선행)

사용자의 다음 표현을 감지하면 **코드 작업 전에 반드시** 실행:

#### 트리거 키워드

**문제 관련**:
- **버그**: "버그", "에러", "오류", "안돼", "작동안해", "깨져", "이상해"
- **불만**: "문제야", "짜증", "불편해", "답답해"
- **성능**: "느려", "버벅여", "멈춰", "렉", "끊겨"

**개선 관련**:
- **기능**: "~하면 좋겠어", "추가해줘", "만들어줘", "구현해줘"
- **수정**: "바꿔줘", "고쳐줘", "수정해줘", "개선해줘"
- **UX**: "사용하기 어려워", "터치하기 어려워", "보기 힘들어", "불편해"
- **디자인**: "폰트", "색상", "크기", "간격", "레이아웃", "애니메이션", "디자인"

#### 실행 명령어

```bash
./scripts/parse_ux_request.sh
```

---

### 2단계: 개발 작업 진행

JIRA 티켓이 생성된 후에만 코드 작업을 시작합니다.

---

### 3단계: JIRA 완료 처리 (필수)

코드 수정 완료 시 **반드시** 실행:

```bash
./scripts/git_jira_commit.sh "해결내용" "JIRA번호" "done"
```

**예시**:
```bash
./scripts/git_jira_commit.sh "버튼 색상을 TOSS 디자인 시스템으로 변경" "KAN-123" "done"
```

---

## 완전한 워크플로우 예시

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

---

## 금지 사항

❌ JIRA 등록 없이 바로 코드 수정
❌ "나중에 JIRA 등록하지" 하고 코드부터 수정
❌ 작은 수정이라고 JIRA 건너뛰기
❌ JIRA 생성했는데 완료 처리 안하기

**모든 작업은 JIRA에 기록되어야 합니다!**

---

## Git 커밋 규칙

### 커밋 메시지 형식

```
[JIRA번호] 작업 유형: 변경 내용

예시:
[KAN-123] fix: 버튼 색상 변경
[KAN-124] feat: 홈 화면 캐싱 추가
[KAN-125] refactor: 운세 서비스 코드 정리
```

### 작업 유형

| 타입 | 설명 |
|------|------|
| feat | 새로운 기능 추가 |
| fix | 버그 수정 |
| refactor | 코드 리팩토링 |
| style | 코드 스타일 변경 (동작 변경 없음) |
| docs | 문서 수정 |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 등 기타 작업 |

---

## 스크립트 위치

| 스크립트 | 파일 경로 | 용도 |
|----------|----------|------|
| JIRA 생성 | `scripts/parse_ux_request.sh` | 사용자 요청 파싱 후 JIRA 티켓 생성 |
| Git 커밋 | `scripts/git_jira_commit.sh` | Git 커밋 + JIRA 상태 업데이트 |

---

## 관련 문서

- [01-core-rules.md](01-core-rules.md) - 핵심 개발 규칙
- [docs/development/CLAUDE_AUTOMATION.md](/docs/development/CLAUDE_AUTOMATION.md) - Claude 자동화
- [docs/development/GIT_JIRA_WORKFLOW.md](/docs/development/GIT_JIRA_WORKFLOW.md) - Git 통합 상세

