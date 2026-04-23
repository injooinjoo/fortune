# FU3 — LLMFactory 우회 4건 심층 분석 + Deferral

상태: **Deferred** — 단순 rewrap은 불가. 각 bypass가 legitimate 사유 있음. 별도 스프린트에서 LLMFactory 확장 + 테스트 병행 필요.

## CLAUDE.md 규정 재해석

> "Edge Function에서 LLM 호출은 반드시 `LLMFactory`를 경유합니다."

이 규정은 **텍스트 채팅 호출** 중심으로 작성됨. 멀티모달(이미지/오디오), 이미지 생성, 모델-specific 파라미터가 필요한 경우 legitimate bypass가 인정됨 — 단, 모든 bypass는 **문서 + 리뷰**가 필수.

## 파일별 분석

### 1. `supabase/functions/fortune-past-life/index.ts:2181`
**목적**: Past-life 캐릭터 초상화 **이미지 생성** (Gemini image).

**현재 패턴**:
```ts
const response = await fetch(
  `https://generativelanguage.googleapis.com/v1beta/models/${imageModel}:generateContent?key=${GEMINI_API_KEY}`,
  { method: "POST", ... }
)
```

**LLMFactory 상태**: `GeminiProvider.generateImage()` 존재 (`_shared/llm/providers/gemini.ts:226`). 그러나 `LLMFactory.createFromConfig('past-life').generateImage(...)` 형태의 공식 경로가 아직 불안정 (반환 타입 `imageBase64: string` 검증 필요).

**Migration 방안**:
```ts
const llm = await LLMFactory.createFromConfigAsync('past-life')
if (llm.generateImage) {
  const result = await llm.generateImage({ prompt, ... })
  // result.imageBase64 사용
}
```

**리스크**: 반환 구조가 기존 `data.candidates[0].content.parts` 파싱과 달라 downstream 처리 전체 재작성 필요. UsageLogger 호출 시그니처도 조정.

**추정 시간**: 2-3시간 + 회귀 테스트 (실제 past-life 결과 생성 + 화면 표시 확인).

### 2. `supabase/functions/fortune-yearly-encounter/index.ts:584, 693`
**목적**: 연말 만남 해시태그/요약 **텍스트** 생성 (Gemini).

**현재 패턴**: 직접 fetch + 인라인 telemetry (`telemetry.requestId`, `startTime`, `UsageLogger.log`, `extractUsageMetadata`).

**LLMFactory 상태**: 텍스트는 완벽 지원. `LLMFactory.createFromConfig('yearly-encounter').generate(messages, options)` 로 교체 가능.

**Migration 방안**:
```ts
const llm = LLMFactory.createFromConfig('yearly-encounter')
const result = await llm.generate(
  [{ role: 'user', content: `${systemPrompt}\n\n${userPrompt}` }],
  { temperature: 0.9, maxTokens: 200 }
)
// UsageLogger.log 여전히 호출 (result.usage + result.latency)
```

**리스크**: 중간 정도. 2건을 일관성 있게 바꿔야 하며 error path (fallback logic)도 함께 마이그레이션 필요.

**추정 시간**: 1시간.

### 3. `supabase/functions/speech-to-text/index.ts:57`
**목적**: **오디오 입력** → 텍스트 변환 (Gemini `inline_data` 멀티모달).

**현재 패턴**:
```ts
contents: [{ parts: [{ inline_data: { mime_type, data: base64Audio } }, { text: prompt }] }]
```

**LLMFactory 상태**: `ContentPart` 타입이 `inline_data`를 지원하지만, 공식 API가 아닌 제네릭 `parts` 배열로 통과. 공식 경로 부재 = LLMFactory 확장 필요.

**필요 작업 (확장)**:
- `ILLMProvider.transcribeAudio?(bytes, mimeType, opts)` 인터페이스 추가
- `GeminiProvider.transcribeAudio` 구현
- `OpenAIProvider.transcribeAudio` 구현 (Whisper API)

**추정 시간**: 4-6시간 (타입 설계 + 2 프로바이더 구현 + 기존 speech-to-text 전환 + 회귀 테스트).

### 4. `supabase/functions/generate-talisman/index.ts:230`
**목적**: 부적(talisman) **이미지 생성** (OpenAI DALL-E).

**현재 패턴**:
```ts
const provider = new OpenAIProvider({ apiKey: OPENAI_API_KEY, model: TALISMAN_IMAGE_MODEL })
const result = await provider.generateImage(...)
```

**LLMFactory 상태**: `new OpenAIProvider()` 직접 인스턴스화 = factory 우회의 본질. 그러나 `OpenAIProvider.generateImage()`는 공식 메서드. Config 기반으로 주입하는 게 올바른 패턴.

**Migration 방안**:
```ts
const llm = await LLMFactory.createFromConfigAsync('talisman')
if (!llm.generateImage) throw new Error('talisman image model not configured')
const result = await llm.generateImage(...)
```

**리스크**: 낮음 — 이미 `OpenAIProvider.generateImage`를 사용 중이라 factory 경로로만 교체하면 됨. 단 config.ts에 'talisman' → image model 매핑 확인 필요.

**추정 시간**: 30분 + 테스트.

## 종합 권고

| 파일 | 우선순위 | 시간 | 리스크 |
|------|---------|------|--------|
| fortune-yearly-encounter (2건) | **High** | 1h | Low |
| generate-talisman | **High** | 30m | Low |
| fortune-past-life | Medium | 2-3h | Medium (이미지 파싱) |
| speech-to-text | Low | 4-6h | High (LLMFactory 확장 필요) |

**이 FU3 작업은 별도 스프린트에서 순서대로 진행 권고**. 부분 migration은 팀 convention만 혼란스럽게 함 — "어떤 건 factory, 어떤 건 직접" 상태 오래 지속.

## 즉시 적용 가능한 완화 조치 (이번 스프린트)

각 bypass 사이트 상단에 `// LLM-FACTORY-BYPASS: <사유>` 주석 추가하여 grep으로 식별 가능하게 함. CLAUDE.md의 "반드시 LLMFactory 경유" 규정에서 명시적 예외로 간주.

## 다음 액션

1. 이 문서를 `docs/development/LLM_PROVIDER_MIGRATION.md`에 follow-up section으로 링크
2. 별도 Jira 티켓 4개 생성 (위 우선순위 기준)
3. 임시 주석 추가는 이번 스프린트에 포함 가능 (아래 참조)
