# 위젯 & 컴포넌트 카탈로그

> 최종 업데이트: 2026.04.06

Ondo의 운세/인사이트 UI를 구성하는 계층을 실제 코드 구조 기준으로 정리한 문서입니다. 단순 파일 나열보다, 어떤 층이 어떤 화면 조립에 쓰이는지를 알 수 있도록 재구성합니다.

## 계층 개요

| 계층 | 기준 경로 | 역할 |
|------|-----------|------|
| Design primitives | `lib/core/design_system/components/` | 범용 DS UI |
| Paper runtime | `lib/core/widgets/paper_runtime_chrome.dart`, `lib/core/widgets/paper_runtime_surface_kit.dart` | 페이지 chrome / panel / app bar |
| Shared result shells | `lib/shared/components/cards/fortune_cards.dart` | 운세 결과 공용 카드 surface |
| Chat result widgets | `lib/features/chat/presentation/widgets/` | 채팅 surface용 결과/프로필 widget |
| Result body widgets | `lib/features/character/presentation/widgets/fortune_bodies/` | 타입별 결과 페이지 본문 조립층 |
| Survey inputs | `lib/features/chat/presentation/widgets/survey/` | 채팅형 설문 입력 |
| Traditional visuals | `lib/core/design_system/components/traditional/`, `lib/core/design_system/components/hanji_background.dart` | 전통/장식 계층 |

## 1. Design Primitives

경로: `lib/core/design_system/components/`

| 컴포넌트 | 파일 | 핵심 역할 |
|----------|------|-----------|
| `DSButton` | `lib/core/design_system/components/ds_button.dart` | CTA, secondary, outline, ghost, destructive, gold, progress 버튼 |
| `DSCard` | `lib/core/design_system/components/ds_card.dart` | flat/elevated/outlined/hanji/premium/gradient/glassmorphism surface |
| `DSChip` | `lib/core/design_system/components/ds_chip.dart` | 상태/선택 chip |
| `DSChoiceChips` | `lib/core/design_system/components/ds_chip.dart` | 단일 선택 segmented chips |
| `DSBadge` | `lib/core/design_system/components/ds_badge.dart` | 상태 뱃지 |
| `DSBottomSheet` | `lib/core/design_system/components/ds_bottom_sheet.dart` | 바텀시트 |
| `DSTextField` | `lib/core/design_system/components/ds_text_field.dart` | 입력 필드 |
| `DSLoading` | `lib/core/design_system/components/ds_loading.dart` | 로딩 인디케이터 |
| `DSModal` | `lib/core/design_system/components/ds_modal.dart` | 확인/경고 모달 |
| `DSToggle` | `lib/core/design_system/components/ds_toggle.dart` | 토글 |
| `DSListTile` | `lib/core/design_system/components/ds_list_tile.dart` | 리스트 row |
| `DSSectionHeader` | `lib/core/design_system/components/ds_section_header.dart` | 섹션 제목 |

## 2. Paper Runtime

경로: `lib/core/widgets/`

| 컴포넌트 | 파일 | 역할 |
|----------|------|------|
| `PaperRuntimeBackground` | `lib/core/widgets/paper_runtime_chrome.dart` | 배경 wrapper |
| `PaperRuntimePanel` | `lib/core/widgets/paper_runtime_chrome.dart` | 기본 panel/card |
| `PaperRuntimeExpandablePanel` | `lib/core/widgets/paper_runtime_chrome.dart` | 확장형 panel |
| `PaperRuntimePill` | `lib/core/widgets/paper_runtime_chrome.dart` | eyebrow / pill |
| `PaperRuntimeAppBar` | `lib/core/widgets/paper_runtime_surface_kit.dart` | 상단 app bar |
| `PaperRuntimeMenuTile` | `lib/core/widgets/paper_runtime_surface_kit.dart` | 설정/메뉴 row |
| `PaperRuntimeToggleTile` | `lib/core/widgets/paper_runtime_surface_kit.dart` | 토글 row |
| `PaperRuntimeButton` | `lib/core/widgets/paper_runtime_surface_kit.dart` | page-level action button |

이 계층은 profile, premium, notification, policy 같은 page shell에서 우선 사용합니다.

## 3. Shared Result Shells

경로: `lib/shared/components/cards/fortune_cards.dart`

| 컴포넌트 | 역할 |
|----------|------|
| `FortuneCardSurface` | 결과 카드의 기본 surface |
| `FortuneCardBadge` | 상태/메타 badge |
| `FortuneMetricPill` | 메트릭 pill |
| `FortuneFeatureCard` | 기능/하이라이트 카드 |
| `FortuneRecordCard` | 기록/히스토리 카드 |
| `FortuneSectionCard` | 그룹형 section card |
| `FortuneResultFrame` | 최상위 결과 frame |

이 계층은 결과 화면 공통 shell로 보고, 상세 의미 구조는 다음 단계의 result body에서 조립합니다.

## 4. Chat Result Widgets

경로: `lib/features/chat/presentation/widgets/`

| 위젯 | 파일 | 역할 |
|------|------|------|
| `ChatSajuResultCard` | `lib/features/chat/presentation/widgets/chat_saju_result_card.dart` | 채팅 surface 안의 사주 결과 카드 |
| `ProfileBottomSheet` | `lib/features/chat/presentation/widgets/profile_bottom_sheet.dart` | 채팅/캐릭터 context 프로필 바텀시트 |

## 5. Result Body Widgets

경로: `lib/features/character/presentation/widgets/fortune_bodies/`

이 계층이 현재 결과 화면 조립의 핵심입니다. shared shell 위에 결과별 전용 section과 시각 구성을 올립니다.

| 파일 | 역할 |
|------|------|
| `lib/features/character/presentation/widgets/fortune_bodies/_fortune_body_shared.dart` | 공통 helper/section 조립 유틸 |
| `lib/features/character/presentation/widgets/fortune_bodies/_fortune_visual_components.dart` | 결과 시각 요소 공통 컴포넌트 |
| `lib/features/character/presentation/widgets/fortune_bodies/calendar_fortune_body.dart` | 달력/일상 계열 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/career_fortune_body.dart` | 직업/커리어 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/coaching_fortune_body.dart` | 코칭/실행 계획 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/family_fortune_body.dart` | 가족 관계/변화/건강/재물 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart` | 건강 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/interactive_fortune_body.dart` | 인터랙티브/실행형 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/mystical_fortune_body.dart` | 신비/전생/드림 계열 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/personality_fortune_body.dart` | 성격/성향/DNA 계열 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/profile_fortune_body.dart` | 프로필형 요약 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/relationship_fortune_body.dart` | 연애/궁합/인연 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/tarot_fortune_body.dart` | 타로 결과 |
| `lib/features/character/presentation/widgets/fortune_bodies/wealth_fortune_body.dart` | 재물/투자 결과 |

문서와 디자인 작업에서 “현재 결과 화면층”이라고 말할 때는 이 디렉터리를 우선 참조합니다.

## 6. Survey Inputs

경로: `lib/features/chat/presentation/widgets/survey/`

| 위젯 | 파일 | 역할 |
|------|------|------|
| `ChatBirthDatetimePicker` | `lib/features/chat/presentation/widgets/survey/chat_birth_datetime_picker.dart` | 생년월일/생시 입력 |
| `ChatSurveyChips` | `lib/features/chat/presentation/widgets/survey/chat_survey_chips.dart` | 단일 선택 chips |
| `ChatSurveyMultiSelectChips` | `lib/features/chat/presentation/widgets/survey/chat_survey_chips.dart` | 다중 선택 chips |
| `ChatSurveySlider` | `lib/features/chat/presentation/widgets/survey/chat_survey_slider.dart` | 수치 slider |
| `ChatImageInput` | `lib/features/chat/presentation/widgets/survey/chat_image_input.dart` | 이미지 업로드 |
| `ChatTarotDeckPicker` | `lib/features/chat/presentation/widgets/survey/chat_tarot_deck_picker.dart` | 타로 덱 선택 |
| `ChatTarotDrawWidget` | `lib/features/chat/presentation/widgets/survey/chat_tarot_draw_widget.dart` | 카드 뽑기 인터랙션 |
| `ChatFaceReadingFlow` | `lib/features/chat/presentation/widgets/survey/chat_face_reading_flow.dart` | 관상 설문 플로우 |
| `ChatMatchSelector` | `lib/features/chat/presentation/widgets/survey/chat_match_selector.dart` | 관계/매치 선택 |
| `ChatInlineCalendar` | `lib/features/chat/presentation/widgets/survey/chat_inline_calendar.dart` | 인라인 달력 |
| `OotdPhotoInput` | `lib/features/chat/presentation/widgets/survey/ootd_photo_input.dart` | OOTD 사진 입력 |

## 7. Traditional And Hanji

| 컴포넌트 | 파일 | 역할 |
|----------|------|------|
| `HanjiBackground` | `lib/core/design_system/components/hanji_background.dart` | 한지 질감 배경 wrapper |
| `CloudBubble` | `lib/core/design_system/components/traditional/cloud_bubble.dart` | 전통풍 bubble |
| `CloudBubblePainter` | `lib/core/design_system/components/traditional/cloud_bubble_painter.dart` | bubble painter |
| `TraditionalKnotIndicator` | `lib/core/design_system/components/traditional/traditional_knot_indicator.dart` | 매듭 장식 |

## Preferred Usage Guide

| 상황 | 우선 계층 |
|------|-----------|
| 일반 앱 화면 | `DS*` primitives |
| profile/premium/settings 같은 page shell | `PaperRuntime*` |
| 결과 카드 공용 외곽 | `Fortune*` shared shells |
| 결과 타입별 본문 구성 | `fortune_bodies/` |
| 전통/장식 연출 | `HanjiBackground`, `traditional/*` |

## Legacy / Compatibility 메모

- 결과 UI를 설명할 때 `DS*`만으로 현재 화면을 설명하면 불충분합니다. 현재 product surface는 `PaperRuntime*` + `Fortune*` + `fortune_bodies/` 조합입니다.
- `HanjiBackground`는 `traditional/` 폴더 내부가 아니라 `components/` 루트에 있습니다.
- Paper runtime file mapping은 `chrome`과 `surface_kit`로 나뉘므로, app bar와 panel 위치를 혼동하지 않도록 주의합니다.

## 관련 문서

- [03-ui-design-system.md](03-ui-design-system.md)
- [24-page-layout-reference.md](24-page-layout-reference.md)
