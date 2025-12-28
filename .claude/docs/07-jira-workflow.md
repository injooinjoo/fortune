# JIRA MCP 워크플로우 가이드

## 개요

Fortune App의 모든 개발 작업은 **JIRA MCP를 통한 자동 이슈 관리**로 진행합니다.

---

## 자동 워크플로우

### 1. 이슈 생성 (작업 시작 시)

모든 개발 요청 감지 시 자동 실행:

```
jira_post /rest/api/3/issue
{
  "fields": {
    "project": { "key": "FORT" },
    "summary": "[요청 내용 요약]",
    "issuetype": { "name": "[Bug|Task|Story]" },
    "description": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{ "type": "text", "text": "[상세 설명]" }]
      }]
    }
  }
}
```

**결과**: `📋 FORT-XXX 생성됨`

---

### 2. 이슈 종료 (작업 완료 시)

코드 수정 완료 후 자동 실행:

```
# 상태 전환
jira_post /rest/api/3/issue/FORT-XXX/transitions
{
  "transition": { "id": "31" }  // Done 상태 ID
}

# 해결 코멘트 추가
jira_post /rest/api/3/issue/FORT-XXX/comment
{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [{
      "type": "paragraph",
      "content": [{ "type": "text", "text": "[해결 내용]" }]
    }]
  }
}
```

**결과**: `✅ FORT-XXX 종료됨`

---

## 이슈 타입 판단 규칙

| 키워드 | 이슈 타입 | 예시 |
|--------|----------|------|
| 버그, 에러, 오류, 안됨, 깨짐, 이상해 | Bug | "로딩이 안돼요" |
| 추가, 만들어줘, 새로운, 구현해줘 | Story | "새 기능 추가해줘" |
| 수정, 바꿔줘, 개선, 고쳐줘 | Task | "색상 바꿔줘" |

---

## MCP 명령어 참조

### 이슈 조회
```
jira_get /rest/api/3/issue/FORT-XXX
```

### 프로젝트 조회
```
jira_get /rest/api/3/project
```

### 트랜지션 조회 (상태 변경용 ID 확인)
```
jira_get /rest/api/3/issue/FORT-XXX/transitions
```

### 이슈 검색
```
jira_get /rest/api/3/search/jql
queryParams: { "jql": "project=FORT AND status!=Done" }
```

---

## 프로젝트 정보

| 항목 | 값 |
|------|-----|
| 프로젝트 키 | FORT |
| JIRA 도메인 | beyond-app.atlassian.net |
| 사용자 | injooinjoo@gmail.com |

---

## 금지 사항

❌ JIRA 등록 없이 바로 코드 수정
❌ 작업 완료 후 JIRA 종료 처리 안함
❌ 기존 스크립트 방식 사용 (parse_ux_request.sh, git_jira_commit.sh)

**모든 작업은 MCP를 통해 JIRA에 자동 기록됩니다!**

---

## Git 커밋 규칙

### 커밋 메시지 형식

```
[FORT-XXX] 작업유형: 변경 내용

예시:
[FORT-123] fix: 버튼 색상 변경
[FORT-124] feat: 홈 화면 캐싱 추가
[FORT-125] refactor: 운세 서비스 코드 정리
```

### 작업 유형

| 타입 | 설명 |
|------|------|
| feat | 새로운 기능 추가 |
| fix | 버그 수정 |
| refactor | 코드 리팩토링 |
| style | 코드 스타일 변경 |
| docs | 문서 수정 |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 등 기타 |

---

## 관련 문서

- [CLAUDE.md](/CLAUDE.md) - 메인 가이드
- [01-core-rules.md](01-core-rules.md) - 핵심 개발 규칙