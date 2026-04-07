# 페이지 레이아웃 레퍼런스

> 최종 업데이트: 2026.04.06

Ondo의 현재 라우팅 구조와 주요 surface를 repo truth 기준으로 정리한 문서입니다. 화면 설명은 실제 route/file/provider 이름을 우선합니다.

## 라우팅 개요

```text
/                    -> /chat
/splash              -> 초기 진입
/signup              -> 인증 게이트
/auth/callback       -> 소셜 로그인 콜백
/onboarding          -> 기본 온보딩
/onboarding/toss-style?partial=true
/chat                -> 메인 진입점
/home                -> /chat redirect
/profile
  /edit
  /saju-summary
  /relationships
  /notifications
/premium
/character/:id
/friends/new/basic
/friends/new/persona
/friends/new/story
/friends/new/review
/friends/new/creating
/privacy-policy
/terms-of-service
/account-deletion
```

## 1. Splash

| 항목 | 내용 |
|------|------|
| 경로 | `/splash` |
| 파일 | `lib/screens/splash_screen.dart` |
| 레이아웃 | 중앙 정렬 단일 surface |

핵심 요소:
- 앱 아이콘
- 로딩 인디케이터
- 태그라인
- 인증/초기화 후 다음 route 결정

## 2. Signup Gate

| 항목 | 내용 |
|------|------|
| 경로 | `/signup` |
| 파일 | `lib/screens/auth/signup_screen.dart` |
| 레이아웃 | 중앙 정렬 onboarding gate |

핵심 요소:
- soft gate eyebrow
- 헤드라인/보조 설명
- 소셜 로그인 진입
- 게스트 진입

## 3. Onboarding

| 항목 | 내용 |
|------|------|
| 경로 | `/onboarding`, `/onboarding/toss-style` |
| 파일 | `lib/screens/onboarding/onboarding_page.dart` |
| 레이아웃 | 단계형 PageView / partial handoff 가능 |

핵심 단계:
1. 인증 진입
2. 생년월일/생시 입력
3. 관심사 선택
4. personalized handoff

비고:
- `/onboarding/toss-style`은 query의 `partial=true`를 받아 부분 완료 플로우로 진입합니다.

## 4. Chat-First Hub

| 항목 | 내용 |
|------|------|
| 경로 | `/chat` |
| 파일 | `lib/features/character/presentation/pages/swipe_home_shell.dart` |
| 레이아웃 | list panel + chat panel 조합 |

### 4-1. CharacterListPanel

| 항목 | 내용 |
|------|------|
| 파일 | `lib/features/character/presentation/pages/character_list_panel.dart` |
| 역할 | 대화 목록, 관심사 목록, 친구 생성 진입 |

핵심 요소:
- 캐릭터 목록
- 최근 메시지/상태
- 신규 친구 생성 CTA
- 온보딩 관심사 surface

### 4-2. CharacterChatPanel

| 항목 | 내용 |
|------|------|
| 파일 | `lib/features/character/presentation/pages/character_chat_panel.dart` |
| 역할 | 1:1 채팅, survey, 결과 카드 조립 |

관련 Provider:
- `characterChatProvider`
- `characterChatSurveyProvider`
- `activeCharacterChatProvider`
- `selectedCharacterProvider`
- `chatModeProvider`

## 5. Profile Cluster

| 항목 | 내용 |
|------|------|
| 경로 | `/profile` |
| 파일 | `lib/screens/profile/profile_screen.dart` |
| 레이아웃 | `RefreshIndicator` + `ListView` |

핵심 섹션:
- 프로필 요약 카드
- 통계 칩
- 나의 온도: 사주 요약 / 인간관계 / 알림 설정
- 구독 관리: 구독 및 토큰 / 구매 복원 / 외부 구독 관리
- 정보: 개인정보처리방침 / 이용약관
- 설정: 테마 모드 + primary provider badge
- 파괴적 액션: 로그아웃 / 계정 삭제

### 5-1. Profile Edit

| 항목 | 내용 |
|------|------|
| 경로 | `/profile/edit` |
| 파일 | `lib/screens/profile/profile_edit_page.dart` |

편집 필드:
- 이름
- 생년월일
- 생시
- 성별
- MBTI
- 혈액형
- 프로필 이미지

### 5-2. Saju Summary

| 항목 | 내용 |
|------|------|
| 경로 | `/profile/saju-summary` |
| 파일 | `lib/screens/profile/saju_summary_page.dart` |

핵심 요소:
- 사주 계산 결과
- 새로고침
- 미입력 시 empty state

### 5-3. Relationships

| 항목 | 내용 |
|------|------|
| 경로 | `/profile/relationships` |
| 파일 | `lib/screens/profile/profile_relationships_page.dart` |

핵심 요소:
- 관계 요약
- 메트릭 칩
- 관계 목록

### 5-4. Notification Settings

| 항목 | 내용 |
|------|------|
| 경로 | `/profile/notifications` |
| 파일 | `lib/features/notification/presentation/pages/notification_settings_page.dart` |

핵심 요소:
- 일일 운세 알림
- 캐릭터 메시지
- 이벤트/프로모션
- 토큰 알림
- 아침 알림 시간 선택
- 테스트 알림 보내기

## 6. Premium

| 항목 | 내용 |
|------|------|
| 경로 | `/premium` |
| 파일 | `lib/screens/premium/premium_screen.dart` |
| 레이아웃 | `RefreshIndicator` + `ListView` + expandable plans section |

핵심 섹션:
- hero card
- feature rows
- “프리미엄 사주 시작하기” CTA
- 플랜 및 토큰 옵션 expandable panel
- 구독 플랜 / 토큰 충전 / 프리미엄 콘텐츠 / 구매 복원

관련 서비스:
- `InAppPurchaseService`

## 7. Character Profile

| 항목 | 내용 |
|------|------|
| 경로 | `/character/:id` |
| 파일 | `lib/features/character/presentation/pages/character_profile_page.dart` |
| 레이아웃 | 프로필 상단 + 정보 패널 + single CTA |

핵심 요소:
- 아바타 / 대화 수 / 친밀도 / 관계 단계
- 이름, 태그, 설명
- 단일 메시지 CTA
- 사진 grid
- 세계관/성격/관계 설정 패널

## 8. Friend Creation Wizard

| 항목 | 내용 |
|------|------|
| 경로 | `/friends/new/*` |
| 파일 | `lib/features/character/presentation/pages/friend_creation_pages.dart` |
| 레이아웃 | 5단계 wizard |

단계:
1. `/friends/new/basic` - 이름 / 성별 / 관계
2. `/friends/new/persona` - 스타일 프리셋 / 성격 / 관심사
3. `/friends/new/story` - 관계 시나리오 / 배경
4. `/friends/new/review` - 확인
5. `/friends/new/creating` - 생성 중 로딩

관련 Provider:
- `friendCreationDraftProvider`

## 9. Policy And Account

| Surface | 경로 | 파일 |
|---------|------|------|
| Auth callback | `/auth/callback` | `lib/screens/auth/callback_page.dart` |
| Privacy policy | `/privacy-policy` | `lib/features/policy/presentation/pages/privacy_policy_page.dart` |
| Terms of service | `/terms-of-service` | `lib/features/policy/presentation/pages/terms_of_service_page.dart` |
| Account deletion | `/account-deletion` | `lib/screens/profile/account_deletion_page.dart` |

회원 탈퇴 페이지 필수 요소:
- 탈퇴 사유
- 선택 피드백
- 동의 체크박스
- 직접 입력 확인
- 조건 충족 시 활성화되는 삭제 버튼

## 공통 구성 계층

| 계층 | 대표 컴포넌트 |
|------|---------------|
| Page chrome | `PaperRuntimeBackground`, `PaperRuntimeAppBar`, `PaperRuntimePanel` |
| Design primitives | `DSButton`, `DSCard`, `DSChip`, `DSChoiceChips` |
| Fortune result shell | `FortuneCardSurface`, `FortuneSectionCard`, `FortuneResultFrame` |
| Chat/result assembly | `lib/features/chat/presentation/widgets/chat_saju_result_card.dart`, `lib/features/character/presentation/widgets/fortune_bodies/` 계층 |

## 관련 문서

- [02-architecture.md](02-architecture.md)
- [03-ui-design-system.md](03-ui-design-system.md)
- [18-chat-first-architecture.md](18-chat-first-architecture.md)
- [26-widget-component-catalog.md](26-widget-component-catalog.md)
