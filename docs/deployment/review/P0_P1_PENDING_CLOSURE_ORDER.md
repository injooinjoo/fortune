# P0/P1 Pending Closure Order (Manual Review Evidence)

## 목적
- 현재 코드/정책/메타데이터 하드닝(`KAN-166`)은 완료됐으며, 제출 `NO-GO`의 잔여 원인은 수동 증빙(`P0/P1 pending`)이다.
- 본 문서는 2026-03-22 기준으로 `어떤 순서로`, `어떤 증빙을`, `어디에` 남겨야 Apple 재제출 `GO`로 전환 가능한지 실행 순서를 고정한다.

## 기준 커밋 (동결)
- `KAN-166` 최종 커밋 SHA를 push 시점에 동결

## 공통 증빙 저장 규칙
- 증빙 루트: `docs/deployment/review/evidence/2026-03-22/`
- 하위 폴더:
  - `ios/kr/`, `ios/en/`, `android/kr/`, `android/en/`
  - `console/app_store_connect/`, `console/google_play/`
  - `logs/`
- 파일명 규칙: `{check_id}_{platform}_{locale}_{yyyymmdd_hhmm}.{png|mp4|txt}`

## 실행 순서 (고정)

### 1) iOS P0 시나리오 먼저 종료
- 대상 check_id:
  - `IOS-RUNTIME-002`
  - `IOS-IAP-001`, `IOS-IAP-002`, `IOS-IAP-003`
  - `APPLE-RUNTIME-001`, `APPLE-IAP-002`
- 작업 순서:
  1. iPhone에서 기존 앱 삭제 후 새 빌드 clean install
  2. 게스트 진입 → 메시지/프로필 경로에서 로그인 바텀시트 호출
  3. Apple 로그인 성공 후 `Network connection error` 미노출 확인
  4. IAP 성공 / 취소 / 복원 1회씩 수행 + 기기 로그 캡처
  5. 가능하면 다른 네트워크 1종에서도 동일 동선 반복
- 완료 기준:
  - 각 check_id별 영상/로그 최소 1세트
  - `IOS_REVIEW_EVIDENCE.md`, `STORE_REVIEW_MASTER_CHECKLIST.md` 해당 행을 `pass/done`으로 전환

### 2) iOS P1 시나리오 종료
- 대상 check_id:
  - `IOS-RUNTIME-003`, `IOS-RUNTIME-004`
  - `APPLE-RUNTIME-002`, `APPLE-RUNTIME-003`
- 작업 순서:
  1. iPad에서 `/chat` 진입, 로그인, 정책 페이지 진입, 구매 진입 확인
  2. 레이아웃 깨짐/overflow/no-op 없는지 영상 또는 스크린샷 확보
  3. NAT64 / IPv6-only 네트워크가 가능하면 동일 로그인 재시도 기록
- 완료 기준:
  - iPad 경로 증빙 1세트
  - NAT64 / IPv6-only는 가능할 때만 진행하고, 불가 시 테스트 불가 메모를 기록

### 3) App Store Connect 제출 자산 최종 확인
- 대상 check_id:
  - `2.3.3`, `2.3.4`, `2.3.9` 관련 제출 전 체크
- 작업 순서:
  1. App Store Connect 스크린샷 / App Preview / age rating / App Privacy 마지막 점검
  2. review notes, public privacy/terms, in-app policy, 제출 메타데이터가 동일한지 재대조
- 완료 기준:
  - 제출 직전 캡처 또는 확인 메모 1세트

### 4) Android / Play는 별도 흐름으로 유지
- 대상 check_id:
  - `PLAY-001`, `PLAY-002`, `PLAY-003`
- 메모:
  - Apple 재제출과 직접 무관한 전체 스토어 릴리즈 게이트이므로, Apple 수동 증빙 종료 후 별도 처리

### 5) 최종 GO/NO-GO 판정
- 대상 check_id:
  - `DEC-002`, `DEC-003`, `DEC-004`, `DEC-007`, `DEC-008`
- 작업 순서:
  1. `STORE_REVIEW_MASTER_CHECKLIST.md`의 P0/P1 전체 재집계
  2. `IOS_REVIEW_EVIDENCE.md`의 Apple 관련 P0/P1 open=0 확인
  3. `RELEASE_DECISION_LOG.md`에 현재 커밋 SHA와 최종 엔트리 작성
  4. 리스크 승인자 서명
- GO 조건:
  - Apple 재제출 기준: `APPLE-P0=0`, `APPLE-P1=0`, 증빙 경로 전부 채움
  - 전체 스토어 릴리즈 기준: Apple + Play open=0

## 상태 업데이트 규칙
- 항목 완료 시 반드시 동시에 갱신:
  1. 해당 evidence 문서의 `result/status/evidence/due_date`
  2. `STORE_REVIEW_MASTER_CHECKLIST.md` 매핑 행
  3. `RELEASE_DECISION_LOG.md` 집계값/결정

## 블로커 처리 규칙
- P0 재발 시 즉시 `NO-GO` 유지, 코드/설정 수정 후 해당 단계부터 재실행.
- P1 미해결 상태에서는 제출 금지(보수적 게이트 정책).
