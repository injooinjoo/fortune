# Discovery Report - Core Fortune Type Naming Unification (KAN-26)

## 1. Goal
- Requested change:
  - Character + Chat + Edge + Docs 전반에서 운세 타입명을 kebab-case canonical로 통일
  - 분산 문자열 매핑 제거 후 단일 타입 레지스트리 도입
  - DB/로컬 캐시/Edge fortuneType 값 정규화
- Work type: Provider / Service / Model / Constants / Edge Function / Docs / Migration
- Scope:
  - 앱 코어 타입 매핑, Character/Chat 라우팅, Edge fortuneType 표준화, SQL/로컬 마이그레이션, 문서/l10n 정리

## 2. Search Strategy
- Keywords:
  - `daily_calendar`, `newYear`, `exLover`, `yearlyEncounter`, `gameEnhance`, `fortuneCookie`, `babyNickname`, `mbti_dimensions`, `new_year`, `ex_lover`
- Commands:
  - `rg "fortuneType\\s*[:=]\\s*'[^']+'" lib/ supabase/functions/`
  - `rg "daily_calendar|newYear|exLover|yearlyEncounter|gameEnhance|fortuneCookie|new_year|ex_lover" lib/ supabase/functions/ .claude/docs/ docs/`
  - `rg "_mapChipToSurveyType|_mapSurveyTypeToString|_mapToApiFortuneType|getEndpointForType" lib/`
  - `rg --files supabase/functions | rg "fortune-"`

## 3. Similar Code Findings
- Reusable:
  1. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/models/fortune_survey_config.dart` - 설문 enum 단일 source
  2. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/constants/edge_functions_endpoints.dart` - 타입→엔드포인트 중앙 진입점
  3. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/providers/character_chat_provider.dart` - 캐릭터 fortune 라우팅 통합 지점
  4. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/presentation/pages/chat_home_page.dart` - 칩→설문→API 실행 메인 흐름
- Reference only:
  1. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/services/sync_queue_local_service.dart` - SharedPreferences one-time migration 플래그 패턴
  2. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/_shared/cohort/index.ts` - cohort key 정규화 관문
  3. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/_shared/types.ts` - token cost 타입 키 표준

## 4. Reuse Decision
- Reuse as-is:
  - 기존 Survey enum 구조 및 Edge 함수 디렉토리 구조
  - UnifiedFortuneService / GeneratorFactory 호출 체인
- Extend existing code:
  - Survey enum에 canonical id extension 추가
  - Edge endpoint 상수와 로딩/토큰/이름 상수 canonical 보강
- New code required:
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/core/fortune/fortune_type_registry.dart`
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/core/services/fortune_type_local_migration_service.dart`
  - `/Users/jacobmac/Desktop/Dev/fortune/supabase/migrations/20260223000001_normalize_core_fortune_type_ids.sql`
- Duplicate prevention notes:
  - 분산 switch/map를 삭제 또는 레지스트리 위임하여 신규 alias 재유입 방지

## 5. Planned Changes
- Files to edit:
  1. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/data/fortune_characters.dart`
  2. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/pages/character_chat_panel.dart`
  3. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/providers/character_chat_provider.dart`
  4. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/presentation/pages/chat_home_page.dart`
  5. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/models/recommendation_chip.dart`
  6. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/models/ai_recommendation.dart`
  7. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/constants/chip_category_map.dart`
  8. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/constants/life_category_fortune_map.dart`
  9. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/data/services/fortune_recommend_service.dart`
  10. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/constants/edge_functions_endpoints.dart`
  11. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/constants/loading_messages.dart`
  12. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/constants/soul_rates.dart`
  13. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/constants/fortune_type_names.dart`
  14. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/domain/models/yearly_encounter_result.dart`
  15. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-time/index.ts`
  16. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-new-year/index.ts`
  17. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-ex-lover/index.ts`
  18. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-yearly-encounter/index.ts`
  19. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-game-enhance/index.ts`
  20. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-baby-nickname/index.ts`
  21. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-mbti/index.ts`
  22. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-recommend/index.ts`
  23. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/_shared/types.ts`
  24. `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/_shared/cohort/index.ts`
  25. `/Users/jacobmac/Desktop/Dev/fortune/lib/main.dart`
  26. `/Users/jacobmac/Desktop/Dev/fortune/lib/l10n/app_ko.arb`
  27. `/Users/jacobmac/Desktop/Dev/fortune/lib/l10n/app_en.arb`
  28. `/Users/jacobmac/Desktop/Dev/fortune/lib/l10n/app_ja.arb`
  29. `/Users/jacobmac/Desktop/Dev/fortune/.claude/docs/fortune-data-flow.md`
  30. `/Users/jacobmac/Desktop/Dev/fortune/.claude/docs/09-edge-function-conventions.md`
- Files to create:
  1. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/fortune/fortune_type_registry.dart`
  2. `/Users/jacobmac/Desktop/Dev/fortune/lib/core/services/fortune_type_local_migration_service.dart`
  3. `/Users/jacobmac/Desktop/Dev/fortune/supabase/migrations/20260223000001_normalize_core_fortune_type_ids.sql`
  4. `/Users/jacobmac/Desktop/Dev/fortune/docs/development/FORTUNE_TYPE_CANONICAL_MAPPING.md`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
- Runtime checks:
  - 캐릭터 칩 탭 시 canonical type으로 API 호출
  - chat chip/deeplink/local cache에서 canonical type 유지
- Test cases:
  - enum canonical extension 매핑 테스트
  - family concern -> family-{subtype} 분기 테스트
  - migration SQL key remap 시 old key 제거/합산 검증
