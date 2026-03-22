# KAN Open Issues Evidence Matrix

기준 시각: 2026-03-22 KST  
기준 브랜치: `master`  
기준 문서: `docs/deployment/review/APPLE_GUIDELINES_AUDIT_2026-03-22.md`

## Overall Verdict

- 현재 열린 KAN 이슈 중 다수는 이미 `master`에 구현 커밋이 반영되었지만 Jira 상태가 정리되지 않은 케이스입니다.
- Apple/App Review 차단 항목은 모두 단일 버그가 아니라 `정책/메타데이터/설정 정합성 + 실기기 증빙 부족` 문제로 수렴합니다.
- 오늘 기준으로 즉시 닫아도 되는 항목과, 실기기/ASC/Figma 원격 상태 확인 없이는 닫으면 안 되는 항목을 분리했습니다.

## Apple P0/P1 Mapping

| Apple 항목 | 현재 판정 | 연결 Jira | 근거 | 조치 |
| --- | --- | --- | --- | --- |
| `2.1(a)` 최근 Apple 네트워크 오류 | `Needs Manual Proof` | `KAN-146`, `KAN-135` | `lib/core/services/supabase_connection_service.dart`, `lib/presentation/widgets/social_login_bottom_sheet.dart`, Apple rejection evidence | 새 빌드로 실기기 재검증 후 닫기 |
| `2.3`, `5.1` 정책/메타데이터 불일치 | `Confirmed Open -> file fix in this pass` | `KAN-135` | 인앱/공개 정책 불일치, stale release notes | 이번 커밋으로 문구 정리, ASC 입력은 계속 필요 |
| `2.3.12` release notes 불일치 | `Confirmed Open -> file fix in this pass` | `KAN-135` | `ios/fastlane/metadata/ko/release_notes.txt` | KR/EN release notes 갱신 |
| `2.5.16` Live Activities 과다 선언 | `Confirmed Open -> file fix in this pass` | `KAN-135` | `ios/Runner/Info.plist`, 호출부 부재 | Info.plist 선언 제거, 네이티브 정리 여부는 후속 확인 |
| `3.1` IAP success/cancel/restore | `Needs Manual Proof` | `KAN-135` | `docs/deployment/review/IOS_REVIEW_EVIDENCE.md` open items | 샌드박스 수동 검증 후 닫기 |
| `4.8`, `5.1.1(v)` 로그인/계정삭제 정합성 | `Already Fixed` | `KAN-140`, `KAN-135` | `lib/features/chat/presentation/widgets/profile_bottom_sheet.dart`, `lib/screens/profile/profile_screen.dart` | Jira 정리 가능 |

## Full Evidence Matrix

| Key | Category | 현재 Jira 상태 | 현재 판정 | 구체 근거 | 최종 처리 액션 |
| --- | --- | --- | --- | --- | --- |
| `KAN-165` | audit / Apple | `To Do` | `Confirmed Open` | 이번 턴 작업 추적용 이슈. 새 매트릭스와 Apple 정리 커밋으로 닫을 예정 | 이번 작업 완료 후 `Resolved` |
| `KAN-156` | umbrella / quality | `To Do` | `Obsolete/Superseded` | 범용 professionalization 이슈. 실제 산출물은 `KAN-164` Apple audit + `KAN-165` evidence matrix로 분기됨. 기존 커밋 `0f8882fd`, `52ae1732` 존재 | 근거 코멘트 후 `Resolved` |
| `KAN-149` | Apple / auth | `To Do` | `Already Fixed` | `lib/presentation/providers/auth_provider.dart`의 `shouldBlockChatRestorationOverlay`, `test/unit/providers/auth/chat_restoration_policy_test.dart`, 커밋 `71bf9084` | 코멘트 후 `Resolved` |
| `KAN-146` | Apple / auth | `To Do` | `Needs Manual Proof` | `lib/services/social_auth/base/base_social_auth_provider.dart`의 `SocialAuthConfigGuard`, `lib/core/services/supabase_connection_service.dart`, 관련 테스트 존재. 다만 Apple 실제 기기 재검증 미완료 | 실기기 재검증 체크리스트 남기고 유지 |
| `KAN-145` | UI / splash | `To Do` | `Already Fixed` | `lib/screens/splash_screen.dart`가 `DSColors.backgroundDark` 기반 dark-only splash로 유지, 커밋 `24f056c5` 존재 | 코멘트 후 `Resolved` |
| `KAN-140` | auth / session | `In Progress` | `Already Fixed` | `lib/services/session_cleanup_service.dart`, `lib/features/chat/presentation/widgets/profile_bottom_sheet.dart`, `lib/features/character/presentation/pages/character_chat_panel.dart`의 auth gate, 테스트 및 커밋 `a0275823` | 코멘트 후 `Resolved` |
| `KAN-135` | Apple / store review | `Waiting for Customer` | `Confirmed Open` | `docs/deployment/review/APPLE_GUIDELINES_AUDIT_2026-03-22.md`, `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`, `ios/fastlane/metadata/*`에서 여전히 ASC/실기기/IAP 증빙 미완료 | 이번 파일 정리 반영 후 계속 유지 |
| `KAN-133` | chat / localization | `To Do` | `Already Fixed` | 현 브랜치에 커밋 `9a4fd6f8` 반영, follow-up doc commit `da56b3f0` 존재 | 코멘트 후 `Resolved` |
| `KAN-132` | chat / theme | `To Do` | `Already Fixed` | 커밋 `f4a9700f`, 현재 채팅 패널 dirty worktree에도 fortune chip theme 관련 필드 존재 | 코멘트 후 `Resolved` |
| `KAN-130` | push / notification | `In Progress` | `Needs Manual Proof` | 커밋 `9843f542` 존재하지만 DM reply push 정합성은 APNs/실기기 검증 필요 | 수동 푸시 검증 체크리스트 남기고 유지 |
| `KAN-128` | chat / sorting | `To Do` | `Already Fixed` | 커밋 `42d58012` 존재 | 코멘트 후 `Resolved` |
| `KAN-123` | chat / Haneul | `To Do` | `Already Fixed` | 커밋 `770162b5` 존재, `lib/features/character/presentation/pages/character_chat_panel.dart`에 `haneulCharacter` shell 유지 | 코멘트 후 `Resolved` |
| `KAN-122` | UI / button tone | `To Do` | `Already Fixed` | 커밋 `b4fbfe55` 존재 | 코멘트 후 `Resolved` |
| `KAN-120` | chat / pet survey | `To Do` | `Already Fixed` | 커밋 `baf16cf9` 존재, `character_chat_panel.dart`에 pet profile imports/management state 존재 | 코멘트 후 `Resolved` |
| `KAN-109` | backend / model guard | `To Do` | `Already Fixed` | 커밋 `e92b6e3b` 존재, `supabase/migrations/20260227000001_guard_llm_model_config_cost.sql`에 Gemini cost guard 유지 | 코멘트 후 `Resolved` |
| `KAN-104` | chat / unread badge | `To Do` | `Already Fixed` | 커밋 `33eaf1d5` 존재 | 코멘트 후 `Resolved` |
| `KAN-97` | Figma / redesign | `To Do` | `Confirmed Open` | `git log --grep KAN-97` 결과 작업 커밋 없음 | 유지 |
| `KAN-94` | chat / auto-scroll | `To Do` | `Already Fixed` | 커밋 `4ad38ada`, `character_chat_panel.dart`의 anchor/auto-scroll 로직 대폭 존재 | 코멘트 후 `Resolved` |
| `KAN-78` | UI / theme | `To Do` | `Already Fixed` | 커밋 `9d738dfc` 존재 | 코멘트 후 `Resolved` |
| `KAN-77` | runtime cleanup | `To Do` | `Already Fixed` | 커밋 `2730e949`, `ba1b8002`; 현재 `rg -n "manseryeok|/manseryeok" lib` 기준 runtime route 없음 | 코멘트 후 `Resolved` |
| `KAN-75` | onboarding / routing | `To Do` | `Already Fixed` | 커밋 `4b4c9cd4`, `route_config.dart`에 `/premium` 유지 | 코멘트 후 `Resolved` |
| `KAN-72` | chat-first migration | `To Do` | `Already Fixed` | 커밋 `172f8197`, current-state docs의 `fortuneType -> /chat` 설명, 관련 코드 `lib/core/navigation/fortune_chat_route.dart` | 코멘트 후 `Resolved` |
| `KAN-71` | runtime cleanup | `To Do` | `Confirmed Open` | 이슈 목표와 달리 `lib/routes/route_config.dart`에 `/profile`와 profile 하위 route가 아직 active. 반면 `docs/getting-started/APP_SURFACES_AND_ROUTES.md`는 `/profile`을 비활성으로 표시 | 유지 |
| `KAN-68` | CI / monitoring | `To Do` | `Already Fixed` | 커밋 `75135296`, `71506bca`; Jira comment 기준 QA Monitoring success, perf `63/100`, edge `11/11 healthy` | 코멘트 후 `Resolved` |
| `KAN-67` | Figma / catalog | `Waiting for Customer` | `Needs Manual Proof` | repo-side doc/workflow 커밋 다수(`ee5d47b7`, `1a4f62c5`, `ce535e89`) 있으나 원격 Figma catalog 최종 append 상태는 로컬 코드만으로 확정 불가 | Figma 원격 검증 후 닫기 |
| `KAN-66` | Figma / naming | `To Do` | `Obsolete/Superseded` | 후속 이슈 `KAN-67`, `KAN-61`이 더 넓은 범위로 naming/coverage를 흡수. 현재 브랜치에 `KAN-66` 전용 커밋 없음 | 근거 코멘트 후 `Resolved` |
| `KAN-61` | Figma / coverage | `To Do` | `Needs Manual Proof` | 커밋 `d38c73e5`, `252c0617` 존재하나 공식 Figma 파일의 남은 placeholder 상태는 원격 확인 필요 | Figma 원격 검증 후 닫기 |
| `KAN-55` | cleanup / inventory | `To Do` | `Confirmed Open` | 커밋 다수 존재하지만 이슈 자체가 “continue cleanup batches” 성격. 현재도 `docs/development/UNUSED_CANDIDATES.md`와 inventory 산출물이 계속 남아 있음 | 유지 |

## Prioritized TODO

- [x] ~~열린 KAN 이슈 전부를 evidence matrix로 재분류한다.~~
- [x] ~~Apple P0/P1과 기존 KAN 이슈를 매핑한다.~~
- [x] ~~인앱 정책 페이지와 공개 정책 페이지의 핵심 문구를 정합화한다.~~
- [x] ~~KR/EN release notes를 현재 제출 버전에 맞게 갱신한다.~~
- [x] ~~사용하지 않는 Live Activities 선언을 Info.plist에서 제거한다.~~
- [ ] KAN-146: 새 빌드에서 Apple 로그인 placeholder host 재현이 사라졌는지 iPhone 실기기에서 확인한다.
- [ ] KAN-135: IAP success / cancel / restore를 샌드박스 계정으로 재검증한다.
- [ ] KAN-135: App Store Connect App Privacy / Age Rating / review metadata 최종 입력 상태를 확인한다.
- [ ] KAN-130: 캐릭터 DM 답장 푸시를 실기기 2대 이상 또는 실제 APNs 경로로 확인한다.
- [ ] KAN-71: `/profile` 및 잔존 runtime surfaces를 실제 목표 범위에 맞게 더 축소할지 결정하고 코드/문서를 일치시킨다.
- [ ] KAN-67, KAN-61: 공식 Figma 파일의 원격 상태를 확인하고 placeholder/coverage를 닫는다.
- [ ] KAN-55: orphan cleanup batch를 계속 진행해 inventory 후보를 줄인다.

## Manual Proof Checklist

### KAN-146 / Apple 로그인

- [ ] 이전 앱 삭제 후 새 빌드 설치
- [ ] 게스트 상태에서 로그인 바텀시트 열기
- [ ] Apple 로그인 시작 시 placeholder Supabase URL launch가 발생하지 않는지 확인
- [ ] 로그인 완료 후 네트워크 오류 스낵바 없이 채팅으로 복귀하는지 확인

### KAN-135 / IAP

- [ ] 구매 성공
- [ ] 구매 취소
- [ ] 복원
- [ ] 구독 관리 링크
- [ ] 영수증/토큰 반영 확인

### KAN-130 / 푸시

- [ ] 백그라운드 상태에서 DM 답장 수신
- [ ] 포그라운드 상태 중복 알림 억제
- [ ] 탭 시 올바른 캐릭터 스레드로 진입

### KAN-67 / KAN-61 / Figma

- [ ] 공식 Figma screen catalog에서 최신 route key 반영 확인
- [ ] placeholder node 잔존 여부 확인
- [ ] append/rename runbook 결과와 실제 파일 상태 대조
