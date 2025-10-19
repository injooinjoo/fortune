# Fortune Flutter App - Claude Code 개발 규칙

## 🚫 **FLUTTER 실행 금지 규칙 (CRITICAL)** 🚫

**Claude는 절대로 Flutter를 직접 실행하지 않습니다!**

### ❌ 금지 명령어
```bash
flutter run
flutter run --release
flutter run -d [device-id]
```

### ✅ 올바른 워크플로우
1. **Claude**: 코드 수정 완료 후 "Flutter를 실행해서 테스트해주세요" 요청
2. **사용자**: 직접 `flutter run --release -d 00008140-00120304260B001C` 실행
3. **사용자**: 로그를 Claude에게 전달
4. **Claude**: 로그를 분석하고 문제 해결

**이유**: Claude가 Flutter를 실행하면 로그를 제대로 확인할 수 없어 디버깅이 불가능합니다.

---

## 🔴 **에러 로그 근본 원인 분석 원칙 (CRITICAL - PRIORITY #1)** 🔴

**에러 로그가 발생하면, 에러 로그를 숨기거나 제거하려는 것이 아니라, 에러가 발생하지 않도록 근본 원인을 해결합니다!**

### 📋 **에러 발생 시 필수 분석 프로세스**

#### 1️⃣ **왜 에러가 발생했는지 근본 원인 파악 (Root Cause Analysis)**
```
잘못된 접근 ❌:
에러: "Null check operator used on a null value"
→ try-catch로 에러 무시 (WRONG!)
→ if (value != null) 조건만 추가 (WRONG!)

올바른 접근 ✅:
에러: "Null check operator used on a null value"
→ 1️⃣ 왜 null이 들어왔는지 추적
   - 데이터가 아직 로드되지 않았나?
   - API 응답이 잘못되었나?
   - 초기화가 제대로 안됐나?
→ 2️⃣ 다른 곳에서도 동일한 패턴이 있는지 검색
→ 3️⃣ 유사한 케이스는 어떻게 처리했는지 확인
→ 4️⃣ 근본 원인 해결 (예: 데이터 로드 대기, 기본값 설정, 초기화 로직 수정)
```

#### 2️⃣ **다른 곳에서는 발생하지 않는지 전체 코드베이스 확인**
```bash
# 예시: FutureBuilder에서 null 에러 발생 시
# 1. 전체 프로젝트에서 동일 패턴 검색
grep -r "FutureBuilder" lib/

# 2. 제대로 처리된 곳과 비교
# 잘못된 곳:
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    return Text(snapshot.data!.name);  // ❌ null일 수 있음
  }
)

# 올바른 곳:
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();  // ✅ 로딩 처리
    }
    if (snapshot.hasError) {
      return ErrorWidget(snapshot.error);  // ✅ 에러 처리
    }
    if (!snapshot.hasData) {
      return EmptyStateWidget();  // ✅ 데이터 없음 처리
    }
    return Text(snapshot.data!.name);  // ✅ 안전하게 사용
  }
)
```

#### 3️⃣ **다른 곳에서는 어떻게 유사한 문제를 해결했는지 확인**
```dart
// 예시: 비동기 데이터 로딩 패턴
// ❌ 잘못된 방식 - 에러만 숨김
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      return Text(Provider.of<UserData>(context).name);
    } catch (e) {
      return SizedBox.shrink();  // ❌ 에러 무시
    }
  }
}

// ✅ 올바른 방식 - 근본 원인 해결
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Provider가 제공되었는지 확인
    final userData = Provider.of<UserData?>(context, listen: false);

    // 2. null인 이유 명확히 처리
    if (userData == null) {
      // 로그인 필요, 데이터 로딩 중 등 명확한 상태 표시
      return LoginRequiredWidget();
    }

    // 3. 안전하게 사용
    return Text(userData.name);
  }
}
```

#### 4️⃣ **근본 원인 해결 체크리스트**

**에러 발생 시 반드시 확인할 것:**
- [ ] ✅ 왜 에러가 발생했는지 로그 추적 완료
- [ ] ✅ 동일한 패턴이 다른 곳에 있는지 검색 완료
- [ ] ✅ 유사한 케이스를 올바르게 처리한 코드 찾음
- [ ] ✅ 근본 원인을 해결하는 방향으로 수정 (에러 숨김 ❌)
- [ ] ✅ 수정 후 동일 에러가 다른 곳에서도 발생하지 않는지 확인

### 🚨 **절대 하지 말아야 할 것**

#### ❌ 에러 로그만 제거하는 행위
```dart
// ❌ WRONG - 에러만 숨김
try {
  riskyOperation();
} catch (e) {
  // 아무것도 안함 - 에러 무시
}

// ❌ WRONG - 에러만 무시
if (value != null) {  // null 체크만 추가
  // 원래 코드
}
// 왜 null이 들어오는지는 분석 안함
```

#### ❌ 증상만 치료하는 행위
```dart
// ❌ WRONG - 증상만 치료
setState(() {
  _data = snapshot.data ?? [];  // 빈 배열로 기본값만 설정
});
// 왜 data가 null인지, API가 실패했는지, 네트워크 문제인지 분석 안함
```

#### ❌ 다른 곳 확인 없이 해당 파일만 수정
```dart
// ❌ WRONG - 한 곳만 수정
// lib/features/home/home_page.dart 에서만 수정
FutureBuilder(...)  // 수정됨

// lib/features/profile/profile_page.dart 는 그대로 방치
FutureBuilder(...)  // 동일한 에러 패턴 존재!
```

### ✅ **올바른 에러 해결 프로세스**

```
1️⃣ 에러 로그 발생
   ↓
2️⃣ 근본 원인 분석
   - 왜 발생했는가?
   - 어떤 조건에서 발생하는가?
   - 데이터 흐름에서 어느 단계가 문제인가?
   ↓
3️⃣ 프로젝트 전체 검색
   - 동일한 패턴이 있는 곳 찾기
   - 올바르게 처리된 곳 찾기
   - 비교하여 차이점 파악
   ↓
4️⃣ 근본 원인 해결
   - 데이터 초기화 문제 → 초기화 로직 수정
   - API 응답 문제 → API 호출 방식 수정
   - 상태 관리 문제 → 상태 관리 개선
   ↓
5️⃣ 동일 패턴 모두 수정
   - 한 곳만 고치지 말고 전체 수정
   - 일관된 패턴 적용
   ↓
6️⃣ 검증
   - 해당 에러가 더 이상 발생하지 않는지 확인
   - 다른 곳에서도 동일 에러 없는지 확인
```

### 📊 **근본 원인 분석 예시**

#### 예시 1: Null 에러
```
❌ 증상만 치료:
if (data != null) { ... }

✅ 근본 원인 해결:
1. 왜 null인가? → API 호출 전에 접근
2. 다른 곳은? → 모든 API 호출 부분 검색
3. 올바른 패턴? → FutureBuilder로 로딩 상태 관리
4. 해결: 모든 API 호출에 FutureBuilder 적용
```

#### 예시 2: setState 에러
```
❌ 증상만 치료:
if (mounted) { setState(() {...}); }

✅ 근본 원인 해결:
1. 왜 dispose 후 호출? → 비동기 작업 완료 시점 문제
2. 다른 곳은? → 모든 비동기 setState 검색
3. 올바른 패턴? → CancelableOperation 또는 dispose에서 cancel
4. 해결: 모든 비동기 작업에 취소 로직 추가
```

#### 예시 3: IndexOutOfRange 에러
```
❌ 증상만 치료:
if (list.length > index) { ... }

✅ 근본 원인 해결:
1. 왜 인덱스 초과? → 리스트가 비어있거나 삭제됨
2. 다른 곳은? → 모든 리스트 접근 검색
3. 올바른 패턴? → isEmpty 체크 또는 try-get 패턴
4. 해결: 리스트 상태 관리 개선
```

### 🎯 **핵심 원칙**

**"에러 로그를 없애려는 것이 아니라, 에러가 발생하지 않도록 근본 원인을 해결한다"**

1. **증상 치료 금지**: try-catch로 숨기거나 조건문으로만 우회하지 말 것
2. **근본 원인 분석 필수**: 왜 에러가 발생했는지 반드시 파악
3. **전체 검색 필수**: 동일한 패턴이 다른 곳에 없는지 확인
4. **올바른 패턴 적용**: 이미 잘 처리된 곳의 패턴을 찾아 적용
5. **일관성 유지**: 한 곳만 고치지 말고 전체를 일관되게 수정

**이것이 모든 에러 처리의 최우선 원칙입니다!**

---

## 🤖 **필수 자동화 워크플로우** - 절대 건너뛰지 말 것! 🤖

### 🔴 **JIRA 등록 최우선 원칙 (CRITICAL RULE)**

**모든 개발 작업은 반드시 JIRA 티켓 생성부터 시작합니다!**

```
잘못된 순서 ❌:
사용자: "버튼 색상 바꿔줘"
→ 바로 코드 수정 시작 (WRONG!)

올바른 순서 ✅:
사용자: "버튼 색상 바꿔줘"
→ 1️⃣ JIRA 티켓 생성 (parse_ux_request.sh)
→ 2️⃣ 티켓 번호 확인 (예: KAN-123)
→ 3️⃣ 코드 수정 시작
→ 4️⃣ 완료 후 JIRA 완료 처리 (git_jira_commit.sh)
```

### 📋 **1단계: JIRA 티켓 자동 생성 (필수 선행)**

사용자의 다음 표현을 감지하면 **코드 작업 전에 반드시** `./scripts/parse_ux_request.sh` 실행:

**문제 관련**:
- **버그**: "버그", "에러", "오류", "안돼", "작동안해", "깨져", "이상해"
- **불만**: "문제야", "짜증", "불편해", "답답해"
- **성능**: "느려", "버벅여", "멈춰", "렉", "끊겨"

**개선 관련**:
- **기능**: "~하면 좋겠어", "추가해줘", "만들어줘", "구현해줘"
- **수정**: "바꿔줘", "고쳐줘", "수정해줘", "개선해줘"
- **UX**: "사용하기 어려워", "터치하기 어려워", "보기 힘들어", "불편해"
- **디자인**: "폰트", "색상", "크기", "간격", "레이아웃", "애니메이션", "디자인"

**JIRA 생성 명령어**:
```bash
./scripts/parse_ux_request.sh
```

### 2️⃣ **2단계: 개발 작업 진행**

JIRA 티켓이 생성된 후에만 코드 작업을 시작합니다.

### ✅ **3단계: JIRA 완료 처리 (필수)**

코드 수정 완료 시 **반드시** `./scripts/git_jira_commit.sh "해결내용" "JIRA번호" "done"` 실행

**완료 처리 명령어**:
```bash
./scripts/git_jira_commit.sh "버튼 색상을 TOSS 디자인 시스템으로 변경" "KAN-123" "done"
```

### 📝 **완전한 워크플로우 예시**

```
사용자: "홈 화면이 너무 느려"

Claude Code 동작:
→ 1️⃣ [자동] JIRA 등록 먼저!
   $ ./scripts/parse_ux_request.sh
   ✅ KAN-124 생성됨: "홈 화면 성능 개선"

→ 2️⃣ "JIRA KAN-124가 생성되었습니다. 이제 코드 수정을 시작합니다."

→ 3️⃣ [코드 수정 작업]
   - 홈 화면 로딩 최적화
   - 불필요한 리빌드 제거
   - 이미지 캐싱 추가

→ 4️⃣ [완료 처리]
   $ ./scripts/git_jira_commit.sh "홈 화면 로딩 최적화 완료" "KAN-124" "done"
   ✅ Git 커밋 완료
   ✅ JIRA 완료 처리

→ 5️⃣ "해결 완료! JIRA KAN-124도 완료 처리했습니다."
```

### 🚫 **절대 하지 말아야 할 것**

❌ JIRA 등록 없이 바로 코드 수정
❌ "나중에 JIRA 등록하지" 하고 코드부터 수정
❌ 작은 수정이라고 JIRA 건너뛰기
❌ JIRA 생성했는데 완료 처리 안하기

**모든 작업은 JIRA에 기록되어야 합니다!**

## 🚨 절대 금지 사항 - CRITICAL RULES 🚨

### ❌ 일괄 수정 절대 금지 (NEVER USE BATCH MODIFICATIONS)
**이 규칙을 어기면 프로젝트가 망가집니다!**

1. **Python 스크립트를 사용한 일괄 수정 금지**
   - `for file in files:` 형태의 일괄 처리 스크립트 작성 금지
   - 여러 파일을 한번에 수정하는 Python 스크립트 절대 사용 금지
   - 파일 내용을 읽어서 수정하는 Python 스크립트 작성 금지
   - **Write 도구로 Python 스크립트를 작성하는 것 자체가 금지**

2. **Shell 스크립트를 사용한 일괄 수정 금지**
   - `sed -i`, `awk`, `perl` 등을 사용한 일괄 치환 금지
   - `for` 루프를 사용한 여러 파일 동시 수정 금지
   - `grep | xargs` 조합으로 여러 파일 수정 금지

3. **정규식 일괄 치환 금지**
   - IDE의 "Replace All in Files" 기능 사용 금지
   - 정규식 패턴으로 여러 파일 동시 수정 금지

4. **자동화 스크립트 작성 금지**
   - 일괄 수정을 위한 어떠한 형태의 스크립트도 작성 금지
   - 한 파일씩 Edit 도구를 사용하여 수동으로 수정

### ✅ 올바른 수정 방법 (CORRECT MODIFICATION METHOD)
**반드시 하나씩 수정해야 합니다:**
1. 한 파일씩 열어서 확인
2. 해당 파일의 컨텍스트 이해
3. 필요한 부분만 정확히 수정
4. 수정 후 해당 파일 검증
5. 다음 파일로 이동

### 🔴 위반 시 결과 (CONSEQUENCES OF VIOLATION)
- 프로젝트 전체가 빌드 불가능한 상태가 됨
- 수많은 연쇄 에러 발생
- 복구에 몇 시간 소요
- Git 히스토리 오염

**"일괄수정안할거야. 하나씩해" - 이것이 철칙입니다!**

---

## 🤖 **OpenAI API 호출 필수 규칙 (CRITICAL)** 🤖

### 📋 **gpt-5-nano-2025-08-07 모델 필수 파라미터**

**모든 Supabase Edge Function에서 OpenAI API 호출 시 반드시 준수:**

```typescript
// ✅ 올바른 OpenAI API 호출 (gpt-5-nano-2025-08-07)
const completion = await openai.chat.completions.create({
  model: 'gpt-5-nano-2025-08-07',
  messages: [
    {
      role: 'system',
      content: '시스템 메시지...'
    },
    {
      role: 'user',
      content: '사용자 질문을 JSON 형식으로 답변해주세요...'  // ✅ 'JSON' 키워드 필수!
    }
  ],
  response_format: { type: 'json_object' },  // ✅ JSON 응답 강제
  temperature: 1,                             // ✅ 1.0 사용 (0.7 안됨)
  max_completion_tokens: 16000,               // ✅ max_completion_tokens (max_tokens 안됨)
                                              // ⚠️ gpt-5-nano는 reasoning 모델!
                                              // reasoning_tokens (내부 사고) + content (최종 답변) 합산
                                              // 한글은 토큰 많이 사용하므로 충분히 크게 설정
})
```

### 🚨 **절대 규칙 (반드시 지켜야 함)**

#### 1️⃣ **프롬프트에 'JSON' 키워드 필수**
```typescript
// ❌ WRONG - response_format 사용 시 에러 발생
content: '상세한 답변을 제공해주세요.'

// ✅ CORRECT - 반드시 'JSON' 또는 'json' 포함
content: '상세한 답변을 JSON 형식으로 제공해주세요.'
```

**에러 메시지**:
```
400 'messages' must contain the word 'json' in some form,
to use 'response_format' of type 'json_object'.
```

#### 2️⃣ **temperature는 1.0 사용**
```typescript
// ❌ WRONG - gpt-5-nano는 0.7 지원 안함
temperature: 0.7

// ✅ CORRECT
temperature: 1
```

#### 3️⃣ **max_completion_tokens 사용 (16000 권장)**
```typescript
// ❌ WRONG - gpt-5-nano는 max_tokens 지원 안함
max_tokens: 2000

// ⚠️ TOO SMALL - gpt-5-nano는 reasoning 모델로 reasoning_tokens를 많이 사용
max_completion_tokens: 2000  // reasoning에 토큰 전부 소진되어 content가 비어있음

// ✅ CORRECT - reasoning_tokens + content 충분히 확보
max_completion_tokens: 16000  // 4000 (reasoning) + 12000 (content)
```

**에러 메시지**:
```
400 Unsupported parameter: 'max_tokens' is not supported with this model.
Use 'max_completion_tokens' instead.
```

**⚠️ CRITICAL: gpt-5-nano-2025-08-07은 Reasoning 모델입니다!**

```json
// finishReason: "length"이고 content가 비어있는 경우:
{
  "finish_reason": "length",
  "message": { "content": "" },
  "completion_tokens": 4000,
  "completion_tokens_details": {
    "reasoning_tokens": 4000  // ← 모든 토큰이 reasoning에 소진!
  }
}
```

**해결 방법**: `max_completion_tokens`를 16000 이상으로 설정하여 reasoning + content 공간 확보

### 📝 **Edge Function 작성 시 체크리스트**

새로운 운세 Edge Function 작성 시 **반드시 확인**:

- [ ] ✅ 프롬프트에 "JSON 형식으로" 또는 "JSON format" 포함됨
- [ ] ✅ `temperature: 1` 설정됨
- [ ] ✅ `max_completion_tokens` 사용 (max_tokens 아님)
- [ ] ✅ `response_format: { type: 'json_object' }` 설정됨
- [ ] ✅ UTF-8 인코딩 처리 (btoa 대신 SHA-256 해시 사용)

### 🔍 **디버깅 가이드**

**400 에러 발생 시 체크 순서:**

1. **프롬프트에 'JSON' 키워드 있는지 확인**
2. **temperature가 1인지 확인**
3. **max_completion_tokens 사용하는지 확인**
4. **Response 헤더에 `charset=utf-8` 있는지 확인**

### 📚 **참고 파일**

- ✅ **정상 작동 예시**: `supabase/functions/fortune-moving/index.ts`
- ✅ **btoa 대신 SHA-256**: `createHash()` 함수 참고

---

## 🔮 **운세 조회 최적화 시스템 (CRITICAL)** 🔮

### 📊 운세 조회 프로세스 (API 비용 72% 절감)

**모든 운세 조회는 다음 6단계 프로세스를 따릅니다:**

```
운세 보기 클릭
    ↓
1️⃣ 개인 캐시 확인
    ├─ 오늘 동일 조건으로 이미 조회? → YES → DB 결과 즉시 반환 ✅
    └─ NO ↓

2️⃣ DB 풀 크기 확인
    ├─ 동일 조건 전체 데이터 ≥1000개? → YES → DB 랜덤 선택 + 5초 대기 + 저장 ✅
    └─ NO ↓

3️⃣ 30% 랜덤 선택
    ├─ Math.random() < 0.3? → YES → DB 랜덤 선택 + 5초 대기 + 저장 ✅
    └─ NO (70%) ↓

4️⃣ API 호출 준비
    └─ 사용자 데이터 기반 프롬프트 생성 ↓

5️⃣ 광고 표시
    └─ 5초 대기 + 광고 노출 ↓

6️⃣ 결과 저장 & 표시
    └─ OpenAI API 호출 → DB 저장 → 사용자에게 표시 ✅
```

### 🎯 핵심 구현 로직

**1단계: 개인 캐시 확인**
```dart
final existingResult = await supabase
  .from('fortune_results')
  .select()
  .eq('user_id', userId)
  .eq('fortune_type', fortuneType)
  .gte('created_at', todayStart)
  .lte('created_at', todayEnd)
  .matchConditions(conditions) // 운세별 동일조건
  .maybeSingle();

if (existingResult != null) return existingResult; // 즉시 반환
```

**2단계: DB 풀 크기 확인**
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

**3단계: 30% 랜덤 선택**
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

### 📝 운세별 동일 조건 정의

각 운세마다 "동일 조건"을 다르게 정의해야 합니다:

#### 일일운세 (Daily)
```dart
conditions = {
  'period': 'daily' | 'weekly' | 'monthly',
  // 날짜는 제외 (매일 새로운 운세)
}
```

#### 연애운 (Love)
```dart
conditions = {
  'saju': user.sajuData,
  'date': today, // 날짜 포함
}
```

#### 타로 (Tarot)
```dart
conditions = {
  'spread_type': 'basic' | 'love' | 'career',
  'selected_cards': [1, 5, 10],
  // 날짜 제외 (카드 조합만 중요)
}
```

#### 직업 운세 (Career)
```dart
conditions = {
  'saju': user.sajuData,
  'job_category': 'developer' | 'designer',
  'date': today,
}
```

#### 이사운 (Moving)
```dart
conditions = {
  'saju': user.sajuData,
  'move_date': selectedDate,
  'direction': selectedDirection,
  // 조회 날짜 제외
}
```

#### 궁합 (Compatibility)
```dart
conditions = {
  'user_saju': user.sajuData,
  'partner_saju': partner.sajuData,
  // 날짜 제외 (사주 조합만 중요)
}
```

### 🗂️ DB 스키마 요구사항

**fortune_results 테이블**:
```sql
CREATE TABLE fortune_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  fortune_type TEXT NOT NULL,
  result_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  conditions_hash TEXT NOT NULL, -- 조건 해시값

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

### ⚠️ 구현 시 주의사항

1. **동일 조건 판단**: 각 운세마다 `matchConditions()` 메서드를 개별 구현
2. **5초 대기**: `await Future.delayed(Duration(seconds: 5))`로 일관되게 처리
3. **랜덤 선택**: `Math.random() < 0.3`으로 30% 확률 구현
4. **DB 인덱싱**: `(fortune_type, conditions_hash, created_at)` 복합 인덱스 필수
5. **에러 처리**: DB 조회 실패 시 API 호출로 폴백
6. **조건 해시**: `SHA256(JSON.stringify(conditions))`로 생성

### 💰 예상 비용 절감 효과

**가정**:
- 일일 사용자: 10,000명
- 운세 종류: 27개
- API 호출 비용: 건당 $0.01

**기존 방식 (100% API 호출)**:
```
10,000명 × 평균 3개 운세 = 30,000 API 호출/일
30,000 × $0.01 = $300/일 = $9,000/월
```

**신규 방식 (최적화)**:
```
1단계 캐시: 20% 절감 (동일 사용자 재조회)
2단계 DB풀: 50% 절감 (1000개 이상인 운세)
3단계 랜덤: 30% 절감 (70%만 API 호출)

실제 API 호출: 30,000 × 0.8 × 0.5 × 0.7 = 8,400 호출
8,400 × $0.01 = $84/일 = $2,520/월

절감액: $6,480/월 (72% 절감)
```

### 📚 상세 문서

전체 플로우차트, 코드 예시, 27개 운세별 조건 정의는 다음 문서 참조:
- **상세 가이드**: `docs/data/FORTUNE_OPTIMIZATION_GUIDE.md`

---

## 🚀 앱 개발 완료 후 필수 작업 (CRITICAL - ALWAYS DO THIS!)

### 📱 **실제 디바이스 자동 배포 (기본값)**

**모든 수정 작업 완료 후 반드시 실제 디바이스에 릴리즈 빌드를 자동으로 배포합니다!**

#### ✅ 표준 배포 명령어 (기본값)
```bash
flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_release_logs.txt
```

**이 명령어가 하는 일**:
- `--release`: 최적화된 릴리즈 빌드 생성 (프로덕션 환경)
- `-d 00008140-00120304260B001C`: 실제 iPhone 디바이스에 설치
- `2>&1 | tee /tmp/flutter_release_logs.txt`: 로그를 파일과 화면에 동시 출력

#### 🔄 개발 중 빠른 테스트 (시뮬레이터)
개발 중에는 시뮬레이터에서 빠르게 테스트할 수 있습니다:

```bash
# 1. 기존 Flutter 프로세스 종료
pkill -f flutter

# 2. 빌드 캐시 정리
flutter clean

# 3. 의존성 재설치
flutter pub get

# 4. 시뮬레이터에서 앱 삭제
xcrun simctl uninstall 1B54EF52-7E41-4040-A236-C169898F5527 com.beyond.fortune

# 5. 앱 새로 빌드 및 실행 (시뮬레이터)
flutter run -d 1B54EF52-7E41-4040-A236-C169898F5527
```

#### 📋 배포 체크리스트

**수정 작업 완료 시 반드시 실행:**
1. ✅ 코드 수정 완료
2. ✅ `flutter analyze` 실행 (에러 없는지 확인)
3. ✅ **실제 디바이스에 릴리즈 빌드 배포** (기본값!)
   ```bash
   flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_release_logs.txt
   ```
4. ✅ 실제 디바이스에서 변경사항 검증
5. ✅ JIRA 완료 처리 (git_jira_commit.sh)

**⚠️ 중요**: Hot Restart나 Hot Reload로는 변경사항이 제대로 반영되지 않을 수 있습니다!

## Flutter 개발 워크플로우

1. **코드 수정 및 개발**
2. **Hot Reload로 빠른 테스트** (`r` 키)
3. **개발 완료 후 Hot Restart로 전체 검증** (`R` 키)
4. **최종 확인 완료**

## 검증 포인트

### 🚀 앱 시작 플로우
- 스플래시 화면 → 로그인 상태 확인 → 적절한 페이지 라우팅
- 로그인 안 된 경우: LandingPage(시작하기 버튼) 표시
- 로그인 된 경우: 프로필 상태에 따라 onboarding 또는 home 이동

### 🔐 인증 플로우
- 소셜 로그인 (Google, Apple, Kakao, Naver)
- 로그인 상태에 따른 UI 변화
- "오늘의 이야기가 완성되었어요!" 화면은 미로그인 사용자만 표시

### 📱 핵심 기능
- 운세 생성 및 표시
- 사용자 프로필 관리
- 온보딩 플로우

## 개발 시 주의사항

- 로그인 상태와 관계없이 모든 플로우가 정상 작동하는지 확인
- 프로필 완성도에 따른 라우팅 로직 검증
- Hot Restart 후 초기 상태에서의 동작 확인

---

## 🎨 표준 UI 컴포넌트 패턴

### 📝 **폰트 크기 관리 시스템 (CRITICAL)**

**모든 텍스트는 반드시 TypographyUnified를 사용합니다!**

#### ✅ 올바른 방법 (TypographyUnified 사용)

```dart
import 'package:fortune/core/theme/typography_unified.dart';

// 방법 1: BuildContext extension 사용 (권장)
Text('제목', style: context.heading1)
Text('본문', style: context.bodyMedium)
Text('버튼', style: context.buttonMedium)
Text('라벨', style: context.labelMedium)

// 방법 2: 직접 사용
Text('제목', style: TypographyUnified.heading1)
Text('본문', style: TypographyUnified.bodyMedium)

// 색상 적용
Text('제목', style: context.heading1.copyWith(color: Colors.blue))
```

#### ❌ 잘못된 방법 (절대 사용 금지!)

```dart
// ❌ TossDesignSystem의 deprecated TextStyle 사용 금지
Text('제목', style: TossDesignSystem.heading1)  // WRONG!
Text('본문', style: TossDesignSystem.body2)     // WRONG!

// ❌ 하드코딩된 fontSize 사용 금지
Text('제목', style: TextStyle(fontSize: 24))   // WRONG!
```

#### 📋 TypographyUnified 스타일 가이드

**Display (대형 헤드라인)**:
- `displayLarge` - 48pt (스플래시, 온보딩)
- `displayMedium` - 40pt (큰 헤드라인)
- `displaySmall` - 32pt (중간 헤드라인)

**Heading (섹션 제목)**:
- `heading1` - 28pt (메인 페이지 제목)
- `heading2` - 24pt (섹션 제목)
- `heading3` - 20pt (서브 섹션 제목)
- `heading4` - 18pt (작은 섹션 제목)

**Body (본문)**:
- `bodyLarge` - 17pt (큰 본문)
- `bodyMedium` - 15pt (기본 본문)
- `bodySmall` - 14pt (작은 본문)

**Label (라벨, 캡션)**:
- `labelLarge` - 13pt (큰 라벨)
- `labelMedium` - 12pt (기본 라벨)
- `labelSmall` - 11pt (작은 라벨)
- `labelTiny` - 10pt (배지, NEW 표시)

**Button (버튼)**:
- `buttonLarge` - 17pt (큰 버튼)
- `buttonMedium` - 16pt (기본 버튼)
- `buttonSmall` - 15pt (작은 버튼)
- `buttonTiny` - 14pt (매우 작은 버튼)

**Number (숫자 전용, TossFace 폰트)**:
- `numberXLarge` - 40pt (매우 큰 숫자)
- `numberLarge` - 32pt (큰 숫자)
- `numberMedium` - 24pt (중간 숫자)
- `numberSmall` - 18pt (작은 숫자)

#### 🎯 핵심 원칙

1. **사용자 설정 반영**: TypographyUnified는 FontSizeSystem 기반으로 사용자 폰트 크기 설정을 자동 반영
2. **일관성**: 모든 화면에서 동일한 타이포그래피 사용
3. **접근성**: 시각 장애인을 위한 큰 글씨 모드 지원
4. **유지보수**: 한 곳에서 모든 폰트 크기 관리

#### ⚠️ TossDesignSystem의 TextStyle은 Deprecated

TossDesignSystem에 있는 `heading1`, `body2`, `caption` 등은 **사용 금지**입니다.
- 사용자 폰트 크기 설정을 반영하지 않음
- 고정 크기로 접근성 문제 발생
- 하위 호환성을 위해 남아있지만 신규 코드에서는 사용하지 말 것

---

### 📱 표준 뒤로가기 버튼 (AppBar Leading)

**모든 페이지의 뒤로가기 버튼은 이 패턴을 따릅니다:**

```dart
// 참조: lib/features/fortune/presentation/pages/tarot_renewed_page.dart:123-129
AppBar(
  backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
  elevation: 0,
  scrolledUnderElevation: 0,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back_ios,  // iOS 스타일 < 아이콘
      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
    ),
    onPressed: () => context.pop(),  // go_router의 pop 사용
  ),
  title: Text(
    '페이지 제목',
    style: TextStyle(
      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  centerTitle: true,
)
```

**핵심 원칙:**
- ✅ `Icons.arrow_back_ios` 사용 (iOS 스타일)
- ✅ 다크모드 색상 자동 대응 (`isDark` 조건)
- ✅ `context.pop()` 사용 (go_router 표준)
- ✅ AppBar 배경색도 다크모드 대응
- ❌ `Icons.arrow_back` 사용 금지 (안드로이드 스타일)
- ❌ 하드코딩된 색상 사용 금지

**새 페이지 생성 시:**
1. 위 코드를 복사하여 사용
2. `'페이지 제목'` 부분만 변경
3. 다른 부분은 수정하지 말 것

---

## 📚 문서 관리 정책

### 📂 문서 위치 원칙

**모든 프로젝트 문서는 `docs/` 폴더에서 관리합니다.**

```
docs/
├── getting-started/    # 프로젝트 시작
├── design/            # 디자인 시스템
├── data/              # 데이터 & API
├── native/            # 네이티브 기능
├── testing/           # 테스팅
├── deployment/        # 배포 & 보안
├── development/       # 개발 도구 & 자동화
├── legal/             # 법률 & 정책
└── troubleshooting/   # 문제 해결
```

**루트 레벨 문서는 2개만 유지**:
- `README.md` - 프로젝트 소개 및 진입점
- `CLAUDE.md` - Claude Code 개발 규칙 (이 파일)

---

### 📌 빠른 문서 탐색

**작업 시작 전 항상 [docs/README.md](docs/README.md) 확인!**

#### 주제별 폴더 구조

| 작업 유형 | 폴더 | 주요 문서 |
|----------|------|----------|
| 🚀 **프로젝트 시작** | `docs/getting-started/` | PROJECT_OVERVIEW.md, SETUP_GUIDE.md |
| 🎨 **UI 개발** | `docs/design/` | TOSS_DESIGN_SYSTEM.md ⭐️, WIDGET_ARCHITECTURE_DESIGN.md |
| 💾 **DB 작업** | `docs/data/` | DATABASE_GUIDE.md ⭐️, API_USAGE.md |
| 📱 **네이티브 기능** | `docs/native/` | NATIVE_FEATURES_GUIDE.md ⭐️, WATCH_COMPANION_APPS_GUIDE.md |
| 🧪 **테스트** | `docs/testing/` | AB_TESTING_GUIDE.md ⭐️, TESTING_GUIDE.md |
| 🚢 **배포** | `docs/deployment/` | DEPLOYMENT_COMPLETE_GUIDE.md ⭐️, APP_STORE_GUIDE.md ⭐️, SECURITY_CHECKLIST.md |
| 🛠 **개발 자동화** | `docs/development/` | CLAUDE_AUTOMATION.md ⭐️, GIT_JIRA_WORKFLOW.md, MCP_SETUP_GUIDE.md |
| ⚖️ **법률/정책** | `docs/legal/` | PRIVACY_POLICY_CONTENT.md |
| 🐛 **문제 해결** | `docs/troubleshooting/` | FIX_406_ERROR_GUIDE.md |

**⭐️ 표시**: 여러 문서를 통합한 최신 통합 가이드

---

### 🎯 작업별 문서 찾기 가이드

**프로젝트 시작**:
1. [docs/README.md](docs/README.md) 열기
2. `getting-started/` 폴더로 이동
3. PROJECT_OVERVIEW.md → SETUP_GUIDE.md 순서로 읽기

**UI 컴포넌트 개발**:
1. `docs/design/` 폴더 확인
2. 새 컴포넌트 → TOSS_DESIGN_SYSTEM.md에서 패턴 찾기
3. 위젯 설계 → WIDGET_ARCHITECTURE_DESIGN.md 참고

**데이터베이스 작업**:
1. `docs/data/` 폴더 확인
2. DATABASE_GUIDE.md에서 스키마/RLS/마이그레이션 확인
3. API 호출 → API_USAGE.md 패턴 참고

**배포 준비**:
1. `docs/deployment/` 폴더 확인
2. DEPLOYMENT_COMPLETE_GUIDE.md로 전체 프로세스 파악
3. APP_STORE_GUIDE.md로 스토어 등록
4. SECURITY_CHECKLIST.md로 보안 검증

**JIRA 자동화**:
1. `docs/development/` 폴더 확인
2. CLAUDE_AUTOMATION.md로 워크플로우 이해
3. GIT_JIRA_WORKFLOW.md로 Git 통합 확인

---

### 📝 문서 관리 규칙

#### ✅ DO (해야 할 것)
- 새 문서는 반드시 `docs/` 하위 적절한 폴더에 생성
- docs/README.md에 새 문서 추가 시 색인 업데이트
- 통합 가이드 (⭐️) 우선 참고
- 주제별 폴더 구조 유지

#### ❌ DON'T (하지 말아야 할 것)
- 프로젝트 루트에 새 문서 생성 금지
- 중복 문서 생성 금지 (기존 문서 업데이트)
- 개인 메모나 임시 파일 docs/에 커밋 금지
- 문서 이동 시 링크 업데이트 누락 금지

---

### 🔍 문서 검색 팁

1. **전체 검색**: `docs/README.md`에서 키워드로 Ctrl+F
2. **카테고리 검색**: 작업 유형에 맞는 폴더로 직접 이동
3. **통합 문서 우선**: ⭐️ 표시 문서가 가장 최신이고 완전함
4. **크로스 레퍼런스**: 각 문서 하단의 "관련 문서" 섹션 확인

---

## 🧹 미사용 스크린 자동 정리 시스템

### 📊 시스템 개요

Flutter 프로젝트의 `lib/screens/` 폴더에 있는 화면 파일들을 자동으로 분석하고,
실제로 사용되지 않는 화면을 탐지하여 정리하는 자동화 시스템입니다.

**주요 구성 요소:**
1. **정적 분석 도구** (`tools/screen_analyzer.dart`)
2. **런타임 추적** (`lib/core/utils/route_observer_logger.dart`)
3. **자동 정리 스크립트** (`scripts/cleanup_unused_screens.sh`)
4. **Pre-commit 훅** (`scripts/pre-commit-screen-check.sh`)

---

### 🔍 1. 정적 분석 도구 사용법

**기본 실행:**
```bash
dart run tools/screen_analyzer.dart
```

**JSON 결과 저장:**
```bash
dart run tools/screen_analyzer.dart --output analysis.json
```

**분석 항목:**
- ✅ GoRouter에 등록된 화면 (`route_config.dart`, 서브 라우트 파일)
- ✅ MaterialPageRoute로 동적 생성되는 화면
- ✅ showDialog, showBottomSheet로 사용되는 다이얼로그
- ✅ 다른 화면에서 위젯으로 참조되는 컴포넌트

**출력 예시:**
```
📊 분석 결과:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
총 스크린 클래스: 29개
사용 중인 스크린: 29개
미사용 스크린: 0개
위젯 컴포넌트: 23개

🧩 위젯 컴포넌트 (screens/ → widgets/ 이동 고려):
  - TossNumberPad (lib/screens/onboarding/widgets/toss_number_pad.dart)
  - PaymentConfirmationDialog (lib/screens/payment/payment_confirmation_dialog.dart)
```

---

### 📝 2. 런타임 화면 방문 추적

**자동 활성화:** 디버그 모드에서 자동으로 활성화됩니다.

**방문 기록 확인:**
```bash
cat visited_screens.json
```

**기록 내용:**
```json
{
  "last_updated": "2025-01-06T10:30:00Z",
  "total_screens": 15,
  "total_visits": 142,
  "visits": [
    {
      "screen_name": "HomeScreen",
      "route_name": "/home",
      "first_visit": "2025-01-06T09:00:00Z",
      "last_visit": "2025-01-06T10:25:00Z",
      "visit_count": 45
    }
  ]
}
```

**활용 방법:**
- 실제 사용 패턴 분석
- 정적 분석으로 놓친 화면 발견
- 인기 있는 화면 파악

---

### 🚚 3. 자동 정리 스크립트

**시뮬레이션 (실제 이동 없음):**
```bash
./scripts/cleanup_unused_screens.sh --dry-run
```

**실제 실행 (확인 프롬프트 있음):**
```bash
./scripts/cleanup_unused_screens.sh
```

**자동 실행 (확인 없음):**
```bash
./scripts/cleanup_unused_screens.sh --auto
```

**스크립트 동작:**
1. `screen_analyzer.dart` 실행하여 미사용 화면 탐지
2. 사용자 확인 요청 (--auto가 아닐 때)
3. 백업 브랜치 자동 생성 (`backup/unused-screens-cleanup-YYYYMMDD-HHMMSS`)
4. `lib/screens_unused/` 폴더로 파일 이동 (git mv 사용)
5. `flutter analyze` 실행하여 에러 체크
6. 에러 발생 시 자동 롤백 (`git restore`)
7. 성공 시 커밋 가이드 출력

**안전 장치:**
- ✅ 백업 브랜치 자동 생성
- ✅ git mv로 이동 (히스토리 보존)
- ✅ flutter analyze 자동 검증
- ✅ 에러 시 즉시 롤백

---

### 🎯 4. Pre-commit 훅 (선택사항)

**설치:**
```bash
ln -sf ../../scripts/pre-commit-screen-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**동작:**
- `lib/screens/`에 새 화면 파일 커밋 시 자동 체크
- GoRouter에 라우트 등록 여부 확인
- 경고 메시지 출력 (커밋은 차단하지 않음)

**출력 예시:**
```
🔍 Pre-commit: 새 화면 라우트 등록 체크
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 새로 추가된 스크린 파일:
  ✓ lib/screens/new_feature_screen.dart

⚠️  경고: 다음 화면이 라우트에 등록되지 않았을 수 있습니다
  - NewFeatureScreen (lib/screens/new_feature_screen.dart)

💡 lib/routes/route_config.dart에 GoRoute를 추가하거나,
   위젯 컴포넌트라면 lib/core/widgets/로 이동하세요
```

---

### 💡 권장 워크플로우

**월 1회 정기 정리:**
```bash
# 1. 정적 분석 실행
dart run tools/screen_analyzer.dart

# 2. 분석 결과 검토
cat screen_analysis_result.json

# 3. 시뮬레이션으로 미리보기
./scripts/cleanup_unused_screens.sh --dry-run

# 4. 실제 정리 실행
./scripts/cleanup_unused_screens.sh

# 5. 앱 테스트 후 커밋
./scripts/git_jira_commit.sh "Remove unused screens" "KAN-XX" "done"
```

**새 화면 추가 시:**
1. `lib/screens/`에 화면 파일 작성
2. `lib/routes/route_config.dart`에 라우트 등록
3. Pre-commit 훅이 자동 체크 (설치된 경우)
4. 커밋 전 경고 메시지 확인

---

### 🔧 문제 해결

**"미사용으로 표시되는데 실제로 사용 중"인 경우:**
- MaterialPageRoute, showDialog 등 동적 패턴 사용 여부 확인
- `visited_screens.json`에서 런타임 방문 기록 확인
- 필요시 `screen_analyzer.dart` 패턴 추가

**롤백이 필요한 경우:**
```bash
# 백업 브랜치로 복구
git restore .
git checkout backup/unused-screens-cleanup-YYYYMMDD-HHMMSS
```

**Pre-commit 훅 제거:**
```bash
rm .git/hooks/pre-commit
```

---

이 파일은 Claude Code가 이 프로젝트에서 작업할 때 자동으로 참조하는 개발 규칙입니다.