# Gemini CLI와 MCP 서버 설정 가이드

## 개요

이 가이드는 Gemini CLI와 다양한 MCP(Model Context Protocol) 서버(Supabase, GitHub 등)를 설정하는 방법을 제공합니다. MCP는 AI 도구와 외부 시스템 간의 표준화된 연결을 제공하는 프로토콜입니다.

## 1. Gemini CLI 기본 설정

### 1.1 Gemini API 키 준비
1. [Google AI Studio](https://ai.google.dev/aistudio)에 접속
2. 새로운 API 키 생성
3. 생성된 API 키를 안전한 곳에 보관

### 1.2 Gemini CLI 설정 파일 위치
운영체제별 설정 파일 위치:
- **macOS**: `~/.gemini/settings.json`
- **Windows**: `%APPDATA%\gemini\settings.json`
- **Linux**: `~/.config/gemini/settings.json`

### 1.3 기본 설정 구조
```json
{
  "selectedAuthType": "gemini-api-key",
  "theme": "default",
  "mcpServers": {
    // MCP 서버 설정들이 여기에 추가됩니다
  }
}
```

## 2. Supabase MCP 서버 설정

### 2.1 Supabase 개인 액세스 토큰 생성
1. Supabase 대시보드의 Settings 메뉴로 이동
2. Access Tokens 섹션에서 새 토큰 생성
3. 적절한 권한을 설정하고 토큰 저장

### 2.2 Gemini CLI에 Supabase MCP 설정 추가
```json
{
  "selectedAuthType": "gemini-api-key",
  "theme": "default",
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--read-only",
        "--project-ref=<프로젝트-참조-ID>"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "<개인-액세스-토큰>"
      }
    }
  }
}
```

### 2.3 다양한 Supabase MCP 서버 옵션

#### 옵션 1: 공식 Supabase MCP 서버
```json
"supabase-official": {
  "command": "npx",
  "args": ["-y", "@supabase/mcp-server-supabase@latest"],
  "env": {
    "SUPABASE_ACCESS_TOKEN": "<토큰>",
    "SUPABASE_PROJECT_REF": "<프로젝트-ID>"
  }
}
```

#### 옵션 2: 커뮤니티 Supabase MCP 서버
```json
"supabase-community": {
  "command": "node",
  "args": ["path/to/supabase-mcp/build/index.js"],
  "env": {
    "SUPABASE_URL": "<프로젝트-URL>",
    "SUPABASE_KEY": "<서비스-롤-키>",
    "SUPABASE_ACCESS_TOKEN": "<액세스-토큰>"
  }
}
```

## 3. GitHub MCP 서버 설정

### 3.1 GitHub 개인 액세스 토큰 생성
1. GitHub Settings > Developer settings > Personal access tokens
2. "Generate new token (classic)" 선택
3. 필요한 권한 설정:
   - `repo` (리포지토리 접근)
   - `read:org` (조직 정보 읽기)
   - `user` (사용자 정보)

### 3.2 GitHub MCP 서버 설정
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "<GitHub-토큰>"
  }
}
```

## 4. Gemini MCP 서버 설정

### 4.1 Google Gemini API 기반 MCP 서버
```json
"gemini-api": {
  "command": "npx",
  "args": ["-y", "github:aliargun/mcp-server-gemini"],
  "env": {
    "GEMINI_API_KEY": "<Gemini-API-키>"
  }
}
```

### 4.2 Gemini CLI 기반 MCP 서버
```json
"gemini-cli": {
  "command": "uvx",
  "args": [
    "--from",
    "git+https://github.com/DiversioTeam/gemini-cli-mcp.git",
    "gemini-mcp"
  ],
  "env": {
    "LOG_LEVEL": "INFO"
  }
}
```

## 5. 완전한 Gemini CLI 설정 예시

### 5.1 종합 설정 파일
```json
{
  "selectedAuthType": "gemini-api-key",
  "theme": "default",
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--read-only",
        "--project-ref=your-project-ref"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "your-supabase-token"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-github-token"
      }
    },
    "gemini-api": {
      "command": "npx",
      "args": ["-y", "github:aliargun/mcp-server-gemini"],
      "env": {
        "GEMINI_API_KEY": "your-gemini-api-key"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/dbname"
      }
    }
  }
}
```

## 6. 환경 변수 관리

### 6.1 .env 파일 생성
프로젝트 루트에 `.env` 파일을 생성하여 민감한 정보를 관리:

```bash
# Supabase
SUPABASE_ACCESS_TOKEN=your_supabase_token_here
SUPABASE_PROJECT_REF=your_project_ref_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# GitHub
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token_here

# Gemini
GEMINI_API_KEY=your_gemini_api_key_here

# PostgreSQL
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```

### 6.2 환경 변수를 사용한 설정
```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}",
        "SUPABASE_PROJECT_REF": "${SUPABASE_PROJECT_REF}"
      }
    }
  }
}
```

## 7. 사용법 및 명령어

### 7.1 기본 Gemini CLI 명령어
```bash
# 간단한 프롬프트 실행
gemini -p "안녕하세요, Gemini입니다!"

# MCP 도구를 사용한 복합 작업
echo "Supabase 프로젝트의 테이블 목록을 조회해주세요" | gemini

# 파일을 포함한 분석
gemini -p "이 코드를 분석해주세요" -f src/app.js
```

### 7.2 MCP 도구 활용 예시
```bash
# GitHub 리포지토리 정보 조회
gemini -p "내 GitHub 리포지토리 목록을 보여주세요"

# Supabase 데이터베이스 쿼리
gemini -p "users 테이블에서 최근 가입한 사용자 10명을 조회해주세요"

# 복합 작업 (GitHub + Supabase)
gemini -p "GitHub 이슈를 Supabase 데이터베이스에 저장하는 방법을 알려주세요"
```

## 8. 보안 고려사항

### 8.1 토큰 보안
- API 키와 토큰을 절대 공개 리포지토리에 커밋하지 마세요
- `.env` 파일을 `.gitignore`에 추가하세요
- 정기적으로 토큰을 갱신하세요

### 8.2 권한 최소화
- 필요한 최소한의 권한만 부여하세요
- 읽기 전용 모드(`--read-only`)를 가능한 한 사용하세요
- 프로덕션과 개발 환경에서 다른 토큰을 사용하세요

## 9. 문제 해결

### 9.1 일반적인 오류와 해결법

#### MCP 서버 연결 실패
```bash
# 로그 확인
gemini --debug -p "테스트"

# 설정 파일 검증
cat ~/.gemini/settings.json | jq '.'
```

#### 토큰 인증 오류
1. 토큰이 유효한지 확인
2. 필요한 권한이 있는지 확인
3. 토큰이 만료되지 않았는지 확인

#### 환경 변수 문제
```bash
# 환경 변수 확인
echo $SUPABASE_ACCESS_TOKEN
printenv | grep -i supabase
```

### 9.2 디버깅 옵션
```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest"],
      "env": {
        "DEBUG": "true",
        "LOG_LEVEL": "DEBUG",
        "SUPABASE_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

## 10. 추가 MCP 서버

### 10.1 기타 유용한 MCP 서버들
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your-brave-api-key"
      }
    }
  }
}
```

## 11. 프로젝트별 개발 규칙 통합

### 11.1 우리 프로젝트 특화 설정
```json
{
  "selectedAuthType": "gemini-api-key",
  "theme": "default",
  "mcpServers": {
    "fortune-supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--project-ref=your-fortune-project-ref"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "your-token"
      }
    },
    "fortune-github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-github-token",
        "GITHUB_REPOSITORY": "your-username/fortune"
      }
    }
  }
}
```

### 11.2 한국어 응답 설정
```bash
# 한국어로 응답하도록 설정
export GEMINI_SYSTEM_PROMPT="모든 응답을 한국어로 제공하고, 코드 주석도 한국어로 작성해주세요."
```

이 가이드를 통해 Gemini CLI와 다양한 MCP 서버를 효과적으로 설정하고 사용할 수 있습니다. 프로젝트의 요구사항에 맞게 설정을 조정하여 사용하세요. 