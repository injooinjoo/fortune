# 운세 API 개발 체크리스트 (완전판)

> **목적**: Supabase Edge Function + Flutter 클라이언트를 **광고 → API 결정 → DB 저장 → 캐시 → 결과 표시** 전체 플로우로 일관성 있게 개발

> **핵심**: 이 체크리스트는 FortuneApiDecisionService, BaseFortunePage, AdService의 자동화를 100% 활용합니다.

---

## 📊 전체 플로우 다이어그램

```
사용자 입력
  ↓
BaseFortunePage.submitFortune()
  ↓
① 프리미엄 운세 체크 (영혼 확인)
  ↓
② AdService.showInterstitialAdWithCallback() ← 광고 표시
  ↓
③ FortuneApiService.getFortune()
  ↓
  ├─ CacheService.getCachedFortune() ← 캐시 체크
  │   └─ 캐시 있으면 즉시 반환
  ↓
  ├─ FortuneApiDecisionService.shouldCallApi() ← API vs 재사용 결정
  │   ├─ 예외 운세 (wish, dream, face-reading, ex-lover, blind-date) → 무조건 API 호출
  │   └─ 일반 운세 → 사용자 등급/시간대/중요도/랜덤 가중치로 확률 계산
  │        ├─ API 호출 결정 → Edge Function 호출
  │        └─ 재사용 결정 → getSimilarFortune() → personalizeFortune()
  ↓
  ├─ Supabase Edge Function (/api/fortune/{타입})
  │   ├─ fortune_cache 테이블 조회
  │   ├─ OpenAI GPT-4 API 호출
  │   └─ fortune_cache에 결과 저장
  ↓
④ BaseFortunePage._saveFortuneToHistory() ← DB 저장 (fortune_history 테이블)
  ↓
⑤ 결과 화면 표시 (자동 렌더링)
```

---

## 📋 Phase 0: 개발 전 준비

### ✅ 필수 확인 사항

- [ ] **운세 타입 이름** (kebab-case): `avoid-people`, `moving`, `birth-season`
- [ ] **fortuneType 값** (route와 동일): `'avoid-people'`
- [ ] **사용자 입력 파라미터** 목록 작성 (Request Interface용)
- [ ] **출력 데이터 구조** 설계 (Response Interface용)
  - 필수: `overallScore` (number, 0-100)
  - 필수: `content` (string, 전체 분석)
  - 선택: 운세 타입별 커스텀 필드들
- [ ] **로그인 필요 여부** (`requiresUserInfo: true/false`)

### 🎯 중요한 결정

#### 1. Decision Service 예외 여부
```dart
// lib/data/services/fortune_api_service.dart:897
const alwaysCallApiTypes = ['wish', 'dream', 'face-reading', 'ex-lover', 'blind-date'];
```
- [ ] **예외 운세인가?** (항상 새로운 API 호출)
  - YES → 위 배열에 추가 필요
  - NO → FortuneApiDecisionService가 자동으로 API vs 재사용 결정

#### 2. Decision Service 중요도 설정
```dart
// lib/data/services/fortune_api_decision_service.dart:110-144
```
- [ ] **운세 중요도** 분류:
  - **High (50%)**: love, health, investment, exam
  - **Medium (30%)**: dream, traditional_saju, family, moving, wish
  - **Low (10%)**: fortune_cookie, talisman, biorhythm, person_to_avoid, ex_fortune, blind_date
  - **Default (20%)**: 기타

#### 3. 프리미엄 운세 여부
```dart
// lib/core/constants/soul_rates.dart
```
- [ ] **프리미엄 운세인가?** (영혼 소모)
  - YES → SoulRates에 등록 필요
  - NO → 무료 운세

---

## 🚀 Phase 1: Supabase Edge Function 개발

### A. 디렉토리 및 파일 생성

```bash
mkdir -p supabase/functions/fortune-{타입}/
touch supabase/functions/fortune-{타입}/index.ts
```

- [ ] 디렉토리 생성 완료
- [ ] `index.ts` 파일 생성 완료

### B. Edge Function 코드 작성 (index.ts)

#### 1. Import & CORS Headers (필수)
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```
- [ ] Import 문 작성 완료
- [ ] CORS Headers 정의 완료

#### 2. Request/Response Interface (필수)
```typescript
interface {타입}Request {
  // 입력 파라미터들
  param1: string;
  param2: number;
  userId?: string;  // 항상 optional로
}
```
- [ ] Request Interface 정의 완료
- [ ] Response 구조 설계 완료 (overallScore, content 필수)

#### 3. OPTIONS 요청 처리 (필수)
```typescript
if (req.method === 'OPTIONS') {
  return new Response('ok', { headers: corsHeaders })
}
```
- [ ] OPTIONS 핸들러 작성 완료

#### 4. Supabase Client 초기화 (필수)
```typescript
const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? '',
)
```
- [ ] Supabase Client 생성 완료

#### 5. 캐시 Key 생성 & fortune_cache 조회 (필수)
```typescript
const today = new Date().toISOString().split('T')[0]
const cacheKey = `${userId || 'anonymous'}_${fortuneType}_${today}_${주요파라미터해시}`

const { data: cachedResult } = await supabaseClient
  .from('fortune_cache')
  .select('result')
  .eq('cache_key', cacheKey)
  .eq('fortune_type', '{타입}')
  .single()

if (cachedResult) {
  return new Response(JSON.stringify({ success: true, data: cachedResult.result }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  })
}
```
- [ ] Cache Key 로직 작성 완료
- [ ] fortune_cache 조회 로직 완료
- [ ] 캐시 히트 시 즉시 반환 완료

#### 6. OpenAI API 호출 (필수)
```typescript
const controller = new AbortController()
const timeoutId = setTimeout(() => controller.abort(), 30000)

try {
  const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: `당신은 {운세 전문가} 입니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수,
  "content": "전체 분석 (200자 내외)",
  "추가필드": "..."
}`
        },
        {
          role: 'user',
          content: `입력: ${param1}\n날짜: ${new Date().toLocaleDateString('ko-KR')}`
        }
      ],
      response_format: { type: "json_object" },
      temperature: 0.7,
      max_tokens: 1500
    }),
    signal: controller.signal
  })

  if (!openaiResponse.ok) {
    throw new Error(`OpenAI API error: ${openaiResponse.status}`)
  }

  const openaiResult = await openaiResponse.json()
  const fortuneData = JSON.parse(openaiResult.choices[0].message.content)
} finally {
  clearTimeout(timeoutId)
}
```
- [ ] AbortController 타임아웃 설정 완료
- [ ] System Prompt 작성 완료 (역할, JSON 형식 명시)
- [ ] User Prompt 작성 완료 (입력 파라미터 포맷팅)
- [ ] temperature: 0.7-0.8 설정 완료
- [ ] max_tokens: 1500 설정 완료
- [ ] response_format: json_object 설정 완료
- [ ] 타임아웃 정리 (finally 블록) 완료

#### 7. fortune_cache에 결과 저장 (필수)
```typescript
const result = {
  ...fortuneData,
  timestamp: new Date().toISOString()
}

await supabaseClient
  .from('fortune_cache')
  .insert({
    cache_key: cacheKey,
    fortune_type: '{타입}',
    user_id: userId || null,
    result: result,
    created_at: new Date().toISOString()
  })

return new Response(JSON.stringify({ success: true, data: result }), {
  headers: { ...corsHeaders, 'Content-Type': 'application/json' }
})
```
- [ ] Result 객체 생성 완료 (timestamp 포함)
- [ ] fortune_cache INSERT 완료
- [ ] 성공 응답 반환 완료

#### 8. 에러 처리 (필수)
```typescript
} catch (error) {
  console.error('{타입} Fortune API Error:', error)
  return new Response(
    JSON.stringify({
      success: false,
      error: '운세 생성 중 오류가 발생했습니다.',
      details: error instanceof Error ? error.message : String(error)
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
  )
}
```
- [ ] Error 로깅 완료
- [ ] Error 응답 반환 완료

### C. 배포 및 테스트

```bash
# 1. Edge Function 배포
npx supabase functions deploy fortune-{타입}

# 2. 환경 변수 확인
npx supabase secrets list

# 3. 프로덕션 테스트
curl -X POST https://your-project.supabase.co/functions/v1/fortune-{타입} \
  -H "Content-Type: application/json" \
  -d '{"param1":"value","userId":"test"}'
```

- [ ] 배포 성공 확인
- [ ] 환경 변수 (OPENAI_API_KEY) 설정 확인
- [ ] curl 테스트 성공
- [ ] 캐시 동작 테스트 (같은 입력 2회 호출 → 2번째는 캐시 반환)

---

## 📱 Phase 2: Flutter 클라이언트 개발

### A. 파일 생성

```bash
touch lib/features/fortune/presentation/pages/{타입}_fortune_page.dart
```

- [ ] Fortune Page 파일 생성 완료

### B. BaseFortunePage 상속 구조

#### 1. Import 문
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../base/base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/fortune_api_service_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../widgets/standard_fortune_app_bar.dart';
```
- [ ] 필수 import 완료

#### 2. 클래스 정의
```dart
class {타입}FortunePage extends BaseFortunePage {
  const {타입}FortunePage({super.key})
      : super(
          title: '운세 제목',
          description: '운세 설명',
          fortuneType: '{타입}',  // Edge Function 경로와 일치!
          requiresUserInfo: true/false,
        );

  @override
  State<{타입}FortunePage> createState() => _{타입}FortunePageState();
}

class _{타입}FortunePageState extends BaseFortunePageState<{타입}FortunePage> {
  // 입력 State 변수들
  String? _selectedValue;
  int _sliderValue = 3;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final apiService = ref.read(fortuneApiServiceProvider);

    // requiresUserInfo가 true인 경우 userId 체크
    String userId = 'anonymous';
    if (widget.requiresUserInfo) {
      final user = ref.read(userProvider).value;
      if (user == null) throw Exception('로그인이 필요합니다');
      userId = user.id;
    }

    // FortuneApiService.getFortune() 호출 (자동으로 Decision Service, 캐시, DB 저장 처리)
    final fortune = await apiService.getFortune(
      userId: userId,
      fortuneType: widget.fortuneType,
      params: params,
    );

    return fortune;
  }

  @override
  Widget build(BuildContext context) {
    // BaseFortunePage가 자동으로 처리하는 상태들
    if (fortune != null || isLoading || error != null) {
      return super.build(context);  // 결과/로딩/에러 화면 자동 렌더링
    }

    // 커스텀 입력 UI
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossTheme.backgroundPrimary,
      appBar: StandardFortuneAppBar(
        title: widget.title,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 입력 위젯들...

            TossButton(
              text: '운세 보기',
              onPressed: () {
                submitFortune({
                  'param1': _selectedValue,
                  'param2': _sliderValue,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
```
- [ ] BaseFortunePage 상속 완료
- [ ] super() 호출 (title, description, fortuneType, requiresUserInfo) 완료
- [ ] State 클래스 정의 완료
- [ ] 입력 State 변수 선언 완료
- [ ] `generateFortune()` 구현 완료
- [ ] `build()` 메서드 구현 완료
- [ ] 커스텀 입력 UI 작성 완료
- [ ] `submitFortune()` 호출 완료

### C. BaseFortunePage 자동화 이해

#### BaseFortunePage가 자동으로 처리하는 것들:

1. **프리미엄 운세 체크** (lines 294-320)
   - SoulRates.isPremiumFortune() 체크
   - 영혼 부족 시 TokenInsufficientModal 표시
   - 무료 운세는 자동 통과

2. **광고 표시** (lines 339-342)
   - AdService.instance.showInterstitialAdWithCallback()
   - 광고 성공/실패 모두 운세 생성 진행

3. **운세 생성 흐름** (lines 343-380)
   - `generateFortune()` 호출 (개발자가 구현)
   - Fortune 엔티티 반환

4. **DB 저장** (lines 166-226)
   - `_saveFortuneToHistory()` 자동 호출
   - fortune_history 테이블에 INSERT
   - 메타데이터, 태그 자동 생성

5. **결과 화면** (자동 렌더링)
   - fortune != null일 때 자동으로 결과 UI 표시
   - 공유 버튼, 재시도 버튼 자동 포함

6. **에러 처리** (자동)
   - error != null일 때 에러 UI 표시
   - 재시도 버튼 자동 포함

### D. FortuneApiService 자동화 이해

#### FortuneApiService.getFortune()이 자동으로 처리하는 것들:

1. **캐시 체크** (lines 874-886)
   - CacheService.getCachedFortune()
   - 캐시 히트 시 즉시 반환

2. **Decision Service** (lines 888-941)
   - 예외 운세 체크 (`alwaysCallApiTypes`)
   - shouldCallApi() 확률 계산
   - API 호출 or 재사용 결정

3. **유사 운세 재사용** (lines 907-941)
   - getSimilarFortune() (성별, 나이대, MBTI 매칭)
   - personalizeFortune() (이름, 날짜 교체)
   - 재사용 결과도 캐시에 저장

4. **API 호출** (lines 943-997)
   - Edge Function `/api/fortune/{타입}` 호출
   - FortuneResponseModel 파싱
   - Fortune 엔티티 변환

5. **캐시 저장** (lines 983-989)
   - _cacheService.cacheFortune()
   - 다음 호출 시 캐시 반환

---

## ✅ Phase 3: 최종 검증

### A. Edge Function 검증

- [ ] 배포 성공 (`npx supabase functions deploy fortune-{타입}`)
- [ ] curl 테스트 성공 (JSON 응답 확인)
- [ ] 캐시 테스트 (같은 입력 2회 → 2번째는 빠른 응답)
- [ ] 에러 테스트 (잘못된 입력 → 500 에러 반환)
- [ ] OpenAI 타임아웃 테스트 (30초 후 abort)

### B. Flutter 클라이언트 검증

```bash
# 1. Analyze
flutter analyze

# 2. Hot Restart 테스트
flutter run -d {device}  # 'R' 키로 Hot Restart

# 3. 릴리즈 빌드 테스트
flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_{타입}_test.txt
```

- [ ] `flutter analyze` 통과 (에러 0개)
- [ ] Hot Restart 정상 동작
- [ ] 입력 → 광고 → API 호출 → 결과 표시 전체 플로우 테스트
- [ ] 로그인 필요한 운세: 로그인 후 테스트
- [ ] 로그인 불필요한 운세: 미로그인 상태 테스트
- [ ] 프리미엄 운세: 영혼 부족 시 모달 표시 확인
- [ ] 릴리즈 빌드 실제 디바이스 테스트 성공

### C. DB & 캐시 검증

**Supabase 대시보드에서 확인:**

1. **fortune_cache 테이블**
```sql
SELECT cache_key, fortune_type, created_at
FROM fortune_cache
WHERE fortune_type = '{타입}'
ORDER BY created_at DESC
LIMIT 10;
```
- [ ] fortune_cache에 결과 저장 확인
- [ ] cache_key 형식 확인 (userId_타입_날짜_파라미터)
- [ ] result JSON 구조 확인 (overallScore, content 필수)

2. **fortune_history 테이블**
```sql
SELECT id, fortune_type, title, score, created_at
FROM fortune_history
WHERE fortune_type = '{타입}'
ORDER BY created_at DESC
LIMIT 10;
```
- [ ] fortune_history에 결과 저장 확인
- [ ] title, summary, fortune_data 정상 저장
- [ ] metadata에 fortuneParams, userParams 저장 확인
- [ ] tags 자동 생성 확인 (운세명, 연월, 점수 등급)

### D. Decision Service 검증

**로그 확인:**
```
🎲 [API Decision] Should call API: true/false
  - userGradeScore: 0.80
  - importanceScore: 0.30
  - timeScore: 0.50
  - randomScore: 0.45
  - finalProbability: 0.62
```

- [ ] Decision Service 로그 출력 확인
- [ ] 예외 운세는 항상 API 호출 (alwaysCallApiTypes)
- [ ] 일반 운세는 확률적 결정
- [ ] 재사용 시 getSimilarFortune() 로그 확인
- [ ] 개인화 적용 (이름, 날짜 교체) 확인

---

## 🎯 성공 기준 요약

### Edge Function
✅ 배포 성공
✅ fortune_cache 조회/저장 동작
✅ OpenAI API 호출 성공
✅ JSON 응답 형식 정확
✅ 에러 핸들링 동작

### Flutter Client
✅ BaseFortunePage 상속 정확
✅ generateFortune() 구현 정확
✅ submitFortune() 호출 정상
✅ 광고 → API → 결과 플로우 정상
✅ DB 저장 자동 완료

### 전체 플로우
✅ 캐시 히트 시 즉시 반환
✅ Decision Service 동작 (예외 vs 일반)
✅ 유사 운세 재사용 동작 (일반 운세만)
✅ fortune_history 저장 완료
✅ 결과 화면 정상 렌더링

---

## 🔧 문제 해결 가이드

### 1. "API 호출 실패" 에러
**원인**: Edge Function 미배포 또는 fortuneType 불일치
**해결**:
```bash
# 배포 확인
npx supabase functions list

# fortuneType 일치 확인
Flutter: fortuneType: 'avoid-people'
Edge Function: /api/fortune/avoid-people
```

### 2. "fortune_cache 테이블 없음" 에러
**원인**: 마이그레이션 미실행
**해결**:
```bash
npx supabase db push
```

### 3. "Decision Service 동작 안 함" 에러
**원인**: alwaysCallApiTypes에 타입 추가 필요
**해결**: `lib/data/services/fortune_api_service.dart:897` 수정

### 4. "DB 저장 안 됨" 에러
**원인**: BaseFortunePage._saveFortuneToHistory() 미호출
**해결**: BaseFortunePage 상속 확인, generateFortune() 정상 반환 확인

---

## 📚 참고 파일 목록

### Edge Function 참고
- `supabase/functions/fortune-mbti/index.ts` (표준 템플릿)
- `supabase/functions/fortune-avoid-people/index.ts` (최신 예시)

### Flutter Client 참고
- `lib/features/fortune/presentation/pages/base_fortune_page.dart` (Base 클래스)
- `lib/features/fortune/presentation/pages/avoid_people_fortune_page.dart` (구현 예시)
- `lib/features/fortune/presentation/pages/birth_season_fortune_page.dart` (구현 예시)
- `lib/features/fortune/presentation/pages/birthdate_fortune_page.dart` (복잡한 입력 예시)

### Service 참고
- `lib/data/services/fortune_api_service.dart` (lines 858-1000: getFortune 로직)
- `lib/data/services/fortune_api_decision_service.dart` (전체: Decision 로직)
- `lib/services/ad_service.dart` (광고 로직)
- `lib/services/fortune_history_service.dart` (DB 저장 로직)

### DB 참고
- `supabase/migrations/20250829000001_create_fortune_history_table.sql`

---

## 💡 개발 팁

1. **Edge Function 먼저 개발하고 테스트**: Flutter 개발 전에 curl로 완전히 검증
2. **fortune-mbti를 템플릿으로 사용**: 가장 표준적이고 안정적인 구조
3. **fortuneType 일치 필수**: Flutter와 Edge Function 경로 반드시 일치
4. **캐시 키 설계 신중히**: 너무 세밀하면 캐시 히트율 낮음, 너무 넓으면 부정확
5. **System Prompt 상세히**: GPT-4 응답 품질은 프롬프트에 비례
6. **Decision Service 활용**: 예외가 아닌 일반 운세는 자동 최적화
7. **BaseFortunePage 신뢰**: DB 저장, 광고, 에러 처리 모두 자동
8. **로그 확인 습관화**: Logger.info로 전체 플로우 추적 가능

---

**마지막 업데이트**: 2025-01-08
**작성자**: Claude Code
**버전**: 2.0 (완전판)
