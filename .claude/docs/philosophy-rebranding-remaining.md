# 철학 리브랜딩 Phase 2 - 남은 작업 목록

## 개요
- **목표**: "운세" → "인사이트"로 용어 통일
- **철학**: 예측/점술 중심 → 자기 발견/분석 중심
- **Phase 1 완료**: 36개 파일 (2024-12-30)
- **Phase 2 남은 작업**: ~300개 파일

---

## 완료된 작업 (Phase 1)

### Flutter (14개 파일) ✅
- `survey_configs.dart` - 설문 타이틀
- `chat_home_page.dart` - 채팅 UI
- `fortune_type_chips.dart` - 운세 칩
- `chat_welcome_view.dart` - 환영 메시지
- `premium_screen.dart` - 프리미엄 화면
- `fortune_history_chart.dart` - 히스토리 차트
- `multi_photo_selector.dart` - 사진 선택
- `talisman_share_service.dart` - SNS 공유
- `landing_main_content.dart` - 랜딩 슬로건
- `fortune_loading_screen.dart` - 로딩 화면
- `about_page.dart` - 앱 소개
- `preview_screen.dart` - 미리보기
- `recommendation_chip.dart` - 추천 칩
- `cache_settings_widget.dart`, `profile_completion_dialog.dart`

### Edge Functions (22개 파일) ✅
- `fortune-recommend` - METADATA + 시스템 프롬프트
- `fortune-daily`, `fortune-time`
- `fortune-career`, `fortune-love`
- `fortune-compatibility`, `fortune-moving`
- `fortune-blind-date`, `fortune-ex-lover`
- `fortune-mbti`, `fortune-avoid-people`
- `fortune-investment`
- `fortune-family-*` (5개)
- `generate-fortune-story`
- `push-daily-fortune`, `push-winback`
- `_shared/prompts/templates/investment.ts`

---

## 남은 작업 (Phase 2) - 우선순위별

### HIGH Priority - 사용자 직접 노출 UI

#### 위젯 파일 (~50개)
```
lib/features/fortune/presentation/widgets/fortune_result_card.dart
lib/features/fortune/presentation/widgets/fortune_content_card.dart
lib/features/fortune/presentation/widgets/fortune_entry_card.dart
lib/features/fortune/presentation/widgets/fortune_list_card.dart
lib/features/fortune/presentation/widgets/fortune_display.dart
lib/features/fortune/presentation/widgets/tarot/tarot_result_card.dart
lib/features/fortune/presentation/widgets/family_fortune_card.dart
lib/features/fortune/presentation/widgets/pet_fortune_result_card.dart
lib/presentation/widgets/fortune_card.dart
lib/presentation/widgets/fortune_loading_widget.dart
lib/presentation/widgets/time_based_fortune_bottom_sheet.dart
lib/presentation/widgets/fortune_history_summary_widget.dart
lib/presentation/widgets/fortune_explanation_bottom_sheet.dart
lib/presentation/widgets/enhanced_shareable_fortune_card.dart
```

#### 페이지 파일 (~30개)
```
lib/features/fortune/presentation/pages/fortune_list_page.dart
lib/features/fortune/presentation/pages/family_fortune_page.dart
lib/features/fortune/presentation/pages/face_reading_fortune_page.dart
lib/features/fortune/presentation/pages/dream_fortune_voice_page.dart
lib/features/fortune/presentation/pages/moving_fortune_page.dart
lib/features/fortune/presentation/pages/wish_fortune_page.dart
lib/features/fortune/presentation/pages/investment_fortune_page.dart
lib/features/fortune/presentation/pages/biorhythm_input_page.dart
lib/features/interactive/presentation/pages/fortune_cookie_page.dart
lib/features/interactive/presentation/pages/dream_interpretation_page.dart
lib/features/history/presentation/pages/fortune_history_page.dart
lib/features/health/presentation/pages/health_fortune/health_fortune_page.dart
lib/features/sports/presentation/pages/sports_fortune_page.dart
```

### MEDIUM Priority - Edge Functions 시스템 프롬프트

#### 미수정 Edge Functions (~20개)
```
supabase/functions/fortune-talent/index.ts
supabase/functions/fortune-pet-compatibility/index.ts
supabase/functions/fortune-naming/index.ts
supabase/functions/fortune-home-fengshui/index.ts
supabase/functions/fortune-face-reading/index.ts
supabase/functions/fortune-face-reading-watch/index.ts
supabase/functions/fortune-traditional-saju/index.ts
supabase/functions/fortune-lucky-items/index.ts
supabase/functions/fortune-celebrity/index.ts
supabase/functions/fortune-biorhythm/index.ts
supabase/functions/fortune-health/index.ts
supabase/functions/personality-dna/index.ts
supabase/functions/widget-cache/index.ts
supabase/functions/soul-earn/index.ts
supabase/functions/soul-consume/index.ts
supabase/functions/_shared/prompts/presets.ts
supabase/functions/_shared/prompts/templates/face-reading.ts
supabase/functions/_shared/llm/config.ts
supabase/functions/_shared/llm/factory.ts
```

### LOW Priority - 내부 로직/주석

#### 서비스/프로바이더 (~30개)
```
lib/core/services/unified_fortune_service.dart
lib/core/services/personalized_fortune_service.dart
lib/core/services/fortune_generators/*.dart
lib/presentation/providers/fortune_provider.dart
lib/presentation/providers/fortune_badge_provider.dart
lib/features/chat/data/services/fortune_recommend_service.dart
lib/services/fortune_history_service.dart
```

#### 모델/데이터 (~40개)
```
lib/data/models/fortune_response_model.dart
lib/features/fortune/domain/models/fortune_result.dart
lib/features/fortune/domain/models/conditions/*.dart
lib/core/models/fortune_result.dart
lib/domain/entities/fortune.dart
```

#### 상수/설정 (~10개)
```
lib/core/constants/fortune_metadata.dart
lib/core/constants/edge_functions_endpoints.dart
lib/constants/fortune_constants.dart
```

---

## 변경 원칙

### 변경할 패턴
| 기존 | 변경 |
|------|------|
| 운세 | 인사이트 |
| 운세를 보다 | 인사이트를 확인하다 |
| 운세 AI | 인사이트 AI |
| 운세 결과 | 분석 결과 |
| #운세 | #인사이트 |

### 유지할 패턴 (변경하지 않음)
- 전통 기능명: 타로, 사주, 꿈해몽, 관상, 궁합
- 코드 내부 변수명: `fortuneType`, `FortuneService`, `fortune_`
- API 엔드포인트: `/fortune-*`
- 폴더명: `fortune/`, `fortune_`

---

## 실행 명령어

### 현재 상태 확인
```bash
# Flutter 파일에서 "운세" 검색
grep -rn "운세" lib/ --include="*.dart" | wc -l

# Edge Functions에서 "운세" 검색
grep -rn "운세" supabase/functions/ --include="*.ts" | wc -l
```

### 수정 후 검증
```bash
flutter analyze
dart format .
```

---

## 예상 소요 시간
- HIGH Priority: ~2시간
- MEDIUM Priority: ~1시간
- LOW Priority: ~2시간
- **총 예상**: ~5시간

---

## 다음 세션에서 실행할 명령

```
/sc:implement 철학 리브랜딩 Phase 2 - 남은 운세→인사이트 변경 작업 진행
```

문서 위치: `.claude/docs/philosophy-rebranding-remaining.md`
