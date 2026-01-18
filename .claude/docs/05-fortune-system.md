# 인사이트 시스템 가이드

> 최종 업데이트: 2025.01.16

## 개요

Fortune App의 인사이트 시스템은 **72% API 비용 절감**을 위한 최적화된 프로세스를 사용합니다.

### 인사이트 통계 (2025.01.16)

| 항목 | 수치 |
|------|------|
| 인사이트 Edge Functions | 40개 |
| 유틸리티 Functions | 22개 |
| 인사이트 카테고리 | 13개 |
| 프리미엄 전용 | 8개 |
| 무료 전용 | 1개 (게임 강화운세) |

---

## 인사이트 조회 프로세스 (6단계)

```
인사이트 보기 클릭
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

## 인사이트별 동일 조건 정의

각 인사이트마다 "동일 조건"을 다르게 정의해야 합니다:

### 일일 인사이트 (Daily)
```dart
conditions = {
  'period': 'daily' | 'weekly' | 'monthly',
  // 날짜는 제외 (매일 새로운 운세)
}
```

### 연애 인사이트 (Love)
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

### 작명 운세 (Naming)
```dart
conditions = {
  'mother_saju': mother.sajuData,
  'expected_birth_date': expectedDate,
  'baby_gender': 'male' | 'female' | 'unknown',
  'family_name': familyName,
}
```

### 가족운 (Family)
```dart
// family-change, family-children, family-health, family-relationship, family-wealth
conditions = {
  'saju': user.sajuData,
  'family_type': 'change' | 'children' | 'health' | 'relationship' | 'wealth',
  'family_members': familyMembersList,  // 가족 구성원 사주
  'date': today,
}
```

### 전생/윤회 (Past-Life)
```dart
conditions = {
  'saju': user.sajuData,
  'birth_time': birthTime,
  // 사주로만 분석, 날짜 무관
}
```

### 시험운 (Exam)
```dart
conditions = {
  'saju': user.sajuData,
  'exam_type': 'college' | 'certification' | 'job_interview',
  'exam_date': examDate,
}
```

### 셀럽 매칭 (Celebrity)
```dart
conditions = {
  'user_saju': user.sajuData,
  'celebrity_id': selectedCelebrityId,
  // 셀럽 사주는 고정값
}
```

### 재물운 (Wealth/Investment)
```dart
conditions = {
  'saju': user.sajuData,
  'investment_type': 'stock' | 'realestate' | 'crypto' | 'general',
  'date': today,
}
```

### 펫 궁합 (Pet Compatibility)
```dart
conditions = {
  'user_saju': user.sajuData,
  'pet_type': 'dog' | 'cat' | 'bird' | 'etc',
  'pet_birth_date': petBirthDate,  // optional
}
```

### 오늘의 코디 (OOTD)
```dart
conditions = {
  'saju': user.sajuData,
  'gender': 'male' | 'female',
  'season': currentSeason,
  'date': today,
}
```

### 풍수 인테리어 (Home Fengshui)
```dart
conditions = {
  'saju': user.sajuData,
  'room_type': 'bedroom' | 'living' | 'office' | 'entrance',
  'direction': houseDirection,
}
```

### 신년운세 (New Year)
```dart
conditions = {
  'saju': user.sajuData,
  'year': targetYear,  // 2025, 2026 등
}
```

### 게임 강화운세 (Game Enhance)
```dart
// ⚠️ 무료, 입력 없음, 즉시 결과
conditions = {
  'saju': user.sajuData,
  // 추가 입력 없음 - 칩 탭 시 즉시 호출
}
```

### MBTI 운세 (MBTI)
```dart
conditions = {
  'saju': user.sajuData,
  'mbti': 'INFP' | 'ENTJ' | ...,
  'date': today,
}
```

### 건강 문서 (Health Document)
```dart
conditions = {
  'saju': user.sajuData,
  'health_data': {
    'blood_pressure': value,
    'heart_rate': value,
    'steps': value,
  },
  'date': today,
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

## 수익화 모델 (복주머니/블러)

> **상세 정책은 [22-business-model.md](22-business-model.md) 참조**

### 요약

| 모델 | 운세 수 | 특징 |
|------|--------|------|
| 🆓 **무료** | 5개 | 제한 없이 무료 |
| 🔒 **블러** | 22개 | 광고로 해제 (무제한) |
| 🧧 **복주머니** | 9개 | 광고 대체 불가 |

### 복주머니 운세 (9개)
- newYear (5개), traditional (5개), naming (7개)
- babyNickname (5개), yearlyEncounter (3개), celebrity (5개)
- lotto (3개), exam (3개), ootdEvaluation (3개)

### 토큰 소비 코드

```dart
// 복주머니 소비
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
- 운세 종류: 39개
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

## 관상 (Face Reading) 시스템

관상 운세는 별도의 V2 시스템으로 운영됩니다.

### 핵심 특징

| 항목 | 설명 |
|------|------|
| 타겟 | 2-30대 여성 |
| 핵심 가치 | 위로·공감·공유 (자기계발 X) |
| 말투 | 친근한 대화형 (~예요, ~해 보세요) |
| 성별 분기 | 여성: 연애/메이크업, 남성: 리더십/커리어 |

### App Store 컴플라이언스

**외부 표현 (심사용)**:
- "AI 얼굴 분석"
- "자기발견"
- "성격 분석"

**사용 금지 단어**:
- ~~운세~~, ~~점술~~, ~~fortune~~, ~~horoscope~~

### V2 무료/프리미엄 분기

| 무료 | 프리미엄 |
|------|----------|
| 우선순위 인사이트 3가지 | 상세 분석 전체 |
| 컨디션/감정 요약 | 컨디션/감정 상세 |
| 요약형 오관/십이궁 | 전체 오관/십이궁 |
| Watch 데이터 | 관계 인상 분석 |
| - | 스타일 추천 (성별별) |

### 상세 문서

**전체 가이드**: [17-face-reading-system.md](17-face-reading-system.md)

---

## 채팅 기반 운세 조회 (Chat-First)

### 개요

채팅 인터페이스를 통한 운세 조회 프로세스. 기존 6단계 프로세스를 채팅 흐름으로 확장.

### 채팅 운세 조회 흐름

```
사용자 입력 (채팅/칩 탭)
    ↓
1️⃣ 의도 분석 (로컬)
    ├─ 운세 유형 감지? → YES → 해당 유형으로 진행
    └─ 불명확? → 추천 칩 표시
    ↓
2️⃣ 기존 6단계 프로세스 실행
    └─ (캐시 → DB풀 → 랜덤 → API → 결과)
    ↓
3️⃣ FortuneResult → ChatMessage 변환
    ├─ 요약 메시지 (공개)
    ├─ 상세 섹션들 (블러 적용)
    └─ 후속 추천 칩
    ↓
4️⃣ 순차적 채팅 UI 표시
    └─ 500ms 간격 애니메이션
```

### 의도 분석 (Intent Analysis)

```dart
String? analyzeIntent(String message) {
  final lower = message.toLowerCase();

  final patterns = {
    'daily': ['오늘', '운세', '하루', '데일리'],
    'love': ['연애', '사랑', '애인', '결혼', '썸'],
    'money': ['재물', '돈', '금전', '투자', '재테크'],
    'tarot': ['타로', '카드', '점'],
    'dream': ['꿈', '해몽'],
    'career': ['직업', '취업', '이직', '승진'],
    'faceReading': ['얼굴', '관상', '인상'],
    'mbti': ['mbti', '엠비티아이', '성격'],
    'compatibility': ['궁합', '상성'],
  };

  for (final entry in patterns.entries) {
    if (entry.value.any((k) => lower.contains(k))) {
      return entry.key;
    }
  }

  return null; // 불명확 → 추천 칩 표시
}
```

### FortuneResult → ChatMessage 변환

```dart
class FortuneResultConverter {
  static List<ChatMessage> convert(FortuneResult result) {
    final messages = <ChatMessage>[];

    // 1. 요약 메시지 (항상 공개)
    messages.add(ChatMessage(
      type: ChatMessageType.fortuneResult,
      sectionKey: 'summary',
      text: _buildSummaryText(result),
      isBlurred: false,
    ));

    // 2. 상세 섹션들 (블러 적용)
    final sections = _getSections(result.type, result.data);
    for (final section in sections) {
      final isBlurred = result.isBlurred &&
                       result.blurredSections.contains(section.key);

      messages.add(ChatMessage(
        type: ChatMessageType.fortuneResult,
        sectionKey: section.key,
        text: section.content,
        isBlurred: isBlurred,
      ));
    }

    // 3. 후속 추천 칩
    messages.add(ChatMessage(
      type: ChatMessageType.system,
      chips: _generateFollowUpChips(result),
    ));

    return messages;
  }
}
```

### 채팅 내 블러/광고 처리

```dart
// 채팅 메시지에서 블러 해제
void unblurMessage(String messageId) {
  final updated = state.messages.map((m) {
    if (m.id == messageId) {
      return m.copyWith(isBlurred: false);
    }
    return m;
  }).toList();

  state = state.copyWith(messages: updated);
}

// 전체 대화 블러 해제
void unblurAllMessages() {
  final updated = state.messages.map((m) {
    return m.copyWith(isBlurred: false);
  }).toList();

  state = state.copyWith(messages: updated);
}
```

### 토큰 소비 (채팅)

채팅에서도 기존 토큰 소비율 동일 적용:

```dart
Future<void> requestFortuneInChat(String fortuneType) async {
  // 토큰 확인 & 소비
  final tokenNotifier = ref.read(tokenProvider.notifier);
  final success = await tokenNotifier.consumeTokens(
    amount: getTokenCost(fortuneType),
    fortuneType: fortuneType,
  );

  if (!success) {
    _showTokenPurchaseDialog();
    return;
  }

  // 운세 요청 진행
  await _processFortuneRequest(fortuneType);
}
```

### 상세 문서

→ [18-chat-first-architecture.md](18-chat-first-architecture.md)

---

## 관련 문서

- [06-llm-module.md](06-llm-module.md) - Edge Function & LLM
- [18-chat-first-architecture.md](18-chat-first-architecture.md) - Chat-First 아키텍처
- [03-ui-design-system.md](03-ui-design-system.md) - 블러 UI 시스템
- [17-face-reading-system.md](17-face-reading-system.md) - 관상 시스템 전체 가이드
- [docs/data/FORTUNE_OPTIMIZATION_GUIDE.md](/docs/data/FORTUNE_OPTIMIZATION_GUIDE.md) - 상세 최적화
