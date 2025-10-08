# 운세 API 개발 체크리스트 (Supabase Edge Function)

> **목적**: 각 운세 타입별로 Supabase Edge Function과 Flutter 클라이언트를 일관성 있게 개발하기 위한 표준 체크리스트

---

## 📋 개발 전 준비

### 1. 운세 타입 정보 확인
- [ ] 운세 타입 이름 결정 (예: `avoid-people`, `moving`, `birth-season`)
- [ ] 사용자 입력 파라미터 목록 작성
- [ ] 출력 데이터 구조 설계 (overallScore, content, 추가 필드들)
- [ ] 로그인 필요 여부 결정 (`requiresUserInfo: true/false`)

### 2. 참고 문서 확인
- [ ] 기존 Edge Function 예시 읽기: `supabase/functions/fortune-mbti/index.ts`
- [ ] BaseFortunePage 사용법 확인: `lib/features/fortune/presentation/base/base_fortune_page.dart`
- [ ] DB 스키마 확인: `supabase/migrations/20250829000001_create_fortune_history_table.sql`

---

## 🚀 Phase 1: Supabase Edge Function 개발

### A. 파일 구조 생성

```bash
# 1. 함수 디렉토리 생성
mkdir -p supabase/functions/fortune-{타입}/

# 2. index.ts 파일 생성
touch supabase/functions/fortune-{타입}/index.ts
```

- [ ] `supabase/functions/fortune-{타입}/` 디렉토리 생성 완료
- [ ] `index.ts` 파일 생성 완료

---

### B. 기본 코드 구조 (index.ts)

#### 1. Import 문
```typescript
- [ ] import serve from "https://deno.land/std@0.168.0/http/server.ts"
- [ ] import createClient from 'https://esm.sh/@supabase/supabase-js@2'
```

#### 2. CORS Headers 정의
```typescript
- [ ] corsHeaders 객체 생성
  - Access-Control-Allow-Origin: '*'
  - Access-Control-Allow-Headers: 'authorization, x-client-info, apikey, content-type'
```

#### 3. Request Interface 정의
```typescript
- [ ] interface 이름: {타입}Request (예: AvoidPeopleRequest)
- [ ] 모든 입력 파라미터 정의
- [ ] userId?: string (optional) 포함
```

**예시**:
```typescript
interface AvoidPeopleRequest {
  environment: string;
  importantSchedule: string;
  moodLevel: number;
  stressLevel: number;
  socialFatigue: number;
  hasImportantDecision: boolean;
  hasSensitiveConversation: boolean;
  hasTeamProject: boolean;
  userId?: string;
}
```

#### 4. Response Interface 정의
```typescript
- [ ] 출력 데이터 구조 정의
- [ ] overallScore: number (0-100)
- [ ] content: string (전체 분석)
- [ ] timestamp: string (ISO 8601)
- [ ] 추가 필드들 (운세 타입별 커스텀)
```

---

### C. 핸들러 함수 구현

#### 1. OPTIONS 요청 처리
```typescript
- [ ] if (req.method === 'OPTIONS') 체크
- [ ] return new Response('ok', { headers: corsHeaders })
```

#### 2. Supabase Client 초기화
```typescript
- [ ] createClient() 호출
- [ ] Deno.env.get('SUPABASE_URL')
- [ ] Deno.env.get('SUPABASE_ANON_KEY')
```

#### 3. Request 데이터 추출
```typescript
- [ ] const requestData = await req.json()
- [ ] 모든 파라미터 destructuring
```

#### 4. Cache Key 생성
```typescript
- [ ] const today = new Date().toISOString().split('T')[0]
- [ ] const cacheKey 생성 (userId + fortuneType + today + 주요 파라미터)
```

**예시**:
```typescript
const cacheKey = `${userId || 'anonymous'}_avoid-people_${today}_${JSON.stringify({
  environment,
  moodLevel,
  stressLevel
})}`
```

#### 5. Cache 조회
```typescript
- [ ] supabaseClient.from('fortune_cache').select('result')
- [ ] .eq('cache_key', cacheKey)
- [ ] .eq('fortune_type', '{타입}')
- [ ] .single()
- [ ] 캐시 존재 시 즉시 반환
```

#### 6. OpenAI API 호출 준비
```typescript
- [ ] const controller = new AbortController()
- [ ] const timeoutId = setTimeout(() => controller.abort(), 30000)
- [ ] try-catch-finally 블록 구성
```

#### 7. OpenAI API 요청
```typescript
- [ ] fetch('https://api.openai.com/v1/chat/completions')
- [ ] method: 'POST'
- [ ] headers:
  - Authorization: Bearer ${Deno.env.get('OPENAI_API_KEY')}
  - Content-Type: application/json
- [ ] body: JSON.stringify({ ... })
  - model: 'gpt-4-turbo-preview'
  - messages: [시스템 프롬프트, 사용자 프롬프트]
  - response_format: { type: "json_object" }
  - temperature: 0.7-0.8
  - max_tokens: 1500
- [ ] signal: controller.signal
```

#### 8. System Prompt 작성
```typescript
- [ ] role: 'system'
- [ ] content: 운세 전문가 역할 정의
- [ ] JSON 응답 형식 명시
- [ ] 각 필드 설명 상세히 작성
```

**예시**:
```typescript
{
  role: 'system',
  content: `당신은 심리학과 대인관계 전문가입니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수,
  "content": "전체적인 분석 (200자 내외)",
  "추가필드들": "..."
}`
}
```

#### 9. User Prompt 작성
```typescript
- [ ] role: 'user'
- [ ] content: 입력 파라미터들을 포맷팅
- [ ] 날짜 정보 포함: new Date().toLocaleDateString('ko-KR')
```

**예시**:
```typescript
{
  role: 'user',
  content: `환경: ${environment}
중요 일정: ${importantSchedule}
기분 상태: ${moodLevel}/5
날짜: ${new Date().toLocaleDateString('ko-KR')}`
}
```

#### 10. 응답 처리
```typescript
- [ ] !openaiResponse.ok 체크 및 에러 처리
- [ ] const openaiResult = await openaiResponse.json()
- [ ] const fortuneData = JSON.parse(openaiResult.choices[0].message.content)
```

#### 11. Result 객체 생성
```typescript
- [ ] const result = { ...fortuneData, timestamp: new Date().toISOString() }
```

#### 12. Cache 저장
```typescript
- [ ] supabaseClient.from('fortune_cache').insert({...})
  - cache_key: cacheKey
  - fortune_type: '{타입}'
  - user_id: userId || null
  - result: result
  - created_at: new Date().toISOString()
```

#### 13. 성공 응답
```typescript
- [ ] return new Response(JSON.stringify({ success: true, data: result }))
- [ ] headers: { ...corsHeaders, 'Content-Type': 'application/json' }
```

#### 14. 에러 처리
```typescript
- [ ] catch 블록에서 에러 로깅
- [ ] console.error('{타입} Fortune API Error:', error)
- [ ] return new Response(JSON.stringify({ success: false, error, details }))
- [ ] status: 500
```

#### 15. Finally 블록
```typescript
- [ ] clearTimeout(timeoutId)
```

---

### D. 테스트 및 배포

#### 1. 로컬 테스트 (선택사항)
```bash
- [ ] supabase functions serve fortune-{타입} --env-file .env.local
- [ ] curl 또는 Postman으로 테스트
```

#### 2. Supabase 배포
```bash
- [ ] npx supabase functions deploy fortune-{타입}
- [ ] 배포 성공 메시지 확인
```

#### 3. 환경 변수 설정
```bash
- [ ] OPENAI_API_KEY 설정 확인
- [ ] npx supabase secrets list
```

#### 4. 프로덕션 테스트
```bash
- [ ] curl로 프로덕션 엔드포인트 테스트
- [ ] 응답 JSON 구조 검증
```

---

## 📱 Phase 2: Flutter 클라이언트 개발

### A. 파일 구조

```bash
# 파일 생성
touch lib/features/fortune/presentation/pages/{타입}_fortune_page.dart
```

- [ ] `{타입}_fortune_page.dart` 파일 생성 완료

---

### B. BaseFortunePage 상속 구조

#### 1. Import 문
```dart
- [ ] import 'package:flutter/material.dart';
- [ ] import 'package:flutter_riverpod/flutter_riverpod.dart';
- [ ] import '../base/base_fortune_page.dart';
- [ ] import '../../../../domain/entities/fortune.dart';
- [ ] import '../../../providers/user_provider.dart';
- [ ] import '../../../providers/fortune_api_service_provider.dart';
```

#### 2. 클래스 정의
```dart
- [ ] class {타입}FortunePage extends BaseFortunePage
- [ ] const 생성자 정의
- [ ] super() 호출:
  - title: '운세 제목'
  - description: '운세 설명'
  - fortuneType: '{타입}'
  - requiresUserInfo: true/false
```

**예시**:
```dart
class AvoidPeopleFortunePage extends BaseFortunePage {
  const AvoidPeopleFortunePage({super.key})
      : super(
          title: '피해야할 사람',
          description: '오늘 주의해야 할 사람 유형을 알려드립니다',
          fortuneType: 'avoid-people',
          requiresUserInfo: true,
        );

  @override
  State<AvoidPeopleFortunePage> createState() => _AvoidPeopleFortunePageState();
}
```

#### 3. State 클래스 정의
```dart
- [ ] class _{타입}FortunePageState extends BaseFortunePageState<{타입}FortunePage>
- [ ] 입력 파라미터를 위한 State 변수 선언
```

---

### C. generateFortune() 메서드 구현

```dart
- [ ] @override
- [ ] Future<Fortune> generateFortune(Map<String, dynamic> params) async
- [ ] final user = ref.read(userProvider).value
- [ ] requiresUserInfo가 true인 경우:
  - if (user == null) throw Exception('로그인이 필요합니다')
- [ ] final apiService = ref.read(fortuneApiServiceProvider)
- [ ] final fortune = await apiService.getFortune(
      userId: user?.id ?? 'anonymous',
      fortuneType: widget.fortuneType,
      params: params,
    )
- [ ] return fortune
```

**예시**:
```dart
@override
Future<Fortune> generateFortune(Map<String, dynamic> params) async {
  final user = ref.read(userProvider).value;
  if (user == null) throw Exception('로그인이 필요합니다');

  final apiService = ref.read(fortuneApiServiceProvider);
  final fortune = await apiService.getFortune(
    userId: user.id,
    fortuneType: widget.fortuneType,
    params: params,
  );
  return fortune;
}
```

---

### D. build() 메서드 구현 (Custom UI)

```dart
- [ ] @override
- [ ] Widget build(BuildContext context)
- [ ] if (fortune != null || isLoading || error != null) {
      return super.build(context);  // BaseFortunePage가 자동 처리
    }
- [ ] 커스텀 입력 UI 구현
  - Scaffold with StandardFortuneAppBar
  - 입력 폼/위젯들
  - Submit 버튼 (submitFortune(params) 호출)
```

**예시**:
```dart
@override
Widget build(BuildContext context) {
  // BaseFortunePage가 자동으로 처리 (결과 표시, 로딩, 에러)
  if (fortune != null || isLoading || error != null) {
    return super.build(context);
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
          // 입력 폼들...
          TossButton(
            text: '운세 보기',
            onPressed: () {
              submitFortune({
                'environment': _selectedEnvironment,
                'moodLevel': _moodLevel,
                // ... 모든 파라미터
              });
            },
          ),
        ],
      ),
    ),
  );
}
```

---

### E. FortuneApiService 연동 확인

#### 기존 getFortune() 메서드 활용
```dart
- [ ] FortuneApiService.getFortune() 메서드가 자동으로 호출됨
- [ ] Decision Service 통합 (캐시 vs API 자동 선택)
- [ ] API 엔드포인트: /api/fortune/{fortuneType}
- [ ] DB 저장은 BaseFortunePage._saveFortuneToHistory()가 자동 처리
```

**FortuneApiService.getFortune() 흐름**:
1. Decision Service가 캐시 vs API 선택
2. API 호출 시: `/api/fortune/{fortuneType}` 엔드포인트 호출
3. 응답을 Fortune 엔티티로 변환
4. 자동으로 `fortune_history` 테이블에 저장

---

## ✅ 최종 검증 체크리스트

### 1. Edge Function 검증
- [ ] 배포 성공 확인
- [ ] curl로 프로덕션 테스트 성공
- [ ] 캐시 동작 확인 (같은 입력 2회 호출 시 캐시 반환)
- [ ] 에러 핸들링 테스트 (잘못된 입력, OpenAI 타임아웃 등)

### 2. Flutter 클라이언트 검증
- [ ] `flutter analyze` 통과
- [ ] Hot Restart로 전체 플로우 테스트
- [ ] 입력 → API 호출 → 결과 표시 정상 동작
- [ ] DB 저장 확인 (Supabase fortune_history 테이블 조회)
- [ ] 캐시 동작 확인 (같은 입력 재시도)

### 3. 통합 테스트
- [ ] 실제 디바이스에서 릴리즈 빌드 테스트
```bash
flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_{타입}_test.txt
```
- [ ] 로그인 필요한 운세: 로그인 후 테스트
- [ ] 로그인 불필요한 운세: 미로그인 상태 테스트
- [ ] 광고 표시 확인 (AdService 연동)
- [ ] fortune_history 테이블에 데이터 저장 확인

### 4. JIRA 완료 처리
- [ ] Git 커밋 및 푸시
- [ ] JIRA 티켓 완료 처리
```bash
./scripts/git_jira_commit.sh "feat: {타입} 운세 API 및 클라이언트 구현" "KAN-XXX" "done"
```

---

## 📚 참고 문서

### 1. 기존 구현 예시
- **Edge Function 예시**: `supabase/functions/fortune-mbti/index.ts`
- **Flutter 예시**:
  - `lib/features/fortune/presentation/pages/avoid_people_fortune_page.dart`
  - `lib/features/fortune/presentation/pages/birth_season_fortune_page.dart`
  - `lib/features/fortune/presentation/pages/birthdate_fortune_page.dart`

### 2. 핵심 파일
- **BaseFortunePage**: `lib/features/fortune/presentation/base/base_fortune_page.dart`
- **FortuneApiService**: `lib/data/services/fortune_api_service.dart`
- **Fortune Entity**: `lib/domain/entities/fortune.dart`
- **DB Schema**: `supabase/migrations/20250829000001_create_fortune_history_table.sql`

### 3. 개발 가이드
- **CLAUDE.md**: 프로젝트 전체 개발 규칙
- **docs/data/DATABASE_GUIDE.md**: Supabase DB 사용법
- **docs/data/API_USAGE.md**: API 호출 패턴

---

## 🎯 다음 개발할 운세 목록

**현재 완료** (Edge Function + Flutter):
1. ✅ avoid-people (피해야할 사람)

**개발 대기** (Edge Function 미구현):
2. ⏳ moving (이사운)
3. ⏳ birth-season (태어난 계절 운세)
4. ⏳ birthdate (생일 운세)

**낮은 우선순위** (복잡한 구조):
- palmistry (손금 운세) - 872 lines
- biorhythm (바이오리듬) - 3-page 구조
- love (연애운) - 4-step input
- traditional_saju, talisman, same_birthday_celebrity

---

## 💡 개발 팁

1. **Edge Function 먼저 개발**: Flutter 클라이언트보다 서버 API를 먼저 완성하고 테스트
2. **fortune-mbti를 템플릿으로 사용**: 가장 표준적인 구조
3. **캐시 키 설계 신중히**: 캐시 히트율에 영향, 주요 파라미터만 포함
4. **System Prompt 상세히 작성**: GPT-4 응답 품질에 직접적 영향
5. **에러 로깅 충실히**: Supabase 로그에서 디버깅 필수
6. **BaseFortunePage 활용**: DB 저장, 광고, 에러 처리 자동화
7. **requiresUserInfo 정확히 설정**: 로그인 필요 여부에 따라 UX 달라짐

---

**마지막 업데이트**: 2025-01-06
**작성자**: Claude Code
**버전**: 1.0
