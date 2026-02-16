# Discovery Report - Store Review Gate Blockers (KAN-19)

## 요청/목표
- 요청: iOS/Android 심사 게이트가 `문제 없음` 상태가 될 때까지 반복 수정.
- 기준: analyze/test/build/lint 및 심사 핵심 리스크(P0/P1) 제거.

## 사전 조사 결과

### 1) iOS 회귀 스크립트
- 대상 파일: `scripts/run_ios_integration_tests.sh`, `scripts/ios_full_regression.sh`
- 관찰:
  - 기본 시뮬레이터가 `iPhone 15 Pro`로 고정되어 있으며, 미존재 시 즉시 실패.
  - 환경별 설치된 런타임 차이로 false negative 발생 가능.
- 재사용 판단:
  - 기존 `simctl` 기반 부팅/검증 로직 재사용 가능.
  - 신규 스크립트 추가 없이 기존 파일 확장.

### 2) Android 결제 검증
- 대상 파일: `supabase/functions/payment-verify-purchase/index.ts`
- 관찰:
  - Android 분기에서 `purchaseToken` 존재 여부만 확인 후 성공 처리(TODO 미해결).
  - 실제 Google Play 서버 검증 부재로 심사 리스크 P1.
- 재사용 판단:
  - 기존 iOS 검증 함수 패턴(외부 서버 검증 → 결과 반영) 재사용.
  - Google Play는 신규 보조 함수(`OAuth JWT`, `access token`, `purchase verify`) 추가 필요.

### 3) 메타데이터 소스 일관성
- 대상 디렉터리: `ios/fastlane/metadata/en-US`
- 관찰:
  - `support_url.txt` 누락.
  - KR/EN 매트릭스 기준 누락으로 판정될 수 있음.
- 재사용 판단:
  - 기존 동일 디렉터리(`privacy_url.txt`) 패턴 그대로 파일 추가.

### 4) 정적 분석 이슈
- 관찰:
  - `flutter analyze` 78건(대다수 `curly_braces_in_flow_control_structures`).
  - 자동 수정 가능 항목 비율 높음.
- 재사용 판단:
  - `dart fix --apply`로 자동 수정 우선.
  - 잔여 항목(`use_build_context_synchronously`, deprecated, unused)은 파일별 수동 수정.

## 변경 전략
1. 빌드/심사 차단 리스크 우선순위 수정
   - Android 실제 서버 검증 도입
   - iOS 시뮬레이터 fallback 도입
2. 메타데이터 누락 파일 보완
3. analyzer 이슈 일괄 정리 후 잔여 수동 수정
4. 전체 게이트 반복 실행 후 fail 원인 재수정

## 영향 범위(예정)
- scripts/
- supabase/functions/payment-verify-purchase/
- ios/fastlane/metadata/en-US/
- analyzer가 지적한 일부 Dart 파일

## 리스크/가정
- Google Play 검증용 서비스 계정 정보는 환경변수로 주입되어 있어야 한다.
- Flutter/Dart 버전에 따라 deprecated 경고 항목은 코드 패턴 조정이 필요할 수 있다.
- 기존 사용자 변경(working tree dirty)은 건드리지 않고 최소 범위로만 수정한다.
