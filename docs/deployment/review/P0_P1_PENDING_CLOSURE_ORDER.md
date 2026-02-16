# P0/P1 Pending Closure Order (Manual Review Evidence)

## 목적
- 현재 자동 게이트는 통과했으며, 제출 `NO-GO`의 잔여 원인은 수동 증빙(`P0/P1 pending`)이다.
- 본 문서는 `어떤 순서로`, `어떤 증빙을`, `어디에` 남겨야 `GO`로 전환 가능한지 실행 순서를 고정한다.

## 기준 커밋 (동결)
- `c3f9a953ea6295498605cb18211ac63185ecb582`

## 공통 증빙 저장 규칙
- 증빙 루트: `docs/deployment/review/evidence/2026-02-16/`
- 하위 폴더:
  - `ios/kr/`, `ios/en/`, `android/kr/`, `android/en/`
  - `console/app_store_connect/`, `console/google_play/`
  - `logs/`
- 파일명 규칙: `{check_id}_{platform}_{locale}_{yyyymmdd_hhmm}.{png|mp4|txt}`

## 실행 순서 (고정)

### 1) iOS P0 시나리오 먼저 종료
- 대상 check_id:
  - `TC-IOS-001`, `TC-IOS-002`, `TC-IOS-003`, `TC-IOS-004`, `TC-IOS-005`, `TC-IOS-006`
  - `IOS-IAP-001`, `IOS-IAP-002`, `IOS-IAP-003`, `IOS-LINK-003`
- 작업 순서:
  1. KR 로케일로 설치→온보딩→핵심 진입 영상 기록
  2. 권한 프롬프트(카메라/사진) 노출 타이밍 캡처
  3. IAP 성공/취소/오류/복원 각각 1회 수행 + 서버 로그 캡처
  4. 유니버설 링크 탭 시 앱 직진입 영상 확보
  5. EN 로케일 동일 반복
- 완료 기준:
  - 각 check_id별 영상/스크린샷/로그 최소 1세트

### 2) Android P0 시나리오 종료
- 대상 check_id:
  - `TC-AND-001`, `TC-AND-002`, `TC-AND-004`
  - `AND-IAP-001`, `AND-LINK-004`, `AND-DATA-001`
- 작업 순서:
  1. AAB 설치/실행 증빙
  2. 권한 grant/deny/re-request 흐름 캡처
  3. 결제 성공/취소/복원 1회씩 수행
  4. App Links 검증
     - `adb shell pm get-app-links com.beyond.fortune`
     - 링크 탭 시 앱 직진입 영상
  5. Play Console Data Safety 제출 화면 캡처
- 완료 기준:
  - P0 항목 전부 `pass` + 증빙 파일 경로 기입

### 3) iOS/Android P1 정책 정합성 종료
- iOS P1 대상:
  - `IOS-PERM-004`, `IOS-PERM-005`, `IOS-PERM-006`
  - `IOS-PRIV-002`, `IOS-PRIV-003`, `IOS-META-004`, `IOS-SS-003`
- Android P1 대상:
  - `AND-PERM-002`, `AND-PERM-003`, `AND-PERM-005`, `AND-PERM-006`
  - `AND-DATA-002`, `AND-DATA-003`, `AND-IAP-003`, `AND-STAB-003`, `AND-COPY-001`, `AND-COPY-002`
- 작업 순서:
  1. 실제 코드/SDK 수집 데이터 매핑표 작성
  2. ASC App Privacy / Play Data Safety 답변과 1:1 대조
  3. 연령등급/콘텐츠 폼 최신화 캡처
  4. 메타데이터 문구 정책 점검(과장/오해 소지 제거)
- 완료 기준:
  - 각 P1 항목 evidence 링크 + 리뷰어 승인자 기록

### 4) 메타/버전/스크린샷 마감
- 대상 check_id:
  - `IOS-VERS-001`, `IOS-VERS-002`, `IOS-SS-001`, `IOS-SS-002`, `TC-COMMON-001`
- 작업 순서:
  1. `pubspec.yaml` 버전과 ASC 빌드 버전 대조
  2. KR/EN iPhone+iPad 스크린샷 세트 업로드 완료
  3. KR/EN 메타데이터 최종 diff 검토
- 완료 기준:
  - 누락 0건, 해상도/개수 규격 충족

### 5) 최종 GO/NO-GO 판정
- 대상 check_id:
  - `DEC-004`, `DEC-005`, `DEC-006`, `DEC-007`
- 작업 순서:
  1. `STORE_REVIEW_MASTER_CHECKLIST.md`의 P0/P1 전체 재집계
  2. `IOS_REVIEW_EVIDENCE.md`, `ANDROID_REVIEW_EVIDENCE.md` P0/P1 open=0 확인
  3. `RELEASE_DECISION_LOG.md`에 최종 엔트리 작성
  4. 리스크 승인자 서명
- GO 조건:
  - `P0=0`, `P1=0`, 증빙 경로 전부 채움

## 상태 업데이트 규칙
- 항목 완료 시 반드시 동시에 갱신:
  1. 해당 evidence 문서의 `result/status/evidence/due_date`
  2. `STORE_REVIEW_MASTER_CHECKLIST.md` 매핑 행
  3. `RELEASE_DECISION_LOG.md` 집계값/결정

## 블로커 처리 규칙
- P0 재발 시 즉시 `NO-GO` 유지, 코드/설정 수정 후 해당 단계부터 재실행.
- P1 미해결 상태에서는 제출 금지(보수적 게이트 정책).
