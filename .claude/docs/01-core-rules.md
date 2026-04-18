# 핵심 개발 규칙

> 최종 업데이트: 2026.04.17

## 절대 규칙 3가지

### 1. 개발 서버 직접 실행 금지

**Claude는 절대로 Expo/Metro 개발 서버를 직접 실행하지 않습니다!**

```bash
# 금지 명령어
expo start
npx expo start
npx expo run:ios
npx expo run:android
```

**올바른 워크플로우**:
1. **Claude**: 코드 수정 완료 후 "Expo를 실행해서 테스트해주세요" 요청
2. **사용자**: 직접 `npx expo start` 또는 시뮬레이터/실기기에서 실행
3. **사용자**: 로그를 Claude에게 전달
4. **Claude**: 로그를 분석하고 문제 해결

**이유**: Claude가 개발 서버를 띄우면 포그라운드 프로세스가 블로킹되고, 실시간 로그/HMR 상태를 제대로 확인할 수 없어 디버깅이 불가능합니다. 타입체크/정적 분석은 Claude가 직접 수행해도 됩니다.

---

### 2. 일괄 수정 절대 금지

**이 규칙을 어기면 프로젝트가 망가집니다!**

#### 금지 항목
1. **스크립트를 사용한 일괄 수정 금지**
   - `for file in files:` 형태의 일괄 처리 스크립트 작성 금지
   - 여러 파일을 한번에 수정하는 Node/Python/Shell 스크립트 절대 사용 금지
   - **Write 도구로 일괄 수정 스크립트를 작성하는 것 자체가 금지**

2. **Shell 일괄 치환 금지**
   - `sed -i`, `awk`, `perl -pi` 등을 사용한 일괄 치환 금지
   - `for` 루프를 사용한 여러 파일 동시 수정 금지
   - `grep | xargs` 조합으로 여러 파일 수정 금지

3. **정규식 일괄 치환 금지**
   - IDE의 "Replace All in Files" 기능 사용 금지
   - 정규식 패턴으로 여러 파일 동시 수정 금지
   - Edit 툴의 `replace_all` 플래그를 광범위한 파일에 남용 금지

#### 올바른 수정 방법
**반드시 하나씩 수정해야 합니다:**
1. 한 파일씩 열어서 확인
2. 해당 파일의 컨텍스트 이해
3. 필요한 부분만 정확히 수정
4. 수정 후 해당 파일 검증
5. 다음 파일로 이동

#### 위반 시 결과
- 프로젝트 전체가 빌드 불가능한 상태가 됨
- 수많은 연쇄 타입 에러 발생
- 복구에 몇 시간 소요
- Git 히스토리 오염

**"일괄수정안할거야. 하나씩해" - 이것이 철칙입니다!**

---

### 3. JIRA 티켓 먼저 생성

**모든 개발 작업은 반드시 JIRA 티켓 생성부터 시작합니다!**

→ 상세 내용: [07-jira-workflow.md](07-jira-workflow.md) 참조

---

## 디자인 시스템/테마 규칙 (CRITICAL)

**RN 코드 내에서 색상/폰트/간격을 하드코딩하지 않습니다.**

### 금지 패턴
- hex 색상 리터럴 직접 사용 (`'#FF5A5F'`, `'rgba(0,0,0,0.5)'` 등을 컴포넌트 내부에 삽입)
- `<Text style={{ fontSize: 16, fontWeight: '600' }}>` 형태로 스타일을 즉석 작성
- 각 파일에서 제각각 정의한 폰트 패밀리/크기

### 올바른 패턴
- 테마 토큰은 `apps/mobile-rn/src/lib/theme.ts`의 `fortuneTheme`에서 가져옵니다.
- 텍스트는 원칙적으로 `apps/mobile-rn/src/components/app-text.tsx`의 `AppText` 컴포넌트를 사용합니다. 개별 `<Text>`에 스타일을 덕지덕지 붙이지 않습니다.
- 새 토큰이 필요하면 `fortuneTheme`에 먼저 추가하고 그 토큰을 사용합니다.

---

## 에러 로그 근본 원인 분석 원칙 (CRITICAL)

**에러 로그가 발생하면, 에러 로그를 숨기거나 제거하려는 것이 아니라, 에러가 발생하지 않도록 근본 원인을 해결합니다!**

### 에러 발생 시 필수 분석 프로세스

#### 1단계: 왜 에러가 발생했는지 근본 원인 파악

```
잘못된 접근:
에러: "Cannot read properties of undefined (reading 'name')"
→ try-catch로 에러 무시 (WRONG!)
→ if (value) 조건만 추가 (WRONG!)
→ optional chaining(?.)만 덧붙이고 끝 (WRONG!)

올바른 접근:
에러: "Cannot read properties of undefined (reading 'name')"
→ 1. 왜 undefined가 들어왔는지 추적
   - 데이터가 아직 로드되지 않았나? (loading state 미처리)
   - API 응답 스키마가 바뀌었나?
   - 스토어 초기값이 잘못 지정됐나?
→ 2. 다른 곳에서도 동일한 패턴이 있는지 검색
→ 3. 유사한 케이스는 어떻게 처리했는지 확인
→ 4. 근본 원인 해결 (예: 로딩 게이트, 기본값, 스키마 검증)
```

#### 2단계: 다른 곳에서는 발생하지 않는지 전체 코드베이스 확인

```tsx
// 잘못된 곳:
function Profile() {
  const { data } = useQuery(['me'], fetchMe);
  return <Text>{data.name}</Text>; // undefined 접근 가능
}

// 올바른 곳:
function Profile() {
  const { data, isLoading, error } = useQuery(['me'], fetchMe);

  if (isLoading) return <LoadingView />;
  if (error) return <ErrorView error={error} />;
  if (!data) return <EmptyView />;

  return <AppText variant="body">{data.name}</AppText>;
}
```

#### 3단계: 다른 곳에서는 어떻게 유사한 문제를 해결했는지 확인

```tsx
// 잘못된 방식 - 에러만 숨김
function UserCard() {
  try {
    const user = useUserContext();
    return <AppText>{user.name}</AppText>;
  } catch (e) {
    return null; // 에러 무시
  }
}

// 올바른 방식 - 근본 원인 해결
function UserCard() {
  const user = useUserContext(); // 훅은 조건부 호출 금지

  // 1. 스토어가 비어있는 이유를 명시적으로 처리
  if (!user) {
    // 로그인 필요, 데이터 로딩 중 등 명확한 상태 표시
    return <LoginRequiredView />;
  }

  // 2. 안전하게 사용
  return <AppText variant="body">{user.name}</AppText>;
}
```

#### 4단계: 근본 원인 해결 체크리스트

**에러 발생 시 반드시 확인할 것:**
- [ ] 왜 에러가 발생했는지 로그/스택 추적 완료
- [ ] 동일한 패턴이 다른 곳에 있는지 `apps/mobile-rn/src/` 전수 검색 완료
- [ ] 유사한 케이스를 올바르게 처리한 코드 찾음
- [ ] 근본 원인을 해결하는 방향으로 수정 (에러 숨김 금지)
- [ ] 수정 후 동일 에러가 다른 곳에서도 발생하지 않는지 확인

### 절대 하지 말아야 할 것

#### 에러 로그만 제거하는 행위
```ts
// WRONG - 에러만 숨김
try {
  riskyOperation();
} catch (e) {
  // 아무것도 안함 - 에러 무시
}

// WRONG - 로그만 찍고 흘려보냄
try {
  riskyOperation();
} catch (e) {
  console.log(e);
}

// WRONG - optional chaining만 더하고 끝
const name = user?.profile?.name ?? '';
// 왜 user 또는 profile이 undefined인지는 분석 안함
```

#### 증상만 치료하는 행위
```ts
// WRONG - 증상만 치료
const items = data ?? []; // 빈 배열 기본값만 설정
// 왜 data가 undefined인지, API가 실패했는지, 네트워크 문제인지 분석 안함
```

#### 다른 곳 확인 없이 해당 파일만 수정
```
WRONG - 한 곳만 수정
apps/mobile-rn/src/features/chat-surface/chat-surface.tsx 에서만 수정

apps/mobile-rn/src/features/fortune-results/screens/... 는 그대로 방치
→ 동일한 useQuery 에러 패턴이 그대로 존재!
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
     예) grep -rn "useQuery" apps/mobile-rn/src/
         grep -rn "useState" apps/mobile-rn/src/
   - 올바르게 처리된 곳 찾기
   - 비교하여 차이점 파악
   ↓
4. 근본 원인 해결
   - 초기값 문제 → 스토어/상태 초기화 로직 수정
   - API 응답 문제 → 스키마/페처 수정
   - 상태 관리 문제 → 스토어 경계/셀렉터 개선
   ↓
5. 동일 패턴 모두 수정
   - 한 곳만 고치지 말고 전체 수정
   - 일관된 패턴 적용 (하나씩 Edit)
   ↓
6. 검증
   - cd apps/mobile-rn && npx tsc --noEmit
   - 해당 에러가 더 이상 발생하지 않는지 확인
   - 다른 곳에서도 동일 에러 없는지 확인
```

### 근본 원인 분석 예시

#### 예시 1: undefined 접근 에러
```
잘못된 방법: const name = user?.name ?? '';

올바른 방법:
1. 왜 undefined인가? → 쿼리 로딩 완료 전에 렌더
2. 다른 곳은? → grep -rn "useQuery" apps/mobile-rn/src/
3. 올바른 패턴? → isLoading / error / empty 분기
4. 해결: 모든 쿼리 소비자에 로딩/에러/빈 상태 분기 적용
```

#### 예시 2: setState on unmounted 경고
```
잘못된 방법: 경고만 무시

올바른 방법:
1. 왜 unmount 후 호출? → 비동기 작업 완료 시점 문제
2. 다른 곳은? → grep -rn "useEffect" apps/mobile-rn/src/
3. 올바른 패턴? → AbortController 또는 cleanup 플래그
4. 해결: 모든 비동기 effect에 취소/cleanup 로직 추가
```

#### 예시 3: 인덱스 초과 에러
```
잘못된 방법: if (list.length > index) { ... }

올바른 방법:
1. 왜 인덱스 초과? → 리스트가 비어있거나 삭제된 상태에서 접근
2. 다른 곳은? → 리스트 접근부 전수 검색
3. 올바른 패턴? → 빈 배열 가드 + 기본 화면
4. 해결: 리스트 상태 관리 및 렌더 가드 개선
```

### 핵심 원칙

**"에러 로그를 없애려는 것이 아니라, 에러가 발생하지 않도록 근본 원인을 해결한다"**

1. **증상 치료 금지**: try-catch로 숨기거나 optional chaining/기본값으로만 우회하지 말 것
2. **근본 원인 분석 필수**: 왜 에러가 발생했는지 반드시 파악
3. **전체 검색 필수**: 동일한 패턴이 다른 곳에 없는지 `apps/mobile-rn/src/` 전체 확인
4. **올바른 패턴 적용**: 이미 잘 처리된 곳의 패턴을 찾아 적용
5. **일관성 유지**: 한 곳만 고치지 말고 전체를 일관되게 수정 (하나씩 Edit)

**이것이 모든 에러 처리의 최우선 원칙입니다!**
