# 홈 랜딩 페이지 데이터 로딩 경로 분석

## 📊 데이터 소스 구조

```
API (Supabase Edge Function)
    ↓
Provider (dailyFortuneProvider) ← 메모리 상태
    ↓
CacheService (fortune_cache 테이블) ← DB 캐시 (7일 보존)
    ↓
FortuneHistoryService (fortune_history 테이블) ← 영구 저장
```

---

## 🔄 데이터 로딩 우선순위

### StoryHomeScreen의 `_loadTodaysFortune()` 메서드

**우선순위 순서**:
1. **Provider 상태 확인** (메모리)
2. **DB 캐시 확인** (fortune_cache 테이블)
3. **API 호출** (신규 데이터 생성)

---

## 📍 시나리오별 데이터 경로

### 🟢 시나리오 1: 앱 처음 실행 (오늘 첫 방문)

```
1. initState()
   └─ _initializeDataWithCacheCheck()

2. DB 캐시 확인 (CacheService)
   📦 fortune_cache 테이블 조회
   ❌ 캐시 없음 (오늘 날짜 데이터 없음)

3. Provider 상태 확인
   📊 dailyFortuneProvider.fortune
   ❌ null (Provider도 비어있음)

4. API 호출 (_fetchFortuneFromAPI)
   📡 dailyFortuneNotifier.loadFortune()
   └─ generateFortune() 호출
      └─ Supabase Edge Function 호출
         └─ GPT API로 운세 생성

5. 응답 처리
   ✅ Provider 상태 업데이트
   ✅ CacheService.cacheFortune() → fortune_cache 저장
   ✅ FortuneHistoryService.saveFortuneResult() → fortune_history 저장

6. 스토리 생성
   📝 _generateStory()
   └─ Supabase Edge Function (generate-fortune-story)
      └─ GPT로 10페이지 스토리 생성
   ✅ CacheService.cacheStorySegments() → fortune_stories 저장

7. 화면 렌더링
   🎨 FortuneStoryViewer 표시
```

**결과 데이터**:
- ✅ Provider 메모리에 저장됨
- ✅ fortune_cache 테이블에 저장됨 (7일간 유효)
- ✅ fortune_history 테이블에 저장됨 (영구)
- ✅ fortune_stories 테이블에 저장됨 (7일간 유효)

---

### 🟡 시나리오 2: 앱 재실행 (오늘 이미 방문함 - Provider 메모리 없음)

```
1. initState()
   └─ _initializeDataWithCacheCheck()

2. DB 캐시 확인 (CacheService)
   📦 fortune_cache 테이블 조회
   ✅ 캐시 있음! (오늘 날짜 데이터 존재)
   ✅ fortune_stories 테이블에서 스토리도 로드

3. 캐시 데이터 검증
   🔍 cachedFortune.overallScore != null 체크
   ✅ 유효한 데이터

4. 상태 업데이트
   setState() {
     todaysFortune = cachedFortune
     storySegments = cachedStorySegments
     isLoadingFortune = false  ← 로딩 화면 스킵!
   }

5. 화면 렌더링
   🎨 FortuneStoryViewer 표시 (즉시!)
   ⚡ API 호출 없음 - 빠른 로딩
```

**결과 데이터**:
- ✅ DB 캐시에서 복원된 데이터
- ✅ API 호출 없음
- ⚠️ Provider는 비어있음 (메모리에 없음)

---

### 🔵 시나리오 3: 다른 페이지에서 홈으로 돌아옴 (같은 세션)

```
1. 홈 탭 클릭 또는 context.go('/home')

2. initState() 호출되지 않음 (이미 마운트됨)
   ⚠️ Widget이 이미 존재하면 build()만 호출됨

3. 기존 상태 유지
   ✅ todaysFortune != null (메모리에 이미 있음)
   ✅ storySegments != null

4. _loadTodaysFortune() 중복 호출 방지
   if (todaysFortune != null && !isLoadingFortune) {
     debugPrint('✅ Already loaded, skipping');
     return;  ← 조기 종료
   }

5. 화면 렌더링
   🎨 FortuneStoryViewer 표시 (기존 데이터 사용)
```

**결과 데이터**:
- ✅ 메모리의 기존 데이터 재사용
- ✅ API 호출 없음
- ✅ DB 조회 없음
- ⚡ 즉시 렌더링

---

### 🟣 시나리오 4: Provider에만 데이터 있음 (캐시는 없음)

```
1. initState()
   └─ _initializeDataWithCacheCheck()

2. DB 캐시 확인
   📦 fortune_cache 테이블 조회
   ❌ 캐시 없음 (만료되거나 삭제됨)

3. Provider 상태 확인 ← 우선순위 높음!
   📊 dailyFortuneProvider.fortune
   ✅ 데이터 있음! (메모리에 존재)

4. Provider 데이터 사용
   setState() {
     todaysFortune = providerFortune
     isLoadingFortune = false
   }

5. 스토리 확인
   if (cachedStorySegments != null) {
     ✅ 캐시된 스토리 사용
   } else {
     📝 _generateStory() 호출
   }

6. 화면 렌더링
   🎨 FortuneStoryViewer 표시
```

**결과 데이터**:
- ✅ Provider 메모리 데이터 사용
- ⚠️ DB 캐시는 없음
- ⚠️ 스토리는 다시 생성될 수 있음

---

## ❌ 문제 상황: 데이터 불일치

### 문제 증상
"처음 API 호출한 데이터와 다른 페이지에서 돌아왔을 때 보이는 데이터가 다름"

### 원인 분석

#### 1️⃣ **Provider 메모리 손실**
```dart
// Provider는 앱이 종료되면 메모리에서 사라짐
// 다음 실행 시 DB 캐시에서 복원하는데...
```

#### 2️⃣ **DB 캐시 데이터 불완전**
```dart
// CacheService.cacheFortune()이 호출되지 않았을 수 있음
// 또는 메타데이터가 제대로 저장되지 않음
```

#### 3️⃣ **데이터 변환 문제**
```dart
// FortuneModel ↔ Fortune Entity 변환 시
// 일부 필드가 손실될 수 있음

// fortune_cache 테이블 구조:
{
  fortune_data: JSONB  // 전체 데이터 저장
}

// toEntity() 변환 시 문제 가능성:
- overallScore가 metadata에만 있고 root에 없음
- 중첩된 데이터 구조가 평탄화됨
- 일부 커스텀 필드가 누락됨
```

---

## 🔧 해결 방안

### 방안 1: Provider 상태를 항상 최우선으로 사용 (현재 구현)

**장점**:
- ✅ 같은 세션 내에서 데이터 일관성 보장
- ✅ API 호출 최소화

**단점**:
- ❌ 앱 재시작 시 Provider 메모리 손실
- ❌ DB 캐시 데이터 품질에 의존

**현재 코드** (line 540-567):
```dart
// 3. Provider에 데이터가 있으면 Provider 우선 사용
if (hasProviderFortune) {
  final providerFortune = currentProviderState.fortune!;
  setState(() {
    todaysFortune = providerFortune;
    isLoadingFortune = false;
  });
  return; // ← 여기서 종료, DB 캐시 무시
}
```

---

### 방안 2: DB 캐시를 항상 신뢰할 수 있게 개선 ⭐ **추천**

#### 2-1. CacheService.cacheFortune() 호출 보장

**문제**: API 응답 후 캐시 저장이 실패하거나 불완전할 수 있음

**해결**:
```dart
// _fetchFortuneFromAPI() 수정
Future<void> _fetchFortuneFromAPI() async {
  // ... API 호출

  if (fortuneState.fortune != null) {
    final fortune = fortuneState.fortune!;

    // ✅ 명시적으로 캐시 저장 (Provider가 하지 않을 수도 있으므로)
    await _cacheService.cacheFortune(
      'daily',
      {'userId': userId},
      FortuneModel.fromEntity(fortune)  // Entity → Model 변환
    );

    setState(() {
      todaysFortune = fortune;
    });
  }
}
```

#### 2-2. FortuneModel.toEntity() 변환 개선

**문제**: Entity 변환 시 데이터 손실

**해결**: FortuneModel의 metadata에 모든 필드 보존
```dart
// models/fortune_model.dart
FortuneModel.fromEntity(Fortune entity) {
  return FortuneModel(
    // ... 기본 필드
    metadata: {
      'overallScore': entity.overallScore,  // ← 중요!
      'hexagonScores': entity.hexagonScores,
      'scoreBreakdown': entity.scoreBreakdown,
      'recommendations': entity.recommendations,
      'warnings': entity.warnings,
      'luckyItems': entity.luckyItems,
      'categories': entity.categories,
      'sajuInsight': entity.sajuInsight,
      // ... 모든 커스텀 필드
    }
  );
}
```

#### 2-3. DB 캐시 우선순위 상승

**현재 순서**: Provider → DB 캐시 → API

**변경 후**: DB 캐시 → Provider → API

```dart
// _loadTodaysFortune() 수정
Future<void> _loadTodaysFortune() async {
  // 1. DB 캐시 먼저 확인 (가장 신뢰할 수 있는 소스)
  final cachedFortuneData = await _cacheService.getCachedFortune(...);

  if (cachedFortuneData != null && cachedFortuneData.metadata?['overallScore'] != null) {
    // ✅ 유효한 캐시 데이터 발견
    setState(() {
      todaysFortune = cachedFortuneData.toEntity();
      isLoadingFortune = false;
    });

    // Provider도 동기화
    ref.read(dailyFortuneProvider.notifier).state = FortuneState(
      fortune: cachedFortuneData.toEntity(),
      isLoading: false
    );

    return;
  }

  // 2. Provider 확인
  // 3. API 호출
}
```

---

### 방안 3: 데이터 동기화 전략 ⭐⭐ **최선**

#### 핵심 원칙
> **"Single Source of Truth" - DB 캐시를 유일한 진실의 원천으로**

#### 구현 방법

**1. API 응답 즉시 DB에 저장**
```dart
Future<void> _fetchFortuneFromAPI() async {
  final fortune = await api.getFortune();

  // 1순위: DB 캐시 저장 (영속성)
  await _cacheService.cacheFortune('daily', {...}, FortuneModel.fromEntity(fortune));

  // 2순위: Provider 업데이트 (빠른 접근)
  ref.read(dailyFortuneProvider.notifier).state = FortuneState(fortune: fortune);

  // 3순위: 로컬 상태 업데이트 (화면 표시)
  setState(() { todaysFortune = fortune; });

  // 4순위: 히스토리 저장 (영구 기록)
  await _saveDailyFortuneToHistory(fortune);
}
```

**2. 데이터 로딩 시 DB 우선**
```dart
Future<void> _loadTodaysFortune() async {
  // Step 1: DB 캐시 (가장 신뢰할 수 있음)
  final cachedData = await _cacheService.getCachedFortune(...);

  if (cachedData != null && _isValidFortuneData(cachedData)) {
    final fortune = cachedData.toEntity();

    // 모든 상태를 DB 데이터로 동기화
    setState(() { todaysFortune = fortune; });
    ref.read(dailyFortuneProvider.notifier).state = FortuneState(fortune: fortune);

    return; // ✅ 완료
  }

  // Step 2: API 호출 (캐시 없을 때만)
  await _fetchFortuneFromAPI();
}
```

**3. 데이터 검증 함수**
```dart
bool _isValidFortuneData(FortuneModel model) {
  // 필수 필드 검증
  if (model.metadata?['overallScore'] == null) return false;
  if (model.content == null || model.content!.isEmpty) return false;

  // 날짜 검증
  final today = DateTime.now();
  final cachedDate = model.createdAt ?? DateTime(2000);
  if (cachedDate.year != today.year ||
      cachedDate.month != today.month ||
      cachedDate.day != today.day) {
    return false;
  }

  return true;
}
```

---

## 📝 권장 수정 사항

### 1. `_loadTodaysFortune()` 메서드 수정

**파일**: `lib/screens/home/story_home_screen.dart`

**변경 전** (line 540-567):
```dart
// Provider 우선 확인
if (hasProviderFortune) {
  // Provider 데이터 사용
  return;
}

// 그 다음 캐시 확인
if (cachedFortuneData != null) {
  // 캐시 데이터 사용
  return;
}
```

**변경 후**:
```dart
// 1. DB 캐시 우선 확인 (가장 신뢰할 수 있음)
if (cachedFortuneData != null && _isValidFortuneData(cachedFortuneData)) {
  final cachedFortune = cachedFortuneData.toEntity();

  setState(() {
    todaysFortune = cachedFortune;
    storySegments = cachedStorySegments;
    isLoadingFortune = false;
  });

  // Provider도 DB 데이터로 동기화
  final notifier = ref.read(dailyFortuneProvider.notifier);
  notifier.state = FortuneState(fortune: cachedFortune, isLoading: false);

  return; // ✅ DB 캐시 사용 완료
}

// 2. Provider 확인 (DB 캐시가 없을 때만)
if (hasProviderFortune) {
  // Provider 데이터를 DB에 다시 저장
  await _cacheService.cacheFortune(...);
  // 그리고 사용
}

// 3. API 호출 (둘 다 없을 때)
await _fetchFortuneFromAPI();
```

### 2. `_fetchFortuneFromAPI()` 메서드 수정

**변경 후**:
```dart
Future<void> _fetchFortuneFromAPI() async {
  final fortuneState = await dailyFortuneNotifier.loadFortune();

  if (fortuneState.fortune != null) {
    final fortune = fortuneState.fortune!;

    // ✅ 1순위: DB 캐시 저장 보장
    await _cacheService.cacheFortune(
      'daily',
      {'userId': userId},
      FortuneModel.fromEntity(fortune)
    );

    // ✅ 2순위: 로컬 상태 업데이트
    setState(() { todaysFortune = fortune; });

    // ✅ 3순위: 히스토리 저장
    await _saveDailyFortuneToHistory(fortune);

    // ✅ 4순위: 스토리 생성
    await _generateStory(fortune);
  }
}
```

### 3. FortuneModel 변환 개선

**파일**: `lib/models/fortune_model.dart`

**추가 메서드**:
```dart
// Entity → Model 변환 (모든 데이터 보존)
factory FortuneModel.fromEntity(Fortune entity) {
  return FortuneModel(
    id: entity.id,
    type: entity.type,
    content: entity.content,
    createdAt: DateTime.now(),
    metadata: {
      // 모든 필드를 metadata에 보존
      'overallScore': entity.overallScore,
      'hexagonScores': entity.hexagonScores,
      'scoreBreakdown': entity.scoreBreakdown,
      'recommendations': entity.recommendations,
      'warnings': entity.warnings,
      'luckyItems': entity.luckyItems,
      'luckyColor': entity.luckyColor,
      'luckyNumber': entity.luckyNumber,
      'categories': entity.categories,
      'sajuInsight': entity.sajuInsight,
      'personalActions': entity.personalActions,
      // ... 모든 커스텀 필드
    }
  );
}

// Model → Entity 변환 (metadata에서 복원)
Fortune toEntity() {
  return Fortune(
    id: id,
    type: type ?? 'daily',
    content: content ?? '',
    overallScore: metadata?['overallScore'] ?? 75,
    hexagonScores: metadata?['hexagonScores'],
    scoreBreakdown: metadata?['scoreBreakdown'],
    recommendations: metadata?['recommendations'],
    warnings: metadata?['warnings'],
    luckyItems: metadata?['luckyItems'],
    luckyColor: metadata?['luckyColor'],
    luckyNumber: metadata?['luckyNumber'],
    categories: metadata?['categories'],
    sajuInsight: metadata?['sajuInsight'],
    personalActions: metadata?['personalActions'],
    // ... 모든 필드 복원
  );
}
```

---

## 🎯 최종 권장 사항

### **우선순위 1: DB 캐시를 Single Source of Truth로**
- ✅ API 응답 즉시 DB 저장
- ✅ DB 캐시 우선 로딩
- ✅ Provider는 성능 최적화용으로만 사용

### **우선순위 2: 데이터 검증 강화**
- ✅ `_isValidFortuneData()` 함수 구현
- ✅ 필수 필드 검증 (overallScore, content, 날짜)
- ✅ 잘못된 캐시는 즉시 삭제하고 재생성

### **우선순위 3: 동기화 보장**
- ✅ DB ↔ Provider ↔ Local State 항상 동기화
- ✅ 데이터 변경 시 모든 레이어 업데이트
- ✅ 디버그 로그로 데이터 흐름 추적

---

## 🐛 디버깅 체크리스트

데이터 불일치 발생 시 확인할 항목:

### 1. DB 캐시 확인
```sql
SELECT
  fortune_date,
  fortune_type,
  fortune_data->'metadata'->>'overallScore' as score,
  created_at,
  expires_at
FROM fortune_cache
WHERE user_id = 'USER_ID'
  AND fortune_type = 'daily'
ORDER BY fortune_date DESC
LIMIT 7;
```

### 2. Provider 상태 확인
```dart
final providerState = ref.read(dailyFortuneProvider);
debugPrint('Provider fortune: ${providerState.fortune?.overallScore}');
debugPrint('Provider isLoading: ${providerState.isLoading}');
debugPrint('Provider error: ${providerState.error}');
```

### 3. 로컬 상태 확인
```dart
debugPrint('Local todaysFortune: ${todaysFortune?.overallScore}');
debugPrint('Local storySegments: ${storySegments?.length}');
debugPrint('Local isLoadingFortune: $isLoadingFortune');
```

### 4. 데이터 흐름 로그
```dart
// 로딩 시작
debugPrint('🔵 [DATA FLOW] Loading started');

// 캐시 체크
debugPrint('📦 [DATA FLOW] Cache check: ${cachedData != null}');

// Provider 체크
debugPrint('📊 [DATA FLOW] Provider check: ${hasProviderFortune}');

// API 호출
debugPrint('📡 [DATA FLOW] API call initiated');

// 저장 완료
debugPrint('✅ [DATA FLOW] Data saved to DB');
```

---

## 📌 결론

**문제의 핵심**:
- Provider(메모리)와 DB 캐시의 우선순위가 불명확
- 데이터 변환 시 필드 손실
- 동기화 부재

**해결책**:
1. **DB 캐시를 Single Source of Truth로 설정**
2. **FortuneModel 변환 시 모든 데이터 보존**
3. **모든 상태 레이어를 항상 동기화**

이 방식으로 수정하면 **"API에서 가져온 값을 유지하고 이후에도 그대로 보여주기"** 목표를 달성할 수 있습니다.
