# 운세 배치 전략 가이드

## 개요
Fortune 앱의 토큰 효율성을 극대화하기 위한 운세 묶음(Batch) 전략 문서입니다.

## 핵심 전략

### 1. 묶음 원칙
- **시너지 효과**: 서로 연관된 운세를 묶어 통합적 인사이트 제공
- **토큰 효율성**: 배치 요청시 50% 할인 적용
- **사용자 경험**: 한 번의 요청으로 포괄적인 운세 제공

### 2. 묶음 카테고리

#### 시간 기반 묶음 (Time-based Bundle)
```javascript
morning_bundle: {
  fortune_types: ['daily', 'hourly', 'biorhythm', 'lucky-color'],
  token_cost: 2,
  description: '아침 시작 패키지'
}

evening_bundle: {
  fortune_types: ['tomorrow', 'weekly', 'health', 'lucky-items'],
  token_cost: 3,
  description: '저녁 마무리 패키지'
}
```

**활용 시나리오**:
- 아침 6-10시: morning_bundle 추천
- 저녁 6-10시: evening_bundle 추천

#### 라이프스타일 묶음 (Lifestyle Bundle)
```javascript
work_life_bundle: {
  fortune_types: ['career', 'wealth', 'business', 'daily', 'lucky-number'],
  token_cost: 5,
  description: '커리어 성공 패키지'
}

love_life_bundle: {
  fortune_types: ['love', 'compatibility', 'chemistry', 'lucky-items'],
  token_cost: 4,
  description: '연애 성공 패키지'
}

health_life_bundle: {
  fortune_types: ['health', 'biorhythm', 'lucky-food', 'lucky-fitness'],
  token_cost: 3,
  description: '건강 라이프 패키지'
}
```

#### 의사결정 묶음 (Decision Bundle)
```javascript
major_decision_bundle: {
  fortune_types: ['destiny', 'daily', 'hourly', 'avoid-people', 'lucky-place'],
  token_cost: 4,
  description: '중대 결정 패키지'
}

investment_decision_bundle: {
  fortune_types: ['wealth', 'lucky-investment', 'lucky-stock', 'biorhythm'],
  token_cost: 3,
  description: '투자 결정 패키지'
}
```

#### 깊이 있는 분석 묶음 (Deep Analysis Bundle)
```javascript
self_discovery_bundle: {
  fortune_types: ['saju', 'personality', 'talent', 'mbti', 'past-life'],
  token_cost: 8,
  description: '자아 발견 패키지'
}

future_planning_bundle: {
  fortune_types: ['yearly', 'monthly', 'weekly', 'timeline', 'destiny'],
  token_cost: 6,
  description: '미래 계획 패키지'
}
```

#### 활동별 묶음 (Activity Bundle)
```javascript
sports_bundle: {
  fortune_types: ['lucky-golf', 'lucky-tennis', 'lucky-running', 'biorhythm'],
  token_cost: 3,
  description: '스포츠 성공 패키지'
}

social_bundle: {
  fortune_types: ['daily', 'lucky-outfit', 'lucky-place', 'avoid-people'],
  token_cost: 2,
  description: '소셜 활동 패키지'
}
```

## 통합 프롬프트 전략

### 1. 번들별 최적화된 프롬프트
각 번들은 전용 시스템 프롬프트와 구조화된 응답 형식을 가집니다:

```typescript
// 예시: morning_bundle 프롬프트
systemPrompt: "30년 경력의 전문 운세 상담사로서 아침에 하루를 시작하는 사용자를 위해..."
responseFormat: {
  greeting: "상쾌한 아침 인사",
  daily: { /* 일일 운세 구조 */ },
  hourly: { /* 시간별 운세 구조 */ },
  biorhythm: { /* 바이오리듬 구조 */ },
  lucky_color: { /* 행운의 색 구조 */ },
  integrated_advice: "통합 조언"
}
```

### 2. 운세 간 시너지
- **연결성**: 각 운세가 서로 참조하고 보완
- **일관성**: 전체적으로 일관된 메시지 전달
- **통합 조언**: 모든 운세를 종합한 핵심 전략 제공

## API 사용 가이드

### 1. 번들 추천 요청
```javascript
POST /fortune-batch
{
  "get_recommendations": true,
  "user_profile": {
    "occupation": "developer",
    "relationship_status": "single"
  }
}
```

### 2. 번들 생성 요청
```javascript
POST /fortune-batch
{
  "package_type": "morning_bundle",
  "user_profile": {
    "name": "홍길동",
    "birth_date": "1990-01-01",
    "mbti": "INTJ"
  },
  "additional_context": {
    "currentConcern": "이직 고민"
  }
}
```

### 3. 응답 형식
```javascript
{
  "success": true,
  "package": "morning_bundle",
  "fortunes": [
    {
      "type": "daily",
      "data": { /* 운세 데이터 */ },
      "cached": false
    },
    // ... 추가 운세들
  ],
  "integrated_advice": "통합 조언",
  "tokens_used": 2,
  "cached_count": 1,
  "generated_count": 3
}
```

## 토큰 최적화 효과

### 개별 요청 vs 번들 요청
| 운세 조합 | 개별 토큰 | 번들 토큰 | 절감률 |
|---------|---------|---------|-------|
| daily + hourly + biorhythm + lucky-color | 4 | 2 | 50% |
| career + wealth + business + daily + lucky-number | 10 | 5 | 50% |
| saju + personality + talent + mbti + past-life | 16 | 8 | 50% |

### 캐싱 전략
- **평생 운세** (saju, personality 등): 1년 캐싱
- **월간 운세** (monthly, zodiac 등): 30일 캐싱
- **주간 운세** (weekly, career 등): 7일 캐싱
- **일일 운세** (daily, hourly 등): 24시간 캐싱

## 사용자 경험 개선

### 1. 시간대별 자동 추천
- 아침 (6-10시): morning_bundle
- 업무 시간 (10-18시): work_life_bundle
- 저녁 (18-22시): evening_bundle

### 2. 프로필 기반 추천
- 직장인: work_life_bundle
- 싱글: love_life_bundle (싱글용)
- 커플: love_life_bundle (커플용)
- 운동 애호가: sports_bundle

### 3. 상황별 추천
- 중요한 결정 앞: major_decision_bundle
- 투자 고민: investment_decision_bundle
- 자기 성찰: self_discovery_bundle

## 향후 개선 방향

### 1. AI 기반 동적 번들링
- 사용자 행동 패턴 분석
- 개인화된 번들 자동 생성
- 실시간 번들 최적화

### 2. 번들 구독 시스템
- 일일/주간/월간 번들 구독
- 구독자 전용 프리미엄 번들
- 번들 포인트 시스템

### 3. 번들 공유 기능
- 커플/가족 공유 번들
- 팀/그룹 번들
- 소셜 번들 선물하기

## 성과 측정

### KPI
1. **토큰 효율성**: 사용자당 평균 토큰 사용량 감소율
2. **사용자 만족도**: 번들 사용자의 재방문율
3. **수익성**: 번들 판매를 통한 매출 증가율

### 모니터링
- 인기 번들 순위
- 시간대별 번들 사용 패턴
- 번들별 완성도 및 만족도

---

*이 전략은 지속적으로 업데이트되며, 사용자 피드백을 반영하여 개선됩니다.*