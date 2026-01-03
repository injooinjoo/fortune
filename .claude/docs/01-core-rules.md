# 핵심 개발 규칙

> 최종 업데이트: 2025.01.03

## 절대 규칙 3가지

### 1. Flutter 직접 실행 금지

**Claude는 절대로 Flutter를 직접 실행하지 않습니다!**

```bash
# 금지 명령어
flutter run
flutter run --release
flutter run -d [device-id]
```

**올바른 워크플로우**:
1. **Claude**: 코드 수정 완료 후 "Flutter를 실행해서 테스트해주세요" 요청
2. **사용자**: 직접 `flutter run --release -d 00008140-00120304260B001C` 실행
3. **사용자**: 로그를 Claude에게 전달
4. **Claude**: 로그를 분석하고 문제 해결

**이유**: Claude가 Flutter를 실행하면 로그를 제대로 확인할 수 없어 디버깅이 불가능합니다.

---

### 2. 일괄 수정 절대 금지

**이 규칙을 어기면 프로젝트가 망가집니다!**

#### 금지 항목
1. **Python 스크립트를 사용한 일괄 수정 금지**
   - `for file in files:` 형태의 일괄 처리 스크립트 작성 금지
   - 여러 파일을 한번에 수정하는 Python 스크립트 절대 사용 금지
   - **Write 도구로 Python 스크립트를 작성하는 것 자체가 금지**

2. **Shell 스크립트를 사용한 일괄 수정 금지**
   - `sed -i`, `awk`, `perl` 등을 사용한 일괄 치환 금지
   - `for` 루프를 사용한 여러 파일 동시 수정 금지
   - `grep | xargs` 조합으로 여러 파일 수정 금지

3. **정규식 일괄 치환 금지**
   - IDE의 "Replace All in Files" 기능 사용 금지
   - 정규식 패턴으로 여러 파일 동시 수정 금지

#### 올바른 수정 방법
**반드시 하나씩 수정해야 합니다:**
1. 한 파일씩 열어서 확인
2. 해당 파일의 컨텍스트 이해
3. 필요한 부분만 정확히 수정
4. 수정 후 해당 파일 검증
5. 다음 파일로 이동

#### 위반 시 결과
- 프로젝트 전체가 빌드 불가능한 상태가 됨
- 수많은 연쇄 에러 발생
- 복구에 몇 시간 소요
- Git 히스토리 오염

**"일괄수정안할거야. 하나씩해" - 이것이 철칙입니다!**

---

### 3. JIRA 티켓 먼저 생성

**모든 개발 작업은 반드시 JIRA 티켓 생성부터 시작합니다!**

→ 상세 내용: [07-jira-workflow.md](07-jira-workflow.md) 참조

---

## 에러 로그 근본 원인 분석 원칙 (CRITICAL)

**에러 로그가 발생하면, 에러 로그를 숨기거나 제거하려는 것이 아니라, 에러가 발생하지 않도록 근본 원인을 해결합니다!**

### 에러 발생 시 필수 분석 프로세스

#### 1단계: 왜 에러가 발생했는지 근본 원인 파악

```
잘못된 접근:
에러: "Null check operator used on a null value"
→ try-catch로 에러 무시 (WRONG!)
→ if (value != null) 조건만 추가 (WRONG!)

올바른 접근:
에러: "Null check operator used on a null value"
→ 1. 왜 null이 들어왔는지 추적
   - 데이터가 아직 로드되지 않았나?
   - API 응답이 잘못되었나?
   - 초기화가 제대로 안됐나?
→ 2. 다른 곳에서도 동일한 패턴이 있는지 검색
→ 3. 유사한 케이스는 어떻게 처리했는지 확인
→ 4. 근본 원인 해결 (예: 데이터 로드 대기, 기본값 설정, 초기화 로직 수정)
```

#### 2단계: 다른 곳에서는 발생하지 않는지 전체 코드베이스 확인

```dart
// 잘못된 곳:
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    return Text(snapshot.data!.name);  // null일 수 있음
  }
)

// 올바른 곳:
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();  // 로딩 처리
    }
    if (snapshot.hasError) {
      return ErrorWidget(snapshot.error);  // 에러 처리
    }
    if (!snapshot.hasData) {
      return EmptyStateWidget();  // 데이터 없음 처리
    }
    return Text(snapshot.data!.name);  // 안전하게 사용
  }
)
```

#### 3단계: 다른 곳에서는 어떻게 유사한 문제를 해결했는지 확인

```dart
// 잘못된 방식 - 에러만 숨김
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      return Text(Provider.of<UserData>(context).name);
    } catch (e) {
      return SizedBox.shrink();  // 에러 무시
    }
  }
}

// 올바른 방식 - 근본 원인 해결
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

#### 4단계: 근본 원인 해결 체크리스트

**에러 발생 시 반드시 확인할 것:**
- [ ] 왜 에러가 발생했는지 로그 추적 완료
- [ ] 동일한 패턴이 다른 곳에 있는지 검색 완료
- [ ] 유사한 케이스를 올바르게 처리한 코드 찾음
- [ ] 근본 원인을 해결하는 방향으로 수정 (에러 숨김 금지)
- [ ] 수정 후 동일 에러가 다른 곳에서도 발생하지 않는지 확인

### 절대 하지 말아야 할 것

#### 에러 로그만 제거하는 행위
```dart
// WRONG - 에러만 숨김
try {
  riskyOperation();
} catch (e) {
  // 아무것도 안함 - 에러 무시
}

// WRONG - 에러만 무시
if (value != null) {  // null 체크만 추가
  // 원래 코드
}
// 왜 null이 들어오는지는 분석 안함
```

#### 증상만 치료하는 행위
```dart
// WRONG - 증상만 치료
setState(() {
  _data = snapshot.data ?? [];  // 빈 배열로 기본값만 설정
});
// 왜 data가 null인지, API가 실패했는지, 네트워크 문제인지 분석 안함
```

#### 다른 곳 확인 없이 해당 파일만 수정
```dart
// WRONG - 한 곳만 수정
// lib/features/home/home_page.dart 에서만 수정
FutureBuilder(...)  // 수정됨

// lib/features/profile/profile_page.dart 는 그대로 방치
FutureBuilder(...)  // 동일한 에러 패턴 존재!
```

### 올바른 에러 해결 프로세스

```
1. 에러 로그 발생
   ↓
2. 근본 원인 분석
   - 왜 발생했는가?
   - 어떤 조건에서 발생하는가?
   - 데이터 흐름에서 어느 단계가 문제인가?
   ↓
3. 프로젝트 전체 검색
   - 동일한 패턴이 있는 곳 찾기
   - 올바르게 처리된 곳 찾기
   - 비교하여 차이점 파악
   ↓
4. 근본 원인 해결
   - 데이터 초기화 문제 → 초기화 로직 수정
   - API 응답 문제 → API 호출 방식 수정
   - 상태 관리 문제 → 상태 관리 개선
   ↓
5. 동일 패턴 모두 수정
   - 한 곳만 고치지 말고 전체 수정
   - 일관된 패턴 적용
   ↓
6. 검증
   - 해당 에러가 더 이상 발생하지 않는지 확인
   - 다른 곳에서도 동일 에러 없는지 확인
```

### 근본 원인 분석 예시

#### 예시 1: Null 에러
```
잘못된 방법: if (data != null) { ... }

올바른 방법:
1. 왜 null인가? → API 호출 전에 접근
2. 다른 곳은? → 모든 API 호출 부분 검색
3. 올바른 패턴? → FutureBuilder로 로딩 상태 관리
4. 해결: 모든 API 호출에 FutureBuilder 적용
```

#### 예시 2: setState 에러
```
잘못된 방법: if (mounted) { setState(() {...}); }

올바른 방법:
1. 왜 dispose 후 호출? → 비동기 작업 완료 시점 문제
2. 다른 곳은? → 모든 비동기 setState 검색
3. 올바른 패턴? → CancelableOperation 또는 dispose에서 cancel
4. 해결: 모든 비동기 작업에 취소 로직 추가
```

#### 예시 3: IndexOutOfRange 에러
```
잘못된 방법: if (list.length > index) { ... }

올바른 방법:
1. 왜 인덱스 초과? → 리스트가 비어있거나 삭제됨
2. 다른 곳은? → 모든 리스트 접근 검색
3. 올바른 패턴? → isEmpty 체크 또는 try-get 패턴
4. 해결: 리스트 상태 관리 개선
```

### 핵심 원칙

**"에러 로그를 없애려는 것이 아니라, 에러가 발생하지 않도록 근본 원인을 해결한다"**

1. **증상 치료 금지**: try-catch로 숨기거나 조건문으로만 우회하지 말 것
2. **근본 원인 분석 필수**: 왜 에러가 발생했는지 반드시 파악
3. **전체 검색 필수**: 동일한 패턴이 다른 곳에 없는지 확인
4. **올바른 패턴 적용**: 이미 잘 처리된 곳의 패턴을 찾아 적용
5. **일관성 유지**: 한 곳만 고치지 말고 전체를 일관되게 수정

**이것이 모든 에러 처리의 최우선 원칙입니다!**
