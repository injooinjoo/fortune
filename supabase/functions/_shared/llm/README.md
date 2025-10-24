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
