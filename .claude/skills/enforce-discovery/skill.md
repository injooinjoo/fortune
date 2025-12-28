---
name: "sc:enforce-discovery"
description: "기존 코드 탐색 강제. 새 코드 작성 전 필수 실행. Discovery 보고서 미작성 시 코드 생성 차단."
---

# Enforce Discovery Skill (Hard Block)

새 코드 작성 전 기존 코드 탐색을 **강제**하는 Hard Block 스킬입니다.

**이 스킬을 건너뛸 수 없습니다. Discovery 보고서 없이 새 코드 작성은 차단됩니다.**

---

## 사용법

```
/sc:enforce-discovery 날짜 선택 위젯
/sc:enforce-discovery StateNotifier 생성
/sc:enforce-discovery API 서비스 클래스
/sc:enforce-discovery 운세 결과 모델
```

---

## 차단 조건

| 조건 | 상태 |
|------|------|
| 유사 코드 검색 미수행 | ⛔ 차단 |
| 검색 결과 0개 (더 넓은 범위 검색 필요) | ⛔ 차단 |
| 재사용 결정 미작성 | ⛔ 차단 |
| Discovery 보고서 미출력 | ⛔ 차단 |

---

## 강제 탐색 프로세스

```
1️⃣ 목표 분석
   └─ 무엇을 만들려고 하는지 파악
   └─ 키워드 추출
   └─ 검색 전략 수립

2️⃣ 유사 코드 검색 (최소 5개 파일 확인)
   └─ 파일명 패턴 검색
   └─ 클래스/함수명 검색
   └─ 기능별 검색

   필수 명령어:
   ```bash
   # 파일명 검색
   find lib -name "*[키워드]*.dart"

   # 클래스명 검색
   grep -rn "class.*[키워드]" lib/

   # 함수명 검색
   grep -rn "void [키워드]" lib/
   grep -rn "[키워드](" lib/
   ```

   ⛔ 검색 미수행 시: "기존 코드 검색 먼저 실행해주세요" 출력 후 차단
   ⛔ 검색 결과 0개 시: "더 넓은 범위로 검색해주세요" 출력 후 차단

3️⃣ 재사용 가능 코드 확인
   └─ 이미 있는 함수/클래스 확인
   └─ 확장 가능한 코드 확인
   └─ 유틸리티 함수 확인

   ⛔ 재사용 결정 없이 진행 시: "재사용/참조할 코드 명시해주세요" 출력 후 차단

4️⃣ 참조 패턴 확인
   └─ 프로젝트의 기존 패턴 확인
   └─ 일관성 있는 코드 작성 위함
   └─ 네이밍 컨벤션 확인

5️⃣ Discovery 보고서 생성
   └─ 아래 형식 필수 출력
   └─ JIRA Story/Task 이슈 자동 생성
```

---

## 작업 유형별 필수 검색

| 작업 | 필수 검색 명령어 |
|------|-----------------|
| StateNotifier 생성 | `grep -rn "extends StateNotifier" lib/` |
| Widget 생성 | `find lib -name "*widget*.dart"` + `grep -rn "class.*Widget" lib/` |
| Service 생성 | `grep -rn "class.*Service" lib/` |
| Model 생성 | `grep -rn "@freezed" lib/` |
| Provider 생성 | `grep -rn "StateNotifierProvider" lib/` |
| Page 생성 | `find lib -name "*page*.dart"` |
| Edge Function | `ls supabase/functions/` |
| API 호출 | `grep -rn "supabase.functions.invoke" lib/` |

---

## 필수 출력 형식

**이 보고서가 출력되어야 차단이 해제됩니다:**

```
============================================
📂 Discovery (기존 코드 탐색) 보고서
============================================

🎯 목표
   작업: [무엇을 만들 것인지]
   유형: [Widget / Service / Model / StateNotifier / Page / ...]

🔍 검색 수행
   검색어 1: [패턴1]
   검색어 2: [패턴2]
   검색어 3: [패턴3]

📁 검색 결과 (N개 파일 확인)

   ✅ 재사용 가능:
   1. [파일1.dart]
      └─ [함수/클래스명] - 그대로 사용 가능
      └─ 이유: [왜 재사용 가능한지]

   📌 패턴 참조:
   2. [파일2.dart]
      └─ [함수/클래스명] - 구조 참조
      └─ 이유: [무엇을 참조할지]

   3. [파일3.dart]
      └─ [함수/클래스명] - 네이밍 참조

   📝 참고만:
   4. [파일4.dart] - 유사하나 목적 다름
   5. [파일5.dart] - 부분적 참고

♻️ 재사용 결정

   재사용할 코드:
   - [함수명/클래스명] from [파일] → 그대로 import해서 사용

   참조할 패턴:
   - [패턴] from [파일] → 같은 구조로 작성
   - [네이밍 컨벤션] from [파일] → 같은 형식으로 네이밍

   새로 작성할 부분:
   - [꼭 필요한 부분만 명시]
   - 이유: [왜 새로 작성해야 하는지]

⚠️ 중복 방지
   - 기존 [X]가 있으므로 새로 만들지 않음
   - 기존 [Y]를 확장해서 사용

============================================
✅ Discovery 보고서 완료 - 차단 해제
📋 JIRA: FORT-XXX (Story/Task) 생성됨
============================================

➡️ 이제 코드 생성을 진행합니다.
```

---

## 중복 감지 자동 차단

**새 파일 생성 시 유사 파일 존재하면:**

```
⛔ HARD BLOCK: 중복 의심 파일 감지됨

생성하려는 파일: fortune_utils.dart
유사 기존 파일: lib/core/utils/fortune_helper.dart

기존 파일을 먼저 확인해주세요:
1. 기존 파일로 충분한지 검토
2. 기존 파일 확장이 가능한지 검토
3. 정말 새 파일이 필요한지 판단

/sc:enforce-discovery [작업 목표]
```

---

## JIRA 연동

Discovery 보고서 완료 시 자동으로:

```
jira_post:
  project: FORT
  issuetype: Story (기능 추가) 또는 Task (수정)
  summary: "[Discovery] {작업 목표 요약}"
  description: |
    ## 목표
    {무엇을 만들 것인지}

    ## 기존 코드 분석
    {재사용 가능 코드 목록}

    ## 재사용 결정
    {재사용/참조/새로 작성 결정}

    ## 중복 방지
    {중복 방지 조치}
```

---

## 완료 후 흐름

```
Discovery 보고서 완료
    │
    ├─ JIRA Story/Task 이슈 생성됨
    │
    └─ 다음 단계 안내:
       "Discovery 분석이 완료되었습니다.
        재사용 결정에 따라 코드 작성을 진행하세요.
        작성 완료 후 /sc:enforce-verify가 자동 호출됩니다."
```

---

## 프로젝트 주요 재사용 대상

### 자주 재사용되는 코드

| 카테고리 | 파일 | 용도 |
|----------|------|------|
| 상태관리 | `*_notifier.dart` | StateNotifier 패턴 |
| UI 컴포넌트 | `core/widgets/` | 공통 위젯 |
| 디자인 | `TossDesignSystem` | 색상, 간격 |
| 타이포 | `context.heading1` 등 | 폰트 스타일 |
| 블러 | `UnifiedBlurWrapper` | 블러 처리 |
| API | `*_api_service.dart` | API 호출 패턴 |
| 모델 | `@freezed` 클래스 | 데이터 모델 |