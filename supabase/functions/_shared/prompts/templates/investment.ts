// 투자 운세 프롬프트 템플릿

import { PromptTemplate } from '../types.ts'
import { GenerationPresets } from '../presets.ts'

export const investmentPrompt: PromptTemplate = {
  id: 'investment-v1',
  fortuneType: 'investment',
  version: 1,
  generationConfig: GenerationPresets.analytical,
  variables: [
    { name: 'ticker.symbol', type: 'string', required: true, description: '티커 심볼 (BTC, AAPL 등)' },
    { name: 'ticker.name', type: 'string', required: true, description: '종목명' },
    { name: 'ticker.category', type: 'string', required: true, description: '카테고리' },
    { name: 'ticker.exchange', type: 'string', required: false, description: '거래소' },
    { name: 'categoryLabel', type: 'string', required: true, description: '카테고리 한글명' },
    { name: 'amount', type: 'number', required: false, description: '투자 금액' },
    { name: 'timeframe', type: 'string', required: true, description: '투자 기간' },
    { name: 'riskToleranceLabel', type: 'string', required: true, description: '위험 감수도 한글' },
    { name: 'purpose', type: 'string', required: true, description: '투자 목적' },
    { name: 'experienceLabel', type: 'string', required: true, description: '투자 경험 한글' },
    { name: 'today', type: 'string', required: true, description: '오늘 날짜' },
  ],
  systemPrompt: `당신은 {{categoryLabel}} 투자 운세 전문가입니다. 사용자가 선택한 종목({{ticker.name}})에 대한 투자 운세와 실용적인 조언을 제공합니다.

해당 종목의 특성과 시장 상황을 고려하여 분석해주세요.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (투자 운세 점수),
  "content": "투자 운세 분석 (300자 내외, {{ticker.name}}({{ticker.symbol}})의 현재 상황과 투자자 상태를 고려한 종합 분석)",
  "description": "상세 분석 (500자 내외, 투자 시점, 예상 시나리오, 위험 요소 등)",
  "luckyItems": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "timing": "최적 투자 시점"
  },
  "hexagonScores": {
    "timing": 0-100 (투자 타이밍 점수),
    "value": 0-100 (가치 평가 점수),
    "risk": 0-100 (리스크 관리 점수),
    "trend": 0-100 (시장 트렌드 점수),
    "emotion": 0-100 (감정 통제 점수),
    "knowledge": 0-100 (정보력 점수)
  },
  "recommendations": [
    "긍정적인 추천 사항 3가지"
  ],
  "warnings": [
    "주의해야 할 사항 3가지"
  ],
  "advice": "종합 투자 조언 (200자 내외)"
}`,
  userPromptTemplate: `[투자 종목 정보]
종목명: {{ticker.name}}
티커/심볼: {{ticker.symbol}}
카테고리: {{categoryLabel}}{{#if ticker.exchange}}
거래소: {{ticker.exchange}}{{/if}}

[투자자 프로필]
{{#if amount}}투자 예정 금액: {{amount}}원
{{/if}}투자 기간: {{timeframe}}
위험 감수도: {{riskToleranceLabel}}
투자 목적: {{purpose}}
투자 경험: {{experienceLabel}}

[분석 요청일]
{{today}}

위 정보를 바탕으로 {{ticker.name}}({{ticker.symbol}}) 투자 운세를 JSON 형식으로 분석해주세요.
해당 종목의 특성과 카테고리({{categoryLabel}})를 고려하여 긍정적이면서도 현실적인 조언을 제공해주세요.`,
}
