# 🚀 Fortune App - Context Engineering 가이드

Fortune 앱에 Context Engineering이 설정되었습니다. 이를 통해 Claude Code의 성능이 크게 향상됩니다.

## 📁 새로운 구조

```
fortune/
├── .claude/
│   ├── commands/
│   │   ├── generate-prp.md    # PRP 생성 명령
│   │   └── execute-prp.md     # PRP 실행 명령
│   └── settings.local.json    # Claude Code 권한 (자동 생성됨)
├── PRPs/
│   ├── templates/
│   │   └── prp_base.md       # 모든 PRP의 기본 템플릿
│   └── (생성된 PRP들이 여기에 저장됩니다)
├── examples/                  # 프로젝트별 코드 예제
├── CLAUDE.md                 # AI 어시스턴트를 위한 전역 규칙
├── INITIAL.md               # 새 기능 요청 템플릿
└── README_CONTEXT_ENGINEERING.md  # 이 파일
```

## 🎯 사용 방법

### 1. 새 기능 요청하기

`INITIAL.md`를 편집하여 원하는 기능을 상세히 설명하세요:

```markdown
## FEATURE:
AI 기반 일일 운세 생성 시스템을 구현합니다...

## EXAMPLES:
- src/lib/services/fortune-service.ts: 캐싱 패턴 참고...

## DOCUMENTATION:
- OpenAI API 문서: https://platform.openai.com/docs...
```

### 2. PRP 생성하기

Claude Code에서 실행:
```bash
/generate-prp INITIAL.md
```

이 명령은 당신의 요청을 분석하고 상세한 구현 계획(PRP)을 생성합니다.

### 3. PRP 실행하기

생성된 PRP를 검토한 후:
```bash
/execute-prp PRPs/feature-ai-fortune-generation.md
```

Claude는 PRP를 따라 기능을 구현하고, 자동으로 테스트와 검증을 수행합니다.

## 🔥 주요 개선사항

### 이전 (단순 프롬프트)
- 컨텍스트 부족으로 인한 잘못된 구현
- 일관성 없는 코드 스타일
- 테스트 누락
- 반복적인 수정 필요

### 이후 (Context Engineering)
- ✅ 프로젝트별 규칙 자동 준수
- ✅ 일관된 코드 패턴
- ✅ 자동 테스트 및 검증
- ✅ 한 번에 올바른 구현

## 📝 Fortune 앱 특별 규칙

`CLAUDE.md`에 정의된 Fortune 앱만의 규칙들:

1. **서버 사이드 AI 호출**: 모든 AI/GPT 호출은 서버에서만
2. **캐싱 필수**: 운세 결과는 반드시 캐싱
3. **모바일 우선**: 모든 UI는 모바일 최적화
4. **보안 우선**: API 키는 환경 변수로만
5. **사용자 경험**: 로딩 상태, 에러 처리 필수

## 🛠️ 현재 진행 중인 작업

TODO 리스트의 주요 작업들을 Context Engineering으로 처리할 수 있습니다:

1. **환경 변수 보안 강화**
   ```bash
   # INITIAL.md에 작성 후
   /generate-prp INITIAL.md
   /execute-prp PRPs/feature-secure-env-vars.md
   ```

2. **AI 운세 생성 시스템 연결**
   ```bash
   # 가장 중요한 기능!
   /generate-prp INITIAL.md
   /execute-prp PRPs/feature-ai-fortune-generation.md
   ```

## 💡 팁

- **구체적일수록 좋습니다**: INITIAL.md에 최대한 상세히 작성하세요
- **예제 활용**: examples/ 폴더에 참고할 코드를 추가하세요
- **문서 링크**: 필요한 공식 문서 URL을 포함하세요
- **검증 중요**: PRP의 검증 루프가 모두 통과할 때까지 기다리세요

---

이제 Fortune 앱 개발이 10배 더 효율적이 되었습니다! 🚀