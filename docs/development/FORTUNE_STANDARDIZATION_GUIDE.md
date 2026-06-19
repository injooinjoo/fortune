# Fortune Standardization Guide - 운세 표준화 가이드

**프로젝트 목표**: 26개 운세를 통일된 표준 프로세스로 전환 (소원빌기, 꿈해몽 제외)

**최종 업데이트**: 2025-10-10

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [표준 프로세스 플로우](#표준-프로세스-플로우)
3. [26개 운세 현황 분석](#26개-운세-현황-분석)
4. [공통 인프라 설계](#공통-인프라-설계)
5. [DB 스키마 설계](#db-스키마-설계)
6. [구현 가이드](#구현-가이드)
7. [마이그레이션 계획](#마이그레이션-계획)

---

## 🎯 프로젝트 개요

### 배경
현재 운세들은 각기 다른 방식으로 구현되어 있습니다:
- **API 방식 (17개)**: Edge Function 호출, 즉시 생성
- **로컬 방식 (11개)**: 로컬 데이터/계산, 랜덤 선택

### 문제점
1. ❌ **중복 생성**: 같은 날, 같은 조건인데도 매번 새로 생성
2. ❌ **저장 불일치**: 일부는 DB 저장, 일부는 임시 저장
3. ❌ **조건 미반영**: 타로 카드 선택 등 조건이 결과에 영향 없음
4. ❌ **히스토리 부재**: 과거 결과 재확인 불가능

### 목표
✅ **통일된 플로우**: 모든 운세가 동일한 프로세스 적용
✅ **중복 방지**: 같은 날 + 같은 조건 = 기존 결과 반환
✅ **영구 저장**: 모든 결과를 `fortune_history` 테이블에 저장
✅ **조건 반영**: 사용자 입력 조건이 결과에 반영

---

## 🔄 표준 프로세스 플로우

### 전체 플로우 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. 운세 클릭 (운세 리스트 페이지)                                    │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. 조건 입력 (필요시)                                                │
│    - 생년월일, 시간, 성별                                            │
│    - 타로 카드 3장 선택                                              │
│    - MBTI 타입 선택                                                 │
│    - 기타 운세별 필수 조건                                           │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. "운세 보기" 버튼 클릭                                              │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. 조건부 검토 (UnifiedFortuneService)                              │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 4-1. 기존 결과 조회                                         │    │
│  │      - WHERE user_id = ?                                │    │
│  │      - AND fortune_type = ?                             │    │
│  │      - AND fortune_date = TODAY()                       │    │
│  │      - AND input_conditions = ?                         │    │
│  └──────────────┬─────────────────────────────────────────────┘    │
│                 │                                                │
│                 ├─ 있음? → 기존 결과 반환 (5단계로)                   │
│                 │                                                │
│                 └─ 없음? ↓                                         │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 4-2. 데이터 소스 결정                                        │    │
│  │      - API 방식: Edge Function 호출                       │    │
│  │      - 로컬 방식: 조건 반영 랜덤 조회                         │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. 결과 저장 (fortune_history 테이블)                               │
│    - user_id: 사용자 ID                                            │
│    - fortune_type: 운세 타입                                       │
│    - fortune_date: 오늘 날짜                                       │
│    - input_conditions: 입력 조건 (JSONB)                          │
│    - fortune_data: 운세 전체 결과                                  │
│    - score: 운세 점수                                              │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. 결과 화면 표시                                                    │
└─────────────────────────────────────────────────────────────────┘
```

### 주요 로직

#### 4-1. 기존 결과 조회 (중복 방지)
```dart
Future<FortuneResult?> checkExistingFortune({
  required String fortuneType,
  required Map<String, dynamic> inputConditions,
}) async {
  final today = DateTime.now().toIso8601String().split('T')[0];

  final result = await supabase
    .from('fortune_history')
    .select()
    .eq('user_id', userId)
    .eq('fortune_type', fortuneType)
    .eq('fortune_date', today)
    .eq('input_conditions', jsonEncode(inputConditions))
    .maybeSingle();

  return result != null ? FortuneResult.fromJson(result) : null;
}
```

#### 4-2. 데이터 소스별 생성 로직

**API 방식**:
```dart
Future<FortuneResult> generateFromAPI({
  required String fortuneType,
  required Map<String, dynamic> inputConditions,
}) async {
  final response = await supabase.functions.invoke(
    'generate-fortune',
    body: {
      'fortune_type': fortuneType,
      'input_conditions': inputConditions,
    },
  );

  return FortuneResult.fromJson(response.data);
}
```

**로컬 방식** (예: 타로):
```dart
Future<FortuneResult> generateFromLocal({
  required String fortuneType,
  required Map<String, dynamic> inputConditions,
}) async {
  // 타로 카드 예시
  if (fortuneType == 'tarot') {
    final selectedCards = inputConditions['cards'] as List<String>;

    // 선택한 카드에 맞는 해석 조회
    final interpretations = await _getTarotInterpretations(selectedCards);

    return FortuneResult(
      type: fortuneType,
      data: interpretations,
      score: _calculateScore(interpretations),
    );
  }

  // 바이오리듬 예시
  if (fortuneType == 'biorhythm') {
    final birthDate = DateTime.parse(inputConditions['birth_date']);
    final targetDate = DateTime.parse(inputConditions['target_date']);

    // 바이오리듬 계산
    final rhythms = _calculateBiorhythm(birthDate, targetDate);

    return FortuneResult(
      type: fortuneType,
      data: rhythms,
      score: rhythms['average_score'],
    );
  }

  throw UnimplementedError('Fortune type $fortuneType not implemented');
}
```

---

## 📊 26개 운세 현황 분석

### High Priority: 로컬 → 표준화 (11개)

| # | 운세명 | 현재 구현 | 필요 조건 | DB 테이블 | Edge Function | 비고 |
|---|--------|----------|----------|-----------|--------------|------|
| 1 | 전통 운세 | 로컬 데이터 | 생년월일, 시간 | ❌ | ❌ | 사주/토정비결 통합 |
| 2 | 타로 카드 | 로컬 랜덤 | 카드 3장 선택 | ❌ | ❌ | 카드명을 조건으로 |
| 3 | 관상 | 로컬 데이터 | 얼굴 특징 입력 | ❌ | ❌ | 관상 특징 선택 |
| 4 | MBTI 운세 | 로컬 데이터 | MBTI 타입 | ❌ | ❌ | 16개 타입별 |
| 5 | 바이오리듬 | 계산 | 생년월일, 조회일 | ❌ | ❌ | 수학 공식 계산 |
| 6 | 성격 DNA | 로컬 조합 | DNA 4가지 선택 | ❌ | ❌ | 조합 로직 |
| 7 | 연애운 | 로컬 데이터 | 생년월일, 성별 | ❌ | ❌ | 연애 운세 |
| 8 | 행운 아이템 | Bottom Sheet | 날짜 | ❌ | ❌ | 색깔/숫자/음식/아이템 |
| 9 | 재능 발견 | Bottom Sheet | 생년월일 | ❌ | ❌ | 재능 분석 |
| 10 | 운동운세 | 로컬 데이터 | 날짜, 운동 종류 | ❌ | ❌ | 피트니스/요가/런닝 |
| 11 | 스포츠경기 | 로컬 데이터 | 날짜, 경기 종류 | ❌ | ❌ | 골프/야구/테니스 |

### Medium Priority: API → 표준화 (15개)

| # | 운세명 | 현재 구현 | 필요 조건 | DB 테이블 | Edge Function | 비고 |
|---|--------|----------|----------|-----------|--------------|------|
| 12 | 일일운세 | API | 날짜, 시간 구분 | ✅ | ✅ | 오늘/내일/주간/월간/연간 |
| 13 | 궁합 | API | 두 사람 생년월일 | ✅ | ✅ | 커플 궁합 |
| 14 | 피해야 할 사람 | API | 날짜 | ✅ | ✅ | 피해야 할 특징 |
| 15 | 헤어진 애인 | API | 생년월일, 상대 정보 | ✅ | ✅ | 재회 가능성 |
| 16 | 소개팅 운세 | API | 날짜, 상대 정보 | ✅ | ✅ | 소개팅 성공률 |
| 17 | 커리어 운세 | API | 생년월일, 직업 정보 | ✅ | ✅ | 취업/직업/사업/창업 |
| 18 | 시험 운세 | API | 날짜, 시험 정보 | ✅ | ✅ | 시험 합격 운세 |
| 19 | 투자 운세 | API | 날짜, 투자 섹터 | ✅ | ✅ | 주식/부동산/코인 10개 섹터 |
| 20 | 건강운세 | API | 날짜 | ✅ | ✅ | 신체 부위별 운세 |
| 21 | 이사운 | API | 날짜, 방향 | ✅ | ✅ | 이사 길일과 방향 |
| 22 | 포춘 쿠키 | API | 날짜 | ✅ | ✅ | 행운 메시지 |
| 23 | 유명인 운세 | API | 유명인 ID | ✅ | ✅ | 유명인과 나의 운세 |
| 24 | 반려동물 운세 | API | 반려동물 정보 | ✅ | ✅ | 반려동물 궁합 |
| 25 | 가족 운세 | API | 가족 구성원 정보 | ✅ | ✅ | 자녀/육아/가족화합 |
| 26 | 부적 | API | 날짜, 부적 종류 | ✅ | ✅ | 부적 생성 |

### 제외 운세 (2개)

| # | 운세명 | 이유 |
|---|--------|------|
| - | 소원빌기 | 매번 새로운 소원, 중복 방지 불필요 |
| - | 꿈해몽 | 매번 다른 꿈, 중복 방지 불필요 |

---

## 🏗️ 공통 인프라 설계

### UnifiedFortuneService 클래스

**파일 경로**: `lib/core/services/unified_fortune_service.dart`

**주요 메서드**:

```dart
class UnifiedFortuneService {
  final SupabaseClient _supabase;

  UnifiedFortuneService(this._supabase);

  /// 1. 중복 체크: 오늘 + 유저 + 운세타입 + 조건 일치?
  Future<FortuneResult?> checkExistingFortune({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) async {
    // 구현 내용은 위 참조
  }

  /// 2. 운세 생성: API 또는 로컬
  Future<FortuneResult> generateFortune({
    required String fortuneType,
    required FortuneDataSource dataSource,
    required Map<String, dynamic> inputConditions,
  }) async {
    switch (dataSource) {
      case FortuneDataSource.api:
        return await _generateFromAPI(fortuneType, inputConditions);
      case FortuneDataSource.local:
        return await _generateFromLocal(fortuneType, inputConditions);
    }
  }

  /// 3. DB 저장
  Future<void> saveFortune({
    required FortuneResult result,
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('fortune_history').insert({
      'user_id': userId,
      'fortune_type': fortuneType,
      'fortune_date': DateTime.now().toIso8601String().split('T')[0],
      'input_conditions': inputConditions,
      'fortune_data': result.toJson(),
      'score': result.score,
      'title': result.title,
      'summary': result.summary,
    });
  }

  /// 4. 통합 플로우 (메인 엔트리포인트)
  Future<FortuneResult> getFortune({
    required String fortuneType,
    required FortuneDataSource dataSource,
    required Map<String, dynamic> inputConditions,
  }) async {
    // Step 1: 기존 결과 확인
    final existing = await checkExistingFortune(
      fortuneType: fortuneType,
      inputConditions: inputConditions,
    );
    if (existing != null) {
      Logger.info('[UnifiedFortune] 기존 결과 반환: $fortuneType');
      return existing;
    }

    // Step 2: 새로 생성
    final result = await generateFortune(
      fortuneType: fortuneType,
      dataSource: dataSource,
      inputConditions: inputConditions,
    );

    // Step 3: 저장
    await saveFortune(
      result: result,
      fortuneType: fortuneType,
      inputConditions: inputConditions,
    );

    Logger.info('[UnifiedFortune] 새 결과 생성 및 저장: $fortuneType');
    return result;
  }
}

enum FortuneDataSource {
  api,   // Edge Function 호출
  local, // 로컬 데이터/계산
}
```

---

## 🗄️ DB 스키마 설계

### fortune_history 테이블 확장

**기존 스키마**:
```sql
CREATE TABLE fortune_history (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  fortune_type VARCHAR(50),
  fortune_date DATE,
  fortune_data JSONB,
  score INTEGER,
  title VARCHAR(255),
  summary JSONB,
  created_at TIMESTAMP,
  ...
);
```

**추가 필드**:
```sql
ALTER TABLE fortune_history
ADD COLUMN IF NOT EXISTS input_conditions JSONB;

COMMENT ON COLUMN fortune_history.input_conditions IS
'사용자 입력 조건 (타로 카드 선택, MBTI 타입, 생년월일 등)';
```

**복합 유니크 인덱스** (중복 방지):
```sql
-- 기존 인덱스 삭제 (있다면)
DROP INDEX IF EXISTS idx_fortune_unique_daily;

-- 새 복합 유니크 인덱스 생성
-- 같은 날짜 + 같은 유저 + 같은 운세 타입 + 같은 조건 = 중복
CREATE UNIQUE INDEX idx_fortune_unique_daily
ON fortune_history(
  user_id,
  fortune_type,
  fortune_date,
  (input_conditions::text)
);
```

**주의사항**:
- JSONB 컬럼에 직접 UNIQUE 제약을 걸 수 없으므로 `::text` 캐스팅 사용
- 동일한 JSONB 객체라도 키 순서가 다르면 다른 것으로 인식될 수 있음
- 해결: `input_conditions`를 저장할 때 항상 키를 정렬해서 저장

### input_conditions 필드 예시

**타로 카드**:
```json
{
  "cards": [
    "The Fool",
    "The Magician",
    "The High Priestess"
  ],
  "question": "오늘의 연애운은?"
}
```

**바이오리듬**:
```json
{
  "birth_date": "1990-01-01",
  "target_date": "2025-10-10"
}
```

**MBTI 운세**:
```json
{
  "mbti_type": "INFP"
}
```

**궁합**:
```json
{
  "user_birth": "1990-01-01",
  "user_gender": "male",
  "partner_birth": "1992-05-15",
  "partner_gender": "female"
}
```

**일일운세**:
```json
{
  "period": "daily",
  "date": "2025-10-10"
}
```

---

## 🛠️ 구현 가이드

### Step-by-Step 구현 절차

#### 1단계: 기존 운세 페이지 분석
```dart
// 기존 코드 (타로 예시)
class TarotRenewedPage extends ConsumerStatefulWidget {
  // 타로 카드 선택 → 결과 표시
  // ❌ 문제: 매번 새로 생성, DB 저장 안 함
}
```

#### 2단계: UnifiedFortuneService 통합
```dart
class TarotRenewedPage extends ConsumerStatefulWidget {
  final _fortuneService = UnifiedFortuneService(Supabase.instance.client);

  Future<void> _generateTarotFortune(List<String> selectedCards) async {
    // 기존 코드 제거

    // 새 코드
    final result = await _fortuneService.getFortune(
      fortuneType: 'tarot',
      dataSource: FortuneDataSource.local,
      inputConditions: {
        'cards': selectedCards,
        'question': _selectedQuestion,
      },
    );

    // 결과 표시
    setState(() {
      _tarotResult = result;
    });
  }
}
```

#### 3단계: 로컬 생성 로직 구현
```dart
// lib/core/services/fortune_generators/tarot_generator.dart
class TarotGenerator {
  static Future<FortuneResult> generate(Map<String, dynamic> conditions) async {
    final selectedCards = conditions['cards'] as List<String>;

    // 1. 선택한 카드에 맞는 해석 가져오기
    final interpretations = <Map<String, dynamic>>[];
    for (final cardName in selectedCards) {
      final card = TarotMetadata.getCardByName(cardName);
      interpretations.add({
        'card': cardName,
        'meaning': card.meaning,
        'advice': card.advice,
      });
    }

    // 2. 종합 점수 계산
    final score = _calculateScore(interpretations);

    // 3. 결과 반환
    return FortuneResult(
      type: 'tarot',
      title: '타로 카드 운세',
      summary: {
        'score': score,
        'message': _generateSummaryMessage(interpretations),
      },
      data: {
        'cards': interpretations,
        'overall': _generateOverallInterpretation(interpretations),
      },
      score: score,
    );
  }
}
```

#### 4단계: 테스트
```dart
void main() {
  test('타로 운세 중복 방지 테스트', () async {
    // 첫 번째 호출
    final result1 = await fortuneService.getFortune(
      fortuneType: 'tarot',
      dataSource: FortuneDataSource.local,
      inputConditions: {
        'cards': ['The Fool', 'The Magician', 'The High Priestess'],
      },
    );

    // 두 번째 호출 (동일 조건)
    final result2 = await fortuneService.getFortune(
      fortuneType: 'tarot',
      dataSource: FortuneDataSource.local,
      inputConditions: {
        'cards': ['The Fool', 'The Magician', 'The High Priestess'],
      },
    );

    // 같은 결과여야 함 (중복 방지)
    expect(result1.data, equals(result2.data));
  });
}
```

---

## 📅 마이그레이션 계획

### 마이그레이션 순서

1. **High Priority (로컬 운세) 먼저**
   - 전통 운세, 타로, MBTI, 바이오리듬 등
   - 이유: 현재 DB 저장이 없어 사용자 영향 최소

2. **Medium Priority (API 운세) 나중**
   - 시간별, 궁합, 커리어 등
   - 이유: 이미 API가 있어 표준화만 하면 됨

### 운세별 마이그레이션 체크리스트

- [ ] 1. 전통 운세
  - [ ] 입력 조건 정의
  - [ ] 로컬 생성 로직 구현
  - [ ] UnifiedFortuneService 통합
  - [ ] 테스트 (중복 방지 확인)

- [ ] 2. 타로 카드
  - [ ] 카드 선택 → `input_conditions`
  - [ ] 카드별 해석 로직
  - [ ] UnifiedFortuneService 통합
  - [ ] 테스트

...

---

## 🔍 검증 방법

### 1. 중복 방지 검증
```sql
-- 같은 날짜, 같은 운세, 같은 조건으로 2번 조회했을 때
-- fortune_history에 1개만 저장되어야 함
SELECT
  user_id,
  fortune_type,
  fortune_date,
  input_conditions,
  COUNT(*) as count
FROM fortune_history
WHERE user_id = 'USER_ID'
  AND fortune_date = CURRENT_DATE
GROUP BY user_id, fortune_type, fortune_date, input_conditions
HAVING COUNT(*) > 1; -- 이 쿼리 결과가 0이어야 함
```

### 2. 조건 반영 검증
```dart
// 타로 카드 예시: 다른 카드 선택 → 다른 결과
final result1 = await fortuneService.getFortune(
  fortuneType: 'tarot',
  inputConditions: {'cards': ['The Fool', 'The Magician', 'The High Priestess']},
);

final result2 = await fortuneService.getFortune(
  fortuneType: 'tarot',
  inputConditions: {'cards': ['The Emperor', 'The Lovers', 'The Chariot']},
);

// result1과 result2는 달라야 함
assert(result1.data != result2.data);
```

### 3. 영구 저장 검증
```sql
-- 운세 결과가 fortune_history에 영구 저장되었는지 확인
SELECT
  id,
  fortune_type,
  fortune_date,
  input_conditions,
  score,
  created_at
FROM fortune_history
WHERE user_id = 'USER_ID'
ORDER BY created_at DESC
LIMIT 10;
```

---

## 📈 진행 상황 추적

### Phase 1: 문서화
- [x] 표준화 가이드 문서 작성

### Phase 2: JIRA 티켓 생성
- [ ] 에픽 생성
- [ ] 26개 스토리 티켓 생성

### Phase 3: 공통 인프라
- [ ] DB 스키마 확장 (`input_conditions` 필드)
- [ ] 복합 유니크 인덱스 생성
- [ ] `UnifiedFortuneService` 클래스 생성
- [ ] `FortuneResult` 모델 정의
- [ ] 단위 테스트 작성

### Phase 4: 운세별 구현
**High Priority (11개)**:
- [ ] 1. 전통 운세
- [ ] 2. 타로 카드
- [ ] 3. 관상
- [ ] 4. MBTI 운세
- [ ] 5. 바이오리듬
- [ ] 6. 성격 DNA
- [ ] 7. 연애운
- [ ] 8. 행운 아이템
- [ ] 9. 재능 발견
- [ ] 10. 운동운세
- [ ] 11. 스포츠경기

**Medium Priority (15개)**:
- [ ] 12. 일일운세
- [ ] 13. 궁합
- [ ] 14. 피해야 할 사람
- [ ] 15. 헤어진 애인
- [ ] 16. 소개팅 운세
- [ ] 17. 커리어 운세
- [ ] 18. 시험 운세
- [ ] 19. 투자 운세
- [ ] 20. 건강운세
- [ ] 21. 이사운
- [ ] 22. 포춘 쿠키
- [ ] 23. 유명인 운세
- [ ] 24. 반려동물 운세
- [ ] 25. 가족 운세
- [ ] 26. 부적

### Phase 5: 검증 및 배포
- [ ] 중복 방지 테스트
- [ ] 조건 반영 테스트
- [ ] 영구 저장 테스트
- [ ] 실제 디바이스 테스트
- [ ] 배포 및 모니터링

---

## 📞 연락처 및 참고 자료

- **JIRA 프로젝트**: KAN (Kanban Board)
- **Edge Functions**: `supabase/functions/`
- **공유 계약**: `packages/product-contracts/`
- **RN 앱**: `apps/mobile-rn/`

---

**마지막 업데이트**: 2025-10-10
**작성자**: Claude Code Assistant
**버전**: 1.0.0
