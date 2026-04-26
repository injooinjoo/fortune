# Archived Migrations

이 디렉토리에 들어있는 SQL은 **production에 적용되지 않은 보류 마이그레이션**.

## 왜 archive 되었나

2026-04-26 deploy 사이클 점검 중 다음을 발견:

1. `supabase db push --dry-run` 결과 13개 마이그레이션이 production 미적용 상태로 보류 중.
2. 첫 번째 마이그레이션부터 production schema와 분기되어 (`user_notification_preferences` 테이블이 production에 없음) `db push --include-all`이 fail.
3. 즉 production은 이 마이그레이션들이 가정한 schema 진화 경로와 다른 경로로 운영되어 옴.
4. 한편 production이 정상 동작하는 데 필요한 schema는 모두 별도 경로(직접 SQL/다른 마이그레이션)로 적용되어 있음.

따라서 이 13개를 그대로 두면 git/production 분기 상태가 영구화되고 다음 PR에서도 `db push`가 또 fail.

## 결정

- **production은 정상 동작하므로** 코드 의존 schema(fcm_tokens, runtime_state, user_proactive_preferences 등)는 별도 hotfix 마이그레이션으로 이미 적용 완료.
- **이 13개는 dormant** — 코드가 의존하지 않거나, 다른 경로로 이미 적용되었거나, 이미 의도가 다른 곳으로 이전됨.
- 향후 schema baseline을 새로 snapshot할 때 참고 가능하도록 archive로 보관 (삭제하지 않음).

## 주의사항

- 이 디렉토리의 SQL을 다시 적용하려면 production schema와의 호환성을 한 파일씩 검증 후 진행.
- `supabase db push`는 `migrations/` 직속 SQL만 처리. `_archived/` 안의 파일은 자동으로 무시.
- 추후 baseline snapshot 작업 시 이 SQL들의 의도를 묶은 idempotent 통합 마이그레이션으로 대체 검토.

## 목록

```
20260214000001_add_character_dm_notification_preference.sql  -- character_dm 컬럼: 별도 hotfix로 적용
20260215000001_create_user_character_memory.sql              -- user_character_memory 테이블: 코드 의존 시점에 별도 적용 필요
20260217000001_create_character_proactive_images_bucket.sql  -- storage bucket: generate-character-proactive-image 함수 사용 시 적용 필요
20260217000002_upsert_character_chat_model_config.sql        -- llm_model_config seed
20260223000001_normalize_core_fortune_type_ids.sql           -- legacy fortune_type id 정규화 (one-shot data migration)
20260227000001_guard_llm_model_config_cost.sql               -- llm_model_config 비용 가드
20260310000001_repair_llm_guard_schema.sql                   -- llm_model_config schema repair
20260311000001_remove_celebrity_crawling_metadata.sql        -- celebrities 컬럼 정리 (DROP 포함, destructive)
20260324000001_create_talisman_catalog_assets.sql            -- talisman_catalog_assets 테이블
20260407000002_character_conversations_runtime_state.sql     -- runtime_state 컬럼: 20260426000003_runtime_state_hotfix.sql 로 별도 적용 완료
20260418000001_enable_rls_migration_log.sql                  -- migration_log RLS 강화
20260422000001_create_missing_image_buckets.sql              -- 누락 image bucket 생성
20260423000003_harden_rls_policies.sql                       -- 추가 RLS 강화
```
