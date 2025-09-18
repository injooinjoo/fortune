# 유명인 DB 마이그레이션 가이드 (Celebrity Database Migration Guide)

## 개요

이 문서는 기존 celebrities 테이블에서 새로운 스키마로 마이그레이션하는 전체 과정을 설명합니다.

## 마이그레이션 단계별 가이드

### 1단계: 기존 데이터 백업 (20250119000001)

**목적**: 마이그레이션 실패 시 복구를 위한 안전장치

```sql
-- 실행 파일: 20250119000001_backup_existing_celebrities.sql

-- 기존 데이터 백업
CREATE TABLE IF NOT EXISTS public.celebrities_backup AS
SELECT * FROM public.celebrities;

-- 백업 확인
SELECT COUNT(*) FROM public.celebrities_backup;
```

**검증 방법**:
- 백업 테이블 레코드 수가 원본과 일치하는지 확인
- `migration_log` 테이블에 성공 로그 기록 확인

### 2단계: 새 스키마 생성 (20250119000002)

**목적**: 새로운 테이블 구조 및 제약조건 생성

```sql
-- 실행 파일: 20250119000002_create_new_celebrity_schema.sql

-- 기존 테이블 삭제
DROP TABLE IF EXISTS public.celebrities CASCADE;

-- 새 테이블 생성
CREATE TABLE public.celebrities (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    celebrity_type TEXT NOT NULL CHECK (celebrity_type IN (
        'pro_gamer', 'streamer', 'politician', 'business',
        'solo_singer', 'idol_member', 'actor', 'athlete'
    )),
    -- ... 기타 필드들
);
```

**주요 변경사항**:
- `category` → `celebrity_type`: enum 값 변경 및 세분화
- `additional_info` → `profession_data`: 구조화된 JSON 스키마
- `popularity_score`, `is_active` 필드 제거
- `external_ids` JSONB 필드 추가
- 새로운 인덱스 및 검색 함수 추가

### 3단계: 데이터 변환 마이그레이션 (20250119000003)

**목적**: 기존 데이터를 새 스키마 형식으로 변환

```sql
-- 실행 파일: 20250119000003_migrate_existing_data.sql

-- 카테고리 매핑 함수
CREATE OR REPLACE FUNCTION determine_celebrity_type(category TEXT, name TEXT)
RETURNS TEXT AS $$
BEGIN
    IF category = 'singer' THEN
        -- 그룹/솔로 구분
        IF name IN ('BTS', '블랙핑크', '트와이스', ...) THEN
            RETURN 'idol_member';
        ELSE
            RETURN 'solo_singer';
        END IF;
    ELSIF category = 'politician' THEN
        RETURN 'politician';
    -- ... 기타 매핑 규칙
    END IF;
END;
$$;

-- 데이터 변환 삽입
INSERT INTO public.celebrities (
    id, name, birth_date, gender, celebrity_type,
    -- ... 기타 필드들
)
SELECT
    b.id,
    b.name,
    b.birth_date::DATE,
    CASE WHEN b.gender = 'mixed' THEN 'other' ELSE b.gender END,
    determine_celebrity_type(b.category, b.name),
    -- ... 기타 변환 로직
FROM public.celebrities_backup b;
```

**데이터 변환 규칙**:

| 기존 필드 | 새 필드 | 변환 규칙 |
|-----------|---------|-----------|
| `category` | `celebrity_type` | singer → solo_singer/idol_member 구분 |
| `gender = 'mixed'` | `gender = 'other'` | 값 매핑 변경 |
| `additional_info` | `profession_data` | JSON 구조 표준화 |
| `full_saju_data` | `notes` | 레거시 데이터를 비고에 보관 |
| `nationality = NULL` | `nationality = '한국'` | 기본값 설정 |

### 4단계: 인덱스 및 함수 생성 (20250119000004)

**목적**: 성능 최적화 및 편의 기능 추가

```sql
-- 실행 파일: 20250119000004_create_indexes_and_functions.sql

-- 성능 최적화 인덱스
CREATE INDEX idx_celebrities_type_birth_date ON public.celebrities(celebrity_type, birth_date);
CREATE INDEX idx_celebrities_search ON public.celebrities USING GIN(...);

-- 직업별 특화 검색 함수
CREATE OR REPLACE FUNCTION get_pro_gamers_by_game(game_title TEXT, limit_count INTEGER DEFAULT 50);
CREATE OR REPLACE FUNCTION get_streamers_by_platform(platform TEXT, limit_count INTEGER DEFAULT 50);
-- ... 기타 편의 함수들

-- 통계 뷰
CREATE OR REPLACE VIEW celebrity_analytics AS ...;
```

### 5단계: 기존 테이블 정리 (20250119000005)

**목적**: 불필요한 테이블 및 함수 정리, 제약조건 추가

```sql
-- 실행 파일: 20250119000005_cleanup_old_tables.sql

-- 더 이상 사용하지 않는 테이블 삭제
DROP TABLE IF EXISTS public.celebrity_master_list CASCADE;
DROP TABLE IF EXISTS public.celebrity_saju CASCADE;

-- 기존 호환되지 않는 함수 삭제
DROP FUNCTION IF EXISTS public.get_celebrities_by_category(TEXT);
DROP FUNCTION IF EXISTS public.get_popular_celebrities(INTEGER);

-- 데이터 무결성 제약조건 추가
ALTER TABLE public.celebrities
ADD CONSTRAINT check_non_empty_name CHECK (length(trim(name)) > 0);

-- 정책 업데이트
CREATE POLICY "Service role can delete celebrities" ON public.celebrities
    FOR DELETE USING (auth.jwt() ->> 'role' = 'service_role');
```

## 마이그레이션 실행 방법

### Supabase CLI 사용

```bash
# 1. 로컬에서 마이그레이션 확인
supabase db reset

# 2. 실제 DB에 적용
supabase db push

# 3. 마이그레이션 상태 확인
supabase migration list
```

### 수동 실행 (운영 환경)

```bash
# 1. 백업
psql "postgresql://..." -f supabase/migrations/20250119000001_backup_existing_celebrities.sql

# 2. 새 스키마
psql "postgresql://..." -f supabase/migrations/20250119000002_create_new_celebrity_schema.sql

# 3. 데이터 마이그레이션
psql "postgresql://..." -f supabase/migrations/20250119000003_migrate_existing_data.sql

# 4. 인덱스 및 함수
psql "postgresql://..." -f supabase/migrations/20250119000004_create_indexes_and_functions.sql

# 5. 정리
psql "postgresql://..." -f supabase/migrations/20250119000005_cleanup_old_tables.sql
```

## 검증 및 테스트

### 1. 데이터 무결성 검증

```sql
-- 마이그레이션 전후 레코드 수 비교
SELECT 'backup' as source, COUNT(*) FROM celebrities_backup
UNION ALL
SELECT 'new' as source, COUNT(*) FROM celebrities;

-- 필수 필드 NULL 체크
SELECT COUNT(*) as null_names FROM celebrities WHERE name IS NULL OR name = '';
SELECT COUNT(*) as null_birth_dates FROM celebrities WHERE birth_date IS NULL;
SELECT COUNT(*) as invalid_types FROM celebrities WHERE celebrity_type NOT IN (
    'pro_gamer', 'streamer', 'politician', 'business',
    'solo_singer', 'idol_member', 'actor', 'athlete'
);

-- 외래키 무결성 (해당하는 경우)
SELECT COUNT(*) as orphaned_records FROM celebrities c
LEFT JOIN other_table o ON c.id = o.celebrity_id
WHERE o.celebrity_id IS NULL;
```

### 2. 기능 테스트

```sql
-- 검색 함수 테스트
SELECT COUNT(*) FROM search_celebrities('아이유');
SELECT COUNT(*) FROM get_celebrities_by_type('solo_singer');
SELECT COUNT(*) FROM get_pro_gamers_by_game('League of Legends');

-- 인덱스 성능 테스트
EXPLAIN ANALYZE SELECT * FROM celebrities WHERE celebrity_type = 'actor' AND birth_date > '1990-01-01';

-- JSON 필드 검색 테스트
SELECT COUNT(*) FROM celebrities WHERE profession_data->>'game_title' = 'League of Legends';
```

### 3. Flutter 앱 연동 테스트

```dart
// 1. 기본 조회 테스트
final celebrities = await celebrityService.getAllCelebrities();
print('Total celebrities: ${celebrities.length}');

// 2. 타입별 조회 테스트
final actors = await celebrityService.getCelebritiesByType(CelebrityType.actor);
print('Total actors: ${actors.length}');

// 3. 검색 테스트
final searchResults = await celebrityService.searchCelebrities('김');
print('Search results: ${searchResults.length}');

// 4. JSON 직렬화 테스트
final celebrity = celebrities.first;
final json = celebrity.toJson();
final restored = Celebrity.fromJson(json);
assert(celebrity.id == restored.id);
```

## 롤백 계획

### 긴급 롤백 (마이그레이션 실패 시)

```sql
-- 1. 새 테이블 삭제
DROP TABLE IF EXISTS public.celebrities CASCADE;

-- 2. 백업에서 복원
CREATE TABLE public.celebrities AS SELECT * FROM celebrities_backup;

-- 3. 기존 인덱스 재생성
CREATE INDEX idx_celebrities_category ON public.celebrities(category);
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
-- ... 기존 인덱스들

-- 4. 기존 함수 복원
CREATE OR REPLACE FUNCTION get_celebrities_by_category(category_name TEXT) ...;
```

### 점진적 롤백 (운영 중 문제 발견 시)

1. **읽기 전용 모드**: 새 스키마 읽기만 허용, 쓰기는 기존 스키마 사용
2. **데이터 동기화**: 기존 스키마와 새 스키마 간 실시간 동기화
3. **단계적 전환**: 기능별로 점진적으로 새 스키마로 전환
4. **완전 롤백**: 모든 기능을 기존 스키마로 되돌림

## 성능 영향 분석

### 예상 성능 변화

| 작업 | 기존 성능 | 새 스키마 성능 | 개선도 |
|------|----------|----------------|--------|
| 이름 검색 | 100ms | 50ms | +100% |
| 카테고리별 조회 | 80ms | 30ms | +167% |
| 복합 검색 | 200ms | 120ms | +67% |
| JSON 필드 검색 | N/A | 150ms | 신규 |

### 최적화 권장사항

1. **인덱스 모니터링**: 쿼리 패턴에 따른 인덱스 추가 최적화
2. **JSON 필드 최적화**: 자주 검색되는 JSON 키에 대한 부분 인덱스 생성
3. **파티셔닝**: 데이터 증가 시 celebrity_type별 파티셔닝 고려
4. **캐싱**: 자주 조회되는 데이터에 대한 Redis 캐싱 적용

## 문제 해결 가이드

### 자주 발생하는 문제

#### 1. 문자 인코딩 문제
```sql
-- 증상: 한글 이름이 깨져서 표시됨
-- 해결: 데이터베이스 인코딩 확인 및 수정
SHOW client_encoding;
SET client_encoding = 'UTF8';
```

#### 2. JSON 필드 파싱 오류
```sql
-- 증상: profession_data 필드에서 파싱 오류
-- 해결: JSON 유효성 검사 및 수정
SELECT id, name FROM celebrities WHERE NOT (profession_data::text)::json IS NOT NULL;
UPDATE celebrities SET profession_data = '{}' WHERE profession_data IS NULL OR profession_data::text = '';
```

#### 3. 외래키 참조 오류
```sql
-- 증상: 다른 테이블에서 celebrity_id 참조 오류
-- 해결: 참조하는 테이블의 ID 업데이트
UPDATE other_table SET celebrity_id = new_mapping.new_id
FROM id_mapping new_mapping
WHERE other_table.celebrity_id = new_mapping.old_id;
```

### 성능 문제 진단

```sql
-- 1. 느린 쿼리 식별
SELECT query, mean_time, calls
FROM pg_stat_statements
WHERE query LIKE '%celebrities%'
ORDER BY mean_time DESC;

-- 2. 인덱스 사용률 확인
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename = 'celebrities';

-- 3. 테이블 통계 업데이트
ANALYZE celebrities;
```

## 후속 작업

### 1. 모니터링 설정
- 쿼리 성능 모니터링 대시보드 구성
- 데이터 증가율 추적
- 오류율 모니터링

### 2. 문서화 업데이트
- API 문서 업데이트
- Flutter 앱 개발 가이드 업데이트
- 운영 매뉴얼 업데이트

### 3. 개발팀 교육
- 새로운 스키마 구조 교육
- 새로운 검색 함수 사용법 교육
- 트러블슈팅 가이드 공유

## 연락처 및 지원

- **DB 관리자**: [담당자 연락처]
- **백엔드 개발팀**: [담당자 연락처]
- **긴급 상황**: [24시간 지원 연락처]

---

**주의사항**: 운영 환경에서 마이그레이션 실행 전 반드시 스테이징 환경에서 전체 과정을 테스트하고, 충분한 백업을 준비한 후 진행하시기 바랍니다.