# 🔗 Git-JIRA 완전 자동화 워크플로우

## 🎯 **더 이상 매번 푸시할 필요 없어요!**

이제 **한 번의 명령어**로 Git 커밋 + JIRA 업데이트가 동시에 됩니다! 🚀

---

## 📋 **3가지 워크플로우 옵션**

### 1️⃣ **자동 연동 스크립트 (추천!)**

```bash
# 기본 사용법
./scripts/git_jira_commit.sh "커밋 메시지" "JIRA이슈번호" [상태]

# 작업 중인 이슈에 진행사항 업데이트
./scripts/git_jira_commit.sh "폰트 크기 16px로 조정" "KAN-39" "in-progress"

# 작업 완료 시 자동으로 JIRA 이슈도 Done으로 변경
./scripts/git_jira_commit.sh "UserProfile null 이슈 완전 해결" "KAN-15" "done"

# 단순 코드 변경사항 기록
./scripts/git_jira_commit.sh "코드 리팩토링 및 주석 추가" "KAN-39"
```

### 2️⃣ **일반 Git 커밋 (수동)**

```bash
# 평소처럼 커밋하되 JIRA 이슈 번호만 포함
git commit -m "fix: UserProfile null 이슈 해결 KAN-15"
git commit -m "feat: 메인 화면 폰트 크기 조정 KAN-39"
git push origin main

# 그 다음 JIRA에서 수동으로 상태 변경
```

### 3️⃣ **Claude Code를 통한 자동화**

```
"KAN-39 폰트 크기 작업 완료했어요. Git 커밋하고 JIRA도 Done으로 바꿔주세요."
```

---

## 🔥 **자동 연동 스크립트 상세 기능**

### ✨ **자동으로 실행되는 작업들**

1. **Git 커밋 생성** 📝
2. **JIRA 이슈에 커밋 정보 자동 추가** 🔗
3. **GitHub 커밋 링크 자동 연결** 🌐
4. **JIRA 상태 자동 변경** (선택사항) ⚡
5. **타임스탬프 자동 기록** ⏰

### 📊 **상태 옵션**

| 상태 | 효과 | 사용 시점 |
|------|------|----------|
| `done` | 이슈를 **Done**으로 변경 | 작업 완전 완료 |
| `in-progress` | 이슈를 **In Progress**로 변경 | 작업 진행 중 |
| `comment` (기본값) | 커밋 정보만 추가 | 단순 업데이트 |

### 🎨 **실제 JIRA에 추가되는 내용**

```
✅ 해결 완료

UserProfile null 이슈 완전 해결

🔗 GitHub 커밋: https://github.com/injooinjoo/fortune/commit/abc123...
📂 브랜치: main
⏰ 완료 시간: 2025-09-27 17:30:15
```

---

## 📝 **실제 사용 예시**

### 🐛 **버그 수정 플로우**

```bash
# 1. 버그 발견 → JIRA 이슈 자동 생성 (이미 구축됨)
# 2. 코드 수정 후 커밋 + JIRA 업데이트
./scripts/git_jira_commit.sh "UserProfile 캐시 로딩 시 null 이슈 해결" "KAN-15" "done"

# 결과:
# ✅ Git 커밋 성공!
# ✅ JIRA 이슈 KAN-15가 Done으로 변경되었습니다!
# 🔗 JIRA 이슈: https://beyond-app.atlassian.net/browse/KAN-15
# 🔗 GitHub 커밋: https://github.com/injooinjoo/fortune/commit/abc123...
```

### 🎨 **UX 개선 플로우**

```bash
# 1. UX 요청 생성
./scripts/create_ux_request.sh "메인 폰트 크기 조정" "가독성 개선을 위해 16px로 변경" "font"

# 2. 작업 진행 업데이트
./scripts/git_jira_commit.sh "폰트 크기 14px → 16px 변경" "KAN-39" "in-progress"

# 3. 완료 처리
./scripts/git_jira_commit.sh "폰트 크기 조정 완료 및 테스트 확인" "KAN-39" "done"
```

### ⚡ **빠른 수정 플로우**

```bash
# 간단한 수정사항 - 커밋만 하고 JIRA는 코멘트로
./scripts/git_jira_commit.sh "타이포 수정 및 코드 정리" "KAN-39"
```

---

## 🚀 **추가 자동화 기능**

### 📱 **Claude Code 통합**

Claude Code에게 다음과 같이 요청하면 **자동으로 실행**됩니다:

```
✅ "폰트 작업 끝났어요. KAN-39 완료 처리해주세요."
✅ "버그 고쳤습니다. KAN-15 커밋하고 완료로 바꿔주세요."
✅ "코드 정리했어요. KAN-39에 업데이트 해주세요."
```

### 🔄 **자동 푸시 (선택사항)**

스크립트를 수정하여 자동 푸시도 가능:

```bash
# git_jira_commit.sh 끝에 추가 가능
git push origin main
```

---

## 📊 **장점 요약**

### ✅ **이전: 번거로운 수동 작업**
1. 코드 수정
2. Git 커밋
3. GitHub 푸시
4. JIRA 열어서 이슈 찾기
5. 상태 변경
6. 코멘트 추가
7. 링크 복사/붙여넣기

### 🚀 **지금: 한 줄 명령어**
```bash
./scripts/git_jira_commit.sh "작업 완료" "KAN-39" "done"
```
**끝!** 🎉

---

## 🛠️ **고급 설정 (선택사항)**

### 📌 **Git Alias 설정**

더 간편하게 사용하려면:

```bash
# ~/.gitconfig에 추가
[alias]
  jira = "!f() { ./scripts/git_jira_commit.sh \"$1\" \"$2\" \"$3\"; }; f"

# 사용법
git jira "작업 완료" "KAN-39" "done"
```

### 🔔 **알림 설정**

Slack이나 이메일 알림도 추가 가능합니다.

---

## ❓ **자주 묻는 질문**

### Q: 매번 푸시해야 하나요?
**A:** 아니요! 스크립트가 커밋까지만 하고, 원하면 푸시는 나중에 일괄로 해도 됩니다.

### Q: JIRA 이슈가 없으면 어떻게 하나요?
**A:** 먼저 UX 요청 스크립트로 이슈를 생성하세요:
```bash
./scripts/create_ux_request.sh "제목" "내용" "카테고리"
```

### Q: 실수로 잘못 커밋했으면?
**A:** Git은 평소대로 되돌리고, JIRA는 수동으로 코멘트나 상태를 조정하면 됩니다.

---

## 🎉 **결론**

**이제 개발 → 커밋 → JIRA 업데이트가 원클릭으로 가능합니다!**

더 이상 여러 사이트를 오가며 수동으로 관리할 필요 없어요. 😎