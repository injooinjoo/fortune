# MCP 서버 설정 가이드

Fortune 앱 개발을 위한 MCP(Model Context Protocol) 서버 설정 가이드입니다.

## 📊 현재 연결된 MCP 서버 (11개)

### ✅ 완전 자동화 (설정 불필요, 6개)

1. **Playwright** - E2E 테스팅, 브라우저 자동화
2. **Supabase** - DB 직접 접근 (이미 설정 완료)
3. **Context7** - 라이브러리 공식 문서 검색
4. **Sequential Thinking** - 복잡한 문제 다단계 분석
5. **Memory** - 세션 간 컨텍스트 유지
6. **Filesystem** - Fortune 프로젝트 파일 시스템 접근

### 🔐 수동 설정 필요 (API 키 필요, 5개)

7. **JIRA** - 티켓 자동 생성/관리 (이미 설정 완료)
8. **GitHub** - PR/Issue 자동화 (⚠️ 토큰 필요)
9. **Firebase** - Analytics, A/B Testing, Remote Config
10. **Slack** - 알림 및 팀 협업 (⚠️ 토큰 필요)
11. **Figma** - 디자인 시스템 연동

---

## 🔧 수동 설정이 필요한 MCP 서버

### 1. GitHub MCP 설정 (권장)

**왜 필요한가?**
- JIRA와 완벽 통합 (이슈 자동 연동)
- PR 자동 생성 및 리뷰
- 커밋 메시지 자동 생성

**설정 방법**:

#### Step 1: GitHub Personal Access Token 생성
1. GitHub 웹사이트 방문: https://github.com/settings/tokens
2. "Generate new token (classic)" 클릭
3. 이름: `Claude Code MCP - Fortune`
4. 권한 선택:
   - ✅ `repo` (전체 repository 접근)
   - ✅ `workflow` (GitHub Actions 관리)
   - ✅ `read:org` (Organization 정보 읽기)
5. "Generate token" 클릭
6. **토큰 복사** (한 번만 표시됩니다!)

#### Step 2: MCP 설정에 토큰 추가
```bash
# MCP 설정 파일 열기
code ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

`github` 섹션 수정:
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "여기에_복사한_토큰_붙여넣기"
  }
}
```

#### Step 3: Claude Code 재시작
- VSCode 재시작 또는 Command Palette → "Developer: Reload Window"

**사용 예시**:
```
사용자: "버그 수정했으니까 PR 만들어줘"
→ Claude가 자동으로:
  1. JIRA 티켓 확인 (KAN-XXX)
  2. Git 커밋 생성
  3. GitHub PR 자동 생성 (JIRA 링크 포함)
  4. PR 설명 자동 작성
```

---

### 2. Slack MCP 설정 (선택 사항)

**왜 필요한가?**
- 빌드 완료 알림
- 에러 발생 시 팀 알림
- 배포 상태 공유

**설정 방법**:

#### Step 1: Slack App 생성
1. https://api.slack.com/apps 방문
2. "Create New App" 클릭
3. "From scratch" 선택
4. App 이름: `Fortune Bot`
5. Workspace 선택

#### Step 2: Bot Token 및 권한 설정
1. 좌측 메뉴 "OAuth & Permissions" 클릭
2. "Scopes" → "Bot Token Scopes" 섹션에서 권한 추가:
   - `chat:write` - 메시지 전송
   - `channels:read` - 채널 목록 읽기
   - `files:write` - 파일 업로드
3. 페이지 상단 "Install to Workspace" 클릭
4. **Bot User OAuth Token** 복사 (xoxb-로 시작)

#### Step 3: Team ID 확인
1. Slack 웹 열기: https://app.slack.com
2. URL에서 팀 ID 확인: `https://app.slack.com/client/T01234ABC/...`
   - `T01234ABC` 부분이 Team ID

#### Step 4: MCP 설정에 추가
```json
"slack": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-slack"],
  "env": {
    "SLACK_BOT_TOKEN": "xoxb-여기에_Bot_Token_붙여넣기",
    "SLACK_TEAM_ID": "T01234ABC"
  }
}
```

#### Step 5: Claude Code 재시작

**사용 예시**:
```
사용자: "배포 완료되면 슬랙으로 알려줘"
→ Claude가 자동으로:
  1. 배포 완료 대기
  2. #dev-alerts 채널에 메시지 전송
  3. 배포 결과 요약 공유
```

---

### 3. Firebase MCP 설정 (선택 사항)

**왜 필요한가?**
- Firebase Console 수동 확인 불필요
- A/B 테스트 결과 즉시 분석
- Remote Config 자동 업데이트

**설정 방법**:

#### Step 1: Firebase Admin SDK 키 생성
1. Firebase Console 방문: https://console.firebase.google.com
2. 프로젝트 선택: `Fortune`
3. 톱니바퀴 아이콘 → "프로젝트 설정"
4. "서비스 계정" 탭
5. "새 비공개 키 생성" 클릭
6. JSON 파일 다운로드

#### Step 2: 키 파일 저장
```bash
# 안전한 위치에 저장
mkdir -p ~/.config/firebase
mv ~/Downloads/fortune-firebase-adminsdk-xxxxx.json ~/.config/firebase/admin-sdk.json
chmod 600 ~/.config/firebase/admin-sdk.json
```

#### Step 3: MCP 설정 업데이트
```json
"firebase": {
  "command": "npx",
  "args": ["-y", "@google/generative-ai-firebase-tools"],
  "env": {
    "GOOGLE_APPLICATION_CREDENTIALS": "/Users/jacobmac/.config/firebase/admin-sdk.json"
  }
}
```

#### Step 4: Claude Code 재시작

**사용 예시**:
```
사용자: "A/B 테스트 결과 보여줘"
→ Claude가 자동으로:
  1. Firebase A/B Testing 결과 조회
  2. 통계 데이터 분석
  3. 승자 변형 추천
```

---

## 📋 빠른 설정 체크리스트

### 필수 설정 (이미 완료)
- ✅ Playwright
- ✅ Supabase
- ✅ JIRA
- ✅ Context7
- ✅ Sequential Thinking
- ✅ Memory
- ✅ Filesystem

### 권장 설정
- ⬜ GitHub (JIRA 연동 강화)
  - [ ] Personal Access Token 생성
  - [ ] MCP 설정 업데이트
  - [ ] Claude Code 재시작

### 선택 사항
- ⬜ Slack (팀 알림)
  - [ ] Slack App 생성
  - [ ] Bot Token 생성
  - [ ] MCP 설정 업데이트
- ⬜ Firebase (A/B Testing 자동화)
  - [ ] Admin SDK 키 다운로드
  - [ ] 키 파일 저장
  - [ ] MCP 설정 업데이트

---

## 🔍 MCP 서버 동작 확인

### Claude Code 재시작 후:
1. 새 채팅 시작
2. 다음 메시지 입력:
   ```
   MCP 서버 연결 상태 확인해줘
   ```
3. Claude가 자동으로 연결된 MCP 서버 목록 표시

### 연결 문제 해결:
```bash
# MCP 설정 백업 확인
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup

# MCP 로그 확인 (에러 발생 시)
tail -f ~/Library/Logs/Claude/mcp-*.log
```

---

## 🎯 각 MCP 서버 활용 예시

### Playwright
```
"앱 로그인 플로우 E2E 테스트 만들어줘"
```

### Supabase
```
"user_profiles 테이블에 새 컬럼 추가해줘"
```

### JIRA
```
"버튼 색상이 이상해" → 자동 JIRA 티켓 생성
```

### GitHub
```
"이 버그 수정 PR 만들어줘" → 자동 PR 생성
```

### Context7
```
"Flutter에서 Riverpod 상태 관리 베스트 프랙티스 알려줘"
```

### Sequential Thinking
```
"앱 성능 최적화 전략 수립해줘" → 다단계 분석
```

### Memory
```
"지난번에 TOSS 디자인 시스템 어떻게 적용했었지?"
```

### Filesystem
```
"프로젝트 전체에서 미사용 파일 찾아줘"
```

### Firebase
```
"A/B 테스트 결과 분석해줘"
```

### Slack
```
"배포 완료되면 #dev-alerts 채널에 알려줘"
```

---

## 📝 주의사항

### 보안
- ⚠️ API 키/토큰은 **절대** Git에 커밋하지 마세요
- ⚠️ MCP 설정 파일은 로컬에만 저장됩니다
- ⚠️ 팀원과 토큰을 공유하지 마세요 (각자 생성)

### 성능
- 너무 많은 MCP 서버 동시 사용 시 속도 저하 가능
- 필요한 서버만 활성화 권장
- 사용하지 않는 서버는 비활성화:
  ```json
  "disabled_servers": ["slack", "figma"]
  ```

---

## 🆘 문제 해결

### "MCP 서버 연결 실패" 에러
1. Claude Code 완전 재시작
2. MCP 설정 파일 JSON 문법 확인
3. 백업에서 복원:
   ```bash
   cp ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup \
      ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

### GitHub MCP 인증 실패
- Personal Access Token 만료 확인
- 권한(scope) 재확인: `repo`, `workflow`

### Slack MCP 메시지 전송 실패
- Bot Token 확인 (xoxb-로 시작)
- 채널에 Bot 초대 확인: `/invite @Fortune Bot`

---

## 📚 추가 자료

- [MCP 공식 문서](https://modelcontextprotocol.io)
- [Claude Code MCP 가이드](https://docs.anthropic.com/claude/docs/model-context-protocol)
- Fortune 프로젝트 문서: [CLAUDE.md](CLAUDE.md)

---

**백업 위치**: `~/Library/Application Support/Claude/claude_desktop_config.json.backup`

**마지막 업데이트**: 2025-09-30