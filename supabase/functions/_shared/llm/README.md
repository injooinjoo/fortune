# LLM 모듈

LLM Provider 추상화 레이어 - OpenAI, Gemini, Anthropic를 통일된 인터페이스로 사용

## 사용법

### 기본 사용 (권장)

```typescript
import { LLMFactory } from '../_shared/llm/factory.ts'

// 설정 기반 LLM Client 생성
const llm = LLMFactory.createFromConfig('moving')

// LLM 호출
const response = await llm.generate([
  { role: 'system', content: '당신은 운세 전문가입니다.' },
  { role: 'user', content: '이사운세를 봐주세요.' }
], {
  temperature: 1,
  maxTokens: 8192,
  jsonMode: true
})

console.log(`✅ ${response.provider}/${response.model} - ${response.latency}ms`)
console.log(`📊 Tokens: ${response.usage.totalTokens}`)
```

### 특정 Provider 사용

```typescript
import { LLMFactory } from '../_shared/llm/factory.ts'

// Gemini 직접 지정
const llm = LLMFactory.create('gemini', 'gemini-2.0-flash-exp')

// OpenAI 직접 지정
const llm = LLMFactory.create('openai', 'gpt-4o-mini')
```

## 환경변수 설정

### Gemini 사용 (권장)

```bash
supabase secrets set LLM_PROVIDER=gemini
supabase secrets set LLM_DEFAULT_MODEL=gemini-2.0-flash-exp
supabase secrets set GEMINI_API_KEY=your-key-here
```

### OpenAI 사용

```bash
supabase secrets set LLM_PROVIDER=openai
supabase secrets set LLM_DEFAULT_MODEL=gpt-4o-mini
supabase secrets set OPENAI_API_KEY=your-key-here
```

### OpenRouter 플랫폼 라우팅

- `OPENROUTER_ROUTING_MODE=legacy` (기본): 기존 provider/model을 그대로 사용합니다.
- `OPENROUTER_ROUTING_MODE=shadow`: 실제 호출은 기존 provider로 유지하고 용도별 OpenRouter 후보만 로그에 남깁니다.
- `OPENROUTER_ROUTING_MODE=openrouter`: 범용 텍스트·구조화·비전 호출을 용도별 허용 alias로 라우팅합니다.
- 플랫폼 호출은 `OPENROUTER_WORKSPACE_API_KEY`만 사용합니다. 사용자 BYOK와 개인/레거시 키는 섞지 않습니다.
- workspace key가 없으면 기존 provider로 안전하게 돌아가며 OpenRouter를 호출하지 않습니다.
- `OPENROUTER_RUNTIME_FALLBACK_ENABLED=true`일 때만 런타임 실패 후 기존 provider를 한 번 호출합니다.
- 이전 `OPENROUTER_API_KEY`를 임시 허용하려면 `OPENROUTER_ALLOW_LEGACY_PLATFORM_KEY=true`를 명시해야 합니다.

음성 인식, TTS, 이미지 생성·편집, 사용자 키 검증은 OpenRouter chat-completions 라우터 대상이 아닙니다.

## 파일 구조

```
_shared/llm/
├── README.md              # 이 파일
├── types.ts               # 인터페이스 정의
├── config.ts              # 설정 관리
├── factory.ts             # Provider Factory
└── providers/
    ├── gemini.ts          # Gemini 구현
    ├── openai.ts          # OpenAI 구현
    └── anthropic.ts       # Anthropic 구현 (향후)
```

## 상세 가이드

- [LLM_MODULE_GUIDE.md](../../../../docs/data/LLM_MODULE_GUIDE.md) - 전체 사용법
- [LLM_PROVIDER_MIGRATION.md](../../../../docs/data/LLM_PROVIDER_MIGRATION.md) - 마이그레이션 가이드
- [PROMPT_ENGINEERING_GUIDE.md](../../../../docs/data/PROMPT_ENGINEERING_GUIDE.md) - 프롬프트 최적화
