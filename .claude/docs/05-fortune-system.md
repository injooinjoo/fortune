# 운세 시스템 가이드

## 개요

Fortune App의 운세 시스템은 **72% API 비용 절감**을 위한 최적화된 프로세스를 사용합니다.

---

## 운세 조회 프로세스 (6단계)

```
운세 보기 클릭
    ↓
1️⃣ 개인 캐시 확인
    ├─ 오늘 동일 조건으로 이미 조회? → YES → DB 결과 즉시 반환
    └─ NO ↓

2️⃣ DB 풀 크기 확인
    ├─ 동일 조건 전체 데이터 ≥1000개? → YES → DB 랜덤 선택 + 저장
    └─ NO ↓

3️⃣ 30% 랜덤 선택
    ├─ Math.random() < 0.3? → YES → DB 랜덤 선택 + 저장
    └─ NO (70%) ↓

4️⃣ 프리미엄 확인 & API 호출
    └─ Gemini 2.0 Flash Lite 호출 → DB 저장 ↓

5️⃣ 결과 페이지 표시 (분기)
    ├─ 프리미엄 사용자? → YES → 전체 결과 즉시 표시
    └─ 일반 사용자? → NO ↓

6️⃣ 블러 처리 결과 표시
    └─ 4개 섹션 블러 (조언, 미래전망, 행운아이템, 주의사항)
```

---

## 구현 로직

### 1단계: 개인 캐시 확인

```dart
final existingResult = await supabase
  .from('fortune_results')
  .select()
  .eq('user_id', userId)
  .eq('fortune_type', fortuneType)
  .gte('created_at', todayStart)
  .lte('created_at', todayEnd)
  .matchConditions(conditions)
  .maybeSingle();

if (existingResult != null) return existingResult; // 즉시 반환
```

### 2단계: DB 풀 크기 확인

```dart
final count = await supabase
  .from('fortune_results')
  .count()
  .eq('fortune_type', fortuneType)
  .matchConditions(conditions);

if (count >= 1000) {
  final randomResult = await getRandomFromDB(conditions);
  await Future.delayed(Duration(seconds: 5)); // 5초 대기
  await saveToUserHistory(userId, randomResult);
  return randomResult;
}
```

### 3단계: 30% 랜덤 선택

```dart
final random = Random().nextDouble();

if (random < 0.3) {
  final randomResult = await getRandomFromDB(conditions);
  await Future.delayed(Duration(seconds: 5));
  await saveToUserHistory(userId, randomResult);
  return randomResult;
} else {
  // 70% 확률로 API 호출 진행
  proceedToAPICall();
}
```

---

## 운세별 동일 조건 정의

각 운세마다 "동일 조건"을 다르게 정의해야 합니다:

### 일일운세 (Daily)
```dart
conditions = {
  'period': 'daily' | 'weekly' | 'monthly',
  // 날짜는 제외 (매일 새로운 운세)
}
```

### 연애운 (Love)
```dart
conditions = {
  'saju': user.sajuData,
  'date': today,
}
```

### 타로 (Tarot)
```dart
conditions = {
  'spread_type': 'basic' | 'love' | 'career',
  'selected_cards': [1, 5, 10],
  // 날짜 제외 (카드 조합만 중요)
}
```

### 직업 운세 (Career)
```dart
conditions = {
  'saju': user.sajuData,
  'job_category': 'developer' | 'designer',
  'date': today,
}
```

### 이사운 (Moving)
```dart
conditions = {
  'saju': user.sajuData,
  'move_date': selectedDate,
  'direction': selectedDirection,
}
```

### 궁합 (Compatibility)
```dart
conditions = {
  'user_saju': user.sajuData,
  'partner_saju': partner.sajuData,
}
```

---

## 프리미엄 & 광고 시스템

### 프리미엄 vs 일반 사용자

| 구분 | 프리미엄 | 일반 |
|------|---------|------|
| 결과 표시 | 즉시 전체 공개 | 블러 처리 |
| 광고 시청 | 불필요 | 필수 (5초) |
| 블러 섹션 | 없음 | 4개 섹션 |

### 프리미엄 확인 방법

```dart
// 1. 프리미엄 상태 확인
final tokenState = ref.read(tokenProvider);
final premiumOverride = await DebugPremiumService.getOverrideValue();
final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

// 2. UnifiedFortuneService 호출 시 전달
final fortuneResult = await fortuneService.getFortune(
  fortuneType: 'daily_calendar',
  inputConditions: inputConditions,
  conditions: conditions,
  isPremium: isPremium,
);
```

### 블러 처리 시스템

```dart
// FortuneResult에 블러 적용
if (!isPremium) {
  fortuneResult.applyBlur([
    'advice',           // 조언
    'future_outlook',   // 미래 전망
    'luck_items',       // 행운 아이템
    'warnings',         // 주의사항
  ]);
}
```

### 광고 시청 & 블러 해제

```dart
Future<void> _showAdAndUnblur() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AdLoadingDialog(
      duration: Duration(seconds: 5),
    ),
  );

  await Future.delayed(Duration(seconds: 5));
  Navigator.of(context).pop();

  setState(() {
    _fortuneResult.removeBlur();
  });
}
```

---

## 토큰/소울 소비율

### 운세 유형별 토큰 소비

| 유형 | 토큰 | 예시 |
|------|------|------|
| **Simple** | 1 | daily, today, tomorrow, lucky-color, lucky-number |
| **Medium** | 2 | love, career, tarot, dream, biorhythm, mbti |
| **Complex** | 3 | saju, traditional-saju, tojeong, past-life |
| **Premium** | 5 | startup, business, lucky-investment, celebrity-match |

### 토큰 소비 코드

```dart
// 토큰 소비
final tokenNotifier = ref.read(tokenProvider.notifier);
await tokenNotifier.consumeTokens(
  amount: getTokenCost(fortuneType),
  fortuneType: fortuneType,
);
```

---

## UnifiedFortuneService 사용법

### 기본 사용

```dart
final fortuneService = ref.read(unifiedFortuneServiceProvider);

final result = await fortuneService.getFortune(
  fortuneType: 'daily',
  inputConditions: InputConditions(
    birthDate: DateTime(1990, 1, 1),
    birthTime: '오시',
    gender: 'male',
  ),
  conditions: FortuneConditions.daily(period: 'daily'),
  isPremium: isPremium,
);
```

### FortuneConditions 클래스

```dart
abstract class FortuneConditions {
  String getConditionsHash();
  Map<String, dynamic> buildAPIPayload();
}

class DailyFortuneConditions extends FortuneConditions {
  final String period;

  @override
  String getConditionsHash() => 'daily_$period';

  @override
  Map<String, dynamic> buildAPIPayload() => {'period': period};
}
```

---

## DB 스키마

### fortune_results 테이블

```sql
CREATE TABLE fortune_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  fortune_type TEXT NOT NULL,
  result_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  conditions_hash TEXT NOT NULL,

  -- 운세별 조건 필드 (인덱싱용)
  saju_data JSONB,
  date DATE,
  period TEXT,
  selected_cards JSONB,

  -- 복합 인덱스
  CONSTRAINT unique_user_fortune_today
    UNIQUE(user_id, fortune_type, date, conditions_hash)
);

-- 성능 최적화 인덱스
CREATE INDEX idx_fortune_type_conditions
  ON fortune_results(fortune_type, conditions_hash, created_at DESC);

CREATE INDEX idx_user_fortune_date
  ON fortune_results(user_id, fortune_type, date DESC);
```

---

## 비용 절감 효과

### 가정
- 일일 사용자: 10,000명
- 운세 종류: 27개
- API 호출 비용: 건당 $0.01

### 기존 방식 (100% API 호출)
```
10,000명 × 평균 3개 운세 = 30,000 API 호출/일
30,000 × $0.01 = $300/일 = $9,000/월
```

### 최적화 방식
```
1단계 캐시: 20% 절감 (동일 사용자 재조회)
2단계 DB풀: 50% 절감 (1000개 이상인 운세)
3단계 랜덤: 30% 절감 (70%만 API 호출)

실제 API 호출: 30,000 × 0.8 × 0.5 × 0.7 = 8,400 호출
8,400 × $0.01 = $84/일 = $2,520/월

절감액: $6,480/월 (72% 절감)
```

---

## 주요 파일

| 기능 | 파일 |
|------|------|
| 프리미엄 확인 | `lib/core/services/debug_premium_service.dart` |
| 블러 위젯 | `lib/core/widgets/blurred_fortune_content.dart` |
| FortuneResult | `lib/core/models/fortune_result.dart` |
| UnifiedFortuneService | `lib/core/services/unified_fortune_service.dart` |
| 운세 페이지들 | `lib/features/fortune/presentation/pages/` |

---

## 관련 문서

- [06-llm-module.md](06-llm-module.md) - Edge Function & LLM
- [03-ui-design-system.md](03-ui-design-system.md) - 블러 UI 시스템
- [docs/data/FORTUNE_OPTIMIZATION_GUIDE.md](/docs/data/FORTUNE_OPTIMIZATION_GUIDE.md) - 상세 최적화
