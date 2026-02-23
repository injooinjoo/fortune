# Verify Report - Fortune Type Unification

## 1. Change Summary
- What changed:
  - 코어 운세 타입을 `kebab-case` canonical id로 정규화했다.
  - Character/Chat/Edge/DB 마이그레이션/로컬 마이그레이션/l10n/문서를 같은 기준으로 정리했다.
  - `fortune-mbti` 내부 전역 차원 타입도 `mbti-dimensions`로 정규화했다.
- Why changed:
  - `daily` 외에 코어 전체 운세 타입 표기가 혼재되어 기능/캐시/통계/문서 정합성 이슈가 있었기 때문이다.
- Affected area:
  - Flutter: core registry + character/chat flow + constants + local migration + l10n
  - Supabase Edge: recommend/time/new-year/ex-lover/yearly-encounter/game-enhance/baby-nickname/mbti/_shared
  - DB: core fortune type id normalization migration
  - Docs: canonical mapping + edge/data-flow convention 문서

## 2. Static Validation
- `flutter analyze`
  - Result: `info` lint 13건으로 기본 실행은 exit code 1
  - Notes:
    - `lib/features/chat/presentation/pages/chat_home_page.dart`의 `use_build_context_synchronously` info 13건
    - 에러/워닝은 없음
- `flutter analyze --no-fatal-infos`
  - Result: 성공 (exit code 0)
  - Notes: 동일 `info` 13건만 존재
- `dart format --set-exit-if-changed .`
  - Result: 성공 (최종 0 changed)
  - Notes:
    - 최초 실행 시 3개 파일 자동 정렬 후 재실행으로 clean 확인
- `dart run build_runner build --delete-conflicting-outputs` (if applicable)
  - Result: 미실행
  - Notes: freezed 모델 구조 변경/생성 파일 영향 작업이 아니어서 N/A

## 3. Tests and QA
- Unit/Widget/Integration tests run:
  - Command: `flutter test`
  - Result: 성공 (`All tests passed!`)
- Playwright QA (if applicable):
  - Command: 미실행
  - Result: 이번 작업은 타입/엔드포인트/문서 중심 변경으로 비적용

## 4. Files Changed
1. `lib/core/fortune/fortune_type_registry.dart` - canonical registry 추가/단일화
2. `lib/features/chat/domain/models/fortune_survey_config.dart` - enum canonical id 확장 및 역매핑
3. `lib/features/character/data/fortune_characters.dart` - 캐릭터 specialty canonical id 적용
4. `lib/features/character/presentation/pages/character_chat_panel.dart` - 레지스트리 기반 라벨/설문 매핑
5. `lib/features/character/presentation/providers/character_chat_provider.dart` - 분산 매핑 제거/레지스트리 기반 정리
6. `lib/features/chat/presentation/pages/chat_home_page.dart` - chip/survey 문자열 매핑 canonical 단일화
7. `lib/features/chat/domain/models/recommendation_chip.dart` - chip id/fortuneType canonical 정리
8. `lib/features/chat/domain/models/ai_recommendation.dart` - 추천 파싱 canonical 기준화
9. `lib/features/chat/domain/constants/chip_category_map.dart` - canonical 키 정리
10. `lib/features/chat/domain/constants/life_category_fortune_map.dart` - canonical 키 정리
11. `lib/features/chat/data/services/fortune_recommend_service.dart` - 추천 타입 canonical 처리
12. `lib/core/constants/edge_functions_endpoints.dart` - canonical endpoint 매핑 정리
13. `lib/core/constants/loading_messages.dart` - canonical 타입 키 정리
14. `lib/core/constants/soul_rates.dart` - alias 제거/canonical 정리
15. `lib/core/constants/fortune_type_names.dart` - canonical 타입명/라우트 정리
16. `lib/features/fortune/domain/models/yearly_encounter_result.dart` - `fortuneType` canonical 고정
17. `supabase/functions/fortune-recommend/index.ts` - canonical-only 반환/필터링
18. `supabase/functions/fortune-time/index.ts` - `daily-calendar` 반환 정규화
19. `supabase/functions/fortune-new-year/index.ts` - `new-year` 정규화
20. `supabase/functions/fortune-ex-lover/index.ts` - `ex-lover` 정규화
21. `supabase/functions/fortune-yearly-encounter/index.ts` - `yearly-encounter` 정규화
22. `supabase/functions/fortune-game-enhance/index.ts` - `game-enhance` 정규화
23. `supabase/functions/fortune-baby-nickname/index.ts` - `baby-nickname` 정규화
24. `supabase/functions/fortune-mbti/index.ts` - `mbti-dimensions` 정규화
25. `supabase/functions/_shared/types.ts` - 코어 alias 제거
26. `supabase/functions/_shared/cohort/index.ts` - 코어 alias 분기 제거
27. `supabase/migrations/20260223000001_normalize_core_fortune_type_ids.sql` - DB canonical 일괄 정규화
28. `lib/core/services/fortune_type_local_migration_service.dart` - 로컬 1회 canonical 변환
29. `lib/main.dart` - deferred init에서 로컬 마이그레이션 호출
30. `lib/l10n/app_ko.arb` - `fortuneDaily` 인사이트 톤 반영
31. `lib/l10n/app_en.arb` - `fortuneDaily` 인사이트 톤 반영
32. `lib/l10n/app_ja.arb` - `fortuneDaily` 인사이트 톤 반영
33. `lib/l10n/app_localizations.dart` - l10n 재생성 반영
34. `lib/l10n/app_localizations_en.dart` - l10n 재생성 반영
35. `lib/l10n/app_localizations_ko.dart` - l10n 재생성 반영
36. `lib/l10n/app_localizations_ja.dart` - l10n 재생성 반영
37. `.claude/docs/fortune-data-flow.md` - canonical 데이터 플로우 규칙 문서화
38. `.claude/docs/09-edge-function-conventions.md` - canonical edge 규칙 문서화
39. `docs/development/FORTUNE_TYPE_CANONICAL_MAPPING.md` - 기준표 추가

## 5. Risks and Follow-ups
- Known risks:
  - `flutter analyze` 기본 설정에서는 `info` lint도 실패(exit 1) 처리된다.
  - 워크스페이스에 본 작업과 무관한 기존 변경사항이 매우 많아, 커밋 시 파일 선별이 중요하다.
- Deferred items:
  - `use_build_context_synchronously` info 13건은 본 작업 범위를 벗어나 보류.

## 6. User Manual Test Request
- Scenario:
  1. 캐릭터 칩에서 `new-year`, `ex-lover`, `yearly-encounter`, `game-enhance`를 각각 실행한다.
  2. family 설문에서 concern(`health/wealth/children/relationship/change`)을 각각 선택한다.
  3. 추천 칩/히스토리/결과 카드에서 저장·표시되는 `fortuneType`을 확인한다.
  4. 앱 재시작 후 deep link/pending cache가 legacy type일 때 canonical로 변환되는지 확인한다.
- Expected result:
  - API 호출/응답/캐시/DB/UI 표기가 canonical id로 일치한다.
- Failure signal:
  - `daily_calendar`, `new_year`, `yearlyEncounter`, `gameEnhance`, `ex_lover` 등 legacy id가 다시 노출된다.

## 7. Completion Gate
- 검증 명령은 완료되었고, 남은 게이트는 Git 커밋/푸시 + Actions 확인 + Jira Done 전환이다.
