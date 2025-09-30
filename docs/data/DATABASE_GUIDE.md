# Fortune Flutter App - Comprehensive Database Guide

This guide provides complete documentation for the Fortune Flutter App's Supabase database architecture, including all tables, schemas, RLS policies, indexes, and migration procedures.

**Last Updated**: 2025-09-30

---

## Table of Contents

1. [Database Overview](#database-overview)
2. [Schema Details](#schema-details)
3. [Celebrity Database](#celebrity-database)
4. [API Usage Patterns](#api-usage-patterns)
5. [Migration Guide](#migration-guide)
6. [Security and Performance](#security-and-performance)

---

## Database Overview

### All Tables Summary

#### 1. User-Related Tables

| Table | Purpose | Service/Location | RLS Applied |
|-------|---------|------------------|-------------|
| `user_profiles` | User profile information | `lib/services/phone_auth_service.dart`, `lib/services/social_auth_service.dart` | ✅ User-only access |
| `pets` | Pet profile information | `lib/services/pet_service.dart`, `lib/data/models/pet_profile.dart` | ✅ User-only access |
| `user_statistics` | User activity statistics | `lib/services/user_statistics_service.dart` | ✅ User-only access |

#### 2. Celebrity-Related Tables

| Table | Purpose | Migration Files | RLS Applied |
|-------|---------|----------------|-------------|
| `celebrities` | Celebrity information and saju data | `20250119000002_create_new_celebrity_schema.sql`, `20250828000002_create_accurate_celebrities_table.sql` | Public read, service role write |
| `celebrity_master_list` | Celebrity master management list | `20250826000004_create_celebrity_master_list.sql` | Public read |
| `celebrities_backup` | Backup table for existing celebrity data | - | Public read |

#### 3. Fortune-Related Tables

| Table | Purpose | Service/Location | RLS Applied |
|-------|---------|------------------|-------------|
| `fortune_cache` | Fortune result caching | `lib/services/cache_service.dart`, `create_fortune_cache_tables.sql` | ✅ User-only access |
| `fortune_stories` | Generated fortune stories | `lib/services/cache_service.dart`, `create_fortune_cache_tables.sql` | ✅ User-only access |
| `fortune_history` | User fortune history | `lib/services/fortune_history_service.dart`, `20250829000001_create_fortune_history_table.sql` | ✅ User-only access |

#### 4. Talisman-Related Tables

| Table | Purpose | Service/Location | RLS Applied |
|-------|---------|------------------|-------------|
| `user_talismans` | User talisman inventory | `lib/features/talisman/data/services/talisman_service.dart`, `20250825000001_create_talisman_tables.sql` | ✅ User-only access |
| `talisman_effects` | Talisman effects and influence | `lib/features/talisman/data/services/talisman_service.dart`, `20250825000001_create_talisman_tables.sql` | Public read |

#### 5. Date-Related Tables

| Table | Purpose | Migration File | RLS Applied |
|-------|---------|----------------|-------------|
| `korean_holidays` | Korean holiday information | `20240820000001_create_korean_holidays.sql` | Public read |
| `auspicious_days` | Auspicious and inauspicious days | `20240820000001_create_korean_holidays.sql` | Public read |
| `popular_regions` | Regional popularity statistics | `20250829000002_create_popular_regions_table.sql` | Public read |

#### 6. Miscellaneous Tables

| Table | Purpose | Migration File | RLS Applied |
|-------|---------|----------------|-------------|
| `todos` | User task management | `create_todos_table.sql` | ✅ User-only access |
| `migration_log` | Database migration history | `20250119000004_create_indexes_and_functions.sql` | Service role only |
| `crawling_logs` | Celebrity data crawling history | `20250826000003_add_crawling_metadata.sql` | Service role only |

### Table Relationships

```
auth.users (Supabase Auth)
    ├── user_profiles (1:1)
    ├── pets (1:N)
    ├── user_talismans (1:N)
    ├── fortune_history (1:N)
    ├── fortune_cache (1:N)
    ├── user_statistics (1:1)
    └── todos (1:N)

celebrities (Independent)
    └── celebrity_master_list (Related)

korean_holidays (Independent)
auspicious_days (Independent)
popular_regions (Independent)
```

---

## Schema Details

### Core Table Schemas

#### user_profiles

**Purpose**: Store user profile information linked to Supabase Auth

```sql
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id),
    name TEXT,
    birth_date DATE,
    gender TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

**RLS Policy**:
```sql
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);
```

**Indexes**:
```sql
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
```

#### pets

**Purpose**: Store pet profile information for fortune calculations

```sql
CREATE TABLE pets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    age INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

**RLS Policy**:
```sql
CREATE POLICY "Users can manage own pets" ON pets
    FOR ALL USING (auth.uid() = user_id);
```

**Indexes**:
```sql
CREATE INDEX idx_pets_user_id ON pets(user_id);
```

#### fortune_cache

**Purpose**: Cache fortune results to optimize performance

```sql
CREATE TABLE fortune_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    fortune_type TEXT NOT NULL,
    cache_data JSONB NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

**RLS Policy**:
```sql
CREATE POLICY "Users can access own cache" ON fortune_cache
    FOR ALL USING (auth.uid() = user_id);
```

**Indexes**:
```sql
CREATE INDEX idx_fortune_cache_user_id ON fortune_cache(user_id);
CREATE INDEX idx_fortune_cache_expires_at ON fortune_cache(expires_at);
CREATE INDEX idx_fortune_cache_user_type ON fortune_cache(user_id, fortune_type);
```

#### fortune_history

**Purpose**: Track user fortune query history

```sql
CREATE TABLE fortune_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    fortune_type TEXT NOT NULL,
    fortune_date DATE NOT NULL,
    result_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

**RLS Policy**:
```sql
CREATE POLICY "Users can manage own fortune history" ON fortune_history
    FOR ALL USING (auth.uid() = user_id);
```

**Indexes**:
```sql
CREATE INDEX idx_fortune_history_user_id ON fortune_history(user_id);
CREATE INDEX idx_fortune_history_date ON fortune_history(fortune_date);
CREATE INDEX idx_fortune_history_user_date ON fortune_history(user_id, fortune_date);
```

#### user_talismans

**Purpose**: Store user talisman inventory

```sql
CREATE TABLE user_talismans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    talisman_type TEXT NOT NULL,
    obtained_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

**RLS Policy**:
```sql
CREATE POLICY "Users can manage own talismans" ON user_talismans
    FOR ALL USING (auth.uid() = user_id);
```

**Indexes**:
```sql
CREATE INDEX idx_user_talismans_user_id ON user_talismans(user_id);
CREATE INDEX idx_user_talismans_active ON user_talismans(user_id, is_active);
```

### Storage Buckets and Policies

#### profile-images Bucket

**Purpose**: Store user profile images

**Migration**: `20250929130000_create_storage_buckets_and_policies.sql`

**Storage Policy**:
```sql
-- Create public bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true);

-- Users can upload/update/delete their own files
CREATE POLICY "Users can manage own profile images"
ON storage.objects FOR ALL
USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- All users can view profile images
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-images');
```

**File Constraints**:
- Maximum file size: 5MB
- Allowed formats: JPEG, PNG, WebP
- Path structure: `{user_id}/{filename}`

**Service Integration**: `SupabaseStorageService.ensureBucketExists()` performs real-time permission verification

---

## Celebrity Database

### Overview

The celebrity database schema was completely redesigned in January 2025 to support flexible, extensible celebrity information storage across various profession types.

### Design Principles

- **Flexibility**: JSON fields for profession-specific data
- **Extensibility**: Easy to add new profession types
- **Performance**: Optimized indexes for fast search and filtering
- **Internationalization**: Multi-language name and alias support

### celebrities Table Schema

#### Core Structure

```sql
CREATE TABLE public.celebrities (
    -- Core identity fields (required)
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,                           -- Stage name
    birth_date DATE NOT NULL,                     -- Birth date
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),

    -- Extended identity fields (optional)
    stage_name TEXT,                              -- Stage name if different from name
    legal_name TEXT,                              -- Legal name
    aliases TEXT[] DEFAULT '{}',                  -- Alternative names/nicknames
    nationality TEXT DEFAULT '한국',               -- Nationality
    birth_place TEXT,                             -- Birth place
    birth_time TIME DEFAULT '12:00',              -- Birth time

    -- Professional information
    celebrity_type TEXT NOT NULL CHECK (celebrity_type IN (
        'pro_gamer', 'streamer', 'politician', 'business',
        'solo_singer', 'idol_member', 'actor', 'athlete'
    )),
    active_from INTEGER,                          -- Debut/professional conversion year
    agency_management TEXT,                       -- Agency/management
    languages TEXT[] DEFAULT '{"한국어"}',         -- Languages spoken

    -- External references
    external_ids JSONB DEFAULT '{}',              -- External service links

    -- Profession-specific data
    profession_data JSONB DEFAULT '{}',           -- Profession-specific information

    -- General fields
    notes TEXT,                                   -- Notes

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

#### Field Details

**Basic Identity (Required)**:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | TEXT | Unique identifier | "singer_아이유", "actor_박서준" |
| `name` | TEXT | Stage/activity name | "아이유", "박서준" |
| `birth_date` | DATE | Birth date | "1993-05-16" |
| `gender` | TEXT | Gender | "male", "female", "other" |

**Extended Identity (Optional)**:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `stage_name` | TEXT | Stage name (if different) | "IU" |
| `legal_name` | TEXT | Legal name | "이지은" |
| `aliases` | TEXT[] | Alternative names/nicknames | ["아이유", "IU", "이지은"] |
| `nationality` | TEXT | Nationality | "한국", "미국" |
| `birth_place` | TEXT | Birth place | "서울특별시 종로구" |
| `birth_time` | TIME | Birth time | "14:30" |

**Professional Information**:

| Field | Type | Description | Possible Values |
|-------|------|-------------|-----------------|
| `celebrity_type` | TEXT | Profession type | "pro_gamer", "streamer", "politician", "business", "solo_singer", "idol_member", "actor", "athlete" |
| `active_from` | INTEGER | Debut/conversion year | 2008, 2019 |
| `agency_management` | TEXT | Agency/management | "EDAM 엔터테인먼트" |
| `languages` | TEXT[] | Languages spoken | ["한국어", "영어", "일본어"] |

**External References** (`external_ids` JSONB):

```json
{
  "wikipedia": "https://ko.wikipedia.org/wiki/아이유",
  "imdb": "https://www.imdb.com/name/nm4710923/",
  "youtube": "https://www.youtube.com/@dlwlrma",
  "twitch": "https://twitch.tv/username",
  "instagram": "https://instagram.com/dlwlrma",
  "x": "https://x.com/dlwlrma"
}
```

### Profession-Specific Data

Each profession type stores specialized information in the `profession_data` JSONB field:

#### 1. Pro Gamer (pro_gamer)

```json
{
  "game_title": "League of Legends",
  "primary_role": "Mid",
  "team": "T1",
  "league_region": "LCK",
  "jersey_number": "1",
  "career_highlights": ["2023 월드 챔피언십 우승"],
  "ign": "Faker",
  "pro_debut": "2013-02",
  "retired": false
}
```

#### 2. Streamer (streamer)

```json
{
  "main_platform": "twitch",
  "channel_url": "https://twitch.tv/username",
  "affiliation": "파트너",
  "content_genres": ["게임", "토크"],
  "stream_schedule": "평일 오후 2-8시",
  "first_stream_date": "2020-01",
  "avg_viewers_bucket": "large"
}
```

#### 3. Politician (politician)

```json
{
  "party": "더불어민주당",
  "current_office": "국회의원",
  "constituency": "서울 종로구",
  "term_start": "2020-05-30",
  "term_end": "2024-05-29",
  "previous_offices": ["서울시장"],
  "ideology_tags": ["진보"]
}
```

#### 4. Business Leader (business)

```json
{
  "company_name": "삼성전자",
  "title": "CEO",
  "industry": "전자/반도체",
  "founded_year": "1969",
  "board_memberships": ["삼성물산"],
  "notable_ventures": ["삼성 바이오로직스"]
}
```

#### 5. Solo Singer (solo_singer)

```json
{
  "debut_date": "2008-09",
  "label": "EDAM 엔터테인먼트",
  "genres": ["발라드", "팝", "R&B"],
  "fandom_name": "유애나",
  "vocal_range": "소프라노",
  "notable_tracks": ["좋은 날", "Through the Night", "Celebrity"]
}
```

#### 6. Idol Member (idol_member)

```json
{
  "group_name": "BTS",
  "position": ["vocal", "leader"],
  "debut_date": "2013-06-13",
  "label": "HYBE 엔터테인먼트",
  "fandom_name": "ARMY",
  "sub_units": [],
  "solo_activities": ["Indigo 앨범"]
}
```

#### 7. Actor (actor)

```json
{
  "acting_debut": "2011",
  "agency": "매니지먼트 숲",
  "specialties": ["film", "tv"],
  "notable_works": ["기생충", "옥자"],
  "awards": ["아카데미 작품상"]
}
```

#### 8. Athlete (athlete)

```json
{
  "sport": "축구",
  "position_role": "미드필더",
  "team": "토트넘 홋스퍼",
  "league": "프리미어리그",
  "dominant_hand_foot": "right",
  "pro_debut": "2008",
  "career_highlights": ["2018 월드컵 16강"],
  "records_personal_bests": ["EPL 시즌 최다골 23골"]
}
```

### Indexes

Performance optimization indexes:

```sql
-- Basic indexes
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
CREATE INDEX idx_celebrities_celebrity_type ON public.celebrities(celebrity_type);
CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);
CREATE INDEX idx_celebrities_gender ON public.celebrities(gender);

-- Composite indexes
CREATE INDEX idx_celebrities_type_birth_date ON public.celebrities(celebrity_type, birth_date);
CREATE INDEX idx_celebrities_type_name ON public.celebrities(celebrity_type, name);

-- GIN indexes (for array/JSON search)
CREATE INDEX idx_celebrities_aliases ON public.celebrities USING GIN(aliases);
CREATE INDEX idx_celebrities_languages ON public.celebrities USING GIN(languages);
CREATE INDEX idx_celebrities_external_ids ON public.celebrities USING GIN(external_ids);
CREATE INDEX idx_celebrities_profession_data ON public.celebrities USING GIN(profession_data);

-- Full-text search index
CREATE INDEX idx_celebrities_search ON public.celebrities USING GIN(
    to_tsvector('simple', name || ' ' || COALESCE(stage_name, '') || ' ' || COALESCE(legal_name, '') || ' ' || array_to_string(aliases, ' '))
);
```

### Helper Functions

#### Search Functions

```sql
-- Comprehensive search
CREATE OR REPLACE FUNCTION search_celebrities(
    search_query TEXT DEFAULT NULL,
    celebrity_type_filter TEXT DEFAULT NULL,
    gender_filter TEXT DEFAULT NULL,
    nationality_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities;

-- Search by type
CREATE OR REPLACE FUNCTION get_celebrities_by_type(
    type_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities;

-- Random selection
CREATE OR REPLACE FUNCTION get_random_celebrities(
    limit_count INTEGER DEFAULT 10,
    type_filter TEXT DEFAULT NULL
)
RETURNS SETOF celebrities;
```

#### Profession-Specific Search Functions

```sql
-- Pro gamers (by game)
CREATE OR REPLACE FUNCTION get_pro_gamers_by_game(game_title TEXT, limit_count INTEGER DEFAULT 50);

-- Streamers (by platform)
CREATE OR REPLACE FUNCTION get_streamers_by_platform(platform TEXT, limit_count INTEGER DEFAULT 50);

-- Politicians (by party)
CREATE OR REPLACE FUNCTION get_politicians_by_party(party_name TEXT, limit_count INTEGER DEFAULT 50);

-- Business leaders (by industry)
CREATE OR REPLACE FUNCTION get_business_leaders_by_industry(industry_name TEXT, limit_count INTEGER DEFAULT 50);

-- Idol members (by group)
CREATE OR REPLACE FUNCTION get_idol_members_by_group(group_name TEXT, limit_count INTEGER DEFAULT 50);

-- Athletes (by sport)
CREATE OR REPLACE FUNCTION get_athletes_by_sport(sport_name TEXT, limit_count INTEGER DEFAULT 50);
```

### Analytics View

```sql
CREATE OR REPLACE VIEW celebrity_analytics AS
SELECT
    celebrity_type,
    COUNT(*) as total_count,
    COUNT(DISTINCT nationality) as unique_nationalities,
    ROUND(AVG(EXTRACT(YEAR FROM birth_date)), 1) as avg_birth_year,
    MIN(birth_date) as oldest_birth_date,
    MAX(birth_date) as youngest_birth_date,
    COUNT(*) FILTER (WHERE gender = 'male') as male_count,
    COUNT(*) FILTER (WHERE gender = 'female') as female_count,
    COUNT(*) FILTER (WHERE external_ids != '{}') as with_external_links
FROM public.celebrities
GROUP BY celebrity_type
ORDER BY total_count DESC;
```

### Security and Permissions

#### Row Level Security (RLS)

```sql
-- Public read access
CREATE POLICY "Anyone can view celebrities" ON public.celebrities
    FOR SELECT USING (true);

-- Service role can modify
CREATE POLICY "Service role can manage celebrities" ON public.celebrities
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');
```

### Flutter Model Integration

#### CelebrityType Enum

```dart
enum CelebrityType {
  @JsonValue('pro_gamer')
  proGamer('프로게이머'),

  @JsonValue('streamer')
  streamer('스트리머'),

  @JsonValue('politician')
  politician('정치인'),

  @JsonValue('business')
  business('기업인'),

  @JsonValue('solo_singer')
  soloSinger('솔로 가수'),

  @JsonValue('idol_member')
  idolMember('아이돌 멤버'),

  @JsonValue('actor')
  actor('배우'),

  @JsonValue('athlete')
  athlete('운동선수');

  final String displayName;
  const CelebrityType(this.displayName);
}
```

#### Field Mapping

| DB Field | Flutter Field | Type | Description |
|----------|--------------|------|-------------|
| `id` | `id` | String | Unique identifier |
| `name` | `name` | String | Stage/activity name |
| `birth_date` | `birthDate` | DateTime | Birth date |
| `celebrity_type` | `celebrityType` | CelebrityType | Profession type |
| `external_ids` | `externalIds` | ExternalIds? | External references |
| `profession_data` | `professionData` | Map<String, dynamic>? | Profession-specific data |

---

## API Usage Patterns

### Common Query Examples

#### 1. Basic Searches

```sql
-- Search by name
SELECT * FROM search_celebrities('아이유');

-- Get all pro gamers
SELECT * FROM get_celebrities_by_type('pro_gamer');

-- Get League of Legends players
SELECT * FROM get_pro_gamers_by_game('League of Legends');
```

#### 2. Complex Filtering

```sql
-- Female solo singers born in the 1990s
SELECT * FROM get_celebrities_by_birth_year_range(1990, 1999, 'solo_singer')
WHERE gender = 'female';

-- Celebrities with Instagram accounts
SELECT * FROM get_celebrities_with_external_links('instagram');

-- Athletes by sport and nationality
SELECT * FROM get_athletes_by_sport('축구')
WHERE nationality = '한국';
```

#### 3. Statistics and Analytics

```sql
-- View statistics by profession
SELECT * FROM celebrity_analytics;

-- Overall statistics
SELECT get_celebrity_statistics();

-- Count by gender and type
SELECT celebrity_type, gender, COUNT(*)
FROM celebrities
GROUP BY celebrity_type, gender
ORDER BY celebrity_type, gender;
```

### Flutter Service Usage

#### Basic Celebrity Queries

```dart
// Get all celebrities
final celebrities = await celebrityService.getAllCelebrities();

// Get by type
final actors = await celebrityService.getCelebritiesByType(CelebrityType.actor);

// Search celebrities
final results = await celebrityService.searchCelebrities('김');

// Get random celebrities
final random = await celebrityService.getRandomCelebrities(count: 10);
```

#### Fortune Cache Operations

```dart
// Cache fortune result
await cacheService.cacheFortune(
  userId: user.id,
  fortuneType: 'daily',
  data: fortuneData,
  expiresAt: DateTime.now().add(Duration(hours: 24)),
);

// Retrieve cached fortune
final cached = await cacheService.getCachedFortune(
  userId: user.id,
  fortuneType: 'daily',
);

// Clear expired cache
await cacheService.clearExpiredCache();
```

#### Fortune History Tracking

```dart
// Save fortune history
await historyService.saveFortune(
  userId: user.id,
  fortuneType: 'celebrity',
  fortuneDate: DateTime.now(),
  result: fortuneResult,
);

// Get user fortune history
final history = await historyService.getUserHistory(
  userId: user.id,
  limit: 50,
);

// Get history by date range
final rangeHistory = await historyService.getHistoryByDateRange(
  userId: user.id,
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime(2025, 12, 31),
);
```

### Performance Tips

#### 1. Use Appropriate Indexes

- Always filter on indexed columns first
- Use composite indexes for multi-column queries
- Leverage GIN indexes for JSON/array searches

#### 2. Limit Result Sets

```sql
-- Always use LIMIT for large result sets
SELECT * FROM celebrities LIMIT 100;

-- Use pagination
SELECT * FROM celebrities
ORDER BY id
LIMIT 50 OFFSET 100;
```

#### 3. Cache Frequently Accessed Data

- Use `fortune_cache` table for repeated fortune queries
- Cache celebrity data in app memory for session duration
- Implement proper cache expiration strategies

#### 4. Optimize JSON Queries

```sql
-- Use jsonb operators for efficient JSON queries
SELECT * FROM celebrities
WHERE profession_data->>'game_title' = 'League of Legends';

-- Use GIN index for JSON containment queries
SELECT * FROM celebrities
WHERE profession_data @> '{"retired": false}';
```

#### 5. Monitor Query Performance

```sql
-- Use EXPLAIN ANALYZE to profile queries
EXPLAIN ANALYZE
SELECT * FROM celebrities
WHERE celebrity_type = 'actor'
AND birth_date > '1990-01-01';

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE tablename = 'celebrities';
```

---

## Migration Guide

### Overview

This section documents the complete migration process from the legacy celebrity schema to the new flexible schema implemented in January 2025.

### Migration Phases

#### Phase 1: Backup (20250119000001)

**Purpose**: Create safety backup for rollback capability

```sql
-- File: 20250119000001_backup_existing_celebrities.sql

-- Backup existing data
CREATE TABLE IF NOT EXISTS public.celebrities_backup AS
SELECT * FROM public.celebrities;

-- Verify backup
SELECT COUNT(*) FROM public.celebrities_backup;
```

**Verification**:
- Confirm backup record count matches source
- Check `migration_log` table for success entry

#### Phase 2: New Schema Creation (20250119000002)

**Purpose**: Create new table structure with updated constraints

```sql
-- File: 20250119000002_create_new_celebrity_schema.sql

-- Drop existing table
DROP TABLE IF EXISTS public.celebrities CASCADE;

-- Create new table with updated schema
CREATE TABLE public.celebrities (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    celebrity_type TEXT NOT NULL CHECK (celebrity_type IN (
        'pro_gamer', 'streamer', 'politician', 'business',
        'solo_singer', 'idol_member', 'actor', 'athlete'
    )),
    -- ... additional fields
);
```

**Key Changes**:
- `category` → `celebrity_type`: Updated enum values and categorization
- `additional_info` → `profession_data`: Structured JSON schema
- Removed fields: `popularity_score`, `is_active`
- Added field: `external_ids` JSONB
- New indexes and search functions

#### Phase 3: Data Migration (20250119000003)

**Purpose**: Transform existing data to new schema format

```sql
-- File: 20250119000003_migrate_existing_data.sql

-- Category mapping function
CREATE OR REPLACE FUNCTION determine_celebrity_type(category TEXT, name TEXT)
RETURNS TEXT AS $$
BEGIN
    IF category = 'singer' THEN
        -- Distinguish between group and solo
        IF name IN ('BTS', '블랙핑크', '트와이스', ...) THEN
            RETURN 'idol_member';
        ELSE
            RETURN 'solo_singer';
        END IF;
    ELSIF category = 'politician' THEN
        RETURN 'politician';
    -- ... additional mapping rules
    END IF;
END;
$$;

-- Transform and insert data
INSERT INTO public.celebrities (
    id, name, birth_date, gender, celebrity_type,
    -- ... other fields
)
SELECT
    b.id,
    b.name,
    b.birth_date::DATE,
    CASE WHEN b.gender = 'mixed' THEN 'other' ELSE b.gender END,
    determine_celebrity_type(b.category, b.name),
    -- ... transformation logic
FROM public.celebrities_backup b;
```

**Data Transformation Rules**:

| Legacy Field | New Field | Transformation |
|--------------|-----------|----------------|
| `category` | `celebrity_type` | singer → solo_singer/idol_member (context-dependent) |
| `gender = 'mixed'` | `gender = 'other'` | Value mapping |
| `additional_info` | `profession_data` | JSON structure standardization |
| `full_saju_data` | `notes` | Legacy data preserved in notes |
| `nationality = NULL` | `nationality = '한국'` | Default value assignment |

#### Phase 4: Indexes and Functions (20250119000004)

**Purpose**: Optimize performance and add convenience features

```sql
-- File: 20250119000004_create_indexes_and_functions.sql

-- Performance optimization indexes
CREATE INDEX idx_celebrities_type_birth_date ON public.celebrities(celebrity_type, birth_date);
CREATE INDEX idx_celebrities_search ON public.celebrities USING GIN(...);

-- Profession-specific search functions
CREATE OR REPLACE FUNCTION get_pro_gamers_by_game(game_title TEXT, limit_count INTEGER DEFAULT 50);
CREATE OR REPLACE FUNCTION get_streamers_by_platform(platform TEXT, limit_count INTEGER DEFAULT 50);
-- ... additional helper functions

-- Analytics view
CREATE OR REPLACE VIEW celebrity_analytics AS ...;
```

#### Phase 5: Cleanup (20250119000005)

**Purpose**: Remove deprecated tables and functions, add constraints

```sql
-- File: 20250119000005_cleanup_old_tables.sql

-- Remove deprecated tables
DROP TABLE IF EXISTS public.celebrity_master_list CASCADE;
DROP TABLE IF EXISTS public.celebrity_saju CASCADE;

-- Remove incompatible functions
DROP FUNCTION IF EXISTS public.get_celebrities_by_category(TEXT);
DROP FUNCTION IF EXISTS public.get_popular_celebrities(INTEGER);

-- Add data integrity constraints
ALTER TABLE public.celebrities
ADD CONSTRAINT check_non_empty_name CHECK (length(trim(name)) > 0);

-- Update policies
CREATE POLICY "Service role can delete celebrities" ON public.celebrities
    FOR DELETE USING (auth.jwt() ->> 'role' = 'service_role');
```

### Execution Methods

#### Using Supabase CLI

```bash
# 1. Test migration locally
supabase db reset

# 2. Apply to production
supabase db push

# 3. Verify migration status
supabase migration list
```

#### Manual Execution (Production)

```bash
# Execute migrations in order
psql "postgresql://..." -f supabase/migrations/20250119000001_backup_existing_celebrities.sql
psql "postgresql://..." -f supabase/migrations/20250119000002_create_new_celebrity_schema.sql
psql "postgresql://..." -f supabase/migrations/20250119000003_migrate_existing_data.sql
psql "postgresql://..." -f supabase/migrations/20250119000004_create_indexes_and_functions.sql
psql "postgresql://..." -f supabase/migrations/20250119000005_cleanup_old_tables.sql
```

### Verification and Testing

#### 1. Data Integrity Verification

```sql
-- Compare record counts
SELECT 'backup' as source, COUNT(*) FROM celebrities_backup
UNION ALL
SELECT 'new' as source, COUNT(*) FROM celebrities;

-- Check for NULL required fields
SELECT COUNT(*) as null_names FROM celebrities WHERE name IS NULL OR name = '';
SELECT COUNT(*) as null_birth_dates FROM celebrities WHERE birth_date IS NULL;
SELECT COUNT(*) as invalid_types FROM celebrities WHERE celebrity_type NOT IN (
    'pro_gamer', 'streamer', 'politician', 'business',
    'solo_singer', 'idol_member', 'actor', 'athlete'
);

-- Verify foreign key integrity
SELECT COUNT(*) as orphaned_records FROM celebrities c
LEFT JOIN other_table o ON c.id = o.celebrity_id
WHERE o.celebrity_id IS NULL;
```

#### 2. Function Testing

```sql
-- Test search functions
SELECT COUNT(*) FROM search_celebrities('아이유');
SELECT COUNT(*) FROM get_celebrities_by_type('solo_singer');
SELECT COUNT(*) FROM get_pro_gamers_by_game('League of Legends');

-- Test index performance
EXPLAIN ANALYZE SELECT * FROM celebrities
WHERE celebrity_type = 'actor' AND birth_date > '1990-01-01';

-- Test JSON field searches
SELECT COUNT(*) FROM celebrities
WHERE profession_data->>'game_title' = 'League of Legends';
```

#### 3. Flutter App Integration Testing

```dart
// 1. Basic retrieval test
final celebrities = await celebrityService.getAllCelebrities();
print('Total celebrities: ${celebrities.length}');

// 2. Type-based retrieval test
final actors = await celebrityService.getCelebritiesByType(CelebrityType.actor);
print('Total actors: ${actors.length}');

// 3. Search test
final searchResults = await celebrityService.searchCelebrities('김');
print('Search results: ${searchResults.length}');

// 4. JSON serialization test
final celebrity = celebrities.first;
final json = celebrity.toJson();
final restored = Celebrity.fromJson(json);
assert(celebrity.id == restored.id);
```

### Rollback Plan

#### Emergency Rollback (Migration Failure)

```sql
-- 1. Drop new table
DROP TABLE IF EXISTS public.celebrities CASCADE;

-- 2. Restore from backup
CREATE TABLE public.celebrities AS SELECT * FROM celebrities_backup;

-- 3. Recreate legacy indexes
CREATE INDEX idx_celebrities_category ON public.celebrities(category);
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
-- ... other legacy indexes

-- 4. Restore legacy functions
CREATE OR REPLACE FUNCTION get_celebrities_by_category(category_name TEXT) ...;
```

#### Gradual Rollback (Production Issues)

1. **Read-only Mode**: Allow reads from new schema, writes to legacy schema
2. **Data Synchronization**: Real-time sync between legacy and new schemas
3. **Phased Transition**: Gradually transition features to new schema
4. **Complete Rollback**: Revert all features to legacy schema

### Performance Impact Analysis

#### Expected Performance Changes

| Operation | Legacy Performance | New Schema Performance | Improvement |
|-----------|-------------------|------------------------|-------------|
| Name search | 100ms | 50ms | +100% |
| Category/type retrieval | 80ms | 30ms | +167% |
| Complex search | 200ms | 120ms | +67% |
| JSON field search | N/A | 150ms | New feature |

#### Optimization Recommendations

1. **Index Monitoring**: Optimize indexes based on query patterns
2. **JSON Field Optimization**: Create partial indexes for frequently queried JSON keys
3. **Partitioning**: Consider partitioning by celebrity_type as data grows
4. **Caching**: Implement Redis caching for frequently accessed data

### Troubleshooting

#### Common Issues

**1. Character Encoding Problems**

```sql
-- Symptom: Korean names appear garbled
-- Solution: Verify and correct database encoding
SHOW client_encoding;
SET client_encoding = 'UTF8';
```

**2. JSON Field Parsing Errors**

```sql
-- Symptom: Parsing errors in profession_data field
-- Solution: Validate JSON and fix
SELECT id, name FROM celebrities WHERE NOT (profession_data::text)::json IS NOT NULL;
UPDATE celebrities SET profession_data = '{}' WHERE profession_data IS NULL OR profession_data::text = '';
```

**3. Foreign Key Reference Errors**

```sql
-- Symptom: celebrity_id reference errors in other tables
-- Solution: Update IDs in referencing tables
UPDATE other_table SET celebrity_id = new_mapping.new_id
FROM id_mapping new_mapping
WHERE other_table.celebrity_id = new_mapping.old_id;
```

#### Performance Diagnosis

```sql
-- 1. Identify slow queries
SELECT query, mean_time, calls
FROM pg_stat_statements
WHERE query LIKE '%celebrities%'
ORDER BY mean_time DESC;

-- 2. Check index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename = 'celebrities';

-- 3. Update table statistics
ANALYZE celebrities;
```

### Post-Migration Tasks

#### 1. Monitoring Setup
- Configure query performance monitoring dashboard
- Track data growth rates
- Monitor error rates

#### 2. Documentation Updates
- Update API documentation
- Update Flutter app development guide
- Update operations manual

#### 3. Team Training
- Train on new schema structure
- Train on new search function usage
- Share troubleshooting guide

---

## Security and Performance

### Security Best Practices

#### Row Level Security (RLS)

**RLS-Enabled Tables** (User-only access):
- `user_profiles`: Users can only access their own profile
- `pets`: Users can only access their own pets
- `user_talismans`: Users can only access their own talismans
- `fortune_history`: Users can only access their own history
- `fortune_cache`: Users can only access their own cache
- `user_statistics`: Users can only access their own statistics

**Public Tables** (No RLS):
- `celebrities`: Read-only for all users
- `korean_holidays`: Read-only for all users
- `auspicious_days`: Read-only for all users
- `popular_regions`: Read-only for all users

**Service Role Tables**:
- `migration_log`: Service role only
- `crawling_logs`: Service role only

#### Storage Security

**profile-images Bucket Policies**:
- Users can upload/update/delete only their own files
- All users can view profile images (public bucket)
- File size limit: 5MB
- Allowed formats: JPEG, PNG, WebP

### Performance Optimization

#### Caching Strategy

**Fortune Cache Table**:
- Cache fortune results to minimize API calls
- Set appropriate expiration times
- Regularly clean expired cache entries

**Fortune Stories Table**:
- Reuse generated stories for better performance
- Store commonly requested story types
- Implement LRU cache eviction

#### Index Usage Guidelines

1. **Use Composite Indexes** for multi-column filters
2. **GIN Indexes** for JSON and array searches
3. **Partial Indexes** for frequently filtered subsets
4. **Full-Text Search Indexes** for name/text searches

#### Query Optimization Tips

1. **Always use LIMIT** for large result sets
2. **Pagination** for better user experience
3. **Avoid SELECT \*** when only specific columns needed
4. **Use prepared statements** to prevent SQL injection
5. **Monitor query performance** with EXPLAIN ANALYZE

### Monitoring and Maintenance

#### Regular Maintenance Tasks

1. **Daily**:
   - Automated backups
   - Cache cleanup
   - Error log review

2. **Weekly**:
   - Query performance analysis
   - Index usage review
   - Storage usage monitoring

3. **Monthly**:
   - Data quality audit
   - Security policy review
   - Performance optimization review

#### Performance Metrics to Track

- Query response times
- Cache hit rates
- Index usage statistics
- Storage bucket usage
- RLS policy effectiveness
- Error rates by table

---

## Important Notes

### Critical Database Rules

#### ⚠️ Pre-Creation Checklist for New Tables

**Always verify before creating a new table:**

1. **Check Existing Tables**:
   - Review this document first (`docs/DATABASE_GUIDE.md`)
   - Search codebase: `grep -r "table_name" lib/`
   - Review migration files for creation history
   - Verify table existence in actual database

2. **Analyze Table Structure**:
   - Check existing model classes in code
   - Review service files for field usage
   - Understand RLS policy requirements
   - Identify index requirements

3. **Prevent Duplication**:
   - Never create duplicate migration files
   - Verify no conflicts with existing tables
   - Check for naming collisions

#### Example: pets Table Verification ✅

- **User Confirmation**: "팻테이블은 이미 있어" (Pet table already exists)
- **Code Confirmation**: `lib/services/pet_service.dart` uses 'pets' table
- **Model Confirmation**: `lib/data/models/pet_profile.dart` defines PetProfile class
- **Status**: Table exists and is integrated with code
- **Lesson**: Always verify table existence before creation!

### Migration File Management

- All tables managed via `supabase/migrations/` SQL files
- Timestamp-based sequential execution (YYYYMMDD_HHMMSS format)
- Safe schema changes through backup tables

### Storage Buckets and Policies ✅ Verified

- **Storage Bucket**: `profile-images` (profile image storage)
- **Migration**: `20250929130000_create_storage_buckets_and_policies.sql`
- **Policies**:
  - Users can upload/update/delete only in their own folder
  - All users can view profile images (public bucket)
  - File size limit: 5MB
  - Allowed formats: JPEG, PNG, WebP
- **Permission Verification**: `SupabaseStorageService.ensureBucketExists()` performs real-time permission checks

### Caching Strategy

- `fortune_cache`: Cache fortune results to minimize API calls
- `fortune_stories`: Reuse generated stories for improved performance

---

**Document Maintainer**: Claude Code
**Purpose**: Comprehensive database tracking and management reference
**Status**: Active and maintained