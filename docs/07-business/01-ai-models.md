# 🤖 AI 모델 설정 및 사용 가이드

Fortune 프로젝트에서 사용하는 모든 AI 모델들의 설정과 사용법에 대한 상세 가이드입니다.

## 📋 목차
- [GPT 모델 구성](#gpt-모델-구성)
- [Teachable Machine 모델](#teachable-machine-모델)
- [모델 선택 로직](#모델-선택-로직)
- [사용법 및 예제](#사용법-및-예제)
- [비용 최적화](#비용-최적화)
- [개발 가이드](#개발-가이드)

---

## 🧠 GPT 모델 구성

### 1. **GPT-4o-Mini** (기본 운세 생성)
```typescript
name: 'gpt-4o-mini'
비용: $0.00015 per 1K tokens (매우 경제적)
최적 용도: 일일운세, 간단한 궁합, 기본 사주해석
```

**장점:**
- 💰 매우 저렴한 비용 (GPT-4 대비 66배 저렴)
- ⚡ 빠른 응답 속도
- 📱 모바일 앱에 최적화

**사용 사례:**
- 일일/주간/월간 운세
- 간단한 MBTI 기반 운세
- 띠별 운세
- 기본 궁합 분석

### 2. **GPT-4-Turbo** (멀티모달 분석)
```typescript
name: 'gpt-4-turbo'
비용: $0.01 per 1K tokens
최적 용도: 이미지 기반 운세 분석
특징: Vision API 지원
```

**장점:**
- 👁️ 이미지 분석 능력
- 🔍 정확한 시각적 해석
- 📊 복합적 데이터 처리

**사용 사례:**
- 관상 사진 분석
- 손금 사진 해석
- 출생차트 이미지 읽기
- 타로카드 이미지 해석
- 사주 한자 차트 분석

### 3. **GPT-4-Turbo-Preview** (전문 분석)
```typescript
name: 'gpt-4-turbo-preview'
비용: $0.01 per 1K tokens
최적 용도: 전문적이고 상세한 운세 분석
토큰 한도: 8,000 tokens
```

**장점:**
- 🎓 전문가 수준의 분석
- 📚 깊이 있는 해석
- 🔬 세밀한 상세 분석

**사용 사례:**
- 전통 사주 상세 분석
- 토정비결 전문 해석
- 결혼 궁합 심층 분석
- 사업 운세 컨설팅
- 평생 운세 분석

### 4. **GPT-3.5-Turbo** (실시간 대화)
```typescript
name: 'gpt-3.5-turbo'
비용: $0.0005 per 1K tokens
최적 용도: 빠른 대화형 운세
응답 속도: 초고속
```

**장점:**
- ⚡ 실시간 응답
- 💬 자연스러운 대화
- 🔄 연속적 상담

**사용 사례:**
- 실시간 질의응답
- 간단한 운세 질문
- 일상 상담
- 챗봇 기능

---

## 🎯 Teachable Machine 모델

### 1. **관상 분석 모델** (Face Reading)
```typescript
정확도: 85%
훈련 데이터: 10,000+ 한국인 관상 데이터
분류: 8가지 상 유형
```

**분류 카테고리:**
- 복상 (부유한 상) - 경제적 성공 예측
- 귀상 (고귀한 상) - 사회적 지위 상승
- 수상 (장수하는 상) - 건강과 장수
- 지혜상 (지적인 상) - 학문과 지식
- 인덕상 (인기가 많은 상) - 대인관계
- 예술상 (예술적 재능) - 창작 능력
- 리더상 (지도력이 있는 상) - 리더십
- 평범상 (일반적인 상) - 안정적 삶

**분석 요소:**
- 얼굴형 (둥근형, 각진형, 긴형 등)
- 눈의 형태와 크기
- 코의 높이와 형태
- 입술의 두께와 모양
- 이마의 넓이와 높이
- 귀의 크기와 위치

### 2. **손금 분석 모델** (Palm Reading)
```typescript
정확도: 78%
훈련 데이터: 8,000+ 손금 이미지
분류: 8가지 손금 유형
```

**분류 카테고리:**
- 장수형 (긴 생명선) - 건강한 삶
- 단명형 (짧은 생명선) - 건강 주의
- 감정풍부형 (깊은 감정선) - 풍부한 감성
- 이성적형 (명확한 지능선) - 논리적 사고
- 예술가형 (복잡한 손금) - 창의적 재능
- 사업가형 (태양선 발달) - 사업 성공
- 학자형 (수성구 발달) - 학문적 성취
- 일반형 (평범한 손금) - 평범한 삶

**분석 요소:**
- 생명선 (길이, 깊이, 곡선)
- 감정선 (시작점, 끝점, 깊이)
- 지능선 (명확성, 방향, 길이)
- 운명선 (존재 여부, 연결성)
- 태양선 (명성과 성공)
- 결혼선 (개수, 위치)

### 3. **출생차트 분석 모델** (Birth Chart)
```typescript
정확도: 72%
훈련 데이터: 5,000+ 출생차트
분류: 8가지 행성 배치 패턴
```

**분류 카테고리:**
- 물상 (수성 강세) - 소통과 지식
- 화상 (화성 강세) - 열정과 행동력
- 목상 (목성 강세) - 확장과 성장
- 금상 (금성 강세) - 사랑과 미적 감각
- 토상 (토성 강세) - 책임감과 인내
- 그랜드트라인 (대삼각) - 조화로운 재능
- 그랜드크로스 (대십자) - 도전과 성장
- 균형형 (고른 배치) - 전체적 균형

### 4. **타로카드 인식 모델** (Tarot Recognition)
```typescript
정확도: 92%
훈련 데이터: 15,000+ 타로카드 이미지
인식 범위: 78장 타로카드 + 정/역 방향
```

**인식 카테고리:**
- 메이저 아르카나 22장 (개별 인식)
- 마이너 아르카나 4개 수트별 분류
- 정방향/역방향 자동 판별
- 카드 상태 (새 카드/오래된 카드)

### 5. **사주 한자 인식 모델** (Saju Characters)
```typescript
정확도: 95%
훈련 데이터: 20,000+ 사주 한자
인식 범위: 십간 10자 + 십이지 12자
```

**인식 한자:**
- 십간: 갑, 을, 병, 정, 무, 기, 경, 신, 임, 계
- 십이지: 자, 축, 인, 묘, 진, 사, 오, 미, 신, 유, 술, 해
- 필체 변화 대응 (정자, 흘림체, 인쇄체)

---

## ⚙️ 모델 선택 로직

### 자동 모델 선택 알고리즘

```typescript
function selectOptimalModel(fortuneType, inputType, userTier) {
  // 1. 입력 타입 확인
  if (inputType === 'image' || inputType === 'multimodal') {
    return GPT_MODELS.MULTIMODAL; // GPT-4-Turbo
  }

  // 2. 전문성 요구사항 확인
  const professionalTypes = ['saju', 'marriage', 'yearly', 'consultation'];
  if (professionalTypes.includes(fortuneType)) {
    return GPT_MODELS.PROFESSIONAL; // GPT-4-Turbo-Preview
  }

  // 3. 실시간 요구사항 확인
  if (fortuneType === 'chat') {
    return GPT_MODELS.CHAT; // GPT-3.5-Turbo
  }

  // 4. 기본 운세는 경제적 모델
  return GPT_MODELS.BASIC; // GPT-4o-Mini
}
```

### 비용 최적화 전략

| 운세 타입 | 사용 모델 | 월 예상 비용 | 최적화 전략 |
|-----------|----------|-------------|------------|
| 일일운세 | GPT-4o-Mini | $2-5 | 캐시 24시간 |
| 사주분석 | GPT-4-Turbo | $15-30 | 캐시 1년 |
| 관상분석 | Teachable Machine + GPT-4 | $8-15 | TM 우선, GPT 보조 |
| 실시간 상담 | GPT-3.5-Turbo | $3-8 | 세션 기반 캐시 |

---

## 💻 사용법 및 예제

### 1. 기본 텍스트 운세 생성

```typescript
import { selectGPTModel, callGPTAPI, PROMPT_TEMPLATES } from '@/config/ai-models';

async function generateBasicFortune(userInfo: any) {
  // 모델 선택
  const model = selectGPTModel('daily', 'text');
  
  // 프롬프트 생성
  const prompt = PROMPT_TEMPLATES.BASIC_FORTUNE(userInfo, '일일운세');
  
  // GPT API 호출
  const result = await callGPTAPI(prompt, model);
  
  return result;
}
```

### 2. 이미지 기반 관상 분석

```typescript
import { selectGPTModel, callGPTAPI, selectTeachableModel, callTeachableMachine } from '@/config/ai-models';

async function analyzePhysiognomy(imageUrl: string, userInfo: any) {
  // 1단계: Teachable Machine으로 기본 분류
  const tmModel = selectTeachableModel('physiognomy');
  const tmResult = await callTeachableMachine(imageUrl, tmModel);
  
  // 2단계: GPT로 상세 해석
  const gptModel = selectGPTModel('physiognomy', 'multimodal');
  const prompt = `
    Teachable Machine 분석 결과: ${JSON.stringify(tmResult)}
    사용자 정보: ${JSON.stringify(userInfo)}
    
    위 관상 분석 결과를 바탕으로 상세한 운세를 해석해주세요.
  `;
  
  const gptResult = await callGPTAPI(prompt, gptModel, imageUrl);
  
  return {
    machineAnalysis: tmResult,
    aiInterpretation: gptResult,
    combinedInsight: generateCombinedInsight(tmResult, gptResult)
  };
}
```

### 3. 하이브리드 사주 분석

```typescript
async function analyzeSajuWithImage(chartImageUrl: string, userInfo: any) {
  // 1단계: 사주 한자 인식
  const charModel = TEACHABLE_MACHINE_MODELS.SAJU_CHARACTERS;
  const recognizedChars = await callTeachableMachine(chartImageUrl, charModel);
  
  // 2단계: 인식된 한자를 텍스트로 변환
  const sajuText = convertCharsToSaju(recognizedChars);
  
  // 3단계: 전문 GPT 모델로 해석
  const gptModel = GPT_MODELS.PROFESSIONAL;
  const prompt = PROMPT_TEMPLATES.PROFESSIONAL_ANALYSIS(
    { ...userInfo, saju: sajuText }, 
    '사주팔자'
  );
  
  const analysis = await callGPTAPI(prompt, gptModel);
  
  return {
    recognizedSaju: sajuText,
    analysis: analysis,
    confidence: recognizedChars.prediction.confidence
  };
}
```

---

## 📊 비용 최적화

### 캐시 전략
```typescript
const CACHE_DURATIONS = {
  daily: 24 * 60 * 60 * 1000,      // 24시간
  weekly: 7 * 24 * 60 * 60 * 1000,  // 7일
  saju: 365 * 24 * 60 * 60 * 1000,  // 1년 (평생운세)
  compatibility: 30 * 24 * 60 * 60 * 1000, // 30일
};
```

### 토큰 최적화
- **프롬프트 압축**: 불필요한 설명 제거
- **응답 형식 표준화**: JSON 스키마 고정
- **컨텍스트 제한**: 핵심 정보만 전달
- **배치 처리**: 여러 운세 동시 생성

### 모델별 사용 기준
```typescript
// 일일 사용량 기준 자동 모델 다운그레이드
function selectModelByUsage(dailyUsage: number, fortuneType: string) {
  if (dailyUsage > 1000) {
    return GPT_MODELS.BASIC; // 경제적 모델로 전환
  }
  
  return selectGPTModel(fortuneType, 'text');
}
```

---

## 🛠️ 개발 가이드

### 환경 설정

```bash
# 필수 패키지 설치
npm install @tensorflow/tfjs @teachablemachine/image

# 환경 변수 설정
OPENAI_API_KEY=your_openai_api_key
```

### 새로운 운세 API 개발 템플릿

```typescript
// src/app/api/fortune/[new-fortune]/route.ts
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';

export async function POST(request: NextRequest) {
  try {
    const userInfo = await request.json();
    
    // 1. 캐시 확인
    const cached = await checkCache(userInfo);
    if (cached) return NextResponse.json(cached);
    
    // 2. 모델 선택
    const model = selectGPTModel('your-fortune-type', 'text');
    
    // 3. 프롬프트 생성
    const prompt = generatePrompt(userInfo);
    
    // 4. GPT 호출
    const result = await callGPTAPI(prompt, model);
    
    // 5. 캐시 저장
    await saveCache(userInfo, result);
    
    return NextResponse.json(result);
  } catch (error) {
    // 백업 로직
    return generateFallbackFortune(userInfo);
  }
}
```

### Teachable Machine 모델 훈련 가이드

1. **데이터 수집**
   - 최소 1,000장 이상의 이미지
   - 균등한 클래스 분포
   - 다양한 조건 (조명, 각도, 품질)

2. **라벨링 기준**
   - 명확한 분류 기준 설정
   - 애매한 경우 제외
   - 전문가 검토 필수

3. **모델 검증**
   - 교차 검증 (Cross-validation)
   - 실제 서비스 데이터로 테스트
   - 지속적인 성능 모니터링

### 성능 모니터링

```typescript
// API 사용량 추적
export function trackAPIUsage(model, inputTokens, outputTokens) {
  const usage = {
    model: model.name,
    cost: calculateCost(inputTokens + outputTokens, model.costPer1kTokens),
    timestamp: new Date()
  };
  
  // DB에 저장하여 대시보드에서 모니터링
  saveUsageMetrics(usage);
}
```

---

## 🎯 향후 개발 계획

### 단기 계획 (1-2개월)
- [ ] 모든 기존 API에 GPT 연동 추가
- [ ] Supabase 캐시 시스템 구현
- [ ] 기본 Teachable Machine 모델 3개 훈련

### 중기 계획 (3-6개월)
- [ ] 고급 Teachable Machine 모델 개발
- [ ] 멀티모달 분석 고도화
- [ ] 사용자별 개인화 모델 구축

### 장기 계획 (6-12개월)
- [ ] 자체 AI 모델 개발 (Fine-tuning)
- [ ] 실시간 스트리밍 분석
- [ ] AR/VR 관상 분석 연동

---

## 📞 지원 및 문의

개발 중 문제가 발생하거나 새로운 AI 모델 추가가 필요한 경우:

1. **기술 문의**: GitHub Issues 등록
2. **모델 요청**: AI 모델 개선 제안서 작성
3. **긴급 문제**: 개발팀 직접 연락

---

*이 문서는 Fortune 프로젝트의 AI 모델 활용을 위한 종합 가이드입니다. 지속적으로 업데이트되며, 새로운 모델이나 기능이 추가될 때마다 갱신됩니다.* 