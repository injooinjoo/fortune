---
name: "sc:troubleshoot"
description: "버그 수정 워크플로우. 에러 분석, 근본 원인 추적, 동일 패턴 일괄 수정 시 사용."
depends_on: ["sc:enforce-rca"]
auto_call_after: ["sc:enforce-verify"]
---

# Troubleshoot Skill

버그와 에러를 체계적으로 분석하고 수정하는 워크플로우 스킬입니다.

---

## ⛔ HARD BLOCK 전제 조건

**이 스킬 실행 전 반드시 `/sc:enforce-rca`가 완료되어야 합니다.**

```
RCA 보고서 없이 troubleshoot 실행 시:
⛔ 차단: "/sc:enforce-rca를 먼저 실행해주세요"
```

---

## 사용법

```
/sc:troubleshoot 타로 결과가 표시되지 않음
/sc:troubleshoot Null check operator used on a null value
/sc:troubleshoot 다크모드에서 텍스트가 안보임
```

---

## 분석 프로세스

```
1️⃣ 증상 분석
   └─ 에러 메시지 파싱
   └─ 에러 유형 분류

2️⃣ 근본 원인 추적
   └─ 에러 발생 파일 확인
   └─ 데이터 흐름 추적
   └─ 관련 코드 분석

3️⃣ 동일 패턴 검색
   └─ 프로젝트 전체에서 동일 문제 찾기
   └─ 올바르게 처리된 코드 찾기

4️⃣ 수정 방안 제시
   └─ Before/After diff 표시
   └─ 수정 이유 설명

5️⃣ 일괄 수정 제안
   └─ 동일 패턴 모두 수정
   └─ 일관성 유지

6️⃣ 검증
   └─ quality-guardian 호출
```

---

## 에러 유형별 체크리스트

### Null 에러
```
Null check operator used on a null value
```
- [ ] FutureBuilder에서 snapshot.data null 체크
- [ ] API 응답 필드 null 체크
- [ ] Provider 초기 상태 확인

### 타입 에러
```
type 'Null' is not a subtype of type 'String'
```
- [ ] JSON 파싱 시 타입 변환
- [ ] @Default 값 설정
- [ ] nullable 타입 사용

### setState 에러
```
setState() called after dispose()
```
- [ ] mounted 체크 추가
- [ ] Timer/Subscription dispose
- [ ] async 작업 취소

### Index 에러
```
RangeError: index out of range
```
- [ ] 리스트 길이 체크
- [ ] 빈 리스트 처리
- [ ] 인덱스 유효성 검증

---

## 리포트 형식

```
============================================
🔍 에러 근본 원인 분석
============================================

📋 에러 정보
   유형: Null check operator used on a null value
   위치: lib/features/fortune/presentation/pages/tarot_page.dart:45

🔎 근본 원인
   FutureBuilder에서 snapshot.data에 null 체크 없이 접근

   문제 코드:
   ```dart
   final result = snapshot.data!;  // snapshot.data가 null일 수 있음
   ```

🔍 동일 패턴 검색 결과
   발견된 파일 3개:
   1. lib/features/fortune/presentation/pages/tarot_page.dart:45 (현재 문제)
   2. lib/features/fortune/presentation/pages/daily_page.dart:62 (동일 문제)
   3. lib/features/profile/presentation/pages/profile_page.dart:38 (올바른 패턴)

✅ 수정 방안
   올바른 패턴 (profile_page.dart:38 참조):
   ```dart
   if (snapshot.connectionState == ConnectionState.waiting) {
     return const CircularProgressIndicator();
   }
   if (!snapshot.hasData || snapshot.data == null) {
     return const Text('데이터 없음');
   }
   final result = snapshot.data!;
   ```

============================================
수정 대상 파일: 2개
============================================

동일 패턴 모두 수정할까요? (Y/n)
```

---

## 금지 패턴

### 증상만 치료 (금지)
```dart
// ❌ 왜 null인지 분석 없이 조건만 추가
if (value != null) {
  // ...
}
```

### 에러 무시 (금지)
```dart
// ❌ 에러 숨기기
try {
  riskyOperation();
} catch (e) {
  // 아무것도 안함
}
```

### 단일 파일만 수정 (금지)
```
❌ 동일 패턴이 있는데 한 곳만 수정
✅ 프로젝트 전체 검색 후 일괄 수정
```

---

## 완료 후 자동 검증

**수정 완료 시 `/sc:enforce-verify`가 자동 호출됩니다.**

```
수정 완료!
    │
    └─ /sc:enforce-verify 자동 호출
        ├─ flutter analyze
        ├─ build_runner
        ├─ quality-guardian
        └─ 사용자 테스트 요청
```

---

## 완료 메시지

```
✅ 버그가 수정되었습니다!

📁 수정된 파일:
1. lib/features/fortune/presentation/pages/tarot_page.dart:45
2. lib/features/fortune/presentation/pages/daily_page.dart:62

🔧 수정 내용:
- FutureBuilder null 체크 추가
- ConnectionState 확인 로직 추가

➡️ /sc:enforce-verify 실행 중...
```