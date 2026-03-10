# Fortune Screen And Component Registry

## 기준

- 공식 파일: [Fortune Design Source of Truth](https://www.figma.com/file/xKO8asAUg2g9fqpQQ9PZwb/Fortune-Design-Source-of-Truth?type=design&node-id=1-2&mode=design)
- 파일 키: `xKO8asAUg2g9fqpQQ9PZwb`
- 라우트 기준 소스: `lib/routes/route_config.dart`
- nested route 소스:
  - `lib/routes/routes/auth_routes.dart`
  - `lib/routes/routes/interactive_routes.dart`
  - `lib/routes/routes/trend_routes.dart`
  - `lib/routes/routes/wellness_routes.dart`
  - `lib/routes/character_routes.dart`

이 문서는 공식 Figma 파일에 들어가는 화면, 레이아웃, 컴포넌트 인벤토리의 저장소 기준 사본이다.

## Route Inventory

현재 route config 기준으로 관리 중인 핵심 route family는 아래와 같다.

### Entry / Auth

- `/`
- `/splash`
- `/signup`
- `/auth/callback`
- `/onboarding`
- `/onboarding/toss-style`

### Main Shell

- `/chat`
- `/home`
- `/fortune`
- `/history`
- `/more`

### Profile / Account / Monetization

- `/profile`
- `/profile/edit`
- `/profile/saju`
- `/profile/saju-summary`
- `/profile/elements`
- `/profile/verification`
- `/profile/social-accounts`
- `/profile/phone-management`
- `/profile/notifications`
- `/profile/font`
- `/profile/account-deletion`
- `/subscription`
- `/token-purchase`
- `/premium`

### Interactive / Fortune Flows

- `/interactive`
- `/interactive/dream`
- `/interactive/psychology-test`
- `/interactive/tarot`
- `/interactive/animated-flow`
- `/interactive/face-reading`
- `/interactive/taemong`
- `/interactive/worry-bead`
- `/interactive/dream-journal`
- `/manseryeok`
- `/health-toss`
- `/medical-document-result`
- `/exercise`
- `/sports-game`

### Trend / Wellness

- `/trend`
- `/trend/psychology/:contentId`
- `/trend/worldcup/:contentId`
- `/trend/balance/:contentId`
- `/wellness`
- `/wellness/meditation`

### Utility / Support / Detail / Admin

- `/help`
- `/privacy-policy`
- `/terms-of-service`
- `/fortune-history/:id`
- `/character/:id`
- `/admin/celebrity-crawling`

## Layout Shell Inventory

### Primary Shells

- `lib/shared/layouts/main_shell.dart`
- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/screens/onboarding/onboarding_page.dart`
- `lib/features/character/presentation/pages/character_onboarding_page.dart`

### Section Shell Families

- `lib/features/history/presentation/pages/fortune_history_page.dart`
- `lib/features/more/presentation/pages/fortune_tab_page.dart`
- `lib/features/more/presentation/pages/more_page.dart`
- `lib/features/trend/presentation/pages/trend_page.dart`
- `lib/features/wellness/presentation/pages/wellness_page.dart`
- `lib/features/wellness/presentation/pages/meditation_page.dart`
- `lib/screens/profile/profile_screen.dart`

## Page / Screen Source Inventory

### Admin

- `lib/features/admin/pages/celebrity_crawling_page.dart`

### Character

- `lib/features/character/presentation/pages/character_onboarding_page.dart`
- `lib/features/character/presentation/pages/character_profile_page.dart`

### Exercise

- `lib/features/exercise/presentation/pages/exercise_fortune_page.dart`

### Fortune / Calendar

- `lib/features/fortune/presentation/pages/manseryeok_page.dart`

### Health

- `lib/features/health/presentation/pages/health_fortune/health_fortune_page.dart`
- `lib/features/health/presentation/pages/health_fortune_page.dart`
- `lib/features/health/presentation/pages/medical_document_result_page.dart`

### History

- `lib/features/history/presentation/pages/fortune_history_detail_page.dart`
- `lib/features/history/presentation/pages/fortune_history_page.dart`

### Interactive

- `lib/features/interactive/presentation/pages/dream_interpretation_page.dart`
- `lib/features/interactive/presentation/pages/dream_page.dart`
- `lib/features/interactive/presentation/pages/face_reading_page.dart`
- `lib/features/interactive/presentation/pages/interactive_list_page.dart`
- `lib/features/interactive/presentation/pages/psychology_test_page.dart`
- `lib/features/interactive/presentation/pages/taemong_page.dart`
- `lib/features/interactive/presentation/pages/tarot_animated_flow_page.dart`
- `lib/features/interactive/presentation/pages/tarot_chat_page.dart`
- `lib/features/interactive/presentation/pages/worry_bead_page.dart`

### More / Explore

- `lib/features/more/presentation/pages/fortune_tab_page.dart`
- `lib/features/more/presentation/pages/more_page.dart`

### Notification / Payment / Policy / Settings / Support

- `lib/features/notification/presentation/pages/notification_settings_page.dart`
- `lib/features/payment/presentation/pages/token_purchase_page.dart`
- `lib/features/policy/presentation/pages/privacy_policy_page.dart`
- `lib/features/policy/presentation/pages/terms_of_service_page.dart`
- `lib/features/settings/presentation/pages/font_settings_page.dart`
- `lib/features/support/presentation/pages/help_page.dart`

### Trend

- `lib/features/trend/presentation/pages/trend_balance_game_page.dart`
- `lib/features/trend/presentation/pages/trend_ideal_worldcup_page.dart`
- `lib/features/trend/presentation/pages/trend_page.dart`
- `lib/features/trend/presentation/pages/trend_psychology_test_page.dart`

### Wellness

- `lib/features/wellness/presentation/pages/meditation_page.dart`
- `lib/features/wellness/presentation/pages/wellness_page.dart`

### Auth / Onboarding / Premium / Profile / Settings

- `lib/screens/auth/callback_page.dart`
- `lib/screens/auth/signup_screen.dart`
- `lib/screens/onboarding/onboarding_page.dart`
- `lib/screens/premium/premium_screen.dart`
- `lib/screens/profile/account_deletion_page.dart`
- `lib/screens/profile/elements_detail_page.dart`
- `lib/screens/profile/profile_edit_page.dart`
- `lib/screens/profile/profile_screen.dart`
- `lib/screens/profile/profile_verification_page.dart`
- `lib/screens/profile/saju_detail_page.dart`
- `lib/screens/profile/saju_summary_page.dart`
- `lib/screens/settings/phone_management_screen.dart`
- `lib/screens/settings/social_accounts_screen.dart`
- `lib/screens/splash_screen.dart`
- `lib/screens/subscription/subscription_page.dart`

## Component Inventory

### DS Primitives

- `lib/core/design_system/components/ds_badge.dart`
- `lib/core/design_system/components/ds_bottom_sheet.dart`
- `lib/core/design_system/components/ds_button.dart`
- `lib/core/design_system/components/ds_card.dart`
- `lib/core/design_system/components/ds_chip.dart`
- `lib/core/design_system/components/ds_list_tile.dart`
- `lib/core/design_system/components/ds_loading.dart`
- `lib/core/design_system/components/ds_modal.dart`
- `lib/core/design_system/components/ds_section_header.dart`
- `lib/core/design_system/components/ds_text_field.dart`
- `lib/core/design_system/components/ds_toast.dart`
- `lib/core/design_system/components/ds_toggle.dart`
- `lib/core/design_system/components/hanji_background.dart`

### Traditional / Heritage Components

- `lib/core/design_system/components/traditional/cloud_bubble.dart`
- `lib/core/design_system/components/traditional/cloud_bubble_painter.dart`
- `lib/core/design_system/components/traditional/seal_stamp_widget.dart`
- `lib/core/design_system/components/traditional/traditional_knot_indicator.dart`

### Shared Product Components

- `lib/shared/components/app_header.dart`
- `lib/shared/components/korean_date_picker.dart`
- `lib/shared/components/loading_states.dart`
- `lib/shared/components/premium_membership_card.dart`
- `lib/shared/components/profile_header_icon.dart`
- `lib/shared/components/progressive_date_input.dart`
- `lib/shared/components/purchase_loading_overlay.dart`
- `lib/shared/components/section_header.dart`
- `lib/shared/components/settings_list_tile.dart`
- `lib/shared/components/toast.dart`
- `lib/shared/components/token_balance_widget.dart`
- `lib/shared/components/token_insufficient_modal.dart`

### Token Families

- `lib/core/design_system/tokens/ds_animation.dart`
- `lib/core/design_system/tokens/ds_colors.dart`
- `lib/core/design_system/tokens/ds_radius.dart`
- `lib/core/design_system/tokens/ds_shadows.dart`
- `lib/core/design_system/tokens/ds_spacing.dart`
- `lib/core/design_system/tokens/ds_typography.dart`

## 운영 체크리스트

### 새 화면 추가 시

1. route family와 실제 page 파일을 둘 다 확인한다.
2. 공식 Figma 파일의 `10 Screen Registry`를 업데이트한다.
3. 이 문서의 route inventory와 page source inventory를 같이 업데이트한다.

### 레이아웃 셸 변경 시

1. `20 Layout Shells`를 먼저 업데이트한다.
2. 영향받는 screen family가 있으면 `10 Screen Registry`도 같이 업데이트한다.
3. `/chat` 같이 상태 전환이 있는 surface는 verified state 자료를 유지한다.

### 공용 컴포넌트 변경 시

1. component family를 primitive, heritage, shared product 중 하나로 분류한다.
2. 공식 Figma 파일 `30 Components`와 이 문서의 component inventory를 같이 업데이트한다.
3. 코드에 남아 있는 legacy component를 조용히 삭제하지 않는다.
