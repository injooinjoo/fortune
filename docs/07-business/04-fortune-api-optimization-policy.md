# 🚀 Fortune API 호출 최적화 정책

> Fortune 앱의 API 호출을 최적화하여 비용을 최소화하고 사용자 경험을 극대화하기 위한 종합 정책 문서입니다.

## 📋 목차
1. [운세 타입별 분류 및 캐싱 정책](#운세-타입별-분류-및-캐싱-정책)
2. [배치 API 호출 전략](#배치-api-호출-전략)
3. [AI 모델 사용 가이드](#ai-모델-사용-가이드)
4. [DB 캐싱 및 저장 전략](#db-캐싱-및-저장-전략)
5. [프롬프트 작성 가이드](#프롬프트-작성-가이드)
6. [토큰 최적화 전략](#토큰-최적화-전략)
7. [구현 체크리스트](#구현-체크리스트)

---

## 🎯 운세 타입별 분류 및 캐싱 정책

### 1. 평생 운세 (Lifetime Fortune)
**특징**: 한 번 생성하면 변하지 않는 운세
**캐싱**: 365일 또는 무제한
**DB 저장**: `fortunes` 테이블에 영구 저장

| 운세 타입 | 캐시 기간 | 토큰 비용 | 필수 정보 |
|-----------|-----------|-----------|-----------|
| saju (사주팔자) | 무제한 | 5 | 생년월일시, 성별 |
| traditional-saju (전통사주) | 무제한 | 5 | 생년월일시, 성별 |
| tojeong (토정비결) | 365일 | 4 | 생년월일시 |
| past-life (전생) | 무제한 | 3 | 생년월일 |
| destiny (운명) | 무제한 | 4 | 생년월일, 성별 |
| personality (성격) | 무제한 | 3 | 생년월일, MBTI |
| talent (재능) | 무제한 | 3 | 생년월일 |
| salpuli (살풀이) | 365일 | 4 | 생년월일시 |

### 2. 주기별 운세 (Periodic Fortune)
**특징**: 시간에 따라 갱신이 필요한 운세
**캐싱**: 각 주기에 맞춘 캐시
**DB 저장**: 캐시 만료 시 재생성

| 운세 타입 | 캐시 기간 | 토큰 비용 | 갱신 주기 |
|-----------|-----------|-----------|-----------|
| daily (일일) | 24시간 | 1 | 매일 자정 |
| today (오늘) | 24시간 | 1 | 매일 자정 |
| tomorrow (내일) | 24시간 | 1 | 매일 자정 |
| hourly (시간별) | 1시간 | 1 | 매시간 |
| weekly (주간) | 7일 | 2 | 매주 월요일 |
| monthly (월간) | 30일 | 2 | 매월 1일 |
| yearly (연간) | 365일 | 3 | 매년 1월 1일 |
| biorhythm (바이오리듬) | 7일 | 2 | 주 단위 |

### 3. 시스템 레벨 운세 (System Level Fortune)
**특징**: 사용자별로 다르지 않고, 그룹별로 동일한 운세
**캐싱**: 시스템 레벨 캐시 (모든 사용자 공유)
**DB 저장**: 별도 테이블에 그룹별 저장

| 운세 타입 | 캐시 기간 | 토큰 비용 | 그룹 기준 |
|-----------|-----------|-----------|-----------|
| mbti | 30일 | 2 | 16개 MBTI 타입 |
| blood-type (혈액형) | 30일 | 1 | 4개 혈액형 |
| zodiac (별자리) | 30일 | 2 | 12개 별자리 |
| zodiac-animal (띠) | 365일 | 2 | 12개 띠 |
| birth-season (계절) | 90일 | 2 | 4계절 |

**최적화 방안**:
```typescript
// 시스템 레벨 운세는 한 번에 모든 타입 생성
const generateSystemFortunes = async () => {
  // MBTI 16개 타입 일괄 생성
  const mbtiTypes = ['INTJ', 'INTP', 'ENTJ', ...];
  const mbtiPrompt = `다음 16개 MBTI 타입의 ${period} 운세를 생성해주세요...`;
  
  // 혈액형 4개 타입 일괄 생성
  const bloodTypes = ['A', 'B', 'O', 'AB'];
  const bloodPrompt = `다음 4개 혈액형의 ${period} 운세를 생성해주세요...`;
  
  // 한 번의 API 호출로 모든 타입 생성 (토큰 80% 절약)
};
```

### 4. 인터랙티브 운세 (Interactive Fortune)
**특징**: 사용자 입력에 따라 실시간 생성
**캐싱**: 동일 입력에 대해서만 캐시
**DB 저장**: 생성 즉시 저장

| 운세 타입 | 캐시 기간 | 토큰 비용 | 특이사항 |
|-----------|-----------|-----------|-----------|
| palmistry (손금) | 캐시 없음 | 4 | 이미지 분석 필요 |
| face-reading (관상) | 캐시 없음 | 5 | 이미지 분석 필요 |
| physiognomy (인상) | 캐시 없음 | 5 | 이미지 분석 필요 |
| wish (소원) | 7일 | 2 | 동일 소원 캐시 |
| compatibility (궁합) | 30일 | 3 | 동일 파트너 캐시 |
| chemistry (케미) | 30일 | 3 | 동일 파트너 캐시 |

### 5. 테마별 운세 (Themed Fortune)
**특징**: 특정 주제에 특화된 운세
**캐싱**: 주제별로 다름
**DB 저장**: 일반 운세와 동일

#### 연애/인연 카테고리
| 운세 타입 | 캐시 기간 | 토큰 비용 |
|-----------|-----------|-----------|
| love (연애운) | 24시간 | 2 |
| marriage (결혼운) | 7일 | 3 |
| blind-date (소개팅) | 24시간 | 2 |
| ex-lover (전애인) | 30일 | 2 |
| couple-match (커플매칭) | 30일 | 3 |
| celebrity-match (연예인매칭) | 30일 | 2 |

#### 커리어/재물 카테고리
| 운세 타입 | 캐시 기간 | 토큰 비용 |
|-----------|-----------|-----------|
| career (직업운) | 7일 | 3 |
| wealth (재물운) | 7일 | 3 |
| business (사업운) | 7일 | 4 |
| employment (취업운) | 3일 | 3 |
| startup (창업운) | 7일 | 4 |
| investment (투자운) | 24시간 | 3 |
| lucky-stock (주식운) | 24시간 | 3 |
| lucky-crypto (암호화폐) | 24시간 | 3 |
| lucky-realestate (부동산) | 7일 | 3 |
| lucky-sidejob (부업운) | 7일 | 2 |

#### 행운 아이템 카테고리
| 운세 타입 | 캐시 기간 | 토큰 비용 |
|-----------|-----------|-----------|
| lucky-color (행운색) | 30일 | 1 |
| lucky-number (행운숫자) | 30일 | 1 |
| lucky-items (행운아이템) | 30일 | 2 |
| lucky-food (행운음식) | 7일 | 1 |
| lucky-outfit (행운의상) | 7일 | 2 |
| lucky-place (행운장소) | 7일 | 2 |

#### 스포츠/취미 카테고리
| 운세 타입 | 캐시 기간 | 토큰 비용 |
|-----------|-----------|-----------|
| lucky-baseball | 7일 | 2 |
| lucky-golf | 7일 | 2 |
| lucky-tennis | 7일 | 2 |
| lucky-running | 7일 | 2 |
| lucky-cycling | 7일 | 2 |
| lucky-swim | 7일 | 2 |
| lucky-hiking | 7일 | 2 |
| lucky-fishing | 7일 | 2 |
| lucky-fitness | 7일 | 2 |
| lucky-yoga | 7일 | 2 |

---

## 📦 배치 API 호출 전략

### 1. 온보딩 완료 패키지
**시점**: 회원가입 완료 직후
**목적**: 핵심 운세 미리 생성하여 첫 경험 개선

```typescript
const ONBOARDING_PACKAGE = {
  fortune_types: [
    'saju',           // 사주팔자 (평생)
    'personality',    // 성격운세 (평생)
    'talent',         // 재능운세 (평생)
    'daily',          // 오늘의운세
    'yearly'          // 올해운세
  ],
  token_cost: 5,      // 개별: 14토큰 → 묶음: 5토큰 (64% 절약)
  cache_strategy: 'mixed'
};
```

### 2. 일일 자동 갱신 패키지
**시점**: 매일 자정 (활성 사용자 대상)
**목적**: 자주 사용하는 운세 미리 준비

```typescript
const DAILY_REFRESH_PACKAGE = {
  fortune_types: [
    'daily',          // 오늘의운세
    'hourly',         // 시간별운세
    'biorhythm',      // 바이오리듬
    'lucky-color'     // 오늘의 행운색
  ],
  token_cost: 2,      // 개별: 5토큰 → 묶음: 2토큰 (60% 절약)
  cache_duration: '24h'
};
```

### 3. 테마별 패키지

#### 연애운 패키지 (솔로용)
```typescript
const LOVE_PACKAGE_SINGLE = {
  fortune_types: ['love', 'destiny', 'blind-date', 'celebrity-match'],
  token_cost: 4,      // 개별: 9토큰 → 묶음: 4토큰 (56% 절약)
  target_users: 'relationship_status === "single"'
};
```

#### 연애운 패키지 (커플용)
```typescript
const LOVE_PACKAGE_COUPLE = {
  fortune_types: ['love', 'couple-match', 'chemistry', 'marriage'],
  token_cost: 5,      // 개별: 10토큰 → 묶음: 5토큰 (50% 절약)
  target_users: 'relationship_status === "in_relationship"'
};
```

#### 커리어 패키지
```typescript
const CAREER_PACKAGE = {
  fortune_types: ['career', 'wealth', 'business', 'talent'],
  token_cost: 6,      // 개별: 13토큰 → 묶음: 6토큰 (54% 절약)
  recommended_for: ['job_seekers', 'entrepreneurs']
};
```

#### 행운 아이템 패키지
```typescript
const LUCKY_ITEMS_PACKAGE = {
  fortune_types: [
    'lucky-color',
    'lucky-number',
    'lucky-items',
    'lucky-food',
    'lucky-outfit'
  ],
  token_cost: 3,      // 개별: 7토큰 → 묶음: 3토큰 (57% 절약)
  cache_duration: '30d'
};
```

### 4. 프리미엄 종합 패키지
```typescript
const PREMIUM_COMPLETE_PACKAGE = {
  fortune_types: [
    // 평생 운세 (5개)
    'saju', 'traditional-saju', 'tojeong', 'destiny', 'past-life',
    // 주기별 운세 (4개)
    'daily', 'weekly', 'monthly', 'yearly',
    // 테마 운세 (6개)
    'love', 'career', 'wealth', 'health', 'lucky-items', 'biorhythm'
  ],
  token_cost: 15,     // 개별: 45토큰 → 묶음: 15토큰 (67% 절약)
  price: 49000,       // 원
  validity: '1_year'
};
```

---

## 🤖 AI 모델 사용 가이드

### 1. GPT-4.1-nano (기본 모델)
**용도**: 텍스트 기반 모든 운세 생성
**특징**: 
- 빠른 응답 속도 (평균 1-2초)
- 낮은 비용 (GPT-4 대비 90% 저렴)
- 충분한 품질의 운세 생성

**사용 예시**:
```typescript
const generateFortuneWithNano = async (fortuneType, userProfile) => {
  const response = await openai.chat.completions.create({
    model: "gpt-4.1-nano",
    messages: [
      {
        role: "system",
        content: `당신은 전문 운세 상담사입니다. 
                  긍정적이고 희망적인 메시지를 전달하되, 
                  구체적이고 실용적인 조언을 포함해주세요.`
      },
      {
        role: "user",
        content: generatePrompt(fortuneType, userProfile)
      }
    ],
    temperature: 0.8,
    max_tokens: 500,
    response_format: { type: "json_object" }
  });
  
  return JSON.parse(response.choices[0].message.content);
};
```

### 2. GPT-4-Vision (이미지 분석용)
**용도**: 관상, 손금 등 이미지 분석이 필요한 운세
**특징**:
- 이미지 인식 및 분석
- 높은 정확도
- 상대적으로 높은 비용

**사용 예시**:
```typescript
const analyzeFaceReading = async (imageUrl) => {
  const response = await openai.chat.completions.create({
    model: "gpt-4-vision-preview",
    messages: [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: "이 얼굴의 관상을 분석해서 운세를 알려주세요."
          },
          {
            type: "image_url",
            image_url: { url: imageUrl }
          }
        ]
      }
    ],
    max_tokens: 1000
  });
  
  return response.choices[0].message.content;
};
```

### 3. 모델 선택 기준
| 운세 유형 | 추천 모델 | 이유 |
|-----------|-----------|------|
| 텍스트 운세 (95%) | gpt-4.1-nano | 비용 효율적, 충분한 품질 |
| 이미지 분석 (4%) | gpt-4-vision | 이미지 인식 필요 |
| 복잡한 분석 (1%) | gpt-4-turbo | 심층 분석 필요 시 |

---

## 💾 DB 캐싱 및 저장 전략

### 1. 캐시 테이블 구조
```sql
-- fortune_cache 테이블
CREATE TABLE fortune_cache (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cache_key TEXT UNIQUE NOT NULL,  -- {type}_{user_id}_{date}
  fortune_type TEXT NOT NULL,
  user_id UUID NOT NULL,
  fortune_data JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL,
  hit_count INTEGER DEFAULT 0
);

-- 인덱스
CREATE INDEX idx_cache_key ON fortune_cache(cache_key);
CREATE INDEX idx_expires_at ON fortune_cache(expires_at);
CREATE INDEX idx_user_type ON fortune_cache(user_id, fortune_type);
```

### 2. 캐시 키 생성 전략
```typescript
const generateCacheKey = (fortuneType: string, userId: string, params?: any): string => {
  const baseKey = `${fortuneType}_${userId}`;
  
  // 주기별 운세는 날짜 포함
  if (['daily', 'today', 'tomorrow', 'hourly'].includes(fortuneType)) {
    const date = new Date().toISOString().split('T')[0];
    return `${baseKey}_${date}`;
  }
  
  // 시스템 레벨 운세는 userId 제외
  if (['mbti', 'blood-type', 'zodiac'].includes(fortuneType)) {
    return `${fortuneType}_${params.type}_${new Date().getMonth()}`;
  }
  
  // 인터랙티브 운세는 입력값 해시
  if (params) {
    const hash = crypto.createHash('md5').update(JSON.stringify(params)).digest('hex');
    return `${baseKey}_${hash}`;
  }
  
  return baseKey;
};
```

### 3. 캐시 조회 및 갱신
```typescript
const getCachedFortune = async (fortuneType: string, userId: string, params?: any) => {
  const cacheKey = generateCacheKey(fortuneType, userId, params);
  
  // 1. 캐시 조회
  const cached = await supabase
    .from('fortune_cache')
    .select('*')
    .eq('cache_key', cacheKey)
    .gte('expires_at', new Date().toISOString())
    .single();
  
  if (cached.data) {
    // 2. 히트 카운트 증가
    await supabase
      .from('fortune_cache')
      .update({ hit_count: cached.data.hit_count + 1 })
      .eq('id', cached.data.id);
    
    return cached.data.fortune_data;
  }
  
  // 3. 캐시 미스 - 새로 생성
  const newFortune = await generateFortune(fortuneType, userId, params);
  
  // 4. 캐시 저장
  const expiresAt = getExpirationTime(fortuneType);
  await supabase
    .from('fortune_cache')
    .upsert({
      cache_key: cacheKey,
      fortune_type: fortuneType,
      user_id: userId,
      fortune_data: newFortune,
      expires_at: expiresAt
    });
  
  return newFortune;
};
```

### 4. 배치 캐싱 전략
```typescript
const batchCacheFortunes = async (userId: string, fortunes: BatchFortuneResult[]) => {
  const cacheEntries = fortunes.map(fortune => {
    const cacheKey = generateCacheKey(fortune.type, userId);
    const expiresAt = getExpirationTime(fortune.type);
    
    return {
      cache_key: cacheKey,
      fortune_type: fortune.type,
      user_id: userId,
      fortune_data: fortune.data,
      expires_at: expiresAt
    };
  });
  
  // 한 번에 여러 캐시 저장
  await supabase
    .from('fortune_cache')
    .upsert(cacheEntries);
};
```

### 5. 캐시 정리 정책
```typescript
// 매일 자정 실행되는 크론 작업
const cleanupExpiredCache = async () => {
  // 만료된 캐시 삭제
  await supabase
    .from('fortune_cache')
    .delete()
    .lt('expires_at', new Date().toISOString());
  
  // 오래된 히스토리 아카이빙
  const threeMonthsAgo = new Date();
  threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
  
  await supabase
    .from('fortunes')
    .update({ archived: true })
    .lt('created_at', threeMonthsAgo.toISOString());
};
```

---

## ✍️ 프롬프트 작성 가이드

### 1. 기본 프롬프트 구조
```typescript
const BASE_PROMPT_TEMPLATE = `
당신은 30년 경력의 전문 운세 상담사입니다.
다음 정보를 바탕으로 {fortuneType} 운세를 작성해주세요.

사용자 정보:
- 이름: {name}
- 생년월일: {birthDate}
- 성별: {gender}
- MBTI: {mbti}

운세 작성 지침:
1. 최소 200자 이상, 최대 500자 이내로 작성
2. 긍정적이고 희망적인 톤 유지
3. 구체적이고 실용적인 조언 포함
4. 개인화된 내용으로 작성
5. 문장은 자연스럽고 읽기 쉽게

응답 형식 (JSON):
{
  "summary": "한 줄 요약 (20자 내외)",
  "overall_score": 0-100 사이의 점수,
  "description": "상세 운세 내용",
  "lucky_items": {
    "color": "행운의 색",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "time": "행운의 시간"
  },
  "advice": "오늘의 조언",
  "caution": "주의사항"
}
`;
```

### 2. 운세별 특화 프롬프트

#### 사주 운세
```typescript
const SAJU_PROMPT = `
${BASE_PROMPT_TEMPLATE}

추가 분석 요소:
- 오행(목화토금수) 균형 분석
- 십성(비견, 겁재, 식신 등) 해석
- 대운과 세운의 영향
- 평생 운의 흐름과 중요 시기

특별히 다음을 포함해주세요:
1. 타고난 기질과 성격
2. 인생의 주요 전환점 (3-5개)
3. 직업 및 재물운
4. 건강운과 주의사항
5. 인연과 대인관계
`;
```

#### 일일 운세
```typescript
const DAILY_PROMPT = `
${BASE_PROMPT_TEMPLATE}

오늘 날짜: {today}
요일: {dayOfWeek}

오늘의 운세에 포함할 내용:
1. 전반적인 운세 흐름
2. 오전/오후 운세 변화
3. 금전운과 건강운
4. 대인관계 조언
5. 오늘의 행운 포인트

특히 {dayOfWeek}요일의 특성을 고려하여 
실용적인 조언을 제공해주세요.
`;
```

#### 연애운
```typescript
const LOVE_PROMPT = `
${BASE_PROMPT_TEMPLATE}

연애 상태: {relationshipStatus}
이상형: {idealType}

연애운 분석에 포함할 내용:
1. 현재 연애운의 흐름
2. 새로운 만남의 가능성
3. 기존 관계 발전 방향
4. 이상적인 파트너 특징
5. 연애 성공을 위한 조언

{relationshipStatus}에 맞는 
맞춤형 조언을 제공해주세요.
`;
```

### 3. 배치 프롬프트 최적화
```typescript
const BATCH_PROMPT = `
다음 사용자의 여러 운세를 한 번에 생성해주세요.

사용자 정보:
- 이름: {name}
- 생년월일: {birthDate}
- 성별: {gender}
- MBTI: {mbti}

생성할 운세 목록:
1. 오늘의 운세 (daily)
2. 이번 주 운세 (weekly)
3. 연애운 (love)
4. 금전운 (wealth)
5. 건강운 (health)

각 운세별로 최소 150자 이상 작성하고,
서로 연관성 있게 구성해주세요.

응답 형식:
{
  "daily": { ... },
  "weekly": { ... },
  "love": { ... },
  "wealth": { ... },
  "health": { ... }
}
`;
```

### 4. 품질 체크리스트
- [ ] 200자 이상의 충실한 내용
- [ ] 개인화된 요소 포함 (이름, 나이, 성별 등)
- [ ] 긍정적이면서 현실적인 톤
- [ ] 구체적인 행동 지침 제공
- [ ] 행운 아이템 구체적 명시
- [ ] 자연스러운 문장 흐름
- [ ] 적절한 은유와 비유 사용

---

## 💰 토큰 최적화 전략

### 1. 토큰 사용량 계산
```typescript
const TOKEN_COSTS = {
  // 개별 호출 시
  individual: {
    saju: 500,        // 평균 토큰
    daily: 200,
    love: 300,
    career: 350,
    lucky_items: 150
  },
  
  // 배치 호출 시 (70-85% 절감)
  batch: {
    onboarding_package: 800,    // 5개 운세
    daily_package: 400,         // 4개 운세
    love_package: 600,          // 4개 운세
    premium_package: 2000       // 15개 운세
  }
};
```

### 2. 프롬프트 최적화 기법
```typescript
// 1. 공통 컨텍스트 재사용
const sharedContext = `
사용자: ${userProfile.name}, ${age}세, ${gender}
생일: ${birthDate} (${zodiacSign}, ${chineseZodiac})
`;

// 2. 압축된 지시문
const compactInstruction = `
간결하고 실용적인 ${fortuneType} 운세 생성.
포함: 점수, 요약, 조언, 행운요소
제외: 불필요한 인사말, 반복적 내용
`;

// 3. 스키마 기반 응답
const jsonSchema = {
  type: "object",
  properties: {
    score: { type: "number", minimum: 0, maximum: 100 },
    summary: { type: "string", maxLength: 50 },
    content: { type: "string", minLength: 200, maxLength: 500 }
  },
  required: ["score", "summary", "content"]
};
```

### 3. 토큰 절약 전략
1. **배치 처리**: 여러 운세를 한 번에 생성
2. **캐싱 활용**: 동일 조건 재사용
3. **프롬프트 템플릿**: 반복 내용 최소화
4. **JSON 응답**: 구조화된 간결한 응답
5. **컨텍스트 공유**: 사용자 정보 한 번만 전달

### 4. 월별 토큰 예산 관리
```typescript
const TOKEN_BUDGET = {
  daily_limit: 100000,      // 일일 한도
  monthly_limit: 2000000,   // 월 한도
  
  alerts: {
    warning: 0.8,           // 80% 도달 시 경고
    critical: 0.95          // 95% 도달 시 제한
  },
  
  optimization_triggers: {
    high_usage: 'switch_to_batch',
    peak_hours: 'increase_cache_duration',
    low_budget: 'restrict_premium_features'
  }
};
```

---

## ✅ 구현 체크리스트

### 1. Edge Functions 구현
- [ ] 배치 운세 생성 함수 (`fortune-batch`)
- [ ] 시스템 레벨 운세 함수 (`fortune-system`)
- [ ] 캐시 관리 함수 (`fortune-cache-manager`)
- [ ] 토큰 최적화 미들웨어

### 2. 데이터베이스 최적화
- [ ] `fortune_cache` 테이블 인덱스 최적화
- [ ] 파티셔닝 전략 (월별 파티션)
- [ ] 자동 정리 크론 작업
- [ ] 읽기 전용 복제본 활용

### 3. Flutter 앱 통합
- [ ] 배치 API 서비스 구현
- [ ] 오프라인 캐시 매니저
- [ ] 백그라운드 동기화
- [ ] 토큰 사용량 모니터링 UI

### 4. 모니터링 및 분석
- [ ] 토큰 사용량 대시보드
- [ ] 캐시 히트율 분석
- [ ] API 응답 시간 추적
- [ ] 사용자 만족도 측정

### 5. A/B 테스트
- [ ] 캐시 기간 최적화
- [ ] 프롬프트 품질 비교
- [ ] 배치 vs 개별 호출 효과
- [ ] 토큰 패키지 가격 정책

---

## 📊 예상 효과

### 비용 절감
- **API 호출 횟수**: 70% 감소
- **토큰 사용량**: 65-85% 절감
- **월 예상 비용**: $500 → $125

### 성능 개선
- **평균 응답 시간**: 2초 → 0.5초
- **캐시 히트율**: 80% 이상
- **동시 처리 능력**: 5배 향상

### 사용자 경험
- **첫 로딩 시간**: 90% 단축
- **오프라인 사용**: 주요 운세 가능
- **만족도**: 4.2 → 4.7점

---

*최종 업데이트: 2025년 1월 13일*
*버전: 1.0.0*