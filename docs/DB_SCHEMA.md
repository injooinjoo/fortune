# 유명인 데이터베이스 스키마 (Celebrity Database Schema)

## 개요

유명인 데이터베이스는 다양한 직업군의 유명인 정보를 효율적으로 저장하고 관리하기 위한 새로운 스키마입니다. 2025년 1월에 기존 스키마를 완전히 리뉴얼했습니다.

## 설계 원칙

- **유연성**: JSON 필드를 활용하여 직업별 특화 정보를 저장
- **확장성**: 새로운 직업 유형 추가 시 쉽게 확장 가능
- **성능**: 적절한 인덱스로 빠른 검색 및 필터링 지원
- **국제화**: 다국어 이름 및 별칭 지원

## 핵심 테이블: celebrities

### 기본 구조

```sql
CREATE TABLE public.celebrities (
    -- Core identity fields (필수)
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,                           -- 활동명
    birth_date DATE NOT NULL,                     -- 생년월일
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),

    -- Extended identity fields (선택)
    stage_name TEXT,                              -- 예명
    legal_name TEXT,                              -- 본명
    aliases TEXT[] DEFAULT '{}',                  -- 다른 표기/닉네임
    nationality TEXT DEFAULT '한국',               -- 국적
    birth_place TEXT,                             -- 출생지
    birth_time TIME DEFAULT '12:00',              -- 출생시각

    -- Professional information
    celebrity_type TEXT NOT NULL CHECK (celebrity_type IN (
        'pro_gamer', 'streamer', 'politician', 'business',
        'solo_singer', 'idol_member', 'actor', 'athlete'
    )),
    active_from INTEGER,                          -- 데뷔/프로 전향 연도
    agency_management TEXT,                       -- 소속
    languages TEXT[] DEFAULT '{"한국어"}',         -- 사용 언어

    -- External references
    external_ids JSONB DEFAULT '{}',              -- 외부 참조

    -- Profession-specific data
    profession_data JSONB DEFAULT '{}',           -- 직군별 특화 정보

    -- General fields
    notes TEXT,                                   -- 비고

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

## 필드 상세 설명

### 1. 기본 신원 정보 (필수)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `id` | TEXT | 고유 식별자 | "singer_아이유", "actor_박서준" |
| `name` | TEXT | 활동명 (필수) | "아이유", "박서준" |
| `birth_date` | DATE | 생년월일 (필수) | "1993-05-16" |
| `gender` | TEXT | 성별 (필수) | "male", "female", "other" |

### 2. 확장 신원 정보 (선택)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `stage_name` | TEXT | 예명 (활동명과 다를 때) | "IU" |
| `legal_name` | TEXT | 본명 | "이지은" |
| `aliases` | TEXT[] | 다른 표기/닉네임 | ["아이유", "IU", "이지은"] |
| `nationality` | TEXT | 국적 | "한국", "미국" |
| `birth_place` | TEXT | 출생지 | "서울특별시 종로구" |
| `birth_time` | TIME | 출생시각 | "14:30" |

### 3. 직업 정보

| 필드명 | 타입 | 설명 | 가능한 값 |
|--------|------|------|----------|
| `celebrity_type` | TEXT | 직업 유형 | "pro_gamer", "streamer", "politician", "business", "solo_singer", "idol_member", "actor", "athlete" |
| `active_from` | INTEGER | 데뷔/전향 연도 | 2008, 2019 |
| `agency_management` | TEXT | 소속사/에이전시 | "EDAM 엔터테인먼트" |
| `languages` | TEXT[] | 사용 언어 | ["한국어", "영어", "일본어"] |

### 4. 외부 참조

`external_ids` JSONB 필드에 저장되는 외부 서비스 링크:

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

## 직군별 특화 정보 (profession_data)

각 직업 유형별로 `profession_data` JSONB 필드에 저장되는 특화 정보:

### 1. 프로게이머 (pro_gamer)

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

### 2. 스트리머 (streamer)

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

### 3. 정치인 (politician)

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

### 4. 기업인 (business)

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

### 5. 솔로 가수 (solo_singer)

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

### 6. 아이돌 멤버 (idol_member)

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

### 7. 배우 (actor)

```json
{
  "acting_debut": "2011",
  "agency": "매니지먼트 숲",
  "specialties": ["film", "tv"],
  "notable_works": ["기생충", "옥자"],
  "awards": ["아카데미 작품상"]
}
```

### 8. 운동선수 (athlete)

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

## 인덱스

성능 최적화를 위한 인덱스:

```sql
-- 기본 인덱스
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
CREATE INDEX idx_celebrities_celebrity_type ON public.celebrities(celebrity_type);
CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);
CREATE INDEX idx_celebrities_gender ON public.celebrities(gender);

-- 복합 인덱스
CREATE INDEX idx_celebrities_type_birth_date ON public.celebrities(celebrity_type, birth_date);
CREATE INDEX idx_celebrities_type_name ON public.celebrities(celebrity_type, name);

-- GIN 인덱스 (배열/JSON 검색용)
CREATE INDEX idx_celebrities_aliases ON public.celebrities USING GIN(aliases);
CREATE INDEX idx_celebrities_languages ON public.celebrities USING GIN(languages);
CREATE INDEX idx_celebrities_external_ids ON public.celebrities USING GIN(external_ids);
CREATE INDEX idx_celebrities_profession_data ON public.celebrities USING GIN(profession_data);

-- 전문 검색 인덱스
CREATE INDEX idx_celebrities_search ON public.celebrities USING GIN(
    to_tsvector('simple', name || ' ' || COALESCE(stage_name, '') || ' ' || COALESCE(legal_name, '') || ' ' || array_to_string(aliases, ' '))
);
```

## 헬퍼 함수

### 검색 함수

```sql
-- 종합 검색
CREATE OR REPLACE FUNCTION search_celebrities(
    search_query TEXT DEFAULT NULL,
    celebrity_type_filter TEXT DEFAULT NULL,
    gender_filter TEXT DEFAULT NULL,
    nationality_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities;

-- 직업별 검색
CREATE OR REPLACE FUNCTION get_celebrities_by_type(
    type_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities;

-- 랜덤 선택
CREATE OR REPLACE FUNCTION get_random_celebrities(
    limit_count INTEGER DEFAULT 10,
    type_filter TEXT DEFAULT NULL
)
RETURNS SETOF celebrities;
```

### 직업별 특화 검색 함수

```sql
-- 프로게이머 (게임별)
CREATE OR REPLACE FUNCTION get_pro_gamers_by_game(game_title TEXT, limit_count INTEGER DEFAULT 50);

-- 스트리머 (플랫폼별)
CREATE OR REPLACE FUNCTION get_streamers_by_platform(platform TEXT, limit_count INTEGER DEFAULT 50);

-- 정치인 (정당별)
CREATE OR REPLACE FUNCTION get_politicians_by_party(party_name TEXT, limit_count INTEGER DEFAULT 50);

-- 기업인 (업종별)
CREATE OR REPLACE FUNCTION get_business_leaders_by_industry(industry_name TEXT, limit_count INTEGER DEFAULT 50);

-- 아이돌 (그룹별)
CREATE OR REPLACE FUNCTION get_idol_members_by_group(group_name TEXT, limit_count INTEGER DEFAULT 50);

-- 운동선수 (종목별)
CREATE OR REPLACE FUNCTION get_athletes_by_sport(sport_name TEXT, limit_count INTEGER DEFAULT 50);
```

## 통계 뷰

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

## Flutter 모델 연동

### CelebrityType Enum

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

### 주요 필드 매핑

| DB 필드 | Flutter 필드 | 타입 | 설명 |
|---------|-------------|------|------|
| `id` | `id` | String | 고유 식별자 |
| `name` | `name` | String | 활동명 |
| `birth_date` | `birthDate` | DateTime | 생년월일 |
| `celebrity_type` | `celebrityType` | CelebrityType | 직업 유형 |
| `external_ids` | `externalIds` | ExternalIds? | 외부 참조 |
| `profession_data` | `professionData` | Map<String, dynamic>? | 직업별 데이터 |

## 마이그레이션 가이드

### 기존 데이터에서 변환

1. **celebrities_backup 테이블 생성**: 기존 데이터 백업
2. **새 스키마 적용**: 새로운 테이블 구조 생성
3. **데이터 변환**: 기존 데이터를 새 구조로 마이그레이션
4. **인덱스 및 함수 생성**: 성능 최적화 및 편의 기능
5. **정리**: 기존 테이블 및 호환되지 않는 함수 제거

### 주요 변환 규칙

- `category` → `celebrity_type`: 카테고리 명칭 변경 및 세분화
- `additional_info` → `profession_data`: JSON 구조 표준화
- `사주 데이터` → `notes`: 레거시 데이터는 비고란으로 이동
- `keywords` → `aliases`: 검색용 키워드를 별칭으로 통합

## 보안 및 권한

### Row Level Security (RLS)

```sql
-- 공개 읽기 허용
CREATE POLICY "Anyone can view celebrities" ON public.celebrities
    FOR SELECT USING (true);

-- 서비스 역할만 수정 가능
CREATE POLICY "Service role can manage celebrities" ON public.celebrities
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');
```

## 사용 예시

### 1. 기본 검색

```sql
-- 이름으로 검색
SELECT * FROM search_celebrities('아이유');

-- 프로게이머만 검색
SELECT * FROM get_celebrities_by_type('pro_gamer');

-- 특정 게임의 프로게이머 검색
SELECT * FROM get_pro_gamers_by_game('League of Legends');
```

### 2. 복합 조건 검색

```sql
-- 1990년대 출생 여성 가수
SELECT * FROM get_celebrities_by_birth_year_range(1990, 1999, 'solo_singer')
WHERE gender = 'female';

-- Instagram 계정이 있는 연예인
SELECT * FROM get_celebrities_with_external_links('instagram');
```

### 3. 통계 조회

```sql
-- 직업별 통계
SELECT * FROM celebrity_analytics;

-- 전체 통계
SELECT get_celebrity_statistics();
```

## 향후 확장 계획

1. **새로운 직업 유형 추가**: 작가, 과학자, 요리사 등
2. **다국어 지원 강화**: 이름의 다국어 표기 확장
3. **관계 정보**: 가족, 연인, 소속팀 관계 테이블 추가
4. **이벤트 타임라인**: 경력, 수상, 스캔들 등의 시간순 이벤트
5. **소셜 미디어 통합**: 실시간 팔로워 수, 인기도 지표

## 유지보수

- **정기 백업**: 매일 자동 백업
- **성능 모니터링**: 쿼리 성능 및 인덱스 효율성 추적
- **데이터 품질**: 중복 데이터 및 오류 정기 점검
- **보안 업데이트**: RLS 정책 및 권한 정기 검토