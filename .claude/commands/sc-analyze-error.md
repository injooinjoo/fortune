에러의 근본 원인을 분석합니다.

## 입력 정보

- **에러 로그**: $ARGUMENTS 또는 사용자가 제공한 에러 메시지
- **스택트레이스**: 에러 발생 위치 정보

## 분석 프로세스

### 1단계: 에러 유형 파악

```
에러 로그 분석
   ↓
에러 유형 분류:
   - Null 에러 (Null check operator used on a null value)
   - 타입 에러 (type 'X' is not a subtype of type 'Y')
   - setState 에러 (setState() called after dispose())
   - Index 에러 (RangeError: Invalid value)
   - 비동기 에러 (Future error, Uncaught async error)
```

### 2단계: 근본 원인 추적

```bash
# 에러 발생 파일 확인
# 스택트레이스에서 lib/ 경로 추출

# 관련 코드 분석
# 데이터 흐름 추적
# 상태 변화 확인
```

### 3단계: 동일 패턴 전체 검색

```bash
# 예: FutureBuilder에서 null 에러 발생 시
grep -r "FutureBuilder" lib/

# setState 에러 시
grep -r "setState" lib/ | grep -v "if (mounted)"

# nullable 접근 시
grep -r "snapshot.data!" lib/
```

### 4단계: 올바른 패턴 찾기

프로젝트 내에서 동일한 상황을 올바르게 처리한 코드를 찾습니다.

### 5단계: 수정 방안 제시

## 출력 형식

```
============================================
🔍 에러 근본 원인 분석
============================================

📋 에러 정보
   유형: Null check operator used on a null value
   위치: lib/features/fortune/presentation/pages/daily_page.dart:45

🔎 근본 원인
   FutureBuilder에서 snapshot.data에 null 체크 없이 접근
   → 데이터 로딩 전에 위젯이 빌드됨

🔍 동일 패턴 검색 결과
   - lib/features/fortune/presentation/pages/tarot_page.dart:62 (동일 문제)
   - lib/features/profile/presentation/pages/profile_page.dart:38 (올바른 패턴)

✅ 수정 방안
   1. snapshot.connectionState 확인 추가
   2. snapshot.hasData 확인 추가
   3. 로딩 상태 UI 표시

📝 수정 코드 예시
```dart
// Before (❌)
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    return Text(snapshot.data!.name);
  }
)

// After (✅)
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return ErrorWidget(snapshot.error);
    }
    if (!snapshot.hasData) {
      return EmptyStateWidget();
    }
    return Text(snapshot.data!.name);
  }
)
```

============================================
수정 대상 파일: 2개
============================================
```

## 금지 사항

- ❌ 에러만 숨기는 try-catch
- ❌ 증상만 치료하는 null 체크
- ❌ 한 곳만 수정하고 다른 곳 방치

## 관련 Agent

- error-resolver

