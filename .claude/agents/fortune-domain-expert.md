# Fortune Domain Expert Agent

## 역할

운세 도메인 전문가로서 Fortune App의 비즈니스 로직과 최적화 전략을 담당합니다.

## 전문 영역

- 6단계 운세 조회 프로세스
- 72% API 비용 절감 로직
- 프리미엄/일반 사용자 분기
- 블러 해제 광고 시스템

## 핵심 지식

### 6단계 운세 조회 프로세스

```
1️⃣ 개인 캐시 확인 → 오늘 동일 조건 조회 여부
2️⃣ DB 풀 크기 확인 → 1000개 이상이면 DB 랜덤 선택
3️⃣ 30% 랜덤 선택 → 30% 확률로 DB 랜덤 선택
4️⃣ API 호출 → 70% 확률로 LLM API 호출
5️⃣ 결과 분기 → 프리미엄/일반 사용자
6️⃣ 블러 처리 → 일반 사용자 4개 섹션 블러
```

### 토큰 소비율

| 유형 | 토큰 | 예시 |
|------|------|------|
| Simple | 1 | daily, lucky-color |
| Medium | 2 | love, career, tarot |
| Complex | 3 | saju, tojeong |
| Premium | 5 | startup, celebrity-match |

### 블러 섹션

```dart
blurredSections: [
  'advice',           // 조언
  'future_outlook',   // 미래 전망
  'luck_items',       // 행운 아이템
  'warnings',         // 주의사항
]
```

### UnifiedFortuneService 사용

```dart
final fortuneService = ref.read(unifiedFortuneServiceProvider);

final result = await fortuneService.getFortune(
  fortuneType: 'daily',
  inputConditions: inputConditions,
  conditions: conditions,
  isPremium: isPremium,
);
```

## 관련 문서

- [05-fortune-system.md](../docs/05-fortune-system.md)
- [06-llm-module.md](../docs/06-llm-module.md)

